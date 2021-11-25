/*
 *   Copyright 2019 by Marco Martin <mart@kde.org>
 *   Copyright 2021 by Rui Wang <wangrui@jingos.com>
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

#pragma once

#include <QQuickItem>

class JResizeHandle: public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(Corner resizeCorner MEMBER m_resizeCorner NOTIFY resizeCornerChanged)
    Q_PROPERTY(bool resizeBlocked READ resizeBlocked NOTIFY resizeBlockedChanged)
    Q_PROPERTY(QQuickItem *rectangle READ rectangle WRITE setRectangle NOTIFY rectangleChanged)
    Q_PROPERTY(QRectF moveAreaRect READ moveAreaRect WRITE setMoveAreaRect NOTIFY moveRectChanged)
    Q_PROPERTY(bool isPressed READ isPressed WRITE setIsPressed NOTIFY isPressedChanged)

public:
    enum Corner {
        Left = 0,
        TopLeft,
        Top,
        TopRight,
        Right,
        BottomRight,
        Bottom,
        BottomLeft,
    };
    Q_ENUM(Corner)

    JResizeHandle(QQuickItem *parent = nullptr);
    ~JResizeHandle();

    QRectF moveAreaRect(){
        return m_moveArea;
    }

    void setMoveAreaRect(const QRectF &moveArea){
        m_moveArea = moveArea;
        Q_EMIT moveRectChanged();
    }

    QQuickItem *rectangle() const;
    void setRectangle(QQuickItem *rectangle);

    bool resizeBlocked() const;

    bool isPressed() const;
    void setIsPressed(bool v);
protected:
    void mousePressEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;

Q_SIGNALS:
    void resizeCornerChanged();
    void resizeBlockedChanged();
    void rectangleChanged();
    void onReleased();
    void moveRectChanged();

    void isPressedChanged();


private:
    inline bool resizeLeft() const;
    inline bool resizeTop() const;
    inline bool resizeRight() const;
    inline bool resizeBottom() const;
    void setResizeBlocked(bool width, bool height);

    QPointF m_mouseDownPosition;
    QRectF m_mouseDownGeometry;

    Corner m_resizeCorner = Left;
    bool m_resizeWidthBlocked = false;
    bool m_resizeHeightBlocked = false;
    QQuickItem *m_rectangle = nullptr;
    QRectF m_moveArea;
    bool m_nIsPressed = false;

};
