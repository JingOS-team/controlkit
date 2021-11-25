/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#ifndef JPLATFORMTHEMEPRIVATE_H
#define JPLATFORMTHEMEPRIVATE_H

#include <QFont>
#include <QSet>
#include <QPointer>
#include <QObject>
#include "../jplatformtheme.h"
class JPlatformThemePrivate : public QObject
{
    Q_OBJECT
    Q_DECLARE_PUBLIC(JPlatformTheme)
public:
    JPlatformThemePrivate();
    ~JPlatformThemePrivate();
    void setPaletteColor(QPalette& custPalette, QPalette::ColorGroup cg, QPalette::ColorRole cr,
                         const QColor& color, bool& changed);

    void emitCompressedColorChanged();

    void syncColors();

protected:
    JPlatformTheme* q_ptr;

    QString m_nThemeName;
    QString m_nColorScheme;

    QColor m_nMajorForeground;
    QColor m_nMinorForeground;
    QColor m_nDisableForeground;
    QColor m_nDividerForeground;

    QColor m_nBackground;
    QColor m_nCardBackground;
    QColor m_nHeaderBackground;
    QColor m_nFloatBackground;
    QColor m_nOverBackground;
    QColor m_nComponentBackground;
    QColor m_nCurrentBackground;
    QColor m_nTextEditTipBackground;
    QColor m_nHoverBackground;
    QColor m_nPressBackground;

    QColor m_nTextFieldBackground;
    QColor m_nTextFieldBorder;
    QColor m_nTextFieldSelectColor;

    QColor m_nIconForeground;
    QColor m_nIconMinorForeground;
    QColor m_nIconDisableForeground;

    QColor m_nButtonForeground;
    QColor m_nButtonBackground;
    QColor m_nButtonBorder;

    QColor m_nButtonWeakForeground;
    QColor m_nButtonWeakBackground;
    QColor m_nButtonWeakBorder;

    QColor m_nButtonStrongForeground;
    QColor m_nButtonStrongBackground;
    QColor m_nButtonStrongBorder;

    QColor m_nButtonPopupForeground;
    QColor m_nButtonPopupBackground;
    QColor m_nButtonPopupBorder;


    QColor m_nHighlightColor;
    QColor m_nHighlightLinearColor;
    QColor m_nHighlightRed;
    QColor m_nHighlightGreen;
    QColor m_nHighlightBlue;
    QColor m_nHighlightYellow;
    QColor m_nHighlightOrange;
    QColor m_nHighlightPurple;
    QColor m_nHighlightRoseRed;
    QColor m_nHighlightPink;

    QColor m_nSettingMajorBackground;
    QColor m_nSettingMinorBackground;


    QColor m_nCustomMajorForeground;
    QColor m_nCustomMinorForeground;
    QColor m_nCustomDisableForeground;
    QColor m_nCustomDividerForeground;

    QColor m_nCustomBackground;
    QColor m_nCustomCardBackground;
    QColor m_nCustomHeaderBackground;
    QColor m_nCustomFloatBackground;
    QColor m_nCustomOverBackground;
    QColor m_nCustomComponentBackground;
    QColor m_nCustomCurrentBackground;
    QColor m_nCustomTextEditTipBackground;
    QColor m_nCustomHoverBackground;
    QColor m_nCustomPressBackground;

    QColor m_nCustomTextFieldBackground;
    QColor m_nCustomTextFieldBorder;
    QColor m_nCustomTextFieldSelectColor;

    QColor m_nCustomIconForeground;
    QColor m_nCustomIconMinorForeground;
    QColor m_nCustomIconDisableForeground;

    QColor m_nCustomButtonForeground;
    QColor m_nCustomButtonBackground;
    QColor m_nCustomButtonBorder;

    QColor m_nCustomButtonWeakForeground;
    QColor m_nCustomButtonWeakBackground;
    QColor m_nCustomButtonWeakBorder;

    QColor m_nCustomButtonStrongForeground;
    QColor m_nCustomButtonStrongBackground;
    QColor m_nCustomButtonStrongBorder;

    QColor m_nCustomButtonPopupForeground;
    QColor m_nCustomButtonPopupBackground;
    QColor m_nCustomButtonPopupBorder;

    QPalette m_nPalette;

    QFont  m_nFont;
    QFont  m_nSmallFont;
};

#endif // JPLATFORMTHEMEPRIVATE_H
