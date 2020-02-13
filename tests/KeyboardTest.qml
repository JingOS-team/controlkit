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
        Kirigami.Page {
            readonly property alias lastKey: see.text
            Text {
                id: see
                anchors.centerIn: parent
                color: parent.focus ? "black" : "red"
            }

            Keys.onPressed: {
                if (event.text)
                    see.text = event.text
                else
                    see.text = event.key
            }

            Keys.onEnterPressed: main.showPassiveNotification("page!")
        }
    }

    header: Text {
        text: "focus:" + activeFocusItem + " current: " + main.pageStack.currentIndex
    }

    Component.onCompleted: {
        main.pageStack.push(keyPage)
        main.pageStack.push(keyPage)
    }
}
