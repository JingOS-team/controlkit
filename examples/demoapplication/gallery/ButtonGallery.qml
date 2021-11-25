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


ScrollablePage {
    id: page

    Layout.fillWidth: true
    title: "ButtonGallery"

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

    Column {
        spacing: 50
        width: page.width

        Kirigami215.JButton{
            id: jbutton
            width:200
            height:100

            font.pixelSize: 22
            font.italic: true
            text: "hover"

            onClicked: {
                showPassiveNotification("Action 2 clicked")
            }
        }

        Kirigami215.JIconButton{
            source:"qrc:/Interfac.svg"
            onClicked: {
                showPassiveNotification("Action 2 clicked")
            }
        }

        Kirigami215.JIconButton{
            width: 128
            height: 128

            source:"qrc:/Music.svg"
            disableSource: "qrc:/blackPlay.png"

            onClicked: {
                showPassiveNotification("Action 2 clicked")
            }
        }

        Kirigami215.JSolidButton{
            width: 128
            height: 128

            source:"qrc:/recoder.png"
            onClicked: {
                showPassiveNotification("Action 2 clicked")
            }

            Kirigami.Icon{
                anchors.centerIn:parent

                width: 74
                height: 74
                source:"qrc:/recoder-speaker.png"
            }
        }

        Rectangle{
            width: 300
            height: 300
            color: "black"

            Kirigami215.JIconButton{
                anchors.centerIn: parent
                
                width: 74
                height: 74
                z: 666
                darkMode: true
                source:"qrc:/blackPlay.png"

                onClicked: {
                    showPassiveNotification("Action 2 clicked")
                }
            }
        }
        
    }
}


