/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

pragma Singleton

import QtQuick 2.4
import QtQml 2.12
import org.kde.kirigami 2.15


QtObject {

    property string themeName: JPlatformTheme.themeName
    property string colorScheme: JPlatformTheme.colorScheme  //jingosLight  jingosDark

    property color majorForeground: JPlatformTheme.majorForeground         //#FF000000          #FFF7F7F7
    property color minorForeground: JPlatformTheme.minorForeground         //#8C000000          #8CF7F7F7
    property color disableForeground: JPlatformTheme.disableForeground     //#4C000000          #4CF7F7F7
    property color dividerForeground: JPlatformTheme.dividerForeground     //#1E000000          #1EF7F7F7


    property color background: JPlatformTheme.background                   //#FFE8EFFF          #FF000000
    property color cardBackground: JPlatformTheme.cardBackground           //#FFFFFFFF          #FF1D1D1F
    property color headerBackground: JPlatformTheme.headerBackground       //#B2FFFFFF          #CC2B2B2C
    property color floatBackground: JPlatformTheme.floatBackground         //#99FFFFFF          #9926262A
    property color overBackground: JPlatformTheme.overBackground           //#7F000000          #B2000000
    property color componentBackground: JPlatformTheme.componentBackground //#1E767680          #338E8E93
    property color currentBackground: JPlatformTheme.currentBackground         //#F2FFFFFF      #4C9F9FAA
    property color textEditTipBackground: JPlatformTheme.textEditTipBackground //#E6303030      #E6303030
    property color hoverBackground: JPlatformTheme.hoverBackground             //#14767680      #33767680
    property color pressBackground: JPlatformTheme.pressBackground             //#1E767680      #4C767680


    property color textFieldBackground: JPlatformTheme.textFieldBackground     //#FFFFFFFF      #FF1D1D1F
    property color textFieldBorder: JPlatformTheme.textFieldBorder             //#FF3C4BE8       #FF456BFF
    property color textFieldSelectColor: JPlatformTheme.textFieldSelectColor   //#333F50FF      #333F50FF


    property color iconForeground: JPlatformTheme.iconForeground               //#FF000000      #FFF7F7F7
    property color iconMinorForeground: JPlatformTheme.iconMinorForeground     //#8C000000      #FF8E8E93
    property color iconDisableForeground: JPlatformTheme.iconDisableForeground //#4C000000      #4cF7F7F7


    property color buttonForeground: JPlatformTheme.buttonForeground           //#FF000000      #FFFFFFFF
    property color buttonBackground: JPlatformTheme.buttonBackground           //#FFFFFFFF      #FF1D1D1F
    property color buttonBorder: JPlatformTheme.buttonBorder                   //#FFCDD0D7      #8cF7F7F7

    property color buttonWeakForeground: JPlatformTheme.buttonWeakForeground   //#FF3C4BE8      #FF3C4BE8
    property color buttonWeakBackground: JPlatformTheme.buttonWeakBackground   //#FFFFFFFF      #FF1D1D1F
    property color buttonWeakBorder: JPlatformTheme.buttonWeakBorder           //#FF3C4BE8      #FF456BFF

    property color buttonStrongForeground: JPlatformTheme.buttonStrongForeground  //#FFFFFFFF    #FFFFFF
    property color buttonStrongBackground: JPlatformTheme.buttonStrongBackground  //#FF3C4BE8    #3F50FF
    property color buttonStrongBorder: JPlatformTheme.buttonStrongBorder          //#FF3C4BE8    #FF3F50FF

    property color buttonPopupForeground: JPlatformTheme.buttonPopupForeground    //#FF000000    #FFFFFFFF
    property color buttonPopupBackground: JPlatformTheme.buttonPopupBackground    //#CCE4E9EC    #4C000000
    property color buttonPopupBorder: JPlatformTheme.buttonPopupBorder            //#CCE4E9EC    #4C000000

    property color highlightColor:JPlatformTheme.highlightColor                   //#FF3C4BE8    #FF3F50FF
    property color highlightLinearColor:JPlatformTheme.highlightLinearColor       //#FF3C4BE8    #FF456BFF
    property color highlightRed:JPlatformTheme.highlightRed                       //#FFE95B4E    #FFE95B4E
    property color highlightGreen:JPlatformTheme.highlightGreen                   //#FF39C17B    #FF39C17B
    property color highlightBlue:JPlatformTheme.highlightBlue                     //#FF5AC8FA    #FF5AC8FA
    property color highlightYellow:JPlatformTheme.highlightYellow                 //#FFFDD32E    #FFFDD32E
    property color highlightOrange:JPlatformTheme.highlightOrange                 //#FFFF9B5F    #FFFF9B5F
    property color highlightPurple:JPlatformTheme.highlightPurple                 //#FF824BFF    #FF824BFF
    property color highlightRoseRed:JPlatformTheme.highlightRoseRed               //#FFC558F2    #FFC558F2
    property color highlightPink:JPlatformTheme.highlightPink                     //#FFFF2D55    #FFFF2D55

    property color settingMajorBackground: JPlatformTheme.settingMajorBackground  //#FFE8EFFF    #FF1D1D1F
    property color settingMinorBackground: JPlatformTheme.settingMinorBackground  //#FFF6F9FF    #FF000000


    property variant defaultFont: JPlatformTheme.defaultFont
    property variant smallFont: JPlatformTheme.smallFont
}
