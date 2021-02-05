/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import org.kde.kirigami 2.4 as Kirigami
import org.kde.kirigami 2.15 as Kirigami215
import org.kde.kirigami 2.8 as Kirigami28
import org.kde.kirigami 2.0 as Kirigami20
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.14

Kirigami.ApplicationWindow {
    id: root

    fastBlurMode: true

    globalDrawer: Kirigami.GlobalDrawer {

        title: "Demo Jingos Control App"
        titleIcon: "applications-graphics"

        handleVisible: true

        actions: [
            Kirigami.Action {
                text: "View"
                icon.name: "view-list-icons"
                Kirigami.Action {
                    text: "action 1"
                }
                Kirigami.Action {
                    text: "action 2"
                }
                Kirigami.Action {
                    text: "action 3"
                }
            },

            Kirigami.Action {
                text: "action 3"
            },

            Kirigami.Action {
                text: "action 4"
            }
        ]

    }
    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

    pageStack.initialPage: mainRootPageComponent

    Component{
        id: mainRootPageComponent
        
        MainPage{
        }
    }

    Component {
        id: mainPageComponent

        Kirigami.Page {
            title: "Hello"
            actions {
                contextualActions: [
                    Kirigami.Action {
                        text: "action 1"
                    },
                    Kirigami.Action {
                        text: "action 2"
                    }
                ]
            }
        }
    }
}
