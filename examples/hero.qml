/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.4
import org.kde.kirigami 2.15 as Kirigami

Kirigami.ApplicationWindow {
    id: root

    pageStack.initialPage: Kirigami.Page {
        Kirigami.Avatar {
            id: avvy
            name: "Janet Doe"
            anchors.centerIn: parent

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    let page = root.pageStack.layers.push(layer)
                    page.hero.source = avvy
                    page.hero.open()
                }
            }
        }
    }

    Component {
        id: layer

        Kirigami.Page {
            id: page
            title: "Oh No"
            property Kirigami.Hero hero: Kirigami.Hero {
                destination: stackAv
            }

            Kirigami.Avatar {
                id: stackAv
                name: "John Doe"
                width: height
                height: Kirigami.Units.gridUnit * 20
                anchors.centerIn: parent

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        page.hero.close()
                        root.pageStack.layers.pop()
                    }
                }
            }
        }
    }
}
