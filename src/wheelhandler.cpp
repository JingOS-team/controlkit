/*
*   Copyright (C) 2019 by Marco Martin <mart@kde.org>
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
*/

#include "wheelhandler.h"
#include "settings.h"
#include <QWheelEvent>
#include <QQuickItem>
#include <QDebug>


KirigamiWheelEvent::KirigamiWheelEvent(QObject *parent)
    : QObject(parent)
{}

KirigamiWheelEvent::~KirigamiWheelEvent()
{}

void KirigamiWheelEvent::initializeFromEvent(QWheelEvent *event)
{
    m_x = event->x();
    m_y = event->y();
    m_angleDelta = event->angleDelta();
    m_pixelDelta = event->pixelDelta();
    m_buttons = event->buttons();
    m_modifiers = event->modifiers();
    m_accepted = false;
    m_inverted = event->inverted();
}

qreal KirigamiWheelEvent::x() const
{
    return m_x;
}

qreal KirigamiWheelEvent::y() const
{
    return m_y;
}

QPointF KirigamiWheelEvent::angleDelta() const
{
    return m_angleDelta;
}

QPointF KirigamiWheelEvent::pixelDelta() const
{
    return m_pixelDelta;
}

int KirigamiWheelEvent::buttons() const
{
    return m_buttons;
}

int KirigamiWheelEvent::modifiers() const
{
    return m_modifiers;
}

bool KirigamiWheelEvent::inverted() const
{
    return m_inverted;
}

bool KirigamiWheelEvent::isAccepted()
{
    return m_accepted;
}

void KirigamiWheelEvent::setAccepted(bool accepted)
{
    m_accepted = accepted;
}


///////////////////////////////

WheelHandler::WheelHandler(QObject *parent)
    : QObject(parent)
{
}

WheelHandler::~WheelHandler()
{
}

QQuickItem *WheelHandler::target() const
{
    return m_target;
}

void WheelHandler::setTarget(QQuickItem *target)
{
    if (m_target == target) {
        return;
    }

    if (m_target) {
        m_target->removeEventFilter(this);
    }

    m_target = target;

    if (m_target) {
        m_target->installEventFilter(this);

        // Duck typing: accept everyhint that has all the properties we need
        m_targetIsFlickable = m_target->metaObject()->indexOfProperty("contentX") > -1
            && m_target->metaObject()->indexOfProperty("contentY") > -1
            && m_target->metaObject()->indexOfProperty("contentWidth") > -1
            && m_target->metaObject()->indexOfProperty("contentHeight") > -1
            && m_target->metaObject()->indexOfProperty("topMargin") > -1
            && m_target->metaObject()->indexOfProperty("bottomMargin") > -1
            && m_target->metaObject()->indexOfProperty("leftMargin") > -1
            && m_target->metaObject()->indexOfProperty("rightMargin") > -1
            && m_target->metaObject()->indexOfProperty("originX") > -1
            && m_target->metaObject()->indexOfProperty("originY") > -1;

    } else {
        m_targetIsFlickable = false;
    }

    emit targetChanged();
}

bool WheelHandler::eventFilter(QObject *watched, QEvent *event)
{
    if (event->type() == QEvent::Wheel) {
        QWheelEvent *we = static_cast<QWheelEvent *>(event);
        m_wheelEvent.initializeFromEvent(we);

        emit wheel(&m_wheelEvent);

        if (m_scrollFlickableTarget && !m_wheelEvent.isAccepted()) {
            manageWheel(we);
        }

        if (m_blockTargetWheel) {
            return true;
        }
    }
    return QObject::eventFilter(watched, event);
}

void WheelHandler::manageWheel(QWheelEvent *event)
{
    if (!m_targetIsFlickable) {
        return;
    }

    qreal contentWidth = m_target->property("contentWidth").toReal();
    qreal contentHeight = m_target->property("contentHeight").toReal();
    qreal contentX = m_target->property("contentX").toReal();
    qreal contentY = m_target->property("contentY").toReal();
    qreal topMargin = m_target->property("topMargin").toReal();
    qreal bottomMargin = m_target->property("bottomMargin").toReal();
    qreal leftMargin = m_target->property("leftMaring").toReal();
    qreal rightMargin = m_target->property("rightMargin").toReal();
    qreal originX = m_target->property("originX").toReal();
    qreal originY = m_target->property("originY").toReal();

    // Scroll Y
    if (contentHeight > m_target->height()) {

        int y = event->pixelDelta().y() != 0 ? event->pixelDelta().y() : event->angleDelta().y() / 8;

        //if we don't have a pixeldelta, apply the configured mouse wheel lines
        if (!event->pixelDelta().y()) {
            y *= Settings::self()->mouseWheelScrollLines();
        }

        // Scroll one page regardless of delta:
        if ((event->modifiers() & Qt::ControlModifier) || (event->modifiers() & Qt::ShiftModifier)) {
            if (y > 0) {
                y = m_target->height();
            } else if (y < 0) {
                y = -m_target->height();
            }
        }

        qreal minYExtent = topMargin - originY;
        qreal maxYExtent = m_target->height() - (contentHeight + bottomMargin + originY);

        m_target->setProperty("contentY", qMin(-maxYExtent, qMax(-minYExtent, contentY - y)));
    }
    
    //Scroll X
    if (contentWidth > m_target->width()) {

        int x = event->pixelDelta().x() != 0 ? event->pixelDelta().x() : event->angleDelta().x() / 8;

        // Special case: when can't scroll vertically, scroll horizontally with vertical wheel as well
        if (x == 0 && contentHeight <= m_target->height()) {
            x = event->pixelDelta().y() != 0 ? event->pixelDelta().y() : event->angleDelta().y() / 8;
        }

        //if we don't have a pixeldelta, apply the configured mouse wheel lines
        if (!event->pixelDelta().x()) {
            x *= Settings::self()->mouseWheelScrollLines();
        }

        // Scroll one page regardless of delta:
        if ((event->modifiers() & Qt::ControlModifier) || (event->modifiers() & Qt::ShiftModifier)) {
            if (x > 0) {
                x = m_target->width();
            } else if (x < 0) {
                x = -m_target->width();
            }
        }

        qreal minXExtent = leftMargin - originX;
        qreal maxXExtent = m_target->width() - (contentWidth + rightMargin + originX);

        m_target->setProperty("contentX", qMin(-maxXExtent, qMax(-minXExtent, contentX - x)));
    }

    //this is just for making the scrollbar 
    m_target->metaObject()->invokeMethod(m_target, "flick", Q_ARG(double, 0), Q_ARG(double, 1));
    m_target->metaObject()->invokeMethod(m_target, "cancelFlick");
}


WheelHandler *WheelHandler::qmlAttachedProperties(QObject *object)
{
    return new WheelHandler(object);
}

#include "moc_wheelhandler.cpp"
