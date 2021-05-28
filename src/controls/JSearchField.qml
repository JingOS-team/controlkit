/*
 * Copyright 2021 Rui Wang <wangrui@jingos.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */


import QtQuick 2.6
import QtQml 2.12
import QtQuick.Controls 2.1 as Controls
import org.kde.kirigami 2.7 as Kirigami
import org.kde.kirigami 2.15

Controls.TextField
{
    id: textField

    property string focusSequence
    property bool alwaysShowSearchIcon: false
    property list<QtObject> leftActions
    property list<QtObject> rightActions
    property color bgColor: "#0c000000"
    property bool showPassword: false

    echoMode: showPassword ? TextInput.Password : TextInput.Normal

    signal leftActionTrigger()
    signal rightActionTrigger()

    Accessible.name: qsTr("Search")
    Accessible.searchEdit: true

    leftPadding: alwaysShowSearchIcon ? leftActionsRow.width : 10
    rightPadding: rightActionsRow.width

    placeholderText: ""
    hoverEnabled: true

    Shortcut {
        id: focusShortcut
        enabled: textField.focusSequence
        sequence: textField.focusSequence
        onActivated: {
            textField.forceActiveFocus()
            textField.selectAll()
        }
    }

    background:Rectangle{
        width:parent.width
        height: parent.height

        color:textField.bgColor
        radius: parent.height*0.36
    }

    leftActions:[
        Kirigami.Action {
            icon.name: "jing-search-bar"
            visible: textField.alwaysShowSearchIcon === true || (textField.activeFocus === false && (textField.text.length <= 0))

            onTriggered:{
                textField.leftActionTrigger()
            }
        }                
    ]

    rightActions: [
        Kirigami.Action {
            icon.name:  "jing-search-clear" 
            visible: textField.text.length > 0

            onTriggered: {
                textField.text = ""
                textField.accepted()
                textField.focus = false
                textField.rightActionTrigger()
            }
        },
        Kirigami.Action {
            icon.name:  textField.echoMode === TextInput.Normal ?  "jing-input-pwd-visible" : "jing-input-pwd-hidden"
            visible: textField.showPassword
            onTriggered: {
                if(textField.echoMode === TextInput.Normal){
                    textField.echoMode = TextInput.Password
                } else {
                    textField.echoMode = TextInput.Normal;
                }
            }
        }
    ]

    Controls.ToolTip {
        visible: textField.focusSequence && textField.text.length === 0 && !rightActionsRow.hovered && !leftActionsRow.hovered && hovered
        text: textField.focusSequence ? textField.focusSequence : ""
    }
    
    cursorDelegate: Rectangle{
        id: cursorBg
        anchors.verticalCenter: parent.verticalCenter

        width: Kirigami.Units.devicePixelRatio * 2
        height: parent.height / 2
        color: "#FF3C4BE8"

        Timer{
            id: timer

            interval: 700
            repeat: true

            //running: textField.focus
            running: textField.activeFocus

            onRunningChanged: {
                if(running === false){
                    cursorBg.visible = false
                }
            }

            onTriggered: {
                if(timer.running) {
                    cursorBg.visible = !cursorBg.visible
                } else {
                    cursorBg.visible = false
                }
            }
        }

//        Connections {
//            target: textField
//            function onActiveFocusChanged(){
//                cursorBg.visible = focus
//            }
//        }
    }

    Row {
        id: leftActionsRow

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        height: textField.implicitHeight - 2 * Kirigami.Units.smallSpacing
        padding: Kirigami.Units.smallSpacing

        Repeater {
            model: textField.leftActions
            Kirigami.Icon {
                anchors.verticalCenter: parent.verticalCenter

                height: parent.height
                width:  parent.height
                
                source: modelData.icon.name.length > 0 ? modelData.icon.name : modelData.icon.source
                visible: modelData.visible
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: modelData.trigger()
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }

    Row {
        id: rightActionsRow

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        
        height: textField.implicitHeight - 2 * Kirigami.Units.smallSpacing
        //padding: Kirigami.Units.smallSpacing
        layoutDirection: Qt.RightToLeft

        Repeater {
            model: textField.rightActions

            JIconButton{
                anchors.verticalCenter: parent.verticalCenter
                padding: 2
                height: parent.height
                width: parent.height

                source: modelData.icon.name.length > 0 ? modelData.icon.name : modelData.icon.source
                visible: modelData.visible

                onClicked:modelData.trigger()
            }
        }
    }
}
