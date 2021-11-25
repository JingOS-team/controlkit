/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Yu Jiashu <yujiashu@jingos.com>
 *
 */
import QtQuick 2.0
import QtQml 2.12

Rectangle {
    id:keyBtn

    property alias keyStr: keyText.text
    property string imagePath:"upper.svg"
    property int type : 0
    property bool textVisible: true

    implicitWidth:  jkeyboard.boardWidth * 0.1329
    implicitHeight: jkeyboard.boardHeight * 0.1613
    color: JTheme.colorScheme === "jingosLight" ? mouse.containsMouse ? (mouse.pressed ? "#787880":"#FFFFFF"):"#A6B8BACF"
                                              : mouse.containsMouse ? (mouse.pressed ? "#4D787880":"#787880"):"#338E8E93"
    opacity: mouse.containsMouse ? (mouse.pressed ? 1.0 : 0.9) : 1.0
    radius: keyBtn.height * 0.34

    Text {
        id: keyText
        anchors.fill: parent
        visible: textVisible
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: "Gilroy"
        font.weight: Font.Normal
        font.pixelSize: parseInt(jkeyboard.boardHeight * 0.0472)
        color: JTheme.majorForeground
    }

    Item {
        width: jkeyboard.boardHeight * 0.0857
        height: jkeyboard.boardHeight * 0.0857
        anchors.centerIn: parent
         visible: !textVisible

        Image {
            id: keyImage
            anchors.fill: parent
            source: "./image/keyImage/" + imagePath
        }
        ShaderEffect {
            anchors.fill: keyImage
            property variant src: keyImage
            property color color: JTheme.majorForeground
            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform sampler2D src;
                uniform highp vec4 color;
                uniform lowp float qt_Opacity;
                void main() {
                    lowp vec4 tex = texture2D(src, qt_TexCoord0);
                    gl_FragColor = vec4(color.r * tex.a, color.g * tex.a, color.b * tex.a, tex.a) * qt_Opacity;
                }"
        }
    }

    MouseArea {
        id:mouse
        anchors.fill: parent
        hoverEnabled : true
        onClicked: {
            jkeyboard.changModel(textVisible, keyStr, imagePath)
        }
        onContainsMouseChanged: {
            if(mouse.pressed) {
                jkeyboard.changModel(textVisible, keyStr, imagePath)
            }
        }
    }
}
