/*
 * Copyright 2021 Lele Huan <huanlele@jingos.com>
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

import QtQuick 2.12
import QtQml 2.12
import org.kde.kirigami 2.5
import org.kde.kirigami 2.15 as Kirigami
PinchArea{
    id:pinchItem
    //anchors.fill: parent
    property bool isGif : false
    property string source : "file:///home/jingos/image/11.jpg"
    //是否是设置壁纸
    property bool setWallpaper: false

    //等比例拉满全屏
    property bool fullScreen: false

    //最大放大比例
    property real maxScale : 3.0

    //图片初始化宽度
    property real originWidth
    //图片初始化高度
    property real originHeight

    //图片初始化x坐标
    property real originX
    //图片初始化y坐标
    property real originY

    //最小缩放宽度
    property real scaleMinWidth
    //最小缩放高度
    property real scaleMinHeight

    //手势识别开始时的图片的宽高
    property real initialWidth
    property real initialHeight

    //编辑的图片
    property alias editImg: editImage

    //参数是否初始化完成,
    property bool paramInited: false
    signal moveToLeftEdge();
    signal moveToRightEdge();
    signal clicked()
    //页面初始化完成
    signal initFinished()
    clip: true


    onWidthChanged: {
        console.log("jimage viewer modify qml  width changed  " + pinchItem.width +  " invoke init param " + pinchItem.source)
        pinchItem.paramInited = false;
        delayTimer.restart()
    }

    onHeightChanged: {
        console.log("jimage viewer modify qml  height changed  " + pinchItem.height + " invoke init param " + pinchItem.source)
        pinchItem.paramInited = false;
        delayTimer.restart()
    }

    onPinchStarted:{
        initialWidth = editImage.width
        initialHeight = editImage.height
    }

    onPinchUpdated:{

//        var movx = pinch.previousCenter.x - pinch.center.x;
//        var movy = pinch.previousCenter.y - pinch.center.y;

        //先禁用双手拖动事件,这部分在边界处理时有问题，后期有时间再打开，
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
    }

    Component{
        id:staticImageCom
        Image {
            id: staticImage
            cache: false
            source: pinchItem.source
            autoTransform:true
            asynchronous:true
            onSourceChanged: {
                pinchItem.paramInited = false;
            }

            onStatusChanged:{
                console.log("image status changed " + staticImage.status + "  source " + pinchItem.source)
                if (staticImage.status === Image.Ready){
                    delayTimer.restart();
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
            onSourceChanged: {
                pinchItem.paramInited = false;
            }

            onStatusChanged:{
                console.log("image status changed " + gifImage.status + "  source " + pinchItem.source)
                if (gifImage.status === AnimatedImage.Ready){
                    delayTimer.restart();
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
                console.log("pinchitem clicked")
                pinchItem.clicked();
        }
    }

    Timer{
        id:delayReleaseTimer
        interval: 100
        onTriggered: {
            console.log("on release calculate iamge pos")
            pinchItem.calculateImagePos();
        }
    }

    MouseArea{
        id:imgMouse

        //上一次点击位置
        property int oldx: 0
        property int oldy: 0

        //鼠标按下的位置
        property int pressedX: 0
        property int pressedY: 0

        //鼠标松开位置
        property int releaseX: 0
        property int releaseY: 0

        //间隔时间内点击次数,用来判断是否发送click事件
        property int clickCount: 0
        anchors.fill: parent
        enabled: pinchItem.paramInited //参数初始化完成之后才能操作
        property bool posMoved: false
        property bool dbClicked: false
        onClicked: {
            imgMouse.clickCount ++
            //这里使用两次点击模拟一次双击事件，主要是在触摸屏上不容易出现doubleclick事件，
            if (imgMouse.clickCount === 2) {
                console.log(" twice clicked invoke double clicke")
                simulateDoubleClick(mouse);
            } else if (!imgClickTimer.running) {
                imgClickTimer.start()
            }
        }

        function simulateDoubleClick(mouse){
            if(delayReleaseTimer.running){
                console.log("simulateDoubleClick  delay release timer is running , stop timer");
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
            console.log("double clicked")
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
        //on release 事件在 doubleclick之后发出
        onReleased: {
            releaseX = mouse.x;
            releaseY = mouse.y;
            if(pinchItem.setWallpaper === true && posMoved === true && dbClicked === false){
                //这里使用延迟，主要是为了确定是否要执行doubleclick事件，如果执行doubleclick，就会取消改timer，doubleclick也会设置图片大小
                console.log("onrelase   delay timer restart")
                delayReleaseTimer.restart();
            }
            posMoved = false;
            dbClicked = false;
        }
    }

    Component.onCompleted: {
        delayTimer.start();
    }

    Timer{
        id:delayTimer
        interval: 10
        running: false
        repeat: false
        onTriggered: {
            if(editImage.status === Loader.Ready && editImage.item && editImage.item.status === Image.Ready && (pinchItem.width > 0 && pinchItem.height > 0)){
                console.log("delay timer init param")
                pinchItem.initParam();
            }
        }
    }

    function resetParam(){
        if(editImage.status === Loader.Ready && editImage.item && editImage.item.status === Image.Ready){
            console.log("reset param")
            pinchItem.paramInited = false;
            initParam();
        }
    }

    function initParam() {
        //console.log("initParam  source is " + pinchItem.source)
        var sWidth = editImage.item.sourceSize.width;
        var sHeight = editImage.item.sourceSize.height;

        if(sWidth <= 0 || sHeight <= 0 || pinchItem.width <= 0 || pinchItem.height <= 0){
//            console.log("invoke  init param   soursize is " + editImage.sourceSize
//                        + "  pinchitem width is " + pinchItem.width + "  height is " + pinchItem.height + " return")
            return;
        }

        if(pinchItem.paramInited === true){
            //console.log("invoke init param pinchItem.paramInited  is true, return")
            return;
        }

        console.log("invoke  init param   soursize is " + editImage.item.sourceSize
                    + "  pinchitem width is " + pinchItem.width + "  height is " + pinchItem.height + "   source " + pinchItem.source)

        var rateX = sWidth * 1.0 / pinchItem.width
        var rateY = sHeight * 1.0 / pinchItem.height

        if(pinchItem.setWallpaper === true){
            //图片的宽度和显示区域的宽度比例 大于 图片的高度和显示区域的高度比例，则把高度落满全屏，则宽度肯定大于全屏
            if(rateX >= rateY){
                editImage.height = pinchItem.height;
                editImage.width = sWidth * 1.0 / rateY;
            } else {
                //图片的宽度和显示区域的宽度比例 小于 图片的高度和显示区域的高度比例，则把宽度度落满全屏，则高度肯定大于全屏
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

            //图片的宽度和显示区域的宽度比例 大于 图片的高度和显示区域的高度比例
            if(rateX >= rateY){
                if(rateX <= 1.0 && pinchItem.fullScreen === false){
                    //图片的原始宽度小于显示区域宽度，则按照原始大小显示
                    editImage.width = sWidth;
                    editImage.height = sHeight;
                } else {
                    //图片的原始宽度大于显示区域宽度，则按照高度全屏显示
                    editImage.width = pinchItem.width;
                    editImage.height = sHeight * 1.0 / rateX;
                }

            } else {
                //图片的宽度和显示区域的宽度比例 小于 图片的高度和显示区域的高度比例
                if(rateY <= 1.0 && pinchItem.fullScreen === false){
                    //图片的原始高度小于显示区域高度，则按照原始大小显示
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
                //如果时布满显示区域,则将显示区域的宽高设置成图片的宽高
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

        pinchItem.paramInited = true;
        pinchItem.initFinished();
    }

    function calculateImagePos(){
        //设置锁屏壁纸模式
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
            //图片预览模式
            //图片大小小于显示区域大小
            if (editImage.width <= pinchItem.width && editImage.height <= pinchItem.height){
                zoomAnim.x = (pinchItem.width - editImage.width) / 2;
                zoomAnim.y = (pinchItem.height - editImage.height) / 2;
                zoomAnim.width = editImage.width
                zoomAnim.height = editImage.height
                zoomAnim.running = true;
            } else if (editImage.width <= pinchItem.width && editImage.height >= pinchItem.height){
                //图片宽度小于显示区域宽度，图片高度大于显示区域高度
                zoomAnim.x = (pinchItem.width - editImage.width) / 2;
                zoomAnim.y = editImage.y > 0 ? 0 : (editImage.y + editImage.height < pinchItem.height ? pinchItem.height - editImage.height : editImage.y);
                zoomAnim.width = editImage.width
                zoomAnim.height = editImage.height
                zoomAnim.running = true;
            } else if (editImage.width >= pinchItem.width && editImage.height <= pinchItem.height){
                //图片高度小于显示区域高度，图片宽度大于显示区域宽度
                zoomAnim.x = editImage.x > 0 ? 0 : (editImage.x + editImage.width < pinchItem.width ? pinchItem.width - editImage.width : editImage.x);
                zoomAnim.y = (pinchItem.height - editImage.height) / 2;
                zoomAnim.width = editImage.width
                zoomAnim.height = editImage.height
                zoomAnim.running = true;
            } else if((editImage.x > 0 || editImage.x + editImage.width < pinchItem.width) || (editImage.y > 0 || editImage.y + editImage.height < pinchItem.height)){
                //图片宽高都大于显示区域宽高
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
