/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtTest 1.0
import org.kde.kirigami 2.14 as Kirigami

// TODO: Find a nicer way to handle this
import "../src/controls/private" as KirigamiPrivate

TestCase {
    id: testCase
    name: "IconTests"

    width: 500
    height: 400
    visible: true

    when: windowShown

    // These buttons are required for getting the right metrics.
    // Since ActionToolBar bases all sizing on button sizes, we need to be able
    // to verify that layouting does the right thing.
    property ToolButton iconButton: KirigamiPrivate.PrivateActionToolButton {
        display: Button.IconOnly
        action: Kirigami.Action { icon.name: "document-new"; text: "Test Action" }
        font.pointSize: 10
    }
    property ToolButton textButton: KirigamiPrivate.PrivateActionToolButton {
        display: Button.TextOnly
        action: Kirigami.Action { icon.name: "document-new"; text: "Test Action" }
        font.pointSize: 10
    }
    property ToolButton textIconButton: KirigamiPrivate.PrivateActionToolButton {
        action: Kirigami.Action { icon.name: "document-new"; text: "Test Action" }
        font.pointSize: 10
    }
    property TextField textField: TextField { font.pointSize: 10 }

    Component {
        id: single;
        Kirigami.ActionToolBar {
            font.pointSize: 10
            actions: [
                Kirigami.Action { icon.name: "document-new"; text: "Test Action" }
            ]
        }
    }

    Component {
        id: multiple
        Kirigami.ActionToolBar {
            font.pointSize: 10
            actions: [
                Kirigami.Action { icon.name: "document-new"; text: "Test Action" },
                Kirigami.Action { icon.name: "document-new"; text: "Test Action" },
                Kirigami.Action { icon.name: "document-new"; text: "Test Action" }
            ]
        }
    }

    Component {
        id: iconOnly
        Kirigami.ActionToolBar {
            display: Button.IconOnly
            font.pointSize: 10
            actions: [
                Kirigami.Action { icon.name: "document-new"; text: "Test Action" },
                Kirigami.Action { icon.name: "document-new"; text: "Test Action" },
                Kirigami.Action { icon.name: "document-new"; text: "Test Action" }
            ]
        }
    }

    Component {
        id: qtActions
        Kirigami.ActionToolBar {
            font.pointSize: 10
            actions: [
                Action { icon.name: "document-new"; text: "Test Action" },
                Action { icon.name: "document-new"; text: "Test Action" },
                Action { icon.name: "document-new"; text: "Test Action" }
            ]
        }
    }

    Component {
        id: mixed
        Kirigami.ActionToolBar {
            font.pointSize: 10
            actions: [
                Kirigami.Action { icon.name: "document-new"; text: "Test Action"; displayHint: Kirigami.DisplayHint.IconOnly },
                Kirigami.Action { icon.name: "document-new"; text: "Test Action" },
                Kirigami.Action { icon.name: "document-new"; text: "Test Action"; displayComponent: TextField { } },
                Kirigami.Action { icon.name: "document-new"; text: "Test Action"; displayHint: Kirigami.DisplayHint.AlwaysHide },
                Kirigami.Action { icon.name: "document-new"; text: "Test Action"; displayHint: Kirigami.DisplayHint.KeepVisible }
            ]
        }
    }

    function test_layout_data() {
        return [
            // One action
            // Full window width, should just display a toolbutton
            { tag: "single_full", component: single, width: testCase.width, expected: testCase.textIconButton.width },
            // Small width, should display the overflow button
            { tag: "single_min", component: single, width: 50, expected: testCase.iconButton.width },
            // Half window width, should display a single toolbutton
            { tag: "single_half", component: single, width: testCase.width / 2, expected: testCase.textIconButton.width },
            // Multiple actions
            // Full window width, should display as many buttons as there are actions
            { tag: "multi_full", component: multiple, width: testCase.width,
                expected: testCase.textIconButton.width * 3 + Kirigami.Units.smallSpacing * 2 },
            // Small width, should display just the overflow button
            { tag: "multi_min", component: multiple, width: 50, expected: testCase.iconButton.width },
            // Half window width, should display one action and overflow button
            { tag: "multi_half", component: multiple,
                width: testCase.width / 2,
                expected: testCase.textIconButton.width * 2 + testCase.iconButton.width + Kirigami.Units.smallSpacing },
            // Multiple actions, display set to icon only
            // Full window width, should display as many icon-only buttons as there are actions
            { tag: "icon_full", component: iconOnly, width: testCase.width,
                expected: testCase.iconButton.width * 3 + Kirigami.Units.smallSpacing * 2 },
            // Small width, should display just the overflow button
            { tag: "icon_min", component: iconOnly, width: 50, expected: testCase.iconButton.width },
            // Quarter window width, should display one icon-only button and the overflow button
            { tag: "icon_quarter", component: iconOnly, width: testCase.width / 4,
                expected: testCase.iconButton.width * 3 + Kirigami.Units.smallSpacing * 2 },
            // QtQuick Controls actions
            // Full window width, should display as many buttons as there are actions
            { tag: "qt_full", component: qtActions, width: testCase.width,
                expected: testCase.textIconButton.width * 3 + Kirigami.Units.smallSpacing * 2 },
            // Small width, should display just the overflow button
            { tag: "qt_min", component: qtActions, width: 50, expected: testCase.iconButton.width },
            // Half window width, should display one action and overflow button
            { tag: "qt_half", component: qtActions,
                width: testCase.width / 2,
                expected: testCase.textIconButton.width * 2 + testCase.iconButton.width + Kirigami.Units.smallSpacing },
            // Mix of different display hints, displayComponent and normal actions.
            // Full window width, should display everything, but one action is collapsed to icon
            { tag: "mixed", component: mixed, width: testCase.width,
                expected: testCase.textIconButton.width * 2 + testCase.iconButton.width * 2 + testCase.textField.width + Kirigami.Units.smallSpacing * 3 }
        ]
    }

    // Test layouting of ActionToolBar
    //
    // ActionToolBar has some pretty complex behaviour, which generally boils down to it trying
    // to fit as many visible actions as possible and placing the hidden ones in an overflow menu.
    // This test, along with the data above, verifies that that this behaviour is correct.
    function test_layout(data) {
        var toolbar = createTemporaryObject(data.component, testCase)

        verify(toolbar)
        verify(waitForRendering(toolbar))

        toolbar.width = data.width
        wait(100) // Allow events to propagate so toolbar can resize properly

        compare(toolbar.visibleWidth, data.expected)
    }
}
