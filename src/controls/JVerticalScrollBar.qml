/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.5
import QtQuick.Controls 2.14
import org.kde.kirigami 2.15
import jingos.display 1.0
ScrollBar {
    id:scrollControl
    topInset: JDisplay.dp(2)
    bottomInset: JDisplay.dp(2)
    leftInset: JDisplay.dp(2)
    rightInset: JDisplay.dp(4)
    padding:JDisplay.dp(2)
    rightPadding: JDisplay.dp(4)
    implicitWidth: JDisplay.dp(3 + 4 + 2)
    interactive: true
    hoverEnabled: true
    policy: ScrollBar.AsNeeded

    contentItem: Item {
        Rectangle{
            width: parent.width + JDisplay.dp(6)
            height: parent.height + JDisplay.dp(6)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: -  JDisplay.dp(2)
            color: scrollControl.hovered ? scrollControl.pressed ? JTheme.pressBackground : JTheme.hoverBackground : "transparent"
            radius: width / 2
        }

        Rectangle{
            anchors.fill: parent
            radius: width / 2
            color: {
                var c = JTheme.componentBackground
                return Qt.rgba(c.r, c.g, c.b, 0.5)
            }
        }
    }
    background: Rectangle{
        radius: width / 2
        color: {
            var c = JTheme.componentBackground
            return Qt.rgba(c.r, c.g, c.b, 0.3)
        }
    }
}
