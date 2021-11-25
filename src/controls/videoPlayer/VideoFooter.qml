/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 * SPDX-FileCopyrightText: 2021 Yu Jiashu <yujiashu@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQml 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls 2.5 as T
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.15 as Kirigami
import jingos.display 1.0

Item{
    id: root
    property bool seekFlag: false
    property alias progressBar: control
    property alias footerRow: footerRow
    property alias timeInfo: timeInfo
    property bool zoomIconVisible: false
    property real duration: 0.0
    property bool playStatus: true
    property alias  controlEnable: control.enabled

    signal playBtnClicked()
    signal seekValue(real value)
    signal sliderPress()
    signal zoomBtnClicked()
    signal  enterOrLeave(bool flag)


    height: JDisplay.dp(80)
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter

//    Kirigami.JBlurBackground {
//        id: titleBackground
//        anchors.fill:parent
//        showBgBoder:false
//        blurRadius: 130
//        radius: 0
//    }
    function setSliderValue(time) {
        if(!root.seekFlag) {
            control.value = time
        }
    }

    Rectangle {
        anchors.fill: parent
        color:Kirigami.JTheme.background
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            root.enterOrLeave(true)
        }

        onExited: {
            root.enterOrLeave(false)
        }
    }

    RowLayout {
        id: footerRow
        anchors.fill: parent

        Kirigami.JIconButton {
            Layout.preferredWidth: JDisplay.dp(30 + 10)
            Layout.preferredHeight: JDisplay.dp(30 + 10)
            source: root.playStatus ? Qt.resolvedUrl("../image/videoImage/audio_play.svg") :
                                      Qt.resolvedUrl("../image/videoImage/audio_pause.svg")
            Layout.alignment: Qt.AlignVCenter |Qt.AlignLeft
            Layout.leftMargin: JDisplay.dp(35)

            onClicked: {
                //root.playStatus = !root.playStatus
                root.playBtnClicked()
            }
        }

        Label {
            id: postionstimeInfo

            text: positionTimeInfoTextMetrics.text
            font.pointSize: positionTimeInfoTextMetrics.font.pointSize
            horizontalAlignment: Qt.AlignHCenter
            Layout.leftMargin: JDisplay.dp(45)
            Layout.preferredWidth: JDisplay.dp(86)
            color: Kirigami.JTheme.majorForeground

            TextMetrics {
                id: positionTimeInfoTextMetrics
                text: Kirigami.JMediaSetTool.formatTime(control.value)
                font.pointSize: JDisplay.sp(11)
            }
        }

        Slider {
            id: control

            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: JDisplay.dp(13)
            Layout.rightMargin: JDisplay.dp(13)
            Layout.fillWidth: true

            implicitWidth: JDisplay.dp(800)//1024
            implicitHeight: JDisplay.dp(10 + 30)
            leftPadding: 0
            rightPadding: 0

            from: 0
            to: root.duration
            stepSize: 0.01

            onToChanged: control.value = 0//mpvVideo.duration
            focusPolicy: Qt.NoFocus

            onPressedChanged: {
                if(pressed) {
                    root.seekFlag = true
                } else {
                    root.seekValue(control.value)
                    root.seekFlag = false
                }
                root.sliderPress()
            }

            Keys.onPressed: {
                event.accepted = false
            }

            handle: Rectangle {
                id: handleRect
                visible: true
                x: leftPadding + control.visualPosition * (control.availableWidth - width)
                y: control.topPadding + control.availableHeight / 2 - height / 2

                width: JDisplay.dp(23)
                height: JDisplay.dp(20)
                anchors.verticalCenter:parent.verticalCenter
                color:"#FFFFFFFF"
                radius: JDisplay.dp(6)
            }
            DropShadow {
                anchors.fill: handleRect
                horizontalOffset: 0
                radius: 12.0
                samples: 16
                cached: true
                spread: 0.3
                color: Qt.rgba(0, 0, 0, 0.1)
                source: handleRect
                visible: true
            }

            background: Rectangle {
                id: progressBarBackground

                x: control.leftPadding
                y: control.topPadding + control.availableHeight / 2 - height / 2
                width: control.availableWidth
                height: JDisplay.dp(5)
                color: "#2E3C3C43"
                radius: JDisplay.dp(2)
                anchors.verticalCenter:parent.verticalCenter

                Rectangle {
                    width: control.visualPosition * parent.width
                    height: JDisplay.dp(5)
                    radius: JDisplay.dp(2)
                    color: "#FF3C4BE8"
                }
            }

        }

        Label {
            id: timeInfo
            color: Kirigami.JTheme.majorForeground
            text: timeInfoTextMetrics.text
            font.pointSize: timeInfoTextMetrics.font.pointSize
            horizontalAlignment: Qt.AlignHCenter
            Layout.leftMargin: JDisplay.dp(10)
            Layout.preferredWidth: JDisplay.dp(86)

            TextMetrics {
                id: timeInfoTextMetrics
                text: Kirigami.JMediaSetTool.formatTime(root.duration)
                font.pointSize: JDisplay.sp(11)
            }

            ToolTip {
                visible: timeInfoMouseArea.containsMouse
                timeout: -1
            }
            MouseArea {
                id: timeInfoMouseArea
                anchors.fill: parent
                hoverEnabled: false
            }
        }

        Kirigami.JIconButton {
            width: JDisplay.dp(30 + 10)
            height: width
            visible: false
            source: Qt.resolvedUrl("../image/videoImage/video_zoom.svg")
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.leftMargin: JDisplay.dp(15)
            onClicked: {
                root.zoomBtnClicked()
            }
        }

        Rectangle {
            id: marginArea
            width: JDisplay.dp(50)
        }
    }
}
