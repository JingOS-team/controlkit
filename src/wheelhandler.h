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

#pragma once

#include <QtQml>
#include <QPoint>
#include <QQuickItem>
#include <QObject>

class QWheelEvent;

class KirigamiWheelEvent : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal x READ x CONSTANT)
    Q_PROPERTY(qreal y READ y CONSTANT)
    Q_PROPERTY(QPointF angleDelta READ angleDelta CONSTANT)
    Q_PROPERTY(QPointF pixelDelta READ pixelDelta CONSTANT)
    Q_PROPERTY(int buttons READ buttons CONSTANT)
    Q_PROPERTY(int modifiers READ modifiers CONSTANT)
    Q_PROPERTY(bool inverted READ inverted CONSTANT)
    Q_PROPERTY(bool accepted READ isAccepted WRITE setAccepted)

public:
    KirigamiWheelEvent(QObject *parent = nullptr);
    ~KirigamiWheelEvent();

    void initializeFromEvent(QWheelEvent *event);

    qreal x() const;
    qreal y() const;
    QPointF angleDelta() const;
    QPointF pixelDelta() const;
    int buttons() const;
    int modifiers() const;
    bool inverted() const;
    bool isAccepted();
    void setAccepted(bool accepted);

private:
    qreal m_x = 0;
    qreal m_y = 0;
    QPointF m_angleDelta;
    QPointF m_pixelDelta;
    Qt::MouseButtons m_buttons = Qt::NoButton;
    Qt::KeyboardModifiers m_modifiers = Qt::NoModifier;
    bool m_inverted = false;
    bool m_accepted = false;
};


class WheelHandler : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QQuickItem *target READ target WRITE setTarget NOTIFY targetChanged)

public:

    explicit WheelHandler(QObject *parent = nullptr);
    ~WheelHandler() override;

    QQuickItem *target() const;
    void setTarget(QQuickItem *target);

    //QML attached property
    static WheelHandler *qmlAttachedProperties(QObject *object);

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

Q_SIGNALS:
    void targetChanged();
    void wheel(KirigamiWheelEvent *wheel);

private:
    QPointer<QQuickItem> m_target;
    bool m_targetIsFlickable = false;
    KirigamiWheelEvent m_wheelEvent;
};

QML_DECLARE_TYPEINFO(WheelHandler, QML_HAS_ATTACHED_PROPERTIES)

