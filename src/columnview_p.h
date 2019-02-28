/*
 *   Copyright 2019 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#pragma once

#include "columnview.h"

#include <QQuickItem>
#include <QPointer>

class QPropertyAnimation;
class QQmlComponent;

class QmlComponentsPool: public QObject {
    Q_OBJECT

public:
    QmlComponentsPool(QObject *parent = nullptr);
    ~QmlComponentsPool();

    void initialize(QQmlEngine *engine);

    QQmlComponent *m_separatorComponent = nullptr;
    QObject *m_units = nullptr;

Q_SIGNALS:
    void gridUnitChanged();
    void longDurationChanged();

private:
    QObject *m_instance = nullptr;
};

class ContentItem : public QQuickItem {
    Q_OBJECT

public:
    ContentItem(ColumnView *parent = nullptr);
    ~ContentItem();

    void layoutItems();
    qreal childWidth(QQuickItem *child);
    void updateVisibleItems();
    void forgetItem(QQuickItem *item);
    QQuickItem *ensureSeparator(QQuickItem *item);

    void setBoundedX(qreal x);
    void animateX(qreal x);
    void snapToItem();

protected:
    void itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value) override;
    void geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry) override;

private Q_SLOTS:
    void syncItemsOrder();
    void updateRepeaterModel();

private:
    ColumnView *m_view;
    QPropertyAnimation *m_slideAnim;
    QList<QQuickItem *> m_items;
    QList<QObject *> m_visibleItems;
    QPointer<QQuickItem> m_viewAnchorItem;
    QHash<QQuickItem *, QQuickItem *> m_separators;
    QHash<QObject *, QObject*> m_models;

    qreal m_columnWidth = 0;
    ColumnView::ColumnResizeMode m_columnResizeMode = ColumnView::FixedColumns;
    bool m_shouldAnimate = false;
    friend class ColumnView;
};

