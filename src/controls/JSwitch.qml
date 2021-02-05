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

QQC2.Switch {
    id: control

    implicitWidth: Math.max(background ? background.implicitWidth : 0, 
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: units.gridUnit * 1.6

    indicator: Rectangle {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        implicitHeight: units.gridUnit * 1.6
        implicitWidth: units.gridUnit * 2.8
        radius: units.gridUnit / 2
        color: control.checked ? "#3C4BE8" : "#E5E5EA"
        Rectangle{
            x: control.checked ? parent.width - width -2 : 2
            anchors.verticalCenter: parent.verticalCenter
            width: control.checked ?  units.gridUnit * 1.4 : units.gridUnit * 0.85
            height: units.gridUnit * 1.4
            color: "#FFFFFF"
            radius: units.gridUnit / 2
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
}



