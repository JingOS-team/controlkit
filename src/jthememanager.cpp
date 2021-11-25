/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#include "jthememanager.h"
#include "./ThemePrivate/jthememanager_p.h"

#include <QDebug>
#include <QHash>
#include <QByteArray>
#include <QQmlEngine>
#include <QStandardItemModel>
#define SET_KDE_THEME 1
JThemeManager::JThemeManager(QObject *parent) : QObject(parent)
  , d_ptr(new JThemeManagerPrivate)
{
    d_ptr->q_ptr = this;
    //qmlRegisterType<QStandardItemModel>();
    Q_D(JThemeManager);
    d->m_pModel = new QStandardItemModel(this);

    QHash<int, QByteArray> roles = d->m_pModel->roleNames();
    roles[PluginNameRole] = "pluginName";
    roles[DescriptionRole] = "description";
    roles[ScreenshotRole] = "screenshot";
    roles[FullScreenPreviewRole] = "fullScreenPreview";
    roles[HasSplashRole] = "hasSplash";
    roles[HasLockScreenRole] = "hasLockScreen";
    roles[HasRunCommandRole] = "hasRunCommand";
    roles[HasLogoutRole] = "hasLogout";
    roles[HasColorsRole] = "hasColors";
    roles[HasWidgetStyleRole] = "hasWidgetStyle";
    roles[HasIconsRole] = "hasIcons";
    roles[HasPlasmaThemeRole] = "hasPlasmaTheme";
    roles[HasCursorsRole] = "hasCursors";
    roles[HasWindowSwitcherRole] = "hasWindowSwitcher";
    roles[HasDesktopSwitcherRole] = "hasDesktopSwitcher";

    d->m_pModel->setItemRoleNames(roles);

    d->initData();
    loadModel();
}

JThemeManager::~JThemeManager()
{

}

void JThemeManager::loadModel()
{
    Q_D(JThemeManager);
    d->m_pModel->clear();
    const QList<KPackage::Package> pkgs = d->availablePackages({"defaults", "layouts"});
    for(const KPackage::Package& pkg : pkgs){
        if(pkg.metadata().isValid() == false){
            continue;
        }

        QStandardItem* row = new QStandardItem(pkg.metadata().name());
        row->setData(pkg.metadata().pluginId(), PluginNameRole);
        row->setData(pkg.metadata().description(), DescriptionRole);
        row->setData(pkg.filePath("preview"), ScreenshotRole);
        row->setData(pkg.filePath("fullscreenpreview"), FullScreenPreviewRole);
        //package 提供的内容

        row->setData(pkg.filePath("splashmainscript").isEmpty() == false, HasSplashRole);
        row->setData(pkg.filePath("lockscreenmainscript").isEmpty() == false, HasLockScreenRole);
        row->setData(pkg.filePath("runcommandmainscript").isEmpty() == false, HasRunCommandRole);
        row->setData(pkg.filePath("logoutmainscript").isEmpty() == false, HasLogoutRole);

        if(pkg.filePath("defaults").isEmpty() == false){
            KSharedConfigPtr conf = KSharedConfig::openConfig(pkg.filePath("defaults"));
            KConfigGroup prefixCg(conf, "jingosThemeGlobals");
            if(prefixCg.isValid() == false){
                prefixCg = KConfigGroup(conf, "kdeglobals");
            }
            KConfigGroup cg = KConfigGroup(&prefixCg, "General");

            bool hasColors = !cg.readEntry("ColorScheme", QString()).isEmpty();
            if(hasColors == false){
                hasColors = !pkg.filePath("colors").isEmpty();
            }
            row->setData(hasColors, HasColorsRole);
            {
                cg =  KConfigGroup(&prefixCg, "KDE");
                bool hasWidgetStyle = !cg.readEntry("widgetStyle", QString()).isEmpty();
                row->setData(hasWidgetStyle, HasWidgetStyleRole);

                cg =  KConfigGroup(&prefixCg, "Icons");
                bool hasIcons = !cg.readEntry("Theme", QString()).isEmpty();
                row->setData(hasIcons, HasIconsRole);

                prefixCg =  KConfigGroup(conf, "plasmarc");
                cg =  KConfigGroup(&prefixCg, "Theme");
                bool hasPlasmaTheme = !cg.readEntry("name", QString()).isEmpty();
                row->setData(hasPlasmaTheme, HasPlasmaThemeRole);

                prefixCg =  KConfigGroup(conf, "kcminputrc");
                cg =  KConfigGroup(&prefixCg, "Mouse");
                bool hasCursorTheme = !cg.readEntry("cursorTheme", QString()).isEmpty();
                row->setData(hasCursorTheme, HasCursorsRole);

                prefixCg =  KConfigGroup(conf, "kwinrc");
                cg =  KConfigGroup(&prefixCg, "WindowSwitcher");
                bool hasWindowSwitcher = !cg.readEntry("LayoutName", QString()).isEmpty();
                row->setData(hasWindowSwitcher, HasWindowSwitcherRole);

                cg =  KConfigGroup(&prefixCg, "DesktopSwitcher");
                bool hasDesktopSwitcher = !cg.readEntry("LayoutName", QString()).isEmpty();
                row->setData(hasDesktopSwitcher, HasDesktopSwitcherRole);
            }

        }
        d->m_pModel->appendRow(row);
    }
    d->m_pModel->sort(0);
    Q_EMIT themePackageChanged();
}

void JThemeManager::saveTheme()
{
    Q_D(JThemeManager);
     KPackage::Package package = KPackage::PackageLoader::self()->loadPackage(QStringLiteral("Plasma/LookAndFeel"));
     package.setDefaultPackageRoot("plasma/jingosTheme");
     package.setPath(d->m_nThemePackage);

     if(package.isValid() == false){
        qWarning()<< "Plasma/LookAndFeel  package is unvalid return";
        return;
     }

     if(package.filePath("defaults").isEmpty() == false){
         KSharedConfigPtr conf = KSharedConfig::openConfig(package.filePath("defaults"));
         KConfigGroup prefixCg(conf, "jingosThemeGlobals");

         QString colorsFile = package.filePath("colors");
         KConfigGroup cg = KConfigGroup(&prefixCg, "General");
         QString colorScheme = cg.readEntry("ColorScheme", QString());

         if(colorsFile.isEmpty() == false){
             if(colorScheme.isEmpty() == false){
                setColors(colorScheme, colorsFile);
             } else {
                setColors(package.metadata().name(), colorsFile);
             }
         } else if(colorScheme.isEmpty() == false){
             colorScheme.remove(QLatin1Char('\'')); // So Foo's does not become FooS
             QRegExp fixer(QStringLiteral("[\\W,.-]+(.?)"));
             int offset;
             while ((offset = fixer.indexIn(colorScheme)) >= 0) {
                 colorScheme.replace(offset, fixer.matchedLength(), fixer.cap(1).toUpper());
             }
             colorScheme.replace(0, 1, colorScheme.at(0).toUpper());

             bool schemeFound = false;
             const QStringList schemeDirs = QStandardPaths::locateAll(QStandardPaths::GenericDataLocation, QStringLiteral("color-schemes"),
                                                                      QStandardPaths::LocateDirectory);
             for (const QString &dir : schemeDirs) {
                 const QStringList fileNames = QDir(dir).entryList(QStringList()<<QStringLiteral("*.colors"));
                 for (const QString &file : fileNames) {
                     if (file.endsWith(colorScheme + QStringLiteral(".colors"))) {
                         setColors(colorScheme, dir + QLatin1Char('/') + file);
                         schemeFound = true;
                         break;
                     }
                 }
                 if (schemeFound) {
                     break;
                 }
             }
         }
     }
#if SET_KDE_THEME
     saveKdeTheme();
#endif
}

QStandardItemModel *JThemeManager::themeModel() const
{
    Q_D(const JThemeManager);
    return d->m_pModel;
}

int JThemeManager::pluginIndex(const QString &pluginName)
{
    Q_D(JThemeManager);
    const QModelIndexList results = d->m_pModel->match(d->m_pModel->index(0, 0), PluginNameRole, pluginName);
    if(results.count() == 1){
        return results.first().row();
    }
    return -1;
}

void JThemeManager::reloadModel()
{
    loadModel();
}

void JThemeManager::setColors(const QString &scheme, const QString &colorFile)
{
    Q_D(JThemeManager);
    if(scheme.isEmpty() && colorFile.isEmpty()){
        return;
    }

    KSharedConfigPtr conf = KSharedConfig::openConfig(colorFile, KConfig::SimpleConfig);
    for(const QString& grp : conf->groupList()){
        KConfigGroup cg(conf, grp);
        KConfigGroup cg2(d->m_nConfig, grp);
        cg.copyTo(&cg2, KConfig::Notify);
    }

    d->m_nConfigGroup.writeEntry("ThemePackage", d->m_nThemePackage);
    d->m_nConfigGroup.writeEntry("ColorScheme", scheme, KConfig::Notify);
    d->m_nConfig->sync();
}

void JThemeManager::setIcons(const QString &theme)
{

}

void JThemeManager::setPlasmaTheme(const QString &theme)
{

}

QString JThemeManager::themeName() const
{
   Q_D(const JThemeManager);
    return d->m_nThemePackage;
}

void JThemeManager::setThemeName(const QString &name)
{
    Q_D(JThemeManager);
    if(d->m_nThemePackage != name){
        d->m_nThemePackage = name;
        Q_EMIT themeNameChanged();
    }
}

void JThemeManager::saveKdeTheme()
{
    Q_D(JThemeManager);
     KPackage::Package package = KPackage::PackageLoader::self()->loadPackage(QStringLiteral("Plasma/LookAndFeel"));
     QString kdeTheme;
     if(d->m_nThemePackage == "org.jingos.light.desktop"){
         kdeTheme = "org.kde.breeze.desktop";
     } else {
         kdeTheme = "org.kde.breezedark.desktop";
     }
     package.setPath(kdeTheme);

     if(package.isValid() == false){
        qWarning()<< "Plasma/LookAndFeel  package is unvalid return";
        return;
     }

     if(package.filePath("defaults").isEmpty() == false){
         KSharedConfigPtr conf = KSharedConfig::openConfig(package.filePath("defaults"));
         KConfigGroup prefixCg(conf, "kdeglobals");

         QString colorsFile = package.filePath("colors");
         KConfigGroup cg = KConfigGroup(&prefixCg, "General");
         QString colorScheme = cg.readEntry("ColorScheme", QString());

         if(colorsFile.isEmpty() == false){
             if(colorScheme.isEmpty() == false){
                setKdeColors(colorScheme, colorsFile, kdeTheme);
             } else {
                setKdeColors(package.metadata().name(), colorsFile, kdeTheme);
             }
         } else if(colorScheme.isEmpty() == false){
             colorScheme.remove(QLatin1Char('\'')); // So Foo's does not become FooS
             QRegExp fixer(QStringLiteral("[\\W,.-]+(.?)"));
             int offset;
             while ((offset = fixer.indexIn(colorScheme)) >= 0) {
                 colorScheme.replace(offset, fixer.matchedLength(), fixer.cap(1).toUpper());
             }
             colorScheme.replace(0, 1, colorScheme.at(0).toUpper());

             bool schemeFound = false;
             const QStringList schemeDirs = QStandardPaths::locateAll(QStandardPaths::GenericDataLocation, QStringLiteral("color-schemes"),
                                                                      QStandardPaths::LocateDirectory);
             for (const QString &dir : schemeDirs) {
                 const QStringList fileNames = QDir(dir).entryList(QStringList()<<QStringLiteral("*.colors"));
                 for (const QString &file : fileNames) {
                     if (file.endsWith(colorScheme + QStringLiteral(".colors"))) {
                         setKdeColors(colorScheme, dir + QLatin1Char('/') + file, kdeTheme);
                         schemeFound = true;
                         break;
                     }
                 }
                 if (schemeFound) {
                     break;
                 }
             }
         }
     }
}

void JThemeManager::setKdeColors(const QString &scheme, const QString &colorFile, const QString& theme)
{
    if(scheme.isEmpty() && colorFile.isEmpty()){
        return;
    }

    KSharedConfigPtr conf = KSharedConfig::openConfig(colorFile, KConfig::SimpleConfig);
    KSharedConfigPtr kdeconfPtr = KSharedConfig::openConfig(QStringLiteral("kdeglobals"), KConfig::SimpleConfig);
    for(const QString& grp : conf->groupList()){
        KConfigGroup cg(conf, grp);
        KConfigGroup cg2(kdeconfPtr, grp);
        cg.copyTo(&cg2, KConfig::Notify);
    }

    KConfigGroup generalcg(kdeconfPtr, "General");
    generalcg.writeEntry("ColorScheme", scheme, KConfig::Notify);

    KConfigGroup kdecg(kdeconfPtr, "KDE");
    generalcg.writeEntry("LookAndFeelPackage", theme, KConfig::Notify);

    kdeconfPtr->sync();
}
