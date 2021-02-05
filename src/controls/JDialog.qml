/*
 * Copyright 2021 Rui Wang <wangrui@jingos.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import QtQml 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.14 as QQC2

import org.kde.kirigami 2.5
import org.kde.kirigami 2.15
/*
ApplicationWindow
   |
   |- QQuickRootItem
   |      |
   |      |- QQuickContentItem (objectName is  ApplicationWindow)
   |               |
   |               |-(实际内容)
   |
   |- QQuickOverlay

Window
   |
   |- QQuickContentItem
         |
         |-(实际内容)
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

    property color titleColor: "#000000"
    property color textColor: "#000000"
    property color msgTextColor: "#000000"
    property color inputTextColor: "#000000"

    property string rightButtonText
    property string leftButtonText
    property string centerButtonText

    property bool rightButtonEnable: true
    property bool leftButtonEnable: true
    property bool centerButtonEnable: true

    property color rightButtonTextColor : "#3C4BE8"
    property color leftButtonTextColor : "#000000"
    property color centerButtonTextColor : "#3C4BE8"

    //show textEdit, default false
    property bool inputEnable: false
    //输入框是否使用密码方式显示
    property bool showPassword: true

    signal rightButtonClicked()
    signal leftButtonClicked()
    signal centerButtonClicked()

    //用来作背景图的item
    property Item sourceItem: null
    //window窗口句柄
    //property var rootWindow : null
    //applicationwidnow的 cotentitem
    property Item windowContentItem: null

    //default anchor center in screen
    property bool defaultAnchors: true
    //anchors.centerIn: parent
    anchors.centerIn:{
        console.log(" jdialog  center in Overlay.overlay " + ApplicationWindow.overlay)
        ApplicationWindow.overlay
    }

    modal: true
    closePolicy: QQC2.Popup.NoAutoClose

    topPadding: 16
    leftPadding: 16
    rightPadding: 16
    bottomPadding: 19

    width: 231
    height: clayout.height + dialog.topPadding + dialog.bottomPadding


    property Component titleItem: null
    property Component textItem: null
    property Component msgTextItem: null
    property Component inputItem: null
    property Component buttonItem: null

    function getRootWindow(){
        if(dialog.windowContentItem){
            //already get, not need redo
            return ;
        }

        if(typeof applicationWindow === "function"){
            var rootwin = applicationWindow();
            dialog.windowContentItem = rootwin.contentItem;
            console.log("JDialog applicationWindow is defined get  windowContentItem is " + dialog.windowContentItem);
            return;
        }

        var p = dialog

        while(p){
            console.log("p  is " + p + " width is " + p.width + " height is " + p.height + " object name " + p.objectName);
            if(p.objectName && p.objectName === "rootPageRow"){
                var rootwin = p.applicationWindow();
                dialog.windowContentItem = rootwin.contentItem;
                if(dialog.windowContentItem){
                    console.log("find rootwindow get windowContentItem " + dialog.windowContentItem)
                    break;
                }
            }

            if(p.objectName === "ApplicationWindow"){
                dialog.windowContentItem = p;
                console.log("find ApplictionWindow's contentItem set sourceItem " + dialog.windowContentItem)
                break;
            }
            p = p.parent;
        }
    }

    contentItem: FocusScope {
        focus: true
        Column{
            id:clayout
            width: parent.width

            Loader{
                id:titleLoader
                width: parent.width
                active: dialog.title != ""
                sourceComponent: dialog.titleItem ? dialog.titleItem : defaultTitleCom
            }

            Loader{
                id:textLoader
                width: parent.width
                active: dialog.text != ""
                sourceComponent: dialog.textItem ? dialog.textItem : defaultTextItem
            }

            Loader{
                id:msgtextLoader
                width: parent.width
                active: dialog.msgText != "" && dialog.inputEnable === false
                sourceComponent: dialog.msgTextItem ? dialog.msgTextItem : defaultMsgTextItem
            }

            Loader{
                id:inputLoader
                width: parent.width
                focus: active
                active: dialog.inputEnable
                sourceComponent: dialog.inputItem ? dialog.inputItem : defaultInputItem
            }

            Loader{
                id:twoButtonLoader
                width: parent.width
                active: (dialog.leftButtonText != "" && dialog.rightButtonText != "") && centerButtonText == ""
                sourceComponent: dialog.buttonItem ? dialog.buttonItem : defaultTwoButtonItem
            }

            Loader{
                id:oneButtonLoader
                width: parent.width
                active: centerButtonText != ""
                sourceComponent: dialog.buttonItem ? dialog.buttonItem : defaultOneButtonItem
            }

        }
    }

    Component{
        id:defaultTitleCom
        Item {
            height: titleText.height + 6
            Text {
                id: titleText
                width: parent.width

                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.pointSize: 10.5
                text: dialog.title
            }
        }
    }

    Component{
        id:defaultTextItem
        Item {
            height: textText.height + (dialog.msgText != "" ? 8 : 19)
            Text {
                id: textText
                width: parent.width

                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.pointSize: 8
                text: dialog.text
            }
        }
    }

    Component{
        id:defaultMsgTextItem
        Item {
            height: msgTextText.height + 19
            Text {
                id: msgTextText
                width: parent.width

                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.pointSize: 15
                text: dialog.msgText
            }
        }
    }

    Component{
        id:defaultInputItem
        FocusScope {
            height: Math.max(inputContainRect.implicitHeight, inputContainRect.height) + 16
            focus: true
            JSearchField{
                id: inputContainRect
                width: parent.width
                height: 30
                focus: true
                leftActions:[]
                font.pointSize: 10
                placeholderText: ""
                showPassword:dialog.showPassword
                text:dialog.inputText
                onTextChanged:{
                    dialog.inputText = inputContainRect.text
                }
                onVisibleChanged: {
                    if(visible === false){
                        if(showPassword === true){
                            inputContainRect.echoMode = TextInput.Password
                        }
                    }
                }

                background:Rectangle{
                    border.color: "#26000000"
                    border.width: 1
                    radius: 5
                }
                Keys.onPressed: {
                    if(event.key === Qt.Key_Enter || event.key === Qt.Key_Return){
                        if(dialog.centerButtonText != ""){
                            console.log("emit centerButtonClicked")
                            dialog.centerButtonClicked();
                        } else if(dialog.leftButtonText != "" && dialog.rightButtonText != ""){
                            dialog.rightButtonClicked();
                        }
                    }
                }

                onFocusChanged: {
                    if(focus === false && inputContainRect.visible === true){
                        console.log("set focus to true")
                        inputContainRect.focus = true;
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

                width: ConstValue.jingUnit * 5
                height: ConstValue.jingUnit * 2

                enabled: dialog.leftButtonEnable
                backgroundColor: "#22767680"

                fontColor: dialog.leftButtonTextColor
                font.pointSize: 11
                text: dialog.leftButtonText

                onClicked: dialog.leftButtonClicked()
            }

            JButton {
                id: rightButton
                anchors.right: parent.right

                width: ConstValue.jingUnit * 5
                height: ConstValue.jingUnit * 2

                enabled: dialog.rightButtonEnable
                backgroundColor: "#22767680"

                fontColor: dialog.rightButtonTextColor
                font.pointSize: 11
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
                height: ConstValue.jingUnit * 2

                enabled: dialog.centerButtonEnable
                backgroundColor: "#22767680"

                fontColor: dialog.rightButtonTextColor
                font.pointSize: 11
                text: dialog.centerButtonText

                onClicked: {
                    dialog.centerButtonClicked()
                }
            }
        }
    }

    background: JBlurBackground{
        id: bkground
        sourceItem: dialog.sourceItem ? dialog.sourceItem : dialog.windowContentItem
        backgroundColor:"#EDFFFFFF"
        blurRadius: 130
        radius: ConstValue.jingUnit
    }
    onAboutToShow:{
        if(dialog.defaultAnchors === true){
            dialog.getRootWindow();
//            console.log("dialog  visible is true   getrootwindow return  " + dialog.rootWindow)
//            if(dialog.rootWindow){
//                console.log("set dialog parent to dialog.rootWindow.overlay " + dialog.rootWindow.overlay
//                            + " width " + dialog.rootWindow.overlay.width
//                            + " height " + dialog.rootWindow.overlay.height)
//                //dialog.parent = dialog.rootWindow.overlay
//            } else {
//                console.log("dialog.rootWindow is null set dialog parent to QQC2.Overlay.overlay  " + QQC2.Overlay.overlay
//                            + " width " + QQC2.Overlay.overlay.width
//                            + " height " + QQC2.Overlay.overlay.height)
//                //dialog.parent = QQC2.Overlay.overlay;
//            }
            console.log("set bkground source item to dialog.windowContentItem " + dialog.windowContentItem + " width is  " + dialog.windowContentItem.width +
                        " height is " + dialog.windowContentItem.height)
        }

        if(inputLoader.active && inputLoader.item){
            dialog.focus = true;

        }
    }
}
