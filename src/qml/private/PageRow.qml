/*
 *   Copyright 2016 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
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

import QtQuick 2.5
import QtQml.Models 2.2
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.2
import org.kde.kirigami 1.0

Item {
    id: root

    anchors.fill: parent

//BEGIN PROPERTIES
    /**
     * This property holds the number of items currently pushed onto the view
     */
    property alias depth: listView.count

    /**
     * The last Page in the Row
     */
    property Item lastItem: listView.count ? pagesModel.get(listView.count - 1) : null

    /**
     * The currently visible Item
     */
    property Item currentItem: listView.currentItem.page

    /**
     * the index of the currently visible Item
     */
    property alias currentIndex: listView.currentIndex

    /**
     * This property holds the list of content children.
     */
    property alias contentChildren: pagesModel.actualPages

    /**
     * The initial item when this PageRow is created
     */
    property variant initialPage

    /**
     * The main flickable of this Row
     */
    property alias contentItem: listView

    /**
     * The default width for a column
     * default is wide enough for 30 grid units.
     * Pages can override it with their Layout.fillWidth,
     * implicitWidth Layout.minimumWidth etc.
     */
    property int defaultColumnWidth: Units.gridUnit * 30

//END PROPERTIES

//BEGIN FUNCTIONS
    /**
     * Pushes a page on the stack.
     * The page can be defined as a component, item or string.
     * If an item is used then the page will get re-parented.
     * If a string is used then it is interpreted as a url that is used to load a page 
     * component.
     *
     * @param page The page can also be given as an array of pages.
     *     In this case all those pages will
     *     be pushed onto the stack. The items in the stack can be components, items or
     *     strings just like for single pages.
     *     Additionally an object can be used, which specifies a page and an optional
     *     properties property.
     *     This can be used to push multiple pages while still giving each of
     *     them properties.
     *     When an array is used the transition animation will only be to the last page.
     *
     * @param properties The properties argument is optional and allows defining a
     * map of properties to set on the page.
     * @return The new created page
     */
    function push(page, properties) {

        pop(currentItem, true);

        // figure out if more than one page is being pushed
        var pages;
        if (page instanceof Array) {
            pages = page;
            page = pages.pop();
            if (page.createObject === undefined && page.parent === undefined && typeof page != "string") {
                properties = properties || page.properties;
                page = page.page;
            }
        }

        // push any extra defined pages onto the stack
        if (pages) {
            var i;
            for (i = 0; i < pages.length; i++) {
                var tPage = pages[i];
                var tProps;
                if (tPage.createObject === undefined && tPage.parent === undefined && typeof tPage != "string") {
                    tProps = tPage.properties;
                    tPage = tPage.page;
                }

                var container = pagesModel.initPage(tPage, tProps);
                pagesModel.actualPages.push(pages[i]);
                pagesModel.append(container);
            }
        }

        // initialize the page
        var container = pagesModel.initPage(page, properties);
        pagesModel.actualPages.push(container.page);

        pagesModel.append(container);
        listView.currentIndex = container.ObjectModel.index;
        return container.page
    }

    /**
     * Pops a page off the stack.
     * @param page If page is specified then the stack is unwound to that page,
     * to unwind to the first page specify
     * page as null.
     * @return The page instance that was popped off the stack.
     */
    function pop(page) {
        if (depth == 0) {
            return null;
        }

        if (page !== undefined && page == pagesModel.actualPages[root.currentIndex - 1]) {
            return null;
        }

        if (page !== undefined) {
            var oldPage = pagesModel.actualPages[pagesModel.actualPages.length-1];
            // an unwind target has been specified - pop until we find it
            while (page != oldPage && pagesModel.actualPages.length > 1) {
                oldPage = pagesModel.actualPages[pagesModel.actualPages.length-1];

                pagesModel.actualPages.pop();
                pagesModel.remove(oldPage.parent.ObjectModel.index);
                if (oldPage.parent.owner) {
                    oldPage.parent = oldPage.parent.owner;
                    oldPage.parent.destroy();
                }
            }
        }
    }

    /**
     * Replaces a page on the stack.
     * @param page The page can also be given as an array of pages.
     *     In this case all those pages will
     *     be pushed onto the stack. The items in the stack can be components, items or
     *     strings just like for single pages.
     *     Additionally an object can be used, which specifies a page and an optional
     *     properties property.
     *     This can be used to push multiple pages while still giving each of
     *     them properties.
     *     When an array is used the transition animation will only be to the last page.
     * @param properties The properties argument is optional and allows defining a
     * map of properties to set on the page.
     * @see push() for details.
     */
    function replace(page, properties) {
        pop(currentItem, true);
        return push(page, properties);
    }

    /**
     * Clears the page stack.
     * Destroy (or reparent) all the pages contained.
     */
    function clear() {
        pagesModel.actualPages.clear();
        return pagesModel.clear();
    }

//END FUNCTIONS

    ObjectModel {
        id: pagesModel

        property var componentCache
        property var actualPages

        Component.onCompleted: {
            componentCache = {};
            actualPages = [];
        }

        onCountChanged: root.contentChildrenChanged();

        function initPage(page, properties) {
            var container = containerComponent.createObject(pagesModel);

            var pageComp;
            if (page.createObject) {
                // page defined as component
                pageComp = page;
            } else if (typeof page == "string") {
                // page defined as string (a url)
                pageComp = pagesModel.componentCache[page];
                if (!pageComp) {
                    pageComp = pagesModel.componentCache[page] = Qt.createComponent(page);
                }
            }
            if (pageComp) {
                if (pageComp.status == Component.Error) {
                    throw new Error("Error while loading page: " + pageComp.errorString());
                } else {
                    // instantiate page from component
                    page = pageComp.createObject(container.pageParent, properties || {});
                }
            } else {
                // copy properties to the page
                for (var prop in properties) {
                    if (properties.hasOwnProperty(prop)) {
                        page[prop] = properties[prop];
                    }
                }
            }

            container.page = page;
            if (page.parent == null || page.parent == container.pageParent) {
                container.owner = null;
            } else {
                container.owner = page.parent;
            }

            // the page has to be reparented
            if (page.parent != container) {
                page.parent = container;
            }

            return container;
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: pagesModel
        orientation: ListView.Horizontal
        snapMode: ListView.SnapToItem
        boundsBehavior: Flickable.StopAtBounds
        highlightMoveDuration: Units.longDuration
        onMovementEnded: {
            var pos = currentItem.mapToItem(listView, 0, 0);
            if (pos.x < 0 || pos.x >= width) {
                currentIndex = indexAt(contentX + width - 10, 10);
            }
        }
        onFlickEnded: movementEnded();

        add: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Units.longDuration
                }
                NumberAnimation {
                    properties: "x,y"
                    duration: Units.longDuration
                }
            }
        }
    }

    Component {
        id: containerComponent

        MouseArea {
            id: container
            implicitWidth: ObjectModel.index == pagesModel.count - 1 ? Math.max(roundedWidth, root.width - (ObjectModel.index == 0 ? 0 : pagesModel.get(ObjectModel.index-1).width)) : roundedWidth
            height: listView.height
            property int hint: page && page.implicitWidth ? page.implicitWidth : root.defaultColumnWidth
            property int roundedWidth: Math.floor(root.width/hint) > 0 ? root.width/Math.floor(root.width/hint) : root.width

            property Item page
            property Item owner
            onPageChanged: {
                page.parent = container;
                page.anchors.fill = container;
            }
            drag.filterChildren: true
            onClicked: root.currentIndex = ObjectModel.index;
            Rectangle {
                z: 999
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                }
                width: 1
                color: Theme.textColor
                opacity: 0.3
                visible: container.ObjectModel.index < root.depth
            }
        }
    }

    Component.onCompleted: {
        if (initialPage) {
            push(initialPage, null)
        }
    }
}
