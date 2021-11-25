/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.15 as Kirigami
import jingos.display 1.0

import "./videoPlayer"
import "./ImagePreview"
//user need set a model,
/*
model view data
mimeType : image type  image/gif
mediaType: 0 image 1 video
previewurl: path
imageTime: file create time
mediaurl: video file path
*/
Kirigami.Page {
    id: root
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
    clip:true

    property bool usePageStack : true
    property var startIndex
    property var imagesModel
    property bool isFirstOpenPage: true
    property string imageDetailTitle
    property string wallpaperUrl
    property string croppaperUrl
    property string cropMimeType: ""
    property var rootWindow: null
    property var oldVisibility
    property bool imageIncreaseByCrop: false
    property alias listCurrIndex: listView.currentIndex

    signal close();
    signal requestFullScreen();
    signal cropImageFinished(string path, string mimeType)
    signal deleteCurrentPicture(int index, string path);

    signal playVideo(string mediaUrl);
    signal spaceKeyPressed()

    //true use mpv， false use mediaplayer
    property bool useMpv: true

    background: Rectangle {
        color: "black"
    }

    onWindowChanged:{
        if(!root.rootWindow){
            root.rootWindow = window;
            root.oldVisibility = root.rootWindow.visibility;
        }
    }

    function getRootWindow(){
        if(typeof applicationWindow === "function"){
            root.rootWindow =  applicationWindow();
            root.oldVisibility = root.rootWindow.visibility;
        }
    }

    function openCropPictureView(imageUrl, mimeType) {
        root.croppaperUrl = imageUrl;
        root.cropMimeType = mimeType;
        if(typeof applicationWindow === "function" && root.usePageStack === true){
            applicationWindow().pageStack.layers.push(cropPicCom)
        } else {
            cropImageLoader.active = true;
        }
    }

    function closeCropPictureView() {

        if(typeof applicationWindow === "function" && root.usePageStack === true){
            applicationWindow().pageStack.layers.pop()
        } else {
            cropImageLoader.active = false;
        }
    }

    function openWallpaperView(imageUrl){
        root.wallpaperUrl = imageUrl
        if(typeof applicationWindow === "function" && root.usePageStack === true){
            applicationWindow().pageStack.layers.push(wallpaperComponent)
        } else {
            wallpaperLoader.active = true;
        }
    }

    function popWallpaperView(){
        if(typeof applicationWindow === "function" && root.usePageStack === true){
            applicationWindow().pageStack.layers.pop()
        } else {
            wallpaperLoader.active = false;
        }
    }

    function setInteractive(active){
            if(typeof applicationWindow === "function"){
                var win = applicationWindow();
                if(win.pageStack){
                    win.pageStack.interactive = active;
                }
            }
        }

    function actionClicked(flag){    
        switch (flag) {
        case 1:
            root.openCropPictureView(listView.currentItem.previewUrl, listView.currentItem.mimeType)
            break
        case 2:
            //saveToFileClicked()
            break
        case 3:
            root.openWallpaperView(listView.currentItem.previewUrl)
            break
        case 4:
            deleteDialog.open()
            break
        case 5:
            listView.rorateView()
            break;
        }
    }

    Component.onCompleted: {
        getRootWindow();
        delayForcusTimer.start();
    }

    Component.onDestruction: {

        if(root.rootWindow){
            root.rootWindow.visibility =  root.oldVisibility;
        }
    }

    Keys.onPressed: {
        switch (event.key) {

        case Qt.Key_Escape:
            if(deleteDialog.visible === false && wallpaperLoader.active === false && cropImageLoader.active === false){
                root.close()
            }
            break
        case Qt.Key_F:
            if(deleteDialog.visible === false){
                if(root.rootWindow){
                    root.rootWindow.visibility = (root.rootWindow.visibility === Window.FullScreen ? Window.Windowed : Window.FullScreen);
                } else {
                    root.requestFullScreen()
                }
            }
            break
        case Qt.Key_Space:
            spaceKeyPressed()
            break
        default:
            break
        }
    }

    Keys.onSpacePressed: {
        if(listView.mpvObj && listView.currentItem && listView.currentItem.isVideo){
            if(root.useMpv){
                listView.mpvObj.pause = !listView.mpvObj.pause
            } else {
                /*
                StoppedState,  0
                PlayingState,   1
                PausedState    2
                 */
                if(listView.mpvObj.playbackState !== 1){
                    listView.mpvObj.play()
                } else {
                    listView.mpvObj.pause();
                }
            }

        }
    }

    Timer{
        id:delayForcusTimer
        running: false
        repeat: false
        interval: 200
        onTriggered: {
            listView.forceActiveFocus();
        }
    }

    ListView {
        id: listView

        anchors.fill: parent
        orientation: Qt.Horizontal
        snapMode: ListView.SnapOneItem
        maximumFlickVelocity: 10000

        highlightMoveVelocity: 9000
        highlightMoveDuration: 0
        highlightRangeMode: ListView.StrictlyEnforceRange
        interactive: true
        keyNavigationEnabled:false

        model: imagesModel
        property bool completedOk : false
        property var mpvObj: null
        Component.onCompleted: {
            listView.currentIndex = startIndex

            if (!setCacheTimer.running & listView.cacheBuffer != listView.width * 5) {
                setCacheTimer.start()
            }
            listView.completedOk = true;
        }

        Keys.onReleased : {
            if(event.isAutoRepeat === false){
                if(event.key === Qt.Key_Right){
                    if(listView.currentIndex < listView.count - 1){
                        listView.currentIndex += 1
                    }
                } else if(event.key === Qt.Key_Left){
                    if(listView.currentIndex >= 1){
                        listView.currentIndex -= 1;
                    }
                }
            }
        }

        onCountChanged: {
            if((count === 0 || listView.currentIndex >= count) && listView.completedOk === true){
                root.close();
            }
            if(root.imageIncreaseByCrop === true){
                if(listView.currentIndex + 1 < count){
                    listView.currentIndex++;
                }
                root.imageIncreaseByCrop = false;
            }
        }

        delegate:Item{
            id:deleViewer
            width: root.width
            height: root.height
            property bool isVideo: model.mediaType === 1
            property bool  isGif: deleViewer.mimeType === "image/gif"
            property string imageTime: model.imageTime
            property string mediaUrl: model.mediaurl
            property string mimeType: model.mimeType
            property string previewUrl: model.previewurl
            property alias deleItem: deleLoader.item
            Loader{
                id:deleLoader
                anchors.fill: parent
                sourceComponent: deleViewer.isVideo ? videoCom : imageCom
                onLoaded: {
                    if(item){
                        if(deleViewer.isVideo){
                            if(!listView.mpvObj) {
                                delayCreateMediaObjTimer.restart();
                            }
                            item.playVideoPath = deleViewer.mediaUrl;
                            if(listView.currentIndex === model.index) {
                                item.isShow = true;

                                footer.setSliderValue(0)
                                footer.visible = true

                                deleViewer.imageTime = item.videoDisplayName
                                titleItem.visible = true
                            }
                        } else {
                            item.isGif =  deleViewer.isGif
                            item.source = deleViewer.previewUrl;
                        }
                    }
                }
            }

            Connections{
                target: listView
                function onCurrentIndexChanged() {
                    if(listView.moving === false)
                        indexOrCountChange()
                }

                function onCountChanged() {
                    if((listView.count === 0 || listView.currentIndex >= listView.count) && listView.completedOk === true) {
                        root.close()
                    }
                    indexOrCountChange()
                }

                function onMovementEnded(){
                    indexOrCountChange();
                }

                function indexOrCountChange() {
                    if(listView.currentIndex !== model.index) {
                        if(deleViewer.isVideo){
                            if(deleLoader.item.isShow === true){
                                deleLoader.item.isShow = false;
                                if(listView.mpvObj){
                                    if(root.useMpv){
                                        listView.mpvObj.pause = true;
                                    } else {
                                        listView.mpvObj.stop();
                                    }
                                }
                            }
                        } else {
                            deleLoader.item.resetParam()
                        }
                    } else {
                        if(deleViewer.isVideo && deleLoader.item) {
                            deleLoader.item.isShow = true;
                            titleItem.visible = true;
                            footer.visible = true;
                        } else {
                            footer.visible = false
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: {
                    if(deleLoader.status === Loader.Null || deleLoader.status === Loader.Error)  {
                        return true
                    } else {
                        if(deleViewer.isVideo) {
                            return  false
                        } else {
                            if(deleViewer.deleItem.mouseEbable) {
                                return false
                            } else {
                                return  true
                            }
                        }
                    }
                }
                onClicked: {
                     titleItem.visible = !titleItem.visible
                }
            }
        }

        Component{
            id:imageCom
            JImageViewer {
                id: imgViewer
                onClicked: {
                    titleItem.visible = !titleItem.visible
                }
            }
        }

        Component {
            id: videoCom
            JVideoView {
                id: video
                strVideoTitle: imageDetailTitle
                mpvVideo: listView.mpvObj
                useMpv: root.useMpv
                onFootAndHeadVisibleChanged: {
                    if(listView.currentItem && listView.currentItem.isVideo && video.isShow) {
                        titleItem.visible = video.footAndHeadVisible
                        footer.visible = video.footAndHeadVisible
                    }
                }

                onSetOsdBritness: {
                    osdItem.dealBrightness(brirnessData)
                }

                onSetOsdVolume: {
                    osdItem.dealVolume(volumeData)
                    if(mpvVideo) {
                        if(root.useMpv) {
                            mpvVideo.volume = osdItem.volume
                        } else {
                            mpvVideo.volume = osdItem.volume/100
                        }
                    }
                }
            }
        }


        Timer {
            id: setCacheTimer
            interval: 500
            onTriggered: {
                if (listView.cacheBuffer != listView.width * 5) {
                    listView.cacheBuffer = listView.width * 5
                }
            }
        }

        function rorateView() {
            if(listView.mpvObj) {
                if(root.useMpv){
                    listView.mpvObj.videoRotate = listView.mpvObj.videoRotate + 90
                    if(listView.mpvObj.pause === true) {
                        listView.mpvObj.seekPosition(listView.mpvObj.position)
                    }
                } else {
                    if(listView.currentItem.isVideo){
                        if(listView.currentItem.deleItem.orientation === 0){
                            listView.currentItem.deleItem.orientation = 270;
                        } else {
                            listView.currentItem.deleItem.orientation = listView.currentItem.deleItem.orientation - 90;
                        }
                    }
                }
                listView.currentItem.deleItem.restartHideHeadFooterTimer()
            }
        }

        Timer {
            id:delayCreateMediaObjTimer
            interval: 300
            onTriggered: {
                listView.createMpvObject();
            }
        }

        function createMpvObject() {
            if(root.useMpv){
                listView.mpvObj = Qt.createQmlObject('import jingos.multimedia 1.0; MpvObject {}', root);
            } else {
                listView.mpvObj = Qt.createQmlObject('import QtMultimedia 5.15
                                                        import jingos.multimedia 1.0
                                                        MediaPlayer{
                                                            id:qmp
                                                            notifyInterval:200
                                                            videoOutput: JBaseVideoSurface{id:jbv}
                                                            function addRenderItem(item){jbv.addRenderItem(item)}
                                                            function clearRenderItem(item){jbv.clearRenderItem(item)}
                                                        }', root);
            }

            if(listView.mpvObj == null) {
                console.log("Error creating object");
            } else {
                if(root.useMpv) {
                    listView.mpvObj.volume = osdItem.volume
                } else {
                    listView.mpvObj.volume = osdItem.volume/100
                }

            }
        }
    }

    //left Navigation buttons
    Item {
        id: leftItem

        anchors .left: parent.left
        height:  parent.height - titleItem.height
        width: leftArrow.width +  JDisplay.dp(10)
        anchors.bottom: parent.bottom
        visible: listView.currentIndex !== 0

        MouseArea {
            id:leftIconMouse
            anchors.fill: parent
            hoverEnabled: true
        }

        Image {
            id: leftArrow
            anchors {
                left: parent.left
                leftMargin: Kirigami.Units.largeSpacing
                verticalCenter: parent.verticalCenter
            }
            source: "./image/imagePreviewIcon/leftarrow.png"
            sourceSize: Qt.size(JDisplay.dp(30), JDisplay.dp(30))
            opacity:leftIconMouse.containsMouse ? 1.0 : 0.0

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    listView.currentIndex > 1 ? (listView.currentIndex -= 1) : (listView.currentIndex = 0)
                }
            }
        }
    }

    //right Navigation buttons
    Item {
        id: rightItem

        anchors.right: parent.right
        //height:titleItem.visible ? parent.height - titleItem.height : parent.height
        height: parent.height - titleItem.height
        width: rightArrow.width +  JDisplay.dp(10)
        anchors.bottom: parent.bottom
        visible: listView.currentIndex !== (listView.count - 1)

        MouseArea {
            id:rightIconMouse
            anchors.fill: parent
            hoverEnabled: true
        }

        Image {
            id: rightArrow

            anchors {
                right: parent.right
                rightMargin: Kirigami.Units.largeSpacing
                verticalCenter: parent.verticalCenter
            }
            source: "./image/imagePreviewIcon/rightarrow.png"
            sourceSize: Qt.size(JDisplay.dp(30), JDisplay.dp(30))
            opacity: rightIconMouse.containsMouse ? 1.0 : 0.0

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    (listView.currentIndex < listView.count - 1) ? listView.currentIndex += 1 : (listView.currentIndex = listView.currentIndex)
                }
            }
        }
    }


    //title
    Item {
        id:titleItem
        width: parent.width
        height: JDisplay.dp(60)
        visible: false
//        Kirigami.JBlurBackground{
//            anchors.fill:parent
//            sourceItem: listView
//            showBgBoder:false
//            blurRadius: 130
//            radius: 0
//        }

        Rectangle {
            anchors.fill: parent
            color:Kirigami.JTheme.background
        }

        Item {
            id: titleBarLeftTitle
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            height: parent.height - JDisplay.dp(18)
            width: parent.width

            Kirigami.JIconButton {
                id: back
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: JDisplay.dp(9)
                width: JDisplay.dp(22 + 10)
                height: width
                source: Qt.resolvedUrl("./image/imagePreviewIcon/back.svg")
                onClicked:{
                    root.close();
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: back.right
                anchors.leftMargin: JDisplay.dp(8)
                font.pointSize: JDisplay.sp(12)
                width: titleBarLeftTitle.width / 2
                color: Kirigami.JTheme.majorForeground
                elide: Text.ElideRight
                text: (listView.currentItem && listView.currentItem.isVideo) ? listView.currentItem.deleItem.videoDisplayName: listView.currentItem.imageTime
            }

            Row {
                id: imageTitleRight
                height: JDisplay.dp(32)
                anchors.right: parent.right
                anchors.rightMargin: JDisplay.dp(14)
                anchors.verticalCenter: parent.verticalCenter

                spacing: JDisplay.dp(36)

                Repeater {
                    id: btnRepeater
                    model: {
                        if(listView.currentItem){
                            if(listView.currentItem.isVideo){
                                return videoTitleModel
                            } else if(listView.currentItem.isGif){
                                return gifTitleModel
                            } else {
                                return imageTitleModel
                            }
                        } else {
                            return null;
                        }
                    }

                    delegate: Kirigami.JIconButton {
                        width: imageTitleRight.height
                        height:width
                        source: name
                        onClicked:{
                            var flag = model.flag
                            root.actionClicked(flag)
                        }
                    }
                }
            }
        }

        ListModel {
            id: imageTitleModel
            property string cropname : Qt.resolvedUrl("./image/imagePreviewIcon/crop.svg")
            property string magicname : Qt.resolvedUrl("./image/imagePreviewIcon/magic.svg")
            property string deletename : Qt.resolvedUrl("./image/imagePreviewIcon/delete.svg")

            Component.onCompleted: {
                imageTitleModel.append({"name": imageTitleModel.cropname, "flag" : 1})
                imageTitleModel.append({"name": imageTitleModel.magicname, "flag" : 3})
                imageTitleModel.append({"name": imageTitleModel.deletename, "flag" : 4})
            }
        }

        ListModel {
            id: gifTitleModel
            property string deletename : Qt.resolvedUrl("./image/imagePreviewIcon/delete.svg")
            Component.onCompleted: {
                gifTitleModel.append({"name": gifTitleModel.deletename, "flag" : 4})
            }
        }

        ListModel {
            id: videoTitleModel
            property string rotatename : Qt.resolvedUrl("./image/imagePreviewIcon/rotate.svg")
            Component.onCompleted: {
                videoTitleModel.append({"name": videoTitleModel.rotatename, "flag" : 5})
            }
        }
    } // end title

    VideoFooter {
        id: footer
        z:1
        width: parent.width
        visible: false
        Connections{
            target: listView.mpvObj
            function onDurationChanged(){
                if(root.useMpv){
                    footer.duration = listView.mpvObj.duration
                } else {
                    footer.duration = listView.mpvObj.duration / 1000
                }
            }
            function onPositionChanged(){
                if(root.useMpv){
                    footer.setSliderValue(listView.mpvObj.position);
                } else {
                    footer.setSliderValue(listView.mpvObj.position / 1000);
                }
            }
        }
        Component.onDestruction: {
            if(!playStatus) {
                Kirigami.JMediaSetTool.setInhibit(false)
            }
        }
        playStatus:{
            if(listView.mpvObj){
                if(useMpv){
                    return listView.mpvObj.pause;
                } else {
                    return listView.mpvObj.playbackState !== 1
                }
            }
            return true
        }
        onPlayStatusChanged: {
            Kirigami.JMediaSetTool.setInhibit(!playStatus)
        }

        onPlayBtnClicked: {
            if(listView.mpvObj) {
                if(root.useMpv){
                    listView.mpvObj.pause = !listView.mpvObj.pause
                } else {
                    if(listView.mpvObj.playbackState !== 1){
                        listView.mpvObj.play()
                    } else {
                        listView.mpvObj.pause();
                    }
                }
                listView.currentItem.deleItem.restartHideHeadFooterTimer()
            }
        }
        onSeekValue: {
            if(listView.mpvObj){
                if(root.useMpv){
                    listView.mpvObj.seekPosition(value)
                } else {
                    listView.mpvObj.seek(parseInt(value * 1000));
                }
            }
        }

        onSliderPress: {
            listView.currentItem.deleItem.restartHideHeadFooterTimer()
        }

        onZoomBtnClicked: {

        }
    }

    Osd {
        id: osdItem
        visible: false
        z:1

        onInitMediaSetVolume: {
            if(listView.currentItem && listView.currentItem.isVideo) {
                if(listView.mpvObj)
                     if(root.useMpv){
                        listView.mpvObj.volume = osdItem.volume
                     } else {
                        listView.mpvObj.volume = osdItem.volume/100
                     }
            }
        }
    }


    Kirigami.JDialog{
        id:deleteDialog
        title: i18nd("kirigami-controlkit", "Delete")
        text: (listView.currentItem && listView.currentItem.isVideo) ? i18nd("kirigami-controlkit", "Are you sure you want to delete this video?")
                                           : i18nd("kirigami-controlkit", "Are you sure you want to delete this photo?")
        rightButtonText:i18nd("kirigami-controlkit", "Delete")
        leftButtonText: i18nd("kirigami-controlkit", "Cancel")
        visible:false

        onLeftButtonClicked:{
            deleteDialog.close()
        }

        onRightButtonClicked:{
            deleteDialog.close()
            root.deleteCurrentPicture(listView.currentIndex, listView.currentItem.previewUrl);
        }
    }

    Loader{
        id:wallpaperLoader
        anchors.fill: parent
        sourceComponent: wallpaperComponent
        active: false
        onStatusChanged:{
            if (wallpaperLoader.status === Loader.Ready){
                wallpaperLoader.item.parent = Overlay.overlay
            }
        }
    }

    //wallpapersettings
    Component{
        id:wallpaperComponent
        JWallPaperItem{
            id:wallpaperItem

            source: root.wallpaperUrl
            onSetWallPaperFinished:{
                popWallpaperView()
            }
            onCancel:{
                popWallpaperView()
            }
        }
    }

    Loader{
        id:cropImageLoader
        anchors.fill: parent
        sourceComponent: cropPicCom
        active: false
        onStatusChanged:{
            if (cropImageLoader.status === Loader.Ready){
                cropImageLoader.item.parent = Overlay.overlay
            }
        }
    }

    //crop image
    Component {
        id: cropPicCom
        JCropView {
            id: cropView
            imageUrl: root.croppaperUrl
            onCropImageFinished:{
                root.imageIncreaseByCrop = true;
                root.cropImageFinished(path, root.cropMimeType);
                root.closeCropPictureView();
            }
            onClosePage:{
                root.closeCropPictureView();
            }
        }
    }
}
