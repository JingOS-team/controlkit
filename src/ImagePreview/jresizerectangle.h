/*
 * SPDX-FileCopyrightText: (C) 2020 Carl Schwan <carl@carlschwan.eu>
 * SPDX-FileCopyrightText: (C) 2021 Rui Wang <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#pragma once

#include <QQuickItem>

class JResizeRectangle : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QRectF moveAreaRect READ moveAreaRect WRITE setMoveAreaRect NOTIFY rectangleChanged)
    Q_PROPERTY(bool isMoving READ isMoving WRITE setIsMoving NOTIFY isMovingChanged)
public:
    JResizeRectangle(QQuickItem *parent = nullptr);



    QRectF moveAreaRect(){
        return m_moveArea;
    }

    void setMoveAreaRect(const QRectF &moveArea){
        m_moveArea = moveArea;
        m_currentArea = QRectF(x(),y(),width(),height());
        Q_EMIT rectangleChanged();
    }

    ~JResizeRectangle() = default;

    bool isMoving() const;
    void setIsMoving(bool v);
private:
    bool isMutilPoint = false;
    QRectF m_moveArea;
    QRectF m_currentArea;


protected:
    void mouseReleaseEvent(QMouseEvent *event) override;
    void mousePressEvent(QMouseEvent * event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void mouseDoubleClickEvent(QMouseEvent *event) override;
    void touchEvent(QTouchEvent *event) override;

Q_SIGNALS:
    /// Double click event signal
    void acceptSize();
    void moveRect(bool isMove);
    void isMovingChanged();
    void rectangleChanged();
public Q_SLOTS:
    void onWidthChanged();
private:
    QPointF m_mouseDownPosition;
    QPointF m_mouseDownGeometry;
    bool m_nIsMoving = false;
};
