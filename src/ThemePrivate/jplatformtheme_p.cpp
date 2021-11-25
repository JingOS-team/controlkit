/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#include "jplatformtheme_p.h"
#include <QQmlEngine>
#include <QQuickItem>
#include <QDebug>
#include "jbasictheme.h"

Q_GLOBAL_STATIC(JBasicTheme, privateBasicTheme)
JPlatformThemePrivate::JPlatformThemePrivate()
{

}

JPlatformThemePrivate::~JPlatformThemePrivate()
{

}

void JPlatformThemePrivate::setPaletteColor(QPalette &custPalette, QPalette::ColorGroup cg,
                                            QPalette::ColorRole cr, const QColor &color, bool &changed)
{
    if(custPalette.color(cg, cr) != color){
        changed = true;
        custPalette.setColor(cg, cr, color);
    }

}

void JPlatformThemePrivate::emitCompressedColorChanged()
{

}


void JPlatformThemePrivate::syncColors()
{
    Q_Q(JPlatformTheme);

    q->setThemeName(privateBasicTheme->themeName());
    q->setColorScheme(privateBasicTheme->colorScheme());

    q->setMajorForeground(privateBasicTheme->color("Colors:Foreground", "foreground"));
    q->setMinorForeground(privateBasicTheme->color("Colors:Foreground", "minorForeground"));
    q->setDisableForeground(privateBasicTheme->color("Colors:Foreground", "disableForeground"));
    q->setDividerForeground(privateBasicTheme->color("Colors:Foreground", "dividerForeground"));

    q->setBackground(privateBasicTheme->color("Colors:Background", "backround"));
    q->setCardBackground(privateBasicTheme->color("Colors:Background", "cardBackround"));
    q->setHeaderBackground(privateBasicTheme->color("Colors:Background", "headerBackground"));
    q->setFloatBackground(privateBasicTheme->color("Colors:Background", "floatBackground"));
    q->setOverBackground(privateBasicTheme->color("Colors:Background", "overBackground"));
    q->setComponentBackground(privateBasicTheme->color("Colors:Background", "componentBackground"));
    q->setCurrentBackground(privateBasicTheme->color("Colors:Background", "currentBackground"));
    q->setTextEditTipBackground(privateBasicTheme->color("Colors:Background", "textEditTipBackground"));
    q->setHoverBackground(privateBasicTheme->color("Colors:Background", "hoverBackground"));
    q->setPressBackground(privateBasicTheme->color("Colors:Background", "pressBackground"));

    q->setTextFieldBackground(privateBasicTheme->color("Colors:TextFiled", "background"));
    q->setTextFieldBorder(privateBasicTheme->color("Colors:TextFiled", "border"));
    q->setTextFieldSelectColor(privateBasicTheme->color("Colors:TextFiled", "selectBackground"));

    q->setIconForeground(privateBasicTheme->color("Colors:Icon", "forground"));
    q->setIconMinorForeground(privateBasicTheme->color("Colors:Icon", "minorForeground"));
    q->setIconDisableForeground(privateBasicTheme->color("Colors:Icon", "disableForeground"));

    q->setButtonForeground(privateBasicTheme->color("Colors:Button", "foreground"));
    q->setButtonBackground(privateBasicTheme->color("Colors:Button", "background"));
    q->setButtonBorder(privateBasicTheme->color("Colors:Button", "border"));

    q->setButtonWeakForeground(privateBasicTheme->color("Colors:Button", "weakForeground"));
    q->setButtonWeakBackground(privateBasicTheme->color("Colors:Button", "weakBackground"));
    q->setButtonWeakBorder(privateBasicTheme->color("Colors:Button", "weakBorder"));

    q->setButtonStrongForeground(privateBasicTheme->color("Colors:Button", "strongForeground"));
    q->setButtonStrongBackground(privateBasicTheme->color("Colors:Button", "strongBackground"));
    q->setButtonStrongBorder(privateBasicTheme->color("Colors:Button", "strongBorder"));

    q->setButtonPopupForeground(privateBasicTheme->color("Colors:Button", "popupForeground"));
    q->setButtonPopupBackground(privateBasicTheme->color("Colors:Button", "popupBackground"));
    q->setButtonPopupBorder(privateBasicTheme->color("Colors:Button", "popupBorder"));

    q->setHighlightColor(privateBasicTheme->color("Colors:Highlight", "default"));
    q->setHighlightLinearColor(privateBasicTheme->color("Colors:Highlight", "linearColor"));
    q->setHighlightRed(privateBasicTheme->color("Colors:Highlight", "red"));
    q->setHighlightGreen(privateBasicTheme->color("Colors:Highlight", "green"));
    q->setHighlightBlue(privateBasicTheme->color("Colors:Highlight", "blue"));
    q->setHighlightYellow(privateBasicTheme->color("Colors:Highlight", "yellow"));
    q->setHighlightOrange(privateBasicTheme->color("Colors:Highlight", "orange"));
    q->setHighlightPurple(privateBasicTheme->color("Colors:Highlight", "purple"));
    q->setHighlightRoseRed(privateBasicTheme->color("Colors:Highlight", "roseRed"));
    q->setHighlightPink(privateBasicTheme->color("Colors:Highlight", "pink"));

    q->setSettingMajorBackground(privateBasicTheme->color("Colors:Setting", "majorBackground"));
    q->setSettingMinorBackground(privateBasicTheme->color("Colors:Setting", "minorBackground"));
}
