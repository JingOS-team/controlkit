/*
 *   Copyright 2017 Marco Martin <mart@kde.org>
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

import QtQuick 2.5
import QtQuick.Templates 2.0 as T2
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.1 as Kirigami
import "private"

/**
 * An item that can be used as an header for a ListView.
 * It will play nice with the margin policies of ScrollablePage and can
 * automatically shrink when the list is scrolled, like the behavior
 * of list headers in many mobile applications.
 * It provides some default content: a title and an optional background image
 * @since 2.1
 */
Kirigami.AbstractItemViewHeader {
    id: root
    property alias title: heading.text
    property alias color: heading.color

    property alias backgroundImage: image

    maximumHeight: (backgroundImage.status == Image.Ready ? 10 : 6) * Kirigami.Units.gridUnit

    background: Rectangle {
        color: Kirigami.Theme.backgroundColor
        Image {
            id: image
            anchors {
                fill: parent
                bottomMargin: rect.height
            }
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }
        EdgeShadow {
            edge: root.view.headerPositioning == ListView.InlineHeader ? Qt.BottomEdge : Qt.TopEdge
            anchors {
                right: parent.right
                left: parent.left
                top: root.view.headerPositioning == ListView.InlineHeader ? undefined : parent.bottom
                bottom: root.view.headerPositioning == ListView.InlineHeader ? parent.top : undefined
            }
        }

        property Page page: function findPage() {
            var obj = root;
            while(obj && !obj.hasOwnProperty("title") && !obj.hasOwnProperty("isCurrentPage")) {
                obj = obj.parent
            }
            return obj;
        }
        Rectangle {
            id: rect
            color: page.isCurrentPage ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
            height: Kirigami.Units.smallSpacing
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
        }
    }

    contentItem: Item {
        Kirigami.Heading {
            id: heading
            anchors {
                fill: parent
                margins:  Kirigami.Units.smallSpacing
            }

            height: undefined
            text: page.title
            fontSizeMode: Text.Fit
            minimumPointSize: 10
            font.pointSize: 30
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignBottom
            color: root.backgroundImage.status === Image.Ready ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.highlightColor
            opacity: 1
            elide: Text.ElideRight

            layer.enabled: root.backgroundImage.status === Image.Ready
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 2
                radius: Kirigami.Units.smallSpacing*2
                samples: 32
                color: Qt.rgba(0, 0, 0, 0.7)
            }
        }
    }
}

