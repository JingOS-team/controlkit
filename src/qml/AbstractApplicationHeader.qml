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
Rectangle {
    id: headerItem
    z: 2
    anchors {
        left: parent.left
        right: parent.right
    }
    color: Theme.highlightColor
    property int minimumHeight: 0
    property int preferredHeight: Units.gridUnit * 1.6
    property int maximumHeight: Units.gridUnit * 3
    default property alias contentItem: mainItem.data
    readonly property bool wideScreen: __appWindow.pageStack.width >= __appWindow.pageStack.defaultColumnWidth*2

    height: maximumHeight

    y: 0

    property QtObject __appWindow: applicationWindow();
    parent: __appWindow.pageStack;

    transform: Translate {
        id: translateTransform
        y: __appWindow.controlsVisible ? 0 : -headerItem.height - shadow.height
        Behavior on y {
            NumberAnimation {
                duration: Units.longDuration
                easing.type: translateTransform.y < 0 ? Easing.OutQuad : Easing.InQuad
            }
        }
    }

    onWideScreenChanged: {
        if (wideScreen) {
            y = -headerItem.maximumHeight + headerItem.preferredHeight;
        } else {
            y = 0;
        }
    }
    Connections {
        id: headerSlideConnection
        target: __appWindow.pageStack.currentItem ? __appWindow.pageStack.currentItem.flickable : null
        property int oldContentY
        onContentYChanged: {
            if (!__appWindow.pageStack.currentItem) {
                return;
            }
            if (__appWindow.pageStack.currentItem.flickable.atYBeginning ||
                __appWindow.pageStack.currentItem.flickable.atYEnd) {
                return;
            }

            if (headerItem.wideScreen) {
                headerItem.y = -headerItem.maximumHeight + headerItem.preferredHeight;
            } else {
                headerItem.y = Math.min(0, Math.max(-headerItem.height + headerItem.minimumHeight, headerItem.y + oldContentY - __appWindow.pageStack.currentItem.flickable.contentY));
                oldContentY = __appWindow.pageStack.currentItem.flickable.contentY;
            }
        }
        onMovementEnded: {
            if (headerItem.y > -headerItem.maximumHeight + headerItem.preferredHeight) {
                //if don't change the position if more then preferredSize is shown
            } else if (headerItem.y > -headerItem.maximumHeight + headerItem.preferredHeight - headerItem.preferredHeight/2 ) {
                headerItem.y = -headerItem.maximumHeight + headerItem.preferredHeight;
            } else {
                headerItem.y = -headerItem.maximumHeight;
            }
        }
    }
    Connections {
        target: __appWindow.pageStack
        onCurrentItemChanged: {
            if (!__appWindow.pageStack.currentItem) {
                return;
            }
            if (__appWindow.pageStack.currentItem.flickable) {
                headerSlideConnection.oldContentY = __appWindow.pageStack.currentItem.flickable.contentY;
            } else {
                headerSlideConnection.oldContentY = 0;
            }
            if (__appWindow.pageStack.currentItem.flickable) {
                headerItem.y = 0;
            } else {
                headerItem.y = -headerItem.maximumHeight + headerItem.preferredHeight;
            }
        }
    }

    Behavior on y {
        enabled: __appWindow.pageStack.currentItem && __appWindow.pageStack.currentItem.flickable && !__appWindow.pageStack.currentItem.flickable.moving
        NumberAnimation {
            duration: Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    Item {
        id: mainItem
        property Translate overshootTransform
        Component.onCompleted: {
            if (applicationWindow() && applicationWindow().pageStack.transform[0]) {
                overshootTransform = applicationWindow().pageStack.transform[0]
            }
        }
        anchors {
            fill: parent
            topMargin: overshootTransform && overshootTransform.y > 0 ? 0 : Math.min(headerItem.height - headerItem.preferredHeight, -headerItem.y)
        }
    }

    EdgeShadow {
        id: shadow
        edge: Qt.TopEdge
        opacity: headerItem.y > -headerItem.height ? 1 : 0
        anchors {
            right: parent.right
            left: parent.left
            top: parent.bottom
        }
        Behavior on opacity {
            OpacityAnimator {
                duration: Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
}
