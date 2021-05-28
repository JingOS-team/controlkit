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

import QtQuick 2.2
import org.kde.kirigami 2.5
import org.kde.kirigami 2.15
import QtQuick.Controls 2.14

Popup  {
    id: dailog

    property string title
    property alias inputText: textInput.text
    property alias echoMode: textInput.echoMode
    
    signal cancelButtonClicked()
    signal okButtonClicked()

    anchors.centerIn: applicationWindow().overlay
    parent: applicationWindow().overlay

    modal: true
    closePolicy: Popup.NoAutoClose

    height: units.gridUnit * 10.7
    width: units.gridUnit * 22.1

    contentItem: Item {
        anchors.fill: parent
        Text {
            id: titleText
            anchors.left: parent.left
            anchors.leftMargin: units.gridUnit * 1.4
            anchors.top: parent.top
            anchors.topMargin: units.gridUnit * 1.4
            horizontalAlignment: Text.AlignHCenter 
            verticalAlignment: Text.AlignVCenter 
            
            width: units.gridUnit * 12
            font.pointSize: 31
            color: "#000000"
            text: dailog.title
        }
        Row{
            anchors.right: parent.right
            anchors.rightMargin: units.gridUnit * 1.4
            anchors.top: parent.top
            anchors.topMargin: units.gridUnit * 1.4
            spacing: units.gridUnit * 2.1
            JIconButton {
                source: "jing-dailog-cancel"
                width: units.gridUnit * 1.57
                height: units.gridUnit * 1.57
                onClicked: {
                    dailog.inputText = ""
                    dailog.cancelButtonClicked()
                    dailog.close()
                }
            }
            JIconButton {
                source: "jing-dailog-ok"
                width: units.gridUnit * 1.57
                height: units.gridUnit * 1.57
                onClicked: {
                    dailog.okButtonClicked()
                }
            }
        }
        TextField {
            id: textInput
            anchors.top: titleText.bottom
            anchors.topMargin: units.gridUnit * 2
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - units.gridUnit * 2.8
            height: units.gridUnit * 3.2
            font.pointSize: 30
            color: "#000000"
            background:Item{
                width:parent.width
                height: parent.height
                Rectangle{
                    anchors.bottom: parent.bottom
                    width:parent.width
                    height: 1
                    color: "#EEE5E5EA"
                }
            }
            cursorDelegate: Rectangle{
                id: cursorBg
                anchors.verticalCenter: parent.verticalCenter

                width: units.devicePixelRatio * 2
                height: parent.height / 2
                color: "#FF3C4BE8"

                Timer{
                    id: timer

                    interval: 700
                    repeat: true
                    running: textInput.focus

                    onTriggered: {
                        if(timer.running) {
                            cursorBg.visible = !cursorBg.visible
                        } else {
                            cursorBg.visible = false
                        }
                    }
                }

                Connections {
                    target: textInput
                    onFocusChanged: cursorBg.visible = focus
                }
            }
        }
    }

    background: Rectangle{
        id: bkground
        width:parent.width
        height: parent.height
        color:"#FEFFFFFF"
        radius: ConstValue.jingUnit 
    }
}
