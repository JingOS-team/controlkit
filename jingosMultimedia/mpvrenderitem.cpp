/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#include "mpvrenderitem.h"
#include <QQuickWindow>
#include <QOpenGLFramebufferObject>

#include <QOpenGLContext>
#include <QSGRectangleNode>
#include "mpvobject.h"

static MpvRenderItem* rendingItem = nullptr;
static void on_mpv_redraw(void *ctx)
{
    if(rendingItem && (rendingItem == ctx)){
        if(rendingItem->isFirstSetCallback() == true){
            rendingItem->setFirstSetCallback(false);
            return;
        }
        QMetaObject::invokeMethod(static_cast<MpvRenderItem*>(ctx), "update", Qt::QueuedConnection);
    }

}

MpvRenderItem::MpvRenderItem(QQuickItem * parent):QQuickFramebufferObject(parent)
{
    m_pRender = new MpvRenderer(const_cast<MpvRenderItem *>(this));
}

MpvRenderItem::~MpvRenderItem()
{
    if(m_nRenderUsed == false){
        delete m_pRender;
    }
    if(this == rendingItem){
        rendingItem = nullptr;
    }
}

//mpvrender delete by ~QSGFramebufferObjectNode()
QQuickFramebufferObject::Renderer *MpvRenderItem::createRenderer() const
{
    window()->setPersistentOpenGLContext(true);
    window()->setPersistentSceneGraph(true);

    return m_pRender;
}

MpvObject *MpvRenderItem::mpvObj() const
{
    return m_pObj;
}

void MpvRenderItem::setMpvObj(MpvObject *mObj)
{
    if(m_pObj != mObj){
        m_pObj = mObj;
        if(m_pObj){
            m_pRender->setMpvObj(m_pObj);
        }
        emit mpvObjChanged();
    }
}

bool MpvRenderItem::canShowVideo() const
{
    return m_nCanShowVideo;
}

void MpvRenderItem::setCanShowVideo(bool v)
{
    if(m_nCanShowVideo != v){
        m_nCanShowVideo = v;
        if(m_nCanShowVideo){
            rendingItem = this;
            if(m_pObj->mpv_gl){
                setFirstSetCallback(true);
                mpv_render_context_set_update_callback(m_pObj->mpv_gl, on_mpv_redraw, this);
            } else {
                m_nTimerId = startTimer(10);
            }
        } else {
            if(m_nTimerId != 0){
                killTimer(m_nTimerId);
            }
            m_pRender->invalidateCurrentFrameBuffer();
            update();
        }
        m_pRender->setCanRender(v);
    }
}

void MpvRenderItem::setFirstSetCallback(bool v)
{
    m_nFirstSetCallback = v;
}

bool MpvRenderItem::isFirstSetCallback()
{
    return m_nFirstSetCallback;
}

QSGNode *MpvRenderItem::updatePaintNode(QSGNode *node, UpdatePaintNodeData *data)
{
    //updatePaintNode transferred createRender return renderer pointer，and release in the rendering thread ，if item destroyed as soon as it is created,
    //updatepaintnode maybe't transferred, at this time, mpvrenderitem Destructor  del renderer pointer。
    if(m_nRenderUsed == false){
        m_nRenderUsed = true;
    }
    return QQuickFramebufferObject::updatePaintNode(node, data);
}

void MpvRenderItem::timerEvent(QTimerEvent *event)
{
    if(event->timerId() == m_nTimerId && m_pObj->mpv_gl){
        setFirstSetCallback(true);
        mpv_render_context_set_update_callback(m_pObj->mpv_gl, on_mpv_redraw, this);
        killTimer(m_nTimerId);
        m_nTimerId = 0;
    }
}

MpvRenderer::MpvRenderer(MpvRenderItem *pItem)
    : m_pRenderItem(pItem)
{

}

MpvRenderer::~MpvRenderer()
{

}

void MpvRenderer::setMpvObj(MpvObject *mpvObj)
{
    if(m_pObj != mpvObj){
        m_pObj = mpvObj;
    }
}

void MpvRenderer::invalidateCurrentFrameBuffer()
{
    invalidateFramebufferObject();
}

void MpvRenderer::setCanRender(bool v)
{
    m_nCanRender = v;
}

void MpvRenderer::render()
{
//    if(m_nItemDelted == true || !(m_pRenderItem->window()))
//        return;
//    m_pRenderItem->window()->resetOpenGLState();


    //if(m_pRenderItem->m_nCanShowVideo && m_pRenderItem->m_pObj){
    if(m_nCanRender &&  m_pObj && m_pObj->mpv_gl){
        QOpenGLFramebufferObject *fbo = framebufferObject();
        mpv_opengl_fbo mpfbo;
        mpfbo.fbo = static_cast<int>(fbo->handle());
        mpfbo.w = fbo->width();
        mpfbo.h = fbo->height();
        mpfbo.internal_format = 0;

        mpv_render_param params[] = {
            // Specify the default framebuffer (0) as target. This will
            // render onto the entire screen. If you want to show the video
            // in a smaller rectangle or apply fancy transformations, you'll
            // need to render into a separate FBO and draw it manually.
            {MPV_RENDER_PARAM_OPENGL_FBO, &mpfbo},
            {MPV_RENDER_PARAM_INVALID, nullptr}
        };
        // See render_gl.h on what OpenGL environment mpv expects, and
        // other API details.
        //mpv_render_context_render(m_pRenderItem->m_pObj->mpv_gl, params);
        mpv_render_context_render(m_pObj->mpv_gl, params);
    }
}


static void *get_proc_address_mpv(void *ctx, const char *name)
{
    Q_UNUSED(ctx)

    QOpenGLContext *glctx = QOpenGLContext::currentContext();
    if (!glctx) return nullptr;

    return reinterpret_cast<void *>(glctx->getProcAddress(QByteArray(name)));
}

QOpenGLFramebufferObject * MpvRenderer::createFramebufferObject(const QSize &size)
{
    // init mpv_gl:
    if (m_pObj && !m_pObj->mpv_gl){
        mpv_opengl_init_params gl_init_params{get_proc_address_mpv, nullptr, nullptr};
        mpv_render_param params[]{
            {MPV_RENDER_PARAM_API_TYPE, const_cast<char *>(MPV_RENDER_API_TYPE_OPENGL)},
            {MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, &gl_init_params},
            {MPV_RENDER_PARAM_INVALID, nullptr}
        };

        if (mpv_render_context_create(&(m_pObj->mpv_gl), m_pObj->mpv, params) < 0)
            throw std::runtime_error("failed to initialize mpv GL context");
    }

    return QQuickFramebufferObject::Renderer::createFramebufferObject(size);
}
