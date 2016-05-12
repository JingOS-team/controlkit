/*
 *   Copyright 2016 Marco Martin <mart@kde.org>
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
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1
import QtQuick.Controls.Private 1.0
import org.kde.kirigami 1.0

MouseArea {
    anchors {
        left: parent.left
        top: parent.top
        bottom: parent.bottom
    }
    opacity: !Settings.isMobile &&__appWindow.pageStack.currentIndex < 1 ? 0.4 : 1
    width: height
    z: 99
    onClicked: applicationWindow().pageStack.goBack();
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: width/2
        antialiasing: true
        width: parent.width/2
        height: Math.ceil(Units.smallSpacing / 3)
        rotation: 45
        transformOrigin: Item.Left
        color: Theme.highlightedTextColor
    }
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: width/2
        antialiasing: true
        width: parent.width/2
        height: Math.ceil(Units.smallSpacing / 3)
        rotation: -45
        transformOrigin: Item.Left
        color: Theme.highlightedTextColor
    }
}
