/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtTest 1.0
import org.kde.kirigami 2.11 as Kirigami

TestCase {
    id: testCase
    name: "IconTests"

    width: 400
    height: 400
    visible: true

    when: windowShown

    Component { id: emptyIcon; Kirigami.Icon { } }
    Component { id: sourceOnlyIcon; Kirigami.Icon { source: "document-new" } }
    Component { id: sizeOnlyIcon; Kirigami.Icon { width: 50; height: 50 } }
    Component { id: sizeSourceIcon; Kirigami.Icon { width: 50; height: 50; source: "document-new" } }
    Component { id: minimalSizeIcon; Kirigami.Icon { width: 1; height: 1; source: "document-new" } }

    function test_create_data() {
        return [
            { tag: "Empty", component: emptyIcon },
            { tag: "Source Only", component: sourceOnlyIcon },
            { tag: "Size Only", component: sizeOnlyIcon },
            { tag: "Size & Source", component: sizeSourceIcon },
            { tag: "Minimal Size", component: minimalSizeIcon }
        ]
    }

    // Test creation of Icon objects.
    // It should not crash when certain properties are not specified and also
    // should still work when they are.
    function test_create(data) {
        var icon = createTemporaryObject(data.component, testCase)
        verify(icon)
        verify(waitForRendering(icon))
    }
}
