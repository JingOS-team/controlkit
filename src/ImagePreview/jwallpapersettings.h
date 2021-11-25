/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Yu Jiashu <yujiashu@jingos.com>
 *
 */

#ifndef JWALLPAPERSETTINGS_H
#define JWALLPAPERSETTINGS_H

#include <QObject>

class JWallPaperSettings : public QObject
{
    Q_OBJECT
public:
    enum WallPaperType {
        Both = 0,
        HomeScreen = 1,
        LockScreen = 2,
//        Unkown = 0,
//        LockScreen = 0x01,
//        HomeScreen = 0x10,
//        Both = LockScreen | HomeScreen,
    };
    Q_ENUM(WallPaperType)

    explicit JWallPaperSettings(QObject *parent = nullptr);
    Q_INVOKABLE QString getWallPaperPath(const QString& originPath);
    Q_INVOKABLE void setWallPaper(WallPaperType type, const QString& path);

Q_SIGNALS:
    void sigSetWallPaperFinished(bool success);
    void localeNameChanged();
private:
    QString m_nScreenPaperPath;
};

#endif // JWALLPAPERSETTINGS_H
