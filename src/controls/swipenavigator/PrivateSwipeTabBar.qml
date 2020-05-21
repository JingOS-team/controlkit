/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import org.kde.kirigami 2.12 as Kirigami

RowLayout {
    id: swipeTabBarRoot
    spacing: 0
    signal indexChanged(real xPos, real tabWidth)

    property Item layouter: Item {
        Row {
            id: expandedLayouter
            Repeater {
                model: swipeNavigatorRoot.pages
                delegate: PrivateSwipeTab { small: false }
            }
        }
    }

    Repeater {
        model: swipeNavigatorRoot.pages
        delegate: PrivateSwipeTab {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter
            small: expandedLayouter.width > swipeNavigatorRoot.width
            onIndexChanged: swipeTabBarRoot.indexChanged(xPos, tabWidth)
        }
    }
}
