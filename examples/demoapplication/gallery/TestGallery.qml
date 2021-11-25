/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Rui Wang <wangrui@jingos.com>
 * Lele Huan <huanlele@jingos.com>
 *
 */
 
import QtQuick 2.0
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.5
import org.kde.kirigami 2.11 as Kirigami
import org.kde.kirigami 2.15 as Kirigami215
import org.kde.kirigami 2.8 as Kirigami28
import QtQuick.Controls 2.14

Kirigami.Page {
    id: page
    Layout.fillWidth: true

    background: Rectangle {
        anchors.fill: parent
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        color: "white"
    }
    
    title: "TestGallery"
    // actions {
    //     contextualActions: [
    //         Kirigami.Action {
    //             text: "action 1"
    //         },
    //         Kirigami.Action {
    //             text: "action 2"
    //         }
    //     ]
    // }
    // Column {
    //     width: page.width
    //     spacing: Units.smallSpacing
    //     Rectangle{
    //         width: 200
    //         height: 100
    //         Text{
    //             text: "MouseArea Test"
    //         }
    //         MouseArea {
    //             anchors.fill: parent
    //             hoverEnabled: true
    //             onEntered: {
    //                 console.log(" --onEntered- " + mouseX + " --- " + mouseY)
    //             }

    //             onExited: {
    //                 console.log(" -onExited-- " + mouseX + " --- " + mouseY)
    //             }

    //             onClicked: {
    //                 console.log(" -onClicked-- " + mouseX + " --- " + mouseY)

    //             }
    //             onPressed: {
    //                 console.log(" -onPressed-- " + mouseX + " --- " + mouseY)
    //             }
    //         }
    //     }
    // }
    Column {
        anchors.fill: parent
        spacing: Units.smallSpacing
        Rectangle{
            width:200
            height: 200
            Text{
                text: "Menu test"
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    console.log("--onPressAndHold----mouse.button:" + mouse.button)
                    if (mouse.button === Qt.RightButton)
                        contextMenu.popup()
                }
                onPressAndHold:{
                    console.log("--onPressAndHold----mouse.button:" + mouse.button)
                    if (mouse.button === Qt.MouseEventNotSynthesized)
                        contextMenu.popup()
                }
            }

            Menu {
                id: contextMenu
                MenuItem {text: "Cut"}
                MenuItem {text: "Copy"}
                MenuItem {text: "Paste"}
            }
        }
    }
}
