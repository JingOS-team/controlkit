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

namespace DisplayHint
{
    Q_NAMESPACE

    /**
     * Hints for implementations using Actions indicating preferences about how to display the action.
     */
    enum DisplayHint {
        /**
         * Indicates there is no specific preference.
         */
        NoPreference = 0,
        /**
         * Only display an icon for this Action.
         */
        IconOnly = 1,
        /**
         * Try to keep the action visible even when space constrained.
         * Mutually exclusive with AlwaysHide, KeepVisible has priority.
         */
        KeepVisible = 2,
        /**
         * If possible, hide the action in an overflow menu or similar location.
         * Mutually exclusive with KeepVisible, KeepVisible has priority.
         */
        AlwaysHide = 4,
        /**
         * When this action has children, do not display any indicator (like a
         * menu arrow) for this action.
         */
        HideChildIndicator = 8
    };
    Q_DECLARE_FLAGS(DisplayHints, DisplayHint)
    Q_FLAG_NS(DisplayHints)
}

Q_DECLARE_OPERATORS_FOR_FLAGS(DisplayHint::DisplayHints)

#endif // ENUMS_H
