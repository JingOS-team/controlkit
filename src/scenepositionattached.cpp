/*
*   Copyright (C) 2017 by Marco Martin <mart@kde.org>
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

#include "scenepositionattached.h"
#include <QQuickItem>
#include <QDebug>

ScenePositionAttached::ScenePositionAttached(QObject *parent)
    : QObject(parent)
{
    m_item = qobject_cast<QQuickItem *>(parent);
    connectAncestors(m_item);
}

ScenePositionAttached::~ScenePositionAttached()
{
}

int ScenePositionAttached::x() const
{
    qreal x = 0;
    QQuickItem *item = m_item;

    while (item) {
        x += item->x();
        item = item->parentItem();
    }

    return x;
}

int ScenePositionAttached::y() const
{
    qreal y = 0;
    QQuickItem *item = m_item;

    while (item) {
        y += item->y();
        item = item->parentItem();
    }

    return y;
}

void ScenePositionAttached::connectAncestors(QQuickItem *item)
{
    if (!item) {
        return;
    }

    QQuickItem *ancestor = item;
    while (ancestor) {
        m_ancestors << ancestor;

        connect(ancestor, &QQuickItem::xChanged, this, &ScenePositionAttached::xChanged);
        connect(ancestor, &QQuickItem::yChanged, this, &ScenePositionAttached::yChanged);
        connect(ancestor, &QQuickItem::parentChanged, this, 
            [this, ancestor]() {
                do {
                    disconnect(ancestor, nullptr, this, nullptr);
                    m_ancestors.pop_back();
                } while (!m_ancestors.isEmpty() && m_ancestors.last() != ancestor);

                connectAncestors(ancestor);
                emit xChanged();
                emit yChanged();
            }
        );

        ancestor = ancestor->parentItem();
    }
}

ScenePositionAttached *ScenePositionAttached::qmlAttachedProperties(QObject *object)
{
    return new ScenePositionAttached(object);
}

#include "moc_scenepositionattached.cpp"
