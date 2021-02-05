/*
 * Copyright 2021 Rui Wang <wangrui@jingos.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import org.kde.kirigami 2.0
import QtQuick.Controls 2.14 as QQC2
import org.kde.kirigami 2.0 as Kirigami
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.15
import "private"

QQC2.Menu {
    id: menu

    width: ConstValue.jingUnit * 22

    background: JBlurBackground{
        anchors.fill: parent

        startX: menu.x
        startY: menu.y

        sourceItem:menu.parent
        blurRadius: 144
        radius:ConstValue.jingUnit
        backgroundColor:"#EDFFFFFF"
    }

    delegate: QQC2.MenuItem {
        id: itemDelegate

        width: parent.width
        height: ConstValue.jingUnit*5
        leftPadding: ConstValue.jingUnit*2.2
        rightPadding: ConstValue.jingUnit*2.2

        state: "hidden"

        contentItem: Item{
            id: menuItemContentItem

            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: parent.height

            Text{
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                color:"#000000"
                font.pointSize: 22
                text: itemDelegate.text
            }

            Icon{
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: itemDelegate.icon.source
            }
        }

        background: Item{
            id: menuItemBackground

            property alias color : bgColor.color

            anchors.fill: parent
            visible: false
            clip: true

            Rectangle{
                id: bgColor

                width: parent.width
                height: (menu.currentIndex == 0 || menu.currentIndex == menu.count -1) ? parent.height +  ConstValue.jingUnit : parent.height

                radius: (menu.currentIndex == 0 || menu.currentIndex == menu.count -1) ? ConstValue.jingUnit : 0

                Connections{
                    target: menu
                    onCurrentIndexChanged:{
                        if (menu.currentIndex == 0) {
                            bgColor.anchors.top = menuItemBackground.top
                            bgColor.anchors.bottom = undefined
                            bgColor.anchors.fill = undefined
                        } else if (menu.currentIndex == menu.count -1 ) {
                            bgColor.anchors.top = undefined
                            bgColor.anchors.fill = undefined
                            bgColor.anchors.bottom = menuItemBackground.bottom
                        } else {
                            bgColor.anchors.top = undefined
                            bgColor.anchors.bottom = undefined
                            bgColor.anchors.fill= menuItemBackground
                        }
                    }
                }
            }
        }

        MouseArea{
            anchors.fill:parent

            hoverEnabled: true
            
            onEntered: {
                cursorShape = Qt.BlankCursor
                itemDelegate.state = "hovered"
            }

            onExited: {
                cursorShape = Qt.ArrowCursor
                itemDelegate.state = "hidden"
            }

            onClicked:{
                itemDelegate.triggered()
            }
            
            onPressed: {
                itemDelegate.state = "pressed"
            }

            onReleased: {
                itemDelegate.state = "hovered"
            }
        }

        states: [
            State {
                name: "hovered"
                PropertyChanges {
                    target: menuItemBackground
                    visible: true
                    color: "#1F767680"
                    
                }
            },
            State {
                name: "hidden"
                PropertyChanges {
                    target: menuItemBackground
                    visible: false
                    color: "transparent"
                }
            },
            State {
                name: "pressed"
                PropertyChanges {
                    target: menuItemBackground
                    visible: true
                    color: "#29787880"
                }
            }
        ]

        transitions: [
            Transition {
                from: "*"
                to: "hidden"
                PropertyAnimation {
                    target: menuItemBackground
                    properties: "visible"
                    duration: Units.shortDuration
                    easing.type: Easing.OutQuad
                }
                
            },
            Transition {
                from: "*"
                to: "hovered"
                PropertyAnimation {
                    target: menuItemBackground
                    properties: "visible"
                    duration: Units.shortDuration
                    easing.type: Easing.OutQuad
                }
            },
            Transition {
                from: "*"
                to: "pressed"
                PropertyAnimation {
                    target: menuItemBackground
                    properties: "visible"
                    duration: Units.shortDuration
                    easing.type: Easing.OutQuad
                }
            }
        ]
    }
}



