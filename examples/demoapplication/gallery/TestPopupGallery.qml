/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Rui Wang <wangrui@jingos.com>
 * Lele Huan <huanlele@jingos.com>
 *
 */


import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.5
import org.kde.kirigami 2.11 as Kirigami
import org.kde.kirigami 2.15 as Kirigami215
import org.kde.kirigami 2.8 as Kirigami28


Page {
    id: page
    Layout.fillWidth: true
    
    title: "PopupGallery"
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
    Kirigami215.JArrowPopup{
        id:popDemo
        x:10
        y:10
        visible:false
        Button{
            text:"hide me"
            //anchors.fill:parent
            anchors.centerIn:parent
            onClicked:{
                console.log("before hide:" + popDemo.x + " " + popDemo.y)
                popDemo.visible = false;
                console.log("after hide:" + popDemo.x + " " + popDemo.y)
            }
        }
    }

    Row{
        id:topRow
        anchors{
            top:parent.top
            margins: Kirigami.Units.gridUnit * 2
        }
        height: Kirigami.Units.gridUnit * 3
        width: parent.width - Kirigami.Units.gridUnit * 4
        
        GridLayout{
            columns:5
            rows:1
            Repeater{
                id:rept
                model: 5
                Button{
                    Layout.column:index
                    Layout.margins:Kirigami.Units.gridUnit * 0.75
                    Layout.alignment:Qt.AlignHCenter | Qt.AlignVCenter
                    text: "Button Top " + (index + 1)
                    onClicked:{
                        popDemo.setOrientation(Kirigami215.JArrowPopup.Orientation.UP);
                        popDemo.setOrientedItem(rept.itemAt(index));
                        popDemo.draw();
                    }
                }
            }
        }
    }
}
