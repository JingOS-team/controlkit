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
import QtQuick.Templates 2.0 as T2
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.0

T2.Drawer {
    id: root

    parent: modal ? T2.ApplicationWindow.overlay : T2.ApplicationWindow.contentItem
    height: edge == Qt.LeftEdge || edge == Qt.RightEdge ? applicationWindow().height : Math.min(contentItem.implicitHeight, Math.round(applicationWindow().height*0.8))
    width:  edge == Qt.TopEdge || edge == Qt.BottomEdge ? applicationWindow().width : Math.min(contentItem.implicitWidth, Math.round(applicationWindow().width*0.8))
    edge: Qt.LeftEdge
    modal: true

    dragMargin: enabled && (edge == Qt.LeftEdge || edge == Qt.RightEdge) ? Qt.styleHints.startDragDistance : 0

    /**
     * drawerOpen: bool
     * true when the drawer is open and visible
     */
    property bool drawerOpen: false

    /**
     * enabled: bool
     * This property holds whether the item receives mouse and keyboard events. By default this is true.
     */
    property bool enabled: true

    /**
     * peeking: true
     * When true the drawer is in a state between open and closed. the drawer is visible but not completely open.
     * This is usually the case when the user is dragging the drawer from a screen 
     * edge, so the user is "peeking" what's in the drawer
     */
    property bool peeking: false

    /**
     * animating: Bool
     * True during an animation of a drawer either opening or closing
     */
    readonly property bool animating : enterAnimation.animating || exitAnimation.animating || positionResetAnim.running

    onPositionChanged: {
        if (peeking) {
            visible = true
        }
    }
    onVisibleChanged: {
        if (peeking) {
            visible = true
        } else {
            drawerOpen = visible;
        }
    }
    onPeekingChanged:  {
        if (peeking) {
            root.enter.enabled = false;
            root.exit.enabled = false;
        } else {
            positionResetAnim.to = position > 0.5 ? 1 : 0;
            positionResetAnim.running = true
            root.enter.enabled = true;
            root.exit.enabled = true;
        }
    }
    onDrawerOpenChanged: {
        //sync this property only when the component is properly loaded
        if (!__internal.completed) {
            return;
        }
        positionResetAnim.running = false;
        if (drawerOpen) {
            open();
        } else {
            close();
        }
    }

    Component.onCompleted: {
        //if defined as drawerOpen by default in QML, don't animate
        if (root.drawerOpen) {
            root.enter.enabled = false;
            root.visible = true;
            root.position = 1;
            root.enter.enabled = true;
        }
        __internal.completed = true;
    }


    //this is as hidden as it can get here
    property QtObject __internal: QtObject {
        //here in order to not be accessible from outside
        property bool completed: false
        property NumberAnimation positionResetAnim: NumberAnimation {
            id: positionResetAnim
            target: root
            to: 0
            property: "position"
            duration: (root.position)*Units.longDuration
        }
    }
    implicitWidth: Math.max(background ? background.implicitWidth : 0, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0, contentHeight + topPadding + bottomPadding)

    contentWidth: contentItem.implicitWidth || (contentChildren.length === 1 ? contentChildren[0].implicitWidth : 0)
    contentHeight: contentItem.implicitHeight || (contentChildren.length === 1 ? contentChildren[0].implicitHeight : 0)

    enter: Transition {
        SequentialAnimation {
            id: enterAnimation
            /*NOTE: why this? the running status of the enter transition is not relaible and
             * the SmoothedAnimation is always marked as non running,
             * so the only way to get to a reliable animating status is with this
             */
            property bool animating
            ScriptAction {
                script: enterAnimation.animating = true
            }
            SmoothedAnimation {
                velocity: 5
            }
            ScriptAction {
                script: enterAnimation.animating = false
            }
        }
    }
    exit: Transition {
        SequentialAnimation {
            id: exitAnimation
            property bool animating
            ScriptAction {
                script: exitAnimation.animating = true
            }
            SmoothedAnimation {
                velocity: 5 
            }
            ScriptAction {
                script: exitAnimation.animating = false
            }
        }
    }
}

