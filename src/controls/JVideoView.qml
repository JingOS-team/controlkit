/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Yu Jiashu <yujiashu@jingos.com>
 *
 */

import QtQuick 2.0
import QtQml 2.12
import org.kde.kirigami 2.15 as Kirigami
Rectangle {
    id: root
    property bool isShow: false
    property string playVideoPath: ""
    property var mpvVideo: null
    property Item renderItem: null
    property string strVideoTitle: ""
    property string videoName: ""
    property string videoDisplayName: ""
    property bool footAndHeadVisible: true
    property int videoVolume: 0
    property bool canPlay: isShow === true && mpvVideo
    property int orientation: 0
    property bool alreadyStartPlay: false
    property bool useMpv: false

    signal setOsdVolume(real volumeData)
    signal setOsdBritness(real brirnessData)

    color: "black"
    anchors.fill: parent


    Connections{
        target: Qt.application
        function onStateChanged(){
            if(Qt.application.state === Qt.ApplicationActive){
                if(alreadyStartPlay === false){
                    readyTimer.restart();
                }
            } else if(Qt.application.state === Qt.ApplicationInactive){
                if(canPlay && mpvVideo ){
                    if(root.useMpv) {
                        if(mpvVideo.pause === false) {
                            mpvVideo.pause = true;
                        }
                    } else {
                        if(mpvVideo.playbackState === 1){
                            mpvVideo.pause();
                        }
                    }
                }
            }
        }

    }

    onCanPlayChanged: {
        if(canPlay){
            if(!root.renderItem){
                if(root.useMpv){
                    root.renderItem = Qt.createQmlObject('import jingos.multimedia 1.0; MpvRenderItem{ id:renderItem;  anchors.fill: parent;  mpvObj: root.mpvVideo;}', root);
                } else {
                    root.renderItem = Qt.createQmlObject('import QtMultimedia 5.15
                                                        import QtQuick 2.0
                                                        import QtQml 2.12
                                                        VideoOutput{
                                                            id:vo
                                                            anchors.fill: parent
                                                            orientation:root.orientation
                                                            property bool canShowVideo : true
                                                            Component.onCompleted: {root.mpvVideo.addRenderItem(vo)}
                                                            Component.onDestruction: {root.mpvVideo.clearRenderItem(vo)}
                                                        }', root);
                }
            }
            root.footAndHeadVisible = true
            headerFooterHideTimer.restart()
            readyTimer.restart();
        } else {
            root.alreadyStartPlay = false;
            root.renderItem.canShowVideo = false;
        }
    }

    Loader{
        active: root.useMpv
        sourceComponent: mpvCom
    }

    Component{
        id:mpvCom
        Connections{
            target: mpvVideo
            function onFileLoaded(){
                if(root.canPlay && root.alreadyStartPlay === true){
                    delaySetCanShowTimer.restart();
                }
            }
        }
    }

    Timer{
        id:delaySetCanShowTimer
        interval: 30
        running: false
        repeat: false
        onTriggered: {
            if(root.canPlay && root.alreadyStartPlay === true){
                root.renderItem.canShowVideo = true;
            }
        }
    }

    function restartHideHeadFooterTimer (){
        headerFooterHideTimer.restart();
    }

    Timer {
        id:readyTimer
        interval: 50
        running: false
        repeat: false
        onTriggered: {
            if(root.canPlay && mpvVideo && Qt.application.state === Qt.ApplicationActive) {
                if(root.useMpv){
                    mpvVideo.videoRotate = 0;
                    mpvVideo.pause = false
                    mpvVideo.startPlay(root.playVideoPath)
                } else {

                    mpvVideo.source = root.playVideoPath
                    mpvVideo.play();
                    root.orientation = 0;
                    root.renderItem.canShowVideo = true;
                }
                root.alreadyStartPlay = true
            }
        }
    }

    MouseArea{
        id: videoMosue
        anchors.fill: parent
        hoverEnabled: true
        property real oldx: 0.0
        property real oldy: 0.0
        property real pressedX: 0.0
        property real pressedY: 0.0
        property real releaseX: 0.0
        property real releaseY: 0.0
        property int clickCount: 0

        onWheel: {

            if(wheel.angleDelta.x === 0 && wheel.angleDelta.y !== 0) {
                if (wheel.x < root.width / 2) {
                    setOsdBritness(-wheel.angleDelta.y/120)
                } else {
                    setOsdVolume(-wheel.angleDelta.y/120)
                }
                wheel.accepted = true;
            } else {
                wheel.accepted = false;
            }
        }

        onClicked: {
            videoMosue.clickCount ++
            if (videoMosue.clickCount === 2) {
                simulateDoubleClick(mouse)
            } else if(!delayClickTimer.running) {
                delayClickTimer.start()
            }
        }

        onDoubleClicked: {
            simulateDoubleClick(mouse)
        }

        onPositionChanged: {
            if(videoMosue.pressed) {
                var distanceY = mouse.y - pressedY
                if(Math.abs(distanceY) < 15){
                    return;
                }
                videoMosue.preventStealing = true;
                var movy = mouse.y - oldy
                if (pressedX < root.width / 2) {
                    setOsdBritness(-movy)
                } else {
                    setOsdVolume(-movy)
                }
            }
            oldy = mouse.y
        }

        onPressed: {
            oldx = mouse.x
            oldy = mouse.y

            pressedX = mouse.x
            pressedY = mouse.y
        }

        onReleased: {
            releaseX = mouse.x
            releaseY = mouse.y
            videoMosue.preventStealing = false;
        }

        function simulateDoubleClick(mouse) {
            if(mpvVideo){
                if(root.useMpv){
                    mpvVideo.pause = !mpvVideo.pause
                } else {
                    if(mpvVideo.playbackState !== 1){
                        mpvVideo.play()
                    } else {
                        mpvVideo.pause();
                    }
                }


            }

            videoMosue.clickCount = 0
            if (delayClickTimer.running) {
                delayClickTimer.stop()
            }
            if(footAndHeadVisible === true){
                headerFooterHideTimer.restart();
            }
        }
    }

    Timer {
        id: headerFooterHideTimer
        running: false
        repeat: false
        interval: 10 * 1000
        onTriggered: {
            footAndHeadVisible = false
        }
    }

    Timer {
        id: delayClickTimer
        interval: 200
        onTriggered: {
            videoMosue.clickCount = 0
            if(Math.abs(videoMosue.releaseX - videoMosue.pressedX) <= 30 &&
                    Math.abs(videoMosue.releaseY - videoMosue.pressedY) <= 30){
                footAndHeadVisible=!footAndHeadVisible
                if(footAndHeadVisible){
                    headerFooterHideTimer.restart()
                }
            }
        }
    }

    onPlayVideoPathChanged: {
       videoName = playVideoPath.substr(playVideoPath.lastIndexOf('/') + 1)
        if( videoName.length > 40) {
            videoDisplayName = videoName.substr(0,40) + "..."
        } else {
             videoDisplayName = videoName
        }
    }
}
