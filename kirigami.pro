TEMPLATE = lib
CONFIG += plugin

QT          += qml quick gui svg
HEADERS     += $$PWD/src/kirigamiplugin.h $$PWD/src/enums.h
SOURCES     += $$PWD/src/kirigamiplugin.cpp $$PWD/src/enums.cpp
RESOURCES   += $$PWD/kirigami.qrc

API_VER=1.0

TARGET = $$qtLibraryTarget(org/kde/kirigamiplugin)

importPath = $$[QT_INSTALL_QML]/org/kde/kirigami
target.path = $${importPath}

controls.path = $${importPath}
controls.files += $$PWD/src/controls/*

#For now ignore Desktop and Plasma stuff in qmake
#styles.path = $${importPath}/styles
#styles.files += $$PWD/src/styles/*

INSTALLS    += target controls






