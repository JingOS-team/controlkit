/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */



import QtQuick 2.6
import QtQml 2.12
import QtQuick.Controls 2.1 as Controls
import org.kde.kirigami 2.15 as Kirigami
import jingos.display 1.0

//Controls.TextField
Kirigami.JTextField {
    id: textField

    property string focusSequence
    property bool alwaysShowSearchIcon: false
    property list<QtObject> leftActions

    property color borderColor: JTheme.textFieldBorder
    property color selectColor: JTheme.textFieldSelectColor
    bgRadius:JDisplay.dp(10)

    signal leftActionTrigger()
    signal rightActionTrigger();


    leftPadding: JDisplay.dp(7) + leftActionsRow.width

    FontMetrics {
         id: fontMetrics
         font:textField.font
     }

    Shortcut {
        id: focusShortcut
        enabled: textField.focusSequence
        sequence: textField.focusSequence
        onActivated: {
            textField.forceActiveFocus()
            textField.selectAll()
        }
    }

    leftActions:[
        Kirigami.Action {
            icon.name: Qt.resolvedUrl("./image/64-actions-jing-search-bar.svg")
            visible: textField.alwaysShowSearchIcon === true || (textField.activeFocus === false && (textField.text.length <= 0))

            onTriggered:{
                textField.leftActionTrigger()
            }
        }
    ]

    Row {
        id: leftActionsRow

        anchors.left: parent.left
        anchors.leftMargin: JDisplay.dp(7)
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: textField.leftActions
            Kirigami.JIconButton {
                height: Math.max(textField.height * 0.8, JDisplay.dp(12))
                width: height

                visible: modelData.visible
                source: modelData.icon.name.length > 0 ? modelData.icon.name : modelData.icon.source
                onClicked: {
                    modelData.trigger()
                    textField.forceActiveFocus()
                }
            }
        }
    }

//    background:Rectangle{
//        color:textField.bgColor
//        radius: textField.bgRadius
//        border.color: textField.borderColor
//        border.width: textField.activeFocus === true ?  textField.borderWidth : 0
//    }
}

