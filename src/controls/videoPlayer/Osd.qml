/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 * SPDX-FileCopyrightText: 2021 Yu Jiashu <yujiashu@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls 2.5
import jingos.display 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.15 as Kirigami

Rectangle {
    id: volumeOrBrightArea

    property int vob: 0
    property int maxBrightness: 0
    property int brightnessValue
    property int  volume: 0
    property int oldBrightNessValue
    property int whoolHeight: JDisplay.dp(648)

    signal initMediaSetVolume()

    width: JDisplay.dp(169)
    height: JDisplay.dp(48)
    radius: JDisplay.dp(12)
    visible: false
    anchors.centerIn: parent
    color: "#99000000"


    function setBrightness( brightnessValue ) {
        var service = pmSource.serviceForSource("PowerDevil")
        var operation = service.operationDescription("setBrightness")
        operation.brightness = brightnessValue <= 8 ? 8 : brightnessValue;
        operation.silent = true
        service.startOperationCall(operation)
    }

    function dealBrightness(distanceY) {
        volumeOrBrightArea.visible = true
        volumeOrBrightArea.vob = 2
        var newBrightness = distanceY / volumeOrBrightArea.whoolHeight * volumeOrBrightArea.maxBrightness
        var tempBrightness=newBrightness.toString().split(".");

        if(parseInt(tempBrightness[1]) > 5) {
            if(newBrightness > 0)
                newBrightness += 1
            else
                newBrightness -= 1
        }
        newBrightness += volumeOrBrightArea.brightnessValue

        if (newBrightness < 0) {
            newBrightness = 0
        } else if (newBrightness > volumeOrBrightArea.maxBrightness) {
            newBrightness = volumeOrBrightArea.maxBrightness
        }
        volumeOrBrightArea.brightnessValue = newBrightness
        mouseEventTimer.restart()
        hideOsdTimer.restart()
    }

    function dealVolume(distanceY) {
        volumeOrBrightArea.visible = true
        volumeOrBrightArea.vob = 1

        var newVolume = distanceY / volumeOrBrightArea.whoolHeight * 100
        var tempValue=newVolume.toString().split(".");

        if(parseInt(tempValue[1]) > 5) {
            if(newVolume>0)
                newVolume += 1
            else
                newVolume-=1
        }
        newVolume += volumeOrBrightArea.volume
        if(newVolume < 0) {
            newVolume = 0
        } else if(newVolume > 100) {
            newVolume = 100
        }
        volumeOrBrightArea.volume = newVolume
        hideOsdTimer.restart()
    }

    Component.onCompleted: {
        volumeOrBrightArea.volume = Kirigami.JMediaSetTool.readVolume()
        volumeOrBrightArea.initMediaSetVolume()
    }

    Component.onDestruction: {
        Kirigami.JMediaSetTool.writeVolume(volumeOrBrightArea.volume)
    }

    Timer {
        id: mouseEventTimer
        interval: 200
        running: false
        repeat: false
        onTriggered: volumeOrBrightArea.setBrightness(volumeOrBrightArea.brightnessValue)
    }

    Timer {
        id: hideOsdTimer
        interval: 200
        running: false
        repeat: false
        onTriggered: volumeOrBrightArea.visible = false
    }


    Image {
        id:vobImage
        width: JDisplay.dp(22)
        height: JDisplay.dp(22)
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: JDisplay.dp(13)
        source: {
            if(volumeOrBrightArea.vob == 1) {
                if( volumeOrBrightArea.volume === 0) {
                    Qt.resolvedUrl("../image/videoImage/vol_silent.png")
                } else if(volumeOrBrightArea.volume > 0 && volumeOrBrightArea.volume < 50) {
                     Qt.resolvedUrl("../image/videoImage/vol_low.png")
                } else if(volumeOrBrightArea.volume > 50) {
                     Qt.resolvedUrl("../image/videoImage/vol_mid.png")
                }
            } else {
                 Qt.resolvedUrl("../image/videoImage/bri.png")
            }
        }
    }

    Slider {
        id: progressBar
        width: JDisplay.dp(113)
        z: parent.z + 1
        from:0
        to: volumeOrBrightArea.vob == 2 ? maxBrightness : 100
        value: volumeOrBrightArea.vob == 1 ? volumeOrBrightArea.volume : volumeOrBrightArea.brightnessValue
        spacing: 0
        focus: true
        enabled: false
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: vobImage.right
        anchors.leftMargin: JDisplay.dp(13)

        background: Rectangle {
            id: rect1
            width: progressBar.availableWidth
            height: JDisplay.dp(4)
            color: "#4DEBEBF5"
            radius: JDisplay.dp(2)
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: rect2
                width: progressBar.visualPosition * parent.width
                height: JDisplay.dp(4)
                color: "#FFFFFFFF"
                radius: (2)
            }
        }
        handle: Item {}
    }

    PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["PowerDevil"]
        onSourceAdded: {
            if (source === "PowerDevil") {
                disconnectSource(source)
                connectSource(source)
            }
        }

        onDataChanged: {
            if(volumeOrBrightArea.maxBrightness == 0){
                volumeOrBrightArea.maxBrightness = pmSource.data["PowerDevil"] ? pmSource.data["PowerDevil"]["Maximum Screen Brightness"] || 0 : 7500
            }
            if(!mouseEventTimer.running)
                volumeOrBrightArea.brightnessValue = pmSource.data["PowerDevil"]["Screen Brightness"]
        }
    }
}
