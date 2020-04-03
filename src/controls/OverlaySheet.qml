/*
 *  SPDX-FileCopyrightText: 2016 by Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.5
import org.kde.kirigami 2.12 as Kirigami
import "private"
import "templates" as T

/**
 * An overlay sheet that covers the current Page content.
 * Its contents can be scrolled up or down, scrolling all the way up or
 * all the way down, dismisses it.
 * Use this for big, modal dialogs or information display, that can't be
 * logically done as a new separate Page, even if potentially
 * are taller than the screen space.
 */
T.OverlaySheet {
    id: root

    leftInset: 0
    topInset: -Kirigami.Units.smallSpacing
    rightInset: 0
    bottomInset: -Kirigami.Units.smallSpacing

    background: Item {
        Kirigami.ShadowedRectangle {
            // HACK to make it overlap the border perfectly
            anchors{
                fill: parent
                margins: 0.5
            }
            radius: Kirigami.Units.smallSpacing
            color: Kirigami.Theme.backgroundColor

            shadow {
                size: Kirigami.Units.gridUnit*2
                yOffset: 2
                color: Qt.rgba(0, 0, 0, 0.8)
            }
        }

        // FIXME: the border of ShadowedRectangle isn't correctly pixel aligned, fix and replace this asap
        Rectangle {
            anchors.fill: parent
            radius: Kirigami.Units.smallSpacing
            color: "transparent"

            border {
                width: Math.floor(Kirigami.Units.devicePixelRatio)
                color: Qt.tint(Kirigami.Theme.textColor, Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8))
            }
        }
    }
}
