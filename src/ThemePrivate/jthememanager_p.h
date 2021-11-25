/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#ifndef JTHEMEMANAGERPRIVATE_H
#define JTHEMEMANAGERPRIVATE_H

#include <QDir>
#include <QList>
#include <QObject>

#include <KConfig>
#include <KConfigGroup>
#include <KSharedConfig>
#include <KPluginMetaData>
#include <KPackage/Package>
#include <KPackage/PackageLoader>
#include <KPackage/PackageStructure>

#include "../jthememanager.h"

class QStandardItemModel;

class JThemeManagerPrivate : public QObject
{
    Q_OBJECT
    Q_DECLARE_PUBLIC(JThemeManager)
public:
    explicit JThemeManagerPrivate(QObject *parent = nullptr);
    ~JThemeManagerPrivate();
    QList<KPackage::Package> availablePackages(const QStringList& components);
    void initData();
    KPackage::Package m_nPackage;
    KSharedConfigPtr m_nConfig;
    KConfigGroup m_nConfigGroup;


protected:
    JThemeManager* q_ptr;
    QStandardItemModel* m_pModel = nullptr;

    QString m_nThemePackage = "org.kde.breeze.desktop";
};

#endif // JTHEMEMANAGERPRIVATE_H
