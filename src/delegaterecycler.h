/*
 *   Copyright 2018 Marco Martin <mart@kde.org>
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

#ifndef DELEGATERECYCLER_H
#define DELEGATERECYCLER_H

#include <QQuickItem>
#include <QVariant>
#include <QPointer>


class DelegateCache;

class DelegateRecycler : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QQmlComponent *sourceComponent READ sourceComponent WRITE setSourceComponent RESET resetSourceComponent NOTIFY sourceComponentChanged)

public:
    DelegateRecycler(QQuickItem *parent=0);
    ~DelegateRecycler();


    QQmlComponent *sourceComponent() const;
    void setSourceComponent(QQmlComponent *component);
    void resetSourceComponent();

protected:
    void geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry) override;

    void updateSize(bool parentResized);

Q_SIGNALS:
    void sourceComponentChanged();

private:
    QPointer<QQmlComponent> m_sourceComponent;
    QPointer<QQuickItem> m_item;
    bool m_updatingSize = false;
};

#endif
