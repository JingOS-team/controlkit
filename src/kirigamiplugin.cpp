/*
 *   Copyright 2009 by Alan Alpert <alan.alpert@nokia.com>
 *   Copyright 2010 by Ménard Alexis <menard@kde.org>
 *   Copyright 2010 by Marco Martin <mart@kde.org>

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

#include "kirigamiplugin.h"

#include <QQmlExtensionPlugin>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickItem>

QString KirigamiPlugin::componentPath(const QString &fileName) const
{
    QString candidate;

    foreach (const QString &style, m_stylesFallbackChain) {
        candidate = baseUrl().toString() + QStringLiteral("/styles/") + style + QLatin1Char('/') + fileName;
        if (QFile::exists(QUrl(candidate).path())) {
            return candidate;
        }
    }

    return baseUrl().toString() + QLatin1Char('/') + fileName;
}

void KirigamiPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.kirigami"));

    const QString style = QString::fromLatin1(qgetenv("QT_QUICK_CONTROLS_STYLE"));

   /* if (!style.isEmpty() && QFile::exists(baseUrl().path() + QStringLiteral("/styles/Desktop"))) {
        m_stylesFallbackChain.prepend(QStringLiteral("Desktop"));
    }*/

    if (!style.isEmpty() && QFile::exists(baseUrl().path() + QStringLiteral("/styles/") + style)) {
        m_stylesFallbackChain.prepend(style);
    }
    //At this point the fallback chain will be selected->Desktop->Fallback


    //TODO: in this plugin it will end up something similar to
    //PlasmaCore's ColorScope?

    qmlRegisterSingletonType(componentPath(QStringLiteral("Theme.qml")), uri, 1, 0, "Theme");
    qmlRegisterSingletonType(componentPath(QStringLiteral("Units.qml")), uri, 1, 0, "Units");

    qmlRegisterType(componentPath(QStringLiteral("Action.qml")), uri, 1, 0, "Action");
    qmlRegisterType(componentPath(QStringLiteral("AbstractApplicationHeader.qml")), uri, 1, 0, "AbstractApplicationHeader");
    qmlRegisterType(componentPath(QStringLiteral("AbstractApplicationWindow.qml")), uri, 1, 0, "AbstractApplicationWindow");
    qmlRegisterType(componentPath(QStringLiteral("AbstractListItem.qml")), uri, 1, 0, "AbstractListItem");
    qmlRegisterType(componentPath(QStringLiteral("ApplicationHeader.qml")), uri, 1, 0, "ApplicationHeader");
    qmlRegisterType(componentPath(QStringLiteral("ApplicationWindow.qml")), uri, 1, 0, "ApplicationWindow");
    qmlRegisterType(componentPath(QStringLiteral("BasicListItem.qml")), uri, 1, 0, "BasicListItem");
    qmlRegisterType(componentPath(QStringLiteral("OverlayDrawer.qml")), uri, 1, 0, "OverlayDrawer");
    qmlRegisterType(componentPath(QStringLiteral("ContextDrawer.qml")), uri, 1, 0, "ContextDrawer");
    qmlRegisterType(componentPath(QStringLiteral("GlobalDrawer.qml")), uri, 1, 0, "GlobalDrawer");
    qmlRegisterType(componentPath(QStringLiteral("Heading.qml")), uri, 1, 0, "Heading");
    qmlRegisterType(componentPath(QStringLiteral("Icon.qml")), uri, 1, 0, "Icon");
    qmlRegisterType(componentPath(QStringLiteral("Label.qml")), uri, 1, 0, "Label");
    qmlRegisterType(componentPath(QStringLiteral("OverlaySheet.qml")), uri, 1, 0, "OverlaySheet");
    qmlRegisterType(componentPath(QStringLiteral("Page.qml")), uri, 1, 0, "Page");
    qmlRegisterType(componentPath(QStringLiteral("ScrollablePage.qml")), uri, 1, 0, "ScrollablePage");
    qmlRegisterType(componentPath(QStringLiteral("SplitDrawer.qml")), uri, 1, 0, "SplitDrawer");
    qmlRegisterType(componentPath(QStringLiteral("SwipeListItem.qml")), uri, 1, 0, "SwipeListItem");
}


#include "moc_kirigamiplugin.cpp"

