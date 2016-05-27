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

import QtQuick 2.1
import QtQuick.Controls 1.3 as Controls
import org.kde.kirigami 1.0

Rectangle {
    id: root

    height: childrenRect.height
    property Item page: parent
    color: Theme.backgroundColor

    anchors {
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        color: Theme.textColor
        opacity: 0.3
        height: Math.ceil(Units.smallSpacing / 5)
    }
    Row {
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: height
        }
        Controls.ToolButton {
            anchors.verticalCenter: parent.verticalCenter
            iconName: page.actions.left.iconName
            text: page.actions.left.text
            tooltip: page.actions.left.text
            checkable: page.actions.left.checkable
            checked: page.actions.left.checked
            enabled: page.actions.left.enabled
            visible: page.actions.left && page.actions.left.visible
            onClicked: page.actions.left.trigger();
        }
        Controls.ToolButton {
            anchors.verticalCenter: parent.verticalCenter
            iconName: page.actions.main.iconName
            text: page.actions.main.text
            tooltip: page.actions.main.text
            checkable: page.actions.main.checkable
            checked: page.actions.main.checked
            enabled: page.actions.main.enabled
            visible: page.actions.main && page.actions.main.visible
            onClicked: page.actions.main.trigger();
        }
        Controls.ToolButton {
            anchors.verticalCenter: parent.verticalCenter
            iconName: page.actions.right.iconName
            text: page.actions.right.text
            tooltip: page.actions.right.text
            checkable: page.actions.right.checkable
            checked: page.actions.right.checked
            enabled: page.actions.right.enabled
            visible: page.actions.right && page.actions.right.visible
            onClicked: page.actions.right.trigger();
        }
        Repeater {
            model: page.actions.contextualActions
            delegate: Controls.ToolButton {
                anchors.verticalCenter: parent.verticalCenter
                iconName: modelData.iconName
                text: modelData.text
                tooltip: modelData.text
                checkable: modelData.checkable
                checked: modelData.checked
                enabled: modelData.enabled
                visible: modelData.visible
                onClicked: modelData.trigger();
            }
        }
    }
}
