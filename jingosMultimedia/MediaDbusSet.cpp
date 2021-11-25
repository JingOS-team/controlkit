/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Yu Jiashu <yujiashu@jingos.com>
 *
 */

#include "MediaDbusSet.h"
#include <QtDBus/QDBusConnection>
#include <KCoreAddons/KAboutData>
#include <QCoreApplication>
#include <QDebug>

#if defined Q_OS_WIN
#include <Windows.h>
#else
#include <unistd.h>
#endif

static const double MAX_RATE = 1.0;
static const double MIN_RATE = 1.0;

MediaDbusSet::MediaDbusSet(Player *audioPlayer, bool showProgressOnTaskBar, QObject *parent)
    :QDBusAbstractAdaptor(parent)
    ,m_showProgressOnTaskBar(showProgressOnTaskBar)
    ,m_pPlayer(audioPlayer)
    ,m_progressIndicatorSignal(QDBusMessage::createSignal(QStringLiteral("/org/maui/vvave"),
                                                          QStringLiteral("com.canonical.Unity.LauncherEntry"), QStringLiteral("Update")))
{
    initMediaDbusSet();
}

MediaDbusSet::~MediaDbusSet()
{
}

void MediaDbusSet::initMediaDbusSet()
{
    connect(m_pPlayer, &Player::stateChanged, this, &MediaDbusSet::playerPlaybackStateChanged);
    connect(m_pPlayer, &Player::stateChanged, this, &MediaDbusSet::playerIsSeekableChanged);
    connect(m_pPlayer, &Player::posChanged, this, &MediaDbusSet::audioPositionChanged);
    connect(m_pPlayer, &Player::durationChanged, this, &MediaDbusSet::audioDurationChanged);
    connect(m_pPlayer, &Player::volumeChanged, this, &MediaDbusSet::playerVolumeChanged);
    connect( this, &MediaDbusSet::next,m_pPlayer, &Player::next);
    connect( this, &MediaDbusSet::previous,m_pPlayer, &Player::previous);
    connect(m_pPlayer,&Player::urlChanged,this,&MediaDbusSet::onUrlChangeSlot);

    m_volume = m_pPlayer->getVolume() / 100;
    signalPropertiesChange(QStringLiteral("Volume"), Volume());

    m_mediaPlayerPresent = 1;
    QObject::connect(qApp, &QCoreApplication::aboutToQuit, [this](){
        m_metadata.clear();
        signalPropertiesChange(QStringLiteral("Metadata"), Metadata());
    });
}

void MediaDbusSet::quitControls()
{
    m_metadata.clear();
    signalPropertiesChange(QStringLiteral("Metadata"), Metadata());
}

void MediaDbusSet::setShowProgressOnTaskBar(bool value)
{
    m_showProgressOnTaskBar = value;
    if (m_showProgressOnTaskBar) {
        QVariantMap parameters;

        if (m_playState == QMediaPlayer::StoppedState || m_pPlayer->getDuration() == 0) {
            parameters.insert(QStringLiteral("progress-visible"), false);
            parameters.insert(QStringLiteral("progress"), 0);
        } else {
            parameters.insert(QStringLiteral("progress-visible"), true);
            parameters.insert(QStringLiteral("progress"), qRound(static_cast<double>(m_position / m_pPlayer->getDuration())));
        }

        m_progressIndicatorSignal.setArguments({QStringLiteral("application://org.maui.vvave.desktop"), parameters});

        QDBusConnection::sessionBus().send(m_progressIndicatorSignal);
    }
}

QString MediaDbusSet::PlaybackStatus() const
{
    QString result;

    if (!m_pPlayer || m_pPlayer->listNull()) {
        result = QStringLiteral("Stopped");
        return result;
    }

    if (m_pPlayer->getState() == QMediaPlayer::StoppedState) {
        result = QStringLiteral("Stopped");
    } else if (m_pPlayer->getState() == QMediaPlayer::PlayingState) {
        result = QStringLiteral("Playing");
    } else {
        result = QStringLiteral("Paused");
    }

    return result;
}

double MediaDbusSet::Rate() const
{
    return m_rate;
}

void MediaDbusSet::setRate(double newRate)
{
    if (newRate <= 0.0001 && newRate >= -0.0001) {
        Pause();
    } else {
        m_rate = qBound(MinimumRate(), newRate, MaximumRate());
        Q_EMIT rateChanged(m_rate);

        signalPropertiesChange(QStringLiteral("Rate"), Rate());
    }
}

QVariantMap MediaDbusSet::Metadata() const
{
    return m_metadata;
}

double MediaDbusSet::Volume() const
{
    return m_volume;
}

void MediaDbusSet::setVolume(double volume)
{
    if(!m_pPlayer) return;
    m_volume = qBound(0.0, volume, 1.0);
    Q_EMIT volumeChanged(m_volume);

    m_pPlayer->setVolume(100 * m_volume);

    signalPropertiesChange(QStringLiteral("Volume"), Volume());
}

qlonglong MediaDbusSet::Position() const
{
    return m_position;
}

double MediaDbusSet::MinimumRate() const
{
    return MIN_RATE;
}

double MediaDbusSet::MaximumRate() const
{
    return MAX_RATE;
}

bool MediaDbusSet::CanGoNext() const
{
    return m_pPlayer->canPlayNext();
}

bool MediaDbusSet::CanGoPrevious() const
{
    return m_pPlayer->canPlayPre();
}

bool MediaDbusSet::CanPlay() const
{
    return m_pPlayer->canPlay(m_pPlayer->getUrl());
}

bool MediaDbusSet::CanPause() const
{
     return m_canPlay;
}
bool MediaDbusSet::CanSeek() const
{
    return m_pPlayer->seekable();
}

bool MediaDbusSet::CanControl() const
{
    return true;
}

int MediaDbusSet::currentTrack() const
{
    return m_pPlayer->getCurrentIndex();
}

void MediaDbusSet::onUrlChangeSlot()
{
  setCurrentTrack(m_pPlayer->getCurrentIndex());
}

void MediaDbusSet::setCurrentTrack(int newTrackPosition)
{
   if(!m_pPlayer) return;
    m_currentTrack = m_pPlayer->getUrl().toLocalFile();
    m_currentTrackId = QDBusObjectPath(QLatin1String("/org/jingos/jingmedia/playlist/") + QString::number(newTrackPosition)).path();

    emit currentTrackChanged();

    m_metadata = getMetadataOfCurrentTrack();
    signalPropertiesChange(QStringLiteral("Metadata"), Metadata());
}

int MediaDbusSet::mediaPlayerPresent() const
{
    return m_mediaPlayerPresent;
}

void MediaDbusSet::Next()
{
    Q_EMIT next();
}

void MediaDbusSet::Previous()
{
    Q_EMIT previous();
}

void MediaDbusSet::Pause()
{
    if (m_pPlayer || !m_pPlayer->listNull()) {
        m_pPlayer->setPlaying(false);
    }
}

void MediaDbusSet::PlayPause()
{
    if (m_pPlayer || !m_pPlayer->listNull()) {
        if(m_pPlayer->getState() == QMediaPlayer::State::PlayingState){
            m_pPlayer->setPlaying(false);
        } else {
            m_pPlayer->setPlaying(true);
        }
    }
}

void MediaDbusSet::Stop()
{
    if (m_pPlayer || !m_pPlayer->listNull()) {
        m_pPlayer->stop();
    }
}

void MediaDbusSet::Play()
{
    if(!m_pPlayer) return;
     m_pPlayer->setPlaying(true);
}

void MediaDbusSet::Seek(qlonglong Offset)
{
    if(!m_pPlayer) return;
    if (mediaPlayerPresent()) {
        auto offset = (m_position + Offset) ;
         m_pPlayer->setPos(int(offset));
    }
}

void MediaDbusSet::SetPosition(const QDBusObjectPath &trackId, qlonglong pos)
{
    if(!m_pPlayer) return;
    if (trackId.path() == m_currentTrackId) {
        m_pPlayer->setPos(int(pos));
    }
}

void MediaDbusSet::OpenUri(const QString &uri)
{
    Q_UNUSED(uri);
}

void MediaDbusSet::playerPlaybackStateChanged()
{
    signalPropertiesChange(QStringLiteral("PlaybackStatus"), PlaybackStatus());
    Q_EMIT playbackStatusChanged();
    playerIsSeekableChanged();
}

void MediaDbusSet::playerIsSeekableChanged()
{
    if(!m_pPlayer) return;
    m_playerIsSeekableChanged = m_pPlayer->getState() == QMediaPlayer::State::PausedState || m_pPlayer->getState() == QMediaPlayer::State::PlayingState;

    signalPropertiesChange(QStringLiteral("CanSeek"), CanSeek());
    emit canSeekChanged();
}

void MediaDbusSet::audioPositionChanged()
{
    setPropertyPosition(static_cast<int>(m_pPlayer->getPos()));
}

void MediaDbusSet::setPropertyPosition(int newPositionInMs)
{
    if(!m_pPlayer) return;
    m_position = qlonglong(newPositionInMs);

    Q_EMIT Seeked(m_position);

    /* only sent new progress when it has advanced more than 1 %
     * to limit DBus traffic
     */
    const auto incrementalProgress = static_cast<double>(newPositionInMs - m_previousProgressPosition) / m_pPlayer->getDuration();
    if (m_showProgressOnTaskBar && (incrementalProgress > 0.01 || incrementalProgress < 0)) {
        m_previousProgressPosition = newPositionInMs;
        QVariantMap parameters;
        parameters.insert(QStringLiteral("progress-visible"), true);
        parameters.insert(QStringLiteral("progress"), static_cast<double>(newPositionInMs) / m_pPlayer->getDuration());

        m_progressIndicatorSignal.setArguments({QStringLiteral("application://org.kde.index.desktop"), parameters});

        QDBusConnection::sessionBus().send(m_progressIndicatorSignal);
    }
}

void MediaDbusSet::audioDurationChanged()
{
    if(!m_pPlayer) return;
    m_metadata = getMetadataOfCurrentTrack();
    signalPropertiesChange(QStringLiteral("Metadata"), Metadata());

    skipBackwardControlEnabledChanged();
    skipForwardControlEnabledChanged();
    playerPlaybackStateChanged();
    playerIsSeekableChanged();
    setPropertyPosition(static_cast<int>((m_pPlayer->getPos()/(m_pPlayer->getDuration()))));
}

QVariantMap MediaDbusSet::getMetadataOfCurrentTrack()
{
    auto result = QVariantMap();

    if (m_currentTrackId.isEmpty() && !m_pPlayer) {
        return {};
    }

    result[QStringLiteral("mpris:trackid")] = QVariant::fromValue<QDBusObjectPath>(QDBusObjectPath(m_currentTrackId));
    result[QStringLiteral("mpris:length")] = qlonglong(m_pPlayer->getDuration());
    // convert milli-seconds into micro-seconds

    result[QStringLiteral("xesam:title")] = m_pPlayer->title();
    result[QStringLiteral("xesam:url")] = m_pPlayer->getUrl().toLocalFile();
    result[QStringLiteral("xesam:album")] = m_pPlayer->getAlbum();
    result[QStringLiteral("xesam:artist")] = m_pPlayer->getArtist();
    result[QStringLiteral("mpris:artUrl")] = m_pPlayer->getGenre();

    return result;
}

void MediaDbusSet::skipBackwardControlEnabledChanged()
{
    if (!m_pPlayer || m_pPlayer->listNull()) {
        return;
    }

    signalPropertiesChange(QStringLiteral("CanGoPrevious"), CanGoPrevious());
    Q_EMIT canGoPreviousChanged();
}

void MediaDbusSet::skipForwardControlEnabledChanged()
{
    if (!m_pPlayer || m_pPlayer->listNull()) {
        return;
    }

    signalPropertiesChange(QStringLiteral("CanGoNext"), CanGoNext());
    Q_EMIT canGoNextChanged();
}

void MediaDbusSet::playerVolumeChanged()
{
    if(!m_pPlayer) return;
    setVolume(m_pPlayer->getVolume() / 100.0);
}

void MediaDbusSet::setMediaPlayerPresent(int status)
{
    if(!m_pPlayer) return;
    if (m_mediaPlayerPresent != status) {
        m_mediaPlayerPresent = status;
        emit mediaPlayerPresentChanged();

        signalPropertiesChange(QStringLiteral("CanGoNext"), CanGoNext());
        signalPropertiesChange(QStringLiteral("CanGoPrevious"), CanGoPrevious());
        signalPropertiesChange(QStringLiteral("CanPause"), CanPause());
        signalPropertiesChange(QStringLiteral("CanPlay"), CanPlay());
        Q_EMIT canGoNextChanged();
        Q_EMIT canGoPreviousChanged();
        Q_EMIT canPauseChanged();
        Q_EMIT canPlayChanged();
    }
}

void MediaDbusSet::signalPropertiesChange(const QString &property, const QVariant &value)
{
    QVariantMap properties;
    properties[property] = value;
    const int ifaceIndex = metaObject()->indexOfClassInfo("D-Bus Interface");
    QDBusMessage msg = QDBusMessage::createSignal(QStringLiteral("/org/mpris/MediaPlayer2"), QStringLiteral("org.freedesktop.DBus.Properties"), QStringLiteral("PropertiesChanged"));

    msg << QLatin1String(metaObject()->classInfo(ifaceIndex).value());
    msg << properties;
    msg << QStringList();

    QDBusConnection::sessionBus().send(msg);
}

/*********************************************
    application control
**********************************************/

MediaPlayer2::MediaPlayer2(QObject *parent)
    : QDBusAbstractAdaptor(parent)
{
}

MediaPlayer2::~MediaPlayer2() = default;

bool MediaPlayer2::CanQuit() const
{
    return true;
}

bool MediaPlayer2::CanRaise() const
{
    return true;
}
bool MediaPlayer2::HasTrackList() const
{
    return false;
}

void MediaPlayer2::Quit()
{
    QCoreApplication::quit();
}

void MediaPlayer2::Raise()
{
    Q_EMIT raisePlayer();
}

QString MediaPlayer2::Identity() const
{
    return KAboutData::applicationData().displayName();
}

QString MediaPlayer2::DesktopEntry() const
{
    return KAboutData::applicationData().desktopFileName();
}

QStringList MediaPlayer2::SupportedUriSchemes() const
{
    return QStringList() << QStringLiteral("file");
}

QStringList MediaPlayer2::SupportedMimeTypes() const
{
    //    KService::Ptr app = KService::serviceByDesktopName(KCmdLineArgs::aboutData()->appName());

    //    if (app) {
    //        return app->mimeTypes();
    //    }

    return QStringList();
}



Mpris2::Mpris2(QObject *parent)
    : QObject(parent)
{

}

void Mpris2::initDBusService()
{
#if defined Q_OS_LINUX && !defined Q_OS_ANDROID

    QString mspris2Name(QStringLiteral("org.mpris.MediaPlayer2.") + m_playerName);

    bool success = QDBusConnection::sessionBus().registerService(mspris2Name);
    // If the above failed, it's likely because we're not the first instance
    // or the name is already taken. In that event the MPRIS2 spec wants the
    // following:
    if (!success) {
#if defined Q_OS_WIN
        success = QDBusConnection::sessionBus().registerService(mspris2Name + QLatin1String(".instance") + QString::number(GetCurrentProcessId()));
#else
        success = QDBusConnection::sessionBus().registerService(mspris2Name + QLatin1String(".instance") + QString::number(getpid()));
#endif
    }

    if (success) {
        m_mp2 = std::unique_ptr<MediaPlayer2>(new MediaPlayer2(this));
        m_mp2p = std::unique_ptr<MediaDbusSet>(new MediaDbusSet(m_audioPlayer, mShowProgressOnTaskBar, this));

        QDBusConnection::sessionBus().registerObject(QStringLiteral("/org/mpris/MediaPlayer2"), this, QDBusConnection::ExportAdaptors);
        connect(m_mp2.get(), &MediaPlayer2::raisePlayer, this, &Mpris2::raisePlayer);
    }
#endif
}

Mpris2::~Mpris2() = default;

QString Mpris2::playerName() const
{
    return m_playerName;
}

Player *Mpris2::audioPlayer() const
{
    return m_audioPlayer;
}

bool Mpris2::showProgressOnTaskBar() const
{
    return mShowProgressOnTaskBar;
}
void Mpris2::quitControls()
{
#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
    if(m_mp2p)
        m_mp2p->quitControls();
#endif
}

void Mpris2::setPlayerName(const QString &playerName)
{
    if (m_playerName == playerName) {
        return;
    }

    m_playerName = playerName;

#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
    if ( m_audioPlayer && !m_playerName.isEmpty()) {
        if (!m_mp2) {
            initDBusService();
        }
    }
#endif

    Q_EMIT playerNameChanged();
}

void Mpris2::setAudioPlayer(Player *audioPlayer)
{
    if (m_audioPlayer == audioPlayer)
        return;

    m_audioPlayer = audioPlayer;
#if defined Q_OS_LINUX && !defined Q_OS_ANDROID

    if ( m_audioPlayer && !m_playerName.isEmpty()) {
        if (!m_mp2) {
            initDBusService();
        }
    }
#endif
    Q_EMIT audioPlayerChanged();
}

void Mpris2::setShowProgressOnTaskBar(bool value)
{
#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
    m_mp2p->setShowProgressOnTaskBar(value);
    mShowProgressOnTaskBar = value;
    Q_EMIT showProgressOnTaskBarChanged();
#else
    Q_UNUSED(value)
#endif
}

