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
//import QtQuick.Controls 1.3 as Controls
import QtQuick.Controls 2.0 

Item {
    id: root
    default property Item contentItem
    property Flickable flickableItem

    //TODO: horizontalScrollBarPolicy is completely noop just for compatibility right now
    property int horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
    property int verticalScrollBarPolicy: Qt.ScrollBarAsNeeded

    clip: true

    onVerticalScrollBarPolicyChanged: {
        flickableItem.ScrollBar.vertical.visible = verticalScrollBarPolicy == Qt.ScrollBarAlwaysOff
    }

    onContentItemChanged: {
        if (contentItem.hasOwnProperty("contentY")) {
            flickableItem = contentItem;
            contentItem.parent = root;
        } else {
            flickableItem = flickableComponent.createObject(root);
            contentItem.parent = flickableItem.contentItem;
        }
        flickableItem.anchors.fill = root;
        flickableItem.ScrollBar.vertical = scrollComponent.createObject(root);
    }
    Binding {
        target: flickableItem
        property: "contentHeight"
        when: contentItem !== flickableItem
        value: contentItem ? contentItem.height : 0
    }

    Binding {
        target: flickableItem
        when: contentItem !== flickableItem
        property: "contentWidth"
        value: contentItem ? contentItem.width : 0
    }
    Component {
        id: flickableComponent
        Flickable {
            anchors {
                fill: parent
            }
        }
    }
    Component {
        id: scrollComponent
        ScrollBar { }
    }
}
