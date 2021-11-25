/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.12
import QtQml 2.12
import org.kde.kirigami 2.15 as Kirigami
PinchArea{
    id:pinchItem
    //anchors.fill: parent
    property bool isGif : false
    property string source : ""
    property bool setWallpaper: false
    property bool fullScreen: false
    property real maxScale : 3.0
    property real originWidth
    property real originHeight

    property real originX
    property real originY

    property real scaleMinWidth
    property real scaleMinHeight
    property real initialWidth
    property real initialHeight

    property alias editImg: editImage
    property alias mouseEbable: imgMouse.enabled

    property int paramIniting: -1
    signal moveToLeftEdge();
    signal moveToRightEdge();
    signal clicked()
    signal initFinished()

    clip: true


    onWidthChanged: {
        if(pinchItem.width >= 0 && pinchItem.height >= 0 && editImage.item && editImage.item.status === Image.Ready && pinchItem.paramIniting !== 0){
            initParam();
        }
    }

    onHeightChanged: {
        if(pinchItem.width >= 0 && pinchItem.height >= 0 && editImage.item && editImage.item.status === Image.Ready && pinchItem.paramIniting !== 0){
            initParam();
        }
    }

    onPinchStarted:{
        initialWidth = editImage.width
        initialHeight = editImage.height
    }

    onPinchUpdated:{

//        var movx = pinch.previousCenter.x - pinch.center.x;
//        var movy = pinch.previousCenter.y - pinch.center.y;

        //        console.log( " scale  diff " + (pinch.scale - pinch.previousScale) + "  movx is + " + movx + "  movy is " + movy)
        //        if(pinchItem.setWallpaper === false && (oldWidth === editImage.width)){
        //            if(editImage.width >= pinchItem.width){
        //                if(editImage.x - movx > 0){
        //                    editImage.x = 0;

        //                } else if(editImage.x -movx + editImage.width <= pinchItem.width){
        //                    editImage.x = pinchItem.width - editImage.width
        //                } else {
        //                    editImage.x -= movx;
        //                }
        //            }

        //            if(editImage.height >= pinchItem.height){
        //                if(editImage.y - movy > 0){
        //                    editImage.y = 0;
        //                } else if(editImage.y -movy + editImage.height <= pinchItem.height){
        //                    editImage.y = pinchItem.height - editImage.height
        //                } else {
        //                    editImage.y -= movy;
        //                }
        //            }

        //        } else {
        //            editImage.x -= movx;
        //            editImage.y -= movy;
        //        }

        // resize content
        var oldWidth = editImage.width;
        var oldHeight = editImage.height;
        editImage.width = Math.max(pinchItem.scaleMinWidth,
                                   Math.min(pinchItem.initialWidth * pinch.scale, pinchItem.originWidth * pinchItem.maxScale));
        editImage.height = Math.max(pinchItem.scaleMinHeight,
                                    Math.min(pinchItem.initialHeight * pinch.scale, pinchItem.originHeight * pinchItem.maxScale));


        var centerPos = pinchItem.mapToItem(editImage, pinch.center.x, pinch.center.y);

        editImage.x -= (centerPos.x / oldWidth) * (editImage.width - oldWidth);
        editImage.y -= (centerPos.y / oldHeight) * (editImage.height - oldHeight);
    }

    onPinchFinished:{
        pinchItem.calculateImagePos();
    }

    ParallelAnimation{
        id: zoomAnim
        property real x: 0
        property real y: 0
        property real width: editImage.width
        property real height: editImage.height

        NumberAnimation{
            target: editImage
            property: "x"
            from: editImage.x
            to: zoomAnim.x
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }

        NumberAnimation{
            target: editImage
            property: "y"
            from: editImage.y
            to: zoomAnim.y
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }

        NumberAnimation{
            target: editImage
            property: "width"
            from: editImage.width
            to: zoomAnim.width
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }

        NumberAnimation{
            target: editImage
            property: "height"
            from: editImage.height
            to: zoomAnim.height
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    Loader{
        id: editImage
        sourceComponent: pinchItem.isGif === true ? gifImageCom : staticImageCom
        onItemChanged: {
            //AnimatedImage status have been finshed ，and loader's item is null
            if(pinchItem.isGif === true && editImage.item && editImage.item.sourceSize.width > 0 &&  editImage.item.sourceSize.height > 0){
                initParam();
            }
        }
    }

    Component{
        id:staticImageCom
        Image {
            id: staticImage
            cache: false
            source: pinchItem.source
            autoTransform:true
            asynchronous:true

            onStatusChanged:{
                if (staticImage.status === Image.Ready && pinchItem.width >= 0 && pinchItem.height >= 0  && pinchItem.paramIniting !== 0){
                    initParam();
                }
            }
        }
    }

    Component{
        id:gifImageCom
        AnimatedImage {
            id: gifImage
            cache: true
            source: pinchItem.source
            autoTransform:true
            asynchronous:true
            playing: true
//            onSourceChanged: {
//                pinchItem.paramInited = false;
//            }

//            onStatusChanged:{
//                if (gifImage.status === AnimatedImage.Ready && pinchItem.width >= 0 && pinchItem.height >= 0  && pinchItem.paramIniting !== 0){
//                    initParam();
//                }
//            }

            //AnimatedImage 先发送Ready 然后才 设置sourceize
            onSourceSizeChanged: {
                if (editImage.item &&  gifImage.status === AnimatedImage.Ready && pinchItem.width >= 0 && pinchItem.height >= 0  && pinchItem.paramIniting !== 0){
                    initParam();
                }
            }
        }
    }

    Timer {
        id: imgClickTimer
        interval: 200
        onTriggered: {
            imgMouse.clickCount = 0
            if(Math.abs(imgMouse.releaseX - imgMouse.pressedX) <= 30 && Math.abs(imgMouse.releaseY - imgMouse.pressedY) <= 30)
                pinchItem.clicked();
        }
    }

    Timer{
        id:delayReleaseTimer
        interval: 100
        onTriggered: {
            pinchItem.calculateImagePos();
        }
    }

    MouseArea{
        id:imgMouse

        property int oldx: 0
        property int oldy: 0

        property int pressedX: 0
        property int pressedY: 0

        property int releaseX: 0
        property int releaseY: 0

        property int clickCount: 0
        anchors.fill: parent

        enabled: pinchItem.paramIniting === 1
        property bool posMoved: false
        property bool dbClicked: false

        property int  wheelUnit: 120
        property int wheelTotal: 0

        onWheel: {
            if (pinchItem.setWallpaper === false && wheel.modifiers & Qt.ControlModifier) {
                var scale = 1.0;
                wheelTotal += wheel.angleDelta.y;
                if( wheelTotal >= wheelUnit){
                    wheelTotal = 0;
                    scale = 1.01;
                } else if (wheelTotal <= -wheelUnit){
                    wheelTotal = 0;
                    scale = 0.99;
                }

                if(scale != 1.0){
                    pinchItem.initialWidth = editImage.width
                    pinchItem.initialHeight = editImage.height

                    var oldWidth = editImage.width;
                    var oldHeight = editImage.height;
                    editImage.width = Math.max(pinchItem.scaleMinWidth,
                                               Math.min(pinchItem.initialWidth * scale, pinchItem.originWidth * pinchItem.maxScale));
                    editImage.height = Math.max(pinchItem.scaleMinHeight,
                                                Math.min(pinchItem.initialHeight * scale, pinchItem.originHeight * pinchItem.maxScale));



                    var centerPos = imgMouse.mapToItem(editImage, wheel.x, wheel.y);
                    if(editImage.width <= pinchItem.width){
                        editImage.x = (pinchItem.width - editImage.width) / 2;
                    } else {
                        if(editImage.x < 0 && ((editImage.x + editImage.width) <= pinchItem.width)){
                            if(scale < 1.0){
                                editImage.x -= editImage.width - oldWidth;
                            } else {
                                editImage.x -= (centerPos.x / oldWidth) * (editImage.width - oldWidth);
                            }
                        } else if(editImage.x >= 0){
                            if(scale < 1.0){
                            } else {
                                editImage.x -= (centerPos.x / oldWidth) * (editImage.width - oldWidth);
                            }
                        } else {
                            editImage.x -= (centerPos.x / oldWidth) * (editImage.width - oldWidth);
                        }
                    }

                    if(editImage.height <= pinchItem.height){
                        editImage.y = (pinchItem.height - editImage.height) / 2;
                    } else {
                        if(editImage.y < 0 && ((editImage.y + editImage.height) <= pinchItem.height)){
                            if(scale < 1.0){
                                editImage.y += editImage.height - oldHeight;
                            } else {
                                editImage.y -= (centerPos.y / oldHeight) * (editImage.height - oldHeight);
                            }
                        } else if(editImage.y >= 0){
                            if(scale < 1.0){

                            } else {
                                editImage.y -= (centerPos.y / oldHeight) * (editImage.height - oldHeight);
                            }
                        } else {
                            editImage.y -= (centerPos.y / oldHeight) * (editImage.height - oldHeight);
                        }
                    }
                }
            } else {
                wheel.accepted = false;
            }
        }

        onClicked: {
            imgMouse.clickCount ++
            if (imgMouse.clickCount === 2) {
                simulateDoubleClick(mouse);
            } else if (!imgClickTimer.running) {
                imgClickTimer.start()
            }
        }

        function simulateDoubleClick(mouse){
            if(delayReleaseTimer.running){
                delayReleaseTimer.stop();
            }

            if(zoomAnim.running){
                zoomAnim.stop();
            }

            imgMouse.clickCount = 0
            if (imgClickTimer.running) {
                imgClickTimer.stop()
            }

            if (pinchItem.originWidth === editImage.width && pinchItem.originHeight === editImage.height) {
                var pos = pinchItem.mapToItem(editImage, mouse.x, mouse.y);
                var maxWidth = pinchItem.originWidth * pinchItem.maxScale;
                var maxHeight = pinchItem.originHeight * pinchItem.maxScale;
                var newx = editImage.x - (pos.x / editImage.width) * (maxWidth - editImage.width);
                var newy = editImage.y - (pos.y / editImage.height) * (maxHeight - editImage.height);

                zoomAnim.x = newx;
                zoomAnim.y = newy;
                zoomAnim.width = maxWidth;
                zoomAnim.height = maxHeight;
                zoomAnim.running = true;
            } else {
                zoomAnim.x = pinchItem.originX;
                zoomAnim.y = pinchItem.originY;
                zoomAnim.width = pinchItem.originWidth;
                zoomAnim.height = pinchItem.originHeight;
                zoomAnim.running = true;
            }
        }

        onDoubleClicked:{
            dbClicked = true
            simulateDoubleClick(mouse);
        }

        onPressed: {
            posMoved = false;
            oldx = mouse.x
            oldy = mouse.y

            pressedX = mouse.x;
            pressedY = mouse.y;
        }

        onPositionChanged: {
            posMoved = true;
            var movx = mouse.x - oldx;
            var movy = mouse.y - oldy;

            if(pinchItem.setWallpaper === false){
                if(editImage.width >= pinchItem.width){

                    if(editImage.x + movx > 0){
                        editImage.x = 0;
                        imgMouse.preventStealing = false;
                        pinchItem.moveToLeftEdge();
                    } else if(editImage.x + movx + editImage.width <= pinchItem.width){
                        editImage.x = pinchItem.width - editImage.width
                        imgMouse.preventStealing = false;
                        pinchItem.moveToRightEdge();
                    } else {
                        editImage.x += movx;
                        imgMouse.preventStealing = true;
                    }
                } else {
                    imgMouse.preventStealing = false;
                }

                if(editImage.height >= pinchItem.height){
                    if(editImage.y + movy > 0){
                        editImage.y = 0;
                    } else if(editImage.y + movy + editImage.height <= pinchItem.height){
                        editImage.y = pinchItem.height - editImage.height
                    } else {
                        editImage.y += movy;
                    }
                }
            } else {
                editImage.x += movx
                editImage.y += movy;
            }

            oldx = mouse.x;
            oldy = mouse.y;
        }
        onReleased: {
            releaseX = mouse.x;
            releaseY = mouse.y;
            if(pinchItem.setWallpaper === true && posMoved === true && dbClicked === false) {
                delayReleaseTimer.restart();
            }
            posMoved = false;
            dbClicked = false;
        }
    }


    function resetParam(){
        if(editImage.item && editImage.item.status === Image.Ready && pinchItem.paramIniting !== 0){
            initParam();
        }
    }

    function initParam() {

        if(editImage.item.sourceSize.width <= 0 || editImage.item.sourceSize.height <= 0 || pinchItem.paramIniting === 0){
            return;
        }

        pinchItem.paramIniting = 0;
        var sWidth = editImage.item.sourceSize.width;
        var sHeight = editImage.item.sourceSize.height;

        var rateX = sWidth * 1.0 / pinchItem.width
        var rateY = sHeight * 1.0 / pinchItem.height

        if(pinchItem.setWallpaper === true){
            if(rateX >= rateY){
                editImage.height = pinchItem.height;
                editImage.width = sWidth * 1.0 / rateY;
            } else {
                editImage.height = sHeight * 1.0 / rateX;
                editImage.width = pinchItem.width;
            }

            editImage.x = - (editImage.width - pinchItem.width) / 2
            editImage.y = -(editImage.height - pinchItem.height) / 2

            pinchItem.originWidth = editImage.width
            pinchItem.originHeight = editImage.height

            pinchItem.originX = editImage.x;
            pinchItem.originY = editImage.y;

            if(rateX >= rateY){
                var tmpScale = pinchItem.originWidth * 1.0  / (pinchItem.width * 0.6);
                pinchItem.scaleMinWidth = pinchItem.originWidth / tmpScale;
                pinchItem.scaleMinHeight = pinchItem.originHeight / tmpScale;
            } else {
                var tmpScale = pinchItem.originHeight * 1.0  / (pinchItem.height * 0.6);
                pinchItem.scaleMinWidth = pinchItem.originWidth / tmpScale;
                pinchItem.scaleMinHeight = pinchItem.originHeight / tmpScale;
            }

        } else {

            if(rateX >= rateY){
                if(rateX <= 1.0 && pinchItem.fullScreen === false){
                    editImage.width = sWidth;
                    editImage.height = sHeight;
                } else {
                    editImage.width = pinchItem.width;
                    editImage.height = sHeight * 1.0 / rateX;
                }

            } else {
                if(rateY <= 1.0 && pinchItem.fullScreen === false){
                    editImage.width = sWidth;
                    editImage.height = sHeight;
                } else {
                    editImage.height = pinchItem.height;
                    editImage.width = sWidth * 1.0 / rateY;
                }
            }

            pinchItem.originWidth = editImage.width
            pinchItem.originHeight = editImage.height

            if(pinchItem.fullScreen === false){
                editImage.x = - (editImage.width - pinchItem.width) / 2
                editImage.y = -(editImage.height - pinchItem.height) / 2

                pinchItem.scaleMinWidth = pinchItem.originWidth * 0.6;
                pinchItem.scaleMinHeight = pinchItem.originHeight * 0.6;
            } else {
                editImage.x = 0;
                editImage.y = 0;

                pinchItem.width = editImage.width;
                pinchItem.height = editImage.height;

                pinchItem.scaleMinWidth = pinchItem.width;
                pinchItem.scaleMinHeight = pinchItem.height;
            }

            pinchItem.originX = editImage.x;
            pinchItem.originY = editImage.y;
        }
        pinchItem.initFinished();
        pinchItem.paramIniting = 1;
    }

    function calculateImagePos(){
        if(pinchItem.setWallpaper === true){
            if (editImage.width < pinchItem.width || editImage.height < pinchItem.height){
                zoomAnim.x = pinchItem.originX;
                zoomAnim.y = pinchItem.originY;
                zoomAnim.width = pinchItem.originWidth
                zoomAnim.height = pinchItem.originHeight
                zoomAnim.running = true;
            } else if((editImage.x > 0 || editImage.x + editImage.width < pinchItem.width) || (editImage.y > 0 || editImage.y + editImage.height < pinchItem.height)){
                zoomAnim.x = editImage.x > 0 ? 0 : (editImage.x + editImage.width < pinchItem.width ? pinchItem.width - editImage.width : editImage.x);
                zoomAnim.y = editImage.y > 0 ? 0 : (editImage.y + editImage.height < pinchItem.height ? pinchItem.height - editImage.height : editImage.y);
                zoomAnim.width = editImage.width;
                zoomAnim.height = editImage.height
                zoomAnim.running = true;
            }
        } else {
            if (editImage.width <= pinchItem.width && editImage.height <= pinchItem.height){
                zoomAnim.x = (pinchItem.width - editImage.width) / 2;
                zoomAnim.y = (pinchItem.height - editImage.height) / 2;
                zoomAnim.width = editImage.width
                zoomAnim.height = editImage.height
                zoomAnim.running = true;
            } else if (editImage.width <= pinchItem.width && editImage.height >= pinchItem.height){
                zoomAnim.x = (pinchItem.width - editImage.width) / 2;
                zoomAnim.y = editImage.y > 0 ? 0 : (editImage.y + editImage.height < pinchItem.height ? pinchItem.height - editImage.height : editImage.y);
                zoomAnim.width = editImage.width
                zoomAnim.height = editImage.height
                zoomAnim.running = true;
            } else if (editImage.width >= pinchItem.width && editImage.height <= pinchItem.height){
                zoomAnim.x = editImage.x > 0 ? 0 : (editImage.x + editImage.width < pinchItem.width ? pinchItem.width - editImage.width : editImage.x);
                zoomAnim.y = (pinchItem.height - editImage.height) / 2;
                zoomAnim.width = editImage.width
                zoomAnim.height = editImage.height
                zoomAnim.running = true;
            } else if((editImage.x > 0 || editImage.x + editImage.width < pinchItem.width) || (editImage.y > 0 || editImage.y + editImage.height < pinchItem.height)){
                zoomAnim.x = editImage.x > 0 ? 0 : (editImage.x + editImage.width < pinchItem.width ? pinchItem.width - editImage.width : editImage.x);
                zoomAnim.y = editImage.y > 0 ? 0 : (editImage.y + editImage.height < pinchItem.height ? pinchItem.height - editImage.height : editImage.y);
                zoomAnim.width = editImage.width;
                zoomAnim.height = editImage.height
                zoomAnim.running = true;
            }

            if(editImage.width >= pinchItem.width){
                if(editImage.x > 1){
                    imgMouse.preventStealing = false;
                } else if(editImage.x + editImage.width < pinchItem.width - 1){
                    imgMouse.preventStealing = false;
                }
            } else {
                imgMouse.preventStealing = false;
            }
        }
    }
}
