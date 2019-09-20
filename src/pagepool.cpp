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

#include "pagepool.h"

#include <QDebug>
#include <QQmlEngine>
#include <QQmlComponent>

class PagePoolSingleton
{
public:
    PagePool self;
};

Q_GLOBAL_STATIC(PagePoolSingleton, privatePagePoolSelf)


PagePool::PagePool(QObject *parent)
    : QObject(parent)
{
}

PagePool::~PagePool()
{
}

PagePool *PagePool::self()
{
    return &privatePagePoolSelf()->self;
}



QQuickItem *PagePool::pageForUrl(const QString &url)
{
    if (m_itemForUrl.contains(url)) {
        return m_itemForUrl[url];
    }

    Q_ASSERT(qmlEngine(this));
    QQmlContext *ctx = QQmlEngine::contextForObject(this);
    Q_ASSERT(ctx);
    QQmlComponent component(qmlEngine(this), url);

    QObject *obj = component.create(ctx);
    // Error?
    if (!obj) {
        return nullptr;
    }

    QQuickItem *item = qobject_cast<QQuickItem *>(obj);
    if (!item) {
        obj->deleteLater();
        return nullptr;
    }

    m_itemForUrl[url] = item;
    return item;
}

QString PagePool::urlForPage(QQuickItem *item) const
{
    return m_urlForItem.value(item);
}

bool PagePool::contains(const QVariant &page) const
{
    if (page.canConvert<QQuickItem *>()) {
        return m_urlForItem.contains(page.value<QQuickItem *>());
    } else if (page.canConvert<QString>()) {
        return m_itemForUrl.contains(page.value<QString>());
    } else {
        return false;
    }
}

void PagePool::deletePage(const QVariant &page)
{
    if (!contains(page)) {
        return;
    }

    QQuickItem *item;
    if (page.canConvert<QQuickItem *>()) {
        item = page.value<QQuickItem *>();
    } else if (page.canConvert<QString>()) {
        QString url = page.value<QString>();
        if (url.isEmpty()) {
            return;
        }

        item = m_itemForUrl.value(url);
    } else {
        return;
    }

    if (!item) {
        return;
    }

    QString url = m_urlForItem.value(item);

    if (url.isEmpty()) {
        return;
    }

    m_itemForUrl.remove(url);
    m_urlForItem.remove(item);
    item->deleteLater();
}


#include "moc_pagepool.cpp"
