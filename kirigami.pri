
QT          += qml quick gui svg quickcontrols2
HEADERS     += $$PWD/src/kirigamiplugin.h \
               $$PWD/src/enums.h \
               $$PWD/src/settings.h \
               $$PWD/src/libkirigami/basictheme_p.h \
               $$PWD/src/libkirigami/platformtheme.h \
               $$PWD/src/libkirigami/platformthemefactory.h
SOURCES     += $$PWD/src/kirigamiplugin.cpp \
               $$PWD/src/enums.cpp \
               $$PWD/src/settings.cpp \
               $$PWD/src/libkirigami/basictheme.cpp \
               $$PWD/src/libkirigami/platformtheme.cpp \
               $$PWD/src/libkirigami/platformthemefactory.cpp
INCLUDEPATH += $$PWD/src
DEFINES     += KIRIGAMI_BUILD_TYPE_STATIC

!ios:!android {
    message( "compiling for desktop" )
    HEADERS += $$PWD/src/desktopicon.h
    SOURCES += $$PWD/src/desktopicon.cpp
}

API_VER=1.0

RESOURCES += $$PWD/kirigami.qrc

exists($$_PRO_FILE_PWD_/kirigami-icons.qrc) {
    message("Using icons QRC file shipped by the project")
    RESOURCES += $$_PRO_FILE_PWD_/kirigami-icons.qrc
} else {
    message("Using icons QRCfile shipped in kirigami")
    RESOURCES += $$PWD/kirigami-icons.qrc
}
