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

QQC2.Switch {
    id: control
    implicitHeight: JDisplay.dp(26)
    implicitWidth: JDisplay.dp(46)
    indicator: Rectangle {
        anchors.fill: parent
        radius: Math.min(JDisplay.dp(10), control.height / 2)
        color: control.checked ? JTheme.highlightColor : JTheme.iconDisableForeground
        Rectangle{
            x: control.checked ? parent.width - width - JDisplay.dp(2) : JDisplay.dp(2)
            anchors.verticalCenter: parent.verticalCenter
            width: control.checked ?  height : height * 0.7
            height: control.height - JDisplay.dp(4)
            color: JTheme.colorScheme === "jingosLight" ? "#FFFFFFFF" : "#FFF7F7F7"
            radius: Math.min(JDisplay.dp(6), width / 2)
            Behavior on x {
                XAnimator{
                    duration: units.longDuration
                    easing.type: Easing.OutBounce
                }
            }
            Behavior on width {
                NumberAnimation{
                    duration: units.shortDuration / 2
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    Keys.onReleased: {
        if (event.key === Qt.Key_Space) {
            event.accepted = true;
        }
    }
}



