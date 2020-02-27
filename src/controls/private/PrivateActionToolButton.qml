/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.4 as Controls
import org.kde.kirigami 2.4

Controls.ToolButton {
    id: control

    signal menuAboutToShow

    implicitWidth: {
        if (!menuArrow.visible) {
            if (!showText || display == Controls.Button.IconOnly) {
                return implicitHeight
            }

            var textLength = kirigamiAction ? kirigamiAction.text.length : text.length
            if (textLength == 0) {
                return implicitHeight
            }
        }

        return Math.max(layout.implicitWidth + Units.largeSpacing * 2, background.implicitWidth)
    }

    Theme.colorSet: Theme.Button
    Theme.inherit: kirigamiAction && kirigamiAction.icon.color.a === 0
    Theme.backgroundColor: kirigamiAction && kirigamiAction.icon.color.a ? kirigamiAction.icon.color : undefined
    Theme.textColor: kirigamiAction && !flat && kirigamiAction.icon.color.a ? Theme.highlightedTextColor : undefined

    hoverEnabled: true
    flat: !control.kirigamiAction || !control.kirigamiAction.icon.color.a
    //TODO: replace with upstream action when we depend on Qt 5.10
    //TODO: upstream action makes the style to re-draw the content, it'd be ideal except for the custom dropDown icon needed for actionsMenu
    property Controls.Action kirigamiAction
    property bool showText: !(kirigamiAction && kirigamiAction.displayHint !== undefined
                              && kirigamiAction.displayHintSet(Action.DisplayHint.IconOnly))
    property bool showMenuArrow: !(kirigamiAction && kirigamiAction.displayHint !== undefined
                                   && kirigamiAction.displayHintSet(Action.DisplayHint.HideChildIndicator))
    property alias menu: menu

    //we need our own text delegate
    text: ""
    checkable: (kirigamiAction && kirigamiAction.checkable) || (menu.actions && menu.actions.length > 0)
    checked: (kirigamiAction && kirigamiAction.checked)
    enabled: kirigamiAction && kirigamiAction.enabled
    opacity: enabled ? 1 : 0.4
    visible: (kirigamiAction && kirigamiAction.hasOwnProperty("visible")) ? kirigamiAction.visible : true
    onClicked: {
        if (kirigamiAction) {
            kirigamiAction.trigger();
        }
    }

    onToggled: {
        if (menu.actions.length > 0) {
            if (checked) {
                control.menuAboutToShow();
                menu.popup(control, 0, control.height)
            } else {
                menu.dismiss()
            }
        }
    }

    ActionsMenu {
        id: menu
        y: control.height
        actions: control.kirigamiAction && kirigamiAction.hasOwnProperty("children") ? control.kirigamiAction.children : null

        // Important: We handle the press on parent in the parent, so ignore it here.
        closePolicy: Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnPressOutsideParent

        submenuComponent: Component {
            ActionsMenu {}
        }

        onClosed: {
            control.checked = false
        }
    }

    contentItem: MouseArea {
        hoverEnabled: true
        onPressed: mouse.accepted = false
        Theme.colorSet: checked && (control.kirigamiAction && control.kirigamiAction.icon.color.a) ? Theme.Selection : control.Theme.colorSet
        Theme.inherit: control.kirigamiAction && Theme.colorSet != Theme.Selection && control.kirigamiAction.icon.color.a === 0
        implicitWidth: layout.implicitWidth
        implicitHeight: layout.implicitHeight
        GridLayout {
            id: layout
            columns: control.display == Controls.ToolButton.TextUnderIcon ? 1 : 2 + (menuArrow.visible ? 1 : 0)
            rows: control.display == Controls.ToolButton.TextUnderIcon ? 2 : 1

            anchors.centerIn: parent
            Icon {
                id: mainIcon
                Layout.alignment: Qt.AlignCenter
                Layout.minimumWidth: Units.iconSizes.smallMedium
                Layout.minimumHeight: Units.iconSizes.smallMedium
                source: control.kirigamiAction ? (control.kirigamiAction.icon ? control.kirigamiAction.icon.name : control.kirigamiAction.iconName) : ""
                visible: control.kirigamiAction && control.kirigamiAction.iconName != "" && control.display != Controls.ToolButton.TextOnly
                color: control.flat && control.kirigamiAction && control.kirigamiAction.icon && control.kirigamiAction.icon.color.a > 0 ? control.kirigamiAction.icon.color : label.color
            }
            Controls.Label {
                id: label
                MnemonicData.enabled: control.enabled
                MnemonicData.controlType: MnemonicData.ActionElement
                MnemonicData.label: control.kirigamiAction ? control.kirigamiAction.text : ""

                text: MnemonicData.richTextLabel
                visible: control.showText && text.length > 0 && control.display != Controls.ToolButton.IconOnly

                Shortcut {
                    sequence: label.MnemonicData.sequence
                    onActivated: control.clicked()
                }
            }
            Icon {
                id: menuArrow
                Layout.minimumWidth: Units.iconSizes.small
                Layout.minimumHeight: Units.iconSizes.small
                color: mainIcon.color
                source: "arrow-down"
                visible: showMenuArrow && menu.actions && menu.actions.length > 0
            }
        }
    }
    Controls.ToolTip {
        visible: control.hovered && text.length > 0 && !menu.visible && !control.pressed
        text: kirigamiAction ? (kirigamiAction.tooltip && kirigamiAction.tooltip.length ? kirigamiAction.tooltip : kirigamiAction.text) : ""
        delay: Units.toolTipDelay
        timeout: 5000
        y: control.height
    }
}
