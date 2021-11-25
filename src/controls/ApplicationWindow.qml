/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Lele Huan <huanlele@jingos.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.5
import "templates/private"
import org.kde.kirigami 2.4 as Kirigami
import QtGraphicalEffects 1.0
import QtQuick 2.14
import org.kde.kirigami 2.15 as Kirigami15

AbstractApplicationWindow {
    id: root
    property alias pageStack: __pageStack

    // whether is darkMode default is false
    property bool darkMode : false

    // whether is show fastBlur, default is false 
    property bool fastBlurMode : false

    // default value is 0.5
    property real fastBlurOpacity: 0.8 

    // default value is 0.5
    property real fastBlurRadius:  144

    // default value is "#F7F7F7"
    property color fastBlurColor: "#F7F7F7"

    //redefines here as here we can know a pointer to PageRow

    // we negate the canBeEnabled check because we don't want to factor in the automatic drawer provided by Kirigami for page actions for our calculations
    wideScreen: width >= (root.pageStack.defaultColumnWidth) + ((contextDrawer && !(contextDrawer instanceof Kirigami.ContextDrawer)) ? contextDrawer.width : 0) + (globalDrawer ? globalDrawer.width : 0)

    Component.onCompleted: {
        if (pageStack.currentItem) {
            pageStack.currentItem.forceActiveFocus()
        }
        Kirigami15.KeyEventHelper.setKeyEventObject(root);
    }

    background: Item {
        anchors.fill: parent
        visible: root.fastBlurMode

        /*
        Image{
            id:bgImg
            anchors.fill: parent
            source: "/usr/share/icons/jing/bgblur.png"  //TODO: read from settings
            visible: true
            smooth: true
        }
        */
        Rectangle {
            anchors.fill: parent
            color: root.fastBlurColor
            opacity: root.fastBlurOpacity
        }
    }

    Rectangle{
        anchors.fill: parent
        color: JTheme.background
    }

    Connections{
        target:Kirigami15.KeyEventHelper
        onBackKeyEvent:{
            __pageStack.goBack(false)
        }
    }

    PageRow {
        id: __pageStack
        globalToolBar.style: Kirigami.ApplicationHeaderStyle.Auto
        anchors {
            fill: parent
            //HACK: workaround a bug in android iOS keyboard management
            bottomMargin: ((Qt.platform.os == "android" || Qt.platform.os == "ios") || !Qt.inputMethod.visible) ? 0 : Qt.inputMethod.keyboardRectangle.height
            onBottomMarginChanged: {
                if (__pageStack.anchors.bottomMargin > 0) {
                    root.reachableMode = false;
                }
            }
        }
        //FIXME
        onCurrentIndexChanged: root.reachableMode = false;

        function goBack(exit = true) {
            //NOTE: drawers are handling the back button by themselves
            var backEvent = {accepted: false}
            if (root.pageStack.layers.depth > 1) {
                root.pageStack.layers.currentItem.backRequested(backEvent);
                if (!backEvent.accepted) {
                    root.pageStack.layers.pop();
                    backEvent.accepted = true;
                }
            } else {
                if(root.pageStack.currentItem != null && root.pageStack.currentItem.backRequested != undefined) {
                    root.pageStack.currentItem.backRequested(backEvent);
                    if (root.pageStack.currentIndex >= 1) {
                        if (!backEvent.accepted) {
                            root.pageStack.flickBack();
                            backEvent.accepted = true;
                        }
                    }
                }
            }

            if (Kirigami.Settings.isMobile && !backEvent.accepted && Qt.platform.os !== "ios" ) {
                if(exit)
                    Qt.quit();
                else
                    root.showMinimized();
            }
        }
        function goForward() {
            root.pageStack.currentIndex = Math.min(root.pageStack.depth-1, root.pageStack.currentIndex + 1);
        }

//        WheelHandler {
//            id: wheelHandler
//            property int distant : 0

//            //orientation:Qt.Horizontal
//            acceptedDevices:PointerDevice.AllPointerTypes
//            onWheel:{
//                wheelHandler.distant = wheelHandler.distant + event.angleDelta.x
//            }

//            onActiveChanged:{
//                console.log("222222222222222222   active is " + active + "  distant is " + wheelHandler.distant)
//                if(active == false)
//                {

//                    if (wheelHandler.distant > 0)
//                    {
//                        __pageStack.goBack(false)
//                    }
//                    wheelHandler.distant = 0
//                }
//            }
//        }

        Keys.onBackPressed: {
            goBack();
            event.accepted = true
        }
        Shortcut {
            sequence: "Forward"
            onActivated: __pageStack.goForward();
        }
        Shortcut {
            sequence: StandardKey.Forward
            onActivated: __pageStack.goForward();
        }
        Shortcut {
            sequence: StandardKey.Back
            onActivated: __pageStack.goBack();
        }

        focus: true
    }
}
