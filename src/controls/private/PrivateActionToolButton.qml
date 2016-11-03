/*
 *   Copyright 2016 Marco Martin <mart@kde.org>
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

import QtQuick 2.6
import QtQuick.Layouts 1.2
import QtQuick.Templates 2.0 as T
//QQC1 is needed for StyleItem to fully work
import QtQuick.Controls 1.0 as QQC1
import QtQuick.Controls.Private 1.0
import org.kde.kirigami 1.0

T.ToolButton {
    id: control

    implicitWidth: Math.max(background.implicitWidth, layout.implicitWidth + 16)
    implicitHeight: background.implicitHeight

    hoverEnabled: true
    property Action action
    property bool showText: true

    text: action ? action.text : ""
    checkable: action && action.checkable
    checked: action && action.checked
    enabled: action && action.enabled
    opacity: enabled ? 1 : 0.4
    visible: action && action.visible
    onClicked: {
        if (action) {
            action.trigger();
        }
    }

    flat: true
    contentItem: MouseArea {
        hoverEnabled: true
        onPressed: mouse.accepted = false
        RowLayout {
            id: layout
            anchors.centerIn: parent
            Icon {
                Layout.minimumWidth: 22
                Layout.minimumHeight: 22
                source: control.action ? control.action.iconName : ""
                visible: control.action && control.action.iconName != ""
            }
            Label {
                text: control.text
                visible: control.showText
            }
        }
    }
    background: StyleItem {
        id: styleitem
        elementType: control.flat ? "toolbutton" : "button"
        sunken: control.pressed || (control.checkable && control.checked)
        raised: !(control.pressed || (control.checkable && control.checked))
        hover: control.hovered
        activeControl: control.isDefault ? "default" : "f"
    }
    Timer {
        interval: 1000
        property string tooltip: action.tooltip.length ? action.tooltip : action.text
        running: control.hovered && !control.pressed && tooltip.length
        onTriggered: Tooltip.showText(contentItem, Qt.point(contentItem.mouseX, contentItem.mouseY), tooltip)
    }
}
