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

/**
 * Describes the mouse wheel event
 */
class KirigamiWheelEvent : public QObject
{
    Q_OBJECT

    /**
     * x: real
     *
     * X coordinate of the mouse pointer
     */
    Q_PROPERTY(qreal x READ x CONSTANT)

    /**
     * y: real
     *
     * Y coordinate of the mouse pointer
     */
    Q_PROPERTY(qreal y READ y CONSTANT)

    /**
     * angleDelta: point
     *
     * The distance the wheel is rotated in degrees.
     * The x and y coordinates indicate the horizontal and vertical wheels respectively.
     * A positive value indicates it was rotated up/right, negative, bottom/left
     * This value is more likely to be set in traditional mice.
     */
    Q_PROPERTY(QPointF angleDelta READ angleDelta CONSTANT)

    /**
     * pixelDelta: point
     *
     * provides the delta in screen pixels available on high resolution trackpads
     */
    Q_PROPERTY(QPointF pixelDelta READ pixelDelta CONSTANT)

    /**
     * buttons: int
     *
     * it contains an OR combination of the buttons that were pressed during the wheel, they can be:
     * Qt.LeftButton, Qt.MiddleButton, Qt.RightButton
     */
    Q_PROPERTY(int buttons READ buttons CONSTANT)

    /**
     * modifiers: int
     *
     * Keyboard mobifiers that were pressed during the wheel event, such as:
     * Qt.NoModifier (default, no modifiers)
     * Qt.ControlModifier
     * Qt.ShiftModifier
     * ...
     */
    Q_PROPERTY(int modifiers READ modifiers CONSTANT)

    /**
     * inverted: bool
     *
     * Whether the delta values are inverted
     * On some platformsthe returned delta are inverted, so positive values would mean bottom/left
     */
    Q_PROPERTY(bool inverted READ inverted CONSTANT)

    /**
     * accepted: bool
     *
     * If set, the event shouldn't be managed anymore,
     * for instance it can be used to block the handler to manage the scroll of a view on some scenarions
     * @code
     * // This handler handles automatically the scroll of
     * // flickableItem, unless Ctrl is pressed, in this case the 
     * // app has custom code to handle Ctrl+wheel zooming
     * Flickable {
     *     Kirigami.WheelHandler.enabled: true
     *     Kirigami.WheelHandler.onWheel: {
     *         if (wheel.modifiers & Qt.ControlModifier) {
     *             wheel.accepted = true;
     *             // Handle scaling of the view
     *         }
     *     }
     * }
     * @endcode
     * 
     */
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


/**
 * This class intercepts the mouse wheel events of its parent, and gives them to the user code as a signal, which can be used for custom mouse wheel management code.
 * The handler can block completely the wheel events from its parent, and if the parent is a Flickable, it can automatically handle scrolling on it
 */
class WheelHandler : public QObject
{
    Q_OBJECT

    /**
     * enabled: bool
     * 
     * If true it will fiter wheel events of its parent item
     */
    Q_PROPERTY(bool enabled MEMBER m_enabled NOTIFY enabledChanged)

    /**
     * blockParentWheel: bool
     *
     * If true, the target won't receive any wheel event at all (default true)
     */
    Q_PROPERTY(bool blockParentWheel MEMBER m_blockParentWheel NOTIFY blockParentWheelChanged)

    /**
     * scrollFlickableParent: bool
     * If this property is true and the target is a Flickable, wheel events will cause the Flickable to scroll (default true)
     */
    Q_PROPERTY(bool scrollFlickableParent MEMBER m_scrollFlickableParent NOTIFY scrollFlickableParentChanged)

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
    void enabledChanged();
    void blockParentWheelChanged();
    void scrollFlickableParentChanged();
    void wheel(KirigamiWheelEvent *wheel);

private:
    inline bool isFlickable(QQuickItem *item);
    void manageWheel(QWheelEvent *wheel);

    QPointer<QQuickItem> m_target;
    bool m_enabled = false;
    bool m_blockParentWheel = true;
    bool m_scrollFlickableParent = true;
    bool m_targetIsFlickable = false;
    KirigamiWheelEvent m_wheelEvent;
};

QML_DECLARE_TYPEINFO(WheelHandler, QML_HAS_ATTACHED_PROPERTIES)

