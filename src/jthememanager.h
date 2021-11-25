/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#ifndef JTHEMEMANAGER_H
#define JTHEMEMANAGER_H

#include <QObject>

class QStandardItemModel;
class JThemeManagerPrivate;
class JThemeManager : public QObject
{
    Q_OBJECT
    Q_DECLARE_PRIVATE(JThemeManager)
    Q_PROPERTY(QStandardItemModel *themeModel READ themeModel CONSTANT)
    Q_PROPERTY(QString themeName READ themeName WRITE setThemeName NOTIFY themeNameChanged)


public:
    enum Roles{
      PluginNameRole = Qt::UserRole + 1,
        ScreenshotRole,
        FullScreenPreviewRole,
        DescriptionRole,
        HasSplashRole,
        HasLockScreenRole,
        HasRunCommandRole,
        HasLogoutRole,
        HasColorsRole,
        HasWidgetStyleRole,
        HasIconsRole,
        HasPlasmaThemeRole,
        HasCursorsRole,
        HasWindowSwitcherRole,
        HasDesktopSwitcherRole
    };
    explicit JThemeManager(QObject *parent = nullptr);
    ~JThemeManager();

    Q_INVOKABLE void loadModel();
    Q_INVOKABLE void saveTheme();

    QStandardItemModel *themeModel() const;
    Q_INVOKABLE int pluginIndex(const QString& pluginName);
    Q_INVOKABLE void reloadModel();
    void setColors(const QString&scheme, const QString& colorFile);
    void setIcons(const QString& theme);
    void setPlasmaTheme(const QString& theme);

    QString themeName() const;
    void setThemeName(const QString& name);

Q_SIGNALS:
    void themePackageChanged();
    void themeNameChanged();

protected:
    QScopedPointer<JThemeManagerPrivate> d_ptr;
private:
    void saveKdeTheme();
    void setKdeColors(const QString&scheme, const QString& colorFile, const QString& theme);
};

#endif // JTHEMEMANAGER_H
