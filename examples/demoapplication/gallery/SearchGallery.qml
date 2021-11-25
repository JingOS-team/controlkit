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


ScrollablePage {
    id: page
    Layout.fillWidth: true
    title: "TestGallery"
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

        Controls.TextField {
            width: 200
            height: 50
            placeholderText: qsTr("Enter name")
            hoverEnabled: true
        }

        Kirigami28.SearchField{
            id: searchField
            width: 200
            height: 50
        }

        Kirigami215.JSearchField{
            id: searchFieldNew
            width: 300
            height: 60
            onTextChanged:{
                console.log("text:" + text)
            }

            onRightActionTrigger:{
                console.log("onRightTrigger")
            }

            onLeftActionTrigger:{
                console.log("onLeftTrigger")
            }
        }
    }
}
