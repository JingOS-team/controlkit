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
    readonly property alias depth: pagesLogic.count

    /**
     * The last Page in the Row
     */
    readonly property Item lastItem: pagesLogic.count ? pagesLogic.get(pagesLogic.count - 1).page : null

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

                var container = pagesLogic.initPage(tPage, tProps);
                pagesLogic.append(container);
            }
        }

        // initialize the page
        var container = pagesLogic.initPage(page, properties);
        pagesLogic.append(container);
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

        var oldPage = pagesLogic.get(pagesLogic.count-1).page;
        if (page !== undefined) {
            // an unwind target has been specified - pop until we find it
            while (page != oldPage && pagesLogic.count > 1) {
                pagesLogic.remove(oldPage.parent.level);

                oldPage = pagesLogic.get(pagesLogic.count-1).page;
            }
        } else {
            pagesLogic.remove(pagesLogic.count-1);
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
        return pagesLogic.clear();
    }

    function get(idx) {
        return pagesLogic.get(idx).page;
    }

//END FUNCTIONS

    QtObject {
        id: pagesLogic

        readonly property int count: mainLayout.children.length
        property var componentCache

        //NOTE:seems to only work if the array is defined in a declarative way,
        //the Object in an imperative way, espacially on Android
        Component.onCompleted: {
            componentCache = {};
        }

        //TODO: remove?
        function get(id) {
            return mainLayout.children[id];
        }

        function append(item) {
            item.parent = mainLayout;
        }

        function clear () {
            while (mainLayout.children.length > 0) {
                remove(0);
            }
        }

        function remove(id) {
            if (id < 0 || id >= count) {
                print("Tried to remove an invalid page index:" + id);
                return;
            }

            var item = mainLayout.children[id];
            if (item.owner) {
                item.page.parent = item.owner;
            }
            //FIXME: why reparent ing is necessary?
            //is destroy just an async deleteLater() that isn't executed immediately or it actually leaks?
            item.parent = root;
            item.destroy();
        }

        function initPage(page, properties) {
            var container = containerComponent.createObject(mainLayout, {
                "level": pagesLogic.count,
                "page": page
            });

            var pageComp;
            if (page.createObject) {
                // page defined as component
                pageComp = page;
            } else if (typeof page == "string") {
                // page defined as string (a url)
                pageComp = pagesLogic.componentCache[page];
                if (!pageComp) {
                    pageComp = pagesLogic.componentCache[page] = Qt.createComponent(page);
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
        id: itemSnapTimer
        interval: Units.longDuration
        property Item itemToSnap
        onTriggered: {
            scrollAnim.running = false;
            scrollAnim.from = mainFlickable.contentX;

            scrollAnim.to = Math.min(itemToSnap.x, mainLayout.childrenRect.width - mainFlickable.width);

            scrollAnim.running = true;
        }
    }
    Timer {
        id: currentItemSnapTimer
        interval: Units.longDuration
        property Item itemToSnap
        onTriggered: {
            var mappedPos = mainFlickable.currentItem.parent.mapToItem(mainFlickable, 0, 0);
            if (mappedPos.x >= 0 && mappedPos.x + mainFlickable.currentItem.parent.width <= mainFlickable.width) {
                return;
            }
            scrollAnim.running = false;
            itemSnapTimer.running = false;
            scrollAnim.from = mainFlickable.contentX;

            scrollAnim.to = Math.max(0, (mainFlickable.currentItem.parent.x + mainFlickable.currentItem.parent.width) - mainFlickable.width);
            scrollAnim.running = true;
        }
    }

    Flickable {
        id: mainFlickable
        anchors.fill: parent
        boundsBehavior: Flickable.StopAtBounds
        contentWidth: mainLayout.childrenRect.width
        contentHeight: height
        readonly property Item currentItem: pagesLogic.get(Math.min(currentIndex, pagesLogic.count-1)).page
        //clip only when the app has a sidebar
        clip: root.x > 0

        property int currentIndex: 0
        flickDeceleration: Units.gridUnit * 50
        onCurrentItemChanged: {
            currentItemSnapTimer.restart();
        }
        onMovementEnded: {
            var pos = currentItem.mapToItem(mainFlickable, 0, 0);
            var oldCurrentIndex = currentIndex;

            var childToSnap = mainLayout.childAt(contentX + 1, 10);
            var mappedPos = childToSnap.mapToItem(mainFlickable, 0, 0);
            if (mappedPos.x < -childToSnap.width / 2) {
                childToSnap = mainLayout.children[childToSnap.level+1];
            }
            itemSnapTimer.itemToSnap = childToSnap;
            itemSnapTimer.restart();

            var mappedCurrentItemPos = currentItem.mapToItem(mainFlickable, 0, 0);

            if (mappedCurrentItemPos.x < 0 || mappedCurrentItemPos.x + currentItem.width > mainFlickable.width) {
                var newCurrentItem = mainLayout.childAt(Math.min(childToSnap.x + width, mainLayout.childrenRect.width) - 10, 10);
                if (newCurrentItem) {
                    currentIndex = newCurrentItem.level;
                } else {
                    currentIndex = pagesLogic.count - 1;
                }
            }
        }
        onFlickEnded: movementEnded();
        onWidthChanged: movementEnded();

        Row {
            id: mainLayout

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

    //show a separator when the app has a sidebar
    Rectangle {
        z: 999
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        width: Math.ceil(Units.smallSpacing / 5)
        color: Theme.textColor
        opacity: 0.3
        visible: root.x > 0
    }

    Rectangle {
        height: Units.smallSpacing
        width: root.width/root.depth
        anchors.bottom: parent.bottom
        color: Theme.textColor
        opacity: 0
        x: root.width * mainFlickable.visibleArea.xPosition
        onXChanged: {
            opacity = 0.3
            scrollIndicatorTimer.restart();
        }
        Behavior on opacity {
            OpacityAnimator {
                duration: Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        Timer {
            id: scrollIndicatorTimer
            interval: Units.longDuration * 4
            onTriggered: parent.opacity = 0;
        }
    }

    Component {
        id: containerComponent

        MouseArea {
            id: container
            height: mainFlickable.height
            width: root.width
            state: pendingState
            property string pendingState: root.width < root.defaultColumnWidth*2 ? "vertical" : (container.level >= pagesLogic.count - 1 ? "last" : "middle");

            //HACK
            onPendingStateChanged: {
                stateTimer.restart();
            }
            Timer {
                id: stateTimer
                interval: 150
                onTriggered: container.state = container.pendingState
            }

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
            onClicked: root.currentIndex = level;

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
                        width: Math.max(roundedHint, root.width - (container.level == 0 ? 0 : pagesLogic.get(container.level-1).width))
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
