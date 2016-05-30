/*
 *   Copyright 2010 Marco Martin <notmart@gmail.com>
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
import "private"
import "templates" as T

/**
 * An item delegate Intended to support extra actions obtainable
 * by uncovering them by dragging away the item with the handle
 * This acts as a container for normal list items.
 * Any subclass of AbstractListItem can be assigned as the contentItem property.
 * @code
 * ListView {
 *     model: myModel
 *     delegate: SwipeListItem {
 *         Label {
 *             text: model.text
 *         }
 *         actions: [
 *              Action {
 *                  iconName: "document-decrypt"
 *                  onTriggered: print("Action 1 clicked")
 *              },
 *              Action {
 *                  iconName: model.action2Icon
 *                  onTriggered: //do something
 *              }
 *         ]
 *     }
 * 
 * }
 * @endcode
 *
 * @inherit QtQuick.Item
 */
T.SwipeListItem {
    id: root

//BEGIN properties
    background: DefaultListItemBackground {}
    /**
     * contentItem: Item
     * This property holds the visual content item.
     *
     * Note: The content item is automatically resized inside the
     * padding of the control.
     */
     //default property Item contentItem

    /**
     * supportsMouseEvents: bool
     * Holds if the item emits signals related to mouse interaction.
     *TODO: remove
     * The default value is false.
     */
    //property alias supportsMouseEvents: itemMouse.enabled

    /**
     * clicked: signal
     * This signal is emitted when there is a click.
     *
     * This is disabled by default, set enabled to true to use it.
     * @see enabled
     */
    //signal clicked


    /**
     * pressAndHold: signal
     * The user pressed the item with the mouse and didn't release it for a
     * certain amount of time.
     *
     * This is disabled by default, set enabled to true to use it.
     * @see enabled
     */
    //signal pressAndHold

    /**
     * checked: bool
     * If true makes the list item look as checked or pressed. It has to be set
     * from the code, it won't change by itself.
     */
    //property bool checked: false

    /**
     * pressed: bool
     * True when the user is pressing the mouse over the list item and
     * supportsMouseEvents is set to true
     */
    //property alias pressed: itemMouse.pressed

    /**
     * containsMouse: bool
     * True when the user hover the mouse over the list item
     * NOTE: on mobile touch devices this will be true only when pressed is also true
     */
    //property alias containsMouse: itemMouse.containsMouse

    /**
     * sectionDelegate: bool
     * If true the item will be a delegate for a section, so will look like a
     * "title" for the items under it.
     */
    //property bool sectionDelegate: false

    /**
     * separatorVisible: bool
     * True if the separator between items is visible
     * default: true
     */
    //property bool separatorVisible: true

    /**
     * actions: list<Action>
     * Defines the actions for the list item: at most 4 buttons will
     * contain the actions for the item, that can be revealed by
     * sliding away the list item.
     */
    //property list<Action> actions


    /**
     * position: real
     * This property holds the position of the dragged list item relative to its
     * final destination (just like the Drawer). That is, the position
     * will be 0 when the list item is fully closed, and 1 when fully open.
     */
    //property real position: 0

    /**
     * background: Item
     * This property holds the background item.
     *
     * Note: If the background item has no explicit size specified,
     * it automatically follows the control's size.
     * In most cases, there is no need to specify width or
     * height for a background item.
     */
    //property var background
//END properties
}
