/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.4

pragma Singleton

QtObject {
    id: constValue

    property int mouseWidth: 25
    property int mouseHight: 25

    property color hoverColor: "#767680"
    property color pressColor: "#787880"

    property color darkHoverColor: "#EBEBF5"
    property color darkPressColor: "#EBEBF5"
    property real opacity

    property real opacityMinimum: 0.7
    property real opacityMaxmum: 0.9

    property real radius: 15
    property int jingUnit: 18
}
