/*
 *   Copyright 2016 Marco Martin <mart@kde.org>
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
import QtQuick 2.5
import QtQuick.Controls 2.0 
import org.kde.kirigami 2.2

MouseArea {
    id: root
    default property Item contentItem
    property Flickable flickableItem

    //TODO: horizontalScrollBarPolicy is completely noop just for compatibility right now
    property int horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
    property int verticalScrollBarPolicy: Qt.ScrollBarAsNeeded

    readonly property Item verticalScrollBar: flickableItem.ScrollBar.vertical ? flickableItem.ScrollBar.vertical : null

    onVerticalScrollBarPolicyChanged: {
        flickableItem.ScrollBar.vertical.visible = verticalScrollBarPolicy == Qt.ScrollBarAlwaysOff
    }

    drag.filterChildren: !Settings.isMobile
    onPressed: {
        mouse.accepted = false;
        flickableItem.interactive = true;
    }
    onReleased:  {
        mouse.accepted = false;
        flickableItem.interactive = false;
    }
    onWheel: {
        flickableItem.interactive = false;
        if (Settings.isMobile || flickableItem.contentHeight<flickableItem.height) {
            return;
        }
        var y = wheel.pixelDelta.y != 0 ? wheel.pixelDelta.y : wheel.angleDelta.y / 8;

        //if we don't have a pixeldelta, apply the configured mouse wheel lines
        if (!wheel.pixelDelta.y) {
            y *= Settings.mouseWheelScrollLines;
        }

        // Scroll one page regardless of delta:
        if ((wheel.modifiers & Qt.ControlModifier) || (wheel.modifiers & Qt.ShiftModifier)) {
            if (y > 0) {
                y = flickableItem.height;
            } else if (y < 0) {
                y = -flickableItem.height;
            }
        }

        var minYExtent = flickableItem.topMargin - flickableItem.originY;
        var maxYExtent = flickableItem.height - (flickableItem.contentHeight + flickableItem.bottomMargin + flickableItem.originY);

        flickableItem.contentY = Math.min(-maxYExtent, Math.max(-minYExtent, flickableItem.contentY - y));

        //this is just for making the scrollbar appear
        flickableItem.flick(0, 0);
        flickableItem.cancelFlick();
    }
    Connections {
        target: flickableItem
        onFlickEnded: flickableItem.interactive = false;
        onMovementEnded: flickableItem.interactive = false;
    }

    onContentItemChanged: {
        if (contentItem.hasOwnProperty("contentY")) {
            flickableItem = contentItem;
            if (typeof(flickableItem.keyNavigationEnabled) != "undefined") {
                flickableItem.keyNavigationEnabled = true;
                flickableItem.keyNavigationWraps = true;
            }
            contentItem.parent = flickableParent;
        } else {
            flickableItem = flickableComponent.createObject(flickableParent);
            contentItem.parent = flickableItem.contentItem;
        }
        //TODO: find a way to make flicking work on laptops with touch screen
        flickableItem.interactive = Settings.isMobile;
        flickableItem.anchors.fill = flickableParent;
        flickableItem.ScrollBar.vertical = scrollComponent.createObject(root);
    }

    MultiPointTouchArea {
        id: flickableParent
        anchors {
            fill: parent
        }
        clip: true
        mouseEnabled: false
        maximumTouchPoints: 1
        property bool touchPressed: false
        onPressed: {
            touchPressed = true;
            flickableItem.interactive = true;
        }
        onReleased: touchPressed = false;
        onCanceled: touchPressed = false;
    }
    Component {
        id: flickableComponent
        Flickable {
            anchors {
                fill: parent
            }
            contentWidth: root.contentItem ? root.contentItem.width : 0
            contentHeight: root.contentItem ? root.contentItem.height : 0
        }
    }
    Component {
        id: scrollComponent
        ScrollBar {
            z: flickableParent.z + 1
            visible: root.contentItem.visible && size < 1

            //NOTE: use this instead of anchors as crashes on some Qt 5.8 checkouts
            height: parent.height - anchors.topMargin
            anchors {
                topMargin: parent.flickableItem.headerItem ? parent.flickableItem.headerItem.height : 0
                right: parent.right
                top: parent.top
            }
        }
    }
}
