/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 * SPDX-FileCopyrightText: 2021 Yu Jiashu <yujiashu@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "mpvobject.h"
#define UNICODE
#include <MediaInfo/MediaInfo.h>
#include <QDebug>
#include <QDir>
#include <QObject>
#include <QStandardPaths>
#include <QtGlobal>
#include <QApplication>
#include <QCoreApplication>
#include <QOpenGLContext>
#include <QDBusMessage>
#include <QDBusConnection>
#include <QTime>
#include <KConfigGroup>
#include <KSharedConfig>
#include <QDateTime>

static MediaInfoLib::MediaInfo MI;

MpvObject::MpvObject(QObject * parent)
    : QObject(parent)
    , mpv{mpv_create()}
    , mpv_gl(nullptr)
{
    if (!mpv)
        throw std::runtime_error("could not create mpv context");

//    mpv_set_option_string(mpv, "terminal", "yes");
//    mpv_set_option_string(mpv, "msg-level", "all=v");


    setProperty("keep-open", "yes");
//    setProperty("cache-pause-wait", 0.0);
//    setProperty("cache-pause", 0);
//    setProperty("cache-pause-initial", 0);

    setProperty(QString(QStringLiteral("hwdec")), QString(QStringLiteral("vaapi")));
    setProperty(QString(QStringLiteral("screenshot-template")),QString(QStringLiteral( "%x/screenshots/%n")));

    mpv_observe_property(mpv, 0, "media-title", MPV_FORMAT_STRING);
    mpv_observe_property(mpv, 0, "time-pos", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "playback-time", MPV_FORMAT_DOUBLE);

    mpv_observe_property(mpv, 0, "time-remaining", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "duration", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "volume", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "pause", MPV_FORMAT_FLAG);
    mpv_observe_property(mpv, 0, "chapter", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "aid", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "sid", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "secondary-sid", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "contrast", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "brightness", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "gamma", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "saturation", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "eof-reached", MPV_FORMAT_FLAG);
    mpv_observe_property(mpv, 0, "video-params", MPV_FORMAT_INT64);


    setProperty(QString(QStringLiteral("sub-auto")),QString(QStringLiteral( "exact")));

    QString configPath = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
    QString watchLaterPath = configPath.append(QString(QStringLiteral("/georgefb/watch-later")));
    setProperty(QString(QStringLiteral("watch-later-directory")), watchLaterPath);
    QDir watchLaterDir(watchLaterPath);
    if (!watchLaterDir.exists()) {
        QDir().mkdir(watchLaterPath);
    }

    if (mpv_initialize(mpv) < 0)
        throw std::runtime_error("could not initialize mpv context");

    mpv_set_wakeup_callback(mpv, MpvObject::on_mpv_events, this);

    qDebug() << Q_FUNC_INFO;
}

MpvObject::~MpvObject()
{
    // only initialized if something got drawn
    if (mpv_gl) {
        mpv_render_context_free(mpv_gl);
    }
    mpv_terminate_destroy(mpv);
}

void MpvObject::on_mpv_events(void *ctx)
{
    QMetaObject::invokeMethod(static_cast<MpvObject*>(ctx),"eventHandler", Qt::QueuedConnection);

}

void MpvObject::startPlay(const QString &path)
{
    qDebug() << Q_FUNC_INFO << path;

    setPosition(0.0);
    setDuration(0.0);
    QStringList params = {"loadfile", path};
    command(QVariant(params));
}

bool MpvObject::pause()
{
    return getProperty(QString(QStringLiteral("pause"))).toBool();
}

void MpvObject::setPause(bool v)
{

    qDebug() << Q_FUNC_INFO << v;
    if(pause() == v){
        return;
    }

    if(v == false && (eofReached() == 1 )  ) {
        QStringList args = {"seek", "0.0", "absolute"};
        QVariant rv = command(QVariant::fromValue(args));
        qDebug() << Q_FUNC_INFO << " seek rv " << rv;
    }

    setProperty("pause", v);
}

QString MpvObject::mediaTitle()
{
    return getProperty(QString(QStringLiteral("media-title"))).toString();
}
double MpvObject::position()
{
    if(m_nPosition == duration()) {
        return m_nPosition;
    }
    double pos = getProperty(QString(QStringLiteral("time-pos"))).toDouble();
    if(qFuzzyCompare(pos, m_nPlaybackTime)){
        return 0.0;
    }
    return  pos;
}

void MpvObject::setPosition(double value)
{
    if(m_nEofReached == 1 && value != duration()) {
        return ;
    }
    if (qFuzzyCompare(value, m_nPosition) == false) {
        m_nPosition = value;
        Q_EMIT positionChanged();
    }
}

double MpvObject::duration()
{
    return m_nDuration;
}

void MpvObject::setDuration(double value)
{
    if (qFuzzyCompare(value, m_nDuration) == false) {
        m_nDuration = value;
        Q_EMIT durationChanged();
    }
}

int MpvObject::eofReached()
{
    return m_nEofReached;
}

void MpvObject::setEofReached(int v)
{
    if(m_nEofReached != v){
        m_nEofReached = v;
        if(m_nEofReached == 1){
            setPosition(duration());
        }
    }
    emit eofReachedChanged();
}

void MpvObject::seekPosition(double position)
{
    QStringList args = {"seek", QString::number(position), "absolute"};
    QVariant rv = command(QVariant::fromValue(args));
    if(eofReached() == 1 && position != duration()) {
        setEofReached(0);
    }
}

double MpvObject::remaining()
{
    return getProperty(QString(QStringLiteral("time-remaining"))).toDouble();
}

int MpvObject::volume()
{
    return getProperty(QString(QStringLiteral("volume"))).toInt();
}

void MpvObject::setVolume(int value)
{
    if (value != volume()) {
        setProperty(QString(QStringLiteral("volume")), value);
        Q_EMIT volumeChanged();
    }
}

int MpvObject::chapter()
{
    return getProperty(QString(QStringLiteral("chapter"))).toInt();
}

void MpvObject::setChapter(int value)
{
    if (value == chapter()) {
        return;
    }
    setProperty(QString(QStringLiteral("chapter")), value);
    Q_EMIT chapterChanged();
}

int MpvObject::audioId()
{
    return getProperty(QString(QStringLiteral("aid"))).toInt();
}

void MpvObject::setAudioId(int value)
{
    if (value == audioId()) {
        return;
    }
    setProperty(QString(QStringLiteral("aid")), value);
    Q_EMIT audioIdChanged();
}

int MpvObject::subtitleId()
{
    return getProperty(QString(QStringLiteral("sid"))).toInt();
}

void MpvObject::setSubtitleId(int value)
{
    if (value == subtitleId()) {
        return;
    }
    setProperty(QString(QStringLiteral("sid")), value);
    Q_EMIT subtitleIdChanged();
}

int MpvObject::secondarySubtitleId()
{
    return getProperty(QString(QStringLiteral("secondary-sid"))).toInt();
}

void MpvObject::setSecondarySubtitleId(int value)
{
    if (value == secondarySubtitleId()) {
        return;
    }
    setProperty(QString(QStringLiteral("secondary-sid")), value);
    Q_EMIT secondarySubtitleIdChanged();
}

int MpvObject::contrast()
{
    return getProperty(QString(QStringLiteral("contrast"))).toInt();
}

void MpvObject::setContrast(int value)
{
    if (value == contrast()) {
        return;
    }
    setProperty(QString(QStringLiteral("contrast")), value);
    Q_EMIT contrastChanged();
}

int MpvObject::brightness()
{
    return getProperty(QString(QStringLiteral("brightness"))).toInt();
}

void MpvObject::setBrightness(int value)
{
    if (value == brightness()) {
        return;
    }
    setProperty(QString(QStringLiteral("brightness")), value);
    Q_EMIT brightnessChanged();
}

int MpvObject::gamma()
{
    return getProperty(QString(QStringLiteral("gamma"))).toInt();
}

void MpvObject::setGamma(int value)
{
    if (value == gamma()) {
        return;
    }
    setProperty(QString(QStringLiteral("gamma")), value);
    Q_EMIT gammaChanged();
}

int MpvObject::saturation()
{
    return getProperty(QString(QStringLiteral("saturation"))).toInt();
}

void MpvObject::setSaturation(int value)
{
    if (value == saturation()) {
        return;
    }
    setProperty(QString(QStringLiteral("saturation")), value);
    Q_EMIT saturationChanged();
}

double MpvObject::watchPercentage()
{
    return m_watchPercentage;
}

void MpvObject::setWatchPercentage(double value)
{
    if (m_watchPercentage == value) {
        return;
    }
    m_watchPercentage = value;
    Q_EMIT watchPercentageChanged();
}

int MpvObject::videoRotate()
{
     return getProperty(QString(QStringLiteral("video-rotate"))).toInt();
}
void MpvObject::setVideoRotate(int rotate)
{
    if(rotate == videoRotate())
        return;
    if(!(rotate < 360)) {
       rotate = 0;
    }
    setProperty(QString(QStringLiteral("video-rotate")), rotate);
    Q_EMIT videoRotateChanged();
}

void MpvObject::eventHandler()
{
    while (mpv) {
        mpv_event *event = mpv_wait_event(mpv, 0);
        if (event->event_id == MPV_EVENT_NONE) {
            break;
        }

        switch (event->event_id) {
        case MPV_EVENT_START_FILE:{
            break;
        }

        case MPV_EVENT_FILE_LOADED: {
            Q_EMIT fileLoaded();
            break;
        }
        case MPV_EVENT_END_FILE: {
            m_nPlaybackTime = -1.0;
            auto prop = (mpv_event_end_file *)event->data;
            if (prop->reason == MPV_END_FILE_REASON_EOF) {
                Q_EMIT endOfFile();
            }
            break;
        }
        case MPV_EVENT_PROPERTY_CHANGE: {
            mpv_event_property *prop = (mpv_event_property *)event->data;
            if (strcmp(prop->name, "time-pos") == 0) {
                if (prop->format == MPV_FORMAT_DOUBLE) {

                    double pos = getProperty(QString(QStringLiteral("time-pos"))).toDouble();
                    setPosition(pos);
                }
            } else if (strcmp(prop->name, "playback-time") == 0) {
                if (prop->format == MPV_FORMAT_DOUBLE) {
                    double playbackTime = getProperty(QString(QStringLiteral("playback-time"))).toDouble();
                    if(qFuzzyCompare(m_nPlaybackTime, -1.0) == true){
                        m_nPlaybackTime = playbackTime;
                    }
                }
            } else if (strcmp(prop->name, "media-title") == 0) {
                if (prop->format == MPV_FORMAT_STRING) {
                    Q_EMIT mediaTitleChanged();
                }
            } else if (strcmp(prop->name, "time-remaining") == 0) {
                if (prop->format == MPV_FORMAT_DOUBLE) {
                    Q_EMIT remainingChanged();
                }
            } else if (strcmp(prop->name, "duration") == 0) {
                if (prop->format == MPV_FORMAT_DOUBLE) {
                    double dur = getProperty(QString(QStringLiteral("duration"))).toDouble();
                    setDuration(dur);
                }
            } else if (strcmp(prop->name, "volume") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT volumeChanged();
                }
            } else if (strcmp(prop->name, "pause") == 0) {
                if (prop->format == MPV_FORMAT_FLAG) {
                    bool rvP = getProperty(QString(QStringLiteral("pause"))).toBool();
                    Q_EMIT pauseChanged();
                }
            } else if (strcmp(prop->name, "chapter") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT chapterChanged();
                }
            } else if (strcmp(prop->name, "aid") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT audioIdChanged();
                }
            } else if (strcmp(prop->name, "sid") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT subtitleIdChanged();
                }
            } else if (strcmp(prop->name, "secondary-sid") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT secondarySubtitleIdChanged();
                }
            } else if (strcmp(prop->name, "contrast") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT contrastChanged();
                }
            } else if (strcmp(prop->name, "brightness") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT brightnessChanged();
                }
            } else if (strcmp(prop->name, "gamma") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT gammaChanged();
                }
            } else if (strcmp(prop->name, "saturation") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT saturationChanged();
                }
            } else if(strcmp(prop->name, "eof-reached") == 0){
                int eof = getProperty("eof-reached").toInt();
                setEofReached(eof);
            }
            break;
        }
        default: ;
            // Ignore uninteresting or unknown events.
        }
    }
}

int MpvObject::setProperty(const QString &name, const QVariant &value)
{
    return mpv::qt::set_property(mpv, name, value);
}

QVariant MpvObject::getProperty(const QString &name)
{
    auto value = mpv::qt::get_property(mpv, name);
    return value;
}

QVariant MpvObject::command(const QVariant &params)
{
    return mpv::qt::command(mpv, params);
}

int MpvObject::getVideoOriginWidth(const QString &path)
{
    QString url=path;
    if(MI.Open(url.toStdWString())) {
         return QString::fromStdWString(MI.Get(MediaInfoLib::Stream_Video, 0, __T("Width"),
                                               MediaInfoLib::Info_Text, MediaInfoLib::Info_Name)).toInt();
    }
    return 0;
}
int MpvObject::getVideoOriginHeight(const QString &path)
{
    QString url=path;
    if(MI.Open(url.toStdWString())) {

        return QString::fromStdWString(MI.Get(MediaInfoLib::Stream_Video, 0, __T("Height"),
                                                MediaInfoLib::Info_Text, MediaInfoLib::Info_Name)).toInt();
    }
    return 0;
}

