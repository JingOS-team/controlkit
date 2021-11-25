/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Yu Jiashu <yujiashu@jingos.com>
 *
 */


#ifndef PLAYER_H
#define PLAYER_H

#include <QObject>
#include <QtMultimedia/QMediaPlayer>
#include <QTimer>
#include <QBuffer>
#if defined Q_OS_ANDROID || defined Q_OS_IOS
#include <taglib/tag.h>
#include <taglib/fileref.h>
#elif defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_LINUX
#include <taglib/tag.h>
#include <taglib/fileref.h>
#endif

#include "jgstmediainfo.h"

class Player : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ getUrl WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(int volume READ getVolume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY( QMediaPlayer::State state READ getState WRITE setState NOTIFY stateChanged)
    Q_PROPERTY(int duration READ getDuration WRITE setDuration NOTIFY durationChanged)
    Q_PROPERTY(bool playing READ getPlaying WRITE setPlaying NOTIFY playingChanged)
    Q_PROPERTY(bool finished READ getFinished NOTIFY finishedChanged)
    Q_PROPERTY(int pos READ getPos WRITE setPos NOTIFY posChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(bool canPlayNext READ canPlayNext WRITE setCanPlayNext NOTIFY canPlayNextChanged)
    Q_PROPERTY(bool canPlayPre READ canPlayPre WRITE setCanPlayPre NOTIFY canPlayPreChanged)
    Q_PROPERTY(bool listNull READ listNull WRITE setListNull NOTIFY listNullChanged)


public:

    explicit Player(QObject *parent = nullptr);
    ~Player();

    void setUrl(const QUrl &value);
    QUrl getUrl() const;

    void setVolume(const int &value);
    int getVolume() const;

    int getDuration() const;
    void setDuration(qint64 duration);

     QMediaPlayer::State getState() const;
     void setState(QMediaPlayer::State state);

    void setPlaying(const bool &value);
    bool getPlaying() const;

    bool getFinished();

    int getPos() const;
    void setPos(const int &value);

    bool seekable();
    bool canPlay(const QUrl &value);

    QString title();
    void setTitle(const QString &title);

    bool canPlayNext();
    void setCanPlayNext(bool flag);

    bool canPlayPre();
    void setCanPlayPre(bool flag);

    bool listNull();
    void setListNull(bool flag);

    int getCurrentIndex();

    const static inline QString getNameFromLocation(const QString &str);
    Q_INVOKABLE void setPlayIndex(int index);
    Q_INVOKABLE QString getAlbum() const;
    Q_INVOKABLE QString getTitle() const;
    Q_INVOKABLE QString getArtist() const;
    Q_INVOKABLE int getTrack() const;
    Q_INVOKABLE QString getGenre() const;
    Q_INVOKABLE QString fileName() const;
    Q_INVOKABLE QString getComment() const;
    Q_INVOKABLE uint getYear() const;
    Q_INVOKABLE int getPreDuration() const;

Q_SIGNALS:
    void durationChanged();
    void urlChanged();
    void volumeChanged();
    void titleChanged();
    void canPlayNextChanged();
    void canPlayPreChanged();
    void listNullChanged();


    void stateChanged();
    void playingChanged();
    void finishedChanged();
    void next();
    void previous();

    void posChanged();

public Q_SLOTS:
    static QString transformTime(const int &pos);
    void stop();
    void updatePos(qint64 position);
    void onMediaStatusChanged(QMediaPlayer::MediaStatus status);
private:

    bool play() const;
    void pause() const;

    QMediaPlayer *m_pPlayer;
    int amountBuffers = 0;
    int pos = 0;
    int volume = 100;
    qint64 m_duration = 0;
    QString m_title = "";


    QUrl m_playUrl;
    QMediaPlayer::State m_playState = QMediaPlayer::StoppedState;
    bool playing = false;
    bool finished = false;
    bool m_canPlayNext = false;
    bool m_canPlayPre = false;
    bool m_listNull = true;
    int m_index = -1;

    TagLib::FileRef m_File;

    JGstMediaInfo m_nGstMediaInfo;

    const QString m_strUnKnown=QString(QStringLiteral("UNKNOWN"));
    const QString m_strDefaultImage=QString(QStringLiteral("./image/videoImage/cover_default.png"));
};

#endif // PLAYER_H
