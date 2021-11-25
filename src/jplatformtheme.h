/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#ifndef JPLATFORMTHEME_H
#define JPLATFORMTHEME_H

#include <QObject>
#include <QPalette>
#include <QQuickItem>
#include <QQuickWindow>
class JPlatformThemePrivate;
class JPlatformTheme : public QObject
{
    Q_OBJECT
    Q_DECLARE_PRIVATE(JPlatformTheme)
    Q_PROPERTY(QString themeName READ themeName NOTIFY themeNameChanged)
    Q_PROPERTY(QString colorScheme READ colorScheme WRITE setColorScheme NOTIFY colorSchemeChanged)
    Q_PROPERTY(QColor majorForeground READ majorForeground WRITE setMajorForeground NOTIFY majorForegroundChanged)
    Q_PROPERTY(QColor minorForeground READ minorForeground WRITE setMinorForeground NOTIFY minorForegroundChanged)
    Q_PROPERTY(QColor disableForeground READ disableForeground WRITE setDisableForeground NOTIFY disableForegroundChanged)
    Q_PROPERTY(QColor dividerForeground READ dividerForeground WRITE setDividerForeground NOTIFY dividerForegroundChanged)

    Q_PROPERTY(QColor background READ background WRITE setBackground NOTIFY backgroundChanged)
    Q_PROPERTY(QColor cardBackground READ cardBackground WRITE setCardBackground NOTIFY cardBackgroundChanged)
    Q_PROPERTY(QColor headerBackground READ headerBackground WRITE setHeaderBackground NOTIFY headerBackgroundChanged)
    Q_PROPERTY(QColor floatBackground READ floatBackground WRITE setFloatBackground NOTIFY floatBackgroundChanged)
    Q_PROPERTY(QColor overBackground READ overBackground WRITE setOverBackground NOTIFY overBackgroundChanged)
    Q_PROPERTY(QColor componentBackground READ componentBackground WRITE setComponentBackground NOTIFY componentBackgroundChanged)
    Q_PROPERTY(QColor currentBackground READ currentBackground WRITE setCurrentBackground NOTIFY currentBackgroundChanged)
    Q_PROPERTY(QColor textEditTipBackground READ textEditTipBackground WRITE setTextEditTipBackground NOTIFY textEditTipBackgroundChanged)
    Q_PROPERTY(QColor hoverBackground READ hoverBackground WRITE setHoverBackground NOTIFY hoverBackgroundChanged)
    Q_PROPERTY(QColor pressBackground READ pressBackground WRITE setPressBackground NOTIFY pressBackgroundChanged)


    Q_PROPERTY(QColor textFieldBackground READ textFieldBackground WRITE setTextFieldBackground NOTIFY textFieldBackgroundChanged)
    Q_PROPERTY(QColor textFieldBorder READ textFieldBorder WRITE setTextFieldBorder NOTIFY textFieldBorderChanged)
    Q_PROPERTY(QColor textFieldSelectColor READ textFieldSelectColor WRITE setTextFieldSelectColor NOTIFY textFieldSelectColorChanged)

    Q_PROPERTY(QColor iconForeground READ iconForeground WRITE setIconForeground NOTIFY iconForegroundChanged)
    Q_PROPERTY(QColor iconMinorForeground READ iconMinorForeground WRITE setIconMinorForeground NOTIFY iconMinorForegroundChanged)
    Q_PROPERTY(QColor iconDisableForeground READ iconDisableForeground WRITE setIconDisableForeground NOTIFY iconDisableForegroundChanged)


    Q_PROPERTY(QColor buttonForeground READ buttonForeground WRITE setButtonForeground NOTIFY buttonForegroundChanged)
    Q_PROPERTY(QColor buttonBackground READ buttonBackground WRITE setButtonBackground NOTIFY buttonBackgroundChanged)
    Q_PROPERTY(QColor buttonBorder READ buttonBorder WRITE setButtonBorder NOTIFY buttonBorderChanged)

    Q_PROPERTY(QColor buttonWeakForeground READ buttonWeakForeground WRITE setButtonWeakForeground NOTIFY buttonWeakForegroundChanged)
    Q_PROPERTY(QColor buttonWeakBackground READ buttonWeakBackground WRITE setButtonWeakBackground NOTIFY buttonWeakBackgroundChanged)
    Q_PROPERTY(QColor buttonWeakBorder READ buttonWeakBorder WRITE setButtonWeakBorder NOTIFY buttonWeakBorderChanged)

    Q_PROPERTY(QColor buttonStrongForeground READ buttonStrongForeground WRITE setButtonStrongForeground NOTIFY buttonStrongForegroundChanged)
    Q_PROPERTY(QColor buttonStrongBackground READ buttonStrongBackground WRITE setButtonStrongBackground NOTIFY buttonStrongBackgroundChanged)
    Q_PROPERTY(QColor buttonStrongBorder READ buttonStrongBorder WRITE setButtonStrongBorder NOTIFY buttonStrongBorderChanged)

    Q_PROPERTY(QColor buttonPopupForeground READ buttonPopupForeground WRITE setButtonPopupForeground NOTIFY buttonPopupForegroundChanged)
    Q_PROPERTY(QColor buttonPopupBackground READ buttonPopupBackground WRITE setButtonPopupBackground NOTIFY buttonPopupBackgroundChanged)
    Q_PROPERTY(QColor buttonPopupBorder READ buttonPopupBorder WRITE setButtonPopupBorder NOTIFY buttonPopupBorderChanged)



    Q_PROPERTY(QColor highlightColor READ highlightColor WRITE setHighlightColor NOTIFY highlightColorChanged)
    Q_PROPERTY(QColor highlightLinearColor READ highlightLinearColor WRITE setHighlightLinearColor NOTIFY highlightLinearColorChanged)
    Q_PROPERTY(QColor highlightRed READ highlightRed WRITE setHighlightRed NOTIFY highlightRedChanged)
    Q_PROPERTY(QColor highlightGreen READ highlightGreen WRITE setHighlightGreen NOTIFY highlightGreenChanged)
    Q_PROPERTY(QColor highlightBlue READ highlightBlue WRITE setHighlightBlue NOTIFY highlightBlueChanged)
    Q_PROPERTY(QColor highlightYellow READ highlightYellow WRITE setHighlightYellow NOTIFY highlightYellowChanged)
    Q_PROPERTY(QColor highlightOrange READ highlightOrange WRITE setHighlightOrange NOTIFY highlightOrangeChanged)
    Q_PROPERTY(QColor highlightPurple READ highlightPurple WRITE setHighlightPurple NOTIFY highlightPurpleChanged)
    Q_PROPERTY(QColor highlightRoseRed READ highlightRoseRed WRITE setHighlightRoseRed NOTIFY highlightRoseRedChanged)
    Q_PROPERTY(QColor highlightPink READ highlightPink WRITE setHighlightPink NOTIFY highlightPinkChanged)

    Q_PROPERTY(QColor settingMajorBackground READ settingMajorBackground WRITE setSettingMajorBackground NOTIFY settingMajorBackgroundChanged)
    Q_PROPERTY(QColor settingMinorBackground READ settingMinorBackground WRITE setSettingMinorBackground NOTIFY settingMinorBackgroundChanged)


public:

    explicit JPlatformTheme(QObject* parent = nullptr);
    ~JPlatformTheme();

    static JPlatformThemePrivate* getPriv(JPlatformTheme* obj){ return obj == nullptr ? nullptr : obj->d_func();}

    //QML attached property
    static JPlatformTheme* qmlAttachedProperties(QObject *object);

    QString themeName() const;
    QString colorScheme() const;

    QColor majorForeground() const;
    QColor minorForeground() const;
    QColor disableForeground() const;
    QColor dividerForeground() const;



    QColor background() const;
    QColor cardBackground() const;
    QColor headerBackground() const;
    QColor floatBackground() const;
    QColor overBackground() const;
    QColor componentBackground() const;
    QColor currentBackground() const;
    QColor textEditTipBackground() const;
    QColor hoverBackground() const;
    QColor pressBackground() const;


    QColor textFieldBackground() const;
    QColor textFieldBorder() const;
    QColor textFieldSelectColor() const;

    QColor iconForeground() const;
    QColor iconMinorForeground() const;
    QColor iconDisableForeground() const;

    QColor buttonForeground() const;
    QColor buttonBackground() const;
    QColor buttonBorder() const;

    QColor buttonWeakForeground() const;
    QColor buttonWeakBackground() const;
    QColor buttonWeakBorder() const;

    QColor buttonStrongForeground() const;
    QColor buttonStrongBackground() const;
    QColor buttonStrongBorder() const;

    QColor buttonPopupForeground() const;
    QColor buttonPopupBackground() const;
    QColor buttonPopupBorder() const;

    QColor highlightColor() const;
    QColor highlightLinearColor() const;
    QColor highlightRed() const;
    QColor highlightGreen() const;
    QColor highlightBlue() const;
    QColor highlightYellow() const;
    QColor highlightOrange() const;
    QColor highlightPurple() const;
    QColor highlightRoseRed() const;
    QColor highlightPink() const;

    QColor settingMajorBackground() const;
    QColor settingMinorBackground() const;

    //this may is used by the desktop QQC2 to set the styleoption palettes
//    QPalette palette() const;
//    static QColor tint(const QColor& c1, const QColor& c2, qreal ratio);


    //custom foreground colors
    void setCustomMajorForeground(const QColor &color);
    void setCustomMinorForeground(const QColor &color);
    void setCustomDisableForeground(const QColor &color);
    void setCustomDividerForeground(const QColor &color);

    void setCustomBackground(const QColor &color);
    void setCustomCardBackground(const QColor &color);
    void setCustomHeaderBackground(const QColor &color);
    void setCustomFloatBackground(const QColor &color);
    void setCustomOverBackground(const QColor &color);
    void setCustomComponentBackground(const QColor &color);

    void setCustomCurrentBackground(const QColor &color);
    void setCustomTextEditTipBackground(const QColor &color);
    void setCustomHoverBackground(const QColor &color);
    void setCustomPressBackground(const QColor &color);

    void setCustomTextFieldBackground(const QColor &color);
    void setCustomTextFieldBorder(const QColor &color);
    void setCustomTextFieldSelectColor(const QColor &color);

    void setCustomIconForeground(const QColor &color);
    void setCustomIconMinorForeground(const QColor &color);
    void setCustomIconDisableForeground(const QColor &color);

    void setCustomButtonForeground(const QColor &color);
    void setCustomButtonBackground(const QColor &color);
    void setCustomButtonBorder(const QColor &color);

    void setCustomButtonWeakForeground(const QColor &color);
    void setCustomButtonWeakBackground(const QColor &color);
    void setCustomButtonWeakBorder(const QColor &color);

    void setCustomButtonStrongForeground(const QColor &color);
    void setCustomButtonStrongBackground(const QColor &color);
    void setCustomButtonStrongBorder(const QColor &color);


Q_SIGNALS:

    void themeNameChanged();
    void colorSchemeChanged();
    void majorForegroundChanged();
    void minorForegroundChanged();
    void disableForegroundChanged();
    void dividerForegroundChanged();

    void backgroundChanged();
    void cardBackgroundChanged();
    void headerBackgroundChanged();
    void floatBackgroundChanged();
    void overBackgroundChanged();
    void componentBackgroundChanged();
    void currentBackgroundChanged();
    void textEditTipBackgroundChanged();
    void hoverBackgroundChanged();
    void pressBackgroundChanged();

    void textFieldBackgroundChanged();
    void textFieldBorderChanged();
    void textFieldSelectColorChanged();

    void iconForegroundChanged();
    void iconMinorForegroundChanged();
    void iconDisableForegroundChanged();

    void buttonForegroundChanged();
    void buttonBackgroundChanged();
    void buttonBorderChanged();

    void buttonWeakForegroundChanged();
    void buttonWeakBackgroundChanged();
    void buttonWeakBorderChanged();

    void buttonStrongForegroundChanged();
    void buttonStrongBackgroundChanged();
    void buttonStrongBorderChanged();

    void buttonPopupForegroundChanged();
    void buttonPopupBackgroundChanged();
    void buttonPopupBorderChanged();

    void highlightColorChanged();
    void highlightLinearColorChanged();
    void highlightRedChanged();
    void highlightGreenChanged();
    void highlightBlueChanged();
    void highlightYellowChanged();
    void highlightOrangeChanged();
    void highlightPurpleChanged();
    void highlightRoseRedChanged();
    void highlightPinkChanged();

    void settingMajorBackgroundChanged();
    void settingMinorBackgroundChanged();

    void defaultFontChanged(const QFont &font);
    void smallFontChanged(const QFont &font);

protected:
    void setThemeName(const QString& name);
    void setColorScheme(const QString& name);
    //foreground colors
    void setMajorForeground(const QColor &color);
    void setMinorForeground(const QColor &color);
    void setDisableForeground(const QColor &color);
    void setDividerForeground(const QColor &color);

    void setBackground(const QColor &color);
    void setCardBackground(const QColor &color);
    void setHeaderBackground(const QColor &color);
    void setFloatBackground(const QColor &color);
    void setOverBackground(const QColor &color);
    void setComponentBackground(const QColor &color);
    void setCurrentBackground(const QColor &color);
    void setTextEditTipBackground(const QColor &color);
    void setHoverBackground(const QColor &color);
    void setPressBackground(const QColor &color);

    void setTextFieldBackground(const QColor &color);
    void setTextFieldBorder(const QColor &color);
    void setTextFieldSelectColor(const QColor &color);

    void setIconForeground(const QColor &color);
    void setIconMinorForeground(const QColor &color);
    void setIconDisableForeground(const QColor &color);

    void setButtonForeground(const QColor &color);
    void setButtonBackground(const QColor &color);
    void setButtonBorder(const QColor &color);

    void setButtonWeakForeground(const QColor &color);
    void setButtonWeakBackground(const QColor &color);
    void setButtonWeakBorder(const QColor &color);

    void setButtonStrongForeground(const QColor &color);
    void setButtonStrongBackground(const QColor &color);
    void setButtonStrongBorder(const QColor &color);

    void setButtonPopupForeground(const QColor &color);
    void setButtonPopupBackground(const QColor &color);
    void setButtonPopupBorder(const QColor &color);

    void setHighlightColor(const QColor &color);
    void setHighlightLinearColor(const QColor &color);
    void setHighlightRed(const QColor &color);
    void setHighlightGreen(const QColor &color);
    void setHighlightBlue(const QColor &color);
    void setHighlightYellow(const QColor &color);
    void setHighlightOrange(const QColor &color);
    void setHighlightPurple(const QColor &color);
    void setHighlightRoseRed(const QColor &color);
    void setHighlightPink(const QColor &color);

    void setSettingMajorBackground(const QColor &color);
    void setSettingMinorBackground(const QColor &color);


protected:
    QScopedPointer<JPlatformThemePrivate> d_ptr;
};
QML_DECLARE_TYPEINFO(JPlatformTheme, QML_HAS_ATTACHED_PROPERTIES)
#endif // JPLATFORMTHEME_H
