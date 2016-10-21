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
import org.kde.kirigami 1.0

//TODO: This will become a QQC2 Drawer
//providing just a dummy api for now
T2.Drawer {
    id: root

    parent: T2.ApplicationWindow.overlay
    height: edge == Qt.LeftEdge || edge == Qt.RightEdge ? applicationWindow().height : Math.min(contentItem.implicitHeight, Math.round(applicationWindow().height*0.8))
    width:  edge == Qt.TopEdge || edge == Qt.BottomEdge ? applicationWindow().width : Math.min(contentItem.implicitWidth, Math.round(applicationWindow().width*0.8))

    dragMargin: enabled && (edge == Qt.LeftEdge || edge == Qt.RightEdge) ? Qt.styleHints.startDragDistance : 0

    //default property alias page: mainPage.data
    property bool opened: false
    edge: Qt.LeftEdge
    modal: true
    property bool enabled: true
    property bool peeking: false
    onPositionChanged: {
        if (peeking) {
            visible = true
        }
    }
    onVisibleChanged: {
        if (peeking) {
            visible = true
        } else {
            opened = visible;
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
    onOpenedChanged: {
        if (opened) {
            open();
        } else {
            close();
        }
    }

    Component.onCompleted: {
        //if defined as opened by default in QML, don't animate
        if (root.opened) {
            root.enter.enabled = false;
            root.visible = true;
            root.position = 1;
            root.enter.enabled = true;
        }
    }
    //FIXME: any way to avoid?
    property NumberAnimation __internalAnim: NumberAnimation {
        id: positionResetAnim
        target: root
        to: 0
        property: "position"
        duration: (root.position)*Units.longDuration
    }

    implicitWidth: Math.max(background ? background.implicitWidth : 0, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0, contentHeight + topPadding + bottomPadding)

    contentWidth: contentItem.implicitWidth || (contentChildren.length === 1 ? contentChildren[0].implicitWidth : 0)
    contentHeight: contentItem.implicitHeight || (contentChildren.length === 1 ? contentChildren[0].implicitHeight : 0)

    enter: Transition {
        SmoothedAnimation { velocity: 5 }
    }
    exit: Transition {
        SmoothedAnimation { velocity: 5 }
    }
}

