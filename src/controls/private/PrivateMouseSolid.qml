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

    property QtObject resizeObject: null

    signal pressed(QtObject mouse)
    signal clicked(QtObject mouse)
    signal released(QtObject mouse)

    anchors.centerIn: parent
    width: parent.width + 10
    height: parent.height + 10

    radius: parent.width / 2
    color: "transparent"

    state: "hiden"
    states: [
        State {
            name: "shown"
            PropertyChanges {
                target: back_item
                visible: true
            }

            PropertyChanges {
                target: resizeObject
                scale: 1.1
            }
        },
        State {
            name: "hiden"
            PropertyChanges {
                target: back_item
                visible: false
            }

            PropertyChanges {
                target: resizeObject
                scale: 1
            }
        }
    ]   

    Rectangle {
        id: press_item
        anchors.fill: parent
        color:ConstValue.pressColor
        visible: false
        radius: parent.radius
        opacity: 0.16
        z: 999
    }

    Rectangle {
        id: back_item
        anchors.fill: parent
        radius: parent.radius
        color: ConstValue.hoverColor
        opacity: 0.12
    }

    transitions:[
        Transition {
            from:"hiden"; to:"shown"

            PropertyAnimation { target: back_item; properties: "visible"; duration: 30; easing.type: Easing.OutQuart }
            PropertyAnimation { target: resizeObject; properties: "scale"; duration: 400; easing.type: Easing.OutQuart }
        },

        Transition {
            from:"shown"; to:"hiden"

            PropertyAnimation { target: back_item; properties: "visible"; duration: 30; easing.type: Easing.OutQuart }
            PropertyAnimation { target: resizeObject; properties: "scale"; duration: 400; easing.type: Easing.OutQuart }
        }
    ]

    MouseArea {
        id:area

        anchors.centerIn: parent
        width: parent.width - ConstValue.mouseWidth/2 
        height: parent.height - ConstValue.mouseHight/2
        hoverEnabled: true

        onEntered: {
            cursorShape = Qt.BlankCursor
            background.state = "shown"
        }

        onExited: {
            cursorShape = Qt.ArrowCursor
            background.state = "hiden"
        }

        onClicked: {
            background.parent.clicked(mouse)
        }

        onPressed: {
            press_item.visible = true
            back_item.visible = false
            background.parent.pressed(mouse)
        }

        onReleased: {
            press_item.visible = false
            back_item.visible = true
            background.parent.released(mouse)
        }
    }
}
