/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
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

import QtQuick 2.5
import QtQuick.Controls 1.3 as Controls
import QtQuick.Layouts 1.2
import QtQuick.Controls.Private 1.0
import "private"
import org.kde.kirigami 1.0


/**
 * 
 */
ApplicationHeader {
    id: header

    preferredHeight: spacer.height
    maximumHeight: preferredHeight

    Controls.ToolButton {
        id: spacer
        iconName: "go-previous"
        visible: false
    }

    //FIXME: needs a property difinition to have its own type in qml
    property string _internal: ""

    pageDelegate: Item {
        id: delegateItem
        readonly property Page page: applicationWindow().pageStack.get(modelData)

        width: {
            //more columns shown?
            if (__appWindow.wideScreen) {
                if (modelData == 0 && ListView.view.x > 0) {
                    return page.width - Math.max(0, ListView.view.x - __appWindow.contentItem.x);
                } else {
                    return page.width;
                }
            } else {
                return Math.min(titleList.width, delegateRoot.implicitWidth + Units.smallSpacing);
            }
        }
        height: ListView.view.height

        Row {
            id: layout
            anchors {
                left: parent.left
                right: parent.right
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.textColor
                opacity: 0.3
                width: Units.devicePixelRatio
                height: parent.height * 0.6
            }
            Controls.ToolButton {
                anchors.verticalCenter: parent.verticalCenter
                iconName: page.actions.main.iconName
                text: page.actions.main.text
                tooltip: page.actions.main.text
                checkable: page.actions.main.checkable
                checked: page.actions.main.checked
                enabled: page.actions.main.enabled
                opacity: enabled ? 1 : 0.4
                visible: page.actions.main && page.actions.main.visible
                onClicked: page.actions.main.trigger();
            }
            Controls.ToolButton {
                anchors.verticalCenter: parent.verticalCenter
                iconName: page.actions.left.iconName
                text: page.actions.left.text
                tooltip: page.actions.left.text
                checkable: page.actions.left.checkable
                checked: page.actions.left.checked
                enabled: page.actions.left.enabled
                opacity: enabled ? 1 : 0.4
                visible: page.actions.left && page.actions.left.visible
                onClicked: page.actions.left.trigger();
            }
            Controls.ToolButton {
                anchors.verticalCenter: parent.verticalCenter
                iconName: page.actions.right.iconName
                text: page.actions.right.text
                tooltip: page.actions.right.text
                checkable: page.actions.right.checkable
                checked: page.actions.right.checked
                enabled: page.actions.right.enabled
                opacity: enabled ? 1 : 0.4
                visible: page.actions.right && page.actions.right.visible
                onClicked: page.actions.right.trigger();
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.textColor
                opacity: 0.3
                width: Units.devicePixelRatio
                height: parent.height * 0.6
            }
            Repeater {
                id: repeater
                model: page.actions.contextualActions
                delegate: Controls.ToolButton {
                    anchors.verticalCenter: parent.verticalCenter
                    iconName: modelData.iconName
                    text: modelData.text
                    tooltip: modelData.text
                    checkable: modelData.checkable
                    checked: modelData.checked
                    enabled: modelData.enabled
                    opacity: enabled ? 1 : 0.4
                    visible: modelData.visible && x+width*2 < delegateItem.width
                    onClicked: modelData.trigger();
                }
            }
        }
        Controls.ToolButton {
            id: moreButton
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            //TODO: we need a kebab icon
            iconName: "application-menu"
            visible: menu.visibleChildren > 0
            onClicked: page.actions.main

            menu: Controls.Menu {
                id: menu

                property int visibleChildren: 0
                Instantiator {
                    model: page.actions.contextualActions
                    Controls.MenuItem {
                        text: modelData.text
                        iconName: modelData.iconName
                        shortcut: modelData.shortcut
                        onTriggered: modelData.trigger();
                        visible: !layout.children[index+3].visible && modelData.visible
                        enabled: modelData.enabled
                        onVisibleChanged: {
                            if (visible) {
                                menu.visibleChildren++;
                            } else {
                                menu.visibleChildren = Math.max(0, menu.visibleChildren-1);
                            }
                        }
                    }
                    onObjectAdded: {
                        menu.insertItem(index, object);
                        if (object.visible) {
                            menu.visibleChildren++;
                        }
                    }
                    onObjectRemoved: {
                        menu.removeItem(object);
                        if (object.visible) {
                            menu.visibleChildren = Math.max(0, menu.visibleChildren-1);
                        }
                    }
                }
            }
        }
    }
}
