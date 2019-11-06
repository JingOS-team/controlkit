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

import QtQuick 2.5
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.5
import "../" as Private


AbstractPageHeader {
    id: root

    implicitWidth: layout.implcitWidth + Units.smallSpacing * 2
    Layout.preferredHeight: Math.max(titleLoader.implicitHeight, toolBar.implicitHeight) + Units.smallSpacing * 2

    MouseArea {
        anchors.fill: parent
        onClicked: page.forceActiveFocus()
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: Units.smallSpacing
        anchors.rightMargin: Units.smallSpacing
        spacing: Units.smallSpacing

        Loader {
            id: titleLoader

            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Layout.fillWidth: item ? item.Layout.fillWidth : undefined
            Layout.minimumWidth: item ? item.Layout.minimumWidth : undefined
            Layout.preferredWidth: item ? item.Layout.preferredWidth : undefined
            Layout.maximumWidth: item ? item.Layout.maximumWidth : undefined

            sourceComponent: page ? page.titleDelegate : null
        }

        ActionToolBar {
            id: toolBar

            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true

            visible: actions.length > 0
            alignment: pageRow.globalToolBar.toolbarActionAlignment
            display: buttonTextMetrics.toobig ? Controls.Button.IconOnly : Controls.Button.TextBesideIcon

            actions: {
                var result = []

                if (page) {
                    if (page.actions.main) {
                        result.push(page.actions.main)
                    }
                    if (page.actions.left) {
                        result.push(page.actions.left)
                    }
                    if (page.actions.right) {
                        result.push(page.actions.right)
                    }
                    if (page.actions.contextualActions.length > 0 && !buttonTextMetrics.toobig) {
                        result = result.concat(Array.prototype.map.call(page.actions.contextualActions, function(item) { return item }))
                    }
                }

                return result
            }

            hiddenActions: page && buttonTextMetrics.toobig ? page.actions.contextualActions : []
        }
    }


    TextMetrics {
        id: buttonTextMetrics
        text: (page.actions.left ? page.actions.left.text : "") + (page.actions.main ? page.actions.main.text : "") + (page.actions.right ? page.actions.right.text : "")
        readonly property int collapsedButtonsWidth: toolBar.Layout.minimumWidth + (page.actions.left ? toolBar.Layout.minimumWidth + Units.gridUnit : 0) + (page.actions.main ? toolBar.Layout.minimumWidth + Units.gridUnit : 0) + (page.actions.right ? toolBar.Layout.minimumWidth + Units.gridUnit : 0)
        readonly property int requiredWidth: width + collapsedButtonsWidth
        readonly property bool toobig: root.width - root.leftPadding - root.rightPadding - titleLoader.implicitWidth - Units.gridUnit < buttonTextMetrics.requiredWidth
    }
}

