/*
 *   Copyright 2018 Marco Martin <mart@kde.org>
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

import QtQuick 2.6
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami
import "../../templates/private" as TemplatesPrivate

 
Kirigami.AbstractApplicationHeader {
    id: header
    readonly property int leftReservedSpace: buttonsLayout.visible && buttonsLayout.visibleChildren.length > 1 ? buttonsLayout.width : 0
    readonly property int rightReservedSpace: rightHandleAnchor.visible ? backButton.background.implicitHeight : 0

    readonly property alias leftHandleAnchor: leftHandleAnchor
    readonly property alias rightHandleAnchor: rightHandleAnchor

    height: visible ? implicitHeight : 0
    minimumHeight: globalToolBar.minimumHeight
    preferredHeight: globalToolBar.preferredHeight
    maximumHeight: globalToolBar.maximumHeight
    separatorVisible: globalToolBar.separatorVisible

    RowLayout {
        anchors.fill: parent
        spacing: 0
        RowLayout {
            id: buttonsLayout
            Layout.fillHeight: true

            visible: globalToolBar.showNavigationButtons && globalToolBar.actualStyle != Kirigami.ApplicationHeaderStyle.None

            Item {
                id: leftHandleAnchor
                visible: typeof applicationWindow() !== "undefined" && applicationWindow().globalDrawer && applicationWindow().globalDrawer.handleVisible &&
                (applicationWindow().globalDrawer.handle.handleAnchor == (Qt.application.layoutDirection == Qt.LeftToRight ? leftHandleAnchor : rightHandleAnchor))
                Layout.fillHeight: true
                Layout.preferredWidth: height
            }
            TemplatesPrivate.BackButton {
                id: backButton
                Layout.leftMargin: leftHandleAnchor.visible ? 0 : Kirigami.Units.smallSpacing
                Layout.fillHeight: true
                Layout.preferredWidth: height
            }
            TemplatesPrivate.ForwardButton {
                Layout.fillHeight: true
                Layout.preferredWidth: height
            }
            Kirigami.Separator {
                Layout.preferredHeight: parent.parent.height * 0.6
                //FIXME: hacky
                opacity: buttonsLayout.visibleChildren.length > 1
            }
        }
        Loader {
            id: breadcrumbLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: -1
            Layout.preferredHeight: -1
            property Kirigami.PageRow pageRow: root

            opacity: pageRow.layers.depth < 2
            active: globalToolBar.actualStyle == Kirigami.ApplicationHeaderStyle.TabBar || globalToolBar.actualStyle == Kirigami.ApplicationHeaderStyle.Breadcrumb

            //TODO: different implementation?
            source: globalToolBar.actualStyle == Kirigami.ApplicationHeaderStyle.TabBar ? Qt.resolvedUrl("TabBarControl.qml") : Qt.resolvedUrl("BreadcrumbControl.qml")

            Behavior on opacity {
                OpacityAnimator {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
        Item {
            id: rightHandleAnchor
            visible: typeof applicationWindow() !== "undefined" && applicationWindow().contextDrawer && applicationWindow().contextDrawer.handleVisible && applicationWindow().contextDrawer.handle.handleAnchor == Qt.application.layoutDirection == (Qt.LeftToRight ? rightHandleAnchor : leftHandleAnchor)
            Layout.fillHeight: true
            Layout.preferredWidth: height
        }
    }
    background.opacity: pageRow.layers.depth < 2 && breadcrumbLoader.active
}

