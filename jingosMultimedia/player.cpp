/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 * SPDX-FileCopyrightText: 2021 Yu Jiashu <yujiashu@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
#include "player.h"
#define UNICODE
#include <MediaInfo/MediaInfo.h>
#include <taglib/mpegfile.h>
#include <taglib/mp4file.h>
#include <taglib/id3v2tag.h>
#include <taglib/attachedpictureframe.h>
#include <QDateTime>
#include <QDebug>
#include <QFileInfo>
#include <QFile>
#include <iostream>
#include <QImage>
#include <memory>

#define USE_GSTMEDIA 1
static MediaInfoLib::MediaInfo MI;

Player::Player(QObject *parent) : QObject(parent),
    m_pPlayer(new QMediaPlayer(this))
{ 

    m_pPlayer->setVolume(this->volume);
    m_pPlayer->setNotifyInterval(200);
    connect(m_pPlayer,&QMediaPlayer::positionChanged,this, &Player::updatePos);
    connect(m_pPlayer,&QMediaPlayer::stateChanged,this,&Player::setState);
    connect(m_pPlayer,&QMediaPlayer::durationChanged,this,&Player::setDuration);
    connect(m_pPlayer,&QMediaPlayer::mediaStatusChanged,this,&Player::onMediaStatusChanged);

}
Player::~Player()
{

}

bool Player::play() const
{
    if(m_playUrl.isEmpty()) return false;
    QFileInfo tempFileInfo(m_playUrl.toLocalFile());
    if(!tempFileInfo.isReadable()) return false;
    m_pPlayer->play();
    return true;
}

void Player::pause() const
{
    if(m_playUrl.isEmpty()) return;
    m_pPlayer->pause();

}

void Player::stop()
{
    if(m_playUrl.isEmpty()) return;

    m_pPlayer->stop();
    m_playUrl.clear();
    m_pPlayer->setMedia(QMediaContent());
    this->playing = false;
    Q_EMIT this->playingChanged();
}

QString Player::transformTime(const int &pos)
{
    QTime t(0, 0, 0);
    QString formattedTime = t.addMSecs(pos).toString
            (QString(QStringLiteral("hh:mm:ss")));
    return formattedTime;
}

void Player::setUrl(const QUrl &value)
{
    if(value.toLocalFile().isEmpty()) {
        m_playUrl.clear();
        return;
    }
    this->pos = 0;
    Q_EMIT posChanged();
    finished = false;
    Q_EMIT finishedChanged();
    m_playUrl = value;
    if(!canPlay(m_playUrl)) {
        m_playUrl.clear();
        return;
    }
    m_pPlayer->setMedia(value);
    Q_EMIT this->urlChanged();
    if(playing) {
        setState(QMediaPlayer::PlayingState);
    }

    QFileInfo tempFileInfo(m_playUrl.toLocalFile());

#if(USE_GSTMEDIA)
    m_nGstMediaInfo.startParse(value.toString());
#else
    QFileInfo tempFileInfo(m_playUrl.toLocalFile());
    if(tempFileInfo.isReadable()) {
        TagLib::FileRef  tempFile(TagLib::FileName(m_playUrl.toLocalFile().toUtf8().constData()));
        m_File = tempFile;
    }
#endif
}

QUrl Player::getUrl() const
{
    return m_playUrl;
}

void Player::setVolume(const int &value)
{
    if(value == volume)
        return;

    volume = value;
    m_pPlayer->setVolume(volume);
    Q_EMIT volumeChanged();
}

int Player::getVolume() const
{
    return volume;
}

int Player::getDuration() const
{
    return static_cast<int>(m_duration);
}

 void Player::setDuration(qint64 duration)
 {
    if(m_duration == duration)
        return;
    m_duration = duration;
    Q_EMIT durationChanged();
 }

QMediaPlayer::State Player::getState() const
{
    return this->m_playState;
}

void Player::setState(QMediaPlayer::State state)
{
    if(m_playState == state)
        return;
    m_playState = state;
    Q_EMIT stateChanged();
}

void Player::setPlaying(const bool &value)
{
    this->playing = value;
    if(this->playing)
        this->play();
    else
        pause();
    Q_EMIT this->playingChanged();
}

bool Player::getPlaying() const
{
    return this->playing;
}

bool Player::getFinished()
{
    return this->finished;
}

void Player::setPos(const int &value)
{
    this->pos = value;
    m_pPlayer->setPosition(value);
    Q_EMIT posChanged();
}

int Player::getPos() const
{
    return this->pos;
}

void Player::updatePos(qint64 position)
{
    if(position > getPreDuration()) return;
    this->pos = position;
    Q_EMIT this->posChanged();
}

void Player::onMediaStatusChanged(QMediaPlayer::MediaStatus status)
{
    if(status == QMediaPlayer::EndOfMedia) {
        finished = true;
        Q_EMIT finishedChanged();
    }
}

void Player::setPlayIndex(int index)
{
    m_index = index;
}

int Player::getCurrentIndex()
{
    return  m_index;
}

QString Player::getAlbum() const
{
    if(!m_playUrl.toLocalFile().isEmpty()) {
#if(USE_GSTMEDIA)
        QString album = m_nGstMediaInfo.getPropertyByKey("album");
        if(album.isEmpty()){
            return m_strUnKnown;
        } else {
            return album;
        }
#else
        if(!m_File.isNull()) {
            const auto value = QString::fromStdWString(m_File.tag()->album().toWString());
            return !value.isEmpty()
                    ? value
                    : m_strUnKnown;
        }
#endif
    }
    return m_strUnKnown;
}
QString Player::getTitle() const
{
    if(!m_playUrl.toLocalFile().isEmpty()) {
#if(USE_GSTMEDIA)
        QString title = m_nGstMediaInfo.getPropertyByKey("title");
        if(title.isEmpty()) {
            return m_strUnKnown;
        } else {
            return title;
        }
#else
        if(!m_File.isNull()) {
            const auto value = QString::fromStdWString(m_File.tag()->title().toWString());
            return !value.isEmpty()
                    ? value
                    : fileName();
        }
#endif
    }
    return m_strUnKnown;
}
QString Player::getArtist() const
{
    if(!m_playUrl.toLocalFile().isEmpty()) {
#if(USE_GSTMEDIA)
        QString artist = m_nGstMediaInfo.getPropertyByKey("artist");
        if(artist.isEmpty()) {
            return m_strUnKnown;
        } else {
            return artist;
        }
#else
        if(!m_File.isNull()){
            const auto value = QString::fromStdWString(m_File.tag()->artist().toWString());
            return !value.isEmpty()
                    ? value
                    : m_strUnKnown;
        }
#endif
    }
    return m_strUnKnown;
}
int Player::getTrack() const
{
    if(!m_playUrl.toLocalFile().isEmpty()) {
#if(USE_GSTMEDIA)
        return m_nGstMediaInfo.getAudioInfoByKey("channels").toUInt();
#else
        if(!m_File.isNull())
            return static_cast<signed int>(m_File.tag()->track());
#endif
    }
    return -1;
}
QString Player::getGenre() const
{
    if(!m_playUrl.toLocalFile().isEmpty()) {
#if(USE_GSTMEDIA)
        return "image://multiMediaFileImageProvider/" + m_nGstMediaInfo.id();
#else

        QString path=m_playUrl.toLocalFile();
        if(!m_File.isNull())
        {
            int index = path.lastIndexOf(QString(QStringLiteral(".")));
            QString newPath = path.mid(0, index);//path/name
            index = newPath.lastIndexOf(QString(QStringLiteral("/")));
            QString startPath = newPath.mid(0, index + 1);//path/
            QString endPath = newPath.mid(index + 1, newPath.length());//name
            QString cover_path = startPath + QString(QStringLiteral(".")) + endPath + QString(QStringLiteral(".png"));

            QFileInfo fileInfo(path);
            QString fileExtension = fileInfo.completeSuffix();
            if(fileExtension == QString(QStringLiteral("mp3"))){
                std::unique_ptr<TagLib::MPEG::File> mpegFile(new TagLib::MPEG::File(
                                                                 QFile::encodeName(path).constData()));
                if(mpegFile->isOpen()) {
                    auto tag = mpegFile->ID3v2Tag(false);
                    auto list = tag->frameListMap()["APIC"];
                    if(!list.isEmpty()) {
                        auto frame = list.front();
                        auto pic = reinterpret_cast<TagLib::ID3v2::AttachedPictureFrame *>(frame);
                        if(pic && !pic->picture().isNull()){
                            QImage image = QImage::fromData((const uchar *)pic->picture().data(), pic->picture().size());
                            image.save(cover_path);
                            return QString(QStringLiteral("file://")) +cover_path;;
                        }
                    }
                }
            }
        }
#endif
    }
    return m_strDefaultImage;
}

QString Player::fileName() const
{
    return getNameFromLocation(m_playUrl.toLocalFile());
}

QString Player::getComment() const
{
    if(!m_playUrl.toLocalFile().isEmpty()) {
#if(USE_GSTMEDIA)
        QString data = m_nGstMediaInfo.getPropertyByKey("comment");
        if(data.isEmpty()) {
            return m_strUnKnown;
        } else {
            return data;
        }
#else
        if(!m_File.isNull()) {
            const auto value = QString::fromStdWString(m_File.tag()->comment().toWString());
            return !value.isEmpty()
                    ?value
                   : m_strUnKnown;
        }
#endif
    }
    return m_strUnKnown;
}

uint Player::getYear() const
{
    if(!m_playUrl.toLocalFile().isEmpty()) {
#if(USE_GSTMEDIA)
        QString data = m_nGstMediaInfo.getPropertyByKey("datetime");
        if(data.length() >= 4){
            data = data.mid(0, 4);
            return data.toUInt();
        } else {
            return 0;
        }
#else
        if(!m_File.isNull()) {
            return m_File.tag()->year();
        }
#endif
    }
    return 0;
}

int Player::getPreDuration() const
{
    if(!m_playUrl.toLocalFile().isEmpty()) {
#if(USE_GSTMEDIA)
        uint duration = m_nGstMediaInfo.getPropertyByKey("duration").toUInt();
        return duration;
#else
        if(!m_File.isNull()) {
            return m_File.audioProperties()->length() * 1000;
        }
#endif
    }
    return 0;
}

bool Player::canPlayNext()
{
    return m_canPlayNext;
}
void Player::setCanPlayNext(bool flag)
{
    if(m_canPlayNext == flag) return;
    m_canPlayNext = flag;
    Q_EMIT canPlayNextChanged();
}

bool Player::canPlayPre()
{
    return m_canPlayPre;
}
void Player::setCanPlayPre(bool flag)
{
    if(m_canPlayPre == flag) return;
    m_canPlayPre = flag;
    Q_EMIT canPlayPreChanged();
}

bool Player::listNull()
{
    return m_listNull;
}
void Player::setListNull(bool flag)
{
    if(m_listNull == flag) return;
    m_listNull = flag;
    emit listNullChanged();
}


const inline QString Player::getNameFromLocation(const QString &str)
{
    QString ret;
    int index = 0;

    for(int i = str.size() - 1; i >= 0; i--) {
        if(str[i] == QString(QStringLiteral("/"))) {
            index = i + 1;
            i = -1;
        }
    }
    for(; index < str.size(); index++){
        ret.push_back(str[index]);
    }
    return ret;
}

QString Player::title()
{
    return  m_title;
}
void Player::setTitle(const QString &title)
{
    if(m_title == title) return;
    m_title = title;
    Q_EMIT titleChanged();
}

bool Player::seekable()
{
    return m_pPlayer->isSeekable();
}

bool Player::canPlay(const QUrl &value)
{
    bool returnValue = true;
    QString path=value.toLocalFile();
    QString version = "";
    int codeid = -1;
    QString duration;
    if(MI.Open(path.toStdWString())) {
        version =  QString::fromStdWString(MI.Get(MediaInfoLib::Stream_Audio, 0, __T("Format_Version")));
    }

    if(MI.Open(path.toStdWString())) {
        codeid =  QString::fromStdWString(MI.Get(MediaInfoLib::Stream_Audio, 0, __T("CodecID"))).toInt();
    }
    if(version.contains("Version 2") && codeid == 1) {
        returnValue = false;
    }

    if(returnValue) {
        QMediaPlayer tempPlayer;
         tempPlayer.setMedia(value);
        if(!tempPlayer.isAvailable() || tempPlayer.mediaStatus() == QMediaPlayer::InvalidMedia) {
            returnValue = false;
        }
    }
    return returnValue;
}
