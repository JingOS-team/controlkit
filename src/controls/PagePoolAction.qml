/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.5 as Controls
import org.kde.kirigami 2.11 as Kirigami

/**
 * An action used to load Pages coming from a common PagePool
 * in a PageRow or QtQuickControls2 StackView
 *
 * @inherit Action
 */
Kirigami.Action {
    id: root

    /**
     * page: string
     * Url or filename of the page this action will load
     */
    property string page

    /**
     * pagePool: Kirigami.PagePool
     * The PagePool used by this PagePoolAction.
     * PagePool will make sure only one instance of the page identified by the page url will be created and reused.
     *PagePool's lastLoaderUrl property will be used to control the mutual
     * exclusivity of the checked state of the PagePoolAction instances
     * sharing the same PagePool
     */
    property Kirigami.PagePool pagePool

    /**
     * pageStack: Kirigami.PageRow or QtQuickControls2 StackView
     * The component that will instantiate the pages, which has to work with a stack logic.
     * Kirigami.PageRow is recommended, but will work with QtQuicControls2 StackView as well.
     * By default this property is binded to ApplicationWindow's global
     * pageStack, which is a PageRow by default.
     */
    property Item pageStack: typeof applicationWindow != undefined ? applicationWindow().pageStack : null

    /**
     * basePage: Kirigami.Page
     * The page of pageStack new pages will be pushed after.
     * All pages present after the given basePage will be removed from the pageStack
     */
    property Controls.Page basePage

    /**
      * initialProperties: JavaScript Object
      * The initialProperties object specifies a map of initial property values for the created page
      * when it is pushed onto the Kirigami.PagePool.
      */
    property var initialProperties

    checked: pagePool && pagePool.resolvedUrl(page) == pagePool.lastLoadedUrl
    onTriggered: {
        if (page.length == 0 || !pagePool || !pageStack) {
            return;
        }

        if (initialProperties && typeof(initialProperties) !== "object") {
            console.warn("initialProperties must be of type object");
            return;
        }

        if (pagePool.resolvedUrl(page) == pagePool.lastLoadedUrl) {
            return;
        }

        if (!pageStack.hasOwnProperty("pop") || typeof pageStack.pop !== "function" || !pageStack.hasOwnProperty("push") || typeof pageStack.push !== "function") {
            return;
        }

        if (pagePool.isLocalUrl(page)) {
            if (basePage) {
                pageStack.pop(basePage);
            } else {
                pageStack.clear();
            }

            pageStack.push(initialProperties ?
                               pagePool.loadPageWithProperties(page, initialProperties) :
                               pagePool.loadPage(page));
                               
        } else {
            var callback = function(item) {
                if (basePage) {
                    pageStack.pop(basePage);
                } else {
                    pageStack.clear();
                }
                pageStack.push(item);
            };

            if (initialProperties) {
                pagePool.loadPage(page, initialProperties, callback);

            } else {
                pagePool.loadPage(page, callback);
            }
        }
    }
}
