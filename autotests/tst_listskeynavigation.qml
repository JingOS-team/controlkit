/*
 *  SPDX-FileCopyrightText: 2016 Aleix Pol Gonzalez <aleixpol@kde.org>
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
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
    name: "KeyboardListsNavigation"

    KeyboardListTest {
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
        id: spyCurrentIndex
        target: mainWindow.pageStack.currentItem.flickable
        signalName: "currentIndexChanged"
    }

    function initTestCase() {
        mainWindow.show()
    }

    function cleanupTestCase() {
        mainWindow.close()
    }

    function test_press() {
        compare(mainWindow.pageStack.depth, 1)
        compare(mainWindow.pageStack.currentIndex, 0)
        if (!mainWindow.active)
            spyActive.wait(5000)
        verify(mainWindow.active)
        compare(mainWindow.pageStack.currentItem.flickable.currentIndex, 0)
        keyClick(Qt.Key_Down)
        spyCurrentIndex.wait()
        compare(mainWindow.pageStack.currentItem.flickable.currentIndex, 1)
    }
}
