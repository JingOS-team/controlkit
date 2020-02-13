/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef ENUMS_H
#define ENUMS_H

#include <QObject>

class ApplicationHeaderStyle : public QObject
{
    Q_OBJECT

public:
    enum Status {
        Auto = 0,
        Breadcrumb,
        Titles,
        TabBar,
        ToolBar, ///@since 5.48
        None ///@since 5.48
    };
    Q_ENUM(Status)

    enum NavigationButton {
        NoNavigationButtons = 0,
        ShowBackButton = 0x1,
        ShowForwardButton = 0x2
    };
    Q_ENUM(NavigationButton)
    Q_DECLARE_FLAGS(NavigationButtons, NavigationButton)
};

class MessageType : public QObject
{
    Q_OBJECT
    Q_ENUMS(Type)

public:
    enum Type {
        Information = 0,
        Positive,
        Warning,
        Error
    };
};

#endif // ENUMS_H
