/*
 *   Copyright 2016 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "settings.h"

#include <QDebug>

Settings::Settings(QObject *parent)
    : QObject(parent)
{
#if defined(Q_OS_IOS) || defined(Q_OS_ANDROID) || defined(Q_OS_BLACKBERRY) || defined(Q_OS_QNX) || defined(Q_OS_WINRT)
    m_mobile = true;
#else
    m_mobile = qEnvironmentVariableIsSet("QT_QUICK_CONTROLS_MOBILE") &&
        (QString::fromLatin1(qgetenv("QT_QUICK_CONTROLS_MOBILE")) == QStringLiteral("1") ||
         QString::fromLatin1(qgetenv("QT_QUICK_CONTROLS_MOBILE")) == QStringLiteral("true"));
#endif
}


Settings::~Settings()
{
}

void Settings::setIsMobile(bool mobile)
{
    if (mobile != m_mobile) {
        return;
    }

    m_mobile = mobile;
    emit isMobileChanged();
}

bool Settings::isMobile() const
{
    return m_mobile;
}

QString Settings::style() const
{
    return m_style;
}

void Settings::setStyle(const QString &style)
{
    m_style = style;
}

#include "moc_settings.cpp"

