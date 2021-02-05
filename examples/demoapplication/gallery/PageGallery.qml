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
