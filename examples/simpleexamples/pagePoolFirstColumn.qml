/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.11
import org.kde.kirigami 2.11 as Kirigami

Kirigami.ApplicationWindow {
    id: root

    Kirigami.PagePool {
        id: mainPagePool
    }

    globalDrawer: Kirigami.GlobalDrawer {
        title: "Hello App"
        titleIcon: "applications-graphics"
    }
    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    pageStack.initialPage: wideScreen ? [firstPage, mainPagePool.loadPage("SimplePage.qml")] : [firstPage]

    Component {
        id: firstPage
        Kirigami.ScrollablePage {
            id: root
            title: i18n("Sidebar")
            property list<Kirigami.PagePoolAction> pageActions: [
                Kirigami.PagePoolAction {
                    text: i18n("Page1")
                    icon.name: "speedometer"
                    pagePool: mainPagePool
                    basePage: root
                    page: "SimplePage.qml"
                },
                Kirigami.PagePoolAction {
                    text: i18n("Page2")
                    icon.name: "window-duplicate"
                    pagePool: mainPagePool
                    basePage: root
                    page: "MultipleColumnsGallery.qml"
                }
            ]
            ListView {
                model: pageActions
                keyNavigationEnabled: true
                activeFocusOnTab: true
                delegate: Kirigami.BasicListItem {
                    id: delegate
                    action: modelData
                }
            }
        }
    }
}
