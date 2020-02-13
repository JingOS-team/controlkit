/*
 *  SPDX-FileCopyrightText: 2017 Eike Hein <hein@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1

import org.kde.kirigami 2.4 as Kirigami

Kirigami.ApplicationWindow {
    id: root

    property int defaultColumnWidth: Kirigami.Units.gridUnit * 13
    property int columnWidth: defaultColumnWidth

    pageStack.defaultColumnWidth: columnWidth
    pageStack.initialPage: [firstPageComponent, secondPageComponent]

    MouseArea {
        id: dragHandle

        visible: pageStack.wideMode

        anchors.top: parent.top
        anchors.bottom: parent.bottom

        x: columnWidth - (width / 2)
        width: Kirigami.Units.devicePixelRatio * 2

        property int dragRange: (Kirigami.Units.gridUnit * 5)
        property int _lastX: -1

        cursorShape: Qt.SplitHCursor

        onPressed: _lastX = mouseX

        onPositionChanged: {
            if (mouse.x > _lastX) {
                columnWidth = Math.min((defaultColumnWidth + dragRange),
                    columnWidth + (mouse.x - _lastX));
            } else if (mouse.x < _lastX) {
                columnWidth = Math.max((defaultColumnWidth - dragRange),
                    columnWidth - (_lastX - mouse.x));
            }
        }

        Rectangle {
            anchors.fill: parent

            color: "blue"
        }
    }

    Component {
        id: firstPageComponent

        Kirigami.Page {
            id: firstPage

            background: Rectangle { color: "red" }
        }
    }

    Component {
        id: secondPageComponent

        Kirigami.Page {
            id: secondPage

            background: Rectangle { color: "green" }
        }
    }
}
