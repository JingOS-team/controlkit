/*
 *  SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.0
import org.kde.kirigami 2.5 as Kirigami

Kirigami.ApplicationWindow
{
    Component {
        id: delegateComponent
        Kirigami.Card {
            contentItem: Label { text: ourlist.prefix + index }
        }
    }

    pageStack.initialPage: Kirigami.ScrollablePage {

        Kirigami.CardsListView {
            id: ourlist
            property string prefix: "ciao "

            delegate: delegateComponent

            model: 100
        }
    }
}
