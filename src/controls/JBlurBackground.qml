/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.2
import QtQml 2.12
import org.kde.kirigami 2.15
import QtGraphicalEffects 1.0
import jingos.display 1.0
Item{
    id: blurBackground

    property var sourceItem: null
    property var radius: JDisplay.dp(10)
    property real blurRadius: 128
    property real backgroundOpacity: 0.6

    property color backgroundColor : JTheme.floatBackground

    property bool showBgCover: true
    property bool showBgBoder: true
    property bool useBlur: true

    property int arrowX: 0
    property int arrowY: 0
    property int arrowWidth: 0
    property int arrowHeight: 0
    property int arrowPos: JRoundRectangle.ARROW_UNKOWN

    property rect sourceRect: Qt.rect(0, 0, -1, -1)
    property bool resetByManual: false
    onWidthChanged: {
        if(resetByManual === false && useBlur === true)
            delayTimer.start();
    }
    onHeightChanged: {
        if(resetByManual === false && useBlur === true)
            delayTimer.start();
    }

    Timer{
        id:delayTimer
        interval: 10
        repeat: false
        onTriggered: {
            resetBg();
        }
    }

    onVisibleChanged: {
        if(visible === false){
            blurLoader.active =false;
        } else {
            if(resetByManual === false && useBlur === true)
                delayTimer.start();
        }
    }

    function resetBg(){
        if((resetByManual === true || blurBackground.visible === true) && blurBackground.sourceItem && blurBackground.width > 0 && blurBackground.height > 0 && useBlur === true){
            var jx = blurBackground.mapToItem(blurBackground.sourceItem, 0, 0);
            blurBackground.sourceRect = Qt.rect(jx.x, jx.y, blurBackground.width, blurBackground.height);
            if(blurLoader.active === false){
                blurLoader.active = true;
            }
        } else {
            blurLoader.active = false;
        }
    }

    Loader{
        id:blurLoader
        anchors.fill: parent
        active: false
        sourceComponent:bkblurCom
    }

    Component{
        id:bkblurCom
        Item{
            ShaderEffectSource{
                id:eff
                anchors.fill: parent
                sourceItem: blurBackground.sourceItem
                sourceRect: blurBackground.sourceRect
                visible: false

            }

            FastBlur{
                id:fastBlur
                anchors.fill: parent
                source: eff
                radius: blurBackground.blurRadius
                cached: false
                visible:false
            }

            JRoundRectangle{
                id:maskRect
                anchors.fill: parent
                visible: false
                radius: blurBackground.radius
                radiusPos: JRoundRectangle.BOTTOMLEFT | JRoundRectangle.BOTTOMRIGHT | JRoundRectangle.TOPLEFT | JRoundRectangle.TOPRIGHT
                arrowPos:blurBackground.arrowPos
                arrowX:blurBackground.arrowX
                arrowY:blurBackground.arrowY
                arrowWidth: blurBackground.arrowWidth
                arrowHeight: blurBackground.arrowHeight
            }

            OpacityMask{
                id:mask
                anchors.fill: maskRect
                source: fastBlur
                maskSource: maskRect
            }

            DropShadow {
                anchors.fill: mask
                horizontalOffset: 0
                verticalOffset: JDisplay.dp(4)
                radius: 12.0
                samples: 24
                cached: true
                color: Qt.rgba(0, 0, 0, 0.1)
                source: mask
            }
        }
    }

    JRoundRectangle{
        anchors.fill: parent
        radius: blurBackground.radius
        radiusPos: JRoundRectangle.BOTTOMLEFT | JRoundRectangle.BOTTOMRIGHT | JRoundRectangle.TOPLEFT | JRoundRectangle.TOPRIGHT
        arrowPos:blurBackground.arrowPos
        arrowX:blurBackground.arrowX
        arrowY:blurBackground.arrowY
        arrowWidth: blurBackground.arrowWidth
        arrowHeight: blurBackground.arrowHeight

        visible: blurBackground.showBgCover
        color: Qt.rgba(blurBackground.backgroundColor.r, blurBackground.backgroundColor.g, blurBackground.backgroundColor.b)
        opacity: blurBackground.sourceItem ? blurBackground.backgroundOpacity : 1.0
        borderColor: Qt.rgba(0, 0, 0, 0.1)
        borderWidth : blurBackground.showBgBoder ? 1 : 0
    }

//    Rectangle{
//        anchors.fill: parent
//        radius: blurBackground.radius
//        visible: blurBackground.showBgCover
//        color: Qt.rgba(blurBackground.backgroundColor.r, blurBackground.backgroundColor.g, blurBackground.backgroundColor.b)
//        opacity: blurBackground.sourceItem ? 0.6 : 1.0
//        border.color:  Qt.rgba(0, 0, 0, 0.1)
//        border.width:  blurBackground.showBgBoder ? 1 : 0
//    }
}
