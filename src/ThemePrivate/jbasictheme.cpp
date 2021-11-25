/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#include "jbasictheme.h"
#include "jbasictheme_p.h"

#include <QDebug>
#include <QColor>

#include <KConfigGroup>
JBasicTheme::JBasicTheme(QObject *parent) : QObject(parent)
  , d_ptr(new JBasicThemePrivate)
{
    d_ptr->q_ptr = this;
}

JBasicTheme::~JBasicTheme()
{

}

QString JBasicTheme::themeName()
{
    Q_D(JBasicTheme);
    KConfigGroup cg(d->m_nColorsConfig, "JINGOS");
    QString theme = cg.readEntry("ThemePackage", QString());
    if(theme.isEmpty()){
        theme = "org.jingos.light.desktop";
    }
    return theme;
}

QString JBasicTheme::colorScheme()
{
    Q_D(JBasicTheme);
    KConfigGroup cg(d->m_nColorsConfig, "JINGOS");
    QString theme = cg.readEntry("ColorScheme", QString());
    if(theme.isEmpty()){
        theme = "jingosLight";
    }
    return theme;
}

QColor JBasicTheme::color(const QString &group, const QString &key)
{
    Q_D(JBasicTheme);
    return d->color(group, key);
}

JBasicThemePrivate::JBasicThemePrivate()
{
    m_nColorsConfig = KSharedConfig::openConfig("jingosThemeGlobals", KConfig::SimpleConfig);
}

JBasicThemePrivate::~JBasicThemePrivate()
{

}

QColor JBasicThemePrivate::color(const QString &group, const QString &key)
{
    QColor output;
    KConfigGroup cg(m_nColorsConfig, group);
    QString colorstr = cg.readEntry(key, QString());
    bool rv = getColorFromString(colorstr, output);
    if(rv == false){
        output = getDefaultColor(group, key);
    }
    return output;
}

bool JBasicThemePrivate::getColorFromString(const QString &data, QColor& output)
{
    if (data.isEmpty() || data == "invalid") {
        return false;
    } else if (data.at(0) == '#') {
        QColor col;
        col.setNamedColor(data);
        output = col;
        return true;
    } else if (!data.contains(',')) {
        QColor col;
        col.setNamedColor(data);
        if (!col.isValid()) {
            return false;
        }
        output = col;
        return true;
    } else {
        QStringList list = data.split(',');
        const int count = list.count();
        if (count != 3 && count != 4) {
            const QString formatError = QStringLiteral(" (wrong format: expected '%1' items, read '%2')");
            qCritical() << qPrintable(formatError.arg(QStringLiteral("3' or '4")).arg(count));
            return false;    // return default
        }

        int temp[4];
        // bounds check components
        for (int i = 0; i < count; i++) {
            bool ok;
            const int j = temp[i] = list.at(i).toInt(&ok);
            if (!ok) { // failed to convert to int
                qCritical() << " (integer conversion failed)";
                return true; // return default
            }
            if (j < 0 || j > 255) {
                static const char *const components[] = {
                    "red", "green", "blue", "alpha"
                };
                const QString boundsError = QStringLiteral(" (bounds error: %1 component %2)");
                qCritical() << qPrintable(boundsError.arg(QLatin1String(components[i])).arg(j < 0 ? QStringLiteral("< 0") : QStringLiteral("> 255")));
                return false; // return default
            }
        }
        QColor aColor(temp[0], temp[1], temp[2]);
        if (count == 4) {
            aColor.setAlpha(temp[3]);
        }

        if (aColor.isValid()) {
            output = aColor;
        } else {
            qCritical() << "22 data can not convert to color " << data;
        }
        return true;
    }
}

QColor JBasicThemePrivate::getDefaultColor(const QString &group, const QString &key)
{
    static QMap<QString, QColor> defaultColor = {
        {"Colors:Foreground-foreground"  , QColor("#FF000000")},
        {"Colors:Foreground-minorForeground"  , QColor("#8C000000")},
        {"Colors:Foreground-disableForeground"  , QColor("#4C000000")},
        {"Colors:Foreground-dividerForeground"  , QColor("#1E000000")},

        {"Colors:Background-backround"  , QColor("#FFE8EFFF")},
        {"Colors:Background-cardBackround"  , QColor("#FFFFFFFF")},
        {"Colors:Background-headerBackground"  , QColor("#B2FFFFFF")},
        {"Colors:Background-floatBackground"  , QColor("#99FFFFFF")},
        {"Colors:Background-overBackground"  , QColor("#7F000000")},
        {"Colors:Background-componentBackground"  , QColor("#1E767680")},
        {"Colors:Background-currentBackground"  , QColor("#F2FFFFFF")},
        {"Colors:Background-textEditTipBackground"  , QColor("#E6303030")},
        {"Colors:Background-hoverBackground"  , QColor("#14767680")},
        {"Colors:Background-pressBackground"  , QColor("#1E767680")},

        {"Colors:TextFiled-background"  , QColor("#FFFFFFFF")},
        {"Colors:TextFiled-border"  , QColor("#FF3C4BE8")},
        {"Colors:TextFiled-selectBackground"  , QColor("#333F50FF")},

        {"Colors:Icon-forground"  , QColor("#FF000000")},
        {"Colors:Icon-minorForeground"  , QColor("#8C000000")},
        {"Colors:Icon-disableForeground"  , QColor("#4C000000")},

        {"Colors:Button-foreground"  , QColor("#FF000000")},
        {"Colors:Button-background"  , QColor("#FFFFFFFF")},
        {"Colors:Button-border"  , QColor("#FFCDD0D7")},

        {"Colors:Button-weakForeground"  , QColor("#FF3C4BE8")},
        {"Colors:Button-weakBackground"  , QColor("#FFFFFFFF")},
        {"Colors:Button-weakBorder"  , QColor("#FF3C4BE8")},

        {"Colors:Button-strongForeground"  , QColor("#FFFFFF")},
        {"Colors:Button-strongBackground"  , QColor("#FF3C4BE8")},
        {"Colors:Button-strongBorder"  , QColor("#FF3C4BE8")},

        {"Colors:Button-popupForeground"  , QColor("#FF000000")},
        {"Colors:Button-popupBackground"  , QColor("#CCE4E9EC")},
        {"Colors:Button-popupBorder"  , QColor("#CCE4E9EC")},

        {"Colors:Highlight-default"  , QColor("#FF3C4BE8")},
        {"Colors:Highlight-linearColor"  , QColor("#FF3C4BE8")},
        {"Colors:Highlight-red"  , QColor("#FFE95B4E")},
        {"Colors:Highlight-green"  , QColor("#FF39C17B")},
        {"Colors:Highlight-blue"  , QColor("#FF5AC8FA")},
        {"Colors:Highlight-yellow"  , QColor("#FFFDD32E")},
        {"Colors:Highlight-orange"  , QColor("#FFFF9B5F")},
        {"Colors:Highlight-purple"  , QColor("#FF824BFF")},
        {"Colors:Highlight-roseRed"  , QColor("#FFC558F2")},
        {"Colors:Highlight-pink"  , QColor("#FFFF2D55")},

        {"Colors:Setting-majorBackground"  , QColor("#FFE8EFFF")},
        {"Colors:Setting-minorBackground"  , QColor("#FFF6F9FF")},
    };

    QString mapKey = group + "-" + key;
    QColor color = defaultColor[mapKey];
    return color;
}
