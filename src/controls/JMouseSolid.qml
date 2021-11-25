/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.2
import org.kde.kirigami 2.15
import "private"

Item{
    id: root
    
    signal pressed(QtObject mouse)
    signal clicked(QtObject mouse)
    signal released(QtObject mouse)
    
    anchors.fill: parent

    PrivateMouseSolid{
        resizeObject: root.parent
    }
}
