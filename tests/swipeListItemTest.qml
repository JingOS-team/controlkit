/*
 *  SPDX-FileCopyrightText: 2016 Aleix Pol Gonzalez <aleixpol@kde.org>
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
                model: 25
                delegate: Kirigami.SwipeListItem {
                    supportsMouseEvents: false
                    actions: [
                        Kirigami.Action {
                            iconName: "go-up"
                        }
                    ]
                    Label {
                        elide: Text.ElideRight
                        text: "big banana big banana big banana big banana big banana big banana big banana big banana big banana big banana big banana big banana big banana big banana big banana big banana big banana big banana big banana big banana "
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        main.pageStack.push(keyPage)
    }
}
