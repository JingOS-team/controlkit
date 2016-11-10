/*
 *   Copyright 2016 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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
 *   51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.7
import org.kde.kirigami 2.0
import "../../private"
import "../../templates" as T

T.AbstractListItem {
    id: listItem

    onPressedChanged: {
        if (pressed) {
            clickAnim.running = true
        }
    }
    background: DefaultListItemBackground {
        clip: true
        //TODO: this will have to reuse QQC2.1 Ripple
        Rectangle {
            id: ripple
            anchors.centerIn: parent
            width: parent.width
            height: parent.width
            radius: width
            color: Qt.rgba(1,1,1,0.3)
            scale: 0
            opacity: 1
            ParallelAnimation {
                id: clickAnim
                ScaleAnimator {
                    target: ripple
                    from: 0
                    to: 1
                    duration: Units.longDuration
                }
                OpacityAnimator {
                    target: ripple
                    from: 0
                    to: 1
                    duration: Units.longDuration
                }
            }
        }
    }
    implicitHeight: contentItem.implicitHeight + Units.smallSpacing * 6
}
