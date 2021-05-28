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

#ifndef JWALLPAPERSETTINGS_H
#define JWALLPAPERSETTINGS_H

#include <QObject>

class JWallPaperSettings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString localeName READ localeName NOTIFY localeNameChanged)
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

    QString localeName() const;
    void setLocaleName(const QString& v);

Q_SIGNALS:
    void sigSetWallPaperFinished(bool success);
    void localeNameChanged();
private:
    QString m_nLocaleName;
};

#endif // JWALLPAPERSETTINGS_H
