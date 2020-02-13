/*
 *  SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2016 Aleix Pol Gonzalez <aleixpol@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4

/**
 * A visual separator
 *
 * Useful for splitting one set of items from another.
 *
 * @inherit QtQuick.Rectangle
 */

Rectangle {
    height: Math.floor(Units.devicePixelRatio)
    width: Math.floor(Units.devicePixelRatio)
    Layout.preferredWidth: Math.floor(Units.devicePixelRatio)
    Layout.preferredHeight: Math.floor(Units.devicePixelRatio)
    color: Qt.tint(Theme.textColor, Qt.rgba(Theme.backgroundColor.r, Theme.backgroundColor.g, Theme.backgroundColor.b, 0.8))
}
