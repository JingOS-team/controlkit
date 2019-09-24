/*
 *   Copyright 2016 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.7
import QtQuick.Controls 2.5 as Controls
import org.kde.kirigami 2.10 as Kirigami

/**
 * An action used to load Pages coming from a common PagePool
 * in a PageRow or QtQuickControls2 StackView
 *
 * @inherit Action
 */
Kirigami.Action {
    id: root

    property string page
    property Kirigami.PagePool pagePool
    property Item pageStack
    property Controls.Page basePage

    checked: pagePool && pagePool.resolvedUrl(page) == pagePool.lastLoadedUrl
    onTriggered: {
        if (page.length == 0 || !pagePool || !pageStack) {
            return;
        }

        if (!pageStack.hasOwnProperty("pop") || typeof pageStack.pop !== "function" || !pageStack.hasOwnProperty("push") || typeof pageStack.push !== "function") {
            return;
        }

        if (pagePool.isLocalUrl(page)) {
            pageStack.pop(basePage);
            pageStack.push(pagePool.loadPage(page));
        } else {
            pagePool.loadPage(page, function(item) {
                pageStack.pop(basePage);
                pageStack.push(item);
            });
        }
    }
}
