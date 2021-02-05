/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import org.kde.kirigami 2.4 as Kirigami
import org.kde.kirigami 2.15 as Kirigami215
import org.kde.kirigami 2.8 as Kirigami28
import org.kde.kirigami 2.0 as Kirigami20
import QtQuick.Controls 2.14
Kirigami.ApplicationItem {
    id: root

    // Rectangle {
    //     color: "red"
    //     anchors.fill: parent
    // }
    globalDrawer: Kirigami.GlobalDrawer {
        title: "Hello App"
        titleIcon: "applications-graphics"

        actions: [
            Kirigami.Action {
                text: "View"
                icon.name: "view-list-icons"
                Kirigami.Action {
                    text: "action 1"
                }
                Kirigami.Action {
                    text: "action 2"
                }
                Kirigami.Action {
                    text: "action 3"
                }
            },
            Kirigami.Action {
                text: "action 3"
            },
            Kirigami.Action {
                text: "action 4"
            }
        ]
        handleVisible: true
    }
    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    pageStack.initialPage: mainPageComponent

    Component {
        id: mainPageComponent
        Kirigami.Page {
            title: "Hello"
            actions {
                contextualActions: [
                    Kirigami.Action {
                        text: "action 1"
                    },
                    Kirigami.Action {
                        text: "action 2"
                    }
                ]
            }
        //    Rectangle {
        //        color: "blue"
        //        anchors.fill: parent
        //    }

            // Kirigami26.LinkButton{
            //     id:linkButton
            //     anchors.centerIn: parent
            //     text: "Hello world"
            //     font.pixelSize: 22
            //     font.italic: true
            //     color: "red"
            //     onClicked: {
            //         showPassiveNotification("Action 2 clicked")
            //     }
            // }
            Kirigami215.JButton{
                id: jbutton
                anchors.top : linkButton.bottom
                width:200
                height:100
                // color:"red"
                anchors.topMargin: 100
                anchors.horizontalCenter: parent
                text: "hover"
                font.pixelSize: 22
                font.italic: true
                onClicked: {
                    showPassiveNotification("Action 2 clicked")
                }
            }
            Kirigami215.JIconButton{
                anchors.top : jbutton.bottom
                anchors.topMargin: 100
                anchors.horizontalCenter: parent
                source:"qrc:/today_number.png"
                onClicked: {
                    showPassiveNotification("Action 2 clicked")
                }
            }

            Kirigami.Icon{
                id: iconK
                anchors.left : jbutton.right
                anchors.topMargin: 100
                anchors.horizontalCenter: parent
                source:"qrc:/today_number.png"
                //source: "applications-games"
                Component.onCompleted:{
                    console.log("Kirigami.Icon Component.onCompleted iconK.width:"+ iconK.width)
                    console.log("Kirigami.Icon Component.onCompleted iconK.height:"+ iconK.height)

                    var pan = new Panel("org.kde.phone.panel")
                    console.log("Kirigami.Icon Component.onCompleted pan.height:" + pan.height)

                }
                // Text {
                //     text: "Icon"
                //     anchors.centerIn: parent
                //     font.bold: true
                //     color: "#8e8e8e"
                // }   
            }

            Kirigami28.SearchField{
                id: searchField
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 200
                height: 50
            }


            Kirigami215.JLabel{
                anchors.top : searchField.bottom
                anchors.topMargin: 100
                anchors.horizontalCenter: parent
                text: qsTr("Label")
                onClicked: {
                    showPassiveNotification("Action 2 clicked")
                }
            }


            // Kirigami20.Icon{
            //     width: 100
            //     height: 100
            //     anchors.top: searchField.bottom
            //     // source: "applications-games"
            //     source: "akregator"

            // }





            // Action {
            //     id: copyAction
            //     text: qsTr("&Copy")
            //     icon.name: "edit-copy"
            //     shortcut: StandardKey.Copy
            //     onTriggered: window.activeFocusItem.copy()
            // }

            // ToolButton {
            //     id: toolButton
            //     anchors.top: searchField.bottom
            //     anchors.topMargin: 300
            //     action: copyAction
            // }
        }
    }
}
