/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import org.kde.kirigami 2.12 as Kirigami

Loader {
    id: __loader
    readonly property bool shouldScroll: shrunkLayouter.width > swipeNavigatorRoot.width
    property Item layouter: Item {
        Row {
            id: shrunkLayouter
            Repeater {
                model: swipeNavigatorRoot.pages
                delegate: PrivateSwipeTab { small: true }
            }
        }
    }
    Component {
        id: nonScrollable
        PrivateSwipeTabBar {}
    }
    Component {
        id: scrollable
        ScrollView {
            id: view
            ScrollBar.horizontal.visible: false
            Timer {
                interval: 5000
                running: true
                repeat: true
            }
            PrivateSwipeTabBar {
                id: bar
                property real targetDestination
                NumberAnimation {
                    id: scrollAni
                    target: view.ScrollBar.horizontal
                    property: "position"
                    to: bar.targetDestination
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.OutExpo
                }
                onIndexChanged: {
                    if (xPos > (bar.width)/2) {
                        bar.targetDestination = (1-view.ScrollBar.horizontal.size) * ((xPos+tabWidth) / bar.width)
                        scrollAni.restart()
                    } else {
                        bar.targetDestination = (1-view.ScrollBar.horizontal.size) * ((xPos) / bar.width)
                        scrollAni.restart()
                    }
                }
            }
        }
    }
    sourceComponent: shouldScroll ? scrollable : nonScrollable
}