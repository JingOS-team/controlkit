/*
 * SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 * 
 * SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

#ifndef TOOLBARLAYOUTDELEGATE_H
#define TOOLBARLAYOUTDELEGATE_H

#include <QQuickItem>
#include "enums.h"

class ToolBarLayout;

class ToolBarLayoutDelegate
{
public:
    ToolBarLayoutDelegate(ToolBarLayout *parent);
    ~ToolBarLayoutDelegate();

    QObject *action() const;
    void setAction(QObject *action);
    void setFull(QQuickItem *full);
    void setIcon(QQuickItem *icon);

    bool isActionVisible() const;
    bool isHidden() const;
    bool isIconOnly() const;
    bool isKeepVisible() const;

    bool isVisible() const;

    void hide();
    void showIcon();
    void showFull();

    void setPosition(qreal x, qreal y);

    qreal width() const;
    qreal height() const;
    qreal maxHeight() const;
    qreal iconWidth() const;
    qreal fullWidth() const;

    DisplayHint::DisplayHints displayHint();

    void beginLayout();
    void endLayout();

private:
    ToolBarLayout *m_parent = nullptr;
    QObject *m_action = nullptr;
    QQuickItem *m_full = nullptr;
    QQuickItem *m_icon = nullptr;

    DisplayHint::DisplayHints m_displayHint = DisplayHint::NoPreference;
    bool m_actionVisible = true;
    bool m_visible = true;
};

#endif // TOOLBARLAYOUTDELEGATE_H
