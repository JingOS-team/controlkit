/*
 *  Copyright 2019 Marco Martin <mart@kde.org>
 *  Copyright 2021 Rui Wang <wangrui@jingos.com>
 *  Copyright 2021 Lele Huan <huanlele@jingos.com>
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
import org.kde.kirigami 2.15
import jingos.display 1.0
JResizeHandle {
    width: JDisplay.dp(30)
    height: width

    property int rhHeight:width/10

    anchors.top: resizeCorner === JResizeHandle.TopLeft || resizeCorner === JResizeHandle.TopRight ? parent.top : undefined
    //anchors.topMargin: -rhHeight

    anchors.left: resizeCorner === JResizeHandle.TopLeft || resizeCorner === JResizeHandle.BottomLeft ? parent.left : undefined
    //anchors.leftMargin: -rhHeight

    anchors.bottom: resizeCorner === JResizeHandle.BottomLeft || resizeCorner === JResizeHandle.BottomRight ? parent.bottom : undefined
    //anchors.bottomMargin: -rhHeight

    anchors.right: resizeCorner === JResizeHandle.TopRight || resizeCorner === JResizeHandle.BottomRight ? parent.right : undefined
    //anchors.rightMargin: -rhHeight

    Rectangle{
        id:topOrBottomRect
        x: resizeCorner === JResizeHandle.TopLeft ||  resizeCorner === JResizeHandle.BottomLeft ? -rhHeight : 0
        y: resizeCorner === JResizeHandle.TopLeft ||  resizeCorner === JResizeHandle.TopRight ? -rhHeight : parent.height
        width:parent.width + rhHeight
        height:rhHeight
    }

    Rectangle {
        id:leftOrRightRect
        x: resizeCorner === JResizeHandle.TopLeft ||  resizeCorner === JResizeHandle.BottomLeft ? -rhHeight : parent.width
        y: resizeCorner === JResizeHandle.TopLeft ||  resizeCorner === JResizeHandle.TopRight ? -rhHeight : 0
        width:rhHeight
        height:parent.width + rhHeight
    }
}
