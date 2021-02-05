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

QQC2.Slider {
    id: control

    value: 0.5
    property var backgroundColor: "#809F9FAA"
    property var controlColor: "#FF3C4BE8"
    property var shadowColor: Qt.rgba(0, 0, 0, 0.1)
    property var handleBtnPressColor: "#EF9F9FAA"
    property var handleBtnColor: "#FFFFFFFF"

    background:Rectangle{
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: units.gridUnit * 11
        implicitHeight: units.gridUnit * 0.29
        width: control.availableWidth
        height: implicitHeight
        radius: 2
        color: backgroundColor

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: controlColor
            radius: 2
        }
    }

//    handle: Rectangle {
//        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
//        y: control.topPadding + control.availableHeight / 2 -height / 2
//        implicitHeight: units.gridUnit * 1.42
//        implicitWidth: units.gridUnit * 1.64
//        color: control.pressed ? "#EF9F9FAA" : "#FFFFFFFF"
//        radius: 11
//        border.color: "#1A000000"
//        border.width: 1
//    }
    handle: Item{
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitHeight: units.gridUnit * 1.42
        implicitWidth: units.gridUnit * 1.64
        Rectangle {
            id:handleRect
            anchors.fill: parent
            radius: 6
            color: control.pressed ? handleBtnPressColor : handleBtnColor
        }
        DropShadow {
            anchors.fill: handleRect
            horizontalOffset: 0
            verticalOffset: 4
            radius: 12.0
            samples: 16
            cached: true
            spread:0.3
            color: shadowColor
            source: handleRect
            visible: true
        }
    }
}



