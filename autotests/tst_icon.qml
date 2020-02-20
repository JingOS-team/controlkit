/*
 *   Copyright 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
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
