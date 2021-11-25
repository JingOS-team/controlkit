/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 * SPDX-FileCopyrightText: 2021 Yu Jiashu <yujiashu@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef MPVOBJECT_H
#define MPVOBJECT_H

#include <QObject>

// #include <mpv/client.h>
#include <mpv/render_gl.h>
#include "qthelper.h"

class MpvRenderer;
class MpvRenderItem;
class MpvObject: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString mediaTitle READ mediaTitle NOTIFY mediaTitleChanged)

    Q_PROPERTY(double position READ position NOTIFY positionChanged)

    Q_PROPERTY(double duration READ duration NOTIFY durationChanged)

    Q_PROPERTY(double remaining READ remaining NOTIFY remainingChanged)

    Q_PROPERTY(bool pause READ pause WRITE setPause NOTIFY pauseChanged)

    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)

    Q_PROPERTY(int chapter READ chapter WRITE setChapter NOTIFY chapterChanged)

    Q_PROPERTY(int audioId READ audioId WRITE setAudioId NOTIFY audioIdChanged)

    Q_PROPERTY(int subtitleId READ subtitleId WRITE setSubtitleId NOTIFY subtitleIdChanged)

    Q_PROPERTY(int secondarySubtitleId READ secondarySubtitleId WRITE setSecondarySubtitleId NOTIFY secondarySubtitleIdChanged)

    Q_PROPERTY(int contrast READ contrast WRITE setContrast NOTIFY contrastChanged)

    Q_PROPERTY(int brightness READ brightness WRITE setBrightness NOTIFY brightnessChanged)

    Q_PROPERTY(int gamma READ gamma WRITE setGamma NOTIFY gammaChanged)

    Q_PROPERTY(int saturation READ saturation WRITE setSaturation NOTIFY saturationChanged)

    Q_PROPERTY(double watchPercentage MEMBER m_watchPercentage READ watchPercentage WRITE setWatchPercentage NOTIFY watchPercentageChanged)

    Q_PROPERTY(int videoRotate READ videoRotate WRITE setVideoRotate NOTIFY videoRotateChanged)

    Q_PROPERTY(int eofReached READ eofReached WRITE setEofReached NOTIFY eofReachedChanged)

    QString mediaTitle();

    double position();
    void setPosition(double value);

    double duration();
    void setDuration(double value);

    double remaining();

    bool pause();
    void setPause(bool v);
    
    int volume();
    void setVolume(int value);

    int chapter();
    void setChapter(int value);

    int audioId();
    void setAudioId(int value);

    int subtitleId();
    void setSubtitleId(int value);

    int secondarySubtitleId();
    void setSecondarySubtitleId(int value);

    int contrast();
    void setContrast(int value);

    int brightness();
    void setBrightness(int value);

    int gamma();
    void setGamma(int value);

    int saturation();
    void setSaturation(int value);

    double watchPercentage();
    void setWatchPercentage(double value);

    int videoRotate();
    void setVideoRotate(int rotate);

    int eofReached();
    void setEofReached(int v);

    mpv_handle *mpv;
    mpv_render_context *mpv_gl;

    friend class MpvRenderer;
    friend class MpvRenderItem;
public:
    MpvObject(QObject * parent = 0);
    virtual ~MpvObject();
    Q_INVOKABLE int getVideoOriginWidth(const QString &path);
    Q_INVOKABLE int getVideoOriginHeight(const QString &path);

    Q_INVOKABLE void startPlay(const QString& path);

public Q_SLOTS:
    static void on_mpv_events(void *ctx);
    void eventHandler();
    int setProperty(const QString &name, const QVariant &value);
    QVariant getProperty(const QString &name);
    QVariant command(const QVariant &params);
    void seekPosition(double position);    

Q_SIGNALS:
    void mediaTitleChanged();
    void positionChanged();
    void durationChanged();
    void remainingChanged();
    void volumeChanged();
    void pauseChanged();
    void chapterChanged();
    void audioIdChanged();
    void subtitleIdChanged();
    void secondarySubtitleIdChanged();
    void contrastChanged();
    void brightnessChanged();
    void gammaChanged();
    void saturationChanged();
    void fileLoaded();
    void endOfFile();
    void watchPercentageChanged();
    void ready();
    void videoRotateChanged();
    void eofReachedChanged();
private:
    QList<int> m_secondsWatched;
    double m_watchPercentage;
    double m_nPlaybackTime = -1.0;
    int m_nEofReached = 0;

    double m_nDuration = 0.0;
    double m_nPosition = 0.0;

};

#endif // MPVOBJECT_H
