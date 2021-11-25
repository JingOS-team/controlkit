/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.2
import QtQuick.Controls 2.14 as QQC2
import QtQml 2.12
import org.kde.kirigami 2.0 as Kirigami
import org.kde.kirigami 2.15
import jingos.display 1.0
import "private"

Item  {
    id: control

    property string source: ""
    property string text: ""

    property bool fingerColdClose: false
    property bool isIcon: true
    property var color: JTheme.iconForeground
    property var disableColor: JTheme.iconDisableForeground
    property var hoverColor: JTheme.hoverBackground
    property var pressColor: JTheme.pressBackground

    property color backgroundColor: JTheme.buttonBackground

    property color labelBackgroundColor: backgroundColor

    property color borderColor: JTheme.buttonBorder
    property int borderWidth: 0

    property color fontColor: JTheme.buttonForeground
    property color disableFontColor: JTheme.disableForeground

    //define the image disable status url load path
    property string disableSource: ""
    property bool hoverEnabled: true
    property int  padding: JDisplay.dp(4)
    property int  radius: Math.min(width, height)  / 2
    // property var  backgroundColor: "transparent"
    property alias containsMouse: area.containsMouse

    signal pressed(QtObject mouse)
    signal clicked(QtObject mouse)
    signal released(QtObject mouse)

    implicitHeight: isIcon ? (Math.max(icon.height, icon.implicitHeight) + control.padding ): (Math.max(label.height, label.implicitHeight) + control.padding)
    implicitWidth: isIcon ? Math.max(icon.width, icon.implicitWidth) + control.padding : Math.max(label.width, label.implicitWidth) + control.padding

    Component.onCompleted: {
        iconText.imageWidth = control.width
        iconText.imageHeight = control. height
        iconText.labelWidth = iconText.imageWidth * 1.8
        iconText.labelHeight = iconText.imageHeight * 0.7
    }

    function reset() {
        control.fingerColdClose = false
        control.isIcon = true
    }

    onIsIconChanged: {
        if (!isIcon) {
            control.width = iconText.labelWidth
            control.height = iconText.labelHeight
            icon.visible = false
            label.visible = true
        } else {
            control.width = iconText.imageWidth
            control.height = iconText.imageHeight
            icon.visible = true
            label.visible = false
        }
    }

    Behavior on width {
         NumberAnimation { duration: 400; easing.type: Easing.OutQuart }
    }
    Behavior on x {
         NumberAnimation { duration: 400; easing.type: Easing.OutQuart }
    }
    Behavior on y {
         NumberAnimation { duration: 400; easing.type: Easing.OutQuart }
    }
    Behavior on height {
         NumberAnimation { duration: 400; easing.type: Easing.OutQuart }
    }

    Item {
        id: iconText

        property real labelWidth: 0
        property real labelHeight: 0
        property real imageWidth: 0
        property real imageHeight: 0

        anchors.fill: parent

        Rectangle {
            id: background

            property real moveX: 0
            property real moveY: 0
            anchors.fill: parent

            radius: control.radius
            color: control.backgroundColor

            Rectangle {
                id: back_item

                color:  area.pressed ? control.pressColor : control.hoverColor
                radius: parent.radius
                state: "hiden"
                states: [
                    State {
                        name: "shown"
                        PropertyChanges {
                            target: back_item
                            x: 0
                            y: 0
                            width: background.width
                            height: background.height
                            visible: true
                        }
                    },
                    State {
                        name: "hiden"
                        PropertyChanges {
                            target: back_item
                            x: background.moveX
                            y: background.moveY
                            width:  0
                            height: 0
                            visible: false
                        }
                    }
                ]

                transitions:[
                    Transition {
                        from:"hiden"; to:"shown"
                        SequentialAnimation {
                            PropertyAnimation { target: back_item; properties: "visible"; duration: 0; easing.type: Easing.OutQuart }
                            PropertyAnimation { target: back_item; properties: "x,y,width,height"; duration: 400; easing.type: Easing.OutQuart }
                        }
                    },
                    Transition {
                        from:"shown"; to:"hiden"
                        SequentialAnimation{
                            PropertyAnimation { target: back_item; properties: "x,y,width,height,"; duration: 200; easing.type: Easing.OutQuart }
                            PropertyAnimation { target: back_item; properties: "visible"; duration: 0; easing.type: Easing.OutQuart }
                        }
                    }
                ]
            }

            MouseArea {
                id:area

                anchors.fill:parent
                hoverEnabled: true

                onContainsMouseChanged: {
                    if (containsMouse) {
                        cursorShape = Qt.BlankCursor
                        back_item.x = area.mouseX
                        back_item.y = area.mouseY
                        back_item.state = "shown"
                        isIcon = false
                    } else {
                        cursorShape = Qt.ArrowCursor
                        background.moveX = area.mouseX
                        background.moveY = area.mouseY
                        back_item.state = "hiden"
                    }
                }

                onPressed: {
                   control.pressed(mouse)
                }

                onClicked: {
                    if (mouse.source !== Qt.MouseEventNotSynthesized) {
                        isIcon = false
                        if (fingerColdClose) {
                            control.clicked(mouse)
                        } else {
                            fingerColdClose = true
                        }
                    } else {
                        control.clicked(mouse)
                    }

                }
                onReleased: {
                    control.released(mouse)
                }
            }
        }

        Kirigami.Icon {
            id: icon

            anchors.fill: parent
            anchors.margins: control.padding
            color: control.enabled ? control.color : control.disableColor
            source: control.enabled ? control.source : (control.disableSource.length > 0 ? control.disableSource: control.source)
        }

        Label {
            id: label

            visible: false
            // width: Math.max(control.width, contentWidth)
            // height: Math.max(control.height, contentHeight)

            anchors.fill: parent

            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: control.text
            font.pixelSize: JDisplay.sp(14)
            color: control.enabled ? control.fontColor : control.disableFontColor
            background: Rectangle {
                color: labelBackgroundColor
                radius: control.radius
            }
        }
    }
}
