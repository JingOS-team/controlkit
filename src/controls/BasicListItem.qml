/*
 *  SPDX-FileCopyrightText: 2010 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0 as QQC2
import org.kde.kirigami 2.12

/**
 * A BasicListItem provides a simple list item design that can handle the
 * most common list item usecases.
 *
 * @image html BasicListItemTypes.svg "The styles of the BasicListItem. From left to right top to bottom: light icon + title + subtitle, dark icon + title + subtitle, light icon + label, dark icon + label, light label, dark label." width=50%
 */
AbstractListItem {
    id: listItem

    /**
     * label: string
     *
     * The label of this list item. If a subtitle is provided, the label will
     * behave as a title and will have a bold font. Every list item should have
     * a label.
     */
    property alias label: listItem.text

    /**
     * subtitle: string
     *
     * An optional subtitle that can appear under the label.
     *
     * @since 5.70
     * @since org.kde.kirigami 2.12
     */
    property alias subtitle: subtitleItem.text

    /**
     * bold: bool
     *
     * Whether the list item's text (both label and subtitle, if provided) should
     * render in bold.
     *
     * @since 5.71
     * @since org.kde.kirigami 2.13
     */
    property bool bold: false

    /**
     * icon: var
     *
     * @code ts
     * interface IconGroup {
     *     name:   string,
     *     source: string,
     *     width:  int,
     *     height: int,
     *     color:  color,
     * }
     * 
     * type Icon = string | IconGroup | URL
     * @endcode
     *
     * The icon that will render on this list item.
     *
     * This can either be an icon name, a URL, or an object with the following properties:
     *
     * - `name`: string
     * - `source`: string
     * - `width`: int
     * - `height`: int
     * - `color`: color
     *
     * If the type of the icon is a string containing an icon name, the icon will be looked up from the
     * platform icon theme.
     *
     * Using an icon object allows you to specify more granular attributes of the icon,
     * such as its color and dimensions.
     *
     * If the icon is a URL, the icon will be attempted to be loaded from the
     * given URL.
     */
    property var icon

    /**
     * iconSize: int
     *
     * The size at which the icon will render at. This will not affect icon lookup,
     * unlike the icon group's width and height properties, which will.
     *
     * @since 2.5
     */
    property alias iconSize: iconItem.size

    /**
     * iconColor: color
     *
     * The color of the icon.
     *
     * If the icon's original colors should be left intact, set this to the default value, "transparent".
     * Note that this colour will only be applied if the icon can be recoloured, (e.g. you can use Kirigami.Theme.foregroundColor to change the icon's colour.)
     *
     * @since 2.7
     */
    property alias iconColor: iconItem.color

    /**
     * reserveSpaceForIcon: bool
     *
     * Whether or not to reserve space for the icon, even if there is no icon.
     *
     * @image html BasicListItemReserve.svg "Left: reserveSpaceForIcon: false. Right: reserveSpaceForIcon: true" width=50%
     *
     */
    property alias reserveSpaceForIcon: iconItem.visible

    /**
     * reserveSpaceForLabel: bool
     *
     * Whether or not the label of the list item should fill width.
     *
     * Setting this to false is useful if you have other items in the list item
     * that should fill width instead of the label.
     *
     */
    property alias reserveSpaceForLabel: labelItem.visible

    default property alias _basicDefault: layout.data

    icon: action ? action.icon.name || action.icon.source : undefined
    contentItem: RowLayout {
        id: layout
        spacing: LayoutMirroring.enabled ? listItem.rightPadding : listItem.leftPadding
        Icon {
            id: iconItem
            source: {
                if (!listItem.icon) {
                    return undefined
                }
                if (listItem.icon.hasOwnProperty) {
                    if (listItem.icon.hasOwnProperty("name") && listItem.icon.name !== "")
                        return listItem.icon.name;
                    if (listItem.icon.hasOwnProperty("source"))
                        return listItem.icon.source;
                }
                return listItem.icon;
            }
            property int size: Units.iconSizes.smallMedium
            Layout.minimumHeight: size
            Layout.maximumHeight: size
            Layout.minimumWidth: size
            selected: (listItem.highlighted || listItem.checked || (listItem.pressed && listItem.supportsMouseEvents))
            opacity: 1
            visible: source != undefined
        }
        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            QQC2.Label {
                id: labelItem
                text: listItem.text
                Layout.fillWidth: true
                color: (listItem.highlighted || listItem.checked || (listItem.pressed && listItem.supportsMouseEvents)) ? listItem.activeTextColor : listItem.textColor
                elide: Text.ElideRight
                font.weight: listItem.bold ? Font.Bold : Font.Normal
                opacity: 1
            }
            QQC2.Label {
                id: subtitleItem
                Layout.fillWidth: true
                color: (listItem.highlighted || listItem.checked || (listItem.pressed && listItem.supportsMouseEvents)) ? listItem.activeTextColor : listItem.textColor
                elide: Text.ElideRight
                font: Theme.smallFont
                opacity: listItem.bold ? 0.9 : 0.7
                visible: text.length > 0
            }
        }
    }
}
