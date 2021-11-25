/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#ifndef MPVRENDERITEM_H
#define MPVRENDERITEM_H

#include <QtQuick/QQuickFramebufferObject>

class MpvRenderer;
class MpvObject;
class QSGRectangleNode;
class MpvRenderItem: public QQuickFramebufferObject
{
    Q_OBJECT
    Q_PROPERTY(MpvObject* mpvObj READ mpvObj WRITE setMpvObj NOTIFY mpvObjChanged)
    Q_PROPERTY(bool canShowVideo READ canShowVideo WRITE setCanShowVideo NOTIFY canShowVideoChanged)
public:
    MpvRenderItem(QQuickItem * parent = 0);
    ~MpvRenderItem();

    virtual Renderer *createRenderer() const override;

    MpvObject* mpvObj() const;
    void setMpvObj(MpvObject* mObj);

    bool canShowVideo() const;
    void setCanShowVideo(bool v);

    void setFirstSetCallback(bool v);
    bool isFirstSetCallback();
Q_SIGNALS:
    void mpvObjChanged();
    void canShowVideoChanged();
protected:
    QSGNode *updatePaintNode(QSGNode *node, UpdatePaintNodeData *data) override;
    void timerEvent(QTimerEvent *event) override;

private:
    MpvObject *m_pObj = nullptr;

    MpvRenderer* m_pRender = nullptr;
    bool m_nCanShowVideo = false;
    bool m_nFirstSetCallback = true;
    int m_nTimerId = 0;
    bool m_nRenderUsed = false;
    friend class MpvRenderer;
};

class MpvRenderer : public QQuickFramebufferObject::Renderer
{
public:
    MpvRenderer(MpvRenderItem *pItem);
    ~MpvRenderer();
    void setMpvObj(MpvObject* mpvObj);
    void invalidateCurrentFrameBuffer();
    void setCanRender(bool v);
    MpvRenderItem* m_pRenderItem = nullptr;
    MpvObject *m_pObj = nullptr;
    bool m_nCanRender = false;

    // This function is called when a new FBO is needed.
    // This happens on the initial frame.
    QOpenGLFramebufferObject * createFramebufferObject(const QSize &size);

    void render();
};


#endif // MPVRENDERITEM_H
