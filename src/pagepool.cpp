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
#include <QQmlContext>

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



QQuickItem *PagePool::pageForUrl(const QString &url, QJSValue callback)
{
    Q_ASSERT(qmlEngine(this));
    QQmlContext *ctx = QQmlEngine::contextForObject(this);
    Q_ASSERT(ctx);

    QUrl actualUrl(url);
    if (actualUrl.scheme().isEmpty()) {
        actualUrl = ctx->resolvedUrl(actualUrl);
    }

    if (m_itemForUrl.contains(actualUrl)) {
        return m_itemForUrl[actualUrl];
    }

    QQmlComponent *component = new QQmlComponent(qmlEngine(this), actualUrl, QQmlComponent::PreferSynchronous);

    if (component->status() == QQmlComponent::Loading) {
        if (!callback.isCallable()) {
            component->deleteLater();
            return nullptr;
        }

        connect(component, &QQmlComponent::statusChanged, this,
                [this, component, callback] (QQmlComponent::Status status) mutable {
            if (status != QQmlComponent::Ready) {
                qWarning() << component->errors();
                component->deleteLater();
                return;
            }
            QQuickItem *item = createFromComponent(component);
            if (item) {
                QJSValueList args = {qmlEngine(this)->newQObject(item)};
                callback.call(args);
            }
            component->deleteLater();
        });

        return nullptr;

    } else if (component->status() != QQmlComponent::Ready) {
        qWarning() << component->errors();
        return nullptr;
    }

    QQuickItem *item = createFromComponent(component);
    component->deleteLater();
    return item;
}

QQuickItem *PagePool::createFromComponent(QQmlComponent *component)
{
    QQmlContext *ctx = QQmlEngine::contextForObject(this);
    Q_ASSERT(ctx);

    QObject *obj = component->create(ctx);
    // Error?
    if (!obj) {
        return nullptr;
    }

    QQuickItem *item = qobject_cast<QQuickItem *>(obj);
    if (!item) {
        obj->deleteLater();
        return nullptr;
    }

    m_itemForUrl[component->url()] = item;
    return item;
}

QString PagePool::urlForPage(QQuickItem *item) const
{
    return m_urlForItem.value(item).toString();
}

bool PagePool::contains(const QVariant &page) const
{
    if (page.canConvert<QQuickItem *>()) {
        return m_urlForItem.contains(page.value<QQuickItem *>());
    } else if (page.canConvert<QString>()) {
        QUrl actualUrl(page.value<QString>());
        QQmlContext *ctx = QQmlEngine::contextForObject(this);
        Q_ASSERT(ctx);
        if (actualUrl.scheme().isEmpty()) {
            actualUrl = ctx->resolvedUrl(actualUrl);
        }
        return m_itemForUrl.contains(actualUrl);
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
        //TODO: function
        QUrl actualUrl(page.value<QString>());
        QQmlContext *ctx = QQmlEngine::contextForObject(this);
        Q_ASSERT(ctx);
        if (actualUrl.scheme().isEmpty()) {
            actualUrl = ctx->resolvedUrl(actualUrl);
        }

        item = m_itemForUrl.value(actualUrl);
    } else {
        return;
    }

    if (!item) {
        return;
    }

    const QUrl url = m_urlForItem.value(item);

    if (url.isEmpty()) {
        return;
    }

    m_itemForUrl.remove(url);
    m_urlForItem.remove(item);
    item->deleteLater();
}


#include "moc_pagepool.cpp"
