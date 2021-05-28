/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
 *            2021 Wang Rui <wangrui@jingos.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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

import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import org.kde.kirigami 2.15
JResizeHandle {
    width: 30
    height: width

    property int rhHeight:width/10

    anchors.top: resizeCorner === JResizeHandle.TopLeft || resizeCorner === JResizeHandle.TopRight ? parent.top : undefined
    anchors.topMargin: -rhHeight

    anchors.left: resizeCorner === JResizeHandle.TopLeft || resizeCorner === JResizeHandle.BottomLeft ? parent.left : undefined
    anchors.leftMargin: -rhHeight

    anchors.bottom: resizeCorner === JResizeHandle.BottomLeft || resizeCorner === JResizeHandle.BottomRight ? parent.bottom : undefined
    anchors.bottomMargin: -rhHeight

    anchors.right: resizeCorner === JResizeHandle.TopRight || resizeCorner === JResizeHandle.BottomRight ? parent.right : undefined
    anchors.rightMargin: -rhHeight


    Rectangle{
        id:topOrBottomRect
        anchors.top: resizeCorner === JResizeHandle.TopLeft || resizeCorner === JResizeHandle.TopRight ? parent.top : undefined
        anchors.bottom: resizeCorner === JResizeHandle.BottomLeft || resizeCorner === JResizeHandle.BottomRight ? parent.bottom : undefined
        width:parent.width
        height:rhHeight
    }

    Rectangle {
        id:leftOrRightRect
        anchors.left: resizeCorner === JResizeHandle.TopLeft || resizeCorner === JResizeHandle.BottomLeft ? parent.left : undefined
        anchors.right: resizeCorner === JResizeHandle.TopRight || resizeCorner === JResizeHandle.BottomRight ? parent.right : undefined
        width:rhHeight
        height:parent.width
    }
}
