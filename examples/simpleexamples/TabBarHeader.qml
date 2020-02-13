/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami

Kirigami.ApplicationWindow {
    id: root
    width: 500
    height: 800
    visible: true


    pageStack.initialPage: mainPageComponent
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.TabBar


    Component.onCompleted: {
        pageStack.push(mainPageComponent);
        pageStack.push(mainPageComponent);
        pageStack.currentIndex = 0;
    }

    //Main app content
    Component {
        id: mainPageComponent
        MultipleColumnsGallery {}
    }

}
