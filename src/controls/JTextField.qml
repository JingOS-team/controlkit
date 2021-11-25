/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.15
import QtQuick.Templates 2.12 as  T
import "TextFieldPrivate" as TextFieldPrivate

import org.kde.kirigami 2.15 as Kirigami
import jingos.display 1.0
T.TextField {
    id: control

    property bool clearButtonShown: true

    property bool revealPasswordButtonShown: false

    property bool showCursorHandle: false
    property bool showToolTip: false

    // this takes into account kiosk restriction
    readonly property bool __effectiveRevealPasswordButtonShown: revealPasswordButtonShown && (echoMode == TextInput.Normal || control.text.length > 0)

    property color bgColor: JTheme.textFieldBackground
    property int borderWidth: JDisplay.dp(1)
    property int bgRadius: JDisplay.dp(4)

    implicitWidth: (implicitBackgroundWidth + leftInset + rightInset)
                   || (Math.max(contentWidth, placeholder.implicitWidth, 100) + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding,
                             placeholder.implicitHeight + topPadding + bottomPadding)

    //when set password，view of point's height will bigger 1Pixel
    //implicitHeight: fontMetrics.height + textField.topPadding + textField.bottomPadding + JDisplay.dp(1)

    leftPadding: JDisplay.dp(7) + (LayoutMirroring.enabled ? inlineButtonRow.width : 0)
    topPadding: JDisplay.dp(5)
    rightPadding: JDisplay.dp(6) + (LayoutMirroring.enabled ? 0 : inlineButtonRow.width)
    bottomPadding: JDisplay.dp(5)


    echoMode: revealPasswordButtonShown ? TextInput.Password : TextInput.Normal
    passwordMaskDelay : revealPasswordButtonShown ? 500 : 0
    font.letterSpacing : echoMode === TextInput.Password ? JDisplay.dp(5) : 0
    //0x25cf
    passwordCharacter:  String.fromCharCode(0x2022, 16)

    color: JTheme.majorForeground
    selectionColor: Kirigami.JTheme.textFieldSelectColor
    selectedTextColor: control.color
    verticalAlignment: TextInput.AlignVCenter
    opacity: control.enabled ? 1 : 0.6

    // Work around Qt bug where NativeRendering breaks for non-integer scale factors
    // https://bugreports.qt.io/browse/QTBUG-70481
    renderType: Screen.devicePixelRatio % 1 !== 0 ? Text.QtRendering : Text.NativeRendering

    selectByMouse: false
    cursorDelegate:  mobileCursor

    onLeftPaddingChanged:{
        var align = control.verticalAlignment;
        control.verticalAlignment = TextInput.AlignTop
        control.verticalAlignment = align;
    }
    onRightPaddingChanged: {
        var align = control.verticalAlignment;
        control.verticalAlignment = TextInput.AlignTop
        control.verticalAlignment = align;
    }

    Component {
        id: mobileCursor
        TextFieldPrivate.TextFieldCursor {
            id:cursorItem
            target: control
            visible: control.selectedText.length === 0 && control.activeFocus
            isCursorDelegate: true
            showHandle: control.showCursorHandle && control.text.length > 0
            onClicked: {
                if(control.echoMode === TextInput.Password){
                    return;
                }

                control.showCursorHandle = true;
                if(showHandle){
                    control.showToolTip = true;
                    hideToolTipTimer.restart();
                }
            }

            Timer{
                id: timer
                interval: 700
                repeat: true
                running: cursorItem.visible && cursorItem.showHandle === false

                onRunningChanged: {
                    if(running === false){
                        cursorItem.cursorColor = Kirigami.JTheme.textFieldBorder
                    }
                }

                onTriggered: {
                    if(cursorItem.cursorColor === Kirigami.JTheme.textFieldBorder){
                        cursorItem.cursorColor = "transparent"
                    } else {
                        cursorItem.cursorColor = Kirigami.JTheme.textFieldBorder
                    }
                }
            }
        }
    }

    Timer{
        id:hideToolTipTimer
        interval: 5000
        onTriggered: {
            if(control.selectedText.length <= 0)
                control.showToolTip = false;
        }
    }

    TextFieldPrivate.TextFieldCursor {
        id:startHandle
        target: control
        selectionStartHandle: true
        visible: target.selectedText.length > 0 &&  (x >= -JDisplay.dp(10) && x <= control.width) && selectByMouse === false
        property rect rect :Qt.rect(0, 0, 0, 0)
        //FIXME: this magic values seem to be always valid, for every font,every dpi, every scaling
        x: rect.x + control.leftPadding  //5
        y : rect.y + JDisplay.dp(6)
    }

    TextFieldPrivate.TextFieldCursor {
        id:endHandle
        target: control
        selectionStartHandle: false
        visible: target.selectedText.length > 0 &&  (x >= 0 && x <= (control.width - control.rightPadding + JDisplay.dp(10))) && selectByMouse === false
        property rect rect :Qt.rect(0, 0, 0, 0)
        //FIXME: this magic values seem to be always valid, for every font,every dpi, every scaling
        x : rect.x + control.leftPadding   //5
        y : rect.y + JDisplay.dp(6)
    }

    onSelectionStartChanged: {
        if(control.selectedText.length > 0 && selectByMouse === false){
            delaySetHandlePosTimer.restart();
        }
    }

    onSelectionEndChanged: {
        if(control.selectedText.length > 0 && selectByMouse === false){
            delaySetHandlePosTimer.restart();
        }
    }

    onCursorPositionChanged: {
        if(control.selectedText.length > 0 && selectByMouse === false){
            delaySetHandlePosTimer.restart();
        }
    }

    Timer{
        id:delaySetHandlePosTimer
        interval: 10
        onTriggered: {
            var startPos = control.positionToRectangle(control.selectionStart)
            var endPos = control.positionToRectangle(control.selectionEnd)
            startHandle.rect = startPos;
            endHandle.rect = endPos;
        }
    }

    onActiveFocusChanged: {
        if(activeFocus){
            TextFieldPrivate.TextFieldToolBar.controlRoot = control;
        }
    }

    onTextChanged: {
        control.showCursorHandle = false;
    }

    onPressed: {
        control.showToolTip = false;
        control.showCursorHandle = true;
    }

    onPressAndHold: {
        forceActiveFocus();
        cursorPosition = positionAt(event.x, event.y);
        if(control.echoMode === TextInput.Password){
            return;
        }
        selectWord();
        control.showToolTip = true;
        hideToolTipTimer.stop();
    }


    Label {
        id: placeholder
        x: control.leftPadding
        y: control.topPadding
        width: control.width - (control.leftPadding + control.rightPadding)
        height: control.height - (control.topPadding + control.bottomPadding)
        visible: !control.length && !control.preeditText && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)

        horizontalAlignment: control.horizontalAlignment
        verticalAlignment: control.verticalAlignment

        elide: Text.ElideRight

        opacity: 0.5
        font: control.font
        color: control.placeholderTextColor
        text: control.placeholderText
    }

    Row {
        id: inlineButtonRow
        anchors.right: control.right
        anchors.rightMargin: 7
        anchors.verticalCenter: control.verticalCenter

        Kirigami.JIconButton {
            id: showPasswordButton
            source: __effectiveRevealPasswordButtonShown ?
                        (control.echoMode === TextInput.Normal ?
                             Qt.resolvedUrl("./image/64-actions-jing-input-pwd-visible.svg")
                           : Qt.resolvedUrl("./image/64-actions-jing-input-pwd-hidden.svg"))
                      : ""
            height: Math.max(control.height * 0.8, JDisplay.dp(12))
            width: height

            visible: __effectiveRevealPasswordButtonShown && control.enabled

            onClicked: {
                control.echoMode = (control.echoMode == TextInput.Normal ? TextInput.Password : TextInput.Normal)
                control.forceActiveFocus()
            }
        }

        Kirigami.JIconButton  {
            id: clearButton
            source: clearButtonShown ? Qt.resolvedUrl("./image/64-actions-jing-search-clear.svg") : ""
            height: Math.max(control.height * 0.8, JDisplay.dp(12))
            width: height
            visible: control.length > 0 && clearButtonShown && control.enabled
            onClicked: {
                control.text = ""
                control.forceActiveFocus()
            }
        }
    }

    background: Rectangle {
        border.color: control.activeFocus === true ? Kirigami.JTheme.textFieldBorder : Kirigami.JTheme.dividerForeground
        border.width: control.borderWidth
        color: control.bgColor
        radius: control.bgRadius
    }
}
