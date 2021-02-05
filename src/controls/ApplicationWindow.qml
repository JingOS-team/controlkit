/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2020 Rui Wang <wangrui@jingos.com>
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.5
import "templates/private"
import org.kde.kirigami 2.4 as Kirigami
import QtGraphicalEffects 1.0
import QtQuick 2.14
import org.kde.kirigami 2.15 as Kirigami15

/**
 * A window that provides some basic features needed for all apps
 *
 * It's usually used as a root QML component for the application.
 * It's based around the PageRow component, the application will be
 * about pages adding and removal.
 * For most of the usages, this class should be used instead
 * of AbstractApplicationWidnow
 * @see AbstractApplicationWidnow
 *
 * Example usage:
 * @code
 * import org.kde.kirigami 2.4 as Kirigami
 *
 * Kirigami.ApplicationWindow {
 *  [...]
 *     globalDrawer: Kirigami.GlobalDrawer {
 *         actions: [
 *            Kirigami.Action {
 *                text: "View"
 *                iconName: "view-list-icons"
 *                Kirigami.Action {
 *                        text: "action 1"
 *                }
 *                Kirigami.Action {
 *                        text: "action 2"
 *                }
 *                Kirigami.Action {
 *                        text: "action 3"
 *                }
 *            },
 *            Kirigami.Action {
 *                text: "Sync"
 *                iconName: "folder-sync"
 *            }
 *         ]
 *     }
 *
 *     contextDrawer: Kirigami.ContextDrawer {
 *         id: contextDrawer
 *     }
 *
 *     pageStack.initialPage: Kirigami.Page {
 *         mainAction: Kirigami.Action {
 *             iconName: "edit"
 *             onTriggered: {
 *                 // do stuff
 *             }
 *         }
 *         contextualActions: [
 *             Kirigami.Action {
 *                 iconName: "edit"
 *                 text: "Action text"
 *                 onTriggered: {
 *                     // do stuff
 *                 }
 *             },
 *             Kirigami.Action {
 *                 iconName: "edit"
 *                 text: "Action text"
 *                 onTriggered: {
 *                     // do stuff
 *                 }
 *             }
 *         ]
 *       [...]
 *     }
 *  [...]
 * }
 * @endcode
 *
*/
AbstractApplicationWindow {
    id: root

    /**
     * pageStack: StackView
     * Readonly.
     * The stack used to allocate the pages and to manage the transitions
     * between them.
     * It's using a PageRow, while having the same API as PageStack,
     * it positions the pages as adjacent columns, with as many columns
     * as can fit in the screen. An handheld device would usually have a single
     * fullscreen column, a tablet device would have many tiled columns.
     */
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
    wideScreen: width >= applicationWindow().pageStack.defaultColumnWidth * 1.5

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

    Connections{
        target:Kirigami15.KeyEventHelper
        onBackKeyEvent:{
            __pageStack.goBack(false)
        }
    }

    PageRow {
        id: __pageStack
        objectName: "rootPageRow"
        anchors {
            bottom: parent.bottom
            top: parent.top
            //HACK: workaround a bug in android iOS keyboard management
            bottomMargin: ((Qt.platform.os == "android" || Qt.platform.os == "ios") || !Qt.inputMethod.visible) ? 0 : Qt.inputMethod.keyboardRectangle.height
            onBottomMarginChanged: {
                if (__pageStack.anchors.bottomMargin > 0) {
                    root.reachableMode = false;
                }
            }
        }

        globalToolBar.style: Kirigami.ApplicationHeaderStyle.Auto
        width: parent.width

        focus: true
        function applicationWindow(){
            return root.applicationWindow();
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

        WheelHandler {
            id: wheelHandler
            property int distant : 0

            orientation:Qt.Horizontal 
            acceptedDevices:PointerDevice.AllPointerTypes
            
            onWheel:{
                wheelHandler.distant = wheelHandler.distant + event.angleDelta.x 
            }

            onActiveChanged:{
                if(active == false)
                {
                    if (wheelHandler.distant > 0)
                    {
                        __pageStack.goBack(false)
                    }
                    wheelHandler.distant = 0
                }
            }
        }
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
    }
}
