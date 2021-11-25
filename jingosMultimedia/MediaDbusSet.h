/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Yu Jiashu <yujiashu@jingos.com>
 *
 */

#ifndef MEDIADBUSSET_H
#define MEDIADBUSSET_H

#include "player.h"

#include <QtDBus/QDBusAbstractAdaptor>
#include <QtDBus/QDBusMessage>
#include <QtDBus/QDBusObjectPath>
#include <memory>

class MediaPlayer2;

class MediaDbusSet : public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.mpris.MediaPlayer2.Player")

    Q_PROPERTY(QString PlaybackStatus READ PlaybackStatus NOTIFY playbackStatusChanged)
    Q_PROPERTY(double Rate READ Rate WRITE setRate NOTIFY rateChanged)
    Q_PROPERTY(QVariantMap Metadata READ Metadata NOTIFY playbackStatusChanged)
    Q_PROPERTY(double Volume READ Volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(qlonglong Position READ Position WRITE setPropertyPosition NOTIFY playbackStatusChanged)
    Q_PROPERTY(double MinimumRate READ MinimumRate CONSTANT)
    Q_PROPERTY(double MaximumRate READ MaximumRate CONSTANT)
    Q_PROPERTY(bool CanGoNext READ CanGoNext NOTIFY canGoNextChanged)
    Q_PROPERTY(bool CanGoPrevious READ CanGoPrevious NOTIFY canGoPreviousChanged)
    Q_PROPERTY(bool CanPlay READ CanPlay NOTIFY canPlayChanged)
    Q_PROPERTY(bool CanPause READ CanPause NOTIFY canPauseChanged)
    Q_PROPERTY(bool CanControl READ CanControl NOTIFY canControlChanged)
    Q_PROPERTY(bool CanSeek READ CanSeek NOTIFY canSeekChanged)
    Q_PROPERTY(int currentTrack READ currentTrack WRITE setCurrentTrack NOTIFY currentTrackChanged)
    Q_PROPERTY(int mediaPlayerPresent READ mediaPlayerPresent WRITE setMediaPlayerPresent NOTIFY mediaPlayerPresentChanged)
//    Q_PROPERTY(QString playerName READ playerName WRITE setPlayerName NOTIFY playerNameChanged)
//    Q_PROPERTY(Player *audioPlayer READ audioPlayer WRITE setAudioPlayer NOTIFY audioPlayerChanged)

public:
    MediaDbusSet(Player *audioPlayer, bool showProgressOnTaskBar,QObject *parent = nullptr);
    ~MediaDbusSet();

    void initMediaDbusSet();
    void setShowProgressOnTaskBar(bool value);

    QString PlaybackStatus() const;
    double Rate() const;
    QVariantMap Metadata() const;
    double Volume() const;
    qlonglong Position() const;
    double MinimumRate() const;
    double MaximumRate() const;
    bool CanGoNext() const;
    bool CanGoPrevious() const;
    bool CanPlay() const;
    bool CanPause() const;
    bool CanSeek() const;
    bool CanControl() const;
    int currentTrack() const;
    int mediaPlayerPresent() const;
    void quitControls();

Q_SIGNALS:
    void raisePlayer();
    void Seeked(qlonglong Position);

    void rateChanged(double newRate);
    void volumeChanged(double newVol);
    void playbackStatusChanged();
    void canGoNextChanged();
    void canGoPreviousChanged();
    void canPlayChanged();
    void canPauseChanged();
    void canControlChanged();
    void canSeekChanged();
    void currentTrackChanged();
    void mediaPlayerPresentChanged();
    void next();
    void previous();

public Q_SLOTS:
    void Next();
    void Previous();
    void Pause();
    void PlayPause();
    void Stop();
    void Play();
    void Seek(qlonglong Offset);
    void SetPosition(const QDBusObjectPath &trackId, qlonglong pos);
    void OpenUri(const QString &uri);

    void playerPlaybackStateChanged();
    void playerIsSeekableChanged();
    void audioPositionChanged();
    void setPropertyPosition(int newPositionInMs);
    void audioDurationChanged();
    void skipBackwardControlEnabledChanged();
    void skipForwardControlEnabledChanged();
    void playerVolumeChanged();
    void onUrlChangeSlot();


private:
    void signalPropertiesChange(const QString &property, const QVariant &value);
    void setMediaPlayerPresent(int status);

    void setRate(double newRate);
    void setVolume(double volume);

    QVariantMap getMetadataOfCurrentTrack();
    void setCurrentTrack(int newTrackPosition);

    QString m_playerName;
    QVariantMap m_metadata;
    QString m_currentTrack;
    QString m_currentTrackId;
    double m_rate = 1.0;
    double m_volume = 0.0;
    int m_mediaPlayerPresent = 0;
    bool m_canPlay = true;
    bool m_canGoNext = true;
    bool m_canGoPrevious = true;
    qlonglong m_position = 0;

    QMediaPlayer::State m_playState ;
    bool m_showProgressOnTaskBar = true;
    bool m_playerIsSeekableChanged = false;
    Player *m_pPlayer = nullptr ;
    mutable QDBusMessage m_progressIndicatorSignal;
    int m_previousProgressPosition = 0;
};

// media application settings
class MediaPlayer2 : public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.mpris.MediaPlayer2") // Docs: https://specifications.freedesktop.org/mpris-spec/latest/Media_Player.html

    Q_PROPERTY(bool CanQuit READ CanQuit CONSTANT)
    Q_PROPERTY(bool CanRaise READ CanRaise CONSTANT)
    Q_PROPERTY(bool HasTrackList READ HasTrackList CONSTANT)

    Q_PROPERTY(QString Identity READ Identity CONSTANT)
    Q_PROPERTY(QString DesktopEntry READ DesktopEntry CONSTANT)

    Q_PROPERTY(QStringList SupportedUriSchemes READ SupportedUriSchemes CONSTANT)
    Q_PROPERTY(QStringList SupportedMimeTypes READ SupportedMimeTypes CONSTANT)

public:
    explicit MediaPlayer2(QObject *parent = nullptr);
    ~MediaPlayer2() override;

    bool CanQuit() const;
    bool CanRaise() const;
    bool HasTrackList() const;

    QString Identity() const;
    QString DesktopEntry() const;

    QStringList SupportedUriSchemes() const;
    QStringList SupportedMimeTypes() const;

public Q_SLOTS:
    void Quit();
    void Raise();

Q_SIGNALS:
    void raisePlayer();
};

class Mpris2 : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString playerName READ playerName WRITE setPlayerName NOTIFY playerNameChanged)
    Q_PROPERTY(Player *audioPlayer READ audioPlayer WRITE setAudioPlayer NOTIFY audioPlayerChanged)
    Q_PROPERTY(bool showProgressOnTaskBar READ showProgressOnTaskBar WRITE setShowProgressOnTaskBar NOTIFY showProgressOnTaskBarChanged)

public:
    explicit Mpris2(QObject *parent = nullptr);
    ~Mpris2() override;

    QString playerName() const;
    Player *audioPlayer() const;
    bool showProgressOnTaskBar() const;
    Q_INVOKABLE void quitControls();

public Q_SLOTS:

    void setPlayerName(const QString &playerName);
    void setAudioPlayer(Player *audioPlayer);
    void setShowProgressOnTaskBar(bool value);

Q_SIGNALS:
    void raisePlayer();
    void playerNameChanged();
    void audioPlayerChanged();
    void showProgressOnTaskBarChanged();

private:
    void initDBusService();

#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
    std::unique_ptr<MediaPlayer2> m_mp2;
    std::unique_ptr<MediaDbusSet> m_mp2p;
#endif

    QString m_playerName;
    Player *m_audioPlayer = nullptr;
    bool mShowProgressOnTaskBar = true;
};
#endif // MEDIADBUSSET_H
