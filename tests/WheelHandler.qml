/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.3 as Controls
import org.kde.kirigami 2.9 as Kirigami

Controls.ScrollView {
    id: root
    width: Kirigami.Units.gridUnit * 30
    height: Kirigami.Units.gridUnit * 40

    readonly property Flickable flickable: contentItem


    Kirigami.WheelHandler {
        target: flickable
        onWheel: {
            if (wheel.modifiers & Qt.ControlModifier) {
                wheel.accepted = true;
                var factor = 1.2;

                // Shrink
                if (wheel.angleDelta.y < 0 || wheel.pixelDelta.y < 0) {
                    factor = 0.83
                }

                contents.zoom = Math.max(contents.zoom * factor, 1);
                flickable.resizeContent(contents.implicitWidth , contents.implicitHeight, contents.mapFromItem(flickable, wheel.x, wheel.y));
                flickable.contentWidth = contents.implicitWidth;
                flickable.contentHeight = contents.implicitHeight;

                flickable.returnToBounds();
            }
        }
    }

    Item {
        id: contents

        property real zoom: 1
        implicitWidth: root.width * zoom
        implicitHeight: Kirigami.Units.gridUnit * 60 * zoom
        Rectangle {
            anchors {
                fill: parent
                margins: Kirigami.Units.gridUnit * 2
            }
            color: "red"
            Controls.Label {
                anchors.centerIn: parent
                text: contents.width+"x"+contents.height
            }
        }
    }
}
