/*
*   Copyright 2018 Marco Martin <mart@kde.org>
*
*   This program is free software; you can redistribute it and/or modify
*   it under the terms of the GNU Library General Public License as
*   published by the Free Software Foundation; either version 2, or
*   (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU Library General Public License for more details
*
*   You should have received a copy of the GNU Library General Public
*   License along with this program; if not, write to the
*   Free Software Foundation, Inc.,
*   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#include "tabletmodewatcher.h"

#if defined(KIRIGAMI_ENABLE_DBUS)
#include "tabletmodemanager_interface.h"
#include <QDBusConnection>
#endif

//TODO: All the dbus stuff should be conditional, optional win32 support

namespace Kirigami {

class TabletModeWatcherSingleton
{
public:
    TabletModeWatcher self;
};

Q_GLOBAL_STATIC(TabletModeWatcherSingleton, privateTabletModeWatcherSelf)


class TabletModeWatcherPrivate
{
public:
    TabletModeWatcherPrivate(TabletModeWatcher *watcher)
        : q(watcher)
    {

#if !defined(KIRIGAMI_ENABLE_DBUS) && (defined(Q_OS_ANDROID) || defined(Q_OS_IOS))
        isTabletModeAvailable = true;
        isTabletMode = true;
#elif defined(KIRIGAMI_ENABLE_DBUS)
        //Mostly for debug purposes and for platforms which are always mobile,
        //such as Plasma Mobile
        if (qEnvironmentVariableIsSet("QT_QUICK_CONTROLS_MOBILE") ||
            qEnvironmentVariableIsSet("KDE_KIRIGAMI_TABLET_MODE")) {
            isTabletMode = (QString::fromLatin1(qgetenv("QT_QUICK_CONTROLS_MOBILE")) == QStringLiteral("1") ||
                QString::fromLatin1(qgetenv("QT_QUICK_CONTROLS_MOBILE")) == QStringLiteral("true")) ||
                (QString::fromLatin1(qgetenv("KDE_KIRIGAMI_TABLET_MODE")) == QStringLiteral("1") ||
                QString::fromLatin1(qgetenv("KDE_KIRIGAMI_TABLET_MODE")) == QStringLiteral("true"));
            isTabletModeAvailable = isTabletMode;
        } else {
            m_interface = new OrgKdeKWinTabletModeManagerInterface(QStringLiteral("org.kde.KWin"), QStringLiteral("/org/kde/KWin"), QDBusConnection::sessionBus(), q);

            if (m_interface->isValid()) {
                //NOTE: the initial call is actually sync, because is better a tiny freeze than having the ui always recalculated and changed at the start
                isTabletModeAvailable = m_interface->tabletModeAvailable();
                isTabletMode = m_interface->tabletMode();
                QObject::connect(m_interface, &OrgKdeKWinTabletModeManagerInterface::tabletModeChanged,
                        q, [this](bool tabletMode) {
                    setIsTablet(tabletMode);
                });
                QObject::connect(m_interface, &OrgKdeKWinTabletModeManagerInterface::tabletModeAvailableChanged,
                        q, [this](bool avail) {
                    isTabletModeAvailable = avail;
                    emit q->tabletModeAvailableChanged(avail);
                });
            } else {
                isTabletModeAvailable = false;
                isTabletMode = false;
            }
        }
//TODO: case for Windows
#else
        isTabletModeAvailable = false;
        isTabletMode = false;
#endif
    }
    ~TabletModeWatcherPrivate() {};
    void setIsTablet(bool tablet);

    TabletModeWatcher *q;
#if defined(KIRIGAMI_ENABLE_DBUS)
    OrgKdeKWinTabletModeManagerInterface *m_interface = nullptr;
#endif
    bool isTabletModeAvailable = false;
    bool isTabletMode = false;
};

void TabletModeWatcherPrivate::setIsTablet(bool tablet)
{
    if (isTabletMode == tablet) {
        return;
    }

    isTabletMode = tablet;
    emit q->tabletModeChanged(tablet);
}



TabletModeWatcher::TabletModeWatcher(QObject *parent)
    : QObject(parent),
      d(new TabletModeWatcherPrivate(this))
{
}

TabletModeWatcher::~TabletModeWatcher()
{
    delete d;
}

TabletModeWatcher *TabletModeWatcher::self()
{
    return &privateTabletModeWatcherSelf()->self;
}

bool TabletModeWatcher::isTabletModeAvailable() const
{
    return d->isTabletModeAvailable;
}

bool TabletModeWatcher::isTabletMode() const
{
    return d->isTabletMode;
}

}

#include "moc_tabletmodewatcher.cpp"
