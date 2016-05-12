/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.2
import QtQuick.Controls.Private 1.0
import "private"
import org.kde.kirigami 1.0


/**
 * An item that can be used as a title for the application.
 * Scrolling the main page will make it taller or shorter (trough the point of going away)
 * It's a behavior similar to the typical mobile web browser adressbar
 * the minimum, preferred and maximum heights of the item can be controlled with
 * * minimumHeight: default is 0, i.e. hidden
 * * preferredHeight: default is Units.gridUnit * 1.6
 * * maximumHeight: default is Units.gridUnit * 3
 *
 * To achieve a titlebar that stays completely fixed just set the 3 sizes as the same
 */
AbstractApplicationHeader {
    id: header

    /**
     * separatorStyle: string
     * The way the separator between pages should be drawn in the header.
     * Allowed values are:
     * * Breadcrumb: the pages are hyerarchical and the separator will look like a >
     * * TabBar: the pages are intended to behave like tabbar pages
     *    and the separator will look limke a dot.
     *
     * When the heaer is in wide screen mode, no separator will be drawn.
     */
    property string separatorStyle: "Breadcrumb"

    Rectangle {
        anchors {
            right: titleList.left
            verticalCenter: parent.verticalCenter
        }
        visible: titleList.x > 0 && !titleList.atXBeginning
        height: parent.height * 0.7
        color: Theme.highlightedTextColor
        width: Math.ceil(Units.smallSpacing / 6)
        opacity: 0.4
    }

    ListView {
        id: titleList
        //uses this to have less strings comparisons
        property bool isTabBar: header.separatorStyle == "TabBar"
        Component.onCompleted: {
            //only iOS and desktop systems put the back button on top left corner
            if (!Settings.isMobile || Qt.platform.os == "ios") {
                var component = Qt.createComponent(Qt.resolvedUrl("private/BackButton.qml"));
                titleList.backButton = component.createObject(titleList.parent);
            }
        }
        property Item backButton
        clip: true
        anchors {
            fill: parent
            leftMargin: Math.max ((backButton ? backButton.width : 0), __appWindow.pageStack.x)
        }
        cacheBuffer: width * count
        displayMarginBeginning: __appWindow.pageStack.width * count
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        model: __appWindow.pageStack.depth
        spacing: 0
        currentIndex: __appWindow.pageStack && __appWindow.pageStack.currentIndex !== undefined ? __appWindow.pageStack.currentIndex : 0

        function gotoIndex(idx) {
            //don't actually scroll in widescreen mode
            if (header.wideScreen) {
                return;
            }
            listScrollAnim.running = false
            var pos = titleList.contentX;
            var destPos;
            titleList.positionViewAtIndex(idx, ListView.Center);
            destPos = titleList.contentX;
            listScrollAnim.from = pos;
            listScrollAnim.to = destPos;
            listScrollAnim.running = true;
        }

        NumberAnimation {
            id: listScrollAnim
            target: titleList
            property: "contentX"
            duration: Units.longDuration
            easing.type: Easing.InOutQuad
        }

        onCurrentIndexChanged: gotoIndex(currentIndex);
        onModelChanged: gotoIndex(currentIndex);
        onContentWidthChanged: gotoIndex(currentIndex);

        onContentXChanged: {
            if (header.wideScreen && !__appWindow.pageStack.contentItem.moving) {
                //FIXME: needs the rewrite to be properly fixed, disable sync in this direction for now
               // __appWindow.pageStack.contentItem.contentX = titleList.contentX
            }
        }
        onHeightChanged: {
            titleList.returnToBounds()
        }
        onMovementEnded: {
            if (header.wideScreen) {
                __appWindow.pageStack.contentItem.movementEnded();
            }
        }

        NumberAnimation {
            id: scrollTopAnimation
            target: __appWindow.pageStack.currentItem && __appWindow.pageStack.currentItem.flickable ? __appWindow.pageStack.currentItem.flickable : null
            property: "contentY"
            to: 0
            duration: Units.longDuration
            easing.type: Easing.InOutQuad
        }

        delegate: MouseArea {
            id: delegate
            readonly property Page page: __appWindow.pageStack.get(modelData)
            //NOTE: why not use ListViewCurrentIndex? because listview itself resets
            //currentIndex in some situations (since here we are using an int as a model,
            //even more often) so the property binding gets broken
            readonly property bool current: __appWindow.pageStack.currentIndex == index

            width: {
                //more columns shown?
                if (header.wideScreen) {
                    if (modelData == 0 && titleList.backButton) {
                        return page.width - Math.max(0, titleList.backButton.width - __appWindow.pageStack.x);
                    } else {
                        return page.width;
                    }
                } else {
                    return Math.min(titleList.width, delegateRoot.implicitWidth + Units.smallSpacing);
                }
            }
            height: titleList.height
            onClicked: {
                if (__appWindow.pageStack.currentIndex == modelData) {
                    //scroll up if current otherwise make current
                    if (!__appWindow.pageStack.currentItem.flickable) {
                        return;
                    }
                    if (__appWindow.pageStack.currentItem.flickable.contentY > -__appWindow.header.height) {
                        scrollTopAnimation.to = -__appWindow.pageStack.currentItem.flickable.topMargin;
                        scrollTopAnimation.running = true;
                    }

                } else {
                    __appWindow.pageStack.currentIndex = modelData;
                }
            }
            Row {
                id: delegateRoot
                x: Units.smallSpacing + header.wideScreen ? (Math.min(delegate.width - width, Math.max(0, titleList.contentX - delegate.x))) : 0

                spacing: Units.smallSpacing
                Item {
                    height: title.height
                    width: titleList.isTabBar ? Math.min(Units.gridUnit/2, title.height / 2) : parent.height/2
                    opacity: modelData > 0 ? 0.4 : 0
                    visible: !header.wideScreen && opacity > 0
                    layer.enabled: true
                    Rectangle {
                        color: Theme.viewBackgroundColor
                        anchors.verticalCenter: parent.verticalCenter
                        width: titleList.isTabBar ? Math.min(Units.gridUnit/2, title.height / 2) : parent.height/2
                        height: titleList.isTabBar ? width : width/10
                        radius: titleList.isTabBar ? width : 0
                        rotation: titleList.isTabBar ? 0 : 45
                        transformOrigin: Item.BottomRight
                    }
                    Rectangle {
                        visible: !titleList.isTabBar
                        color: Theme.viewBackgroundColor
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.height/2
                        height: width/10
                        rotation: -45
                        transformOrigin: Item.TopRight
                    }
                }
                Heading {
                    id: title
                    width:Math.min(titleList.width, implicitWidth)
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: delegate.current ? 1 : 0.4
                    //Scaling animate NativeRendering is too slow
                    renderType: Text.QtRendering
                    color: Theme.highlightedTextColor
                    elide: Text.ElideRight
                    text: page.title
                    font.pixelSize: titleList.height / 1.6
                }
            }
        }
        Connections {
            target: header.wideScreen ? __appWindow.pageStack.contentItem : null
            onContentXChanged: {
                if (!titleList.contentItem.moving) {
                    titleList.contentX = __appWindow.pageStack.contentItem.contentX - __appWindow.pageStack.contentItem.originX + titleList.originX;
                }
            }
        }
    }
}
