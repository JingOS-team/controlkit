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
QQC2.Slider {
    id: control

    property var backgroundColor: JTheme.componentBackground
    property var controlColor: JTheme.highlightColor
    property var shadowColor: Qt.rgba(0, 0, 0, 0.1)
    property var handleBtnColor: JTheme.colorScheme === "jingosLight" ? "#FFFFFFFF" : "#FFF7F7F7"
    property color handleBtnBorderColor: "#FFF6F6F6"
    property int handleBtnBorderWidth: 1

    property var stepStrs: []
    property Item separetorItem: null
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: stepStrs.length !== 0 ? JDisplay.dp(16) : 0
    height: bottomPadding + JDisplay.dp(24)
    value: stepStrs.length === 0 ? 0.5 : 0
    stepSize: stepStrs.length === 0 ? 0 : 1.0
    from: 0
    to:stepStrs.length === 0 ? 1.0 : (stepStrs.length - 1)

    background:Rectangle{
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: JDisplay.dp(176)
        implicitHeight: JDisplay.dp(4)
        width: control.availableWidth
        height: implicitHeight
        radius: JDisplay.dp(2)
        color: backgroundColor

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: controlColor
            radius: JDisplay.dp(2)
        }

        Loader{
            anchors.fill: parent
            active:stepStrs.length !== 0
            sourceComponent: Component{
                Row{
                    spacing:(control.availableWidth - stepStrs.length * JDisplay.dp(4)) / (stepStrs.length - 1)
                    Repeater{
                        model:stepStrs.length
                        delegate: separetorItem === null ? stepDelCom : separetorItem

                    }
                }
            }
        }

    }
    handle: Item{
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitHeight: JDisplay.dp(24)
        implicitWidth: implicitHeight
        Rectangle {
            id:handleRect
            anchors.fill: parent
            radius: JDisplay.dp(6)
            border.color: control.handleBtnBorderColor
            border.width: control.handleBtnBorderWidth
            color: control.handleBtnColor
        }
        DropShadow {
            anchors.fill: handleRect
            horizontalOffset: 0
            verticalOffset: JDisplay.dp(4)
            radius: 12.0
            samples: 16
            cached: true
            spread:0.3
            color: shadowColor
            source: handleRect
            visible: true
        }
    }

    Component{
        id:stepDelCom
        Item {
            width: rect1.width
            height: rect1.height + JDisplay.dp(12) + stepText.height
            Rectangle{
                id:rect1
                width: JDisplay.dp(4)
                height: width
                radius: width / 2
                color: "#FFFFFFFF"
            }
            Text {
                id:stepText
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                color: JTheme.minorForeground
                font.pointSize: JDisplay.sp(6)
                text: stepStrs[index]
            }
        }
    }
}



