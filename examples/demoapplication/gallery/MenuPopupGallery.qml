/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Rui Wang <wangrui@jingos.com>
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.0
import QtQuick.Controls 2.3 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.5
import org.kde.kirigami 2.11 as Kirigami
import org.kde.kirigami 2.15 as Kirigami215
import org.kde.kirigami 2.8 as Kirigami28
import QtQuick.Controls 2.14

ScrollablePage {
    id: page
    Layout.fillWidth: true

    background: Item{
    }
    
    title: "MenuPopupGallery"
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

    Kirigami215.JPopupMenu {
        id: contextMenu
        Action { 
            text: "Batch editing"
            icon.source: "qrc:/menu-folder.png"
            onTriggered:{
                console.log("JPopupMenu--onTriggered----Batch editing")
            }
        }
        Kirigami215.JMenuSeparator { }
        Action { 
            text: "Save to file"
            icon.source: "qrc:/menu-new.png"
            onTriggered:{
                console.log("JPopupMenu--onTriggered----Save to file")
            } 
        }
        Kirigami215.JMenuSeparator { }
        Action { 
            text: "Delete"
            icon.source: "qrc:/menu-delete.png"
            onTriggered:{
                console.log("JPopupMenu--onTriggered----Delete")
            } 
        }

        Component.onCompleted:{
            console.log("Kirigami215.JPopupMenu width:" + contextMenu.width)
        }
    }

    Column {
        width: page.width
        spacing: Units.smallSpacing
        Rectangle{
            width:200
            height: 200
            color:"red"
            Text{
                text: "Menu test1"
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    console.log("--onClicked----mouse.button:" + mouse.button)
                    console.log("--onClicked----mouse.x:" + mouse.x + "  mouse.y:" + mouse.y)
                    contextMenu.popup(mouse.x, mouse.y)
                }
            }
        }
        Rectangle{
            width:200
            height: 200
            color:"yellow"
            Text{
                text: "Menu test1"
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    console.log("--onPressAndHold----mouse.button:" + mouse.button)
                    contextMenu.popup()
                }
            }
        }
        Rectangle{
            width:200
            height: 200
            color:"green"
            Text{
                text: "Menu test1"
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    console.log("--onPressAndHold----mouse.button:" + mouse.button)
                    contextMenu.popup()
                }
            }
        }
    }
}
