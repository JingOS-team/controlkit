/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 * SPDX-FileCopyrightText: 2021 Yu Jiashu <yujiashu@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls 2.5 as T
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12
import QtQml 2.12
import org.kde.kirigami 2.15 as Kirigami
import jingos.multimedia 1.0
import jingos.display 1.0

Rectangle {
    id:root
    property string playPath: ""
    property var playPathList: []
    property int listLength: playPathList.length
    property int currentIndex: -1
    property bool isPlaying: player.playing
    property string playedTime: player.transformTime(progressBar.value)

    signal backBtnClick()
    signal modelBtnClick(int flag)

    anchors.fill: parent
    color: JTheme.colorScheme === "jingosLight" ? "white" : Kirigami.JTheme.background

    function setCurrentIndex(index) {
        if(index < root.playPathList.length && player.playing == false){
            root.currentIndex = index
            root.playPath = root.playPathList[index]
            updateSingContents()
        }
    }

    function setPause(pause) {
        if(root.currentIndex == -1) {
            if(root.playPathList.length > 0) {
                root.currentIndex = 0
                root.playPath = root.playPathList[root.currentIndex]
                updateSingContents()
                player.playing = pause
            } else {
                player.canPlayNext = false
                player.canPlayPre = false
            }
        } else {
            if(root.playPath)
                player.playing = pause
        }
    }

    function resetList() {
        if( player.playing )
            player.playing = false
        root.playPath = ""
        root.playPathList.splice(0,root.playPathList.length)
        root.currentIndex = -1
        listLengthchangeOp()
        mpris2.quitControls()
    }

    function popupOnePlayPath() {
        if(root.playPathList.length == root.currentIndex + 1) {
            root.currentIndex -= 1
            if(root.currentIndex < 0) {
                playPath = ""
                player.playing = false
            } else {
                playPath = root.playPathList[root.currentIndex]
            }
            updateSingContents()
        }
        root.playPathList.pop()
        listLengthchangeOp()

    }

    function pushOnePlayPath(path) {
        root.playPathList.push(path)
        listLengthchangeOp()
    }

    function removeOnePlayPath(index) {
        if((index ===  root.currentIndex && (index + 1) === root.playPathList.length) ||  index < root.currentIndex) {
            root.currentIndex -= 1
        }
        if(root.currentIndex < 0) {
            root.playPath = ""
            player.playing = false
        } else {
            root.playPath =  root.playPathList[root.currentIndex]
        }
        updateSingContents()
        root.playPathList.splice(index, 1)
        listLengthchangeOp()
    }

    function addOnePlayPath(index, path) {  //add after index
        root.playPathList.splice(index,0,path)
        if(index < root.currentIndex) {
            root.currentIndex += 1
        }
        listLengthchangeOp()
    }

    Component.onCompleted: {
        if(root.playPathList.length > 0) {
            root.currentIndex = 0
            root.playPath = root.playPathList[root.currentIndex]
            updateSingContents()
        }
    }

    onCurrentIndexChanged: {// it's use to set pre/next button status when list at edage       
        if(root.playPathList.length < 2) {
             player.canPlayNext = false
             player.canPlayPre = false
        } else {
            if(root.currentIndex == 0) {
                player.canPlayNext = true
                player.canPlayPre = false

            } else if(root.currentIndex + 1 == root.playPathList.length) {
                player.canPlayNext = false
                player.canPlayPre = true
            } else {
                player.canPlayNext = true
                player.canPlayPre = true
            }
        }
        player.setPlayIndex(root.currentIndex)
    }
    onListLengthChanged: {
        listLengthchangeOp()
    }

    function listLengthchangeOp() {
        if(root.playPathList.length == 0) {
            player.listNull = true
        } else {
            player.listNull = false
        }
    }

    function updateSingContents() {//when playPath change cover of sing need update
        singCover.source = player.getGenre()
        timeInfoTextMetrics.text = playedTime + "/" + player.transformTime(player.getPreDuration())
    }

    onPlayPathChanged: {
        if(playPath.length>0) {
            var temp = playPath.substr(playPath.lastIndexOf('/') + 1)
            if( temp.length > 40) {
                titleItem.musicName = temp.substr(0,40) + "..."
            } else {
                titleItem.musicName = temp
            }
        }
        listLengthchangeOp()
    }
    onPlayedTimeChanged: {
        timeInfoTextMetrics.text = playedTime + "/" + player.transformTime(player.getPreDuration())
    }

    property Action playPauseAction: T.Action {
        id: playPauseAction
        text: qsTr("Play/Pause")
        icon.name: "media-playback-pause"
        shortcut: "Space"
        onTriggered: {
            if(playBtn.enabled) {
                player.playing =! player.playing
            }
        }
    }

    MouseArea{
        anchors.fill: parent
    }

    Item {
        id:titleItem
        property bool isVideoScreen
        property bool isGifImage: false
        property real rate: 1
        property string musicName:""
        width: parent.width
        height: JDisplay.dp(70)
        anchors.top: parent.top
//        Kirigami.JBlurBackground {
//            anchors.fill:parent
//            sourceItem: root
//            showBgBoder:false
//            blurRadius: 130
//            radius: 0
//        }
        Rectangle {
            anchors.fill: parent
            color: JTheme.colorScheme === "jingosLight" ? "white" : Kirigami.JTheme.background
        }

        Item {
            id: titleBarLeftTitle
            anchors.fill: parent

            Kirigami.JIconButton {
                id: back
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: JDisplay.dp(10)
                width: JDisplay.dp(22+8)
                height: width
                source: Qt.resolvedUrl("./image/imagePreviewIcon/back.svg")
                onClicked: {
                    backBtnClick()
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: back.right
                anchors.leftMargin: JDisplay.dp(8)
                font.pointSize: JDisplay.sp(11)
                font.weight: Font.Bold
                width: titleBarLeftTitle.width / 2
                elide: Text.ElideRight
                color: Kirigami.JTheme.majorForeground
                text:titleItem.musicName
            }

            Row {
                id: imageTitleRight
                height: JDisplay.dp(22  + 10)
                anchors.right: parent.right
                anchors.rightMargin: JDisplay.dp(14)
                anchors.verticalCenter: parent.verticalCenter
                spacing: JDisplay.dp(36)

                Repeater {
                    id: btnRepeater

                    model: imageMusicModel
                    delegate: Kirigami.JIconButton {
                        width: imageTitleRight.height
                        height:width
                        source: name
                        onClicked: {
                            var flag = model.flag
                            modelBtnClick(flag)
                        }
                    }
                }
            }
        }

        ListModel {
            id: imageMusicModel
//            property string seeallname : Qt.resolvedUrl("./image/imagePreviewIcon/delete.svg")
//            Component.onCompleted: {
//                imageMusicModel.append({"name": imageMusicModel.seeallname, "flag" : 1})
//            }
        }
    }

    Rectangle {
        id:contents
        width: parent.width
        anchors.top: titleItem.bottom
        anchors.bottom: playBarFooter.top
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"
        Item {
            anchors.top: contents.top
            anchors.topMargin: JDisplay.dp(189)
            anchors.horizontalCenter: parent.horizontalCenter
            width: singCover.width + singCoverRight.width
            height: JDisplay.dp(81)
            Image {
                id: singCover
                height: JDisplay.dp(81)
                width: JDisplay.dp(81)
                anchors.left: parent.left
                anchors.top: parent.top
                source: player.getGenre()
                visible: false
            }
            Rectangle{
               id: imageMask
               width: singCover.width
               height: singCover.height
               radius:  JDisplay.dp(10)
               visible: false
            }

            OpacityMask {
                anchors.fill: singCover
                source: singCover
                maskSource: imageMask
            }
            Image {
                id: singCoverRight
                height: JDisplay.dp(77)
                width: JDisplay.dp(21)
                anchors.left: singCover.right
                anchors.verticalCenter: parent.verticalCenter
                source: Qt.resolvedUrl("./image/videoImage/singCoverRight.png")
            }
        }
    }

    Rectangle {
        id: playBarFooter
        height: JDisplay.dp(81)
        width: parent.width
        color: JTheme.colorScheme === "jingosLight" ? "#B3FFFFFF" : "#CC2B2B2C"
        anchors.bottom: parent.bottom

        RowLayout {
            id: footerRow
            anchors.fill: parent

            Kirigami.JIconButton {
                id: previousBtn
                Layout.preferredWidth: JDisplay.dp(22 + 8)
                Layout.preferredHeight: JDisplay.dp(22 + 8)
                color:  JTheme.iconMinorForeground //JTheme.colorScheme === "jingosLight" ? "#C7C7CC" : "white"
                source: Qt.resolvedUrl("./image/videoImage/audio_prew.svg")
                Layout.leftMargin: JDisplay.dp(35)
                enabled: player.canPlayPre
                onClicked: {
                    preBtnClickOP()
                }
                function preBtnClickOP() {
                    var tempflag = false
                    if(isPlaying == true) {
                        tempflag = true
                    }
                    if(root.currentIndex > 0) {
                        root.currentIndex -= 1
                        root.playPath = root.playPathList[root.currentIndex]
                        updateSingContents()
                        player.playing = tempflag
                    }
                }
            }

            Kirigami.JIconButton {
                id:playBtn
                Layout.preferredWidth: JDisplay.dp(30 + 8)
                Layout.preferredHeight: JDisplay.dp(30 + 8)
                color: JTheme.iconMinorForeground//JTheme.colorScheme === "jingosLight" ? "#C7C7CC" : "white"
                enabled: root.playPath.length
                source: isPlaying ? Qt.resolvedUrl("./image/videoImage/audio_pause.svg") :
                                    Qt.resolvedUrl("./image/videoImage/audio_play.svg")
                Layout.leftMargin: JDisplay.dp(33)
                onClicked: {
                    player.playing = !player.playing
                }
            }
            Kirigami.JIconButton {
                id: nextBtn
                Layout.preferredWidth: JDisplay.dp(22 + 8)
                Layout.preferredHeight: JDisplay.dp(22 + 8)
                color: JTheme.iconMinorForeground//JTheme.colorScheme === "jingosLight" ? "#C7C7CC" : "white"
                source: Qt.resolvedUrl("./image/videoImage/audio_next.svg")
                Layout.leftMargin: JDisplay.dp(33)
                enabled: player.canPlayNext
                onClicked: {
                    nextBtnClickOP()
                }
                function nextBtnClickOP() {
                    var tempflag = false
                    if(isPlaying == true) {
                        tempflag = true
                    }
                    if(root.currentIndex + 1 < root.playPathList.length) {
                        root.currentIndex += 1
                        root.playPath = root.playPathList[root.currentIndex]
                        updateSingContents()
                        player.playing = tempflag
                    }
                }
            }


            Slider {
                id: progressBar

                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: JDisplay.dp(35)
                Layout.fillWidth: true
                property bool seekStarted: false
                property bool keyPress: false

                from: 0
                to: player.duration

                handle: Rectangle {
                    id: handleRect
                    width: JDisplay.dp(23)
                    height: JDisplay.dp(20)
                    anchors.verticalCenter:parent.verticalCenter

                    x: progressBar.leftPadding + progressBar.visualPosition * (progressBar.availableWidth - width)
                    y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
                    color: "#FFFFFFFF"
                    radius: JDisplay.dp(4)
                }

                DropShadow {
                    anchors.fill: handleRect
                    horizontalOffset: 0
                    radius: 12.0
                    samples: 16
                    cached: true
                    spread: 0.3
                    color: Qt.rgba(0, 0, 0, 0.1)
                    source: handleRect
                    visible: true
                }

                background: Rectangle {
                    id: rect1
                    x: progressBar.leftPadding
                    y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
                    width: progressBar.availableWidth
                    height: JDisplay.dp(5)
                    color: "#C7C7CC"
                    radius: JDisplay.dp(2)

                    Rectangle {
                        id: rect2
                        width: progressBar.visualPosition * parent.width
                        height: parent.height
                        color: "#43BDF4"
                        radius: JDisplay.dp(2)
                    }
                }
                onPressedChanged: {
                    if(!keyPress) {
                        if (pressed) {
                            progressBar.seekStarted = true
                        } else {
                            player.pos = progressBar.value
                            progressBar.seekStarted = false
                        }
                    }
                }

                Keys.onPressed: {
                    if(event.key === Qt.Key_Right || event.key === Qt.Key_Left) {
                        if(event.key === Qt.Key_Right) {
                            value += 10
                        }  else {
                            value -= 10
                        }
                        progressBar.keyPress = true
                        progressBar.seekStarted = true
                        keyEventTimer.restart()
                    }
                }

                Timer {
                    id: keyEventTimer
                    interval: 200
                    running: false
                    repeat: false
                    onTriggered: {
                        progressBar.keyPress = false
                        progressBar.seekStarted = false
                        player.pos = progressBar.value
                    }
                }

                Connections {
                    target: player
                    function onPosChanged() {
                        if (!progressBar.seekStarted) {
                            progressBar.value = player.pos
                        }
                    }
                    function onFinishedChanged() {
                        if(!player.finished) return
                        if(root.currentIndex + 1 < root.playPathList.length) {
                            root.currentIndex += 1
                            root.playPath = root.playPathList[root.currentIndex]
                            updateSingContents()
                            player.playing = true
                        } else {
                            player.playing = false
                        }
                    }
                }
            }

            Label {
                id: timeInfo
                text: timeInfoTextMetrics.text
                font.pointSize: timeInfoTextMetrics.font.pointSize
                horizontalAlignment: Qt.AlignRight
                Layout.preferredWidth: timeInfoTextMetrics.width
                Layout.leftMargin: JDisplay.dp(2)
                Layout.rightMargin: 0
                color: JTheme.colorScheme === "jingosLight" ? "#FF8E8E93" : "white"
                TextMetrics {
                    id: timeInfoTextMetrics
                    text: playedTime + "/" + player.transformTime(player.getPreDuration())
                    font.pixelSize: JDisplay.sp(11)
                }
                MouseArea {
                    id: timeInfoMouseArea
                    anchors.fill: parent
                    hoverEnabled: false
                }
            }

            Rectangle {
                id: marginArea
                width: JDisplay.dp(35)
            }
        }
        Player{
            id: player
            volume: 100
            url: root.playPath
            title: titleItem.musicName
            onCanPlayNextChanged: {

            }

            onNext: {
                nextBtn.nextBtnClickOP()
            }

            onPrevious: {
                previousBtn.preBtnClickOP()
            }
        }

        Mpris2{
            id: mpris2
            audioPlayer: player
            playerName: 'jingmedia'
        }
    }

    DropShadow {
        anchors.fill: playBarFooter
        horizontalOffset: 0
        verticalOffset: JDisplay.dp(-4)
//        radius: 12.0
//        samples: 16
        radius: 12
        samples: 24
        cached: true
        spread: 0.0
        color: Qt.rgba(0, 0, 0, 0.1)
        source: playBarFooter
        visible: true
    }
}
