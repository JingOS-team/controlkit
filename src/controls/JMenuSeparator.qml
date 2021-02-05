/*
 * Copyright 2021 Rui Wang <wangrui@jingos.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import org.kde.kirigami 2.0
import QtQuick.Controls 2.14 as QQC2
import org.kde.kirigami 2.0 as Kirigami
import org.kde.kirigami 2.15

QQC2.MenuSeparator {
    id: controlRoot

    anchors.horizontalCenter: parent.horizontalCenter

    topPadding: 1
    bottomPadding: 1
    
    implicitHeight: topPadding + bottomPadding + separator.implicitHeight
    width: parent.width - ConstValue.jingUnit*4.5

    contentItem: Rectangle{
        id: separator

        anchors.centerIn: controlRoot
        width: controlRoot.width
        implicitHeight: Units.devicePixelRatio
        
        color: "#FF000000"
        opacity: 0.2
    }
}



