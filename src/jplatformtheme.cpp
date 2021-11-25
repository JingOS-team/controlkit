/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#include "jplatformtheme.h"
#include "ThemePrivate/jplatformtheme_p.h"
JPlatformTheme::JPlatformTheme(QObject *parent): QObject(parent)
  , d_ptr(new JPlatformThemePrivate)
{
    d_ptr->q_ptr = this;

    Q_D(JPlatformTheme);
    d->syncColors();
}

JPlatformTheme::~JPlatformTheme()
{

}

JPlatformTheme *JPlatformTheme::qmlAttachedProperties(QObject *object)
{
    return new JPlatformTheme(object);
}

QString JPlatformTheme::themeName() const
{
    Q_D(const JPlatformTheme) ;
    return d->m_nThemeName;
}

QString JPlatformTheme::colorScheme() const
{
    Q_D(const JPlatformTheme) ;
    return d->m_nColorScheme;
}

#define SHORTCUTGETCOLOR(NAMECOLOR) \
    Q_D(const JPlatformTheme); \
    return d->m_nCustom##NAMECOLOR.isValid() ? d->m_nCustom##NAMECOLOR : d->m_n##NAMECOLOR;

QColor JPlatformTheme::majorForeground() const
{
    SHORTCUTGETCOLOR(MajorForeground);
}

QColor JPlatformTheme::minorForeground() const
{
    SHORTCUTGETCOLOR(MinorForeground);
}

QColor JPlatformTheme::disableForeground() const
{
    SHORTCUTGETCOLOR(DisableForeground);
}

QColor JPlatformTheme::dividerForeground() const
{
    SHORTCUTGETCOLOR(DividerForeground);
}

QColor JPlatformTheme::background() const
{
    SHORTCUTGETCOLOR(Background);
}

QColor JPlatformTheme::cardBackground() const
{
    SHORTCUTGETCOLOR(CardBackground);
}

QColor JPlatformTheme::headerBackground() const
{
    SHORTCUTGETCOLOR(HeaderBackground);
}

QColor JPlatformTheme::floatBackground() const
{
    SHORTCUTGETCOLOR(FloatBackground);
}

QColor JPlatformTheme::overBackground() const
{
    SHORTCUTGETCOLOR(OverBackground);
}

QColor JPlatformTheme::componentBackground() const
{
    SHORTCUTGETCOLOR(ComponentBackground);
}

QColor JPlatformTheme::currentBackground() const
{
    SHORTCUTGETCOLOR(CurrentBackground);
}

QColor JPlatformTheme::textEditTipBackground() const
{
    SHORTCUTGETCOLOR(TextEditTipBackground);
}

QColor JPlatformTheme::hoverBackground() const
{
    SHORTCUTGETCOLOR(HoverBackground);
}

QColor JPlatformTheme::pressBackground() const
{
    SHORTCUTGETCOLOR(PressBackground);
}

QColor JPlatformTheme::textFieldBackground() const
{
    SHORTCUTGETCOLOR(TextFieldBackground);
}

QColor JPlatformTheme::textFieldBorder() const
{
    SHORTCUTGETCOLOR(TextFieldBorder);
}

QColor JPlatformTheme::textFieldSelectColor() const
{
    SHORTCUTGETCOLOR(TextFieldSelectColor);
}

QColor JPlatformTheme::iconForeground() const
{
    SHORTCUTGETCOLOR(IconForeground);
}

QColor JPlatformTheme::iconMinorForeground() const
{
    SHORTCUTGETCOLOR(IconMinorForeground);
}

QColor JPlatformTheme::iconDisableForeground() const
{
    SHORTCUTGETCOLOR(IconDisableForeground);
}

QColor JPlatformTheme::buttonForeground() const
{
    SHORTCUTGETCOLOR(ButtonForeground);
}

QColor JPlatformTheme::buttonBackground() const
{
    SHORTCUTGETCOLOR(ButtonBackground);
}

QColor JPlatformTheme::buttonBorder() const
{
    SHORTCUTGETCOLOR(ButtonBorder);
}

QColor JPlatformTheme::buttonWeakForeground() const
{
    SHORTCUTGETCOLOR(ButtonWeakForeground);
}

QColor JPlatformTheme::buttonWeakBackground() const
{
    SHORTCUTGETCOLOR(ButtonWeakBackground);
}

QColor JPlatformTheme::buttonWeakBorder() const
{
    SHORTCUTGETCOLOR(ButtonWeakBorder);
}

QColor JPlatformTheme::buttonStrongForeground() const
{
    SHORTCUTGETCOLOR(ButtonStrongForeground);
}

QColor JPlatformTheme::buttonStrongBackground() const
{
    SHORTCUTGETCOLOR(ButtonStrongBackground);
}

QColor JPlatformTheme::buttonStrongBorder() const
{
    SHORTCUTGETCOLOR(ButtonStrongBorder);
}

QColor JPlatformTheme::buttonPopupForeground() const
{
    SHORTCUTGETCOLOR(ButtonPopupForeground);
}

QColor JPlatformTheme::buttonPopupBackground() const
{
    SHORTCUTGETCOLOR(ButtonPopupBackground);
}

QColor JPlatformTheme::buttonPopupBorder() const
{
    SHORTCUTGETCOLOR(ButtonPopupBorder);
}

#define SHORTCUTGETHIGHLIGHTCOLOR(NAMECOLOR) \
    Q_D(const JPlatformTheme); \
    return d->m_n##NAMECOLOR;
QColor JPlatformTheme::highlightColor() const
{
    SHORTCUTGETHIGHLIGHTCOLOR(HighlightColor);
}

QColor JPlatformTheme::highlightLinearColor() const
{
    SHORTCUTGETHIGHLIGHTCOLOR(HighlightLinearColor);
}

QColor JPlatformTheme::highlightRed() const
{
    SHORTCUTGETHIGHLIGHTCOLOR(HighlightRed);
}

QColor JPlatformTheme::highlightGreen() const
{
    SHORTCUTGETHIGHLIGHTCOLOR(HighlightGreen);
}

QColor JPlatformTheme::highlightBlue() const
{
    SHORTCUTGETHIGHLIGHTCOLOR(HighlightBlue);
}

QColor JPlatformTheme::highlightYellow() const
{
    SHORTCUTGETHIGHLIGHTCOLOR(HighlightYellow);
}

QColor JPlatformTheme::highlightOrange() const
{
    SHORTCUTGETHIGHLIGHTCOLOR(HighlightOrange);
}

QColor JPlatformTheme::highlightPurple() const
{
    SHORTCUTGETHIGHLIGHTCOLOR(HighlightPurple);
}

QColor JPlatformTheme::highlightRoseRed() const
{
    SHORTCUTGETHIGHLIGHTCOLOR(HighlightRoseRed);
}

QColor JPlatformTheme::highlightPink() const
{
    SHORTCUTGETHIGHLIGHTCOLOR(HighlightPink);
}

QColor JPlatformTheme::settingMajorBackground() const
{
    SHORTCUTGETHIGHLIGHTCOLOR(SettingMajorBackground);
}

QColor JPlatformTheme::settingMinorBackground() const
{
    SHORTCUTGETHIGHLIGHTCOLOR(SettingMinorBackground);
}


#define SHORTCUTSETCUSTOMCOLOR(NAME, name, color) \
    Q_D(JPlatformTheme); \
    if(d->m_nCustom##NAME != color){ \
        d->m_nCustom##NAME = color; \
        Q_EMIT name##Changed(); \
    }

void JPlatformTheme::setCustomMajorForeground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(MajorForeground, majorForeground, color)
}

void JPlatformTheme::setCustomMinorForeground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(MinorForeground, minorForeground, color)
}

void JPlatformTheme::setCustomDisableForeground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(DisableForeground, disableForeground, color)
}

void JPlatformTheme::setCustomDividerForeground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(DisableForeground, disableForeground, color)
}

void JPlatformTheme::setCustomBackground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(Background, background, color)
}

void JPlatformTheme::setCustomCardBackground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(CardBackground, cardBackground, color)
}

void JPlatformTheme::setCustomHeaderBackground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(HeaderBackground, headerBackground, color)
}

void JPlatformTheme::setCustomFloatBackground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(FloatBackground, floatBackground, color)
}

void JPlatformTheme::setCustomOverBackground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(OverBackground, overBackground, color)
}

void JPlatformTheme::setCustomComponentBackground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(ComponentBackground, componentBackground, color)
}

void JPlatformTheme::setCustomCurrentBackground(const QColor &color)
{
   SHORTCUTSETCUSTOMCOLOR(CurrentBackground, currentBackground, color)
}

void JPlatformTheme::setCustomTextEditTipBackground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(TextEditTipBackground, textEditTipBackground, color)
}

void JPlatformTheme::setCustomHoverBackground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(HoverBackground, hoverBackground, color)
}

void JPlatformTheme::setCustomPressBackground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(PressBackground, pressBackground, color)
}

void JPlatformTheme::setCustomTextFieldBackground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(TextFieldBackground, textFieldBackground, color)
}

void JPlatformTheme::setCustomTextFieldBorder(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(TextFieldBorder, textFieldBorder, color)
}

void JPlatformTheme::setCustomTextFieldSelectColor(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(TextFieldSelectColor, textFieldSelectColor, color)
}

void JPlatformTheme::setCustomIconForeground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(IconForeground, iconForeground, color)
}

void JPlatformTheme::setCustomIconMinorForeground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(IconMinorForeground, iconMinorForeground, color)
}

void JPlatformTheme::setCustomIconDisableForeground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(IconDisableForeground, iconDisableForeground, color)
}

void JPlatformTheme::setCustomButtonForeground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(ButtonForeground, buttonForeground, color)
}

void JPlatformTheme::setCustomButtonBackground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(ButtonBackground, buttonBackground, color)
}

void JPlatformTheme::setCustomButtonBorder(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(ButtonBorder, buttonBorder, color)
}

void JPlatformTheme::setCustomButtonWeakForeground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(ButtonWeakForeground, buttonWeakForeground, color)
}

void JPlatformTheme::setCustomButtonWeakBackground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(ButtonWeakBackground, buttonWeakBackground, color)
}

void JPlatformTheme::setCustomButtonWeakBorder(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(ButtonWeakBorder, buttonWeakBorder, color)
}

void JPlatformTheme::setCustomButtonStrongForeground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(ButtonStrongForeground, buttonStrongForeground, color)
}

void JPlatformTheme::setCustomButtonStrongBackground(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(ButtonStrongBackground, buttonStrongBackground, color)
}

void JPlatformTheme::setCustomButtonStrongBorder(const QColor &color)
{
    SHORTCUTSETCUSTOMCOLOR(ButtonStrongBorder, buttonStrongBorder, color)
}


#define SHORTCUTSETCOLOR(NAME, name, color) \
    Q_D(JPlatformTheme); \
    if(d->m_n##NAME != color){ \
        d->m_n##NAME = color; \
        Q_EMIT name##Changed(); \
    }

void JPlatformTheme::setMajorForeground(const QColor &color)
{
    SHORTCUTSETCOLOR(MajorForeground, majorForeground, color)
}

void JPlatformTheme::setMinorForeground(const QColor &color)
{
    SHORTCUTSETCOLOR(MinorForeground, minorForeground, color)
}

void JPlatformTheme::setDisableForeground(const QColor &color)
{
    SHORTCUTSETCOLOR(DisableForeground, disableForeground, color)
}

void JPlatformTheme::setDividerForeground(const QColor &color)
{
    SHORTCUTSETCOLOR(DividerForeground, dividerForeground, color)
}

void JPlatformTheme::setBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(Background, background, color)
}

void JPlatformTheme::setCardBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(CardBackground, cardBackground, color)
}

void JPlatformTheme::setHeaderBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(HeaderBackground, headerBackground, color)
}

void JPlatformTheme::setFloatBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(FloatBackground, floatBackground, color)
}

void JPlatformTheme::setOverBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(OverBackground, overBackground, color)
}

void JPlatformTheme::setComponentBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(ComponentBackground, componentBackground, color)
}

void JPlatformTheme::setCurrentBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(CurrentBackground, currentBackground, color)
}

void JPlatformTheme::setTextEditTipBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(TextEditTipBackground, textEditTipBackground, color)
}

void JPlatformTheme::setHoverBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(HoverBackground, hoverBackground, color)
}

void JPlatformTheme::setPressBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(PressBackground, pressBackground, color)
}

void JPlatformTheme::setTextFieldBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(TextFieldBackground, textFieldBackground, color)
}

void JPlatformTheme::setTextFieldBorder(const QColor &color)
{
    SHORTCUTSETCOLOR(TextFieldBorder, textFieldBorder, color)
}

void JPlatformTheme::setTextFieldSelectColor(const QColor &color)
{
    SHORTCUTSETCOLOR(TextFieldSelectColor, textFieldSelectColor, color)
}

void JPlatformTheme::setIconForeground(const QColor &color)
{
    SHORTCUTSETCOLOR(IconForeground, iconForeground, color)
}

void JPlatformTheme::setIconMinorForeground(const QColor &color)
{
    SHORTCUTSETCOLOR(IconMinorForeground, iconMinorForeground, color)
}

void JPlatformTheme::setIconDisableForeground(const QColor &color)
{
    SHORTCUTSETCOLOR(IconDisableForeground, iconDisableForeground, color)
}

void JPlatformTheme::setButtonForeground(const QColor &color)
{
    SHORTCUTSETCOLOR(ButtonForeground, buttonForeground, color)
}

void JPlatformTheme::setButtonBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(ButtonBackground, buttonBackground, color)
}

void JPlatformTheme::setButtonBorder(const QColor &color)
{
    SHORTCUTSETCOLOR(ButtonBorder, buttonBorder, color)
}

void JPlatformTheme::setButtonWeakForeground(const QColor &color)
{
    SHORTCUTSETCOLOR(ButtonWeakForeground, buttonWeakForeground, color)
}

void JPlatformTheme::setButtonWeakBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(ButtonWeakBackground, buttonWeakBackground, color)
}

void JPlatformTheme::setButtonWeakBorder(const QColor &color)
{
    SHORTCUTSETCOLOR(ButtonWeakBorder, buttonWeakBorder, color)
}

void JPlatformTheme::setButtonStrongForeground(const QColor &color)
{
    SHORTCUTSETCOLOR(ButtonStrongForeground, buttonStrongForeground, color)
}

void JPlatformTheme::setButtonStrongBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(ButtonStrongBackground, buttonStrongBackground, color)
}

void JPlatformTheme::setButtonStrongBorder(const QColor &color)
{
    SHORTCUTSETCOLOR(ButtonStrongBorder, buttonStrongBorder, color)
}

void JPlatformTheme::setButtonPopupForeground(const QColor &color)
{
    SHORTCUTSETCOLOR(ButtonPopupForeground, buttonPopupForeground, color)
}

void JPlatformTheme::setButtonPopupBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(ButtonPopupBackground, buttonPopupBackground, color)
}

void JPlatformTheme::setButtonPopupBorder(const QColor &color)
{
    SHORTCUTSETCOLOR(ButtonPopupBorder, buttonPopupBorder, color)
}

void JPlatformTheme::setHighlightColor(const QColor &color)
{
    SHORTCUTSETCOLOR(HighlightColor, highlightColor, color)
}

void JPlatformTheme::setHighlightLinearColor(const QColor &color)
{
    SHORTCUTSETCOLOR(HighlightLinearColor, highlightLinearColor, color)
}

void JPlatformTheme::setHighlightRed(const QColor &color)
{
    SHORTCUTSETCOLOR(HighlightRed, highlightRed, color)
}

void JPlatformTheme::setHighlightGreen(const QColor &color)
{
    SHORTCUTSETCOLOR(HighlightGreen, highlightGreen, color)
}

void JPlatformTheme::setHighlightBlue(const QColor &color)
{
    SHORTCUTSETCOLOR(HighlightBlue, highlightBlue, color)
}

void JPlatformTheme::setHighlightYellow(const QColor &color)
{
    SHORTCUTSETCOLOR(HighlightYellow, highlightYellow, color)
}

void JPlatformTheme::setHighlightOrange(const QColor &color)
{
    SHORTCUTSETCOLOR(HighlightOrange, highlightOrange, color)
}

void JPlatformTheme::setHighlightPurple(const QColor &color)
{
    SHORTCUTSETCOLOR(HighlightPurple, highlightPurple, color)
}

void JPlatformTheme::setHighlightRoseRed(const QColor &color)
{
    SHORTCUTSETCOLOR(HighlightRoseRed, highlightRoseRed, color)
}

void JPlatformTheme::setHighlightPink(const QColor &color)
{
    SHORTCUTSETCOLOR(HighlightPink, highlightPink, color)
}

void JPlatformTheme::setSettingMajorBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(SettingMajorBackground, settingMajorBackground, color)
}

void JPlatformTheme::setSettingMinorBackground(const QColor &color)
{
    SHORTCUTSETCOLOR(SettingMinorBackground, settingMinorBackground, color)
}

void JPlatformTheme::setThemeName(const QString &name)
{
    Q_D(JPlatformTheme);
    if(d->m_nThemeName != name){
        d->m_nThemeName = name;
        Q_EMIT themeNameChanged();
    }
}

void JPlatformTheme::setColorScheme(const QString &name)
{
    Q_D(JPlatformTheme);
    if(d->m_nColorScheme != name){
        d->m_nColorScheme = name;
        Q_EMIT colorSchemeChanged();
    }
}
