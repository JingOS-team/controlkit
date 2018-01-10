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
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.2

Controls.ToolButton {
    id: control

    implicitWidth: showText ? Math.max(background.implicitWidth, layout.implicitWidth + 16) : height
    implicitHeight: background.implicitHeight

    hoverEnabled: true
    //TODO: replace with upstream action when we can
    property Action kirigamiAction
    property bool showText: true

    //we need our own text delegate
    text: ""
    checkable: kirigamiAction && kirigamiAction.checkable
    checked: kirigamiAction && kirigamiAction.checked
    enabled: kirigamiAction && kirigamiAction.enabled
    opacity: enabled ? 1 : 0.4
    visible: kirigamiAction && kirigamiAction.visible
    onClicked: {
        if (kirigamiAction) {
            kirigamiAction.trigger();
        }
    }

    flat: true
    contentItem: MouseArea {
        hoverEnabled: true
        onPressed: mouse.accepted = false
        Theme.colorSet: checked ? Theme.Selection : Theme.Window
        Theme.inherit: false
        RowLayout {
            id: layout
            anchors.centerIn: parent
            Icon {
                Layout.minimumWidth: 22
                Layout.minimumHeight: 22
                source: control.kirigamiAction ? (control.kirigamiAction.icon ? control.kirigamiAction.icon.name : control.kirigamiAction.iconName) : ""
                visible: control.kirigamiAction && control.kirigamiAction.iconName != ""
                color: control.kirigamiAction && control.kirigamiAction.icon && control.kirigamiAction.icon.color.a > 0 ? control.kirigamiAction.icon.color : Qt.rgba(0, 0, 0, 0)                                                                                     
            }
            Controls.Label {
                text: kirigamiAction ? kirigamiAction.text : ""
                visible: control.showText
            }
        }
    }
    Controls.ToolTip {
        visible: control.hovered
        text: kirigamiAction ? (kirigamiAction.tooltip.length ? kirigamiAction.tooltip : kirigamiAction.text) : ""
        delay: 1000
        timeout: 5000
        y: control.height
    }
}
