/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */


import QtQuick 2.5
import QtQuick.Window 2.5
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.0
import QtQml 2.12

import org.kde.kirigami 2.5
import org.kde.kirigami 2.15 as Kirigami
import jingos.display 1.0
import "./ImagePreview"

Kirigami.Page {
    id: cropView
    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0
    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None

    anchors.fill: parent

    property string source : "file:///home/jingos/image/11.jpg"
    property bool lockScreenPaper : false


    property var rootWindow : null
    property var oldVisibility

    signal setWallPaperFinished(bool success)
    signal cancel();


    onWindowChanged:{
        if(!cropView.rootWindow){
            cropView.rootWindow = window;
            cropView.oldVisibility = cropView.rootWindow.visibility;
            cropView.rootWindow.visibility = Window.FullScreen;
        }
    }

    function getRootWindow(){
        if(!cropView.rootWindow && typeof applicationWindow === "function"){
            cropView.rootWindow =  applicationWindow();
            cropView.oldVisibility = root.rootWindow.visibility;
            cropView.rootWindow.visibility = Window.FullScreen;
        }
    }
    Component.onCompleted: {
        getRootWindow();
    }

    Component.onDestruction: {
        if(cropView.rootWindow){
            cropView.rootWindow.visibility = cropView.oldVisibility;
        }
    }

    Rectangle{
        anchors.fill: parent
        color: "black"
    }

    Kirigami.JImageDocument {
        id: imageDoc
        providerImage:false
    }

    JImageViewer{
        id:imgViewer
        anchors.fill: parent
        setWallpaper:true
        source: cropView.source
        onClicked: {
            cropView.lockScreenPaper = !cropView.lockScreenPaper;
        }
    }

    Loader{
        id:frontItem
        anchors.fill: parent
        sourceComponent: cropView.lockScreenPaper ? lockScrrenViewCom : wallPaperViewCom

    }

    Component{
        id:lockScrrenViewCom
        Item {
            Column{
                id:timeCol
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: JDisplay.dp(100)
                anchors.rightMargin: JDisplay.dp(50)
                width: Math.max(timeText.width, dateText.width)
                Text {
                    id:timeText

                    anchors.right: parent.right
                    color: "#FFFFFF"
                    font.pointSize: JDisplay.sp(71)
                    text: dateTimeTimer.timeString
                }
                Text {
                    id:dateText

                    anchors.right: parent.right
                    color: "#FFFFFF"
                    font.pointSize: JDisplay.sp(13)
                    text: dateTimeTimer.dateString
                }
            }

            Timer{
                id:dateTimeTimer
                property string dateString : ""
                property string timeString : ""
                property var locale : Qt.locale(Qt.locale().name)
                //property string datePrefix: wPaperSettings.localeName === "zh_CN" ? i18nd("kirigami-controlkit", "day") : ""
                property string datePrefix: dateTimeTimer.locale.name === "zh_CN" ? i18nd("kirigami-controlkit", "day") : ""
                running: true
                repeat: true
                interval: 1000
                triggeredOnStart:true
                onTriggered: {
                    var currentDate = new Date();
                    dateTimeTimer.dateString = currentDate.toLocaleDateString(dateTimeTimer.locale, "dddd,MMM d") + dateTimeTimer.datePrefix;
                    dateTimeTimer.timeString = currentDate.toLocaleTimeString(dateTimeTimer.locale, "HH:mm");
                }
            }
        }
    }

    Component{
        id:wallPaperViewCom

        Item {

            ListModel{
                id:dockModel
                ListElement{
                    imagePath:"./image/imagePreviewIcon/wallpaperSet/clock.svg"
                }
                ListElement{
                    imagePath:"./image/imagePreviewIcon/wallpaperSet/files.svg"
                }
                ListElement{
                    imagePath:"./image/imagePreviewIcon/wallpaperSet/app_store.svg"
                }
            }

            ListModel{
                id:gridModel
                ListElement{
                    name:"Voice Memos"
                    imagePath:"./image/imagePreviewIcon/wallpaperSet/voice_memos.svg"
                }
                ListElement{
                    name:"Screen Projection"
                    imagePath:"./image/imagePreviewIcon/wallpaperSet/screen_projection.svg"
                }
                ListElement{
                    name:"Calculator"
                    imagePath:"./image/imagePreviewIcon/wallpaperSet/calculator.svg"
                }
                ListElement{
                    name:"Files"
                    imagePath:"./image/imagePreviewIcon/wallpaperSet/files.svg"
                }
                ListElement{
                    name:"App Store"
                    imagePath:"./image/imagePreviewIcon/wallpaperSet/app_store.svg"
                }
                ListElement{
                    name:"Photos"
                    imagePath:"./image/imagePreviewIcon/wallpaperSet/photos.png"
                }

                ListElement{
                    name:"Calendar"
                    imagePath:"./image/imagePreviewIcon/wallpaperSet/calendar.png"
                }
                ListElement{
                    name:"Settings"
                    imagePath:"./image/imagePreviewIcon/wallpaperSet/settings.svg"
                }
                ListElement{
                    name:"Mail"
                    imagePath:"./image/imagePreviewIcon/wallpaperSet/mail.svg"
                }
                ListElement{
                    name:"Media"
                    imagePath:"./image/imagePreviewIcon/wallpaperSet/media.svg"
                }
                ListElement{
                    name:"Camera"
                    imagePath:"./image/imagePreviewIcon/wallpaperSet/camera.svg"
                }
                ListElement{
                    name:"Browser"
                    imagePath:"./image/imagePreviewIcon/wallpaperSet/browser.svg"
                }
            }

            GridView {
                id: appIconView
                anchors{
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: JDisplay.dp(55)
                }
                interactive: false
                width: parent.width - (JDisplay.dp(55 * 2))
                height: parent.height - JDisplay.dp(50)
                model: gridModel
                cellWidth : appIconView.width / 6
                cellHeight : appIconView.height / 4
                boundsBehavior: Flickable.StopAtBounds
                delegate:Column {
                    width: appIconView.cellWidth
                    height: appIconView.cellHeight
                    spacing: JDisplay.dp(5)

                    Image {
                        id: icon
                        anchors.horizontalCenter:label.horizontalCenter
                        width: parent.width / 3
                        height: width
                        source: model.imagePath
                    }

                    Text {
                        id: label
                        anchors.horizontalCenter: parent.horizontalCenter

                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignTop
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight

                        font.pointSize: JDisplay.sp(8)
                        color: "white"
                        text:  model.name
                    }
                }

            }

            Row {
                id: favoriteAppRow
                anchors{
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    bottomMargin: JDisplay.dp(20)
                }
                spacing: JDisplay.dp(12)

                Repeater {
                    id: dockRepeater
                    model:dockModel
                    delegate: Image {
                        id: dockBarImage
                        width: JDisplay.dp(50)
                        height: width
                        opacity: 0.5
                        source: model.imagePath
                    }
                }
            }
        }
    }



    Item {
        id:actionItem
        anchors.fill: parent

        Row{
            height: JDisplay.dp(22)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: actionRow.top
            anchors.bottomMargin: JDisplay.dp(25)
            spacing: JDisplay.dp(5)

            Item {
                width: JDisplay.dp(22)
                height: width

                Image {
                    id: moveScaleImg
                    anchors.fill: parent
                    source: "./image/imagePreviewIcon/wallpaperSet/move_scale.svg"
                    smooth: true
                    visible: false
                }

                ColorOverlay {
                    anchors.fill: moveScaleImg
                    source: moveScaleImg
                    opacity: 0.6
                    color: "#EBEBF5"
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: "#EBEBF5"
                opacity: 0.6
                font.pointSize: JDisplay.dp(10)
                text: i18nd("kirigami-controlkit", "Move & Scale")
            }
        }

        Row{
            id:actionRow
            anchors.bottom: parent.bottom
            anchors.bottomMargin: JDisplay.dp(95)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: JDisplay.dp(50)
            Kirigami.JButton {
                id:cancelBtn
                width: JDisplay.dp(90)
                height: JDisplay.dp(28)
                font.pointSize: JDisplay.sp(11)
                text: i18nd("kirigami-controlkit", "Cancel")
                onClicked: {
                    cropView.cancel();
                }
            }

            Kirigami.JButton {
                id:setBtn
                width: JDisplay.dp(90)
                height: JDisplay.dp(28)
                font.pointSize: JDisplay.sp(11)
                text: i18nd("kirigami-controlkit", "Set")
                onClicked: {
                    pop.open();
                }
            }
        }

        Popup{
            id:pop
            x:actionItem.width / 2  + (setBtn.width - pop.width) / 2 + JDisplay.dp(25)
            y:actionRow.y - pop.height - JDisplay.dp(10)
            width: JDisplay.dp(260)
            height: JDisplay.dp(145)
            leftPadding:0
            topPadding:0
            rightPadding:0
            bottomPadding:JDisplay.dp(6)
            modal:true
            dim:false
            //closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
            contentItem: Item {
                id:conitem

                Kirigami.JRoundRectangle{
                    id:lockScreeBtn
                    radius: JDisplay.dp(12)
                    width: parent.width
                    height: JDisplay.dp(45)
                    radiusPos: Kirigami.JRoundRectangle.TOPLEFT | Kirigami.JRoundRectangle.TOPRIGHT
                    color: lockScrennMouse.containsMouse ? (lockScrennMouse.pressed ? Kirigami.JTheme.pressBackground: Kirigami.JTheme.hoverBackground) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        color: Kirigami.JTheme.highlightColor
                        font.pointSize: JDisplay.sp(10)
                        text: i18nd("kirigami-controlkit", "Set Lock Screen")
                    }
                    MouseArea{
                        id:lockScrennMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            cropView.cropWallPaper(Kirigami.JWallPaperSettings.LockScreen)
                            pop.close();
                        }
                        onContainsMouseChanged: {

                        }
                    }
                }
                Rectangle{
                    id:homeScreenBtn
                    width: parent.width
                    anchors.top: lockScreeBtn.bottom
                    anchors.bottom: bothBtn.top
                    color: homeScreenMouse.containsMouse ? (homeScreenMouse.pressed ? Kirigami.JTheme.pressBackground: Kirigami.JTheme.hoverBackground) : "transparent"
                    Text {
                        anchors.centerIn: parent
                        color: Kirigami.JTheme.highlightColor
                        font.pointSize: JDisplay.sp(10)
                        text: i18nd("kirigami-controlkit", "Set Home Screen")

                    }
                    MouseArea{
                        id:homeScreenMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            //doingRect.visible = true;
                            cropView.cropWallPaper(Kirigami.JWallPaperSettings.HomeScreen)
                            pop.close();
                        }
                    }
                    Rectangle{
                        width: parent.width
                        height: JDisplay.dp(1)
                        anchors.top : parent.top
                        color: Kirigami.JTheme.dividerForeground
                    }

                    Rectangle{
                        width: parent.width
                        height: JDisplay.dp(1)
                        anchors.bottom: parent.bottom
                        color: Kirigami.JTheme.dividerForeground
                    }
                }
                Kirigami.JRoundRectangle{
                    id:bothBtn
                    width: parent.width
                    height: JDisplay.dp(45)
                    radius: JDisplay.dp(12)
                    anchors.bottom: parent.bottom
                    radiusPos: Kirigami.JRoundRectangle.BOTTOMLEFT | Kirigami.JRoundRectangle.BOTTOMRIGHT
                    color: bothMouse.containsMouse ? (bothMouse.pressed ? Kirigami.JTheme.pressBackground: Kirigami.JTheme.hoverBackground) : "transparent"
                    Text {
                        anchors.centerIn: parent
                        color:Kirigami.JTheme.highlightColor
                        font.pointSize: JDisplay.sp(10)
                        text: i18nd("kirigami-controlkit", "Set Both")
                    }

                    MouseArea{
                        id:bothMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            //doingRect.visible = true;
                            cropView.cropWallPaper(Kirigami.JWallPaperSettings.Both)
                            pop.close();
                        }
                    }
                }
            }
            background: Kirigami.JBlurBackground{
                id:background
                anchors.fill: parent
                sourceItem:cropView
                radius: JDisplay.dp(12)
                //radiusPos: Kirigami.JRoundRectangle.BOTTOMLEFT | Kirigami.JRoundRectangle.BOTTOMRIGHT | Kirigami.JRoundRectangle.TOPLEFT | Kirigami.JRoundRectangle.TOPRIGHT
                arrowPos:Kirigami.JRoundRectangle.ARROW_BOTTOM
                arrowX:background.width / 2
                arrowWidth : JDisplay.dp(12)
                arrowHeight: JDisplay.dp(6)
                arrowY:6
            }
        }

        Rectangle{
            id:doingRect
            width: JDisplay.dp(215)
            height:JDisplay.dp( 60)
            radius: JDisplay.dp(12)
            visible: false
            color: "white"
            anchors.centerIn: parent

            Row{
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: JDisplay.dp(5)
                Image{
                    id:loadingImg
                    width: JDisplay.dp(22)
                    height: width
                    anchors.verticalCenter: parent.verticalCenter
                    source: "./image/imagePreviewIcon/wallpaperSet/loading.png"
                    NumberAnimation {
                        running: loadingImg.visible
                        loops: Animation.Infinite
                        target: loadingImg
                        from: 0
                        to: 360
                        property: "rotation"
                        duration: 1000
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: JDisplay.sp(10)
                    text: i18nd("kirigami-controlkit", "Settings Wallpaper...")
                }
            }
        }

        Kirigami.JWallPaperSettings{
            id:wPaperSettings
            onSigSetWallPaperFinished: {
                cropView.setWallPaperFinished(success);
            }
        }
    }

    function cropWallPaper(type){
//        cropShader.live = true;
//        var cropBeginPos = cropView.mapToItem(imgViewer, 0, 0);
//        cropShader.sourceRect = Qt.rect(cropBeginPos.x, cropBeginPos.y, cropView.width, cropView.height);

//        cropShader.grabToImage(function(result) {

//            var path = wPaperSettings.getWallPaperPath(cropView.source);
//            console.log("save pic to " + path);
//            result.saveToFile(path);
//            wPaperSettings.setWallPaper(type, path);
//            cropShader.live = false;
//        });

        imageDoc.path = cropView.source;
        const ratioX = imgViewer.editImg.width * 1.0 / (imgViewer.editImg.item.sourceSize.width);
        const ratioY = imgViewer.editImg.height * 1.0 / (imgViewer.editImg.item.sourceSize.height);
        console.log("editimage width is " + imgViewer.editImg.width + "  h is " + imgViewer.editImg.height + "  ratiox is " + ratioX + " ratioy is " +ratioY)

        var cRect = cropView.mapToItem(imgViewer.editImg, 0, 0, cropView.width, cropView.height);
        console.log("map crect is " + cRect.x + " " + cRect.y + "  " + cRect.width + "  " + cRect.height)

        var sRect = Qt.rect(cRect.x / ratioX, cRect.y / ratioY, cRect.width / ratioX, cRect.height / ratioY);
        console.log("after scale crect is " + sRect.x + " " + sRect.y + "  " + sRect.width + "  " + sRect.height);

        imageDoc.crop(sRect.x, sRect.y, sRect.width, sRect.height);
        var path = wPaperSettings.getWallPaperPath(cropView.source);
        console.log("save pic to " + path);
        imageDoc.saveAs(path);
        wPaperSettings.setWallPaper(type, path);
    }
}
