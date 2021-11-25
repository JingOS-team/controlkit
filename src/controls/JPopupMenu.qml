/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.2
import QtQuick.Controls 2.14 as QQC2
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.15
import jingos.display 1.0
import "private"

//ConstValue.jingUnit   18
QQC2.Menu {
    id: menu

    implicitWidth :JDisplay.dp(198)
    property alias blurBackground: blurBk

    property color backgroundColor: JTheme.floatBackground
    property color textColor: JTheme.majorForeground
    property color iconColor: JTheme.majorForeground
    property color hoverColor: JTheme.hoverBackground
    property color pressColor: JTheme.pressBackground

    property real textPointSize: JDisplay.sp(13)
    property real iconWidth: JDisplay.dp(16)
    property real iconHeight: JDisplay.dp(16)

    property Item windowContentItem: null

    topPadding: blurBackground.arrowPos === JRoundRectangle.ARROW_TOP ? blurBackground.arrowHeight : 0
    bottomPadding: blurBackground.arrowPos === JRoundRectangle.ARROW_BOTTOM ? blurBackground.arrowHeight : 0

    onWindowChanged: {
        if(window){
            menu.windowContentItem = window.contentItem;
        } else {
            menu.windowContentItem = null;
        }
    }

    delegate: QQC2.MenuItem{
        id: itemDelegate

        width: parent.width
        height: JDisplay.dp(40)
        leftPadding: JDisplay.dp(20)
        rightPadding: JDisplay.dp(20)

        state: "hidden"

        contentItem: Item{
            id: menuItemContentItem
            Text{
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                color: itemDelegate.enabled ? menu.textColor : JTheme.disableForeground
                font.pixelSize: menu.textPointSize
                text: itemDelegate.text
            }

            Icon{
                width: menu.iconWidth
                height: menu.iconHeight
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                color: itemDelegate.enabled ? menu.iconColor : JTheme.iconDisableForeground
                visible: source !== ""
                source: itemDelegate.icon.source
            }
        }

        background: Item{
            id: menuItemBackground

            property alias color : bgColor.color

            anchors.fill: parent
            visible: false
            clip: true

            JRoundRectangle{
                id: bgColor

                anchors.fill: parent

                radiusPos: {
                    if(menu.count === 1) {
                        return JRoundRectangle.TOPLEFT | JRoundRectangle.TOPRIGHT | JRoundRectangle.BOTTOMRIGHT | JRoundRectangle.BOTTOMLEFT
                    } else if(menu.currentIndex === 0){
                        return JRoundRectangle.TOPLEFT | JRoundRectangle.TOPRIGHT
                    } else if(menu.currentIndex === menu.count -1){
                        return JRoundRectangle.BOTTOMRIGHT | JRoundRectangle.BOTTOMLEFT
                    } else {
                        return JRoundRectangle.UNKOWN
                    }
                }
                radius: JDisplay.dp(10)
            }
        }


        onHoveredChanged: {
            if(hovered){
                itemDelegate.state = "hovered";
            } else {
                itemDelegate.state = "hidden"
            }
        }

        onPressed: {
            itemDelegate.state = "pressed"
        }

        onReleased: {
            itemDelegate.state = "hovered"
        }

        states: [
            State {
                name: "hovered"
                PropertyChanges {
                    target: menuItemBackground
                    visible: true
                    color: menu.hoverColor
                    
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
                    color: menu.pressColor
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

    background: JBlurBackground{
        id:blurBk
        backgroundColor: menu.backgroundColor
        sourceItem:windowContentItem
    }
}



