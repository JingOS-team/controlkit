/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#include "jgstmediainfo.h"
#include <QByteArray>
#include <QDebug>
#include <QImage>
#include <QUuid>
JGstMediaInfo::JGstMediaInfo(QObject *parent) : QObject(parent)
{
    if(!gst_is_initialized()){
        gst_init(nullptr, nullptr);
    }
}

JGstMediaInfo::~JGstMediaInfo()
{
    theMutliMediaFileImageInstance->deleteSource(this);
}

void JGstMediaInfo::startParse(const QString &path)
{

    resetData();
    QString temp = path;
    if(temp.startsWith("file:") == false){
        temp += "file://";
    }

    GError *err = nullptr;
    QByteArray array = temp.toUtf8();
    gchar* uri = array.data();

    g_print("Discovering %s \n", uri);

    GstDiscoverer *discoverer = gst_discoverer_new(5 * GST_SECOND, &err);
    if(!discoverer){
        g_print ("Error creating discoverer instance: %s\n", err->message);
        g_clear_error (&err);
        return;
    }

    GstDiscovererInfo* info = gst_discoverer_discover_uri(discoverer, uri, &err);
    if(!info){
        g_clear_error (&err);
    } else{
        discovereFinished(discoverer, info, err);
    }

    if(info){
        gst_discoverer_info_unref(info);
    }
    g_object_unref (discoverer);

    theMutliMediaFileImageInstance->setSource(this);
}

void JGstMediaInfo::discovereFinished(GstDiscoverer *discoverer, GstDiscovererInfo *info, GError *err)
{
    Q_UNUSED(discoverer);
    GstDiscovererResult result;
    const gchar *uri;


    uri = gst_discoverer_info_get_uri(info);
    result = gst_discoverer_info_get_result(info);

    switch (result) {
    case GST_DISCOVERER_URI_INVALID:
        break;
    case GST_DISCOVERER_ERROR:
        break;
    case GST_DISCOVERER_TIMEOUT:
        break;
    case GST_DISCOVERER_BUSY:
        break;
    case GST_DISCOVERER_MISSING_PLUGINS:{
        const GstStructure *s;
        gchar *str;

        s = gst_discoverer_info_get_misc (info);
        str = gst_structure_to_string (s);
        g_free (str);
        break;
    }
    case GST_DISCOVERER_OK:
        break;
    }

    if (result != GST_DISCOVERER_OK) {
        return;
    }

    GstClockTime time = gst_discoverer_info_get_duration (info);
    time = time / (1000 * 1000);

    m_nproperties.insert("duration", QString::number(time));

    const GstTagList *tags = gst_discoverer_info_get_tags (info);
    if (tags) {
        m_pCurProperties = &m_nproperties;
        gst_tag_list_foreach (tags, getTagInfoForeach, this);
    }

    gboolean seekable = gst_discoverer_info_get_seekable (info);

    GstDiscovererStreamInfo *sinfo = nullptr;
    sinfo = gst_discoverer_info_get_stream_info (info);
    if (!sinfo){
        return;
    }

    getTopologyInfo (sinfo, 1);

    gst_discoverer_stream_info_unref (sinfo);
}

void JGstMediaInfo::getTagInfoForeach(const GstTagList *tags, const gchar *tag, gpointer user_data)
{
    JGstMediaInfo* pGstMedia = reinterpret_cast<JGstMediaInfo*>(user_data);

    QMap<QString, QString> *properties = pGstMedia->m_pCurProperties;
    GValue val = { 0, };
    gchar *str = nullptr;

    gst_tag_list_copy_value (&val, tags, tag);

    if (G_VALUE_HOLDS_STRING (&val)) {
        str = g_value_dup_string (&val);
    } else if (G_VALUE_TYPE (&val) == GST_TYPE_SAMPLE && properties == &(pGstMedia->m_nproperties)) {
        GstSample *sample = gst_value_get_sample (&val);
        GstBuffer *img = gst_sample_get_buffer (sample);
        GstCaps *caps = gst_sample_get_caps (sample);

        if (img) {
            if (caps) {
                GstMapInfo mInfo;
                gboolean  rv =  gst_buffer_map(img, &mInfo,  GST_MAP_READ);
                if(rv){
                    bool lrv = pGstMedia->m_nCoverImage.loadFromData(mInfo.data,  mInfo.size, "image/jpeg");
                }
                gst_buffer_unmap(img, &mInfo);

                gchar *caps_str;
                caps_str = gst_caps_to_string (caps);
                str = g_strdup_printf ("buffer of %" G_GSIZE_FORMAT " bytes, "
                    "type: %s", gst_buffer_get_size (img), caps_str);
                g_free (caps_str);
            } else {
                str = g_strdup_printf ("buffer of %" G_GSIZE_FORMAT " bytes",
                                       gst_buffer_get_size (img));
            }
        } else {
            str = g_strdup ("NULL buffer");
        }
    } else {
        str = gst_value_serialize (&val);
    }

    if(str){
        QString key(tag);
        QString value(str);
        properties->insert(key, value);
        g_free (str);
    }

    g_value_unset (&val);
}

void JGstMediaInfo::getTopologyInfo (GstDiscovererStreamInfo *info, gint depth) {
    GstDiscovererStreamInfo *next;

    if (!info)
        return;

    getStreamInfo (info);

    next = gst_discoverer_stream_info_get_next (info);
    if (next) {
        getTopologyInfo (next, depth + 1);
        gst_discoverer_stream_info_unref (next);
    } else if (GST_IS_DISCOVERER_CONTAINER_INFO (info)) {
        GList *tmp, *streams;

        streams = gst_discoverer_container_info_get_streams (GST_DISCOVERER_CONTAINER_INFO (info));
        for (tmp = streams; tmp; tmp = tmp->next) {
            GstDiscovererStreamInfo *tmpinf = (GstDiscovererStreamInfo *) tmp->data;
            getTopologyInfo (tmpinf, depth + 1);
        }
        gst_discoverer_stream_info_list_free (streams);
    }
}

void JGstMediaInfo::getStreamInfo(GstDiscovererStreamInfo *info)
{

    if (GST_IS_DISCOVERER_AUDIO_INFO (info)){
        getAudioStreamInfo(info);
    } else if(GST_IS_DISCOVERER_VIDEO_INFO(info)){
        getVideoStreamInfo(info);
    }else if(GST_IS_DISCOVERER_SUBTITLE_INFO(info)){
        getSubtitleStreamInfo();
    }
}

void JGstMediaInfo::getAudioStreamInfo (GstDiscovererStreamInfo * info)
{
    if(!info){
        return;
    }

    GstCaps *caps = gst_discoverer_stream_info_get_caps(info);
    if(!caps){
        return;
    }
    gchar* codec = nullptr;
    if (gst_caps_is_fixed (caps))
        codec = gst_pb_utils_get_codec_description (caps);
    else
        codec = gst_caps_to_string (caps);

    if(codec){
        m_nAudioStreamInfo.insert("container", codec);
        g_free(codec);
    }

    gchar* desc = gst_caps_to_string(caps);

    if(desc){
        m_nAudioStreamInfo.insert("description", desc);
        g_free(desc);
    }
    gst_caps_unref(caps);

    m_nAudioStreamInfo.insert("name", "audio");

    GstDiscovererAudioInfo *audio_info = (GstDiscovererAudioInfo *) info;
    const gchar *ctmp = gst_discoverer_audio_info_get_language (audio_info);
    m_nAudioStreamInfo.insert("language", ctmp ? ctmp : "unkown");

    guint channels = gst_discoverer_audio_info_get_channels(audio_info);
    m_nAudioStreamInfo.insert("channels", QString::number(channels));

    guint sampleRate = gst_discoverer_audio_info_get_sample_rate (audio_info);
    m_nAudioStreamInfo.insert("sampleRate", QString::number(sampleRate));

    guint depth = gst_discoverer_audio_info_get_depth (audio_info);
    m_nAudioStreamInfo.insert("depth", QString::number(depth));


    guint bitRate = gst_discoverer_audio_info_get_bitrate (audio_info);
    m_nAudioStreamInfo.insert("bitRate", QString::number(bitRate));

    guint maxRate = gst_discoverer_audio_info_get_max_bitrate(audio_info);
    m_nAudioStreamInfo.insert("maxRate", QString::number(maxRate));

//    const GstTagList *tags = gst_discoverer_stream_info_get_tags(info);
//    if(tags){
//        m_pCurProperties = &m_nAudioStreamInfo;
//        gst_tag_list_foreach (tags, getTagInfoForeach, this);
//    }
}

void JGstMediaInfo::getVideoStreamInfo(GstDiscovererStreamInfo *info)
{
    if(!info){
        return;
    }

    GstCaps *caps = gst_discoverer_stream_info_get_caps(info);
    if(!caps){
        return;
    }
    gchar* codec = nullptr;
    if (gst_caps_is_fixed (caps))
        codec = gst_pb_utils_get_codec_description (caps);
    else
        codec = gst_caps_to_string (caps);

    if(codec){
        m_nVideoStreamInfo.insert("container", codec);
        g_free(codec);
    }

    gchar* desc = gst_caps_to_string(caps);

    if(desc){
        m_nVideoStreamInfo.insert("description", desc);
        g_free(desc);
    }

    gst_caps_unref(caps);

    m_nVideoStreamInfo.insert("name", "video");
    GstDiscovererVideoInfo *video_info;


    video_info = (GstDiscovererVideoInfo *) info;
    guint width = gst_discoverer_video_info_get_width(video_info);
    m_nVideoStreamInfo.insert("width", QString::number(width));

    guint height = gst_discoverer_video_info_get_height(video_info);
    m_nVideoStreamInfo.insert("height", QString::number(height));

    guint depth = gst_discoverer_video_info_get_depth(video_info);
    m_nVideoStreamInfo.insert("depth", QString::number(depth));

    guint frameRate = gst_discoverer_video_info_get_framerate_num(video_info);
    m_nVideoStreamInfo.insert("frameRate", QString::number(frameRate));


    guint bitRate = gst_discoverer_video_info_get_bitrate(video_info);
    m_nVideoStreamInfo.insert("bitRate", QString::number(bitRate));

    guint maxRate = gst_discoverer_video_info_get_max_bitrate(video_info);
    m_nVideoStreamInfo.insert("maxRate", QString::number(maxRate));

//    const GstTagList *tags = gst_discoverer_stream_info_get_tags(info);
//    if(tags){
//        m_pCurProperties = &m_nVideoStreamInfo;
//        gst_tag_list_foreach (tags, getTagInfoForeach, this);
//    }

}

void JGstMediaInfo::getSubtitleStreamInfo(GstDiscovererStreamInfo *info)
{
    if(!info){
        return;
    }

    GstCaps *caps = gst_discoverer_stream_info_get_caps(info);
    if(!caps){
        return;
    }
    gchar* codec = nullptr;
    if (gst_caps_is_fixed (caps))
        codec = gst_pb_utils_get_codec_description (caps);
    else
        codec = gst_caps_to_string (caps);

    if(codec){
        m_nSubtitleStreamInfo.insert("container", codec);
        g_free(codec);
    }

    gchar* desc = gst_caps_to_string(caps);

    if(desc){
        m_nSubtitleStreamInfo.insert("description", desc);
        g_free(desc);
    }

    gst_caps_unref(caps);

    m_nVideoStreamInfo.insert("name", "subtitle");

    const GstTagList *tags = gst_discoverer_stream_info_get_tags(info);
    if(tags){
        m_pCurProperties = &m_nSubtitleStreamInfo;
        gst_tag_list_foreach (tags, getTagInfoForeach, this);
    }

}


QMap<QString, QString> JGstMediaInfo::getProperties() const
{

    QMapIterator<QString, QString> i(m_nproperties);
    while (i.hasNext()) {
        i.next();
    }
    return m_nproperties;
}

QMap<QString, QString> JGstMediaInfo::getAudioStreamInfo() const
{
     QMapIterator<QString, QString> i(m_nAudioStreamInfo);
    while (i.hasNext()) {
        i.next();
    }
    return m_nAudioStreamInfo;
}

QMap<QString, QString> JGstMediaInfo::getVideoStreamInfo() const
{
     QMapIterator<QString, QString> i(m_nVideoStreamInfo);
    while (i.hasNext()) {
        i.next();
    }
    return m_nVideoStreamInfo;
}

QMap<QString, QString> JGstMediaInfo::getSubtitleStreamInfo() const
{
     QMapIterator<QString, QString> i(m_nSubtitleStreamInfo);
    while (i.hasNext()) {
        i.next();
    }
    return m_nSubtitleStreamInfo;
}

QString JGstMediaInfo::getPropertyByKey(const QString &key) const
{
    if(m_nproperties.contains(key)){
        return m_nproperties.value(key);
    }
    return QString();
}

QString JGstMediaInfo::getAudioInfoByKey(const QString &key) const
{
    if(m_nAudioStreamInfo.contains(key)){
        return m_nAudioStreamInfo.value(key);
    }
    return QString();
}

QString JGstMediaInfo::getVideoInfoByKey(const QString &key) const
{
    if(m_nVideoStreamInfo.contains(key)){
        return m_nVideoStreamInfo.value(key);
    }
    return QString();
}

QString JGstMediaInfo::getSubtitleInfoByKey(const QString &key) const
{
    if(m_nSubtitleStreamInfo.contains(key)){
        return m_nSubtitleStreamInfo.value(key);
    }
    return QString();
}

QString JGstMediaInfo::id() const
{
    return m_nId;
}

QImage JGstMediaInfo::getCoverImage() const
{
    return m_nCoverImage;
}

void JGstMediaInfo::resetData()
{
    m_nId = QUuid::createUuid().toString();
    m_nId = m_nId.replace("{", "").replace("}", "");
    m_nCoverImage = QImage();
    m_nproperties.clear();
    m_nAudioStreamInfo.clear();
    m_nVideoStreamInfo.clear();
    m_nSubtitleStreamInfo.clear();
}



JMultiMediaFileImageProvider* JMultiMediaFileImageProvider::g_pSingleton = nullptr;
QMutex JMultiMediaFileImageProvider::m_nMutex;

JMultiMediaFileImageProvider *JMultiMediaFileImageProvider::instance()
{
    QMutexLocker locker(&JMultiMediaFileImageProvider::m_nMutex);
    if(g_pSingleton == nullptr){
        g_pSingleton = new JMultiMediaFileImageProvider();
    }
    return g_pSingleton;
}

JMultiMediaFileImageProvider::~JMultiMediaFileImageProvider()
{
    g_pSingleton = nullptr;
    m_VideImages.clear();
}

QImage JMultiMediaFileImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    QImage image;
    if(id.contains("file")) {
        if(m_VideImages.contains(id)) {
           image =  m_VideImages.value(id);
        }
    } else {
        for (auto info : m_nGstMediaInfos ) {
            if(info->id() == id){
                image = info->getCoverImage();
                break;
            }
        }
        if(image.isNull()){
            if(m_nDefaultImage.isNull()){
                m_nDefaultImage = QImage(m_nBaseUrl +"/image/cover_default.png");
            }
            return m_nDefaultImage;
        }
    }
    return image;
}

void JMultiMediaFileImageProvider::setSource(JGstMediaInfo *info)
{
    if(m_nGstMediaInfos.contains(info) == false){
        m_nGstMediaInfos.append(info);
    }
}
void JMultiMediaFileImageProvider::setSource(const QString &id,const QImage &image)
{
    if(!m_VideImages.contains(id)) {
        m_VideImages.insert(id,image);
    }
}

void JMultiMediaFileImageProvider::deleteSource(JGstMediaInfo *info)
{
    if(m_nGstMediaInfos.contains(info)){
        m_nGstMediaInfos.removeAll(info);
    }
}

bool JMultiMediaFileImageProvider::imageExit(const QString &id)
{
    return m_VideImages.contains(id);
}


void JMultiMediaFileImageProvider::setBaseUrl(const QString &url)
{
    m_nBaseUrl = url;
    if(m_nBaseUrl.startsWith("file://")){
       m_nBaseUrl= m_nBaseUrl.mid(7);
    }
}

JMultiMediaFileImageProvider::JMultiMediaFileImageProvider():QQuickImageProvider(QQmlImageProviderBase::Image)
{
}
