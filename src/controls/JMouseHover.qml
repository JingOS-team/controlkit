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
import "private"
Item{
    id: root


    
    property alias radius: mouseHover.radius
    property alias color: mouseHover.color
    property alias darkMode: mouseHover.darkMode

    property int padding: 10

    signal pressed(QtObject mouse)
    signal clicked(QtObject mouse)
    signal released(QtObject mouse)
    
    anchors.centerIn: parent

    PrivateMouseHover{
        id: mouseHover    
    }

    Component.onCompleted:{
        if (root.parent != null) {
            root.width = Qt.binding(function() {return Math.max(root.parent.width, root.parent.implicitWidth) + root.padding});
            root.height = Qt.binding(function() {return Math.max(root.parent.height, root.parent.implicitHeight) + root.padding});
        }
    }
}