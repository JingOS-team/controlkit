TEMPLATE = lib
CONFIG += static plugin

URI = org.kde.kirigami
QMAKE_MOC_OPTIONS += -Muri=org.kde.kirigami
include(kirigami.pri)

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






