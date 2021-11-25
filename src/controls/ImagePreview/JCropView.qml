/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.15
import QtQuick.Controls 2.10 as QQC2

import org.kde.kirigami 2.15 as Kirigami
import jingos.display 1.0
import "./"
Kirigami.Page {
    id: cropView
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None

    property int cropImageWidth:    cropView.width * 4 / 5
    property int cropImageHeight:    cropView.height * 4 / 5
    property string imageUrl: ""
    property int rotateCount: 0

    property bool saveError: false

    signal cropImageFinished(string path)
    signal closePage();

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    Kirigami.JImageDocument {
        id: imageDoc
        property bool isCropping:false
        providerImage:true
        path: cropView.imageUrl
        onVisualImageChanged: {
            if(isCropping === true){
                return;
            }

            imgViewer.source = "";

            imgViewer.width = cropImageWidth;
            imgViewer.height = cropImageHeight;

            imgViewer.source = "image://cropImageProvider/cropImage";
        }

        onCropImageFinished:{
            isCropping = false;
            cropView.cropImageFinished(path);
        }
    }

    JImageViewer{
        id:imgViewer
        anchors.centerIn: parent
        width: cropImageWidth
        height: cropImageHeight
        fullScreen: true
        //source: "image://cropImageProvider/cropImage"
        onInitFinished: {
            resizeRectangle.width = imgViewer.editImg.width
            resizeRectangle.height = imgViewer.editImg.height
            resizeRectangle.x = (cropView.width - imgViewer.editImg.width) / 2;
            resizeRectangle.y = (cropView.height - imgViewer.editImg.height) / 2
            resizeRectangle.moveAreaRect = Qt.rect( resizeRectangle.x, resizeRectangle.y, resizeRectangle.width, resizeRectangle.height);

            vabView.width = resizeRectangle.width
            vabView.height = resizeRectangle.height
            vabView.x = resizeRectangle.x;
            vabView.y = resizeRectangle.y;
        }
    }

    Kirigami.JBlurBackground{
        id:vabView
        visible: resizeRectangle.isMoving === false && resizeRectangle.resizePressed === false && resizeRectangle.isRectChanged === true
        showBgCover:false
        sourceItem: imgViewer
        backgroundColor:"#EDFFFFFF"
        radius: 0
    }

    NumberAnimation {
        id:vabViewAnima
        target: vabView
        property: "opacity"
        from: 0
        to: 1
        duration: 250
        easing.type: Easing.InOutQuad
    }

    Kirigami.JResizeRectangle {
        id: resizeRectangle

        property bool isRectChanged:false
        property bool resizePressed: rzTopLeft.isPressed || rzBottomLeft.isPressed || rzBottomRight.isPressed || rzTopRight.isPressed

        onWidthChanged: {
            isRectChanged = (width !== imgViewer.editImg.width)
            if(vabView.opacity !== 0){
                vabViewAnima.from = 1.0
                vabViewAnima.to = 0
                vabViewAnima.running = true
            }
        }
        onHeightChanged: {
            isRectChanged = (height !== imgViewer.editImg.height)

            if(vabView.opacity !== 0.0){
                vabViewAnima.from = 1.0
                vabViewAnima.to = 0.0
                vabViewAnima.running = true
            }
        }
        JBasicResizeHandle {
            id: rzTopLeft
            rectangle: resizeRectangle
            resizeCorner: Kirigami.JResizeHandle.TopLeft
            moveAreaRect:  Qt.rect(imgViewer.x,imgViewer.y,imgViewer.width,imgViewer.height)

            onOnReleased: {
                if(vabView.opacity !== 1.0){
                    vabViewAnima.from = 0
                    vabViewAnima.to = 1.0
                    vabViewAnima.running = true
                }
            }
        }

        JBasicResizeHandle {
            id: rzBottomLeft
            rectangle: resizeRectangle
            resizeCorner: Kirigami.JResizeHandle.BottomLeft
            moveAreaRect:  Qt.rect(imgViewer.x,imgViewer.y,imgViewer.width,imgViewer.height)

            onOnReleased: {
                if(vabView.opacity !== 1.0){
                    vabViewAnima.from = 0
                    vabViewAnima.to = 1.0
                    vabViewAnima.running = true
                }
            }
        }

        JBasicResizeHandle {
            id: rzBottomRight
            rectangle: resizeRectangle
            resizeCorner: Kirigami.JResizeHandle.BottomRight
            moveAreaRect:  Qt.rect(imgViewer.x,imgViewer.y,imgViewer.width,imgViewer.height)

            onOnReleased: {
                if(vabView.opacity !== 1.0){
                    vabViewAnima.from = 0
                    vabViewAnima.to = 1.0
                    vabViewAnima.running = true
                }
            }
        }

        JBasicResizeHandle {
            id:rzTopRight
            rectangle: resizeRectangle
            resizeCorner: Kirigami.JResizeHandle.TopRight
            moveAreaRect:  Qt.rect(imgViewer.x,imgViewer.y,imgViewer.width,imgViewer.height)

            onOnReleased: {
                if(vabView.opacity !== 1.0){
                    vabViewAnima.from = 0
                    vabViewAnima.to = 1.0
                    vabViewAnima.running = true
                }
            }
        }
        ShaderEffectSource {
            id: ett
            anchors.fill: parent
            visible: vabView.visible
            live:visible
            sourceItem: imgViewer
            onVisibleChanged: {
                if(visible){
                    var pos = ett.mapToItem(imgViewer, 0, 0);
                    ett.sourceRect = Qt.rect(pos.x, pos.y, width, height)
                }
            }
        }

        Row {
            anchors.fill: parent
            spacing: width / 3 - JDisplay.dp(1)
            Repeater {
                model: 4
                delegate: Rectangle {
                    width: JDisplay.dp(1)
                    height: parent.height
                }
            }
        }

        Column {
            anchors.fill: parent
            spacing: height / 3 - JDisplay.dp(1)
            Repeater {
                model: 4
                delegate: Rectangle {
                    width: parent.width
                    height: JDisplay.dp(1)
                }
            }
        }

    }

    Rectangle {
        id: rightToolView

        property bool isModified: doneImage.opacity === 1.0

        width: parent.width / 10
        height: parent.height
        color: "transparent"
        anchors {
            top: parent.top
            topMargin: reduction.height * 2
            bottom: parent.bottom
            right: parent.right
        }

        Text {
            id: reduction

            color: rightToolView.isModified ? "#FFFFFF" : "#4DFFFFFF"
            text: i18nd("kirigami-controlkit", "Reduction")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: JDisplay.sp(10)

            MouseArea {
                anchors.fill: reduction
                onClicked: {
                    if (rightToolView.isModified) {
                        abandionDialog.open()
                    }
                }
            }
        }

        Kirigami.Icon {
            id: rotateImage

            width: JDisplay.dp(22)
            height: width
            anchors {
                bottom: cancelImage.top
                bottomMargin: JDisplay.dp(22)
                horizontalCenter: parent.horizontalCenter
            }
            color:"#ffffff"
            source: Qt.resolvedUrl("../image/imagePreviewIcon/crop_rotate.svg")

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    cropView.rotateCount++
                    imageDoc.rotate(90)
                }
            }
        }

        Kirigami.Icon {
            id: cancelImage

            width: JDisplay.dp(22)
            height: width
            anchors {
                bottom: doneImage.top
                bottomMargin: JDisplay.dp(22)
                horizontalCenter: parent.horizontalCenter
            }
            color:"#ffffff"
            source: Qt.resolvedUrl("../image/imagePreviewIcon/crop_delete.svg")

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    cropView.closePage();
                }
            }
        }

        Kirigami.Icon {
            id: doneImage

            width: JDisplay.dp(22)
            height: width

            anchors {
                bottom: parent.bottom
                bottomMargin: JDisplay.dp(22)
                horizontalCenter: parent.horizontalCenter
            }

            color:"#ffffff"
            source: Qt.resolvedUrl("../image/imagePreviewIcon/done.svg")
            opacity: (resizeRectangle.isRectChanged === true || (cropView.rotateCount % 4 !== 0)) ? 1.0 : 0.5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (rightToolView.isModified) {
                        crop()
                    }
                }
            }
        }
    }

    Kirigami.JDialog{
        id:abandionDialog
        title: cropView.saveError ? i18nd("kirigami-controlkit", "Save failed") : i18nd("kirigami-controlkit", "Abandoning modification")
        text: cropView.saveError ?  i18nd("kirigami-controlkit", "The file has an error and cannot be saved") : i18nd("kirigami-controlkit", "Are you sure to discard the current modification?")
        rightButtonText: cropView.saveError ? "" : i18nd("kirigami-controlkit", "Action")
        leftButtonText: cropView.saveError ? "" : i18nd("kirigami-controlkit", "Cancel")
        centerButtonText : cropView.saveError ? i18nd("kirigami-controlkit", "OK") : ""
        visible:false

        onLeftButtonClicked:{
            abandionDialog.close()
        }

        onRightButtonClicked:{
            abandionDialog.close()
            cropView.rotateCount = 0;
            imageDoc.clearUndoImage()
        }

        onCenterButtonClicked:{
            abandionDialog.close()
        }

        onVisibleChanged:{
            if(abandionDialog.visible === false){
                cropView.saveError = false;
            }
        }
    }

    function crop() {

        const ratioX = imgViewer.editImg.width * 1.0 / imgViewer.editImg.item.sourceSize.width
        const ratioY = imgViewer.editImg.height * 1.0 / imgViewer.editImg.item.sourceSize.height;

        var cRect = resizeRectangle.mapToItem(imgViewer.editImg, 0, 0, resizeRectangle.width, resizeRectangle.height);

        imageDoc.isCropping = true;
        imageDoc.crop(cRect.x / ratioX, cRect.y / ratioY, cRect.width / ratioX, cRect.height / ratioY);
        var rv = imageDoc.saveAs();
        if(rv === false){
            cropView.saveError = true;
            abandionDialog.open();
        }
    }
}
