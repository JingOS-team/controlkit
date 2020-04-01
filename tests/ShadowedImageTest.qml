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

    width: 600
    height: 800

    pageStack.initialPage: Kirigami.Page {
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0

        Column {
            anchors.centerIn: parent

            Kirigami.ShadowedImage {
                width: 400
                height: 300

                color: Kirigami.Theme.highlightColor

                source: "/usr/share/wallpapers/Next/contents/images/1024x768.jpg"

                radius: radiusSlider.value

                shadow.size: sizeSlider.value
                shadow.xOffset: xOffsetSlider.value
                shadow.yOffset: yOffsetSlider.value

                border.width: borderWidthSlider.value
                border.color: Kirigami.Theme.textColor

                corners.topLeftRadius: topLeftSlider.value
                corners.topRightRadius: topRightSlider.value
                corners.bottomLeftRadius: bottomLeftSlider.value
                corners.bottomRightRadius: bottomRightSlider.value
            }

            Kirigami.FormLayout {
                Item { Kirigami.FormData.isSection: true }

                Slider { id: radiusSlider; from: 0; to: 200; Kirigami.FormData.label: "Overall Radius" }
                Slider { id: topLeftSlider; from: -1; to: 200; value: -1; Kirigami.FormData.label: "Top Left Radius" }
                Slider { id: topRightSlider; from: -1; to: 200; value: -1; Kirigami.FormData.label: "Top Right Radius" }
                Slider { id: bottomLeftSlider; from: -1; to: 200; value: -1; Kirigami.FormData.label: "Bottom Left Radius" }
                Slider { id: bottomRightSlider; from: -1; to: 200; value: -1; Kirigami.FormData.label: "Bottom Right Radius" }

                Slider { id: sizeSlider; from: 0; to: 100; Kirigami.FormData.label: "Shadow Size" }
                Slider { id: xOffsetSlider; from: -100; to: 100; Kirigami.FormData.label: "Shadow X-Offset" }
                Slider { id: yOffsetSlider; from: -100; to: 100; Kirigami.FormData.label: "Shadow Y-Offset" }

                Slider { id: borderWidthSlider; from: 0; to: 50; Kirigami.FormData.label: "Border Width" }
            }
        }
    }
}
