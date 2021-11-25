/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQml 2.12
import jingos.display 1.0 

pragma Singleton

/**
 * A set of values to define semantically sizes and durations
 * @inherit QtQuick.QtObject
 */
QtObject {
    id: display
    property int fontSize: JDisplayMetrics.fontSize
    property string fontFamily: JDisplayMetrics.fontFamily
    property real fontScale: JDisplayMetrics.fontScale
    property real dpi: JDisplayMetrics.dpi
    property var fontFamilyModel: JDisplayMetrics.fontFamilyModel

    function sp(size){
        return dpi * fontScale * size;
    }

    function dp(size){
        return dpi * size;
    }

    function setSystemFont(famliy, size){
        JDisplayMetrics.setSystemFont(famliy, size);
    }
}
