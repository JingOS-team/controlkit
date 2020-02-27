/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtTest 1.0
import org.kde.kirigami 2.11 as Kirigami

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
        kirigamiAction: Kirigami.Action { icon.name: "overflow-menu"; text: "Test Action" }
    }
    property ToolButton textButton: KirigamiPrivate.PrivateActionToolButton {
        display: Button.TextOnly
        kirigamiAction: Kirigami.Action { icon.name: "overflow-menu"; text: "Test Action" }
    }
    property ToolButton textIconButton: KirigamiPrivate.PrivateActionToolButton {
        kirigamiAction: Kirigami.Action { icon.name: "overflow-menu"; text: "Test Action" }
    }

    Component {
        id: single;
        Kirigami.ActionToolBar {
            actions: [
                Kirigami.Action { icon.name: "overflow-menu"; text: "Test Action" }
            ]
        }
    }

    Component {
        id: multiple
        Kirigami.ActionToolBar {
            actions: [
                Kirigami.Action { icon.name: "overflow-menu"; text: "Test Action" },
                Kirigami.Action { icon.name: "overflow-menu"; text: "Test Action" },
                Kirigami.Action { icon.name: "overflow-menu"; text: "Test Action" }
            ]
        }
    }

    Component {
        id: iconOnly
        Kirigami.ActionToolBar {
            display: Button.IconOnly
            actions: [
                Kirigami.Action { icon.name: "overflow-menu"; text: "Test Action" },
                Kirigami.Action { icon.name: "overflow-menu"; text: "Test Action" },
                Kirigami.Action { icon.name: "overflow-menu"; text: "Test Action" }
            ]
        }
    }

    Component {
        id: qtActions
        Kirigami.ActionToolBar {
            actions: [
                Action { icon.name: "overflow-menu"; text: "Test Action" },
                Action { icon.name: "overflow-menu"; text: "Test Action" },
                Action { icon.name: "overflow-menu"; text: "Test Action" }
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
            { tag: "multi_half", component: multiple, width: testCase.width / 2,
                expected: testCase.textIconButton.width + testCase.iconButton.width },
            // Multiple actions, display set to icon only
            // Full window width, should display as many icon-only buttons as there are actions
            { tag: "icon_full", component: iconOnly, width: testCase.width,
                expected: testCase.iconButton.width * 3 + Kirigami.Units.smallSpacing * 2 },
            // Small width, should display just the overflow button
            { tag: "icon_min", component: iconOnly, width: 50, expected: testCase.iconButton.width },
            // Quarter window width, should display one icon-only button and the overflow button
            { tag: "icon_quarter", component: iconOnly, width: testCase.width / 4,
                expected: testCase.iconButton.width * 2 },
            // QtQuick Controls actions
            // Full window width, should display as many buttons as there are actions
            { tag: "qt_full", component: qtActions, width: testCase.width,
                expected: testCase.textIconButton.width * 3 + Kirigami.Units.smallSpacing * 2 },
            // Small width, should display just the overflow button
            { tag: "qt_min", component: qtActions, width: 50, expected: testCase.iconButton.width },
            // Half window width, should display one action and overflow button
            { tag: "qt_half", component: qtActions, width: testCase.width / 2,
                expected: testCase.textIconButton.width + testCase.iconButton.width }
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
        waitForRendering(toolbar) // Allow events to propagate so toolbar can resize properly
        compare(toolbar.implicitWidth, data.expected)
    }
}
