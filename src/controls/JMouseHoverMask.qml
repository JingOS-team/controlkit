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
    id: mouseHoverMask

    property color hoverColor: "#329F9FAA"
    property color clickColor: "#4D9F9FAA"
    property alias acceptedButtons: mouseArea.acceptedButtons

    signal pressed(QtObject mouse)
    signal clicked(QtObject mouse)
    signal released(QtObject mouse)
    signal pressAndHold(QtObject mouse)

    radius: Units.smallSpacing
    color: "transparent"
    z: 999

    state: "hidden"

    states: [
        State {
            name: "hovered"
            PropertyChanges {
                target: mouseHoverMask
                color: mouseHoverMask.hoverColor
                
            }
        },
        State {
            name: "hidden"
            PropertyChanges {
                target: mouseHoverMask
                color: "transparent"
            }
        },
        State {
            name: "pressed"
            PropertyChanges {
                target: mouseHoverMask
                color: mouseHoverMask.clickColor
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "hidden"
            PropertyAnimation {
                target: mouseHoverMask
                properties: "color"
                duration: Units.duration
                easing.type: Easing.OutQuad
            }
            
        },
        Transition {
            from: "*"
            to: "hovered"
            PropertyAnimation {
                target: mouseHoverMask
                properties: "color"
                duration: Units.duration
                easing.type: Easing.OutQuad
            }
        },
        Transition {
            from: "*"
            to: "pressed"
            PropertyAnimation {
                target: mouseHoverMask
                properties: "color"
                duration: Units.duration
                easing.type: Easing.OutQuad
            }
        }
    ]

    MouseArea{
        id: mouseArea
        anchors.fill:parent
        hoverEnabled: true

        onEntered: {
            mouseHoverMask.state = "hovered"
        }

        onExited: {
            mouseHoverMask.state = "hidden"
        }

        onCanceled: {
            mouseHoverMask.state = "hidden"
        }

        onClicked: mouseHoverMask.clicked(mouse)

        onPressed: {
            mouseHoverMask.state = "pressed"
            mouseHoverMask.pressed(mouse)
        }

        onPressAndHold:{
            mouseHoverMask.pressAndHold(mouse)
        }

        onReleased: {
            mouseHoverMask.state = "hovered"
            mouseHoverMask.released(mouse)
        }
    }
}
