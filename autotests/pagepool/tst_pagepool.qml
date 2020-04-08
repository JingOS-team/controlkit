/*
 *  SPDX-FileCopyrightText: 2020 Mason McParlane <mtmcp@outlook.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.1
import org.kde.kirigami 2.11 as Kirigami
import QtTest 1.0

TestCase {
    id: testCase
    width: 400
    height: 400
    name: "PagePool"

    function initTestCase() {
        mainWindow.show()
    }

    function cleanupTestCase() {
        mainWindow.close()
    }

    function applicationWindow() { return mainWindow; }

    Kirigami.ApplicationWindow {
        id: mainWindow
        width: 480
        height: 360
    }

    Kirigami.PagePool {
        id: pool
    }

    function init() {
        mainWindow.pageStack.clear()
        pool.clear()
    }

    // Queries added to page URLs ensure the PagePool can
    // have multiple instances of TestPage.qml

    Kirigami.PagePoolAction {
        id: loadPageAction
        pagePool: pool
        pageStack: mainWindow.pageStack
        page: "TestPage.qml?action=loadPageAction"
    }

    function test_loadPage () {
        var expectedUrl = "TestPage.qml?action=loadPageAction"
        compare(mainWindow.pageStack.depth, 0)
        loadPageAction.trigger()
        compare(mainWindow.pageStack.depth, 1)
        verify(pool.lastLoadedUrl.toString().endsWith(expectedUrl))
        compare(mainWindow.pageStack.currentItem.title, "INITIAL TITLE")
    }

    Kirigami.PagePoolAction {
        id: loadPageActionWithProps
        pagePool: pool
        pageStack: mainWindow.pageStack
        page: "TestPage.qml?action=loadPageActionWithProps"
        initialProperties: {
            return {title: "NEW TITLE" }
        }
    }

    function test_loadPageInitialPropertyOverride () {
        var expectedUrl = "TestPage.qml?action=loadPageActionWithProps"
        compare(mainWindow.pageStack.depth, 0)
        loadPageActionWithProps.trigger()
        compare(mainWindow.pageStack.depth, 1)
        verify(pool.lastLoadedUrl.toString().endsWith(expectedUrl))
        compare(mainWindow.pageStack.currentItem.title, "NEW TITLE")
        compare(pool.lastLoadedItem.title, "NEW TITLE")
    }

    Kirigami.PagePoolAction {
        id: loadPageActionPropsNotObject
        pagePool: pool
        pageStack: mainWindow.pageStack
        page: "TestPage.qml?action=loadPageActionPropsNotObject"
        initialProperties: "This is a string not an object..."
    }

    function test_loadPageInitialPropertiesWrongType () {
        var expectedUrl = "TestPage.qml?action=loadPageAction"
        compare(mainWindow.pageStack.depth, 0)
        loadPageAction.trigger()
        loadPageActionPropsNotObject.trigger()
        compare(mainWindow.pageStack.depth, 1)
        verify(pool.lastLoadedUrl.toString().endsWith(expectedUrl))
    }

    Kirigami.PagePoolAction {
        id: loadPageActionPropDoesNotExist
        pagePool: pool
        pageStack: mainWindow.pageStack
        page: "TestPage.qml?action=loadPageActionPropDoesNotExist"
        initialProperties: {
            return { propDoesNotExist: "PROP-NON-EXISTANT" }
        }
    }

    function test_loadPageInitialPropertyNotExistOkay () {
        var expectedUrl = "TestPage.qml?action=loadPageActionPropDoesNotExist"
        loadPageActionPropDoesNotExist.trigger()
        verify(pool.lastLoadedUrl.toString().endsWith(expectedUrl))
    }
}
