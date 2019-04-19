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
    m_accepted = true;
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
    }

    emit targetChanged();
}

bool WheelHandler::eventFilter(QObject *watched, QEvent *event)
{
    if (event->type() == QEvent::Wheel) {
        QWheelEvent *we = static_cast<QWheelEvent *>(event);
        m_wheelEvent.initializeFromEvent(we);

        emit wheel(&m_wheelEvent);

        if (m_blockTargetWheel) {
            return true;
        }
    }
    return QObject::eventFilter(watched, event);
}

WheelHandler *WheelHandler::qmlAttachedProperties(QObject *object)
{
    return new WheelHandler(object);
}

#include "moc_wheelhandler.cpp"
