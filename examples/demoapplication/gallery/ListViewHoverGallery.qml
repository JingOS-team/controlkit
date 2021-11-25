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


Kirigami.Page {
    id: page
    title: "GridHoverGallery"
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

    ListModel {
        id: listModel
        ListElement {
            name: "1"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "2"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "3"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "4"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "5"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "6"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "7"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "8"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "9"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "10"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "11"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "12"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "13"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "14"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "15"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "16"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "17"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "18"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "19"
            portrait: "qrc:/Music.svg"
        }
        ListElement {
            name: "20"
            portrait: "qrc:/Music.svg"
        }
    }

    ListView {
        id: listView
        width: 400
        height: 600
        model: listModel
        delegate:Item {
            width: 100
            height: 40
            // Row {
            //     anchors.fill: parent
            //     Kirigami.Icon { 
            //         source: portrait
            //     }
            //     Text{
            //         text: name
            //         font.pixelSize: 20
            //     }
            // }
            Text{
                text: name
                font.pixelSize: 20
            }
            Kirigami215.JMouseHoverMask{
                anchors.fill: parent
            }
          }
    }

}
