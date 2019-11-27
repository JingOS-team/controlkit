/*
 *   Copyright 2018 Marco Martin <mart@kde.org>
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

import QtQuick 2.7
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.4 as Controls
import org.kde.kirigami 2.5 as Kirigami
import "private"

/**
 * This is a simple toolbar built out of a list of actions
 * each action is represented by a ToolButton, those that won't fit
 * the size will go in a menu under a button with the overflow ... icon
 *
 * @inherits Item
 * @since 2.5
 */
Item {
    id: root
    /**
    * actions: list<Action>
    * if the card should provide clickable actions, put them in this property,
    * they will be put in the footer as a list of ToolButtons plus an optional
    * overflow menu, when not all of them will fit in the available Card width.
    */
    property list<QtObject> actions

    /**
    * actions: hiddenActions<Action>
    * This list of actions is for those you always want in the menu, even if there
    * is enough space.
    * @since 2.6
    */
    property list<QtObject> hiddenActions

    /**
     * flat: bool
     * Wether we want our buttons to have a flat appearance. Default: true
     */
    property bool flat: true

    /**
     * display: enum
     * This controls the label position regarding the icon, is the same value to control individual Button components,
     * permitted values are:
     * * Button.IconOnly
     * * Button.TextOnly
     * * Button.TextBesideIcon
     * * Button.TextUnderIcon
     */
    property int display: Controls.Button.TextBesideIcon

    property int alignment: Qt.AlignLeft

    /**
     * position enum
     * This property holds the position of the toolbar.
     * if this ActionToolBar is the contentItem of a QQC2 Toolbar, the position is binded to the ToolBar's position
     *
     * permitted values are:
     * *ToolBar.Header: The toolbar is at the top, as a window or page header.
     * *ToolBar.Footer: The toolbar is at the bottom, as a window or page footer.
     */
    property int position: parent && parent.hasOwnProperty("position")
            ? parent.position
            : Controls.ToolBar.Header

    /**
     * The maximum width of the contents of this ToolBar. If the toolbar's width is larger than this value, empty space will
     * be added on the sides, according to the Alignment property.
     *
     * The value of this property is derived from the ToolBar's actions and their properties.
     */
    readonly property alias maximumContentWidth: details.maximumWidth

    implicitHeight: actionsLayout.implicitHeight
    implicitWidth: actionsLayout.implicitWidth
    Layout.minimumWidth: moreButton.visible ? moreButton.implicitWidth : 0

    RowLayout {
        id: actionsLayout
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: root.alignment == Qt.AlignRight || root.alignment == Qt.AlignHCenter || root.alignment == Qt.AlignCenter;
            Layout.fillHeight: true
        }

        Repeater {
            model: root.actions

            delegate: PrivateActionToolButton {
                id: actionDelegate

                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: implicitWidth
                // Use rightMargin instead of spacing on the layout to prevent spacer items
                // from creating useless spacing
                Layout.rightMargin: Kirigami.Units.smallSpacing

                visible: details.visibleActions.indexOf(modelData) != -1
                         && (modelData.visible === undefined || modelData.visible)

                flat: root.flat && !modelData.icon.color.a
                display: details.iconOnlyActions.indexOf(modelData) != -1 ? Controls.Button.IconOnly : root.display
                kirigamiAction: modelData
            }
        }

        Item {
            Layout.fillWidth: root.alignment == Qt.AlignLeft || root.alignment == Qt.AlignHCenter || root.alignment == Qt.AlignCenter;
            Layout.fillHeight: true
        }

        PrivateActionToolButton {
            id: moreButton

            Layout.alignment: Qt.AlignRight
            visible: root.hiddenActions.length > 0 || details.hiddenActions.length > 0

            kirigamiAction: Kirigami.Action {
                icon.name: "overflow-menu"
                displayHint: Kirigami.Action.DisplayHint.IconOnly | Kirigami.Action.DisplayHint.HideChildIndicator
                children: Array.prototype.map.call(root.actions, function (i) { return i }).concat(Array.prototype.map.call(hiddenActions, function (i) { return i }))
            }

            menu.submenuComponent: ActionsMenu {
                Binding {
                    target: parentItem
                    property: "visible"
                    value: details.visibleActions.indexOf(parentAction) == -1 &&
                                (parentAction.visible === undefined || parentAction.visible)
                }
            }

            menu.itemDelegate: ActionMenuItem {
                visible: details.visibleActions.indexOf(action) == -1 &&
                                    (action.visible === undefined || action.visible)
            }
        }
    }

    ActionToolBarLayoutDetails {
        id: details
        anchors.fill: parent
        actions: root.actions
        rightPadding: moreButton.width + Kirigami.Units.smallSpacing
        flat: root.flat
        display: root.display
    }
}
