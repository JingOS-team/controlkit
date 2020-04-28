/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include <QJsonValue>
#include <QJsonObject>
#include <QJSValue>
#include <QJSEngine>
#include <QQmlProperty>
#include <QQuickWindow>
#include "pagerouter.h"

ParsedRoute parseRoute(QJSValue value)
{
    if (value.isUndefined()) {
        return ParsedRoute{QString(), QVariant(), false, nullptr};
    } else if (value.isString()) {
        return ParsedRoute{
            value.toString(),
            QVariant(),
            false,
            nullptr
        };
    } else {
        return ParsedRoute{
            value.property(QStringLiteral("route")).toString(),
            value.property(QStringLiteral("data")).toVariant(),
            false,
            nullptr
        };
    }
}

QList<ParsedRoute> parseRoutes(QJSValue values)
{
    QList<ParsedRoute> ret;
    if (values.isArray()) {
        for (auto route : values.toVariant().toList()) {
            if (route.toString() != QString()) {
                ret << ParsedRoute{
                    route.toString(),
                    QVariant(),
                    false,
                    nullptr
                };
            } else if (route.canConvert<QVariantMap>()) {
                auto map = route.value<QVariantMap>();
                ret << ParsedRoute{
                    map.value(QStringLiteral("route")).toString(),
                    map.value(QStringLiteral("data")),
                    false,
                    nullptr
                };
            }
        }
    } else {
        ret << parseRoute(values);
    }
    return ret;
}

PageRouter::PageRouter(QQuickItem *parent) : QObject(parent)
{
    connect(this, &PageRouter::pageStackChanged, [=]() {
        connect(m_pageStack, &ColumnView::itemRemoved, [=](QQuickItem *item) {
            QList<ParsedRoute> toRemove;
            for (auto route : m_currentRoutes) {
                if (route.item == qobject_cast<QObject*>(item)) {
                    if (!route.cache) {
                        route.item->deleteLater();
                    }
                }
            }
            for (auto route : toRemove) {
                m_currentRoutes.removeAll(route);
            }
        });
        connect(m_pageStack, &ColumnView::currentIndexChanged, this, &PageRouter::currentIndexChanged);
    });
}

QQmlListProperty<PageRoute> PageRouter::routes()
{
    return QQmlListProperty<PageRoute>(this, nullptr, appendRoute, routeCount, route, clearRoutes);
}

void PageRouter::appendRoute(QQmlListProperty<PageRoute>* prop, PageRoute* route)
{
    auto router = qobject_cast<PageRouter*>(prop->object);
    router->m_routes.append(route);
}

int PageRouter::routeCount(QQmlListProperty<PageRoute>* prop)
{
    auto router = qobject_cast<PageRouter*>(prop->object);
    return router->m_routes.length();
}

PageRoute* PageRouter::route(QQmlListProperty<PageRoute>* prop, int index)
{
    auto router = qobject_cast<PageRouter*>(prop->object);
    return router->m_routes[index];
}

void PageRouter::clearRoutes(QQmlListProperty<PageRoute>* prop)
{
    auto router = qobject_cast<PageRouter*>(prop->object);
    router->m_routes.clear();
}

PageRouter::~PageRouter() {}

void PageRouter::classBegin()
{

}

void PageRouter::componentComplete()
{
    if (m_pageStack == nullptr) {
        qCritical() << "PageRouter should be created with a ColumnView. Not doing so is undefined behaviour, and is likely to result in a crash upon further interaction.";
    } else {
        Q_EMIT pageStackChanged();
        m_currentRoutes.clear();
        push(parseRoute(initialRoute()));
    }
}

bool PageRouter::routesContainsKey(const QString &key)
{
    for (auto route : m_routes) {
        if (route->name() == key) return true;
    }
    return false;
}

QQmlComponent* PageRouter::routesValueForKey(const QString &key)
{
    for (auto route : m_routes) {
        if (route->name() == key) return route->component();
    }
    return nullptr;
}

bool PageRouter::routesCacheForKey(const QString &key)
{
    for (auto route : m_routes) {
        if (route->name() == key) return route->cache();
    }
    return false;
}

void PageRouter::push(ParsedRoute route)
{
    if (!routesContainsKey(route.name)) {
        qCritical() << "Route" << route.name << "not defined";
        return;
    }
    if (routesCacheForKey(route.name)) {
        for (auto cachedRoute : m_cachedRoutes) {
            if (cachedRoute.name == route.name && cachedRoute.data == route.data) {
                m_currentRoutes << cachedRoute;
                m_pageStack->addItem(qobject_cast<QQuickItem*>(cachedRoute.item));
                return;
            }
        }
    }
    auto context = qmlContext(this);
    auto component = routesValueForKey(route.name);
    auto createAndPush = [component, context, route, this]() {
        // We use beginCreate and completeCreate to allow
        // for a PageRouterAttached to find its parent
        // on construction time.
        auto item = component->beginCreate(context);
        item->setParent(this);
        auto clone = route;
        clone.item = item;
        clone.cache = routesCacheForKey(route.name);
        m_currentRoutes << clone;
        if (routesCacheForKey(route.name)) {
            m_cachedRoutes << clone;
        }
        auto attached = qobject_cast<PageRouterAttached*>(qmlAttachedPropertiesObject<PageRouter>(item, true));
        attached->m_router = this;
        component->completeCreate();
        m_pageStack->addItem(qobject_cast<QQuickItem*>(item));
        m_pageStack->setCurrentIndex(m_currentRoutes.length()-1);
    };

    if (component->status() == QQmlComponent::Ready) {
        createAndPush();
    } else if (component->status() == QQmlComponent::Loading) {
        connect(component, &QQmlComponent::statusChanged, [=](QQmlComponent::Status status) {
            // Loading can only go to Ready or Error.
            if (status != QQmlComponent::Ready) {
                qCritical() << "Failed to push route:" << component->errors();
            }
            createAndPush();
        });
    } else {
        qCritical() << "Failed to push route:" << component->errors();
    }
}

QJSValue PageRouter::initialRoute() const
{
    return m_initialRoute;
}

void PageRouter::setInitialRoute(QJSValue value)
{
    m_initialRoute = value;
}

void PageRouter::navigateToRoute(QJSValue route)
{
    auto incomingRoutes = parseRoutes(route);
    QList<ParsedRoute> resolvedRoutes;

    if (incomingRoutes.length() <= m_currentRoutes.length()) {
        resolvedRoutes = m_currentRoutes.mid(0, incomingRoutes.length());
    } else {
        resolvedRoutes = m_currentRoutes;
        resolvedRoutes.reserve(incomingRoutes.length()-m_currentRoutes.length());
    }

    for (int i = 0; i < incomingRoutes.length(); i++) {
        auto current = resolvedRoutes.value(i);
        auto incoming = incomingRoutes.at(i);
        if (i >= resolvedRoutes.length()) {
            resolvedRoutes.append(incoming);
        } else if (current.name != incoming.name || current.data != incoming.data) {
            resolvedRoutes.replace(i, incoming);
        }
    }

    for (auto route : m_currentRoutes) {
        if (!resolvedRoutes.contains(route)) {
            if (!route.cache) {
                route.item->deleteLater();
            }
        }
    }

    m_pageStack->clear();
    m_currentRoutes.clear();
    for (auto toPush : resolvedRoutes) {
        push(toPush);
    }
}

void PageRouter::bringToView(QJSValue route)
{
    if (route.isNumber()) {
        auto index = route.toNumber();
        m_pageStack->setCurrentIndex(index);
    } else {
        auto parsed = parseRoute(route);
        auto index = 0;
        for (auto currentRoute : m_currentRoutes) {
            if (currentRoute.name == parsed.name && currentRoute.data == parsed.data) {
                m_pageStack->setCurrentIndex(index);
                return;
            }
            index++;
        }
        qWarning() << "Route" << parsed.name << "with data" << parsed.data << "is not on the current stack of routes.";
    }
}

bool PageRouter::routeActive(QJSValue route)
{
    auto parsed = parseRoutes(route);
    if (parsed.length() > m_currentRoutes.length()) {
        return false;
    }
    for (int i = 0; i < parsed.length(); i++) {
        if (parsed[i].name != m_currentRoutes[i].name) {
            return false;
        }
        if (parsed[i].data.isValid()) {
            if (parsed[i].data != m_currentRoutes[i].data) {
                return false;
            }
        }
    }
    return true;
}

void PageRouter::pushRoute(QJSValue route)
{
    push(parseRoute(route));
}

void PageRouter::popRoute()
{
    m_pageStack->pop(qobject_cast<QQuickItem*>(m_currentRoutes.last().item));
    if (!m_currentRoutes.last().cache) {
        m_currentRoutes.last().item->deleteLater();
    }
    m_currentRoutes.removeLast();
}

QVariant PageRouter::dataFor(QObject *object)
{
    auto pointer = object;
    while (pointer != nullptr) {
        for (auto route : m_currentRoutes) {
            if (route.item == pointer) {
                return route.data;
            }
        }
        pointer = pointer->parent();
    }
    return QVariant();
}

bool PageRouter::isActive(QObject *object)
{
    auto pointer = object;
    while (pointer != nullptr) {
        auto index = 0;
        for (auto route : m_currentRoutes) {
            if (route.item == pointer) {
                return m_pageStack->currentIndex() == index;
            }
            index++;
        }
        pointer = pointer->parent();
    }
    qWarning() << "Object" << object << "not in current routes";
    return false;
}

PageRouterAttached* PageRouter::qmlAttachedProperties(QObject *object)
{
    auto attached = new PageRouterAttached(object);
    return attached;
}

void PageRouterAttached::findParent()
{
    QQuickItem *parent = qobject_cast<QQuickItem *>(this->parent());
    while (parent != nullptr) {
        auto attached = qobject_cast<PageRouterAttached*>(qmlAttachedPropertiesObject<PageRouter>(parent, false));
        if (attached != nullptr && attached->m_router != nullptr) {
            m_router = attached->m_router;
            Q_EMIT routerChanged();
            Q_EMIT dataChanged();
            Q_EMIT isCurrentChanged();
            break;
        }
        parent = parent->parentItem();
    }
}

void PageRouterAttached::navigateToRoute(QJSValue route)
{
    if (m_router) {
        m_router->navigateToRoute(route);
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
        return;
    }
}

bool PageRouterAttached::routeActive(QJSValue route)
{
    if (m_router) {
        return m_router->routeActive(route);
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
        return false;
    }
}

void PageRouterAttached::pushRoute(QJSValue route)
{
    if (m_router) {
        m_router->pushRoute(route);
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
        return;
    }
}

void PageRouterAttached::popRoute()
{
    if (m_router) {
        m_router->popRoute();
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
        return;
    }
}

void PageRouterAttached::bringToView(QJSValue route)
{
    if (m_router) {
        m_router->bringToView(route);
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
        return;
    }
}

QVariant PageRouterAttached::data() const
{
    if (m_router) {
        return m_router->dataFor(parent());
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
        return QVariant();
    }
}

bool PageRouterAttached::isCurrent() const
{
    if (m_router) {
        return m_router->isActive(parent());
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
        return false;
    }
}

QJSValue PageRouter::currentRoutes() const
{
    auto engine = qjsEngine(this);
    auto ret = engine->newArray(m_currentRoutes.length());
    for (int i = 0; i < m_currentRoutes.length(); ++i) {
        auto object = engine->newObject();
        object.setProperty(QStringLiteral("route"), m_currentRoutes[i].name);
        object.setProperty(QStringLiteral("data"), engine->toScriptValue(m_currentRoutes[i].data));
        ret.setProperty(i, object);
    }
    return ret;
}

PageRouterAttached::PageRouterAttached(QObject *parent) : QObject(parent)
{
    findParent();
    auto item = qobject_cast<QQuickItem*>(parent);
    if (item != nullptr) {
        connect(item, &QQuickItem::windowChanged, this, [this]() {
            findParent();
        });
        connect(item, &QQuickItem::parentChanged, this, [this]() {
            findParent();
        });
    }
}