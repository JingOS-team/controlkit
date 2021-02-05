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
