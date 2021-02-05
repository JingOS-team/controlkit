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


