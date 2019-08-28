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
import QtQuick.Controls 2.5 as Controls
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

    implicitHeight: actionsLayout.implicitHeight

    implicitWidth: actionsLayout.implicitWidth

    Layout.minimumWidth: moreButton.implicitWidth

    Layout.fillWidth: true

    RowLayout {
        id: actionsLayout
        anchors.fill: parent
        //anchors.rightMargin: moreButton.width
        
        spacing: Kirigami.Units.smallSpacing
        property var overflowSet: []

        // TODO use Array.findIndex once we depend on Qt 5.9
        function findIndex(array, cb) {
            for (var i = 0, length = array.length; i < length; ++i) {
                if (cb(array[i])) {
                    return i;
                }
            }
            return -1;
        }

        function isActionVisible(action) {
            var index = actionsLayout.findIndex(actionsLayout.overflowSet, function(act){return act === action});
            if (index === -1) {
                index = actionsLayout.findIndex(root.hiddenActions, function(act){return act === action});
                if (index === -1) {
                    return true
                }
            }
            return false
        }

        RowLayout {
            Layout.minimumWidth: 0
            Layout.fillHeight: true
            Repeater {
                model: root.actions
                delegate: PrivateActionToolButton {
                    id: actionDelegate
                    flat: root.flat
                    opacity: x + width <= parent.width
                    enabled: opacity

                    display: root.display
                    visible: !modelData.hasOwnProperty("visible") || modelData.visible
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignVCenter
                    Layout.minimumWidth: implicitWidth
                    kirigamiAction: modelData
                    onOpacityChanged: updateOverflowSet()
                    function updateOverflowSet() {
                        var index = actionsLayout.findIndex(actionsLayout.overflowSet, function(act) {
                            return act === modelData});

						if ((opacity > 0 || (modelData.hasOwnProperty("visible") || !modelData.visible)) && index > -1) {
                            actionsLayout.overflowSet.splice(index, 1);
						} else if (opacity === 0 && (!modelData.hasOwnProperty("visible") || modelData.visible) && index === -1) {
                            actionsLayout.overflowSet.push(modelData);
                        }
                        actionsLayout.overflowSetChanged();
                    }
                    Connections {
                        target: modelData
                        ignoreUnknownSignals: !modelData.hasOwnProperty("visible")
                        onVisibleChanged: actionDelegate.updateOverflowSet();
                    }
                    Component.onCompleted: {
                        actionDelegate.updateOverflowSet();
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            visible: root.Layout.fillWidth
        }

        PrivateActionToolButton {
            id: moreButton

            Layout.alignment: Qt.AlignRight

            visible: hiddenActions.length > 0 || actionsLayout.overflowSet.length > 0
            showMenuArrow: false

            kirigamiAction: Kirigami.Action {
                icon.name: "overflow-menu"
                children: Array.prototype.map.call(root.actions, i => i).concat(Array.prototype.map.call(hiddenActions, i => i))
            }

            menu.submenuComponent: ActionsMenu {
                Binding {
                    target: parentItem
                    property: "visible"
                    value: !actionsLayout.isActionVisible(parentAction) && (parentAction.visible === undefined || parentAction.visible)
                }
            }

            menu.itemDelegate: ActionMenuItem {
                visible: !actionsLayout.isActionVisible(ourAction) && (ourAction.visible === undefined || ourAction.visible)
            }
        }
    }
}
