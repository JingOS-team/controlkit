/*
 *   Copyright 2019 by Marco Martin <mart@kde.org>
 *   Copyright 2020 by Carl Schwan <carl@carlschwan.eu>
 *   Copyright 2021 Rui Wang <wangrui@jingos.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

#include "jresizehandle.h"

#include <QCursor>
#include <cmath>
#include <QDebug>

JResizeHandle::JResizeHandle(QQuickItem *parent)
    : QQuickItem(parent)
{
    setAcceptedMouseButtons(Qt::LeftButton);

    auto syncCursor = [this] () {
        switch (m_resizeCorner) {
        case Left:
        case Right:
            setCursor(QCursor(Qt::SizeHorCursor));
            break;
        case Top:
        case Bottom:
            setCursor(QCursor(Qt::SizeVerCursor));
            break;
        case TopLeft:
        case BottomRight:
            setCursor(QCursor(Qt::SizeFDiagCursor));
            break;
        case TopRight:
        case BottomLeft:
        default:
            setCursor(Qt::SizeBDiagCursor);
        }
    };

    syncCursor();
    connect(this, &JResizeHandle::resizeCornerChanged, this, syncCursor);

}

JResizeHandle::~JResizeHandle()
{

}

QQuickItem *JResizeHandle::rectangle() const
{
    return m_rectangle;
}

void JResizeHandle::setRectangle(QQuickItem *rectangle)
{
    if (m_rectangle == rectangle) {
        return;
    }
    m_rectangle = rectangle;
    Q_EMIT rectangleChanged();

}

bool JResizeHandle::resizeBlocked() const
{
    return false;
}

bool JResizeHandle::isPressed() const
{
    return m_nIsPressed;
}

void JResizeHandle::setIsPressed(bool v)
{
    if(m_nIsPressed != v){
        m_nIsPressed = v;
        Q_EMIT isPressedChanged();
    }
}

bool JResizeHandle::resizeLeft() const
{
    return m_resizeCorner == Left || m_resizeCorner == TopLeft || m_resizeCorner == BottomLeft;
}

bool JResizeHandle::resizeTop() const
{
    return m_resizeCorner == Top || m_resizeCorner == TopLeft || m_resizeCorner == TopRight;
}

bool JResizeHandle::resizeRight() const
{
    return m_resizeCorner == Right || m_resizeCorner == TopRight ||m_resizeCorner == BottomRight;
}

bool JResizeHandle::resizeBottom() const
{
    return m_resizeCorner == Bottom || m_resizeCorner == BottomLeft || m_resizeCorner == BottomRight;
}

void JResizeHandle::setResizeBlocked(bool width, bool height)
{
    if (m_resizeWidthBlocked == width && m_resizeHeightBlocked == height) {
        return;
    }

    m_resizeWidthBlocked = width;
    m_resizeHeightBlocked = height;

    Q_EMIT resizeBlockedChanged();
}


void JResizeHandle::mousePressEvent(QMouseEvent *event)
{
    m_mouseDownPosition = event->windowPos();
    m_mouseDownGeometry = QRectF(m_rectangle->x(), m_rectangle->y(), m_rectangle->width(), m_rectangle->height());
    setResizeBlocked(false, false);
    event->accept();
    setIsPressed(true);
}

void JResizeHandle::mouseMoveEvent(QMouseEvent *event)
{

    if(m_nIsPressed == false){
        return;
    }
    const QPointF difference = m_mouseDownPosition - event->windowPos();

    const QSizeF minimumSize = QSize(20, 20);

    // Horizontal resize
    if (resizeLeft()) {
        const qreal width = qMax(minimumSize.width(), m_mouseDownGeometry.width() + difference.x());
        const qreal x = m_mouseDownGeometry.x() + (m_mouseDownGeometry.width() - width);

        if(x >= m_moveArea.x() && width > 150){
            m_rectangle->setX(x);
            m_rectangle->setWidth(width);
            setResizeBlocked(m_mouseDownGeometry.width() + difference.x() < minimumSize.width(), m_resizeHeightBlocked);
        } else if( x < m_moveArea.x()){
            m_rectangle->setX(m_moveArea.x());
            qreal w = width - static_cast<qreal>(m_moveArea.x() - x);
            m_rectangle->setWidth(w);
        }
    } else if (resizeRight()) {
        const qreal width = qMax(minimumSize.width(), m_mouseDownGeometry.width() - difference.x());

        if((m_moveArea.x() + m_moveArea.width()) >= (m_rectangle->x() +width) && width > 150){
            m_rectangle->setWidth(width);
            setResizeBlocked(m_mouseDownGeometry.width() - difference.x() < minimumSize.width(), m_resizeHeightBlocked);
        } else if((m_moveArea.x() + m_moveArea.width()) < (m_rectangle->x() +width)){
            qreal w = m_rectangle->x() + width - (m_moveArea.x() + m_moveArea.width());
            m_rectangle->setWidth(width - w);
        }
    }

    // Vertical Resize
    if (resizeTop()) {
        const qreal height = qMax(minimumSize.height(), m_mouseDownGeometry.height() + difference.y());
        const qreal y = m_mouseDownGeometry.y() + (m_mouseDownGeometry.height() - height);
        if(y >= m_moveArea.y() && height > 150){
            m_rectangle->setY(y);
            m_rectangle->setHeight(height);
            setResizeBlocked(m_resizeWidthBlocked,
                             m_mouseDownGeometry.height() + difference.y() < minimumSize.height());
        } else if( y < m_moveArea.y()){
            m_rectangle->setY(m_moveArea.y());
            qreal h = height - static_cast<qreal>(m_moveArea.y() - y);
            m_rectangle->setHeight(h);
        }
    } else if (resizeBottom()) {
        const qreal height = qMax(minimumSize.height(), m_mouseDownGeometry.height() - difference.y());
        if((m_moveArea.y() + m_moveArea.height()) >= (m_rectangle->y() +height)  && height > 150){
            m_rectangle->setHeight(qMax(height, minimumSize.height()));
            setResizeBlocked(m_resizeWidthBlocked, m_mouseDownGeometry.height() - difference.y() < minimumSize.height());
        } else if((m_moveArea.y() + m_moveArea.height()) < (m_rectangle->y() +height)){
            qreal h = (m_rectangle->y() +height) - (m_moveArea.y() + m_moveArea.height());
            m_rectangle->setHeight(height - h);
        }
    }

    event->accept();
}

void JResizeHandle::mouseReleaseEvent(QMouseEvent *event)
{
    event->accept();

    setResizeBlocked(false, false);
    Q_EMIT resizeBlockedChanged();
    Q_EMIT onReleased();
    setIsPressed(false);

}
