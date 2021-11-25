/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#include "jthememanager_p.h"

#include <QDir>
#include <QDebug>
JThemeManagerPrivate::JThemeManagerPrivate(QObject *parent) : QObject(parent)
{

}

JThemeManagerPrivate::~JThemeManagerPrivate()
{

}

QList<KPackage::Package> JThemeManagerPrivate::availablePackages(const QStringList &components)
{
    QList<KPackage::Package> packages;
    QStringList paths;
    const QStringList dataPaths = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation);
    paths.reserve(dataPaths.count());
    for(const QString& path : dataPaths){
        QDir dir(path + QStringLiteral("/plasma/jingosTheme"));
        paths << dir.entryList(QDir::AllDirs | QDir::NoDotAndDotDot);
    }

    for(const QString& path : paths){
        KPackage::Package pkg = KPackage::PackageLoader::self()->loadPackage(QStringLiteral("Plasma/LookAndFeel"));
        pkg.setDefaultPackageRoot("plasma/jingosTheme");
        pkg.setPath(path);
        pkg.setFallbackPackage(KPackage::Package());
        if(components.isEmpty()){
            packages << pkg;
        } else {
            for(const QString& component : components){
                if(pkg.filePath(component.toUtf8()).isEmpty() == false){
                    packages << pkg;
                    break;
                }
            }
        }
    }

    return packages;

}


void JThemeManagerPrivate::initData()
{
    m_nConfig = KSharedConfig::openConfig(QStringLiteral("jingosThemeGlobals"), KConfig::SimpleConfig);
    m_nConfigGroup = KConfigGroup(m_nConfig, "JINGOS");


    QString themePkg;
    if(m_nConfigGroup.isValid()){
        themePkg = m_nConfigGroup.readEntry("ThemePackage", QString());
    }
    if(themePkg.isEmpty()){
        qWarning() << "JThemeManagerPrivate::initData jingThemeGlobals's data is empty or not exist , so use kdeglobals";
        KSharedConfigPtr ptr = KSharedConfig::openConfig(QStringLiteral("kdeglobals"), KConfig::SimpleConfig);
        KConfigGroup cg = KConfigGroup(ptr, "KDE");
        themePkg = cg.readEntry("LookAndFeelPackage", "org.kde.breeze.desktop");
    }

    if(themePkg == "org.kde.breeze.desktop"){
        themePkg = "org.jingos.light.desktop";
    }
    m_nThemePackage = themePkg;
    m_nConfigGroup.writeEntry("ThemePackage", m_nThemePackage);
    m_nConfig->sync();
}

