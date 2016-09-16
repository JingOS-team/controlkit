/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
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
import QtQuick.Controls 2.0 as QQC2
import QtGraphicalEffects 1.0
import org.kde.kirigami 1.0

//TODO: This will become a QQC2 Drawer
//providing just a dummy api for now
QQC2.Drawer {
    id: root

    height: edge == Qt.LeftEdge || edge == Qt.RightEdge ? applicationWindow().height : contentItem.implicitHeight
    width:  edge == Qt.TopEdge || edge == Qt.BottomEdge ? applicationWindow().width : contentItem.implicitwidth
    parent: applicationWindow().contentItem

    dragMargin: enabled && (edge == Qt.LeftEdge || edge == Qt.RightEdge) ? Qt.styleHints.startDragDistance : 0

    //default property alias page: mainPage.data
    property alias opened: root.visible
    edge: Qt.LeftEdge
    modal: true
    property bool enabled: true

    signal clicked
}

