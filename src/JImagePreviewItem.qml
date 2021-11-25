/*
 * SPDX-FileCopyrightText: (C) 2015 Vishesh Handa <vhanda@kde.org>
 * SPDX-FileCopyrightText: (C) 2017 Atul Sharma <atulsharma406@gmail.com>
 * SPDX-FileCopyrightText: (C) 2017 Marco Martin <mart@kde.org>
 * SPDX-FileCopyrightText: (C) 2021 Wang Rui <wangrui@jingos.com>
 * SPDX-FileCopyrightText: (C) 2021 Yu Jiashu <yujiashu@jingos.com>
 *
 * SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */
import QtQuick 2.12
import QtQuick.Window 2.2
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.15 as Kirigami

import jingos.multimedia 1.0
import "./ImagePreview"
//图片预览插件,用户需要传入一个model,
/*
model 需要的数据有
mimeType : 图片类型  image/gif
mediaType: 0 图片 1 视频
previewurl: 文件路径
imageTime: 文件的时间
mediaUrl: 视频文件路径 (和 mediaType 一样)
*/
Kirigami.Page {
    id: root
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None

    //使用页面管理栈加载改页面调用的其他页面
    property bool usePageStack : true
    //预览图片列表中开始预览的图片索引
    property var startIndex
    //图片列表的 model
    property var imagesModel
    //是否是第一次加载,如果是,显示缩略图,暂时先不用
    property bool isFirstOpenPage: true
    //所预览图片列表标题
    property string imageDetailTitle
    //用来设置壁纸的图片路径
    property string wallpaperUrl
    //用来进行裁剪的图片路径
    property string croppaperUrl
    //用俩进行裁剪的图片 mimetype
    property string cropMimeType: ""
    //ApplicationWindow 句柄,
    property var rootWindow: null
    property var oldVisibility
    //页面关闭信号
    signal close();
    //请求全屏显示
    signal requestFullScreen();
    //图片裁剪或者旋转 完成 path为新图片路径
    signal cropImageFinished(string path, string mimeType)
    //删除 指定图片, index为model中索引,path为图片路径
    signal deleteCurrentPicture(int index, string path);

    signal playVideo(string mediaUrl);

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

    //加载裁剪图片控件
    function openCropPictureView(imageUrl, mimeType) {
        console.log("crop picture " + imageUrl)
        root.croppaperUrl = imageUrl;
        root.cropMimeType = mimeType;
        if(typeof applicationWindow === "function" && root.usePageStack === true){
            console.log("push crop item")
            applicationWindow().pageStack.layers.push(cropPicCom)
        } else {
            console.log("use loader to load crop item")
            cropImageLoader.active = true;
        }
    }

    //关闭裁剪图片控件
    function closeCropPictureView() {

        if(typeof applicationWindow === "function" && root.usePageStack === true){
            console.log("closeCropPict applicationWindow().pageStack.layers.push(videoView)ureView use page stack layer pop")
            applicationWindow().pageStack.layers.pop()
        } else {
            console.log("closeCropPictureView use loader set false")
            cropImageLoader.active = false;
        }
    }

    //打开设置壁纸页面
    function openWallpaperView(imageUrl){
        console.log("open wall paper  picture " + imageUrl)
        root.wallpaperUrl = imageUrl
        if(typeof applicationWindow === "function" && root.usePageStack === true){
            console.log("use page push " + imageUrl)
            applicationWindow().pageStack.layers.push(wallpaperComponent)
        } else {
            console.log("use wall paper loader ")
            wallpaperLoader.active = true;
        }
    }

    //关闭设置壁纸页面
    function popWallpaperView(){
        if(typeof applicationWindow === "function" && root.usePageStack === true){
            applicationWindow().pageStack.layers.pop()
        } else {
            wallpaperLoader.active = false;
        }
    }

    //标题栏点击按钮触发的动作, 裁剪, 设置壁纸, 删除
    function actionClicked(flag){
        switch (flag) {
        case 1:
            root.openCropPictureView(listView.currentItem.source, listView.currentItem.mimeType)
            break
        case 2:
            //saveToFileClicked()
            break
        case 3:
            root.openWallpaperView(listView.currentItem.source)
            break
        case 4:
            deleteDialog.open()
            break
        }
    }

    Component.onCompleted: {
        getRootWindow();
        delayForcusTimer.start();
    }

    Component.onDestruction: {

        if(root.rootWindow){
            console.log("jimage preview item destruction set visibility to " + root.oldVisibility)
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
        default:
            break
        }
    }

    Timer{
        id:delayForcusTimer
        running: false
        repeat: false
        interval: 10
        onTriggered: {
            console.log(" force ative focus")
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

        model: imagesModel
        property bool completedOk : false
        Component.onCompleted: {
            console.log("listview completed   count is  " + listView.count)
            listView.currentIndex = startIndex

            if (!setCacheTimer.running & listView.cacheBuffer != listView.width * 5) {
                setCacheTimer.start()
            }
            listView.completedOk = true;
        }

        onCountChanged: {
            console.log("11111count changed count is " + count + "  currnent index is " + listView.currentIndex + "  completedok is " + listView.completedOk)
            if((count === 0 || listView.currentIndex >= count) && listView.completedOk === true){
                root.close();
            }
        }

        delegate:JImageViewer{
            id:deleViewer
            width: root.width
            height: root.height
            isGif: model.mimeType === "image/gif"
            property bool isVideo: model.mediaType === 1
            property string imageTime: model.imageTime
            property string mediaUrl: model.mediaurl
            property string mimeType: model.mimeType

            source: model.previewurl
            onClicked: {
                if(!deleViewer.isVideo)
                    titleItem.visible = !titleItem.visible
            }

            Connections{
                target: listView
                function onCurrentIndexChanged() {
                    if(listView.currentIndex !== model.index){
                        deleViewer.resetParam();

                    }
                }
            }

            Loader {
                id: videoPicLoader
                anchors.fill: parent
                sourceComponent: videoPicComponent
                active: deleViewer.isVideo
                asynchronous: true
            }

            Component {
                id: videoPicComponent
                JVideoView{
                    id: video
                    property bool indexChange: true
                    anchors.centerIn: parent
                    playVideoPath:deleViewer.mediaUrl
                    onRequestQuit:{
                        root.close()
                    }
                    onOsdVisibleChanged: {
                        if(indexChange)
                        {
                            if(osdVisible){
                                listView.interactive=false
                            }else{
                                listView.interactive=true
                            }
                        }
                    }
                    Connections{
                        target: listView
                        function onCurrentIndexChanged(){
                            if(listView.currentIndex !== model.index){
                                if(indexChange){
                                    video.stopVideo()
                                    video.indexChange=false
                                }
                            }else{
                                video.resetVideo()
                                titleItem.visible=false
                                video.indexChange=true
                            }
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
    }

    //左侧导航按钮
    Item {
        id: leftItem

        anchors .left: parent.left
//        height:  titleItem.visible ? parent.height - titleItem.height : parent.height
        height:  parent.height - titleItem.height
        width: leftArrow.width + 10 * titleItem.rate
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
            sourceSize: Qt.size(30, 30)
            opacity:leftIconMouse.containsMouse ? 1.0 : 0.0

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    listView.currentIndex > 1 ? (listView.currentIndex -= 1) : (listView.currentIndex = 0)
                }
            }
        }
    }

    //右侧导航按钮
    Item {
        id: rightItem

        anchors.right: parent.right
        //height:titleItem.visible ? parent.height - titleItem.height : parent.height
        height: parent.height - titleItem.height
        width: rightArrow.width
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
            sourceSize: Qt.size(30, 30)
            opacity: rightIconMouse.containsMouse ? 1.0 : 0.0

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    (listView.currentIndex < listView.count - 1) ? listView.currentIndex += 1 : (listView.currentIndex = listView.currentIndex)
                }
            }
        }
    }


    //标题栏
    Item {
        id:titleItem
        property bool isVideoScreen
        property bool isGifImage: false
        property real rate: 1
        width: parent.width
        height: 60 * titleItem.rate
        visible: false
        Kirigami.JBlurBackground{
            anchors.fill:parent
            sourceItem: listView
            showBgBoder:false
            blurRadius: 130
            radius: 0
        }

        Item {
            id: titleBarLeftTitle
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            height: parent.height - 18 * titleItem.rate
            width: parent.width

            Kirigami.JIconButton {
                id: back
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10 * titleItem.rate
                width: parent.height / 2 + 10
                height: width
                source: Qt.resolvedUrl("./image/imagePreviewIcon/back.png")
                onClicked:{
                    console.log("click and send close signal")
                    root.close();
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: back.right
                anchors.leftMargin: 8 * titleItem.rate
                font.pointSize: 15 * titleItem.rate
                width: titleBarLeftTitle.width / 2
                color: Kirigami.JTheme.majorForeground
                elide: Text.ElideRight
                text: root.imageDetailTitle
            }

            Text {
                anchors.centerIn: parent
                font.pointSize: 8 * titleItem.rate
                //color: "#99000000"
                color: Kirigami.JTheme.majorForeground
                text: listView.currentItem.imageTime
            }

            Row {
                id: imageTitleRight
                height: 22 * titleItem.rate + 10
                anchors.right: parent.right
                anchors.rightMargin: 14 * titleItem.rate
                anchors.verticalCenter: parent.verticalCenter

                spacing: 36 * titleItem.rate

                Repeater {
                    id: btnRepeater

                    model: listView.currentItem && (listView.currentItem.isVideo || listView.currentItem.isGif) ? imageVideoModel : imageTitleModel
                    delegate: Kirigami.JIconButton{
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
            property string cropname : Qt.resolvedUrl("./image/imagePreviewIcon/crop.png")
            property string magicname : Qt.resolvedUrl("./image/imagePreviewIcon/magic.png")
            property string deletename : Qt.resolvedUrl("./image/imagePreviewIcon/delete.png")

            Component.onCompleted: {
                imageTitleModel.append({"name": imageTitleModel.cropname, "flag" : 1})
                imageTitleModel.append({"name": imageTitleModel.magicname, "flag" : 3})
                imageTitleModel.append({"name": imageTitleModel.deletename, "flag" : 4})
            }
        }

        ListModel {
            id: imageVideoModel
            property string deletename : Qt.resolvedUrl("./image/imagePreviewIcon/delete.png")
            //            ListElement {
            //                name: imageVideoModel.deletename
            //                flag: 4
            //            }
            Component.onCompleted: {
                imageVideoModel.append({"name": imageVideoModel.deletename, "flag" : 4})
            }
        }
    } // end title

    Kirigami.JDialog{
        id:deleteDialog
        title: i18nd("kirigami-controlkit", "Delete")
        text: listView.currentItem.isVideo ? i18nd("kirigami-controlkit", "Are you sure you want to delete this video?")
                                           : i18nd("kirigami-controlkit", "Are you sure you want to delete this photo?")
        rightButtonText:i18nd("kirigami-controlkit", "Delete")
        leftButtonText: i18nd("kirigami-controlkit", "Cancel")
        visible:false

        onLeftButtonClicked:{
            deleteDialog.close()
        }

        onRightButtonClicked:{
            deleteDialog.close()
            //console.log("delete button   count is " + listView.count + "   current index is " + listView.currentIndex)
            root.deleteCurrentPicture(listView.currentIndex, listView.currentItem.source);
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

    //设置壁纸控件
    Component{
        id:wallpaperComponent
        JWallPaperItem{
            id:wallpaperItem

            source: root.wallpaperUrl
            onSetWallPaperFinished:{
                console.log(" setwallpaper finnish:" + success)
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
                console.log("cropImageLoader.status === Loader.Ready ")
                cropImageLoader.item.parent = Overlay.overlay
            }
        }
    }

    //裁剪图片控件
    Component {
        id: cropPicCom
        JCropView {
            id: cropView
            imageUrl: root.croppaperUrl
            onCropImageFinished:{
                root.closeCropPictureView();
                root.cropImageFinished(path, root.cropMimeType);
            }
            onClosePage:{
                root.closeCropPictureView();
            }
        }
    }
}
