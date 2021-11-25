/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.2
import QtQuick.Controls 2.14 as QQC2
import org.kde.kirigami 2.0 as Kirigami
import org.kde.kirigami 2.15
import jingos.display 1.0
import "private"

Item  {
    id: control

    property string source: ""
    property var color: JTheme.iconForeground
    property var disableColor: JTheme.iconDisableForeground
    property var hoverColor: JTheme.hoverBackground
    property var pressColor: JTheme.pressBackground

    //define the image disable status url load path
    property string disableSource: ""
    property bool hoverEnabled: true
    property int  padding: JDisplay.dp(4)
    property int  iconRadius: Math.min(width, height)  / 2
    property var  backgroundColor: "transparent"
    property  alias containsMouse : mouseHover.containsMouse

    signal pressed(QtObject mouse)
    signal clicked(QtObject mouse)
    signal released(QtObject mouse)

    implicitHeight: Math.max(icon.height, icon.implicitHeight) + control.padding
    implicitWidth:  Math.max(icon.width, icon.implicitWidth) + control.padding

    PrivateMouseHover {
        id:mouseHover

        radius: iconRadius
        hoverColor: control.hoverColor
        pressColor: control.pressColor
        color:backgroundColor
        visible: control.hoverEnabled ? true : false
    }

    Kirigami.Icon {
        id:icon

        anchors.fill: parent
        anchors.margins: control.padding
        color: control.enabled ? control.color : control.disableColor
        source: control.enabled ? control.source : (control.disableSource.length > 0 ? control.disableSource: control.source)
    }
}
