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