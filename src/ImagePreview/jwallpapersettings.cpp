/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Yu Jiashu <yujiashu@jingos.com>
 *
 */

#include "jwallpapersettings.h"
#include <QDebug>
#include <QString>
#include <QDir>
#include <QFileInfo>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QLocale>
#include <QStandardPaths>
#include <QTime>
#include <QApplication>
#include <KConfigGroup>
#include <KSharedConfig>

#define WALLPAPER_DBUS_SERVICE "org.jing.systemui.wallpaper"
#define WALLPAPER_DBUS_PATH "/jing/systemui/wallpaper"
#define WALLPAPER_DBUS_INTERFACE "org.jing.systemui.wallpaper"
JWallPaperSettings::JWallPaperSettings(QObject *parent) : QObject(parent)
{
    m_nScreenPaperPath = QStandardPaths::writableLocation(QStandardPaths::HomeLocation);
    if(m_nScreenPaperPath.endsWith("/") == false){
        m_nScreenPaperPath += "/";
    }
    m_nScreenPaperPath += ".config/jingWallPaper/";
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

    QString newFilePath = m_nScreenPaperPath + newFileName;
    QDir dir(m_nScreenPaperPath);
    if(dir.exists() == false){
       bool rv = dir.mkpath(m_nScreenPaperPath);
       if(rv == false){
           qWarning() << "mkpath " << m_nScreenPaperPath << "  false use origin path ";
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

    message << paperType;
    message << paperPath;

    QDBusMessage response = QDBusConnection::sessionBus().call(message);

    if (response.type() == QDBusMessage::ReplyMessage){
        Q_EMIT sigSetWallPaperFinished(true);
    } else {
        Q_EMIT sigSetWallPaperFinished(false);
    }
}


