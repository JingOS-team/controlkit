/*
 *  SPDX-FileCopyrightText: 2016 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.1
import org.kde.kirigami 2.4 as Kirigami
import QtTest 1.0
import "../tests"

TestCase {
    id: testCase
    width: 400
    height: 400
    name: "KeyboardNavigation"

    KeyboardTest {
        id: mainWindow
        width: 480
        height: 360
    }

    SignalSpy {
        id: spyActive
        target: mainWindow
        signalName: "activeChanged"
    }
    SignalSpy {
        id: spyLastKey
        target: mainWindow.pageStack.currentItem
        signalName: "lastKeyChanged"
    }

    function initTestCase() {
        mainWindow.show()
    }

    function cleanupTestCase() {
        mainWindow.close()
    }

    function test_press() {
        compare(mainWindow.pageStack.depth, 2)
        compare(mainWindow.pageStack.currentIndex, 1)
        if (!mainWindow.active)
            spyActive.wait(5000)
        verify(mainWindow.active)
        keyClick("A")
        spyLastKey.wait()
        compare(mainWindow.pageStack.currentItem.lastKey, "A")
        keyClick(Qt.Key_Left, Qt.AltModifier)
        compare(mainWindow.pageStack.currentIndex, 0)
        compare(mainWindow.pageStack.currentItem.lastKey, "")
        keyClick("B")
        spyLastKey.wait()
        compare(mainWindow.pageStack.currentItem.lastKey, "B")
    }
}
