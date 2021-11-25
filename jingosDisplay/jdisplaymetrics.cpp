/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#include "jdisplaymetrics.h"
#include <QDebug>
#include <QFontDatabase>
#include <QStandardItemModel>

#include <KSharedConfig>
#include <KConfigGroup>
JDisplayMetrics::JDisplayMetrics(QObject *parent) : QObject(parent)
{
    KSharedConfigPtr globalConfig = KSharedConfig::openConfig("kdeglobals", KConfig::SimpleConfig);
    KConfigGroup cg(globalConfig, "General");
    if(cg.exists() == false){
        qWarning() << Q_FUNC_INFO << "not find kdeglobals in current users path, so use /etc/skel/.config/kdeglobals";
        globalConfig = KSharedConfig::openConfig("/etc/skel/.config/kdeglobals", KConfig::SimpleConfig);
        cg = KConfigGroup(globalConfig, "General");
        if(cg.exists() == false){
            qWarning() << Q_FUNC_INFO << " /etc/skel/.config/kdeglobals also not exist, user default ,dpi = 1.0, fontscale = 1.0";
        }
    }else {
        qDebug() << Q_FUNC_INFO << "find kdeglobals in user path " ;
    }


    QFont generalFont = QFont("Noto Sans", 10);
    generalFont.setStyleName("Regular");

    QFont ft = cg.readEntry("font", generalFont);
    m_nFontFamily = ft.family();

    m_nFontScale = cg.readEntry("fontScale", 1.0);
    m_nDpi = cg.readEntry("dpi", 2.0);

    m_nFontSize = qRound(m_nDefaultFontSize * m_nFontScale);
}

JDisplayMetrics::~JDisplayMetrics()
{
    qDebug() << Q_FUNC_INFO << this;
}

qreal JDisplayMetrics::dpi() const
{
    return m_nDpi;
}

void JDisplayMetrics::setDpi(qreal v)
{
    if(m_nDpi != v){
        m_nDpi = v;
        Q_EMIT dpiChanged();
    }
}

qreal JDisplayMetrics::fontScale() const
{
    return m_nFontScale;
}

void JDisplayMetrics::setFontScale(qreal v)
{
    if(m_nFontScale != v){
        m_nFontScale = v;
        Q_EMIT fontScaleChanged();
    }
}

QString JDisplayMetrics::fontFamily() const
{
    return m_nFontFamily;
}

void JDisplayMetrics::setFontFamily(const QString &v)
{
    if(m_nFontFamily != v){
        m_nFontFamily = v;
        Q_EMIT fontFamilyChanged();
    }
}

int JDisplayMetrics::fontSize() const
{
    return m_nFontSize;
}

void JDisplayMetrics::setFontSize(int v)
{
    if(m_nFontSize != v){
        m_nFontSize = v;
        Q_EMIT fontSizeChanged();
    }
}

int JDisplayMetrics::defaultFontSize() const
{
    return  m_nDefaultFontSize;
}

void JDisplayMetrics::setDefaultFontSize(int v)
{
    if(m_nDefaultFontSize != v){
        m_nDefaultFontSize = v;
        Q_EMIT defaultFontSizeChanged();
    }
}

QAbstractItemModel *JDisplayMetrics::fontFamilyModel()
{
    if(m_pFontFamilyModel == nullptr){
        QFontDatabase database;
        m_pFontFamilyModel = new QStandardItemModel(this);
        for (const QString &family : database.families()) {
            auto item = new QStandardItem(family);
            m_pFontFamilyModel->appendRow(item);
        }
    }
    return m_pFontFamilyModel;
}

void JDisplayMetrics::setSystemFont(const QString &fontFamily, int fontSize)
{
    if(fontSize <= 10){
        fontSize = 10;
    } else if(fontSize <= 12){
        fontSize = 12;
    } else if(fontSize <= 14){
        fontSize = 14;
    } else if(fontSize <= 16){
        fontSize = 16;
    } else {
        fontSize = 17;
    }

    qreal scale = (fontSize * 1.0) / m_nDefaultFontSize;
    setFontScale(scale);

    setFontSize(fontSize);

    QFont ft;
    ft.setFamily(fontFamily);

    fontSize = qRound(10 * scale);
    ft.setPointSize(fontSize);

    KSharedConfigPtr globalConfig = KSharedConfig::openConfig("kdeglobals", KConfig::SimpleConfig);
    KConfigGroup cg(globalConfig, "General");

    cg.writeEntry("font", ft);
    cg.writeEntry("fontScale", fontScale());
    cg.sync();
}
