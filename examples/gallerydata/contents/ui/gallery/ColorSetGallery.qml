/*
 *   Copyright 2017 Marco Martin <mart@kde.org>
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

import QtQuick 2.0
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.2 as Kirigami

Kirigami.ScrollablePage {
    id: page
    title: "Color Sets"

    background: Rectangle {
        color: Kirigami.Theme.backgroundColor
    }
    ColumnLayout {
        GridLayout {
            columns: 2
            Kirigami.Label {
                text: "Global Drawer color set:"
                Layout.alignment: Qt.AlignRight
            }
            Controls.ComboBox {
                Kirigami.Theme.inherit: true
                currentIndex: 0
                model: ["View", "Window", "Button", "Selection", "Tooltip", "Complementary"]
                onCurrentTextChanged: applicationWindow().globalDrawer.Kirigami.Theme.colorSet = currentText
            }

            Kirigami.Label {
                text: "Page color set:"
                Layout.alignment: Qt.AlignRight
            }
            Controls.ComboBox {
                Kirigami.Theme.inherit: true
                currentIndex: 1
                model: ["View", "Window", "Button", "Selection", "Tooltip", "Complementary"]
                onCurrentTextChanged: page.Kirigami.Theme.colorSet = currentText
            }
        }

        Controls.Frame {
            Kirigami.Theme.inherit: true
            Layout.minimumHeight: childrenRect.height
            Layout.fillWidth: true
            height: childrenRect.height
            width: parent.width
            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
            }
            contentItem: ColumnLayout {
                width: parent.width
                Kirigami.Label {
                    text: "Set inherited from parent Item"
                }
                Kirigami.BasicListItem {
                    width: parent.width
                    icon: "media-record-symbolic"
                    label: "Delegate1"
                }
                Kirigami.BasicListItem {
                    width: parent.width
                    label: "Delegate2"
                }
            }
        }

        Controls.Frame {
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Window
            Layout.minimumHeight: childrenRect.height
            Layout.fillWidth: true
            height: childrenRect.height
            width: parent.width
            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
            }
            contentItem: ColumnLayout {
                width: parent.width
                Kirigami.Label {
                    text: "Window Set"
                }
                Kirigami.BasicListItem {
                    width: parent.width
                    icon: "media-record-symbolic"
                    label: "Delegate1"
                }
                Kirigami.BasicListItem {
                    width: parent.width
                    label: "Delegate2"
                }
            }
        }

        Controls.Frame {
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.View
            Layout.minimumHeight: childrenRect.height
            Layout.fillWidth: true
            height: childrenRect.height
            width: parent.width
            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
            }
            contentItem: ColumnLayout {
                width: parent.width
                Kirigami.Label {
                    text: "View Set"
                }
                Kirigami.BasicListItem {
                    width: parent.width
                    icon: "media-record-symbolic"
                    label: "Delegate1"
                }
                Kirigami.BasicListItem {
                    width: parent.width
                    label: "Delegate2"
                }
            }
        }

        Controls.Frame {
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
            Layout.minimumHeight: childrenRect.height
            Layout.fillWidth: true
            height: childrenRect.height
            width: parent.width
            background: Rectangle {
                color: Kirigami.Theme.backgroundColor
            }
            contentItem: ColumnLayout {
                Kirigami.Label {
                    text: "Complementary Set"
                }
                Kirigami.BasicListItem {
                    width: parent.width
                    icon: "media-record-symbolic"
                    label: "Delegate1"
                }
                Kirigami.BasicListItem {
                    width: parent.width
                    label: "Delegate2"
                }
            }
        }

        Controls.Button {
            Kirigami.Theme.colorSet: Kirigami.Theme.Button
            Kirigami.Theme.inherit: false
            text: "Fixed Color Button"
        }
        Controls.Button {
            Kirigami.Theme.inherit: true
            text: "Dynamic Color Button"
        }
        Kirigami.Icon {
            source: "media-record-symbolic"
            color: "green"
            Layout.minimumWidth: 32
            Layout.minimumHeight: 32
        }
    }
}
