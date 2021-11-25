/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Yu Jiashu <yujiashu@jingos.com>
 *
 */
import QtQuick 2.0
import QtQml 2.12
import QtQuick.Layouts 1.0
import QtQuick.VirtualKeyboard 2.1
import QtQuick.Controls 2.5
import jingos.display 1.0

Popup {
    id:jkeyboard
    property var strRowList1_1: ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p']
    property var strRowList1_2: ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P']
    property var strRowList1_3: ['\\', '/', ':', ';', '(', ')', '$', '&', '@', '\"']
    property var strRowList1_4: ['——', '|', '~', '<', '>', '€', '￡', '￥', '฿','·']

    property var strRowList2_1: ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l']
    property var strRowList2_2: ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L']
    property var strRowList2_3: ['[', ']', '{', '}', '#', '%', '^', '*', '+']
    property var strRowList2_4: ['《', '》', '“', '”', '‰', '₵', '₽', '₩', '§']

    property var strRowList3_1: ['z', 'x', 'c', 'v', 'b', 'n', 'm']
    property var strRowList3_2: ['Z', 'X', 'C', 'V', 'B', 'N', 'M']
    property var strRowList3_3: ['_', '-', '`', '?', '!', '‖', '=']
    property var strRowList3_4: ['…', '¿', '¡', '【', '】', '「', '」']

    property var symbolList1: ["upper.svg","lowwer.svg","~|￥","@*#"]
    property var symbolList2: [".?123","ABC"]

    property int boardWidth: parent.width
    property int boardHeight: JDisplay.dp(657)
    property int spaceHValue:  boardHeight * 0.0183
    property int spaceVValue:  boardWidth * 0.0067

    signal keyBtnClick(var str)
    signal keyBtnEnter
    signal keyBtnDel

    parent: Overlay.overlay

    //width: boardWidth
    width:  boardWidth
    height: boardHeight

    function changModel(flag, keyStr, imagePath) {
        if(flag) {
            if(keyStr === ".?123" || keyStr === "@*#") {
                row1.model = strRowList1_3
                row2.model = strRowList2_3
                row3.model = strRowList3_3
                leftOpBtn1.keyStr = symbolList1[2]
                leftOpBtn1.textVisible = true
                leftOpBtn2.keyStr = symbolList2[1]
            } else if(keyStr === "~|￥") {
                row1.model = strRowList1_4
                row2.model = strRowList2_4
                row3.model = strRowList3_4
                leftOpBtn1.keyStr = symbolList1[3]
                leftOpBtn1.textVisible = true
                leftOpBtn2.keyStr = symbolList2[1]
            } else if(keyStr==="ABC") {
                row1.model = strRowList1_1
                row2.model = strRowList2_1
                row3.model = strRowList3_1
                leftOpBtn1.imagePath = symbolList1[0]
                leftOpBtn1.textVisible = false
                leftOpBtn2.keyStr = symbolList2[0]
            }
        } else {
            if(imagePath === "upper.svg") {
                row1.model = strRowList1_2
                row2.model = strRowList2_2
                row3.model = strRowList3_2
                leftOpBtn1.imagePath = symbolList1[1]
                leftOpBtn1.textVisible = false
            } else if(imagePath === "lowwer.svg") {
                row1.model = strRowList1_1
                row2.model = strRowList2_1
                row3.model = strRowList3_1
                leftOpBtn1.imagePath = symbolList1[0]
                leftOpBtn1.textVisible = false
            } else if(imagePath === "cleaning.svg") {
                keyBtnDel()
            } else if(imagePath === "check.svg"){
                keyBtnEnter()
            }
        }
    }


    background:Item {
    }

    contentItem :Rectangle {
        anchors.fill: parent
        color: JTheme.colorScheme === "jingosLight" ? "#C3C3CF" : "#2B2B2C"

        Rectangle {
            width: boardHeight * 0.067
            height: boardHeight * 0.067
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.right: parent.right
            anchors.rightMargin:  boardWidth - boardWidth * 0.9- spaceVValue * 9 - boardHeight * 0.067
            color: JTheme.colorScheme === "jingosLight" ? mouse.containsMouse ? (mouse.pressed ? "#787880" : "#FFFFFF") : "transparent"
                                                     : mouse.containsMouse ? (mouse.pressed ? "#4D787880" : "#787880") : "transparent"
            opacity: mouse.containsMouse ? (mouse.pressed ? 1.0 : 0.9) : 1.0

            Image {
                id: hideKey
                anchors.fill: parent
                source: "./image/keyImage/down.svg"
            }

            ShaderEffect {
                anchors.fill: hideKey
                property variant src: hideKey
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

            MouseArea {
                id:mouse
                anchors.centerIn: parent
                width: parent.width + 10
                height: parent.height + 10
                hoverEnabled : true
                onClicked: {
                    jkeyboard.close()
                }
            }
        }

        KeyboardLayout {
            id:keyColumLay
            spacing: spaceHValue
            anchors.top: parent.top
            anchors.topMargin: boardHeight * 0.0913
            anchors.horizontalCenter: parent.horizontalCenter

            KeyboardRow {
                spacing: spaceVValue

                Repeater {

                    model: {
                        ["1", "2", "3","4","5","6","7","8","9","0"]
                    }

                    JNormalKey {
                        keyStr:modelData
                    }
                }
            }

            KeyboardRow {
                spacing: spaceVValue

                Repeater {
                    id:row1
                    model: {
                        strRowList1_1
                    }

                    JNormalKey {
                        keyStr:modelData
                    }
                }
            }

            KeyboardRow {
                spacing: spaceVValue
                Layout.leftMargin: boardWidth * 0.0428//76

                Repeater {
                    id:row2
                    model: {
                        strRowList2_1
                    }

                    JNormalKey {
                        keyStr:modelData
                    }
                }
            }

            KeyboardRow {
                spacing: spaceVValue

                JOptionKey {
                    id: leftOpBtn1
                    textVisible: false
                    imagePath: symbolList1[0]
                }

                Item {
                    Layout.fillWidth: parent.width
                    Layout.fillHeight: parent.height

                    Row {
                        spacing: (parent.width - boardWidth * 0.09 * 7)/6
                        anchors.fill: parent

                        Repeater {
                            id:row3

                            model: {
                                strRowList3_1
                            }

                            JNormalKey {
                                keyStr:modelData
                            }
                        }
                    }
                }

                JOptionKey {
                    implicitWidth:  jkeyboard.boardWidth*0.143
                    textVisible:false
                    imagePath:"cleaning.svg"
                }
            }

            KeyboardRow {
                spacing: spaceVValue

                JOptionKey {
                    id:leftOpBtn2
                    keyStr:symbolList2[0]
                }

                Item {
                    Layout.fillWidth: parent.width
                    Layout.fillHeight: parent.height

                    Row {
                        spacing: (parent.width - boardWidth * 0.473 - boardWidth * 0.09 * 2)/2
                        anchors.fill: parent

                        JNormalKey {
                            keyStr: {
                                qsTr(",")
                            }
                        }

                        JNormalKey{
                            implicitWidth: boardWidth * 0.473//840
                            keyStr:qsTr(' ')
                        }

                        JNormalKey{
                            keyStr:qsTr('.')
                        }
                    }

                }

                JOptionKey{
                    implicitWidth:  jkeyboard.boardWidth * 0.143
                    textVisible:false
                    imagePath:"check.svg"
                }
            }
        }
    }
}

