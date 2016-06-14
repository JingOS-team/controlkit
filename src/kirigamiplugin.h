/*
 *   Copyright 2009 by Alan Alpert <alan.alpert@nokia.com>
 *   Copyright 2010 by Ménard Alexis <menard@kde.org>
 *   Copyright 2010 by Marco Martin <mart@kde.org>

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

#ifndef MOBILECOMPONENTSPLUGIN_H
#define MOBILECOMPONENTSPLUGIN_H

#ifdef KIRIGAMI_BUILD_TYPE_STATIC
#include <QObject>
#include <QString>
#include <QUrl>
#else
#include <QQmlEngine>
#include <QQmlExtensionPlugin>
#include <QUrl>
#endif

class AbstractKirigamiPlugin : public QObject
{
    Q_OBJECT
public:
    virtual void registerTypes(const char *uri) = 0;

protected:
    virtual QUrl componentPath(const QString &fileName) const = 0;
    virtual QString resolveFilePath(const QString &path) const = 0;
    virtual QUrl resolveFileUrl(const QString &filePath) const = 0;

    QStringList m_stylesFallbackChain;

};

#ifdef KIRIGAMI_BUILD_TYPE_STATIC

class KirigamiPlugin : public AbstractKirigamiPlugin
{
public:
    static KirigamiPlugin& getInstance()
    {
        static KirigamiPlugin instance;
        return instance;
    }
    KirigamiPlugin(KirigamiPlugin const&) = delete;
    void operator=(KirigamiPlugin const&) = delete;
    void registerTypes(const char *uri);
    static void registerTypes()
    {
        getInstance().registerTypes("org.kde.kirigami");
    }

private:
    KirigamiPlugin() {}
    QUrl componentPath(const QString &fileName) const;
    QString resolveFilePath(const QString &path) const
    {
        return QLatin1Char(':') + path;
    }
    QUrl resolveFileUrl(const QString &filePath) const
    {
        if (filePath.startsWith(QLatin1Char(':'))) {
            return QUrl(QStringLiteral("qrc:") + filePath.right(filePath.length() - 1));
        }
        return QUrl(QStringLiteral("qrc:/") + filePath);
    }
};

#else

class KirigamiPlugin : public AbstractKirigamiPlugin, public QQmlExtensionPlugin
{
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri);

private:
    QUrl componentPath(const QString &fileName) const;
    QString resolveFilePath(const QString &path) const
    {
        return baseUrl().path() + QLatin1Char('/') + path;
    }
    QUrl resolveFileUrl(const QString &filePath) const
    {
        return QUrl(baseUrl().toString() + QLatin1Char('/') + filePath);
    }
};

#endif

#endif
