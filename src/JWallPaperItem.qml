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

import jingos.multimedia 1.0
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
        if(typeof applicationWindow === "function"){
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

    JImageDocument {
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
                anchors.bottomMargin: 100
                anchors.rightMargin: 50
                width: Math.max(timeText.width, dateText.width)
                Text {
                    id:timeText

                    anchors.right: parent.right
                    color: "#FFFFFF"
                    font.pointSize: 71
                    text: dateTimeTimer.timeString
                }
                Text {
                    id:dateText

                    anchors.right: parent.right
                    color: "#FFFFFF"
                    font.pointSize: 13
                    text: dateTimeTimer.dateString
                }
            }

            Timer{
                id:dateTimeTimer
                property string dateString : ""
                property string timeString : ""
                //Qt.locale返回默认的本地locale，但是现在jingos上time一直使用英文，所以
                //需要使用本地localce的name重新促使化locae，这样time也就使用新的格式
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
                    topMargin: 55
                }
                interactive: false
                width: parent.width - (55 * 2 )
                height: parent.height - 50
                model: gridModel
                cellWidth : appIconView.width / 6
                cellHeight : appIconView.height / 4
                boundsBehavior: Flickable.StopAtBounds
                delegate:Column {
                    width: appIconView.cellWidth
                    height: appIconView.cellHeight
                    spacing: 5

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

                        font.pointSize: 8
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
                    bottomMargin: 20
                }
                spacing: 12

                Repeater {
                    id: dockRepeater
                    model:dockModel
                    delegate: Image {
                        id: dockBarImage
                        width: 50
                        height: width
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
            height: 22
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: actionRow.top
            anchors.bottomMargin: 25
            spacing: 5

            Item {
                width: 22
                height: 22

                Image {
                    id: moveScaleImg
                    width: 22
                    height: 22
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
                font.pointSize: 10
                text: i18nd("kirigami-controlkit", "Move & Scale")
            }
        }

        Row{
            id:actionRow
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 95
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 50
            Kirigami.JButton {
                id:cancelBtn
                width: 90
                height: 28

                backgroundColor: "#99FFFFFF"
                font.pointSize: 11
                text: i18nd("kirigami-controlkit", "Cancel")

                onClicked: {
                    cropView.cancel();
                }
            }

            Kirigami.JButton {
                id:setBtn
                width: 90
                height: 28

                backgroundColor: "#99FFFFFF"
                font.pointSize: 11
                text: i18nd("kirigami-controlkit", "Set")
                onClicked: {
                    pop.open();
                }
            }
        }

        Popup{
            id:pop
            x:actionItem.width / 2  + (setBtn.width - pop.width) / 2 + 25
            y:actionRow.y - pop.height - 10
            width: 260
            height: 145
            leftPadding:0
            topPadding:0
            rightPadding:0
            bottomPadding:6
            modal:true
            dim:false
            //closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
            contentItem: Item {
                id:conitem

                Kirigami.JRoundRectangle{
                    id:lockScreeBtn
                    radius: 12
                    width: parent.width
                    height: 45
                    radiusPos: Kirigami.JRoundRectangle.TOPLEFT | Kirigami.JRoundRectangle.TOPRIGHT
                    color: lockScrennMouse.containsMouse ? "#cdcdcd" : "white"
                    opacity: lockScrennMouse.containsMouse ? (lockScrennMouse.pressed ? 0.6 : 0.8) : 1.0
                    Text {
                        anchors.centerIn: parent
                        color: "#FF3C4BE8"
                        font.pointSize: 10
                        text: i18nd("kirigami-controlkit", "Set Lock Screen")
                    }
                    MouseArea{
                        id:lockScrennMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            doingRect.visible = true;
                            cropView.cropWallPaper(JWallPaperSettings.LockScreen)
                            pop.close();
                        }
                    }
                }
                Rectangle{
                    id:homeScreenBtn
                    width: parent.width
                    //height: 45
                    anchors.top: lockScreeBtn.bottom
                    anchors.bottom: bothBtn.top
                    color: homeScreenMouse.containsMouse ? "#cdcdcd" : "white"
                    opacity: homeScreenMouse.containsMouse ? (homeScreenMouse.pressed ? 0.6 : 0.8) : 1.0
                    Text {
                        anchors.centerIn: parent
                        color: "#FF3C4BE8"
                        font.pointSize: 10
                        text: i18nd("kirigami-controlkit", "Set Home Screen")

                    }
                    MouseArea{
                        id:homeScreenMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            doingRect.visible = true;
                            cropView.cropWallPaper(JWallPaperSettings.HomeScreen)
                            pop.close();
                        }
                    }
                    Rectangle{
                        width: parent.width
                        height: 1
                        anchors.top : parent.top
                        color: "#3C3C43"
                        opacity: 0.18
                    }

                    Rectangle{
                        width: parent.width
                        height: 1
                        anchors.bottom: parent.bottom
                        color: "#2E3C3C43"
                    }
                }
                Kirigami.JRoundRectangle{
                    id:bothBtn
                    width: parent.width
                    height: 45
                    radius: 12
                    anchors.bottom: parent.bottom
                    radiusPos: Kirigami.JRoundRectangle.BOTTOMLEFT | Kirigami.JRoundRectangle.BOTTOMRIGHT
                    color: bothMouse.containsMouse ? "#cdcdcd" : "white"
                    opacity: bothMouse.containsMouse ? (bothMouse.pressed ? 0.6 : 0.8) : 1.0
                    Text {
                        anchors.centerIn: parent
                        color: "#FF3C4BE8"
                        font.pointSize: 10
                        text: i18nd("kirigami-controlkit", "Set Both")
                    }

                    MouseArea{
                        id:bothMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            doingRect.visible = true;
                            cropView.cropWallPaper(JWallPaperSettings.Both)
                            pop.close();
                        }
                    }
                }
            }

            background: Item {
                id: background
                Rectangle{
                    anchors.fill: parent
                    anchors.bottomMargin: 6
                    radius: 12
                    layer.enabled: true
                    layer.effect: DropShadow {
                        radius: 40
                        samples: 25
                        color: "#1A000000"
                        verticalOffset: 0
                        horizontalOffset: 0
                        spread: 0
                    }
                }

                Rectangle {
                    id: upBar
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 2
                    anchors.horizontalCenter: parent.horizontalCenter

                    width: 12
                    height: 12

                    rotation: 45
                    layer.enabled: true

                    layer.effect: DropShadow {
                        radius: 40
                        samples: 25
                        color: "#1A000000"
                        verticalOffset: 0
                        horizontalOffset: 0
                        spread: 0
                    }
                }
            }

        }

        Rectangle{
            id:doingRect
            width: 215
            height: 60
            radius: 12
            visible: false
            color: "white"
            anchors.centerIn: parent

            Row{
                height: parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5
                Image{
                    id:loadingImg
                    width: 22
                    height: 22
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
                    font.pointSize: 10
                    text: i18nd("kirigami-controlkit", "Settings Wallpaper...")
                }
            }
        }

        JWallPaperSettings{
            id:wPaperSettings
            onSigSetWallPaperFinished: {
                console.log("jwall paper settings set wall paper finished " + success)
                doingRect.visible = false;
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
