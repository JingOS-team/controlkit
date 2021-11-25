/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.2
import org.kde.kirigami 2.15
import jingos.display 1.0
import "private"
Item{
    id: root


    
    property alias radius: mouseHover.radius
    property alias color: mouseHover.color
    property alias darkMode: mouseHover.darkMode

    property int padding: JDisplay.dp(10)

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
