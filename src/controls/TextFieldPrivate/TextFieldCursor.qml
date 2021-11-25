/*
    SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2021 Lele Huan <huanlele@jingos.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.1
import org.kde.kirigami 2.15 as Kirigami
import jingos.display 1.0
Item {
    id: root
    width: JDisplay.dp(1) //<-important that this is actually a single device pixel
    height: target  ? target.contentHeight : 0


    property Item target

    property bool selectionStartHandle: false
    property bool showHandle: false

    property bool isCursorDelegate: false
    property color cursorColor: Kirigami.JTheme.textFieldBorder
    signal clicked()


    Rectangle {
        width: JDisplay.dp(2)
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            bottom: parent.bottom
        }
        color: root.cursorColor
        //radius: width
        Rectangle {
            width: JDisplay.dp(6)
            height: width
            visible: isCursorDelegate === false || showHandle === true
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: selectionStartHandle === true ? parent.top : undefined
                top: selectionStartHandle === true ? undefined : parent.bottom
            }
            radius: width / 2
            color:root.cursorColor
        }
        MouseArea {
            anchors {
                fill: parent
                margins: JDisplay.dp(-10)
            }
            preventStealing: true

            onClicked: {
                if(isCursorDelegate){
                    root.clicked();
                }
            }

            onPositionChanged: {
                var pos = mapToItem(target, mouse.x, mouse.y);
                pos = target.positionAt(pos.x, pos.y);

                if (target.selectedText.length > 0) {
                    if (selectionStartHandle) {
                        target.select(target.selectionEnd, Math.min(pos, target.selectionEnd - 1));
                    } else {
                         target.select(target.selectionStart, Math.max(pos, target.selectionStart + 1));
                    }
                } else {
                    target.cursorPosition = pos;
                }
            }
        }
    }
}
    
