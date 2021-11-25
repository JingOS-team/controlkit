/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#include "jbasevideosurface.h"
#include <QDebug>
JBaseVideoSurface::JBaseVideoSurface(QObject *parent) : QAbstractVideoSurface(parent)
{

}

JBaseVideoSurface::~JBaseVideoSurface()
{

}

QList<QVideoFrame::PixelFormat>  JBaseVideoSurface::supportedPixelFormats(QAbstractVideoBuffer::HandleType handleType) const
{
    Q_UNUSED(handleType);
    return QList<QVideoFrame::PixelFormat>()
            << QVideoFrame::Format_YUV420P
            << QVideoFrame::Format_YV12
            << QVideoFrame::Format_NV12
            << QVideoFrame::Format_NV21
            << QVideoFrame::Format_UYVY
            << QVideoFrame::Format_YUYV
            << QVideoFrame::Format_RGB32
            << QVideoFrame::Format_ARGB32
            << QVideoFrame::Format_BGR32
            << QVideoFrame::Format_BGRA32
            << QVideoFrame::Format_RGB565
               ;
}

bool  JBaseVideoSurface::isFormatSupported(const QVideoSurfaceFormat &format) const
{
    return true;
}

QVideoSurfaceFormat  JBaseVideoSurface::nearestFormat(const QVideoSurfaceFormat &format) const
{
    return format;
}

bool  JBaseVideoSurface::present(const QVideoFrame &frame)
{
    if (frame.isValid()) {
        deliverFrame(frame);
        return true;
    }
    return false;
}

void JBaseVideoSurface::addRenderItem(QQuickItem *item)
{
    const QMetaObject *metaObject = item->metaObject();

    if (metaObject->indexOfProperty("videoSurface") != -1) {
        QAbstractVideoSurface* surface = item->property("videoSurface").value<QAbstractVideoSurface*>();
        if(surface && m_videoOutputHash.contains(item) == false){
            m_videoOutputHash.insert(item, surface);

            int propertyIndex = metaObject->indexOfProperty("canShowVideo");
            if (propertyIndex != -1) {
                const QMetaProperty showProperty = metaObject->property(propertyIndex);

                if (showProperty.hasNotifySignal()) {
                    QMetaMethod method = showProperty.notifySignal();
                    QMetaObject::connect(item, method.methodIndex(),
                                         this, this->metaObject()->indexOfSlot("updateRenderInfo()"),
                                         Qt::DirectConnection, 0);

                }
            }
        }
    }
}

void JBaseVideoSurface::clearRenderItem(QQuickItem *item)
{
    m_videoOutputHash.remove(item);
}

void JBaseVideoSurface::updateRenderInfo()
{

    QQuickItem* item = dynamic_cast<QQuickItem*>(sender());
    if(m_videoOutputHash.contains(item)){
        if(item->property("canShowVideo").toBool() == false){
            QAbstractVideoSurface *surface = m_videoOutputHash.value(item);
            if(surface->isActive() == false){
                QVideoSurfaceFormat format = surfaceFormat();
                qInfo() << Q_FUNC_INFO << " format " << format.pixelFormat() << " size " << format.frameSize();
                surface->start(format);
            }
            QVideoFrame frame;
            surface->present(frame);
            surface->stop();
        }
    }
}

void JBaseVideoSurface::deliverFrame(const QVideoFrame &frame)
{
    QHash<QQuickItem*, QAbstractVideoSurface*>::iterator bIter = m_videoOutputHash.begin();
    QHash<QQuickItem*, QAbstractVideoSurface*>::iterator eIter = m_videoOutputHash.end();

    while(bIter != eIter){
        QQuickItem* pItem = bIter.key();
        QAbstractVideoSurface *surface = bIter.value();
        if(surface){
            if(pItem->property("canShowVideo").toBool() == true){
                if(surface->isActive() == false){
                    QVideoSurfaceFormat format = surfaceFormat();
                    qInfo() << Q_FUNC_INFO << " format " << format.pixelFormat() << " size " << format.frameSize();
                    surface->start(format);
                }
                surface->present(frame);
            }
        }

        bIter++;
    }
}
