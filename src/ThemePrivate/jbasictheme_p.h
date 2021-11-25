/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#ifndef JBASICTHEME_P_H
#define JBASICTHEME_P_H
#include "jbasictheme.h"
#include <ksharedconfig.h>

class JBasicThemePrivate{
    Q_DECLARE_PUBLIC(JBasicTheme)
public:
    JBasicThemePrivate();
    ~JBasicThemePrivate();
     QColor color(const QString& group, const QString& key);
     bool getColorFromString(const QString &data, QColor& output);
     QColor getDefaultColor(const QString& group, const QString& key);
protected:
    JBasicTheme* q_ptr;

    KSharedConfigPtr m_nColorsConfig;
};

#endif // JBASICTHEME_P_H
