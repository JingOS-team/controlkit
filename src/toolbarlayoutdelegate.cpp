/*
 * SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 * 
 * SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

#include "toolbarlayoutdelegate.h"

#include "toolbarlayout.h"

ToolBarLayoutDelegate::ToolBarLayoutDelegate(ToolBarLayout* parent)
    : QObject() // Note: delegates are managed by unique_ptr, so don't parent
    , m_parent(parent)
{
}

ToolBarLayoutDelegate::~ToolBarLayoutDelegate()
{
    if (m_full) {
        delete m_full;
    }
    if (m_icon) {
        delete m_icon;
    }
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
        QObject::disconnect(m_action, SIGNAL(visibleChanged()), this, SLOT(actionVisibleChanged()));
        QObject::disconnect(m_action, SIGNAL(displayHintChanged()), this, SLOT(displayHintChanged()));
    }

    m_action = action;
    if (m_action) {
        if (m_action->property("visible").isValid()) {
            QObject::connect(m_action, SIGNAL(visibleChanged()), this, SLOT(actionVisibleChanged()));
            m_actionVisible = m_action->property("visible").toBool();
        }

        if (m_action->property("displayHint").isValid()) {
            QObject::connect(m_action, SIGNAL(displayHintChanged()), this, SLOT(displayHintChanged()));
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
        m_full->disconnect(this);
    }

    m_full = full;
    if (m_full) {
        QObject::connect(m_full, &QQuickItem::widthChanged, this, [this]() { m_parent->relayout(); });
        QObject::connect(m_full, &QQuickItem::heightChanged, this, [this]() { m_parent->relayout(); });
        QObject::connect(m_full, &QQuickItem::visibleChanged, this, [this]() { ensureItemVisibility(); });
    }
}

void ToolBarLayoutDelegate::setIcon(QQuickItem* icon)
{
    if (icon == m_icon) {
        return;
    }

    if (m_icon) {
        m_icon->disconnect(this);
    }

    m_icon = icon;
    if (m_icon) {
        QObject::connect(m_icon, &QQuickItem::widthChanged, this, [this]() { m_parent->relayout(); });
        QObject::connect(m_icon, &QQuickItem::heightChanged, this, [this]() { m_parent->relayout(); });
        QObject::connect(m_icon, &QQuickItem::visibleChanged, this, [this]() { ensureItemVisibility(); });
    }
}

bool ToolBarLayoutDelegate::isActionVisible() const
{
    return m_actionVisible;
}

bool ToolBarLayoutDelegate::isHidden() const
{
    return DisplayHint::isDisplayHintSet(m_displayHint, DisplayHint::AlwaysHide);
}

bool ToolBarLayoutDelegate::isIconOnly() const
{
    return DisplayHint::isDisplayHintSet(m_displayHint, DisplayHint::IconOnly);
}

bool ToolBarLayoutDelegate::isKeepVisible() const
{
    return DisplayHint::isDisplayHintSet(m_displayHint, DisplayHint::KeepVisible);
}

bool ToolBarLayoutDelegate::isVisible() const
{
    return m_iconVisible || m_fullVisible;
}

void ToolBarLayoutDelegate::hide()
{
    m_iconVisible = false;
    m_fullVisible = false;
    ensureItemVisibility();
}

void ToolBarLayoutDelegate::showFull()
{
    m_iconVisible = false;
    m_fullVisible = true;
    ensureItemVisibility();
}

void ToolBarLayoutDelegate::showIcon()
{
    m_iconVisible = true;
    m_fullVisible = false;
    ensureItemVisibility();
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

void ToolBarLayoutDelegate::actionVisibleChanged()
{
    m_actionVisible = m_action->property("visible").toBool();
    m_parent->relayout();
}

void ToolBarLayoutDelegate::displayHintChanged()
{
    m_displayHint = DisplayHint::DisplayHints{m_action->property("displayHint").toUInt()};
    m_parent->relayout();
}

