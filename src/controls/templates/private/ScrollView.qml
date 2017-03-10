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
import org.kde.kirigami 2.0

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
    onWheel: {
        if (Settings.isMobile || flickableItem.contentHeight<flickableItem.height) {
            return;
        }
        //TODO: config of how many lines the wheel scrolls
        var y = wheel.pixelDelta.y != 0 ? wheel.pixelDelta.y : (wheel.angleDelta.y > 0 ? Units.gridUnit : -Units.gridUnit)

        flickableItem.contentY = Math.min(Math.max(flickableItem.headerItem ? -flickableItem.headerItem.height : 0, flickableItem.contentY - y), Math.max(0, flickableItem.contentHeight - flickableItem.height));
        //this is just for making the scrollbar appear
        flickableItem.flick(0, 0);
        cancelFlickStateTimer.restart();
    }

    Timer {
        id: cancelFlickStateTimer
        interval: 150
        onTriggered: flickableItem.cancelFlick()
    }
    onContentItemChanged: {
        if (contentItem.hasOwnProperty("contentY")) {
            flickableItem = contentItem;
            contentItem.parent = flickableParent;
        } else {
            flickableItem = flickableComponent.createObject(flickableParent);
            contentItem.parent = flickableItem.contentItem;
        }
        //TODO: find a way to make flicking work on laptops with touch screen
        flickableItem.interactive = Settings.isMobile;
        flickableItem.anchors.fill = flickableParent;
        flickableItem.ScrollBar.vertical = scrollComponent.createObject(root);
        flickableItem.ScrollBar.vertical.anchors.right = root.right
        flickableItem.ScrollBar.vertical.anchors.top = root.top
        //flickableItem.ScrollBar.vertical.anchors.bottom = root.bottom
    }

    //NOTE: use this instead of anchors as crashes on some Qt 5.8 checkouts
    onHeightChanged: flickableItem.ScrollBar.vertical.height = root.height
    Item {
        id: flickableParent
        anchors {
            fill: parent
        }
        clip: true
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
        ScrollBar { }
    }
}
