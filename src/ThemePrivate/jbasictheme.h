/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#ifndef JBASICTHEME_H
#define JBASICTHEME_H

#include <QObject>
class JBasicThemePrivate;
class JBasicTheme : public QObject
{
    Q_OBJECT
    Q_DECLARE_PRIVATE(JBasicTheme)
public:
    explicit JBasicTheme(QObject *parent = nullptr);
    ~JBasicTheme();

    QString themeName();
    QString colorScheme();

    QColor color(const QString& group, const QString& key);
protected:
    QScopedPointer<JBasicThemePrivate> d_ptr;

};

#endif // JBASICTHEME_H
