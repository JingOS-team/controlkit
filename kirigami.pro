TEMPLATE = lib
CONFIG += plugin

QT          += qml quick gui svg
HEADERS     += $$PWD/src/kirigamiplugin.h $$PWD/src/enums.h $$PWD/src/settings.h
SOURCES     += $$PWD/src/kirigamiplugin.cpp $$PWD/src/enums.cpp $$PWD/src/settings.cpp
RESOURCES   += $$PWD/kirigami.qrc

!ios:!android {
    message( "compiling for desktop" )
    HEADERS += $$PWD/src/desktopicon.h
    SOURCES += $$PWD/src/desktopicon.cpp
}

API_VER=1.0

TARGET = $$qtLibraryTarget(org/kde/kirigami.2/kirigamiplugin)

importPath = $$[QT_INSTALL_QML]/org/kde/kirigami.2
target.path = $${importPath}

controls.path = $${importPath}
controls.files += $$PWD/src/controls/*

#For now ignore Desktop and Plasma stuff in qmake
styles.path = $${importPath}/styles
styles.files += $$PWD/src/styles/*

INSTALLS    += target controls styles






