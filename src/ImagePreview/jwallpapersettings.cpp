/*
 * Copyright 2021 Lele Huan <huanlele@jingos.com>
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

#include "jwallpapersettings.h"
#include <QDebug>
#include <QString>
#include <QDir>
#include <QFileInfo>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QLocale>
#define WALLPAPER_DBUS_SERVICE "org.jing.systemui.wallpaper"
#define WALLPAPER_DBUS_PATH "/jing/systemui/wallpaper"
#define WALLPAPER_DBUS_INTERFACE "org.jing.systemui.wallpaper"
#define WALLPAPER_PATH "/home/jingos/Pictures/jingScreen/"
JWallPaperSettings::JWallPaperSettings(QObject *parent) : QObject(parent)
{
    QLocale locale;
    setLocaleName(locale.name());
}

QString JWallPaperSettings::getWallPaperPath(const QString& originPath)
{
    QString paperPath = originPath;
    QString prefixPath = QString(QStringLiteral("file://"));
    if(paperPath.startsWith(prefixPath)){
        paperPath = paperPath.mid(7);
    }


    QFileInfo lt(paperPath);
    QStringList sqlits = lt.fileName().split(QString(QStringLiteral(".")));

    QString locationPath = lt.path();
    QString suffix = sqlits.size() > 0 ? QString(QStringLiteral(".")) + sqlits.last() : QString(QStringLiteral(""));
    QString newFileName =  lt.fileName().replace(suffix, QString(QStringLiteral("")));
    newFileName = newFileName + QString(QStringLiteral("_clip"));

    QString newFilePath = QString(QStringLiteral(WALLPAPER_PATH)) + newFileName;
    QDir dir(QString(QStringLiteral(WALLPAPER_PATH)));
    if(dir.exists() == false){
       bool rv = dir.mkpath(QString(QStringLiteral(WALLPAPER_PATH)));
       if(rv == false){
           qWarning() << "mkpath " << QString(QStringLiteral(WALLPAPER_PATH)) << "  false use origin path ";
            newFilePath = locationPath + QString(QStringLiteral("/")) + newFileName;
       }
    }

    int cur = 1;
    QString updatedPath = newFilePath + suffix;
    QFileInfo check(newFilePath + suffix);
    while (check.exists()) {
        updatedPath = QString(QStringLiteral("%1_%2%3")).arg(newFilePath, QString::number(cur), suffix);
        check = QFileInfo(updatedPath);
        cur++;
    }
    qDebug() << Q_FUNC_INFO << " updatedPath  is " << updatedPath;
    return updatedPath;
}

void JWallPaperSettings::setWallPaper(JWallPaperSettings::WallPaperType type, const QString &path)
{

    QString method = QString(QLatin1String("setWallpaper"));

    QDBusMessage message = QDBusMessage::createMethodCall(QStringLiteral(WALLPAPER_DBUS_SERVICE),
                                                          QStringLiteral(WALLPAPER_DBUS_PATH),
                                                          QStringLiteral(WALLPAPER_DBUS_INTERFACE),
                                                          method);

    QString paperPath = path;
    qint32 paperType = (qint32)type;

    if(paperPath.startsWith(QString(QStringLiteral("file://"))) == false){
        paperPath = QString(QStringLiteral("file://")) + paperPath;
    }

    qDebug() << Q_FUNC_INFO << " type is " << paperType << "  path is " << paperPath;

    message << paperType;
    message << paperPath;

    QDBusMessage response = QDBusConnection::sessionBus().call(message);

    if (response.type() == QDBusMessage::ReplyMessage){
//        int value = response.arguments().takeFirst().toInt();
//        qDebug() << "value =" << value;
        Q_EMIT sigSetWallPaperFinished(true);
    } else {
        qDebug() << "value method called failed! " << response.type() << response.errorMessage();
        Q_EMIT sigSetWallPaperFinished(false);
    }
}

QString JWallPaperSettings::localeName() const
{
    return m_nLocaleName;
}

void JWallPaperSettings::setLocaleName(const QString &v)
{
    if(m_nLocaleName != v){
        m_nLocaleName = v;
        Q_EMIT localeNameChanged();
    }
}
