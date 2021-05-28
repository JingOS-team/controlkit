
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
import org.kde.kirigami 2.15
import QtGraphicalEffects 1.0

Item{
    id: blurBackground

    property var sourceItem: null


    property real blurRadius: 144  //default blur radius
    property real radius: ConstValue.jingUnit
    property color backgroundColor : "#EDFFFFFF"  //default bg color

    property bool showBgCover: true
    property bool showBgBoder: true

    onWidthChanged: {
        console.log("onWidthChanged blurback ground w is " + blurBackground.width + "  h is " + blurBackground.height)
        delayTimer.start();
    }
    onHeightChanged: {
        console.log("onHeightChanged blurback ground w is " + blurBackground.width + "  h is " + blurBackground.height)
        delayTimer.start();
    }

    Timer{
        id:delayTimer
        interval: 10
        repeat: false
        onTriggered: {
            resetBg();
        }
    }

    onVisibleChanged: {
        if(visible === false){
            blurLoader.active =false;
        } else {
            console.log("blur back ground  visibile is true")
            delayTimer.start()
        }
    }

    function resetBg(){
        if(blurBackground.visible === true && blurBackground.sourceItem && blurBackground.width > 0 && blurBackground.height > 0){
            console.log("show blur item effectsource")
            blurLoader.active = true;
        } else {
            console.log("blubackground visible is " + blurBackground.visible + " sourceItem is " + blurBackground.sourceItem
                        +"  w is " + blurBackground.width + "  h is " + blurBackground.height + " not show effectsource")
            blurLoader.active = false;
        }

        //            var jx = eff.mapToItem(blurBackground.sourceItem, 0, 0);
        //            //console.log("reset bg " + jx.x + "  " + jx.y + " w is " + blurBackground.width + "  h is " + blurBackground.height)
        //            eff.sourceRect = Qt.rect(jx.x, jx.y, blurBackground.width, blurBackground.height)
        //            eff.live = true;
        //        } else {
        //            console.log("blubackground visible is " + blurBackground.visible + " sourceItem is " + blurBackground.sourceItem
        //                        +"  w is " + blurBackground.width + "  h is " + blurBackground.height + " not show effectsource")
        //            eff.live = false;
        //        }
    }

    Loader{
        id:blurLoader
        anchors.fill: parent
        active: false
        sourceComponent:bkblurCom
    }

    Component{
        id:bkblurCom
        Item{
            ShaderEffectSource{
                id:eff
                anchors.fill: parent
                sourceItem: blurBackground.sourceItem
                sourceRect: {
                    var jx = eff.mapToItem(blurBackground.sourceItem, 0, 0);
                    Qt.rect(jx.x, jx.y, blurBackground.width, blurBackground.height)
                }
                visible: false
            }

            FastBlur{
                id:fastBlur
                anchors.fill: parent
                source: eff
                radius: blurBackground.blurRadius
                cached: false
                visible:false
            }

            Rectangle{
                id: maskRect
                anchors.fill: parent
                color: blurBackground.backgroundColor
                radius: blurBackground.radius
                visible: false
            }

            OpacityMask{
                id:mask
                anchors.fill: maskRect
                source: fastBlur
                maskSource: maskRect
            }

            DropShadow {
                anchors.fill: mask
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12.0
                samples: 24
                cached: true
                color: Qt.rgba(0, 0, 0, 0.1)
                source: mask
                visible: true
            }
        }
    }


    Rectangle{
        anchors.fill: parent
        visible: blurBackground.showBgCover
        color: blurBackground.sourceItem ? Qt.rgba(1, 1, 1, 0.6) : Qt.rgba(1, 1, 1, 1)
        radius: blurBackground.radius
        border.color: Qt.rgba(0, 0, 0, 0.1)
        border.width : blurBackground.showBgBoder ? 1 : 0
    }
}
