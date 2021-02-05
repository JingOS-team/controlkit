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
import org.kde.kirigami 2.5
import QtQuick.Controls 2.14 as QQC2
import "private"

QQC2.Button  {
    id: control
    
    property color fontColor: Theme.buttonTextColor
    property int radius : 20
    property alias backgroundColor: background.color

    signal pressed(QtObject mouse)
    signal clicked(QtObject mouse)
    signal released(QtObject mouse)

    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: control.clicked(null)

    contentItem: Text {
        horizontalAlignment: Text.AlignHCenter 
        verticalAlignment: Text.AlignVCenter 
        elide: Text.ElideRight 
        opacity: control.enabled ? 1.0 : 0.5
        color: control.fontColor 
        text: control.text 
        font: control.font 
    } 

    background: PrivateMouseHover{
        id: background
        radius:control.radius
    }
}
