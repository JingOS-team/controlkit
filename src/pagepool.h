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

#include <QObject>
#include <QQuickItem>

/**
 * A Pool of Page items, pages will be unique per url and the items
 * will be kept around unless explicitly deleted.
 * Instance are unique per url: if you need 2 different instance for a page
 * url, you should instantiate them in the traditional way
 * or use a different PagePool instance.
 */
class PagePool : public QObject
{
    Q_OBJECT

public:
    PagePool(QObject *parent = nullptr);
    ~PagePool();

    static PagePool *self();

    /**
     * Returns the instance of the item defined in the QML file identified
     * by url, only one instance will be done per url
     * @param url full url of the item
     * @returns the page instance that will have been created if necessary
     */
    Q_INVOKABLE QQuickItem *pageForUrl(const QString &url);

    /**
     * @returns The url of the page for the given instance, empty if there is no correspondence
     */
    Q_INVOKABLE QString urlForPage(QQuickItem *item) const;

    /**
     * @returns true if the is managed by the PagePool
     * @param the page can be either a QQuickItem or an url
     */
    Q_INVOKABLE bool contains(const QVariant &page) const;

    /**
     * Deletes the page (only if is managed by the pool.
     * @param page either the url or the instance of the page
     */
    Q_INVOKABLE void deletePage(const QVariant &page);

private:
    QHash<QString, QQuickItem *> m_itemForUrl;
    QHash<QQuickItem *, QString> m_urlForItem;
};

