/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.12

import org.kde.kirigami 2.12 as Kirigami

Kirigami.ApplicationWindow {
    id: window

    width: 500
    height: 500

    pageStack.initialPage: Kirigami.Page {
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0

        Column {
            anchors.centerIn: parent

            Kirigami.ShadowedRectangle {
                width: 400
                height: 300

                color: Kirigami.Theme.highlightColor

                radius: radiusSlider.value

                shadow.size: sizeSlider.value
                shadow.xOffset: xOffsetSlider.value
                shadow.yOffset: yOffsetSlider.value

                border.width: borderWidthSlider.value
                border.color: Kirigami.Theme.textColor
            }

            Item { width: 1; height: Kirigami.Units.gridUnit }

            Slider {
                id: sizeSlider

                from: 0
                to: 100
            }

            Slider {
                id: radiusSlider

                from: 0
                to: 200
            }

            Slider {
                id: xOffsetSlider

                from: -100
                to: 100
            }

            Slider {
                id: yOffsetSlider

                from: -100
                to: 100
            }

            Slider {
                id: borderWidthSlider

                from: 0
                to: 50
            }
        }
    }
}
