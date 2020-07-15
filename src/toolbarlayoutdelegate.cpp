/*
 * SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 * 
 * SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

#include "toolbarlayoutdelegate.h"

#include "toolbarlayout.h"

ToolBarLayoutDelegate::ToolBarLayoutDelegate(ToolBarLayout* parent)
    : m_parent(parent)
{
}

ToolBarLayoutDelegate::~ToolBarLayoutDelegate()
{
}

QObject * ToolBarLayoutDelegate::action() const
{
    return m_action;
}

void ToolBarLayoutDelegate::setAction(QObject* action)
{
    if (action == m_action) {
        return;
    }

    if (m_action) {
        QObject::disconnect(m_action, SIGNAL(visibleChanged()), m_parent, SLOT(relayout()));
        QObject::disconnect(m_action, SIGNAL(displayHintChanged()), m_parent, SLOT(relayout()));
    }

    m_action = action;
    if (m_action) {
        if (m_action->property("visible").isValid()) {
            QObject::connect(m_action, SIGNAL(visibleChanged()), m_parent, SLOT(relayout()));
            m_actionVisible = m_action->property("visible").toBool();
        }

        if (m_action->property("displayHint").isValid()) {
            QObject::connect(m_action, SIGNAL(displayHintChanged()), m_parent, SLOT(relayout()));
            m_displayHint = DisplayHint::DisplayHints{m_action->property("displayHint").toUInt()};
        }
    }
}

void ToolBarLayoutDelegate::setFull(QQuickItem* full)
{
    if (full == m_full) {
        return;
    }

    if (m_full) {
        QObject::disconnect(m_full, &QQuickItem::widthChanged, m_parent, &ToolBarLayout::relayout);
        QObject::disconnect(m_full, &QQuickItem::heightChanged, m_parent, &ToolBarLayout::relayout);
        QObject::disconnect(m_full, &QQuickItem::visibleChanged, m_parent, &ToolBarLayout::relayout);
    }

    m_full = full;
    if (m_full) {
        QObject::connect(m_full, &QQuickItem::widthChanged, m_parent, &ToolBarLayout::relayout);
        QObject::connect(m_full, &QQuickItem::heightChanged, m_parent, &ToolBarLayout::relayout);
        QObject::connect(m_full, &QQuickItem::visibleChanged, m_parent, &ToolBarLayout::relayout);
    }
}

void ToolBarLayoutDelegate::setIcon(QQuickItem* icon)
{
    if (icon == m_icon) {
        return;
    }

    if (m_icon) {
        QObject::disconnect(m_icon, &QQuickItem::widthChanged, m_parent, &ToolBarLayout::relayout);
        QObject::disconnect(m_icon, &QQuickItem::heightChanged, m_parent, &ToolBarLayout::relayout);
    }

    m_icon = icon;
    if (m_icon) {
        QObject::connect(m_icon, &QQuickItem::widthChanged, m_parent, &ToolBarLayout::relayout);
        QObject::connect(m_icon, &QQuickItem::heightChanged, m_parent, &ToolBarLayout::relayout);
    }
}

bool ToolBarLayoutDelegate::isActionVisible() const
{
    return m_actionVisible;
}

bool ToolBarLayoutDelegate::isHidden() const
{
    return (m_displayHint & DisplayHint::AlwaysHide);
}

bool ToolBarLayoutDelegate::isIconOnly() const
{
    return (m_displayHint & DisplayHint::IconOnly);
}

bool ToolBarLayoutDelegate::isKeepVisible() const
{
    return (m_displayHint & DisplayHint::KeepVisible);
}

bool ToolBarLayoutDelegate::isVisible() const
{
    return m_visible;
}

void ToolBarLayoutDelegate::hide()
{
    m_visible = false;
    m_full->setProperty("visible", false);
    m_icon->setProperty("visible", false);
}

void ToolBarLayoutDelegate::showFull()
{
    m_visible = true;
    m_full->setProperty("visible", true);
    m_icon->setProperty("visible", false);
}

void ToolBarLayoutDelegate::showIcon()
{
    m_visible = true;
    m_full->setProperty("visible", false);
    m_icon->setProperty("visible", true);
}

void ToolBarLayoutDelegate::setPosition(qreal x, qreal y)
{
    m_full->setX(x);
    m_icon->setX(x);
    m_full->setY(y);
    m_icon->setY(y);
}

qreal ToolBarLayoutDelegate::width() const
{
    if (m_icon->isVisible()) {
        return m_icon->width();
    }
    return m_full->width();
}

qreal ToolBarLayoutDelegate::height() const
{
    if (m_icon->isVisible()) {
        return m_icon->height();
    }
    return m_full->height();
}

qreal ToolBarLayoutDelegate::maxHeight() const
{
    return std::max(m_full->height(), m_icon->height());
}

qreal ToolBarLayoutDelegate::iconWidth() const
{
    return m_icon->width();
}

qreal ToolBarLayoutDelegate::fullWidth() const
{
    return m_full->width();
}

void ToolBarLayoutDelegate::beginLayout()
{
    auto visible = m_action->property("visible");
    if (visible.isValid()) {
        m_actionVisible = visible.toBool();
    }
    m_displayHint = DisplayHint::DisplayHints{m_action->property("displayHint").toUInt()};
}

void ToolBarLayoutDelegate::endLayout()
{
}
