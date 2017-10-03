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
import QtQuick.Layouts 1.2
import "private"
import org.kde.kirigami 2.2


/**
 * An item that can be used as a title for the application.
 * Scrolling the main page will make it taller or shorter (trough the point of going away)
 * It's a behavior similar to the typical mobile web browser adressbar
 * the minimum, preferred and maximum heights of the item can be controlled with
 * * minimumHeight: default is 0, i.e. hidden
 * * preferredHeight: default is Units.gridUnit * 1.6
 * * preferredHeight: default is Units.gridUnit * 3
 *
 * To achieve a titlebar that stays completely fixed just set the 3 sizes as the same
 * @inherit QtQuick.Item
 */
Item {
    id: root
    z: 90
    property int minimumHeight: 0
    property int preferredHeight: Units.gridUnit * 2
    property int maximumHeight: Units.gridUnit * 3
    default property alias contentItem: mainItem.data
    readonly property int paintedHeight: headerItem.y + headerItem.height - 1
    LayoutMirroring.enabled: Qt.application.layoutDirection == Qt.RightToLeft 
    LayoutMirroring.childrenInherit: true

    //FIXME: remove
    property QtObject __appWindow: applicationWindow();

    anchors {
        left: parent.left
        right: parent.right
    }
    height: {
        if (!__appWindow.controlsVisible) {
            return 1;
        } else if (__appWindow.wideScreen || !Settings.isMobile) {
            return preferredHeight;
        } else {
            return 1;
        }
    }

    /**
     * background: Item
     * This property holds the background item.
     * Note: the background will be automatically sized as the whole control
     */
    property Item background

    onBackgroundChanged: {
        background.z = -1;
        background.parent = headerItem;
        background.anchors.fill = headerItem;
    }

    opacity: height > 0 && -translateTransform.y <= height ? 1 : 0
    Behavior on opacity {
        OpacityAnimator {
            duration: Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    transform: Translate {
        id: translateTransform
        y: {
            if (__appWindow === undefined) {
                return 0;
            }
            if (!__appWindow.controlsVisible) {
                return -headerItem.height - Units.smallSpacing;
            } else {
                return 0;
            }
        }
        Behavior on y {
            NumberAnimation {
                duration: Units.longDuration
                easing.type: translateTransform.y < 0 ? Easing.OutQuad : Easing.InQuad
            }
        }
    }

    Item {
        id: headerItem
        anchors {
            left: parent.left
            right: parent.right
        }

        height: __appWindow.reachableMode && __appWindow.reachableModeEnabled ? root.maximumHeight : root.preferredHeight

        function updatePageHeader() {
            if (!__appWindow || !__appWindow.pageStack || !__appWindow.pageStack.currentItem || !__appWindow.pageStack.currentItem.header || !__appWindow.pageStack.currentItem.flickable) {
                return;
            }

            if (__appWindow.wideScreen || !Settings.isMobile) {
                __appWindow.pageStack.currentItem.header.y = 0;
            } else {
                __appWindow.pageStack.currentItem.header.y = headerItem.height + headerItem.y -1;
            }
        }
        onYChanged: updatePageHeader()
        onHeightChanged: updatePageHeader()

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

                if (__appWindow.wideScreen || !Settings.isMobile) {
                    headerItem.y = 0;
                } else {
                    headerItem.y = Math.max(root.minimumHeight - root.preferredHeight, Math.min(0, headerItem.y + oldContentY - __appWindow.pageStack.currentItem.flickable.contentY));
                    
                    oldContentY = __appWindow.pageStack.currentItem.flickable.contentY;
                }
            }
            onMovementEnded: {
                if (headerItem.y > root.preferredHeight) {
                    //if don't change the position if more then preferredSize is shown
                } else if (headerItem.y < -(root.preferredHeight - root.minimumHeight)/2 ) {
                    headerItem.y = root.minimumHeight - root.preferredHeight;
                } else {
                    headerItem.y = 0;
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
                headerItem.y = 0;
                headerItem.updatePageHeader()
            }
        }

        Item {
            id: mainItem
            anchors {
                fill: parent
            }
        }
        Behavior on y {
            enabled: __appWindow.pageStack.currentItem && __appWindow.pageStack.currentItem.flickable && !__appWindow.pageStack.currentItem.flickable.moving
            NumberAnimation {
                duration: Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
}

