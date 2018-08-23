/*
 *   Copyright 2018 Marco Martin <mart@kde.org>
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

import QtQuick 2.6
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0 as Controls
import org.kde.kirigami 2.5 as Kirigami
import "private"

/**
 * This is the standard layout of a Card.
 * It is recomended to use this class when the concept of Cards is needed
 * in the application.
 * This Card has default items as header and footer. The header is an
 * image that can contain an optional title and icon, accessible via the
 * banner grouped property.
 * The footer will show a series of toolbuttons (and eventual overflow menu)
 * represewnting the actions list accessible with the list property actions.
 * It is possible even tough is discouraged to override the footer:
 * in this case the actions property shouldn't be used.
 *
 * @inherits AbstractCard
 * @since 2.4
 */
Kirigami.AbstractCard {
    id: root

    /**
     * actions: list<Action>
     * if the card should provide clickable actions, put them in this property,
     * they will be put in the footer as a list of ToolButtons plus an optional
     * overflow menu, when not all of them will fit in the available Card width.
     */
    property list<QtObject> actions

    /**
    * actions: hiddenActions<Action>
    * This list of actions is for those you always want in the menu, even if there
    * is enough space.
    * @since 2.6
    */
    property list<QtObject> hiddenActions

    /**
     * banner: grouped
     * Gropuped property to control the banner image present in the header, it
     * has the following sub properties:
     * * url imageSource: the source for the image, it understands any url
     *                    valid for an Image component
     * * string title: the title for the banner, shown as contrasting
     *                 text over the image
     * * Qt.Alignment titleAlignment: the alignment of the title inside the image,
     *                           a combination of flags is supported
     *                           (default: Qt.AlignTop | Qt.AlignLeft)
     * * string iconSource: the optional icon to put in the banner:
     *                      it can be either a freedesktop-compatible icon name (recommended)
     *                      or any url supported by Image
     * * Image.FillMode fillMode: see the fillMode property of the Image component (default: Image.PreserveAspectCrop)
     */
    readonly property alias banner: bannerGroup

    header: BannerImage {
        id: bannerImage
        BannerGroup {
            id: bannerGroup
        }
        anchors.leftMargin: -root.leftPadding
        anchors.topMargin: -root.topPadding
        anchors.rightMargin: root.headerOrientation == Qt.Vertical ? -root.rightPadding : 0
        anchors.bottomMargin: root.headerOrientation == Qt.Horizontal ? -root.bottomPadding : 0
        title: bannerGroup.title
        source: bannerGroup.imageSource
        titleAlignment: bannerGroup.titleAlignment
        titleIcon: bannerGroup.iconSource
        fillMode: bannerGroup.fillMode
        height: Layout.preferredHeight
        
    }

    onHeaderChanged: {
        if (!header) {
            return;
        }

        header.anchors.leftMargin = Qt.binding(function() {return -root.leftPadding});
        header.anchors.topMargin = Qt.binding(function() {return  -root.topPadding});
        header.anchors.rightMargin = Qt.binding(function() {return root.headerOrientation == Qt.Vertical ? -root.rightPadding : 0});
        header.anchors.bottomMargin = Qt.binding(function() {return root.headerOrientation == Qt.Horizontal ? -root.bottomPadding : 0});
    }

    footer: Kirigami.ActionToolBar {
        id: actionsToolBar
        actions: root.actions
        hiddenActions: root.hiddenActions
        visible: root.footer == actionsToolBar
    }
}
