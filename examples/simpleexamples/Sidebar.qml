/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Controls 2.3 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.7 as Kirigami

Kirigami.ApplicationWindow {
    id: root
    width: Kirigami.Units.gridUnit * 60
    height: Kirigami.Units.gridUnit * 40


    pageStack.initialPage: mainPageComponent
    globalDrawer: Kirigami.OverlayDrawer {
        id: drawer
        drawerOpen: true
        modal: false
        //leftPadding: Kirigami.Units.largeSpacing
        rightPadding: Kirigami.Units.largeSpacing
        contentItem: ColumnLayout {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 20

            Controls.Label {
                Layout.alignment: Qt.AlignHCenter
                text: "This is a sidebar"
                Layout.fillWidth: true
                width: parent.width - Kirigami.Units.smallSpacing * 2
                wrapMode: Text.WordWrap
            }
            Controls.Button {
                Layout.alignment: Qt.AlignHCenter
                text: "Modal"
                checkable: true
                Layout.fillWidth: true
                checked: false
                onCheckedChanged: drawer.modal = checked
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }
    contextDrawer: Kirigami.OverlayDrawer {
        id: contextDrawer
        drawerOpen: true
        edge: Qt.application.layoutDirection == Qt.RightToLeft ? Qt.LeftEdge : Qt.RightEdge
        modal: false
        leftPadding: Kirigami.Units.largeSpacing
        rightPadding: Kirigami.Units.largeSpacing
        contentItem: ColumnLayout {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 10

            Controls.Label {
                Layout.alignment: Qt.AlignHCenter
                text: "This is a sidebar"
                Layout.fillWidth: true
                width: parent.width - Kirigami.Units.smallSpacing * 2
                wrapMode: Text.WordWrap
            }
            Controls.Button {
                Layout.alignment: Qt.AlignHCenter
                text: "Modal"
                checkable: true
                Layout.fillWidth: true
                checked: false
                onCheckedChanged: contextDrawer.modal = checked
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }

    menuBar: Controls.MenuBar {
        Controls.Menu {
            title: qsTr("&File")
            Controls.Action { text: qsTr("&New...") }
            Controls.Action { text: qsTr("&Open...") }
            Controls.Action { text: qsTr("&Save") }
            Controls.Action { text: qsTr("Save &As...") }
            Controls.MenuSeparator { }
            Controls.Action { text: qsTr("&Quit") }
        }
        Controls.Menu {
            title: qsTr("&Edit")
            Controls.Action { text: qsTr("Cu&t") }
            Controls.Action { text: qsTr("&Copy") }
            Controls.Action { text: qsTr("&Paste") }
        }
        Controls.Menu {
            title: qsTr("&Help")
            Controls.Action { text: qsTr("&About") }
        }
    }
    header: Controls.ToolBar {
        contentItem: RowLayout {
            Controls.ToolButton {
                text: "Global ToolBar"
            }
            Item {
                Layout.fillWidth: true
            }
            Kirigami.ActionTextField {
                id: searchField

                placeholderText: "Search..."

                focusSequence: "Ctrl+F"
                leftActions: [
                    Kirigami.Action {
                        icon.name: "edit-clear"
                        visible: searchField.text != ""
                        onTriggered: {
                            searchField.text = ""
                            searchField.accepted()
                        }
                    },
                    Kirigami.Action {
                        icon.name: "edit-clear"
                        visible: searchField.text != ""
                        onTriggered: {
                            searchField.text = ""
                            searchField.accepted()
                        }
                    }
                ]
                rightActions: [
                    Kirigami.Action {
                        icon.name: "edit-clear"
                        visible: searchField.text != ""
                        onTriggered: {
                            searchField.text = ""
                            searchField.accepted()
                        }
                    },
                    Kirigami.Action {
                        icon.name: "anchor"
                        visible: searchField.text != ""
                        onTriggered: {
                            searchField.text = ""
                            searchField.accepted()
                        }
                    }
                ]

                onAccepted: console.log("Search text is " + searchField.text)
            }
        }
    }
    //Main app content
    Component {
        id: mainPageComponent
        MultipleColumnsGallery {}
    }
    footer: Controls.ToolBar {
        position: Controls.ToolBar.Footer
        Controls.Label {
            anchors.fill: parent
            verticalAlignment: Qt.AlignVCenter
            text: "Global Footer"
        }
    }
}
