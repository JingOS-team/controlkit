/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2019 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.4 as Controls
import org.kde.kirigami 2.5 as Kirigami

/**
 * This fairly complex thing determines the layout of ActionToolBar, that is,
 * which actions should be displayed in full width toolbutton form, which should
 * be displayed in an icon-only reduced size and which should be placed in the
 * overflow menu.
 *
 * It makes use of two fairly static layouts, one contains all actions in expanded
 * full-size form, the other in reduced icon-only form. The items in these layouts
 * determine if they should be visible based on their relative position and size
 * and some properties of the action. The update function then goes through these
 * items, adding the actions to the relevant lists, so they can be used by the
 * ActionToolBar to determine which action should be visible in what state.
 *
 * The reason for using two separate layouts from ActionToolBar's main layout is
 * so that we can use the actual geometry of the buttons to calculate the
 * visibility, completely disregarding any other layouting quirks. We can then
 * use that information so only the relevant things in the ActionToolBar are
 * visible. This allows the main ActionToolBar to use normal layout features for
 * things like the positioning of the visible actions.
 */
Item {
    id: details

    property var actions

    property var visibleActions: []
    property var hiddenActions: []
    property var iconOnlyActions: []

    property bool flat: false
    property int display: Controls.Button.TextBesideIcon
    property real spacing: Kirigami.Units.smallSpacing
    property real leftPadding: 0
    property real rightPadding: 0

    property real iconOnlyWidth: 0
    readonly property real iconLayoutWidth: width - rightPadding
    readonly property real fullLayoutWidth: iconLayoutWidth - iconOnlyWidth
    readonly property real maximumWidth: fullSizePlaceholderLayout.width + leftPadding + rightPadding
    property bool hasCollapsed: false
    property var previousWidth: null
    property bool goingAway: false

    enabled: false
    opacity: 0 // Cannot use visible: false because then relayout doesn't happen correctly

    function update() {
        var visible = []
        var hidden = []
        var iconOnly = []
        var iconsWidth = 0

        for (var i = 0; i < root.actions.length; ++i) {
            var item = fullSizePlaceholderRepeater.itemAt(i)
            var iconOnlyItem = iconOnlyPlaceholderRepeater.itemAt(i)

            if ((hasCollapsed ? item.actionVisibleWithPadding : item.actionVisible) ||
               ((goingAway && hiddenActions.length == 1) ? item.actionVisible : false)) {
                visible.push(item.kirigamiAction)
            } else if ((hasCollapsed ? iconOnlyItem.actionVisibleWithPadding : iconOnlyItem.actionVisible) ||
                      ((goingAway && hiddenActions.length == 1) ? iconOnlyItem.actionVisible : false)) {
                visible.push(item.kirigamiAction)
                iconOnly.push(item.kirigamiAction)
                iconsWidth += iconOnlyItem.width + details.spacing
            } else {
                hidden.push(item.kirigamiAction)
            }
        }

        hasCollapsed = hidden.length > 0

        visibleActions = visible
        hiddenActions = hidden
        iconOnlyActions = iconOnly
        iconOnlyWidth = iconsWidth
    }

    onWidthChanged: {
        if (previousWidth != null) {
            goingAway = previousWidth < width
        }
        previousWidth = width
        Qt.callLater(update)
    }
    Component.onCompleted: Qt.callLater(update)

    RowLayout {
        id: fullSizePlaceholderLayout
        spacing: details.spacing

        // This binding is here to take care of things like visibility changes
        onWidthChanged: Qt.callLater(details.update)

        Repeater {
            id: fullSizePlaceholderRepeater

            model: details.actions

            Loader {
                property var kirigamiAction: modelData

                sourceComponent: {
                    if (modelData.displayComponent && !modelData.displayHintSet(Kirigami.Action.DisplayHint.IconOnly)) {
                        return modelData.displayComponent
                    }
                    return toolButtonDelegate
                }

                visible: {
                    if (modelData.hasOwnProperty("visible") && !modelData.visible) {
                        return false
                    }

                    if (modelData.hasOwnProperty("displayHint") &&
                        modelData.displayHintSet(Kirigami.Action.DisplayHint.AlwaysHide)) {
                        return false
                    }

                    return true
                }

                property bool actionVisibleWithPadding: visible && (x + width <= details.fullLayoutWidth)
                property bool actionVisible: visible && (x + width <= (details.fullLayoutWidth + details.rightPadding))

                onLoaded: {
                    if (sourceComponent == toolButtonDelegate) {
                        item.kirigamiAction = modelData
                    }
                }
            }
        }
    }

    Component {
        id: toolButtonDelegate
        PrivateActionToolButton {
            flat: details.flat && !kirigamiAction.icon.color.a
            display: details.display
            menu.actions: {
                if (kirigamiAction.displayComponent && kirigamiAction.displayHintSet(Kirigami.Action.DisplayHint.IconOnly)) {
                    return [kirigamiAction]
                }

                if (kirigamiAction.children) {
                    return kirigamiAction.children
                }

                return []
            }
        }
    }

    RowLayout {
        id: iconOnlyPlaceholderLayout
        spacing: details.spacing

        Repeater {
            id: iconOnlyPlaceholderRepeater

            model: details.actions

            PrivateActionToolButton {
                flat: details.flat && !modelData.icon.color.a
                display: Controls.Button.IconOnly
                visible: {
                    if (modelData.hasOwnProperty("visible") && !modelData.visible) {
                        return false
                    }
                    if (modelData.hasOwnProperty("displayHint")
                        && modelData.displayHintSet(Kirigami.Action.DisplayHint.KeepVisible)) {
                        return true
                    }
                    return false
                }
                kirigamiAction: modelData
                property bool actionVisibleWithPadding: visible && (iconOnlyPlaceholderRepeater.count === 1 || (x + width < details.iconLayoutWidth))
                property bool actionVisible: visible && (iconOnlyPlaceholderRepeater.count === 1 || (x + width < (details.iconLayoutWidth + details.rightPadding)))
            }
        }
    }
}
