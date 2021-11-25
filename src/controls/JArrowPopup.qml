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
QQC2.Popup {
    id: root

    implicitWidth : Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding) //JDisplay.dp(198)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding)

    property alias blurBackground: blurBk

    property Item windowContentItem: null

    leftPadding: JDisplay.dp(20)
    rightPadding: JDisplay.dp(20)

    topPadding: blurBackground.arrowPos === JRoundRectangle.ARROW_TOP ? blurBackground.arrowHeight : 0
    bottomPadding: blurBackground.arrowPos === JRoundRectangle.ARROW_BOTTOM ? blurBackground.arrowHeight : 0

    onWindowChanged: {
        if(window){
            root.windowContentItem = window.contentItem;
        } else {
            root.windowContentItem = null;
        }
    }

//    enter: Transition {
//        SequentialAnimation{
//            ParallelAnimation{
//                NumberAnimation { property: "scale"; from: 0.0; to: 1.0; duration: 225 }
//                NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 225 }
//            }
//            ScriptAction{   script: setbackground();}
//        }
//    }

//    function setbackground(){
//        blurBk.resetBg();
//    }

    background: JBlurBackground{
        id:blurBk
        backgroundColor: JTheme.cardBackground
        sourceItem: root.windowContentItem
    }
}



