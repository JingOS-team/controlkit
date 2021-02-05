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

import QtQuick 2.2
import QtQuick.Controls 2.14 as QQC2
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.6
import org.kde.kirigami 2.15
QQC2.Popup  {
    id: openmodeDialog
    property string title : i18nd("kirigami-controlkit", "Open mode")
    property alias model :  dataModel
    //property real dp: Units.devicePixelRatio * 2.3
    property real dp: Units.devicePixelRatio
    property int verticalAlignment : Qt.AlignBottom
    property var urls: []
    //parent: applicationWindow().overlay

    topPadding : 15
    leftPadding: 25
    rightPadding: 25
    bottomPadding: 15
    width : (appView.count <= 4 ? appView.count * 90 + openmodeDialog.rightPadding * 2 : 4 * 90 + openmodeDialog.rightPadding * 2)
    height: 160

    x: Math.round( parent.width / 2 - width / 2 )
    y: Math.round( positionY() )


    function positionY(){
        //         console.log("position parent height is " + parent.height + "   open mode height " + openmodeDialog.height + "  Maui.Style.space.huge " + Maui.Style.space.huge
        //                     + "  devicePixel ratio is " + openmodeDialog.dp)
        if(verticalAlignment === Qt.AlignVCenter){
            return parent.height / 2 - height / 2
        } else if(verticalAlignment === Qt.AlignTop) {
            return (height + Maui.Style.space.huge)
        } else if(verticalAlignment === Qt.AlignBottom) {
            return (parent.height) - (height + Maui.Style.space.huge)
        } else {
            return parent.height / 2 - height / 2
        }
    }

    ListModel{
        id:dataModel
    }

    onVisibleChanged:{
        bkground.startX = openmodeDialog.x
        bkground.startY = openmodeDialog.y
    }

    background: JBlurBackground{
        id: bkground
        anchors.fill: parent
        sourceItem: openmodeDialog.parent
    }

    contentItem: Item {
        //anchors.fill: parent
        Text{
            id:titleText
            font.pointSize: 13
            text:openmodeDialog.title
        }

        ListView{
            id:appView
            width: parent.width
            anchors.top: titleText.bottom
            anchors.topMargin: 15
            anchors.bottom: parent.bottom
            orientation:ListView.Horizontal
            boundsBehavior:Flickable.StopAtBounds
            clip: true
            model:openmodeDialog.model
            delegate: Item {
                id: viewUnitItem
                width: 90
                height:appView.height
                JIconButton{
                    id:iconBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: model.icon
                    height: 50
                    width: height
                    onClicked: {
                        const obj = dataModel.get(index)
                        Maui.KDE.openWithApp(obj.actionArgument, openmodeDialog.urls)
                        openmodeDialog.close()
                    }
                }

                Text {
                    anchors.top: iconBtn.bottom
                    anchors.topMargin: 5
                    width: parent.width
                    elide:Text.ElideRight
                    wrapMode: Text.WordWrap
                    horizontalAlignment:Text.AlignHCenter
                    maximumLineCount: 2
                    font.pointSize: 8
                    text: model.label
                }
            }
            QQC2.ScrollBar.horizontal: QQC2.ScrollBar { policy: QQC2.ScrollBar.AlwaysOn}
        }
    }
}
