/*
 *   Copyright 2018 Aleix Pol Gonzalez <aleixpol@kde.org>
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

import QtQuick 2.3
import QtQuick.Controls 2.0 as Controls

Controls.Menu
{
    id: theMenu
    property alias actions: actionsRepeater.model
    property Component submenuComponent

    Repeater {
        id: actionsRepeater

        delegate: Controls.MenuItem {
            id: menuItem
            text: model.text
//             TODO: enable when we depend on Qt 5.10
//             icon.name: model.iconName
            visible: model.visible
            enabled: modelData.enabled
            checkable: modelData.checkable
            checked: modelData.checked
            onTriggered: {
                modelData.trigger()
            }

            readonly property var ourMenu: theMenu.submenuComponent ? theMenu.submenuComponent.createObject(menuItem, { actions: modelData.children }) : null
        }
    }
}
