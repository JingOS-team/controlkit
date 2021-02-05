/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "formlayoutattached.h"
#include <QQuickItem>
#include <QDebug>

FormLayoutAttached::FormLayoutAttached(QObject *parent)
    : QObject(parent)
{
    m_buddyFor = qobject_cast<QQuickItem *>(parent);
}

FormLayoutAttached::~FormLayoutAttached()
{
}

void FormLayoutAttached::setLabel(const QString &text)
{
    if (m_label == text) {
        return;
    }

    m_label = text;
    Q_EMIT labelChanged();
}

QString FormLayoutAttached::label() const
{
    return m_label;
}

void FormLayoutAttached::setLabelAlignment(int section)
{
	if (m_labelAlignment == section) {
		return;
	}

	m_labelAlignment = section;
	Q_EMIT labelAlignmentChanged();
}

int FormLayoutAttached::labelAlignment() const
{
	return m_labelAlignment;
}

void FormLayoutAttached::setIsSection(bool section)
{
    if (m_isSection == section) {
        return;
    }

    m_isSection = section;
    Q_EMIT isSectionChanged();
}

bool FormLayoutAttached::isSection() const
{
    return m_isSection;
}

void FormLayoutAttached::setCheckable(bool checkable)
{
    if (checkable == m_checkable) {
        return;
    }

    m_checkable = checkable;
    Q_EMIT checkableChanged();
}

bool FormLayoutAttached::checkable() const
{
    return m_checkable;
}

void FormLayoutAttached::setChecked(bool checked)
{
    if (checked == m_checked) {
        return;
    }

    m_checked = checked;
    Q_EMIT checkedChanged();
}

bool FormLayoutAttached::checked() const
{
    return m_checked;
}

void FormLayoutAttached::setEnabled(bool enabled)
{
    if (enabled == m_enabled) {
        return;
    }

    m_enabled = enabled;
    Q_EMIT enabledChanged();
}

bool FormLayoutAttached::enabled() const
{
    return m_enabled;
}

QQuickItem *FormLayoutAttached::buddyFor() const
{
    return m_buddyFor;
}

void FormLayoutAttached::setBuddyFor(QQuickItem *buddyfor)
{
    if (m_buddyFor == buddyfor || !m_buddyFor->isAncestorOf(buddyfor)) {
        return;
    }

    m_buddyFor = buddyfor;
    Q_EMIT buddyForChanged();
}

FormLayoutAttached *FormLayoutAttached::qmlAttachedProperties(QObject *object)
{
    return new FormLayoutAttached(object);
}

#include "moc_formlayoutattached.cpp"
