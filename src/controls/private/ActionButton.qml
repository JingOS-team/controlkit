/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.2

import "../templates/private"

Item {
    id: root
    Theme.colorSet: Theme.Button
    Theme.inherit: false
    anchors {
        left: parent.left
        right: parent.right
        bottom: parent.bottom
        bottomMargin: root.parent.parent.footer ? root.parent.parent.footer.height : 0
    }
    //smallSpacing for the shadow
    height: button.height + Units.smallSpacing
    clip: true

    //either Action or QAction should work here
    readonly property QtObject action: root.parent.parent ? root.parent.parent.mainAction : null
    readonly property QtObject leftAction: root.parent.parent ? root.parent.parent.leftAction : null
    readonly property QtObject rightAction: root.parent.parent ? root.parent.parent.rightAction : null

    transform: Translate {
        id: translateTransform
        y: mouseArea.internalVisibility ? 0 : button.height
        Behavior on y {
            NumberAnimation {
                duration: Units.longDuration
                easing.type: mouseArea.internalVisibility == true ? Easing.InQuad : Easing.OutQuad
            }
        }
    }

    Item {
        id: button
        x: root.width/2 - button.width/2

        anchors {
            bottom: parent.bottom
            bottomMargin: Units.smallSpacing
        }
        implicitWidth: implicitHeight + Units.iconSizes.smallMedium*2 + Units.gridUnit
        implicitHeight: Units.iconSizes.medium + Units.largeSpacing


        onXChanged: {
            if (mouseArea.pressed || edgeMouseArea.pressed || fakeContextMenuButton.pressed) {
                if (globalDrawer && globalDrawer.enabled && globalDrawer.modal) {
                    globalDrawer.peeking = true;
                    globalDrawer.visible = true;
                    globalDrawer.position = Math.min(1, Math.max(0, (x - root.width/2 + button.width/2)/globalDrawer.contentItem.width + mouseArea.drawerShowAdjust));
                }
                if (contextDrawer && contextDrawer.enabled && contextDrawer.modal) {
                    contextDrawer.peeking = true;
                    contextDrawer.visible = true;
                    contextDrawer.position = Math.min(1, Math.max(0, (root.width/2 - button.width/2 - x)/contextDrawer.contentItem.width + mouseArea.drawerShowAdjust));
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent

            visible: action != null || leftAction != null || rightAction != null
            property bool internalVisibility: (applicationWindow === undefined || (applicationWindow().controlsVisible && applicationWindow().height > root.height*2)) && (root.action === null || root.action.visible === undefined || root.action.visible)
            preventStealing: true

            drag {
                target: button
                //filterChildren: true
                axis: Drag.XAxis
                minimumX: contextDrawer && contextDrawer.enabled && contextDrawer.modal ? 0 : root.width/2 - button.width/2
                maximumX: globalDrawer && globalDrawer.enabled && globalDrawer.modal ? root.width : root.width/2 - button.width/2
            }

            property var downTimestamp;
            property int startX
            property int startMouseY
            property real drawerShowAdjust
            property bool buttonPressedUnderMouse: false
            property bool leftButtonPressedUnderMouse: false
            property bool rightButtonPressedUnderMouse: false

            onPressed: {
                //search if we have a page to set to current
                if (applicationWindow !== undefined && applicationWindow().pageStack.currentIndex !== undefined && root.parent.parent.parent.level !== undefined) {
                    //search the button parent's parent, that is the page parent
                    //this will make the context drawer open for the proper page
                    applicationWindow().pageStack.currentIndex = root.parent.parent.parent.level;
                }
                downTimestamp = (new Date()).getTime();
                startX = button.x + button.width/2;
                startMouseY = mouse.y;
                drawerShowAdjust = 0;
                buttonPressedUnderMouse = mouse.x > buttonGraphics.x && mouse.x < buttonGraphics.x + buttonGraphics.width;
                leftButtonPressedUnderMouse = !buttonPressedUnderMouse && leftAction && mouse.x < buttonGraphics.x;
                rightButtonPressedUnderMouse = !buttonPressedUnderMouse && rightAction && mouse.x > buttonGraphics.x + buttonGraphics.width;
            }
            onReleased: {
                if (globalDrawer) globalDrawer.peeking = false;
                if (contextDrawer) contextDrawer.peeking = false;
                //pixel/second
                var x = button.x + button.width/2;
                var speed = ((x - startX) / ((new Date()).getTime() - downTimestamp) * 1000);
                drawerShowAdjust = 0;

                //project where it would be a full second in the future
                if (globalDrawer && globalDrawer.modal && x + speed > Math.min(root.width/4*3, root.width/2 + globalDrawer.contentItem.width/2)) {
                    globalDrawer.open();
                    contextDrawer.close();
                } else if (contextDrawer && x + speed < Math.max(root.width/4, root.width/2 - contextDrawer.contentItem.width/2)) {
                    if (contextDrawer && contextDrawer.modal) {
                        contextDrawer.open();
                    }
                    if (globalDrawer && globalDrawer.modal) {
                        globalDrawer.close();
                    }
                } else {
                    if (globalDrawer && globalDrawer.modal) {
                        globalDrawer.close();
                    }
                    if (contextDrawer && contextDrawer.modal) {
                        contextDrawer.close();
                    }
                }
                //Don't rely on native onClicked, but fake it here:
                //Qt.startDragDistance is not adapted to devices dpi in case
                //of Android, so consider the button "clicked" when:
                //*the button has been dragged less than a gridunit
                //*the finger is still on the button
                if (Math.abs((button.x + button.width/2) - startX) < Units.gridUnit &&
                    mouse.y > 0) {
                    var action;
                    if (buttonPressedUnderMouse) {
                        action = root.action;
                    } else if (leftButtonPressedUnderMouse) {
                        action = root.leftAction;
                    } else if (rightButtonPressedUnderMouse) {
                        action = root.rightAction;
                    }

                    if (!action) {
                        return;
                    }

                    //if an action has been assigned, trigger it
                    if (action && action.trigger) {
                        action.trigger();
                    }
                }
            }

            onPositionChanged: {
                drawerShowAdjust = Math.min(0.3, Math.max(0, (startMouseY - mouse.y)/(Units.gridUnit*15)));
                button.xChanged();
            }
            onPressAndHold: {
                var action;
                if (buttonPressedUnderMouse) {
                    action = root.action;
                } else if (leftButtonPressedUnderMouse) {
                    action = root.leftAction;
                } else if (rightButtonPressedUnderMouse) {
                    action = root.rightAction;
                }

                if (!action) {
                    return;
                }

                //if an action has been assigned, show a message like a tooltip
                if (action && action.text) {
                    showPassiveNotification(action.text);
                }
            }
            Connections {
                target: globalDrawer
                onPositionChanged: {
                    if ( globalDrawer && globalDrawer.modal && !mouseArea.pressed && !edgeMouseArea.pressed && !fakeContextMenuButton.pressed) {
                        button.x = globalDrawer.contentItem.width * globalDrawer.position + root.width/2 - button.width/2;
                    }
                }
            }
            Connections {
                target: contextDrawer
                onPositionChanged: {
                    if (contextDrawer && contextDrawer.modal && !mouseArea.pressed && !edgeMouseArea.pressed && !fakeContextMenuButton.pressed) {
                        button.x = root.width/2 - button.width/2 - contextDrawer.contentItem.width * contextDrawer.position;
                    }
                }
            }

            Item {
                id: background
                anchors {
                    fill: parent
                }

                Rectangle {
                    id: buttonGraphics
                    radius: width/2
                    anchors.centerIn: parent
                    height: parent.height - Units.smallSpacing*2
                    width: height
                    visible: root.action
                    readonly property bool pressed: root.action && ((mouseArea.buttonPressedUnderMouse && mouseArea.pressed) || root.action.checked)
                    color: pressed ? Qt.lighter(Theme.hoverColor, 1.3) : Theme.hoverColor

                    Icon {
                        id: icon
                        source: root.action && root.action.iconName ? root.action.iconName : ""
                        selected: true
                        anchors {
                            fill: parent
                            margins: Units.smallSpacing * 3
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                    Behavior on x {
                        NumberAnimation {
                            duration: Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
                //left button
                Rectangle {
                    id: leftButtonGraphics
                    z: -1
                    anchors {
                        left: parent.left
                        //verticalCenter: parent.verticalCenter
                        bottom: parent.bottom
                        bottomMargin: Units.smallSpacing
                    }
                    radius: Units.devicePixelRatio*2
                    height: Units.iconSizes.smallMedium + Units.smallSpacing * 2
                    width: height + (root.action ? Units.gridUnit*2 : 0)
                    visible: root.leftAction

                    readonly property bool pressed: root.leftAction && ((mouseArea.leftButtonPressedUnderMouse && mouseArea.pressed) || root.leftAction.checked)
                    color: pressed ? Theme.hoverColor : Theme.backgroundColor
                    Behavior on color {
                        ColorAnimation {
                            duration: Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                    Icon {
                        source: root.leftAction && root.leftAction.iconName ? root.leftAction.iconName : ""
                        width: height
                        selected: leftButtonGraphics.pressed
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                            margins: Units.smallSpacing * 2
                        }
                    }
                }
                //right button
                Rectangle {
                    id: rightButtonGraphics
                    z: -1
                    anchors {
                        right: parent.right
                        //verticalCenter: parent.verticalCenter
                        bottom: parent.bottom
                        bottomMargin: Units.smallSpacing
                    }
                    radius: Units.devicePixelRatio*2
                    height: Units.iconSizes.smallMedium + Units.smallSpacing * 2
                    width: height + (root.action ? Units.gridUnit*2 : 0)
                    visible: root.rightAction
                    readonly property bool pressed: root.rightAction && ((mouseArea.rightButtonPressedUnderMouse && mouseArea.pressed) || root.rightAction.checked)
                    color: pressed ? Theme.hoverColor : Theme.backgroundColor
                    Behavior on color {
                        ColorAnimation {
                            duration: Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                    Icon {
                        source: root.rightAction && root.rightAction.iconName ? root.rightAction.iconName : ""
                        width: height
                        selected: rightButtonGraphics.pressed
                        anchors {
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                            margins: Units.smallSpacing * 2
                        }
                    }
                }
            }

            DropShadow {
                anchors.fill: background
                horizontalOffset: 0
                verticalOffset: Units.devicePixelRatio
                radius: Units.gridUnit /2
                samples: 16
                color: Qt.rgba(0, 0, 0, mouseArea.pressed ? 0.6 : 0.4)
                source: background
            }
        }
    }

    MouseArea {
        id: fakeContextMenuButton
        anchors {
            right: edgeMouseArea.right
            bottom: edgeMouseArea.bottom
        }
        drag {
            target: button
            axis: Drag.XAxis
            minimumX: contextDrawer && contextDrawer.enabled && contextDrawer.modal ? 0 : root.width/2 - button.width/2
            maximumX: globalDrawer && globalDrawer.enabled && globalDrawer.modal ? root.width : root.width/2 - button.width/2
        }
        visible: root.parent.parent.actions.contextualActions.length > 0 && (applicationWindow === undefined || applicationWindow().wideScreen)
            //using internal pagerow api
            && root.parent.parent.parent.level < applicationWindow().pageStack.depth-1

        width: Units.iconSizes.medium + Units.smallSpacing*2
        height: width

        Item {
            anchors {
                fill:parent
                margins: -Units.gridUnit
            }

            DropShadow {
                anchors.fill: handleGraphics
                horizontalOffset: 0
                verticalOffset: Units.devicePixelRatio
                radius: Units.gridUnit /2
                samples: 16
                color: Qt.rgba(0, 0, 0, fakeContextMenuButton.pressed ? 0.6 : 0.4)
                source: handleGraphics
            }
            Rectangle {
                id: handleGraphics
                anchors.centerIn: parent
                color: fakeContextMenuButton.pressed ? Theme.highlightColor : Theme.backgroundColor
                width: Units.iconSizes.smallMedium + Units.smallSpacing * 2
                height: width
                radius: Units.devicePixelRatio
                ContextIcon {
                    anchors.centerIn: parent
                    width: height
                    height: Units.iconSizes.smallMedium
                    color: fakeContextMenuButton.pressed ? Theme.highlightedTextColor : Theme.textColor
                }
                Behavior on color {
                    ColorAnimation {
                        duration: Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        onPressed: mouseArea.onPressed(mouse)
        onReleased: {
            if (globalDrawer) {
                globalDrawer.peeking = false;
            }
            if (contextDrawer) {
                contextDrawer.peeking = false;
            }
            var pos = root.mapFromItem(fakeContextMenuButton, mouse.x, mouse.y);
            if (contextDrawer) {
                if (pos.x < root.width/2 || (!contextDrawer.drawerOpen && mouse.x > 0 && mouse.x < width)) {
                    contextDrawer.open();
                } else if (contextDrawer.drawerOpen && mouse.x > 0 && mouse.x < width) {
                    contextDrawer.close();
                }
            }
            if (globalDrawer) {
                if (globalDrawer.position > 0.5) {
                    globalDrawer.open();
                } else {
                    globalDrawer.close();
                }
            }
        }
    }

    MouseArea {
        id: edgeMouseArea
        z:99
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        drag {
            target: button
            //filterChildren: true
            axis: Drag.XAxis
            minimumX: contextDrawer && contextDrawer.enabled && contextDrawer.modal ? 0 : root.width/2 - button.width/2
            maximumX: globalDrawer && globalDrawer.enabled && globalDrawer.modal ? root.width : root.width/2 - button.width/2
        }
        height: Units.smallSpacing * 3

        onPressed: mouseArea.onPressed(mouse)
        onPositionChanged: mouseArea.positionChanged(mouse)
        onReleased: mouseArea.released(mouse)
    }
}
