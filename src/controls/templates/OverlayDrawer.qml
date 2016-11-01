/*
 *   Copyright 2012 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

import QtQuick 2.1
import QtQuick.Templates 2.0 as T2
import org.kde.kirigami 1.0
import "private"

/**
 * Overlay Drawers are used to expose additional UI elements needed for
 * small secondary tasks for which the main UI elements are not needed.
 * For example in Okular Active, an Overlay Drawer is used to display
 * thumbnails of all pages within a document along with a search field.
 * This is used for the distinct task of navigating to another page.
 *
 */
AbstractDrawer {
    id: root

    z: modal ? (opened ? 100 : 99 ): 98

    //default paddings
    leftPadding: Units.smallSpacing
    topPadding: Units.smallSpacing
    rightPadding: Units.smallSpacing
    bottomPadding: Units.smallSpacing

//BEGIN Properties
    /**
     * handleVisible: bool
     * If true, a little handle will be visible to make opening the drawer easier
     * Currently supported only on left and right drawers
     */
    property bool handleVisible: typeof(applicationWindow)===typeof(Function) && applicationWindow() ? applicationWindow().controlsVisible : true

    /**
     * handle: Item
     * Readonly property that points to the item that will act as a physical
     * handle for the Drawer
     **/
    readonly property Item handle: MouseArea {
        id: drawerHandle
        z: 2000000
        preventStealing: true
        parent: applicationWindow().overlay.parent

        property int startX
        property int mappedStartX
        onPressed: {
            root.peeking = true;
            startX = mouse.x;
            mappedStartX = mapToItem(parent, startX, 0).x
        }
        onPositionChanged: {
            var pos = mapToItem(parent, mouse.x - startX, mouse.y);
            switch(root.edge) {
            case Qt.LeftEdge:
                root.position = pos.x/root.contentItem.width;
                break;
            case Qt.RightEdge:
                root.position = (root.parent.width - pos.x - width)/root.contentItem.width;
                break;
            default:
            }
        }
        onReleased: {
            root.peeking = false;
            
            if (Math.abs(mapToItem(parent, mouse.x, 0).x - mappedStartX) < Qt.styleHints.startDragDistance) {
                root.opened = !root.opened;
            }
        }
        onCanceled: {
            root.peeking = false
        }
        x: {
            switch(root.edge) {
            case Qt.LeftEdge:
                return root.background.width * root.position;
            case Qt.RightEdge:
                return drawerHandle.parent.width - (root.background.width * root.position) - width;
            default:
                return 0;
            }
        }

        anchors.bottom: parent.bottom
        visible: root.enabled && (root.edge == Qt.LeftEdge || root.edge == Qt.RightEdge)
        width: Units.iconSizes.medium + Units.smallSpacing * 2
        height: width
        opacity: root.handleVisible ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        transform: Translate {
            id: translateTransform
            x: root.handleVisible ? 0 : (root.edge == Qt.LeftEdge ? -drawerHandle.width : drawerHandle.width)
            Behavior on x {
                NumberAnimation {
                    duration: Units.longDuration
                    easing.type: !root.handleVisible ? Easing.OutQuad : Easing.InQuad
                }
            }
        }
    }

//END Properties
}
