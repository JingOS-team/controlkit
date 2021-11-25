/*
 * SPDX-FileCopyrightText: (C) 2020 Carl Schwan <carl@carlschwan.eu>
 * SPDX-FileCopyrightText: (C) 2021 Rui Wang <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include "jresizerectangle.h"

#include <cmath>

JResizeRectangle::JResizeRectangle(QQuickItem *parent)
    : QQuickItem(parent)
{
    setAcceptedMouseButtons(Qt::LeftButton);
}

bool JResizeRectangle::isMoving() const
{
    return m_nIsMoving;
}

void JResizeRectangle::setIsMoving(bool v)
{
    if(m_nIsMoving != v){
        m_nIsMoving = v;
        Q_EMIT isMovingChanged();
    }
}

void JResizeRectangle::mouseReleaseEvent(QMouseEvent *event)
{
    if(m_moveArea.width() == width() && m_moveArea.height() == height()){
        event->ignore();
    }else {
        event->accept();
        setIsMoving(false);
    }
}

void JResizeRectangle::mousePressEvent(QMouseEvent *event)
{
    if(m_moveArea.width() == width() && m_moveArea.height() == height()){
        event->ignore();
    }else {
        m_mouseDownPosition = event->windowPos();
        m_mouseDownGeometry = QPointF(x(), y());
        event->accept();
    }
}

void JResizeRectangle::mouseMoveEvent(QMouseEvent *event)
{
    if(!isMutilPoint){
        const QPointF difference = m_mouseDownPosition - event->windowPos();
        const qreal x = m_mouseDownGeometry.x() - difference.x();
        const qreal y = m_mouseDownGeometry.y() - difference.y();
        m_currentArea = QRectF(x,y,width(),height());
        bool leftTop = m_moveArea.contains(m_currentArea);
        if(leftTop){
            setX(x);
            setY(y);
            //setIsMoving(true);
        } else {
            if(m_currentArea.x() < m_moveArea.x()){
                setX(m_moveArea.x());
            } else if((m_currentArea.x() + m_currentArea.width()) > (m_moveArea.x() + m_moveArea.width())){
                setX(m_moveArea.x() + m_moveArea.width() - m_currentArea.width());
            } else {
                setX(x);
            }

            if(m_currentArea.y() < m_moveArea.y()) {
                setY(m_moveArea.y());
            }else if((m_currentArea.y() + m_currentArea.height()) > (m_moveArea.y() + m_moveArea.height())) {
                setY(m_moveArea.y() + m_moveArea.height() - m_currentArea.height());
            } else {
                setY(y);
            }
        }
        setIsMoving(true);
        event->accept();
    } else {
      event->ignore();
      setIsMoving(false);
    }
}

void JResizeRectangle::mouseDoubleClickEvent(QMouseEvent *event)
{
    Q_EMIT acceptSize();
    event->ignore();
}

void JResizeRectangle::touchEvent(QTouchEvent *event)
{
  isMutilPoint = event->touchPoints().size() > 1;
  event->ignore();
}

void JResizeRectangle::onWidthChanged()
{
    m_currentArea = QRectF(x(),y(),width(),height());
}
