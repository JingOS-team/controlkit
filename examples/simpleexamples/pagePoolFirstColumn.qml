/*
 *   Copyright 2016 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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
