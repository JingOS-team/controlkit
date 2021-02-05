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
import org.kde.kirigami 2.5
import org.kde.kirigami 2.15
import QtQuick.Controls 2.14 as QQC2

QQC2.Popup  {
    id: dailog

    property string text
    property string title
    property string rightButtonText
    property string leftButtonText

    property int startX: 0
    property int startY: 0

    property QtObject sourceItem: null
    
    signal rightButtonClicked()
    signal leftButtonClicked()

    anchors.centerIn: applicationWindow().overlay
    parent: applicationWindow().overlay

    modal: true
    closePolicy: QQC2.Popup.NoAutoClose

    height: ConstValue.jingUnit * 14
    width: ConstValue.jingUnit * 25

    contentItem: Item {
        anchors.fill: parent

        Text {
            id: titleText

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: ConstValue.jingUnit * 2 - 4
            anchors.top: parent.top
            horizontalAlignment: Text.AlignHCenter 
            verticalAlignment: Text.AlignVCenter 
            
            width: parent.width - ConstValue.jingUnit
            height: ConstValue.jingUnit * 2 - 2
            font.pointSize: 22
            color: "#000000"
            text: dailog.title
        } 

        Text {
            anchors.top: titleText.bottom
            anchors.topMargin: ConstValue.jingUnit - 3
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter 
            verticalAlignment: Text.AlignVCenter 

            width: parent.width -  ConstValue.jingUnit
            font.pointSize: 17
            wrapMode: Text.WordWrap
            color: "#000000"
            text: dailog.text
        }

        Item {
            id: footer
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: ConstValue.jingUnit -3

            height: ConstValue.jingUnit * 2
            width: parent.width - ConstValue.jingUnit

            JButton{
                id: leftButton
                anchors.left : parent.left
                anchors.leftMargin: ConstValue.jingUnit
                anchors.bottom: parent.bottom

                width: ConstValue.jingUnit * 10.5
                height: ConstValue.jingUnit * 3.6

                backgroundColor: "#22767680"
                fontColor: "#000000" 
                font.pointSize: 22
                text: dailog.leftButtonText

                onClicked: dailog.leftButtonClicked()
            }

            JButton {
                id: rightButton
                anchors.right: parent.right
                anchors.rightMargin: ConstValue.jingUnit
                anchors.bottom: parent.bottom

                width: ConstValue.jingUnit * 10.5
                height: ConstValue.jingUnit * 3.6

                backgroundColor: "#22767680"
                fontColor: "#3C4BE8" 
                font.pointSize: 22
                text: dailog.rightButtonText

                onClicked: dailog.rightButtonClicked()
            }
        }
    }

    background: JBlurBackground{
        id: bkground

        width:parent.width
        height: parent.height
        sourceItem: applicationWindow().pageStack.currentItem
        backgroundColor:"#EDFFFFFF"
        
        blurRadius: 130
        radius: ConstValue.jingUnit 
    }

    onVisibleChanged:{
        var jx = contentItem.mapToItem(dailog.parent, dailog.x, dailog.y)
        bkground.startX = jx.x
        bkground.startY = jx.y
    }
}
