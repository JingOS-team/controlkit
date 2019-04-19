/*
 *   Copyright 2019 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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
