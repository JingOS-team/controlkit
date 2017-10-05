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
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import "private"
import org.kde.kirigami 2.2


/**
 * This Application header represents a toolbar that
 * will display the actions of the current page.
 * Both Contextual actions and the main, left and right actions
 */
ApplicationHeader {
    id: header

    preferredHeight: 38
    maximumHeight: preferredHeight
    headerStyle: ApplicationHeaderStyle.Titles

    //FIXME: needs a property difinition to have its own type in qml
    property string _internal: ""

    pageDelegate: Item {
        id: delegateItem
        readonly property bool current: __appWindow.pageStack.currentIndex == index
        property Row layout

        //don't scroll except just the button
        implicitWidth: parent.parent.width - height
        height: parent.height

        Row {
            id: layout
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Separator {
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height * 0.6
                visible: index > 0
            }
            PrivateActionToolButton {
                anchors.verticalCenter: parent.verticalCenter
                action: page && page.actions ? page.actions.left : null
                showText: false
            }
            PrivateActionToolButton {
                anchors.verticalCenter: parent.verticalCenter
                action: page && page.actions ? page.actions.main : null
                showText: false
            }
            PrivateActionToolButton {
                anchors.verticalCenter: parent.verticalCenter
                action: page && page.actions ? page.actions.right : null
                showText: false
            }
            Separator {
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height * 0.6
                visible: page && page.actions && (page.actions.left || page.actions.main || page.actions.right)
            }

            Row {
                id: contextActionsContainer
                property int hiddenCount
                Repeater {
                    id: repeater
                    model: page && page.actions.contextualActions ? page.actions.contextualActions : null
                    delegate: PrivateActionToolButton {
                        anchors.verticalCenter: parent.verticalCenter
                        action: modelData
                        visible: modelData.visible && x+contextActionsContainer.x+layout.x+width < delegateItem.width
                        Connections {
                            target: modelData
                            onVisibleChanged: {
                                if (modelData.visible) {
                                    ++contextActionsContainer.hiddenCount;
                                } else {
                                    --contextActionsContainer.hiddenCount;
                                }
                            }
                        }
                        Component.onCompleted: {
                            if (!modelData.visible) {
                                ++contextActionsContainer.hiddenCount;
                            }
                        }
                    }
                }
            }
        }

        Heading {
            id: heading
            anchors.verticalCenter: parent.verticalCenter
            visible: layout.width <= 0
            opacity: delegateItem.current ? 1 : 0.4
            color: Theme.textColor
            elide: Text.ElideRight
            text: page ? page.title : ""
            font.pointSize: Math.max(1, (parent.height / 1.6) / Units.devicePixelRatio)
        }
        Controls.ToolButton {
            id: moreButton
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            Icon {
                anchors.fill: parent
                source: "overflow-menu"
                anchors.margins: 4
            }
            checkable: true
            checked: menu.visible
            visible: contextActionsContainer.visibleChildren.length + contextActionsContainer.hiddenCount <= repeater.count
            onClicked: menu.open()

            Controls.Menu {
                id: menu
                y: moreButton.height
                x: -width + moreButton.width

                Repeater {
                    model: page && page.actions.contextualActions ? page.actions.contextualActions : null
                    delegate: BasicListItem {
                        text: modelData ? modelData.text : ""
                        icon: modelData.iconName
                        checkable:  modelData.checkable
                        checked: modelData.checked
                        onClicked: {
                            modelData.trigger();
                            menu.visible = false;
                        }
                        separatorVisible: false
                        backgroundColor: "transparent"
                        visible: index+1 >= contextActionsContainer.visibleChildren.length + contextActionsContainer.hiddenCount && modelData.visible
                        enabled: modelData.enabled
                    }
                }
            }
        }
    }
}
