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
import org.kde.kirigami 1.0

Item {
    id: button

    //either Action or QAction should work here
    property QtObject action: pageStack.currentItem ? pageStack.currentItem.mainAction : null
    property QtObject leftAction: pageStack.currentItem ? pageStack.currentItem.leftAction : null
    property QtObject rightAction: pageStack.currentItem ? pageStack.currentItem.rightAction : null

    implicitWidth: implicitHeight + Units.iconSizes.smallMedium*4
    implicitHeight: Units.iconSizes.large + Units.largeSpacing
    //visible: action != null || leftAction != null || rightAction != null


    onXChanged: {
        if (mouseArea.pressed || edgeMouseArea.pressed) {
            if (globalDrawer && globalDrawer.enabled) {
                globalDrawer.position = Math.min(1, Math.max(0, (x - button.parent.width/2 + button.width/2)/globalDrawer.contentItem.width + mouseArea.drawerShowAdjust));
            }
            if (contextDrawer && contextDrawer.enabled) {
                contextDrawer.position = Math.min(1, Math.max(0, (button.parent.width/2 - button.width/2 - x)/contextDrawer.contentItem.width + mouseArea.drawerShowAdjust));
            }
        }
    }

    MouseArea {
        id: edgeMouseArea
        z:99
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: -Units.smallSpacing
        }
        drag {
            target: button
            //filterChildren: true
            axis: Drag.XAxis
            minimumX: contextDrawer && contextDrawer.enabled ? 0 : button.parent.width/2 - button.width/2
            maximumX: globalDrawer && globalDrawer.enabled ? button.parent.width : button.parent.width/2 - button.width/2
        }
        height: Units.smallSpacing * 3
        width: button.parent.width

        onPressed: mouseArea.onPressed(mouse)
        onPositionChanged: mouseArea.positionChanged(mouse)
        onReleased: mouseArea.released(mouse)
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent

        visible: action != null || leftAction != null || rightAction != null
        property bool internalVisibility: (applicationWindow === undefined || applicationWindow().controlsVisible) && (button.action === null || button.action.visible === undefined || button.action.visible)
        onInternalVisibilityChanged: {
            showAnimation.running = false;
            if (internalVisibility) {
                showAnimation.to = 0;
            } else {
                showAnimation.to = button.height;
            }
            showAnimation.running = true;
        }

        drag {
            target: button
            //filterChildren: true
            axis: Drag.XAxis
            minimumX: contextDrawer && contextDrawer.enabled ? 0 : button.parent.width/2 - button.width/2
            maximumX: globalDrawer && globalDrawer.enabled ? button.parent.width : button.parent.width/2 - button.width/2
        }

        transform: Translate {
            id: translateTransform
        }
        property var downTimestamp;
        property int startX
        property int startMouseY
        property real drawerShowAdjust
        property bool buttonPressedUnderMouse: false
        property bool leftButtonPressedUnderMouse: false
        property bool rightButtonPressedUnderMouse: false

        onPressed: {
            downTimestamp = (new Date()).getTime();
            startX = button.x + button.width/2;
            startMouseY = mouse.y;
            drawerShowAdjust = 0;
            buttonPressedUnderMouse = mouse.x > buttonGraphics.x && mouse.x < buttonGraphics.x + buttonGraphics.width;
            leftButtonPressedUnderMouse = !buttonPressedUnderMouse && leftAction && mouse.x < buttonGraphics.x;
            rightButtonPressedUnderMouse = !buttonPressedUnderMouse && rightAction && mouse.x > buttonGraphics.x + buttonGraphics.width;
        }
        onReleased: {
            //pixel/second
            var x = button.x + button.width/2;
            var speed = ((x - startX) / ((new Date()).getTime() - downTimestamp) * 1000);
            drawerShowAdjust = 0;

            //project where it would be a full second in the future
            if (globalDrawer && x + speed > Math.min(button.parent.width/4*3, button.parent.width/2 + globalDrawer.contentItem.width/2)) {
                globalDrawer.open();
                contextDrawer.close();
            } else if (contextDrawer && x + speed < Math.max(button.parent.width/4, button.parent.width/2 - contextDrawer.contentItem.width/2)) {
                if (contextDrawer) {
                    contextDrawer.open();
                }
                if (globalDrawer) {
                    globalDrawer.close();
                }
            } else {
                if (globalDrawer) {
                    globalDrawer.close();
                }
                if (contextDrawer) {
                    contextDrawer.close();
                }
            }
            //buttonPressedUnderMouse = leftButtonPressedUnderMouse = rightButtonPressedUnderMouse = false;
        }
        onClicked: {
            var action;
            if (buttonPressedUnderMouse) {
                action = button.action;
            } else if (leftButtonPressedUnderMouse) {
                action = button.leftAction;
            } else if (rightButtonPressedUnderMouse) {
                action = button.rightAction;
            }

            if (!action) {
                return;
            }

            //if an action has been assigned, trigger it
            if (action && action.trigger) {
                action.trigger();
            }
        }
        onPositionChanged: {
            drawerShowAdjust = Math.min(0.3, Math.max(0, (startMouseY - mouse.y)/(Units.gridUnit*15)));
            button.xChanged();
        }
        Connections {
            target: globalDrawer
            onPositionChanged: {
                if (!mouseArea.pressed && !edgeMouseArea.pressed) {
                    button.x = globalDrawer.contentItem.width * globalDrawer.position + button.parent.width/2 - button.width/2;
                }
            }
        }
        Connections {
            target: contextDrawer
            onPositionChanged: {
                if (!mouseArea.pressed && !edgeMouseArea.pressed) {
                    button.x = button.parent.width/2 - button.width/2 - contextDrawer.contentItem.width * contextDrawer.position;
                }
            }
        }
        Connections {
            target: button.parent
            onWidthChanged: button.x = button.parent.width/2 - button.width/2
        }

        NumberAnimation {
            id: showAnimation
            target: translateTransform
            properties: "y"
            duration: Units.longDuration
            easing.type: mouseArea.internalVisibility == true ? Easing.InQuad : Easing.OutQuad
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
                visible: button.action
                color: button.action && ((mouseArea.buttonPressedUnderMouse && mouseArea.pressed) || button.action.checked) ? Theme.highlightColor : Theme.backgroundColor
                Icon {
                    id: icon
                    source: button.action && button.action.iconName ? button.action.iconName : ""
                    anchors {
                        fill: parent
                        margins: Units.smallSpacing
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
                z: -1
                anchors {
                    right: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                radius: Units.smallSpacing
                height: buttonGraphics.height * 0.7
                width: height + Units.iconSizes.smallMedium
                visible: button.leftAction
                color: button.leftAction && ((button.leftAction && mouseArea.leftButtonPressedUnderMouse && mouseArea.pressed) || button.leftAction.checked) ? Theme.highlightColor : Theme.backgroundColor
                Icon {
                    source: button.leftAction && button.leftAction.iconName ? button.leftAction.iconName : ""
                    width: height
                    anchors {
                        left: parent.left
                        top: parent.top
                        bottom: parent.bottom
                        margins: Units.smallSpacing
                    }
                }
            }
            //right button
            Rectangle {
                z: -1
                anchors {
                    left: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                radius: Units.smallSpacing
                height: buttonGraphics.height * 0.7
                width: height + Units.iconSizes.smallMedium
                visible: button.rightAction
                color: button.rightAction && ((mouseArea.rightButtonPressedUnderMouse && mouseArea.pressed) || button.rightAction.checked) ? Theme.highlightColor : Theme.backgroundColor
                Icon {
                    source: button.rightAction && button.rightAction.iconName ? button.rightAction.iconName : ""
                    width: height
                    anchors {
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                        margins: Units.smallSpacing
                    }
                }
            }
        }

        DropShadow {
            anchors.fill: background
            horizontalOffset: 0
            verticalOffset: Units.smallSpacing/3
            radius: Units.gridUnit / 3.5
            samples: 16
            color: Qt.rgba(0, 0, 0, 0.5)
            source: background
        }
    }
}

