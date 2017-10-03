/*
*   Copyright (C) 2016 by Marco Martin <mart@kde.org>
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
*   51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
*/

import QtQuick 2.5
import org.kde.kirigami 2.2
import QtGraphicalEffects 1.0
import QtQuick.Templates 2.0 as T2
import "private"

/**
 * An overlay sheet that covers the current Page content.
 * Its contents can be scrolled up or down, scrolling all the way up or
 * all the way down, dismisses it.
 * Use this for big, modal dialogs or information display, that can't be
 * logically done as a new separate Page, even if potentially
 * are taller than the screen space.
 * @inherits: QtQuick.QtObject
 */
QtObject {
    id: root

    Theme.colorSet: Theme.View
    Theme.inherit: false

    /**
     * contentItem: Item
     * This property holds the visual content item.
     *
     * Note: The content item is automatically resized inside the
     * padding of the control.
     */
    default property Item contentItem

    /**
     * sheetOpen: bool
     * If true the sheet is open showing the contents of the OverlaySheet
     * component.
     */
    property bool sheetOpen

    /**
     * leftPadding: int
     * default contents padding at left
     */
    property int leftPadding: Units.gridUnit

    /**
     * topPadding: int
     * default contents padding at top
     */
    property int topPadding: Units.gridUnit

    /**
     * rightPadding: int
     * default contents padding at right
     */
    property int rightPadding: Units.gridUnit

    /**
     * bottomPadding: int
     * default contents padding at bottom
     */
    property int bottomPadding: Units.gridUnit

    /**
     * background: Item
     * This property holds the background item.
     *
     * Note: If the background item has no explicit size specified,
     * it automatically follows the control's size.
     * In most cases, there is no need to specify width or
     * height for a background item.
     */
    property Item background

    property Item parent


    function open() {
        mainItem.visible = true;
        openAnimation.from = -mainItem.height;
        openAnimation.to = openAnimation.topOpenPosition;
        openAnimation.running = true;
        root.sheetOpen = true;
    }

    function close() {
        if (scrollView.flickableItem.contentY < 0) {
            closeAnimation.to = -height;
        } else {
            closeAnimation.to = scrollView.flickableItem.contentHeight;
        }
        closeAnimation.running = true;
    }

    
    onBackgroundChanged: {
        background.parent = flickableContents;
        background.z = -1;
    }
    onContentItemChanged: {
        if (contentItem.hasOwnProperty("contentY") && // Check if flickable
            contentItem.hasOwnProperty("contentHeight")) {
            contentItem.parent = scrollView;
            scrollView.contentItem = contentItem;
        } else {
            contentItem.parent = contentItemParent;
            scrollView.contentItem = flickableContents;
            contentItem.anchors.left = contentItemParent.left;
            contentItem.anchors.right = contentItemParent.right;
        }
        scrollView.flickableItem.flickableDirection = Flickable.VerticalFlick;
    }
    onSheetOpenChanged: {
        if (sheetOpen) {
            open();
        } else {
            close();
            Qt.inputMethod.hide();
        }
    }

    Component.onCompleted: {
        scrollView.flickableItem.interactive = true;
        if (!root.parent) {
            root.parent = applicationWindow().overlay
        }
    }

    readonly property Item rootItem: MouseArea {
        id: mainItem
        Theme.colorSet: root.Theme.colorSet
        Theme.inherit: root.Theme.inherit
        //we want to be over any possible OverlayDrawers, including handles
        parent: root.parent == applicationWindow().overlay ? root.parent.parent : root.parent
        anchors.fill: parent
        z: 2000000
        visible: false
        drag.filterChildren: true
        hoverEnabled: true

        onClicked: {
            var pos = mapToItem(flickableContents, mouse.x, mouse.y);
            if (!flickableContents.contains(pos)) {
                root.close();
            }
        }

        onWidthChanged: {
            if (!contentItem.contentItem)
                return

            var width = Math.max(mainItem.width/2, Math.min(mainItem.width, root.contentItem.implicitWidth));
            contentItem.contentItem.x = (mainItem.width - width)/2
            contentItem.contentItem.width = width;
        }
        onHeightChanged: {
            var focusItem;

            if (typeof applicationWindow !== "undefined") {
                focusItem = applicationWindow().activeFocusItem;
            //fallback: hope activeFocusItem is in context
            } else {
                focusItem = activeFocusItem;
            }

            if (!activeFocusItem) {
                return;
            }

            //NOTE: there is no function to know if an item is descended from another,
            //so we have to walk the parent hyerarchy by hand
            var isDescendent = false;
            var candidate = focusItem.parent;
            while (candidate) {
                if (candidate == root) {
                    isDescendent = true;
                    break;
                }
                candidate = candidate.parent;
            }
            if (!isDescendent) {
                return;
            }

            var cursorY = 0;
            if (focusItem.cursorPosition !== undefined) {
                cursorY = focusItem.positionToRectangle(focusItem.cursorPosition).y;
            }

            
            var pos = focusItem.mapToItem(flickableContents, 0, cursorY - Units.gridUnit*3);
            //focused item alreqady visible? add some margin for the space of the action buttons
            if (pos.y >= scrollView.flickableItem.contentY && pos.y <= scrollView.flickableItem.contentY + scrollView.flickableItem.height - Units.gridUnit * 8) {
                return;
            }
            scrollView.flickableItem.contentY = pos.y;
        }

        NumberAnimation {
            id: openAnimation
            property int topOpenPosition: Math.min(-mainItem.height*0.15, scrollView.flickableItem.contentHeight - mainItem.height + Units.gridUnit * 5)
            property int bottomOpenPosition: (scrollView.flickableItem.contentHeight - mainItem.height) + (Units.gridUnit * 5)
            target: scrollView.flickableItem
            properties: "contentY"
            from: -mainItem.height
            to: topOpenPosition
            duration: Units.longDuration
            easing.type: Easing.OutQuad
            onRunningChanged: {
                if (!running && contentItem.contentItem) {
                    var width = Math.max(mainItem.width/2, Math.min(mainItem.width, root.contentItem.implicitWidth));
                    contentItem.contentItem.x = (mainItem.width - width)/2
                    contentItem.contentItem.width = width;
                }
            }
        }

        SequentialAnimation {
            id: closeAnimation
            property int to: -mainItem.height
            NumberAnimation {
                target: scrollView.flickableItem
                properties: "contentY"
                to: closeAnimation.to
                duration: Units.longDuration
                easing.type: Easing.InQuad
            }
            ScriptAction {
                script: {
                    scrollView.flickableItem.contentY = -mainItem.height;
                    mainItem.visible = root.sheetOpen = false;
                }
            }
        }
        Rectangle {
            anchors.fill: parent
            color: Theme.textColor
            opacity: 0.6 * Math.min(
                (Math.min(scrollView.flickableItem.contentY + scrollView.flickableItem.height, scrollView.flickableItem.height) / scrollView.flickableItem.height),
                (2 + (scrollView.flickableItem.contentHeight - scrollView.flickableItem.contentY - scrollView.flickableItem.topMargin - scrollView.flickableItem.bottomMargin)/scrollView.flickableItem.height))
        }

        Item {
            id: flickableContents
            //anchors.horizontalCenter: parent.horizontalCenter
            x: (mainItem.width - width) / 2

            readonly property real headerHeight: scrollView.flickableItem && root.contentItem.headerItem ? root.contentItem.headerItem.height : 0
            y: scrollView.flickableItem && root.contentItem.hasOwnProperty("contentY") ? -scrollView.flickableItem.contentY - headerHeight : 0
            width: root.contentItem.implicitWidth <= 0 ? mainItem.width : Math.max(mainItem.width/2, Math.min(mainItem.width, root.contentItem.implicitWidth))
            height: scrollView.flickableItem && root.contentItem.hasOwnProperty("contentY") ? scrollView.flickableItem.contentHeight + headerHeight : (root.contentItem.height + topPadding + bottomPadding + Units.iconSizes.medium + Units.gridUnit)
            Item {
                id: contentItemParent
                anchors {
                    fill: parent
                    leftMargin: leftPadding
                    topMargin: topPadding
                    rightMargin: rightPadding
                    bottomMargin: bottomPadding
                }
            }
        }
        Binding {
            when: scrollView.flickableItem != null
            target: scrollView.flickableItem
            property: "topMargin"
            value: scrollView.height
        }
        Binding {
            when: scrollView.flickableItem != null
            target: scrollView.flickableItem
            property: "bottomMargin"
            value: scrollView.height
        }

        Connections {
            target: scrollView.flickableItem
            function movementEnded() {
                //close
                if ((mainItem.height + scrollView.flickableItem.contentY) < mainItem.height/2) {
                    closeAnimation.to = -mainItem.height;
                    closeAnimation.running = true;
                } else if ((mainItem.height*0.6 + scrollView.flickableItem.contentY) > scrollView.flickableItem.contentHeight) {
                    closeAnimation.to = scrollView.flickableItem.contentHeight
                    closeAnimation.running = true;

                //reset to the default sheetOpen position
                } else if (scrollView.flickableItem.contentY < openAnimation.topOpenPosition) {
                    openAnimation.from = scrollView.flickableItem.contentY;
                    openAnimation.to = openAnimation.topOpenPosition;
                    openAnimation.running = true;
                //reset to the default "bottom" sheetOpen position
                } else if (scrollView.flickableItem.contentY > openAnimation.bottomOpenPosition) {
                    openAnimation.from = scrollView.flickableItem.contentY;
                    openAnimation.to = openAnimation.bottomOpenPosition;
                    openAnimation.running = true;
                }
            }
            onMovementEnded: movementEnded();
            onFlickEnded: movementEnded();
            onContentHeightChanged: {
                if (openAnimation.running) {
                    openAnimation.running = false;
                    open();
                }
            }
        }

        //add an extra background for the scrollbar
        Rectangle {
            z: -1
            parent: scrollView.verticalScrollBar.background
            anchors.fill:parent
            color: Theme.backgroundColor
        }
        Binding {
            target: scrollView.verticalScrollBar
            property: "visible"
            value: scrollView.flickableItem.contentHeight > mainItem.height*0.8
        }
        Connections {
            target: scrollView.verticalScrollBar
            onActiveChanged: {
                if (!scrollView.verticalScrollBar.active) {
                    scrollView.flickableItem.movementEnded();
                }
            }
        }
        ScrollView {
            id: scrollView
            anchors.fill: parent
            horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        }
    }
}
