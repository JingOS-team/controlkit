/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.2
import QtQml 2.12
import org.kde.kirigami 2.5
import org.kde.kirigami 2.15
import jingos.display 1.0
import QtQuick.Controls 2.14 as QQC2
import "private"

QQC2.Button  {
    id: control

    display: QQC2.Button.TextOnly
    property int radius : JDisplay.dp(7)
    property color fontColor: JTheme.buttonForeground
    property color disableFontColor: JTheme.disableForeground
    property color backgroundColor:JTheme.buttonBackground
    property color hoverColor:JTheme.hoverBackground
    property color pressColor: JTheme.pressBackground

    property color borderColor: JTheme.buttonBorder
    property int borderWidth: 0

    signal pressed(QtObject mouse)
    signal clicked(QtObject mouse)
    signal released(QtObject mouse)

    padding: JDisplay.dp(2)
    horizontalPadding: padding + JDisplay.dp(6)
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: control.clicked(null)

    contentItem:Loader {
        id: contentLoader
        sourceComponent: {
            if(control.display === QQC2.Button.TextOnly){
                return textOnlyCom
            }
            if(control.display === QQC2.Button.IconOnly){
                return iconOnlyCom
            }
            if(control.display === QQC2.Button.TextUnderIcon){
                return iconTopCom
            }
            if(control.display === QQC2.Button.TextBesideIcon){
                return iconLeftCom
            }
            return textOnlyCom
        }
    }

    Component {
        id: textOnlyCom
        Item {
            implicitWidth : tipText.width
            implicitHeight: tipText.height
            Text{
                id:tipText
                anchors.centerIn: parent
                elide: Text.ElideRight
                color:control.enabled ?  control.fontColor : control.disableFontColor
                text: control.text
                font: control.font
            }
        }
    }

    Component {
        id: iconOnlyCom
        Item {
            implicitWidth : tipIcon.width
            implicitHeight: tipIcon.height
            Icon{
                id:tipIcon
                anchors.centerIn: parent
                width: control.icon.width
                height: control.icon.height
                source: control.icon.source
                color: control.icon.color != "" ? control.icon.color : (control.enabled ?  control.fontColor : control.disableFontColor)
            }
        }
    }

    Component{
        id: iconTopCom

        Item {
            implicitWidth : Math.max(tipIcon.width, tipText.width)
            implicitHeight: tipIcon.height + tipText.height + spacing
            Item {
                width: Math.max(tipIcon.width, tipText.width)
                height: tipIcon.height + tipText.height + spacing
                anchors.centerIn: parent
                Icon{
                    id: tipIcon

                    width: control.icon.width
                    height: control.icon.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: control.icon.source
                    color:  control.icon.color != "" ? control.icon.color : (control.enabled ?  control.fontColor : control.disableFontColor)
                }
                Text{
                    id: tipText

                    anchors.top: tipIcon.bottom
                    anchors.topMargin: control.spacing
                    anchors.horizontalCenter: parent.horizontalCenter
                    elide: Text.ElideRight
                    color:control.fontColor
                    text: control.text
                    font: control.font
                }
            }
        }
    }

    Component{
        id: iconLeftCom
        Item {
            implicitWidth : tipIcon.width + tipText.width + spacing
            implicitHeight: Math.max(tipIcon.height, tipText.height)
            Item {
                width: tipIcon.width + tipText.width + spacing
                height: Math.max(tipIcon.height, tipText.height)
                anchors.centerIn: parent
                Icon{
                    id: tipIcon

                    width: control.icon.width
                    height: control.icon.height
                    anchors.verticalCenter: parent.verticalCenter
                    source: control.icon.source
                    color:  control.icon.color != "" ? control.icon.color : (control.enabled ?  control.fontColor : control.disableFontColor)
                }
                Text{
                    id: tipText

                    anchors.left: tipIcon.right
                    anchors.leftMargin: control.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    color:control.fontColor
                    text: control.text
                    font: control.font
                }
            }
        }
    }

    background: PrivateMouseHover{
        id: background
        radius:control.radius
        border.color: control.borderColor
        border.width: control.borderWidth

        hoverColor: control.hoverColor
        pressColor: control.pressColor
        color: control.backgroundColor
    }
}
