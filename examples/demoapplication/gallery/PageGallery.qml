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
    
    title: "PageGallery"

    Column {
        anchors.fill: parent
        spacing: Units.smallSpacing

        Rectangle{
            width: 200
            height: 200
            color: "red"
            Text{
                anchors.centerIn: parent
                text: "open A Page"
            }
            MouseArea{
                anchors.fill: parent
                onClicked:{
                    applicationWindow().pageStack.push(Qt.resolvedUrl("PageGallery.qml"));
                }
            }
        }

        Rectangle{
            width: 200
            height: 200
            color: "green"
            Text{
                anchors.centerIn: parent
                text: "close A Page"
            }
            MouseArea{
                anchors.fill: parent
                onClicked:{
                    applicationWindow().pageStack.pop();
                }
            }
        }
    }

}
