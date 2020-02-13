/*
 *  SPDX-FileCopyrightText: 2016 Aleix Pol Gonzalez <aleixpol@kde.org>
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0
import org.kde.kirigami 2.4 as Kirigami

Kirigami.ApplicationWindow
{
    id: main
    Component {
        id: keyPage
        Kirigami.ScrollablePage {
            ListView {
                model: 10
                delegate: Rectangle {
                    width: 100
                    height: 30
                    color: ListView.isCurrentItem ? "red" : "white"
                }
            }
        }
    }

    Component.onCompleted: {
        main.pageStack.push(keyPage)
    }
}
