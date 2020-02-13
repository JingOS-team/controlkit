/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.6
import org.kde.kirigami 2.11 as Kirigami

Rectangle {
    color: Kirigami.Theme.backgroundColor

    CornerShadow {
        id: topLeft
        corner: Qt.BottomRightCorner
        z: -1
        anchors {
            right: parent.left
            bottom: parent.top
            margins: margin
            bottomMargin: margin - 1
        }
    }
    CornerShadow {
        id: topRight
        corner: Qt.BottomLeftCorner
        z: -1
        anchors {
            left: parent.right
            bottom: parent.top
            margins: margin
            bottomMargin: margin - 1
        }
    }
    CornerShadow {
        id: bottomLeft
        corner: Qt.TopRightCorner
        z: -1
        anchors {
            right: parent.left
            top: parent.bottom
            margins: margin
        }
    }
    CornerShadow {
        id: bottomRight
        corner: Qt.TopLeftCorner
        z: -1
        anchors {
            left: parent.right
            top: parent.bottom
            margins: margin
        }
    }
    EdgeShadow {
        edge: Qt.BottomEdge
        z: -1
        anchors {
            left: bottomLeft.right
            right: bottomRight.left
            bottom: parent.top
            bottomMargin: - 1
        }
    }
    EdgeShadow {
        edge: Qt.TopEdge
        z: -1
        anchors {
            left: topLeft.right
            right: topRight.left
            top: parent.bottom
        }
    }
    EdgeShadow {
        edge: Qt.LeftEdge
        z: -1
        anchors {
            top: topRight.bottom
            bottom: bottomRight.top
            left: parent.right
        }
    }
    EdgeShadow {
        edge: Qt.RightEdge
        z: -1
        anchors {
            top: topLeft.bottom
            bottom: bottomLeft.top
            right: parent.left
        }
    }
}

