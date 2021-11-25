/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.2
import org.kde.kirigami 2.15

Rectangle{
    id: background

    property real moveX: 0
    property real moveY: 0
    property bool darkMode: false
    property bool containsMouse: area.containsMouse
    property color hoverColor: JTheme.hoverBackground
    property color pressColor: JTheme.pressBackground
    anchors.fill: parent

    radius: ConstValue.radius
    color: "transparent"

    Rectangle {
        id: back_item
        color:  area.pressed? background.pressColor : background.hoverColor
        radius: parent.radius

        state: "hiden"
        states: [
            State {
                name: "shown"
                PropertyChanges {
                    target: back_item

                    x: 0
                    y: 0
                    width: background.width
                    height: background.height

                    visible:true
                }
            },
            State {
                name: "hiden"
                PropertyChanges {

                    target: back_item

                    x: background.moveX
                    y: background.moveY
                    width:  0
                    height: 0

                    visible:false
                }

            }
        ]

        transitions:[
            Transition {
                from:"hiden"; to:"shown"
                SequentialAnimation{
                    PropertyAnimation { target: back_item; properties: "visible"; duration: 0; easing.type: Easing.OutQuart }

                    PropertyAnimation { target: back_item; properties: "x,y,width,height"; duration: 400; easing.type: Easing.OutQuart }
                }

                //PropertyAnimation { target: background.parent; properties: "scale"; duration: 400; easing.type: Easing.OutQuart }
            },
            Transition {
                from:"shown"; to:"hiden"
                SequentialAnimation{
                    PropertyAnimation { target: back_item; properties: "x,y,width,height,"; duration: 200; easing.type: Easing.OutQuart }

                    PropertyAnimation { target: back_item; properties: "visible"; duration: 0; easing.type: Easing.OutQuart }
                }

                //PropertyAnimation { target: background.parent; properties: "scale"; duration: 200; easing.type: Easing.OutQuart }
            }
        ]
    }

    MouseArea {
        id:area

        anchors.fill:parent
        hoverEnabled: true

        onContainsMouseChanged: {
            if (containsMouse) {
                cursorShape = Qt.BlankCursor

                back_item.x = area.mouseX
                back_item.y = area.mouseY
                back_item.state = "shown"
            } else {
                cursorShape = Qt.ArrowCursor

                background.moveX = area.mouseX
                background.moveY = area.mouseY

                back_item.state = "hiden"
            }
        }

        onClicked: {
            background.parent.clicked(mouse)
        }

        onPressed: {
            //press_item.visible = true
            //back_item.visible = false

            background.parent.pressed(mouse)
        }

        onReleased: {
            //press_item.visible = false
            //back_item.visible = true

            background.parent.released(mouse)
        }
    }
}
