/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.2
import QtQuick.Controls 2.14 as QQC2
import org.kde.kirigami 2.15
import jingos.display 1.0
QQC2.MenuSeparator {
    id: controlRoot
    property color separatorColor: JTheme.dividerForeground
    anchors.horizontalCenter: parent.horizontalCenter

    topPadding: 0
    bottomPadding: 0
    
    implicitHeight: topPadding + bottomPadding + separator.implicitHeight
    width: parent.width -  JDisplay.dp(36)

    contentItem: Rectangle{
        id: separator

        anchors.centerIn: controlRoot
        width: controlRoot.width
        implicitHeight: Units.devicePixelRatio
        color:controlRoot.separatorColor
    }
}



