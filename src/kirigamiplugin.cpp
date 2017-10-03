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
#include "enums.h"
#include "desktopicon.h"
#include "settings.h"

#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickItem>

#ifdef KIRIGAMI_BUILD_TYPE_STATIC
#include "libkirigami/platformtheme.h"
#else
#include <platformtheme.h>
#endif

static QString s_selectedStyle;

QUrl KirigamiPlugin::componentUrl(const QString &fileName) const
{
    foreach (const QString &style, m_stylesFallbackChain) {
        const QString candidate = QStringLiteral("styles/") + style + QLatin1Char('/') + fileName;
        if (QFile::exists(resolveFilePath(candidate))) {
            return QUrl(resolveFileUrl(candidate));
        }
    }
    return QUrl(resolveFileUrl(fileName));
}


void KirigamiPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("org.kde.kirigami"));
    const QString style = QString::fromLatin1(qgetenv("QT_QUICK_CONTROLS_STYLE"));

    //org.kde.desktop.plasma is a couple of files that fall back to desktop by purpose
    if ((style.isEmpty() || style == QStringLiteral("org.kde.desktop.plasma")) && QFile::exists(resolveFilePath(QStringLiteral("/styles/org.kde.desktop")))) {
#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
        m_stylesFallbackChain.prepend(QStringLiteral("org.kde.desktop"));
#elif defined(Q_OS_ANDROID)
        m_stylesFallbackChain.prepend(QStringLiteral("Material"));
#else // do we have an iOS specific style?
        m_stylesFallbackChain.prepend(QStringLiteral("Material"));
#endif
    }

    if (!style.isEmpty() && QFile::exists(resolveFilePath(QStringLiteral("/styles/") + style))) {
        m_stylesFallbackChain.prepend(style);
        //if we have plasma deps installed, use them for extra integration
        if (style == QStringLiteral("org.kde.desktop") && QFile::exists(resolveFilePath(QStringLiteral("/styles/org.kde.desktop.plasma")))) {
            m_stylesFallbackChain.prepend("org.kde.desktop.plasma");
        }
    }
    //At this point the fallback chain will be selected->org.kde.desktop->Fallback

    Kirigami::PlatformTheme::setFallbackThemeQmlPath(componentUrl(QStringLiteral("Theme.qml")));

    s_selectedStyle = m_stylesFallbackChain.first();
    qmlRegisterSingletonType<Settings>(uri, 2, 0, "Settings",
         [](QQmlEngine*, QJSEngine*) -> QObject* {
             Settings *settings = new Settings;
             settings->setStyle(s_selectedStyle);
             return settings;
         }
     );

    qmlRegisterUncreatableType<ApplicationHeaderStyle>(uri, 2, 0, "ApplicationHeaderStyle", "Cannot create objects of type ApplicationHeaderStyle");

    qmlRegisterSingletonType(componentUrl(QStringLiteral("Theme.qml")), uri, 2, 0, "Theme");
    //Theme changed from a singleton to an attached property
    qmlRegisterUncreatableType<Kirigami::PlatformTheme>(uri, 2, 2, "Theme", "Cannot create objects of type Theme, use it as an attached poperty");
    qmlRegisterSingletonType(componentUrl(QStringLiteral("Units.qml")), uri, 2, 0, "Units");

    qmlRegisterType(componentUrl(QStringLiteral("Action.qml")), uri, 2, 0, "Action");
    qmlRegisterType(componentUrl(QStringLiteral("AbstractApplicationHeader.qml")), uri, 2, 0, "AbstractApplicationHeader");
    qmlRegisterType(componentUrl(QStringLiteral("AbstractApplicationWindow.qml")), uri, 2, 0, "AbstractApplicationWindow");
    qmlRegisterType(componentUrl(QStringLiteral("AbstractListItem.qml")), uri, 2, 0, "AbstractListItem");
    qmlRegisterType(componentUrl(QStringLiteral("ApplicationHeader.qml")), uri, 2, 0, "ApplicationHeader");
    qmlRegisterType(componentUrl(QStringLiteral("ToolBarApplicationHeader.qml")), uri, 2, 0, "ToolBarApplicationHeader");
    qmlRegisterType(componentUrl(QStringLiteral("ApplicationWindow.qml")), uri, 2, 0, "ApplicationWindow");
    qmlRegisterType(componentUrl(QStringLiteral("BasicListItem.qml")), uri, 2, 0, "BasicListItem");
    qmlRegisterType(componentUrl(QStringLiteral("OverlayDrawer.qml")), uri, 2, 0, "OverlayDrawer");
    qmlRegisterType(componentUrl(QStringLiteral("ContextDrawer.qml")), uri, 2, 0, "ContextDrawer");
    qmlRegisterType(componentUrl(QStringLiteral("GlobalDrawer.qml")), uri, 2, 0, "GlobalDrawer");
    qmlRegisterType(componentUrl(QStringLiteral("Heading.qml")), uri, 2, 0, "Heading");
    qmlRegisterType(componentUrl(QStringLiteral("Separator.qml")), uri, 2, 0, "Separator");
    qmlRegisterType(componentUrl(QStringLiteral("PageRow.qml")), uri, 2, 0, "PageRow");

    //The icon is "special: we have to use a wrapper class to QIcon on org.kde.desktops
#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    //we know that we want a different implementation with Material and Plasma styles
    if (s_selectedStyle == QStringLiteral("Material") || s_selectedStyle == QStringLiteral("Plasma")) {
        qmlRegisterType(componentUrl(QStringLiteral("Icon.qml")), uri, 2, 0, "Icon");
    } else {
        qmlRegisterType<DesktopIcon>(uri, 2, 0, "Icon");
    }
#else
    qmlRegisterType(componentUrl(QStringLiteral("Icon.qml")), uri, 2, 0, "Icon");
#endif

    qmlRegisterType(componentUrl(QStringLiteral("Label.qml")), uri, 2, 0, "Label");
    //TODO: uncomment for 2.3 release
    //qmlRegisterTypeNotAvailable(uri, 2, 3, "Label", "Label type not supported anymore, use QtQuick.Controls.Label 2.0 instead");
    qmlRegisterType(componentUrl(QStringLiteral("OverlaySheet.qml")), uri, 2, 0, "OverlaySheet");
    qmlRegisterType(componentUrl(QStringLiteral("Page.qml")), uri, 2, 0, "Page");
    qmlRegisterType(componentUrl(QStringLiteral("ScrollablePage.qml")), uri, 2, 0, "ScrollablePage");
    qmlRegisterType(componentUrl(QStringLiteral("SplitDrawer.qml")), uri, 2, 0, "SplitDrawer");
    qmlRegisterType(componentUrl(QStringLiteral("SwipeListItem.qml")), uri, 2, 0, "SwipeListItem");

    //2.1
    qmlRegisterType(componentUrl(QStringLiteral("AbstractItemViewHeader.qml")), uri, 2, 1, "AbstractItemViewHeader");
    qmlRegisterType(componentUrl(QStringLiteral("ItemViewHeader.qml")), uri, 2, 1, "ItemViewHeader");
    qmlRegisterType(componentUrl(QStringLiteral("AbstractApplicationItem.qml")), uri, 2, 1, "AbstractApplicationItem");
    qmlRegisterType(componentUrl(QStringLiteral("ApplicationItem.qml")), uri, 2, 1, "ApplicationItem");

    qmlProtectModule(uri, 2);
}

#include "moc_kirigamiplugin.cpp"

