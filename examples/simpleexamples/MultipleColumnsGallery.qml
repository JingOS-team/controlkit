/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
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

import QtQuick 2.0
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.8

ScrollablePage {
    id: page
    Layout.fillWidth: true
    implicitWidth: Units.gridUnit * (Math.floor(Math.random() * 35) + 8)

    title: "Multiple Columns"

    actions {
        contextualActions: [
            Action {
                text:"Action for buttons"
                iconName: "bookmarks"
                onTriggered: print("Action 1 clicked")
            },
            Action {
                text:"Action 2"
                iconName: "folder"
                enabled: false
            }
        ]
    }

    ColumnLayout {
        width: page.width
        spacing: Units.smallSpacing

        Controls.Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: "This page is used to test multiple columns: you can push and pop an arbitrary number of pages, each new page will have a random implicit width between 8 and 35 grid units.\nIf you enlarge the window enough, you can test how the application behaves with multiple columns."
        }
        Item {
            Layout.minimumWidth: Units.gridUnit *2
            Layout.minimumHeight: Layout.minimumWidth
        }
        Controls.Label {
            Layout.alignment: Qt.AlignHCenter
            text: "Page implicitWidth: " + page.implicitWidth
        }
        Controls.Button {
            text: "Push Another Page"
            Layout.alignment: Qt.AlignHCenter
            onClicked: pageStack.push(Qt.resolvedUrl("MultipleColumnsGallery.qml"));
        }
        Controls.Button {
            text: "Pop A Page"
            Layout.alignment: Qt.AlignHCenter
            onClicked: pageStack.pop();
        }
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Controls.TextField {
                id: edit
                text: page.title
            }
            Controls.Button {
                text: "Rename Page"
                onClicked: page.title = edit.text;
            }
        }
        SearchField {
            anchors.horizontalCenter: parent.horizontalCenter
            id: searchField
            onAccepted: console.log("Search text is " + searchField.text);
        }
        PasswordField {
            anchors.horizontalCenter: parent.horizontalCenter
            id: passwordField
            onAccepted: console.log("Password")
        }
    }
}
