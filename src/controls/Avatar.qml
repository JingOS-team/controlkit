/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.13
import org.kde.kirigami 2.13 as Kirigami
import QtQuick.Controls 2.13 as QQC2
import org.kde.kirigami.private 2.13

import "templates/private" as P

/**
 * An element that represents a user, either with initials, an icon, or a profile image.
 */
QQC2.Control {
    id: avatarRoot

    enum ImageMode {
        AlwaysShowImage,
        AdaptiveImageOrInitals,
        AlwaysShowInitials
    }
    enum InitialsMode {
        UseInitials,
        UseIcon
    }

    /**
    * The given name of a user.
    *
    * The user's name will be used for generating initials.
    */
    property string name

    /**
    * The source of the user's profile picture; an image.
    */
    property alias source: avatarImage.source

    /**
    * How the button should represent the user when there is no image available.
    * * `UseInitials` - Use initials when the image is not available
    * * `UseIcon` - Use an icon of a user when the image is not available
    */
    property int initialsMode: Kirigami.Avatar.InitialsMode.UseInitials

    /**
    * Whether the button should always show the image; show the image if one is
    * available and show initials when it is not; or always show initials.
    * * `AlwaysShowImage` - Always show the image; even if is not value
    * * `AdaptiveImageOrInitals` - Show the image if it is valid; or show initials if it is not
    * * `AlwaysShowInitials` - Always show initials
    */
    property int imageMode: Kirigami.Avatar.ImageMode.AdaptiveImageOrInitals

     /**
     * Whether or not the image loaded from the provided source should be cached.
     *
     */
     property alias cache: avatarImage.cache

    /**
    * The source size of the user's profile picture.
    */
    property alias sourceSize: avatarImage.sourceSize

    /**
    * Whether or not the image loaded from the provided source should be smoothed.
    */
    property alias smooth: avatarImage.smooth

    /**
     * color: color
     *
     * The color to use for this avatar.
     */
    property var color: undefined
    // We use a var instead of a color here to allow setting the colour
    // as undefined, which will result in a generated colour being used.

    property P.BorderPropertiesGroup border: P.BorderPropertiesGroup {
        width: 1
        color: Qt.rgba(0,0,0,0.2)
    }

    padding: 0
    horizontalPadding: padding
    verticalPadding: padding
    leftPadding: horizontalPadding
    rightPadding: horizontalPadding
    topPadding: verticalPadding
    bottomPadding: verticalPadding

    implicitWidth: Kirigami.Units.iconSizes.large
    implicitHeight: Kirigami.Units.iconSizes.large

    background: Rectangle {
        radius: parent.width / 2

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Qt.lighter(__private.backgroundColor, 1.1)
            }
            GradientStop {
                position: 1.0
                color: Qt.darker(__private.backgroundColor, 1.1)
            }
        }
    }

    QtObject {
        id: __private
        // This property allows us to fall back to colour generation if
        // the root colour property is undefined.
        property color backgroundColor: {
            if (!!avatarRoot.color) {
                return avatarRoot.color
            }
            return AvatarPrivate.colorsFromString(name)
        }
        property color textColor: Kirigami.ColorUtils.brightnessForColor(__private.backgroundColor) == Kirigami.ColorUtils.Light
                                ? "black"
                                : "white"
        property bool showImage: {
            return (avatarRoot.imageMode == Kirigami.Avatar.ImageMode.AlwaysShowImage) ||
                   (avatarImage.status == Image.Ready && avatarRoot.imageMode == Kirigami.Avatar.ImageMode.AdaptiveImageOrInitals)
        }
    }

    contentItem: Item {
        Text {
            id: avatarText
            font.pointSize: 999 // Maximum point size, not actual point size
            fontSizeMode: Text.Fit
            visible: avatarRoot.initialsMode == Kirigami.Avatar.InitialsMode.UseInitials &&
                    !__private.showImage &&
                    !AvatarPrivate.stringUnsuitableForInitials(avatarRoot.name)

            text: AvatarPrivate.initialsFromString(name)
            color: __private.textColor

            anchors.fill: parent
            padding: Math.round(avatarRoot.height/8) // leftPadding plus rightPadding is avatarRoot.height/4
            verticalAlignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            // Change this to Text.QtRendering if people start wanting to animate the size of avatars
            // or expose renderType as an alias property of Avatar.
            renderType: Text.NativeRendering
        }
        Kirigami.Icon {
            visible: (avatarRoot.initialsMode == Kirigami.Avatar.InitialsMode.UseIcon && !__private.showImage) ||
                    (AvatarPrivate.stringUnsuitableForInitials(avatarRoot.name) && !__private.showImage)

            source: "user"

            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing

            color: __private.textColor
        }
        Image {
            id: avatarImage
            visible: false

            mipmap: true
            smooth: true
            sourceSize {
                width: avatarImage.width
                height: avatarImage.height
            }

            fillMode: Image.PreserveAspectFit
            anchors.fill: parent
        }
        Kirigami.ShadowedTexture {
            visible: __private.showImage

            radius: width / 2
            anchors.fill: parent

            source: avatarImage
        }
        Rectangle {
            color: "transparent"

            radius: width / 2
            anchors.fill: parent

            border {
                width: avatarRoot.border.width
                color: avatarRoot.border.color
            }
        }
    }
}
