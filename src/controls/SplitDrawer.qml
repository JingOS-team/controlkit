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

import QtQuick 2.1
import "templates" as T

/**
 * Split Drawers are used to expose additional UI elements which are optional
 * and can be used in conjunction with the main UI elements.
 * For example the Resource Browser uses a Split Drawer to select
 * different kinds of filters for the main view.
 */
T.SplitDrawer {
    id: root

//BEGIN Properties
    //NOTE: Only property documentation here, no definition/implementation
    /**
     * page: Item
     * It's the default property. it's the main content of the drawer page,
     * the part that is always shown
     */

    /**
     * contentItem: Item
     * It's the part that can be pulled in and out, will act as a sidebar.
     */

    /**
     * opened: bool
     * If true the drawer is open showing the contents of the "drawer"
     * component.
     */

    /**
     * position: real
     * This property holds the position of the drawer relative to its
     * final destination. That is, the position will be 0 when the
     * drawer is fully closed, and 1 when fully open.
     */

    /**
     * modal: bool
     * If true the drawer will be an overlay of the main content,
     * obscuring it and blocking input.
     * If false, the drawer will look like a sidebar, with the main content
     * application still usable.
     * It is recomended to use modal on mobile devices and not modal on desktop
     * devices.
     * Default is true
     */
//END Properties
}

