/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Yu Jiashu <yujiashu@jingos.com>
 *
 */
import QtQuick 2.0
import org.kde.kirigami 2.15

Rectangle {
    id:keyBtn
    property alias keyStr: keyText.text

    implicitWidth:  jkeyboard.boardWidth * 0.09
    implicitHeight: jkeyboard.boardHeight * 0.1613
    color:JTheme.colorScheme === "jingosLight" ? mouse.containsMouse ? (mouse.pressed ? "#787880" : "#FFFFFF") : "#A6FFFFFF"
                                             : mouse.containsMouse ? (mouse.pressed ? "#4D787880" : "#787880") : "#4D9F9FAA"
    opacity: mouse.containsMouse ? (mouse.pressed ? 1.0 : 0.9) : 1.0
    radius: keyBtn.height * 0.34

    Text {
        id: keyText
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family : "Gilroy"
        font.weight: Font.Normal
        font.pixelSize: parseInt(jkeyboard.boardHeight * 0.0472)
        color: JTheme.majorForeground//"#000000"
    }

    MouseArea{
        id:mouse
        hoverEnabled : true
        anchors.fill: parent
        onClicked: {
            jkeyboard.keyBtnClick(keyStr)
        }

        onContainsMouseChanged: {
            if(mouse.pressed) {
                jkeyboard.keyBtnClick(keyStr)
            }
        }
    }
}
