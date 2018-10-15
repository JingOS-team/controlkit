/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
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

import QtQuick 2.1
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami
import "private"
import QtQuick.Templates 2.0 as T2

/**
 * Page is a container for all the app pages: everything pushed to the
 * ApplicationWindow stackView should be a Page instabnce (or a subclass,
 * such as ScrollablePage)
 * @see ScrollablePage
 * @inherit QtQuick.Templates.Page
 */
T2.Page {
    id: root

    /**
     * leftPadding: int
     * default contents padding at left
     */
    leftPadding: Kirigami.Units.gridUnit

    /**
     * topPadding: int
     * default contents padding at top
     */
    topPadding: Kirigami.Units.gridUnit

    /**
     * rightPadding: int
     * default contents padding at right
     */
    rightPadding: Kirigami.Units.gridUnit

    /**
     * bottomPadding: int
     * default contents padding at bottom
     */
    bottomPadding: actionButtons.item ? actionButtons.height : Kirigami.Units.gridUnit

    /**
     * flickable: Flickable
     * if the central element of the page is a Flickable
     * (ListView and Gridview as well) you can set it there.
     * normally, you wouldn't need to do that, but just use the
     * ScrollablePage element instead
     * @see ScrollablePage
     * Use this if your flickable has some non standard properties, such as not covering the whole Page
     */
    property Flickable flickable

    /**
     * actions.contextualActions: list<QtObject>
     * Defines the contextual actions for the page:
     * an easy way to assign actions in the right sliding panel
     *
     * Example usage:
     * @code
     * import org.kde.kirigami 2.4 as Kirigami
     *
     * Kirigami.ApplicationWindow {
     *  [...]
     *     contextDrawer: Kirigami.ContextDrawer {
     *         id: contextDrawer
     *     }
     *  [...]
     * }
     * @endcode
     *
     * @code
     * import org.kde.kirigami 2.4 as Kirigami
     *
     * Kirigami.Page {
     *   [...]
     *     actions.contextualActions: [
     *         Kirigami.Action {
     *             iconName: "edit"
     *             text: "Action text"
     *             onTriggered: {
     *                 // do stuff
     *             }
     *         },
     *         Kirigami.Action {
     *             iconName: "edit"
     *             text: "Action text"
     *             onTriggered: {
     *                 // do stuff
     *             }
     *         }
     *     ]
     *   [...]
     * }
     * @endcode
     */
    //TODO: remove
    property alias contextualActions: actionsGroup.contextualActions

    /**
     * actions.main: Action
     * An optional single action for the action button.
     * it can be a Kirigami.Action or a QAction
     *
     * Example usage:
     *
     * @code
     * import org.kde.kirigami 2.4 as Kirigami
     * Kirigami.Page {
     *     actions.main: Kirigami.Action {
     *         iconName: "edit"
     *         onTriggered: {
     *             // do stuff
     *         }
     *     }
     * }
     * @endcode
     */
    //TODO: remove
    property alias mainAction: actionsGroup.main

    /**
     * actions.left: Action
     * An optional extra action at the left of the main action button.
     * it can be a Kirigami.Action or a QAction
     *
     * Example usage:
     *
     * @code
     * import org.kde.kirigami 2.4 as Kirigami
     * Kirigami.Page {
     *     actions.left: Kirigami.Action {
     *         iconName: "edit"
     *         onTriggered: {
     *             // do stuff
     *         }
     *     }
     * }
     * @endcode
     */
    //TODO: remove
    property alias leftAction: actionsGroup.left

    /**
     * actions.right: Action
     * An optional extra action at the right of the main action button.
     * it can be a Kirigami.Action or a QAction
     *
     * Example usage:
     *
     * @code
     * import org.kde.kirigami 2.4 as Kirigami
     * Kirigami.Page {
     *     actions.right: Kirigami.Action {
     *         iconName: "edit"
     *         onTriggered: {
     *             // do stuff
     *         }
     *     }
     * }
     * @endcode
     */
    //TODO: remove
    property alias rightAction: actionsGroup.right

    /**
     * Actions properties are grouped.
     *
     * @code
     * import org.kde.kirigami 2.4 as Kirigami
     * Kirigami.Page {
     *     actions {
     *         main: Kirigami.Action {...}
     *         left: Kirigami.Action {...}
     *         right: Kirigami.Action {...}
     *         contextualActions: [
     *             Kirigami.Action {...},
     *             Kirigami.Action {...}
     *         ]
     *     }
     * }
     * @endcode
     */
    readonly property alias actions: actionsGroup

    /**
     * isCurrentPage: bool
     *
     * Specifies if it's the currently selected page in the window's pages row.
     *
     * @since 2.1
     */
    readonly property bool isCurrentPage: typeof applicationWindow === "undefined" || !globalToolBar.row
                ? true
                : (globalToolBar.row.layers.depth > 1
                    ? globalToolBar.row.layers.currentItem == root
                    : globalToolBar.row.currentItem == root)

    /**
     * overlay: Item
     * an item which stays on top of every other item in the page,
     * if you want to make sure some elements are completely in a
     * layer on top of the whole content, parent items to this one.
     * It's a "local" version of ApplicationWindow's overlay
     * @since 2.5
     */
    readonly property alias overlay: overlayItem

    /**
     * emitted When the application requests a Back action
     * For instance a global "back" shortcut or the Android
     * Back button has been pressed.
     * The page can manage the back event by itself,
     * and if it set event.accepted = true, it will stop the main
     * application to manage the back event.
     */
    signal backRequested(var event);

    // Look for sheets and cose them
    //FIXME: port Sheets to Popup?
    onBackRequested: {
        for(var i in root.resources) {
            var item = root.resources[i];
            if (item.hasOwnProperty("close") && item.hasOwnProperty("sheetOpen") && item.sheetOpen) {
                item.close()
                event.accepted = true;
                return;
            }
        }
    }

    /**
     * globalToolBarItem: Item
     * The item used as global toolbar for the page
     * present only if we are in a PageRow as a page or as a layer,
     * and the style is either Titles or ToolBar
     * @since 2.5
     */
    readonly property Item globalToolBarItem: globalToolBar.item

    //NOTE: contentItem will be created if not existing (and contentChildren of Page would become its children) This with anchors enforces the geometry we want, where globalToolBar is a super-header, on top of header
    contentItem: Item {
        anchors {
            top: root.header
                    ? root.header.bottom
                    : (globalToolBar.visible ? globalToolBar.bottom : parent.top)
            topMargin: root.topPadding + root.spacing
            bottom: root.footer ? root.footer.top : parent.bottom
            bottomMargin: root.bottomPadding + root.spacing
        }
    }


    //FIXME: on material the shadow would bleed over
    clip: root.header != null;

    onHeaderChanged: {
        if (header) {
            header.anchors.top = Qt.binding(function() {return globalToolBar.visible ? globalToolBar.bottom : root.top});
        }
    }

    Component.onCompleted: {
        headerChanged();
        parentChanged(root.parent);
    }
    onParentChanged: {
        if (!parent) {
            return;
        }
        globalToolBar.stack = null;
        globalToolBar.row = null;

        if (root.parent.hasOwnProperty("__pageRow")) {
            globalToolBar.row = root.parent.__pageRow;
        }
        if (root.T2.StackView.view) {
            globalToolBar.stack = root.T2.StackView.view;
            globalToolBar.row = root.T2.StackView.view.parent;
        }
        if (globalToolBar.row) {
            globalToolBar.row.globalToolBar.actualStyleChanged.connect(globalToolBar.syncSource);
            globalToolBar.syncSource();
        }
    }

    //in data in order for them to not be considered for contentItem, contentChildren, contentData
    data: [
        PageActionPropertyGroup {
            id: actionsGroup
        },

        Item {
            id: overlayItem
            parent: root
            z: 9997
            anchors.fill: parent
        },
        //global top toolbar if we are in a PageRow (in the row or as a layer)
        Loader {
            id: globalToolBar
            z: 9999
            height: item ? item.implicitHeight : 0
            anchors {
                left:  parent.left
                right: parent.right
                top: parent.top
            }
            property Kirigami.PageRow row
            property T2.StackView stack

           // property Component toolbarComponent: Qt.createComponent(Qt.resolvedUrl(row.globalToolBar.actualStyle == Kirigami.ApplicationHeaderStyle.ToolBar ? "private/globaltoolbar/ToolBarPageHeader.qml" : "private/globaltoolbar/TitlesPageHeader.qml"))

            visible: active
            active: row && (stack != null || row.globalToolBar.actualStyle == Kirigami.ApplicationHeaderStyle.ToolBar || globalToolBar.row.globalToolBar.actualStyle == Kirigami.ApplicationHeaderStyle.Titles)

            function syncSource() {
                if (row && active) {
                    setSource(Qt.resolvedUrl(row.globalToolBar.actualStyle == Kirigami.ApplicationHeaderStyle.ToolBar ? "private/globaltoolbar/ToolBarPageHeader.qml" : "private/globaltoolbar/TitlesPageHeader.qml"),
                    //TODO: find container reliably, remove assumption
                    {"pageRow": Qt.binding(function() {return row}),
                    "page": root,
                    "current": Qt.binding(function() {return stack || !root.parent ? true : row.currentIndex == root.parent.level})});
                }
            }

            Separator {
                z: 999
                anchors.verticalCenter: globalToolBar.verticalCenter
                height: globalToolBar.height * 0.6
                visible: globalToolBar.row && root.parent && globalToolBar.row.contentItem.contentX < root.parent.x - globalToolBar.row.globalToolBar.leftReservedSpace
                Kirigami.Theme.textColor: globalToolBar.item ? globalToolBar.item.Kirigami.Theme.textColor : undefined
            }
        },

        //bottom action buttons
        Loader {
            id: actionButtons
            z: 9999
            parent: root
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            //It should be T2.Page, Qt 5.7 doesn't like it
            property Item page: root
            height: item ? item.height : 0
            active: typeof applicationWindow !== "undefined" && (!globalToolBar.row || globalToolBar.row.globalToolBar.actualStyle != Kirigami.ApplicationHeaderStyle.ToolBar) &&
                //Legacy
                    (typeof applicationWindow === "undefined" ||
                    (!applicationWindow().header || applicationWindow().header.toString().indexOf("ToolBarApplicationHeader") === -1) &&
                    (!applicationWindow().footer || applicationWindow().footer.toString().indexOf("ToolBarApplicationHeader") === -1))
            source: Qt.resolvedUrl("./private/ActionButton.qml")
        }
    ]

    Layout.fillWidth: true
}
