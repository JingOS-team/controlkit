/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Controls.Private 1.0
import "private"
import org.kde.kirigami 1.0
import QtGraphicalEffects 1.0

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
 * import org.kde.kirigami 1.0 as Kirigami
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

   /**
    * header: AbstractApplicationHeader
    * An item that can be used as a title for the application.
    * Scrolling the main page will make it taller or shorter (trough the point of going away)
    * It's a behavior similar to the typical mobile web browser adressbar
    * the minimum, preferred and maximum heights of the item can be controlled with
    * * Layout.minimumHeight: default is 0, i.e. hidden
    * * Layout.preferredHeight: default is Units.gridUnit * 1.6
    * * Layout.maximumHeight: default is Units.gridUnit * 3
    *
    * To achieve a titlebar that stays completely fixed just set the 3 sizes as the same
    */
   //FIXME: this should become an actual ApplicationHeader
    property var header: undefined

    /**
     * controlsVisible: bool
     * This property controls wether the standard chrome of the app, such
     * as the Action button, the drawer handles and the application
     * header should be visible or not.
     */
    property bool controlsVisible: true


    MouseArea {
        anchors.fill: parent
        onClicked: overscroll.y = 0
        Rectangle {
            anchors.fill: parent
            color: Theme.complementaryBackgroundColor
            opacity: 0.15
        }
    }

    PageRow {
        id: __pageStack
        anchors {
            fill: parent
            //HACK: workaround a bug in android iOS keyboard management
            bottomMargin: ((Qt.platform.os == "android" || Qt.platform.os == "ios") || !Qt.inputMethod.visible) ? 0 : Qt.inputMethod.keyboardRectangle.height
            onBottomMarginChanged: {
                if (bottomMargin > 0) {
                    overscroll.y = 0;
                }
            }
        }
        onCurrentIndexChanged: overscroll.y = 0;

        function goBack() {
            if (root.contextDrawer && root.contextDrawer.opened) {
                root.contextDrawer.close();
            } else if (root.globalDrawer && root.globalDrawer.opened) {
                root.globalDrawer.close();
            } else {
                var backEvent = {accepted: false}
                if (root.pageStack.currentIndex >= 1) {
                    root.pageStack.currentItem.backRequested(backEvent);
                    if (!backEvent.accepted) {
                        if (root.pageStack.depth > 1) {
                            root.pageStack.currentIndex = Math.max(0, root.pageStack.currentIndex - 1);
                            backEvent.accepted = true;
                        }
                    }
                }

                if (Settings.isMobile && !backEvent.accepted) {
                    Qt.quit();
                }
            }
        }
        Keys.onReleased: {
            if (event.key == Qt.Key_Back ||
            (event.key === Qt.Key_Left && (event.modifiers & Qt.AltModifier))) {
                event.accepted = true;
                goBack();
            }
        }

        Rectangle {
            z: -1
            anchors.fill: parent
            color: Theme.backgroundColor
        }
        //Don't want overscroll in landscape mode
        onWidthChanged: {
            if (width > height) {
                overscroll.y = 0;
            }
        }

        transform: Translate {
            id: overscroll
            Behavior on y {
                NumberAnimation {
                    duration: Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
        focus: true
    }

    Component.onCompleted: {
        if (root.header === undefined) {
            var component = Qt.createComponent(Qt.resolvedUrl("./ApplicationHeader.qml"));
            root.header = component.createObject(root);
        }
    }
}
