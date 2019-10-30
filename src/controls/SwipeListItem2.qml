/*
 *   Copyright 2019 Marco Martin <notmart@gmail.com>
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

import QtQuick 2.6
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.4 as Controls
import QtQuick.Templates 2.4 as T2
import org.kde.kirigami 2.11 as Kirigami
import "private"

/**
 * An item delegate Intended to support extra actions obtainable
 * by uncovering them by dragging away the item with the handle
 * This acts as a container for normal list items.
 * Any subclass of AbstractListItem can be assigned as the contentItem property.
 * @code
 * ListView {
 *     model: myModel
 *     delegate: SwipeListItem {
 *         QQC2.Label {
 *             text: model.text
 *         }
 *         actions: [
 *              Action {
 *                  icon.name: "document-decrypt"
 *                  onTriggered: print("Action 1 clicked")
 *              },
 *              Action {
 *                  icon.name: model.action2Icon
 *                  onTriggered: //do something
 *              }
 *         ]
 *     }
 * 
 * }
 * @endcode
 *
 */
T2.SwipeDelegate {
    id: listItem

    /**
     * supportsMouseEvents: bool
     * Holds if the item emits signals related to mouse interaction.
     *TODO: remove
     * The default value is false.
     */
    property alias supportsMouseEvents: listItem.hoverEnabled

    /**
     * containsMouse: bool
     * True when the user hover the mouse over the list item
     * NOTE: on mobile touch devices this will be true only when pressed is also true
     * KF6: remove
     */
    property alias containsMouse: listItem.hovered

    /**
     * alternatingBackground: bool
     * If true the background of the list items will be alternating between two
     * colors, helping readability with multiple column views.
     * Use it only when implementing a view which shows data visually in multiple columns
     * @ since 2.7 
     */
    property bool alternatingBackground: false

    /**
     * sectionDelegate: bool
     * If true the item will be a delegate for a section, so will look like a
     * "title" for the items under it.
     */
    property bool sectionDelegate: false

    /**
     * separatorVisible: bool
     * True if the separator between items is visible
     * default: true
     */
    property bool separatorVisible: true

    /**
     * actionsVisible: bool
     * True if it's possible to see and access the item actions.
     * Actions should go completely out of the way for instance during
     * the editing of an item.
     * @since 2.5
     */
    readonly property bool actionsVisible: swipe.position != 0

    /**
     * actions: list<Action>
     * Defines the actions for the list item: at most 4 buttons will
     * contain the actions for the item, that can be revealed by
     * sliding away the list item.
     */
    property list<Action> actions

    /**
     * textColor: color
     * Color for the text in the item
     *
     * Note: if custom text elements are inserted in an AbstractListItem,
     * their color property will have to be manually bound with this property
     */
    property color textColor: Kirigami.Theme.textColor

    /**
     * backgroundColor: color
     * Color for the background of the item
     */
    property color backgroundColor: Kirigami.Theme.backgroundColor

    /**
     * alternateBackgroundColor: color
     * The background color to use if alternatingBackground is true.
     * It is advised to leave the default.
     * @since 2.7
     */
    property color alternateBackgroundColor: Kirigami.Theme.alternateBackgroundColor

    /**
     * activeTextColor: color
     * Color for the text in the item when pressed or selected
     * It is advised to leave the default value (Theme.highlightedTextColor)
     *
     * Note: if custom text elements are inserted in an AbstractListItem,
     * their color property will have to be manually bound with this property
     */
    property color activeTextColor: Kirigami.Theme.highlightedTextColor

    /**
     * activeBackgroundColor: color
     * Color for the background of the item when pressed or selected
     * It is advised to leave the default value (Theme.highlightColor)
     */
    property color activeBackgroundColor: Kirigami.Theme.highlightColor


    LayoutMirroring.childrenInherit: true

    hoverEnabled: true
    implicitWidth: contentItem ? contentItem.implicitWidth : Units.gridUnit * 12
    width: parent ? parent.width : implicitWidth
    implicitHeight: Math.max(Units.gridUnit * 2, contentItem.implicitHeight) + topPadding + bottomPadding

    padding: Kirigami.Settings.tabletMode ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing

    leftPadding: padding * 2

    rightPadding: padding * 2 + (overlayLoader.visible ? overlayLoader.width : (hovered || !supportsMouseEvents) * actionsLayout.width) + overlayLoader.anchors.rightMargin
    
    topPadding: padding
    bottomPadding: padding

    Loader {
        id: overlayLoader
        parent: listItem
        z: contentItem ? contentItem.z + 1 : 0
        visible: active
        active: Kirigami.Settings.tabletMode
        sourceComponent: handleComponent
        anchors {
            right: contentItem ? contentItem.right : undefined
            top: parent.top
            bottom: parent.bottom
            rightMargin: -listItem.leftPadding
        }
    }
    Component {
        id: handleComponent

        MouseArea {
            id: dragButton
            anchors {
                right: parent.right
            }
            implicitWidth: Kirigami.Units.iconSizes.smallMedium

            preventStealing: true
            readonly property real openPosition: (listItem.width - width - listItem.leftPadding - listItem.rightPadding)/listItem.width
            property real startX: 0
            property real lastX: 0
            property bool openIntention

            onPressed: startX = mapToItem(listItem, 0, 0).x;
            onClicked: {
                if (Math.abs(mapToItem(listItem, 0, 0).x - startX) > Qt.styleHints.startDragDistance) {
                    return;
                }
                if (listItem.LayoutMirroring.enabled) {
                    if (listItem.swipe.position < 0.5) {
                        slideAnim.to = openPosition
                    } else {
                        slideAnim.to = 0
                    }
                } else {
                    if (listItem.swipe.position > -0.5) {
                        slideAnim.to = -openPosition
                    } else {
                        slideAnim.to = 0
                    }
                }
                slideAnim.restart();
            }
            onPositionChanged: {
                var currentX = mapToItem(listItem, 0, 0).x;
                var pos = mapToItem(listItem, mouse.x, mouse.y);
                
                if (listItem.LayoutMirroring.enabled) {
                    listItem.swipe.position = Math.max(0, Math.min(openPosition, (pos.x / listItem.width)));
                    openIntention = currentX > lastX;
                } else {
                    listItem.swipe.position = Math.min(0, Math.max(-openPosition, (pos.x / (listItem.width -listItem.rightPadding) - 1)));
                    openIntention = currentX < lastX;
                }
                lastX = currentX;
            }
            onReleased: {
                if (listItem.LayoutMirroring.enabled) {
                    if (openIntention) {
                        slideAnim.to = openPosition
                    } else {
                        slideAnim.to = 0
                    }
                } else {
                    if (openIntention) {
                        slideAnim.to = -openPosition
                    } else {
                        slideAnim.to = 0
                    }
                }
                slideAnim.restart();
            }

            Kirigami.Icon {
                id: handleIcon
                anchors.fill: parent
                selected: listItem.checked || (listItem.pressed && !listItem.checked && !listItem.sectionDelegate)
                source: (LayoutMirroring.enabled ? (listItem.background.x < listItem.background.width/2 ? "overflow-menu-right" : "overflow-menu-left") : (listItem.background.x < -listItem.background.width/2 ? "overflow-menu-right" : "overflow-menu-left"))
            }
        }
    }

    property Component actionsDelegate: Rectangle {
        anchors.fill: parent

        color: Controls.SwipeDelegate.pressed ? Qt.darker(Kirigami.Theme.backgroundColor, 1.1) : Qt.darker(Kirigami.Theme.backgroundColor, 1.05)

        visible: listItem.swipe.position != 0
        Controls.SwipeDelegate.onPressedChanged: {
            slideAnim.to = 0;
            slideAnim.restart();
        }

        EdgeShadow {
            edge: Qt.TopEdge
            visible: background.x != 0
            anchors {
                right: parent.right
                left: parent.left
                top: parent.top
            }
        }
        EdgeShadow {
            edge: LayoutMirroring.enabled ? Qt.RightEdge : Qt.LeftEdge
            x: LayoutMirroring.enabled ? listItem.background.x - width : (listItem.background.x + listItem.background.width)
            visible: background.x != 0
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
        }
        RowLayout {
            id: actionsLayout
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }

            property bool hasVisibleActions: false
            function updateVisibleActions(definitelyVisible = false) {
                if (definitelyVisible) {
                    hasVisibleActions = true;
                } else {
                    var actionCount = listItem.actions.length;
                    for (var i = 0; i < actionCount; i++) {
                        // Assuming that visible is only false if it is explicitly false, and not just falsy
                        if (listItem.actions[i].visible === false) {
                            continue;
                        }
                        hasVisibleActions = true;
                        break;
                    }
                }
            }

            Repeater {
                model: {
                    if (listItem.actions.length === 0) {
                        return null;
                    } else {
                        return listItem.actions[0].text !== undefined &&
                            listItem.actions[0].trigger !== undefined ?
                                listItem.actions :
                                listItem.actions[0];
                    }
                }
                delegate: Controls.ToolButton {
                    icon.name: modelData.iconName !== "" ? modelData.iconName : ""
                    icon.source: modelData.iconSource !== "" ? modelData.iconSource : ""
                    enabled: (modelData && modelData.enabled !== undefined) ? modelData.enabled : true;
                    visible: (modelData && modelData.visible !== undefined) ? modelData.visible : true;
                    onVisibleChanged: actionsLayout.updateVisibleActions(visible);
                    Component.onCompleted: actionsLayout.updateVisibleActions(visible);
                    Component.onDestruction: actionsLayout.updateVisibleActions(visible);
                    Controls.ToolTip.delay: Kirigami.Units.toolTipDelay
                    Controls.ToolTip.timeout: 5000
                    Controls.ToolTip.visible: listItem.visible && (Kirigami.Settings.tabletMode ? pressed : hovered) && Controls.ToolTip.text.length > 0
                    Controls.ToolTip.text: modelData.tooltip || modelData.text

                    onClicked: {
                        if (modelData && modelData.trigger !== undefined) {
                            modelData.trigger();
                        }
                        slideAnim.to = 0;
                        slideAnim.restart();
                    }
                }
            }
        }
    }

    background: DefaultListItemBackground {}

    swipe {
        enabled: false
        right: listItem.LayoutMirroring.enabled || !Kirigami.Settings.tabletMode ? null : listItem.actionsDelegate
        left: listItem.LayoutMirroring.enabled && Kirigami.Settings.tabletMod ? listItem.actionsDelegate : null
    }
    NumberAnimation {
        id: slideAnim
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InOutQuad
        target: listItem.swipe
        property: "position"
        from: listItem.swipe.position
    }
}

