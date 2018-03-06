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
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import "private"
import org.kde.kirigami 2.2


/**
 * This Application header represents a toolbar that
 * will display the actions of the current page.
 * Both Contextual actions and the main, left and right actions
 */
ApplicationHeader {
    id: header

    preferredHeight: 42
    maximumHeight: preferredHeight
    headerStyle: ApplicationHeaderStyle.Titles

    //FIXME: needs a property difinition to have its own type in qml
    property string _internal: ""

    pageDelegate: Item {
        id: delegateItem
        readonly property bool current: __appWindow.pageStack.currentIndex == index

        RowLayout {
            id: actionsLayout
            anchors.verticalCenter: parent.verticalCenter

            readonly property bool toobig: Units.iconSizes.medium * 8 > parent.width/3
            Separator {
                anchors.verticalCenter: parent.verticalCenter
                Layout.preferredHeight: parent.height * 0.6
                visible: index > 0
            }
            PrivateActionToolButton {
                anchors.verticalCenter: parent.verticalCenter
                kirigamiAction: page && page.actions ? page.actions.left : null
                showText: !parent.toobig
            }
            PrivateActionToolButton {
                anchors.verticalCenter: parent.verticalCenter
                kirigamiAction: page && page.actions ? page.actions.main : null
                showText: !parent.toobig
            }
            PrivateActionToolButton {
                anchors.verticalCenter: parent.verticalCenter
                kirigamiAction: page && page.actions ? page.actions.right : null
                showText: !parent.toobig
            }
        }

        Heading {
            anchors {
                left: actionsLayout.right
                verticalCenter: parent.verticalCenter
            }
            
            width: parent.width - Math.max(ctxActions.width, actionsLayout.width)
            leftPadding: units.gridUnit
            opacity: delegateItem.current ? 1 : 0.4
            maximumLineCount: 1
            color: Theme.textColor
            elide: Text.ElideRight
            text: page ? page.title : ""
            font.pointSize: Math.max(1, (parent.height / 1.6) / Units.devicePixelRatio)
        }


        PrivateActionToolButton {
            id: ctxActions
            showMenuArrow: false
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: Units.smallSpacing
            }
            Action {
                id: overflowAction
                icon.name: "overflow-menu"
                visible: children.length > 0
                children: page && page.actions.contextualActions ? page.actions.contextualActions : null
            }

            kirigamiAction: page && page.actions.contextualActions.length === 1 ? page.actions.contextualActions[0] : overflowAction
        }
    }
}
