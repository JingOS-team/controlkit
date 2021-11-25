/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.2
import QtQuick.Controls 2.14 as QQC2
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.6
import org.kde.kirigami 2.15
import jingos.display 1.0
QQC2.Popup  {
    id: openmodeDialog
    property string title : i18nd("kirigami-controlkit", "Open mode")
    property alias model :  dataModel
    property real dp: Units.devicePixelRatio
    property int verticalAlignment : Qt.AlignBottom
    property var urls: []

    topPadding : JDisplay.dp(15)
    leftPadding: JDisplay.dp(25)
    rightPadding: JDisplay.dp(25)
    bottomPadding: JDisplay.dp(15)
    width : (appView.count <= 4 ? appView.count * JDisplay.dp(90) + openmodeDialog.rightPadding * 2 : 4 * JDisplay.dp(90) + openmodeDialog.rightPadding * 2)
    height: JDisplay.dp(160)

    x: Math.round( parent.width / 2 - width / 2 )
    y: Math.round( positionY() )


    function positionY(){
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

    background: JBlurBackground{
        id: bkground
        anchors.fill: parent
        sourceItem: openmodeDialog.parent
    }

    contentItem: Item {
        //anchors.fill: parent
        Text{
            id:titleText
            font.pointSize: JDisplay.sp(13)
            color: JTheme.majorForeground
            text:openmodeDialog.title
        }

        ListView{
            id:appView
            width: parent.width
            anchors.top: titleText.bottom
            anchors.topMargin: JDisplay.dp(15)
            anchors.bottom: parent.bottom
            orientation:ListView.Horizontal
            boundsBehavior:Flickable.StopAtBounds
            clip: true
            model:openmodeDialog.model
            delegate: Item {
                id: viewUnitItem
                width: JDisplay.dp(90)
                height:appView.height
                JIconButton{
                    id:iconBtn
                    anchors.horizontalCenter: parent.horizontalCenter
                    color:""
                    disableColor:""
                    source: model.icon
                    height: JDisplay.dp(50)
                    width: height
                    onClicked: {
                        const obj = dataModel.get(index)
                        Maui.KDE.openWithApp(obj.actionArgument, openmodeDialog.urls)
                        openmodeDialog.close()
                    }
                }

                Text {
                    anchors.top: iconBtn.bottom
                    anchors.topMargin: JDisplay.dp(5)
                    width: parent.width
                    elide:Text.ElideRight
                    wrapMode: Text.WordWrap
                    horizontalAlignment:Text.AlignHCenter
                    maximumLineCount: 2
                    font.pointSize: JDisplay.sp(8)
                    color: JTheme.majorForeground
                    text: model.label
                }
            }
            QQC2.ScrollBar.horizontal: QQC2.ScrollBar { policy: QQC2.ScrollBar.AlwaysOn}
        }
    }
}
