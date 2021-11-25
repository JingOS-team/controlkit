/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#ifndef JBASEVIDEOSURFACE_H
#define JBASEVIDEOSURFACE_H

#include <QObject>
#include <QAbstractVideoSurface>
#include <QVideoSurfaceFormat>
#include <QVideoFrame>
#include <QQuickItem>
#include <QHash>
class JBaseVideoSurface : public QAbstractVideoSurface
{
    Q_OBJECT
public:
    explicit JBaseVideoSurface(QObject *parent = nullptr);
    ~JBaseVideoSurface();

    QList<QVideoFrame::PixelFormat> supportedPixelFormats( QAbstractVideoBuffer::HandleType handleType = QAbstractVideoBuffer::NoHandle) const override;
    bool isFormatSupported(const QVideoSurfaceFormat &format) const override;

    QVideoSurfaceFormat nearestFormat(const QVideoSurfaceFormat &format) const override;

    bool present(const QVideoFrame &frame) override;

    Q_INVOKABLE void addRenderItem(QQuickItem* item);
    Q_INVOKABLE void clearRenderItem(QQuickItem* item);
public Q_SLOTS:
    void updateRenderInfo();
private:
    void deliverFrame(const QVideoFrame& frame);


private:
    QHash<QQuickItem*, QAbstractVideoSurface*> m_videoOutputHash;

};

#endif // JBASEVIDEOSURFACE_H
