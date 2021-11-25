/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.1
import org.kde.kirigami 2.4
import QtQuick.Controls 2.0 as Controls
import "private"

Controls.Label {

    signal pressed(QtObject mouse)
    signal clicked(QtObject mouse)
    signal released(QtObject mouse)

    height: Math.round(Math.max(paintedHeight, Units.gridUnit * 1.6))
    width: Math.round(Math.max(paintedWidth, Units.gridUnit * 3))
    
    verticalAlignment: lineCount > 1 ? Text.AlignTop : Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter

    activeFocusOnTab: false

    background: PrivateMouseHover{
    }
}
