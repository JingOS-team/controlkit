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

    // background: Rectangle {
    //     anchors.fill: parent
    //     Kirigami.Theme.colorSet: Kirigami.Theme.View
    //     color: "white"
    // }

    Layout.fillWidth: true
    
    title: "ImageGallery"
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
        width: page.width
        spacing: Units.smallSpacing


        Kirigami.Icon{
            id: iconK
            source:"qrc:/today_number.png"
            //source: "applications-games"
            Component.onCompleted:{
                console.log("Kirigami.Icon Component.onCompleted iconK.width:"+ iconK.width)
                console.log("Kirigami.Icon Component.onCompleted iconK.height:"+ iconK.height)

                var pan = new Panel("org.kde.phone.panel")
                console.log("Kirigami.Icon Component.onCompleted pan.height:" + pan.height)

            }
        }


        Kirigami.Icon{
            width: 128
            height: 128
            source:"qrc:/recoder.png"
            Kirigami215.JMouseSolid{
                onClicked:{
                    console.log("Kirigami215.JMouseSolid clicked")
                }
            }
        }

        Kirigami.Icon{
            width: 40
            height: 40
            source:"qrc:/today_number.png"
            Kirigami215.JMouseHover{
                onClicked:{
                    console.log("Kirigami215.JMouseHover clicked")
                }
            }
        }

        Kirigami.Icon{
            width: 128
            height: 128
            source:"qrc:/Music.svg"
            Kirigami215.JMouseHoverMask{
                anchors.fill: parent
                onClicked:{
                    console.log("Kirigami215.JMouseSolid clicked")
                }
            }
        }
    }
}
