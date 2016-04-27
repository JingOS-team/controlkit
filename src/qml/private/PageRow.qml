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
    readonly property alias depth: pagesModel.count

    /**
     * The last Page in the Row
     */
    readonly property Item lastItem: pagesModel.count ? pagesModel.get(pagesModel.count - 1).page : null

    /**
     * The currently visible Item
     */
    readonly property Item currentItem: mainFlickable.currentItem

    /**
     * the index of the currently visible Item
     */
    property alias currentIndex: mainFlickable.currentIndex

    /**
     * The initial item when this PageRow is created
     */
    property variant initialPage

    /**
     * The main flickable of this Row
     */
    property alias contentItem: mainFlickable

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
                pagesModel.append(container);
            }
        }

        // initialize the page
        var container = pagesModel.initPage(page, properties);
        pagesModel.append(container);

        container.visible = container.page.visible = true;
        mainFlickable.currentIndex = container.level;
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
            return;
        }

        var oldPage = pagesModel.get(pagesModel.count-1).page;
        if (page !== undefined) {
            // an unwind target has been specified - pop until we find it
            while (page != oldPage && pagesModel.count > 1) {
                pagesModel.remove(oldPage.parent.ObjectModel.index);
                if (oldPage.parent.owner) {
                    oldPage.parent = oldPage.parent.owner;
                }
                oldPage.parent.destroy();
                oldPage = pagesModel.get(pagesModel.count-1).page;
            }
        } else {
            pagesModel.remove(pagesModel.count-1);
            if (oldPage.parent.owner) {
                oldPage.parent = oldPage.parent.owner;
            }
            oldPage.parent.destroy();
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
        return pagesModel.clear();
    }

    function get(idx) {
        return pagesModel.get(idx);
    }

//END FUNCTIONS

    ObjectModel {
        id: pagesModel

        property var componentCache

        //NOTE:seems to only work if the array is defined in a declarative way,
        //the Object in an imperative way, espacially on Android
        Component.onCompleted: {
            componentCache = {};
        }

        function initPage(page, properties) {
            var container = containerComponent.createObject(mainLayout, {
                "level": pagesModel.count,
                "page": page
            });

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

    NumberAnimation {
        id: scrollAnim
        target: mainFlickable
        property: "contentX"
        duration: Units.longDuration
        easing.type: Easing.InOutQuad
    }
    Timer {
        id: currentItemSnapTimer
        interval: Units.longDuration
        property Item itemToSnap
        onTriggered: {
            var mappedPos = itemToSnap.mapToItem(mainFlickable, 0, 0);
            if (itemToSnap == currentItem.parent && mappedPos.x >= 0 && mappedPos.x + itemToSnap.width <= mainFlickable.width) {
                return;
            }
            scrollAnim.running = false;
            scrollAnim.from = mainFlickable.contentX;
            //currentItem snaps at the end of the view, the others at the beginning
            if (itemToSnap == currentItem.parent) {
                scrollAnim.to = itemToSnap.x - Math.max(0, mainFlickable.width - itemToSnap.width);
            } else {
                scrollAnim.to = Math.min(itemToSnap.x, mainLayout.width - mainFlickable.width);
            }
            scrollAnim.running = true;
        }
    }
    ScrollView {
        anchors.fill: parent
        Flickable {
            id: mainFlickable
            anchors.fill: parent
            boundsBehavior: Flickable.StopAtBounds
            contentWidth: mainLayout.width
            contentHeight: height
            readonly property Item currentItem: pagesModel.count > currentIndex ? pagesModel.get(currentIndex).page : null
            property int currentIndex: 0
            flickDeceleration: Units.gridUnit * 50
            onCurrentItemChanged: {
                currentItemSnapTimer.itemToSnap = currentItem.parent;
                currentItemSnapTimer.restart();
            }
            onMovementEnded: {
                var pos = currentItem.mapToItem(mainFlickable, 0, 0);
                var oldCurrentIndex = currentIndex;
                if (pos.x < 0 || pos.x >= width) {
                    currentIndex = mainLayout.childAt(contentX + width - 10, 10).level;
                }

                if (oldCurrentIndex != currentIndex) {
                    return;
                }
                var childToSnap = mainLayout.childAt(contentX + 1, 10);
                var mappedPos = childToSnap.mapToItem(mainFlickable, 0, 0);
                if (mappedPos.x < -childToSnap.width / 2) {
                    childToSnap = mainLayout.children[childToSnap.level+1];
                }
                currentItemSnapTimer.itemToSnap = childToSnap;
                currentItemSnapTimer.restart();
            }
            onFlickEnded: movementEnded();
            onWidthChanged: movementEnded();

            Row {
                id: mainLayout
                Repeater {
                    model: pagesModel
                }
                add: Transition {
                    NumberAnimation {
                        property: "y"
                        from: mainFlickable.height
                        to: 0
                        duration: Units.shortDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }

    Component {
        id: containerComponent

        MouseArea {
            id: container
            height: mainFlickable.height
            width: root.width
            state: ""
            property string pendingState: root.width < root.defaultColumnWidth*2 ? "vertical" : (container.level >= pagesModel.count - 1 ? "last" : "middle");

            //HACK
            onPendingStateChanged: {
                stateTimer.restart();
            }
            Timer {
                id: stateTimer
                interval: 150
                onTriggered: container.state = container.pendingState
            }
            //NOTE: use this instead of ObjectModel.index because we need to have this set
            // *before* it's added to the model
            property int level

            property int hint: page && page.implicitWidth ? page.implicitWidth : root.defaultColumnWidth
            property int roundedHint: Math.floor(root.width/hint) > 0 ? root.width/Math.floor(root.width/hint) : root.width

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
                width: Math.ceil(Units.smallSpacing / 5)
                color: Theme.textColor
                opacity: 0.3
                visible: container.level < root.depth
            }
            states: [
                State {
                    name: "vertical"
                    PropertyChanges {
                        target: container
                        width: root.width
                    }
                },
                State {
                    name: "last"
                    PropertyChanges {
                        target: container
                        width: Math.max(roundedHint, root.width - (container.level == 0 ? 0 : pagesModel.get(container.level-1).width))
                    }
                },
                State {
                    name: "middle"
                    PropertyChanges {
                        target: container
                        width: roundedHint
                    }
                }
            ]
            transitions: [
                Transition {
                    from: "last,middle"
                    to: "middle,last"
                    SequentialAnimation {
                        NumberAnimation {
                            property: "width"
                            duration: Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                        ScriptAction {
                            script: {
                                currentItemSnapTimer.itemToSnap = mainFlickable.currentItem.parent;
                                currentItemSnapTimer.restart();
                            }
                        }
                    }
                }
            ]
        }
    }

    Component.onCompleted: {
        if (initialPage) {
            push(initialPage, null)
        }
    }
}
