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
import "private"

Item  {
    id: control

    property string source: ""
    //define the image disable status url load path
    property string disableSource: ""

    property bool darkMode: applicationWindow().darkMode
    property bool hoverEnabled: true

    signal pressed(QtObject mouse)
    signal clicked(QtObject mouse)
    signal released(QtObject mouse)

    height:  Math.max(icon.height, icon.implicitHeight) + 10
    width: Math.max(icon.width, icon.implicitWidth) + 10

    PrivateMouseHover{
        visible: control.hoverEnabled ? true : false
        darkMode: control.darkMode
    }

    Kirigami.Icon{
        id: icon
        anchors.centerIn: parent
        source: control.enabled ? control.source : (control.disableSource.length > 0 ? control.disableSource: control.source)
    }

     Component.onCompleted:{
        if (control.width == 0 || control.height == 0) {
            control.width = Qt.binding(function() {return Math.max(icon.width, icon.implicitWidth) + 10});
            control.height = Qt.binding(function() {return Math.max(icon.height, icon.implicitHeight)+ 10});
        } else {
            icon.width = Qt.binding(function() {return control.width - 10});
            icon.height = Qt.binding(function() {return control.height - 10});
        }
    }
}
