/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.2
import QtQml 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14 as QQC2

import org.kde.kirigami 2.5
import org.kde.kirigami 2.15
import jingos.display 1.0
/*
ApplicationWindow
   |
   |- QQuickRootItem
   |      |
   |      |- QQuickContentItem (objectName is  ApplicationWindow)
   |               |
   |               |-(content)
   |
   |- QQuickOverlay

Window
   |
   |- QQuickContentItem
         |
         |-(content)
*/

/*
    |-----------------------|
    |     title             |
    |-----------------------|

    |-----------------------|
    |     text              |
    |-----------------------|

    |-----------------------|
    | msgText or inputtext  |
    |-----------------------|

    |-----------------------|
    |  two or one button    |
    |-----------------------|

 */


QQC2.ToolTip  {
    id: dialog
    property Item sourceItem: null
    //applicationwidnow cotentitem
    property Item windowContentItem: null

    property color textColor: JTheme.background
    property color backgroundColor: JTheme.majorForeground

    x : (QQC2.Overlay.overlay.width - dialog.width) / 2
    y : QQC2.Overlay.overlay.height - JDisplay.dp(36) - dialog.height

    delay: 0
    timeout: 1500

    topPadding: JDisplay.dp(16)
    leftPadding: JDisplay.dp(16)
    rightPadding: JDisplay.dp(16)
    bottomPadding: JDisplay.dp(16)
    parent: QQC2.Overlay.overlay
    visible: false
    onWindowChanged: {
        if(window){
            dialog.windowContentItem = window.contentItem;
        } else {
            dialog.windowContentItem = null;
        }
    }


    contentItem:  Text {
        id: name
        font: dialog.font
        color:dialog.textColor
        text: dialog.text
    }

    enter: Transition {
            ParallelAnimation{
                NumberAnimation { property: "scale"; from: 0.0; to: 1.0; duration: 75 }
                NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 75 }
            }
    }

    onVisibleChanged: {
        if(visible){
             bkground.resetBg();
        }
    }

    background: JBlurBackground{
        id: bkground
        resetByManual: true
        backgroundColor: dialog.backgroundColor
        sourceItem: dialog.sourceItem ? dialog.sourceItem : dialog.windowContentItem
    }
}
