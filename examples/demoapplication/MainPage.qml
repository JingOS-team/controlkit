/*
 * Copyright 2021 Rui Wang <wangrui@jingos.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.3
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.11 as Kirigami
import QtQuick 2.14

Kirigami.ScrollablePage {
    id: pageRoot

    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0
    topPadding: 0

    title: qsTr("JingOS Demo")

    actions {
        main: Kirigami.Action {
            iconName: "go-home"
            enabled: root.pageStack.lastVisibleItem != pageRoot
            onTriggered: root.pageStack.pop(-1)
        }
    }

    Kirigami.PagePool {
        id: mainPagePool
    }

    ListModel {
        id: galleryModel
        ListElement{
            title: "Buttons"
            targetPage: "gallery/ButtonGallery.qml"
        }
        ListElement{
            title: "Images"
            targetPage: "gallery/ImageGallery.qml"
        }
        ListElement{
            title: "Labels"
            targetPage: "gallery/LabelGallery.qml"
        }
        ListElement{
            title: "Search"
            targetPage: "gallery/SearchGallery.qml"
        }
        ListElement{
            title: "Popup"
            targetPage: "gallery/TestPopupGallery.qml"
        }
        ListElement{
            title: "PopupMenu"
            targetPage: "gallery/MenuPopupGallery.qml"
        }
        ListElement{
            title: "Dialog"
            targetPage: "gallery/DialogGallery.qml"
        }
        ListElement{
            title: "GridHover"
            targetPage: "gallery/GridHoverGallery.qml"
        }
        ListElement{
            title: "ListViewHover"
            targetPage: "gallery/ListViewHoverGallery.qml"
        }
        ListElement{
            title: "Page"
            targetPage: "gallery/PageGallery.qml"
        }
        ListElement{
            title: "Switch_Slider"
            targetPage: "gallery/Switch_Slider.qml"
        }
        ListElement{
            title: "Test"
            targetPage: "gallery/TestGallery.qml"
        }
    }

    ColumnLayout {
        spacing: 0

        Repeater{
            focus: true
            model: galleryModel

            delegate: Kirigami.BasicListItem {
                label: title

                action:Kirigami.PagePoolAction {
                    id: action
                    pagePool: mainPagePool
                    basePage: pageRoot
                    page: targetPage
                }
            }
        }
    }

    background:Item{
    }
}