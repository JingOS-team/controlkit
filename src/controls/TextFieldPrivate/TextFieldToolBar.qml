/*
    SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2021 Lele Huan <huanlele@jingos.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

pragma Singleton

import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Controls 2.14
import org.kde.kirigami 2.15 as Kirigami
import jingos.display 1.0

Kirigami.JArrowPopup {
    id: root

    property Item controlRoot
    parent: controlRoot ? controlRoot.Window.contentItem : undefined
    modal: false

    focus: false
    closePolicy: Popup.NoAutoClose
    property bool shouldBeVisible: controlRoot ?  controlRoot.showToolTip : false
    property bool showTop: true

    blurBackground.backgroundOpacity : 1.0
    blurBackground.useBlur : false
    blurBackground.backgroundColor: Kirigami.JTheme.textEditTipBackground
    blurBackground.arrowPos: showTop ? Kirigami.JRoundRectangle.ARROW_BOTTOM : Kirigami.JRoundRectangle.ARROW_TOP
    blurBackground.arrowX: width * 0.5
    blurBackground.arrowWidth: JDisplay.dp(16)
    blurBackground.arrowHeight: JDisplay.dp(8)

    leftPadding:JDisplay.dp(4)
    rightPadding:JDisplay.dp(4)
    topPadding: (blurBackground.arrowPos === Kirigami.JRoundRectangle.ARROW_TOP ? blurBackground.arrowHeight : 0) + JDisplay.dp(4)
    bottomPadding: (blurBackground.arrowPos === Kirigami.JRoundRectangle.ARROW_BOTTOM ? blurBackground.arrowHeight : 0) + JDisplay.dp(4)



    visible:  controlRoot ? shouldBeVisible : false;
    //visible:  controlRoot ? shouldBeVisible  && (controlRoot.selectedText.length > 0 || controlRoot.canPaste) : false;

    x: {
        if(parent){
            var startPos = controlRoot.positionToRectangle(controlRoot.selectionStart);
            var endPos = controlRoot.positionToRectangle(controlRoot.selectionEnd);
            var cursorPos = controlRoot.cursorRectangle

            var midPos = 0;
            if(startPos.x < 0 && endPos.x > controlRoot.width - controlRoot.rightPadding){
                midPos = (controlRoot.width - controlRoot.rightPadding - controlRoot.leftPadding) / 2
            } else if(startPos.x < 0) {
                midPos = (cursorPos.x - controlRoot.leftPadding) / 2
            } else if(endPos.x > controlRoot.width - controlRoot.rightPadding){
                midPos = cursorPos.x + (controlRoot.width - controlRoot.rightPadding - cursorPos.x) / 2
            } else {
                midPos = startPos.x + (endPos.x - startPos.x) / 2;
            }

            var mapPos = controlRoot.mapToItem(root.parent, midPos, 0).x;
            var wantPos = Math.max(0, mapPos - root.width / 2);
            var finalPos = Math.min(wantPos, parent.width - root.width);
            return finalPos;
        } else {
            return 0;
        }
    }
    y: {

        if(parent){
            var startPos = controlRoot.positionToRectangle(controlRoot.selectionStart);
            var mapPos = controlRoot.mapToItem(root.parent, 0, startPos.y).y;
            var wantPos = mapPos - root.height - 10;
            if(wantPos < 0){
                mapPos = controlRoot.mapToItem(root.parent, 0, startPos.y + startPos.height).y;
                wantPos = mapPos + 10;
                root.showTop = false;
            } else {
                root.showTop = true;
            }

            return wantPos;
        } else {
            return 0;
        }

    }

    contentItem: RowLayout {
        id:rl

        Kirigami.JButton{
            id:selBtn
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: JDisplay.dp(16)
            backgroundColor:"transparent"
            fontColor: "#FFFFFFFF"
            text:i18nd("kirigami-controlkit", "select")
            visible: controlRoot && controlRoot.selectedText.length === 0 && (!controlRoot.hasOwnProperty("echoMode") || controlRoot.echoMode === TextInput.Normal)

            onClicked: {
                controlRoot.selectWord();

            }
        }

        Kirigami.JButton{
            id:selAllBtn
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: JDisplay.dp(16)
            fontColor: "#FFFFFFFF"
            backgroundColor:"transparent"
            text:i18nd("kirigami-controlkit", "select all")
            visible: controlRoot && controlRoot.selectedText.length < controlRoot.text.length && (!controlRoot.hasOwnProperty("echoMode") || controlRoot.echoMode === TextInput.Normal)

            onClicked: {
                controlRoot.selectAll();

            }
        }

        Kirigami.JButton{
            id:cutBtn
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: JDisplay.dp(16)
            fontColor: "#FFFFFFFF"
            backgroundColor:"transparent"
            text:i18nd("kirigami-controlkit", "cut")
            visible: controlRoot && controlRoot.selectedText.length > 0 && (!controlRoot.hasOwnProperty("echoMode") || controlRoot.echoMode === TextInput.Normal)

            onClicked: {
                controlRoot.cut();

            }
        }

        Kirigami.JButton {
            focusPolicy: Qt.NoFocus
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: JDisplay.dp(16)
            fontColor: "#FFFFFFFF"
            backgroundColor:"transparent"
            text:i18nd("kirigami-controlkit", "copy")
            visible: {
                controlRoot && controlRoot.selectedText.length > 0 && (!controlRoot.hasOwnProperty("echoMode") || controlRoot.echoMode === TextInput.Normal)
            }

            onClicked: {
                controlRoot.copy();
            }
        }

        Kirigami.JButton {
            focusPolicy: Qt.NoFocus
            Layout.alignment: Qt.AlignVCenter
            text:i18nd("kirigami-controlkit", "paste")
            font.pixelSize: JDisplay.dp(16)
            fontColor: "#FFFFFFFF"
            backgroundColor:"transparent"
            visible: controlRoot && controlRoot.canPaste
            onClicked: {
                controlRoot.paste();
            }
        }
    }

}

