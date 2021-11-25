/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.2
import QtQml 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14 as QQC2

import org.kde.kirigami 2.5
import org.kde.kirigami 2.15
import jingos.display 1.0
/*
ApplicationWindow
   |
   |- QQuickRootItem
   |      |
   |      |- QQuickContentItem (objectName is  ApplicationWindow)
   |               |
   |               |-(content)
   |
   |- QQuickOverlay

Window
   |
   |- QQuickContentItem
         |
         |-(content)
*/

/*
    |-----------------------|
    |     title             |
    |-----------------------|

    |-----------------------|
    |     text              |
    |-----------------------|

    |-----------------------|
    | msgText or inputtext  |
    |-----------------------|

    |-----------------------|
    |  two or one button    |
    |-----------------------|

 */


QQC2.Popup  {
    id: dialog

    property string title
    property string text
    property string msgText
    property string inputText

    property color titleColor: JTheme.majorForeground  //"#000000"
    property color textColor: JTheme.majorForeground  //"#000000"
    property color msgTextColor: JTheme.majorForeground  //"#000000"
    property color inputTextColor: JTheme.majorForeground  //"#000000"

    property string rightButtonText
    property string leftButtonText
    property string centerButtonText

    property bool rightButtonEnable: true
    property bool leftButtonEnable: true
    property bool centerButtonEnable: true

    property color rightButtonTextColor : JTheme.buttonWeakForeground //"#3C4BE8"
    property color leftButtonTextColor : JTheme.buttonForeground  //"#000000"
    property color centerButtonTextColor : JTheme.buttonWeakForeground  //"#3C4BE8"

    //show textEdit, default false
    property bool inputEnable: false
    property bool showPassword: true
    //property RegExpValidator valid : RegExpValidator { regExp: /[0-9A-F]+/ }
    property RegExpValidator validator :RegExpValidator { }
    property alias blurBackground: bkground

    signal rightButtonClicked()
    signal leftButtonClicked()
    signal centerButtonClicked()

    property Item sourceItem: null
    //property var rootWindow : null
    //applicationwidnow  cotentitem
    property Item windowContentItem: null

    //default anchor center in screen
    property bool defaultAnchors: true
    //anchors.centerIn: parent
    anchors.centerIn: ApplicationWindow.overlay

    modal: true
    dim:false
    closePolicy: QQC2.Popup.NoAutoClose

    topPadding: JDisplay.dp(16)
    leftPadding: JDisplay.dp(16)
    rightPadding: JDisplay.dp(16)
    bottomPadding: JDisplay.dp(19)

    width: JDisplay.dp(231)
    height: clayout.height + dialog.topPadding + dialog.bottomPadding


    property Component titleItem: null
    property Component textItem: null
    property Component msgTextItem: null
    property Component inputItem: null
    property Component buttonItem: null

    onWindowChanged: {
        if(window){
            dialog.windowContentItem = window.contentItem;
        } else {
            dialog.windowContentItem = null;
        }
    }

    contentItem: FocusScope {
        id: focusScope
        focus: true

        Keys.onPressed: {
            if(event.key === Qt.Key_Enter || event.key === Qt.Key_Return){
                if(dialog.centerButtonText != "") {
                    dialog.centerButtonClicked()
                } else if(dialog.leftButtonText != "" && dialog.rightButtonText != "") {
                    dialog.rightButtonClicked()
                }
            }
        }

        onVisibleChanged: {
            if(visible && !inputEnable) {
                focusScope.forceActiveFocus()
            }
        }

        Column{
            id:clayout
            width: parent.width

            Loader{
                id:titleLoader
                width: parent.width
                height: item ? item.height : 0
                active: dialog.title != ""
                sourceComponent: dialog.titleItem ? dialog.titleItem : defaultTitleCom
            }

            Loader{
                id:textLoader
                width: parent.width
                height: item ? item.height : 0
                active: dialog.text != ""
                sourceComponent: dialog.textItem ? dialog.textItem : defaultTextItem
            }

            Loader{
                id:msgtextLoader
                width: parent.width
                height: item ? item.height : 0
                active: dialog.msgText != "" && dialog.inputEnable === false
                sourceComponent: dialog.msgTextItem ? dialog.msgTextItem : defaultMsgTextItem
            }

            Loader{
                id:inputLoader
                width: parent.width
                height: item ? item.height : 0
                focus: active
                active: dialog.inputEnable
                sourceComponent: dialog.inputItem ? dialog.inputItem : defaultInputItem
            }

            Loader{
                id:twoButtonLoader
                width: parent.width
                height: item ? item.height : 0
                active: (dialog.leftButtonText != "" && dialog.rightButtonText != "") && centerButtonText == ""
                sourceComponent: dialog.buttonItem ? dialog.buttonItem : defaultTwoButtonItem
            }

            Loader{
                id:oneButtonLoader
                width: parent.width
                height: item ? item.height : 0
                active: centerButtonText != ""
                sourceComponent: dialog.buttonItem ? dialog.buttonItem : defaultOneButtonItem
            }

        }
    }

    Component{
        id:defaultTitleCom
        Item {
            height: titleText.height + JDisplay.dp(10)
            Text {
                id: titleText
                width: parent.width

                horizontalAlignment: Text.AlignHCenter
                color: dialog.titleColor
                wrapMode: Text.WordWrap
                font.pixelSize: JDisplay.sp(16)
                font.weight: Font.Medium
                text: dialog.title
            }
        }
    }

    Component{
        id:defaultTextItem
        Item {
            height: textText.height + (dialog.msgText != "" ? JDisplay.dp(12) : JDisplay.dp(20))
            Text {
                id: textText
                width: parent.width

                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                color: dialog.textColor
                font.pixelSize: JDisplay.sp(12)
                text: dialog.text
            }
        }
    }

    Component{
        id:defaultMsgTextItem
        Item {
            height: msgTextText.height + JDisplay.dp(24)
            Text {
                id: msgTextText
                width: parent.width

                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                color: dialog.msgTextColor
                font.pixelSize: JDisplay.sp(22)
                text: dialog.msgText
            }
        }
    }

    Component{
        id:defaultInputItem
        FocusScope {
            height: Math.max(inputContainRect.implicitHeight, inputContainRect.height) + JDisplay.dp(18)
            focus: true
            JSearchField{
                id: inputContainRect
		property string rootInputText: dialog.inputText
                width: parent.width
                bgColor: JTheme.buttonPopupBackground
                bgRadius: JDisplay.dp(5)
                borderWidth: 0
                focus: true
                validator: dialog.validator
                leftActions:[]
                font.pointSize: JDisplay.sp(10)
                placeholderText: ""
                revealPasswordButtonShown:dialog.showPassword

		onRootInputTextChanged:{
			inputContainRect.text = rootInputText
		}
                onTextChanged:{
                    dialog.inputText = inputContainRect.text
                }
//                onRightActionTrigger:{
//                    //clear text button click
//                    dialog.inputText = "";
//                }

                onVisibleChanged: {
                    if(visible === false){
                        if(revealPasswordButtonShown === true){
                            inputContainRect.echoMode = TextInput.Password
                        }
                    }
                }

                Keys.onPressed: {
                    if(event.key === Qt.Key_Enter || event.key === Qt.Key_Return){
                        if(dialog.centerButtonText != ""){
                            dialog.centerButtonClicked();
                        } else if(dialog.leftButtonText != "" && dialog.rightButtonText != ""){
                            dialog.rightButtonClicked();
                        }
                        event.accepted = true;
                    }
                }

                onFocusChanged: {
                    if(focus === false && inputContainRect.visible === true){
//                        inputContainRect.focus = true;
                    }
                }
            }
        }
    }


    Component{
        id:defaultTwoButtonItem
        Item {
            height: Math.max(leftButton.height, rightButton.height)

            JButton{
                id: leftButton
                anchors.left : parent.left

                width: JDisplay.dp(90)
                height: JDisplay.dp(36)
                radius: JDisplay.dp(7)
                backgroundColor: JTheme.buttonPopupBackground
                enabled: dialog.leftButtonEnable

                fontColor: dialog.leftButtonTextColor
                font.pointSize: JDisplay.sp(11)
                text: dialog.leftButtonText

                onClicked: dialog.leftButtonClicked()
            }

            JButton {
                id: rightButton
                anchors.right: parent.right
                width: JDisplay.dp(90)
                height: JDisplay.dp(36)
                radius: JDisplay.dp(7)
                backgroundColor: JTheme.buttonPopupBackground
                enabled: dialog.rightButtonEnable

                fontColor: dialog.rightButtonTextColor
                font.pointSize: JDisplay.sp(11)
                text: dialog.rightButtonText

                onClicked: dialog.rightButtonClicked()
            }
        }
    }

    Component{
        id:defaultOneButtonItem
        Item {
            height:oneButton.height

            JButton{
                id: oneButton
                anchors.left : parent.left

                width:parent.width
                height: JDisplay.dp(36)
                radius: JDisplay.dp(7)
                backgroundColor: JTheme.buttonPopupBackground
                enabled: dialog.centerButtonEnable

                fontColor: dialog.rightButtonTextColor
                font.pointSize: JDisplay.sp(11)
                text: dialog.centerButtonText

                onClicked: {
                    dialog.centerButtonClicked()
                }
            }
        }
    }


    enter: Transition {
            ParallelAnimation{
                NumberAnimation { property: "scale"; from: 0.0; to: 1.0; duration: 75 }
                NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 75 }
            }
    }

    onVisibleChanged: {
        if(visible){
             bkground.resetBg();
        }
    }

    background: JBlurBackground{
        id: bkground
        radius: JDisplay.dp(8)
        resetByManual: true
        sourceItem: dialog.sourceItem ? dialog.sourceItem : dialog.windowContentItem
    }
    onAboutToShow:{

        if(inputLoader.active && inputLoader.item){
            dialog.focus = true;

        }
    }
}
