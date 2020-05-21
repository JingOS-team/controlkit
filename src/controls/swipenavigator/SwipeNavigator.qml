/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import org.kde.kirigami 2.13 as Kirigami

/**
 * SwipeNavigator is a control providing for lateral navigation.
 * 
 * @include swipenavigator/main.qml
 */
GridLayout {
    id: swipeNavigatorRoot
    rowSpacing: 0
    columns: 1

    /**
     * pages: list<Kirigami.Page>
     *
     * A list of pages to swipe between.
     */
    default property list<Kirigami.Page> pages

    /**
     * layers: StackView
     *
     * The StackView holding the core item, allowing users of a SwipeNavigator
     * in order to push pages on top of the SwipeNavigator.
     */
    property alias layers: stackView

    /**
     * big: bool
     *
     * Whether or not to present the SwipeNavigator in a larger format
     * suitable for rendering on televisions.
     */
    property bool big: false

    /**
     * header: Item
     *
     * The item that will be displayed before the tabs.
     */
    property Component header: Item {visible: false}

    /**
     * footer: Item
     *
     * The item that will be displayed after the tabs.
     */
    property Component footer: Item {visible: false}

    QtObject {
        id: _gridManager
        readonly property bool tall: (_header.width + __main.item.width + Math.abs(__main.offset) + _footer.width) > swipeNavigatorRoot.width
        readonly property int rowOne: Kirigami.Settings.isMobile ? 1 : 0
        readonly property int rowTwo: Kirigami.Settings.isMobile ? 0 : 1
        readonly property int rowDirection: Kirigami.Settings.isMobile ? 1 : -1
        property Item item: Item {
            states: [
                State {
                    name: "small"
                    when: !_gridManager.tall
                },
                State {
                    name: "tall"
                    when: _gridManager.tall
                }
            ]
            transitions: [
                Transition {
                    to: "tall"
                    ScriptAction {
                        script: {
                            // Let's take these out of the layout first...
                            _dummyOne.visible = false
                            _dummyTwo.visible = false
                            // Now we move the header and footer up
                            _header.Layout.row += _gridManager.rowDirection
                            _footer.Layout.row += _gridManager.rowDirection
                            // Now that the header and footer are out of the way,
                            // let's expand the tabs
                            __main.Layout.column--
                            __main.Layout.columnSpan = 3
                        }
                    }
                },
                Transition {
                    to: "small"
                    ScriptAction {
                        script: {
                            // Let's move the tabs back to where they belong
                            __main.Layout.columnSpan = 1
                            __main.Layout.column++
                            // Move the header and footer down into the empty space
                            _header.Layout.row -= _gridManager.rowDirection
                            _footer.Layout.row -= _gridManager.rowDirection
                            // Now we can bring these guys back in
                            _dummyOne.visible = false
                            _dummyTwo.visible = false
                        }
                    }
                }
            ]
        }
    }

    ToolBar {
        id: topToolBar

        padding: 0
        bottomPadding: 1
        position: Kirigami.Settings.isMobile ? ToolBar.Footer : ToolBar.Header

        Layout.row: Kirigami.Settings.isMobile ? 1 : 0

        GridLayout {
            id: _grid

            rowSpacing: 0
            columnSpacing: 0
            anchors.fill: parent
            rows: 2
            columns: 3

            // Row one
            Item { id: _spacer; Layout.row: 0; Layout.column: 1; Layout.fillWidth: true }
            Item { id: _dummyOne; Layout.row: 0; Layout.column: 0 }
            Item { id: _dummyTwo; Layout.row: 0; Layout.column: 2 }

            // Row two
            Loader { id: _header; sourceComponent: swipeNavigatorRoot.header; Layout.row: 1; Layout.column: 0 }
            PrivateSwipeTabBarLoader {
                id: __main
                readonly property int offset: _header.width - _footer.width
                readonly property int effectiveOffset: _gridManager.tall ? 0 : offset
                Layout.rightMargin: effectiveOffset > 0 ? effectiveOffset : 0
                Layout.leftMargin: effectiveOffset < 0 ? -effectiveOffset : 0
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                Layout.row: 1
                Layout.column: 1
                states: [
                    State {
                        name: "shouldScroll"
                        when: __main.shouldScroll
                        PropertyChanges { target: __main; Layout.fillWidth: true }
                    }
                ]
            }
            Loader { id: _footer; sourceComponent: swipeNavigatorRoot.footer; Layout.row: 1; Layout.column: 2 }
        }

        Layout.fillWidth: true

        Accessible.role: Accessible.PageTabList
    }

    StackView {
        id: stackView

        Layout.fillWidth: true
        Layout.fillHeight: true

        Layout.row: Kirigami.Settings.isMobile ? 0 : 1

        Kirigami.ColumnView {
            id: columnView
            columnResizeMode: Kirigami.ColumnView.SingleColumn

            contentChildren: swipeNavigatorRoot.pages
            anchors.fill: parent

            Component.onCompleted: {
                columnView.currentIndex = 0
            }
        }
    }
}
