/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#ifndef JGSTMEDIAINFO_H
#define JGSTMEDIAINFO_H

#include <QMap>
#include <QVariant>
#include <QImage>
#include <QObject>
#include <QMutex>
#include <QQuickImageProvider>

#include <gst/pbutils/pbutils.h>
#include <gst/pbutils/descriptions.h>
class JGstMediaInfo : public QObject
{
    Q_OBJECT
public:
    explicit JGstMediaInfo(QObject *parent = nullptr);
    ~JGstMediaInfo();

   void startParse(const QString& path);
   static void getTagInfoForeach(const GstTagList* tags, const gchar *tag, gpointer user_data);
   void getStreamInfo(GstDiscovererStreamInfo *info);
   void discovereFinished (GstDiscoverer *discoverer, GstDiscovererInfo *info, GError *err);
   void getTopologyInfo (GstDiscovererStreamInfo *info, gint depth);

   Q_INVOKABLE QMap<QString , QString> getProperties() const;
   Q_INVOKABLE QMap<QString , QString> getAudioStreamInfo() const;
   Q_INVOKABLE QMap<QString , QString> getVideoStreamInfo() const;
   Q_INVOKABLE QMap<QString , QString> getSubtitleStreamInfo() const;

   Q_INVOKABLE QString getPropertyByKey(const QString& key) const;
   Q_INVOKABLE QString getAudioInfoByKey(const QString& key) const;
   Q_INVOKABLE QString getVideoInfoByKey(const QString& key) const;
   Q_INVOKABLE QString getSubtitleInfoByKey(const QString& key) const;
   QString id() const;
   QImage getCoverImage() const;
private:
   void resetData();
   void getAudioStreamInfo(GstDiscovererStreamInfo* info);
   void getVideoStreamInfo(GstDiscovererStreamInfo* info);
   void getSubtitleStreamInfo(GstDiscovererStreamInfo* info);

private:
   QString m_nId;
   QImage m_nCoverImage;
   QMap<QString , QString>  m_nproperties;
   QMap<QString , QString>  m_nAudioStreamInfo;
   QMap<QString , QString>  m_nVideoStreamInfo;
   QMap<QString , QString>  m_nSubtitleStreamInfo;
   QMap<QString , QString> *m_pCurProperties = nullptr;

};
class JMultiMediaFileImageProvider : public QQuickImageProvider{
public:
    static JMultiMediaFileImageProvider* instance();
    ~JMultiMediaFileImageProvider();
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
    void setSource(JGstMediaInfo* info);
    void setSource(const QString &id,const QImage &image);
    void deleteSource(JGstMediaInfo* info);
    bool imageExit(const QString &id);

    void setBaseUrl(const QString& url);
private:
    JMultiMediaFileImageProvider();
    // 唯一单实例对象指针
    static JMultiMediaFileImageProvider *g_pSingleton;
    static QMutex m_nMutex;
    QList<JGstMediaInfo*> m_nGstMediaInfos;
    QHash <QString,QImage> m_VideImages;
    QImage m_nDefaultImage;
    QString m_nBaseUrl;
};

#define theMutliMediaFileImageInstance JMultiMediaFileImageProvider::instance()
#endif // JGSTMEDIAINFO_H
