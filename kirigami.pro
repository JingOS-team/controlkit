TEMPLATE = lib
CONFIG += static plugin
INCLUDEPATH += . \
                ./core \
            /usr/include/KF5/KWindowSystem \
            /usr/include/KF5/KDBusAddons \
            /usr/include/KF5/KCrash \
            /usr/include/KF5/KService \
            /usr/include/KF5/KConfigCore \
            /usr/include/KF5/KDeclarative \
            /usr/include/kworkspace5 \
            /usr/include/KF5/KDELibs4Support \
            /usr/include/KF5/KXmlGui \
            /usr/include/KF5/KCMUtils \
            /usr/include/KF5/KWidgetsAddons \
            /usr/include/KF5/KConfigWidgets \
            /usr/include/KF5/KConfigGui \
            /usr/include/KF5/KCompletion \
            /usr/include/KF5/KI18n \
            /usr/include/KF5/KCoreAddons


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

DISTFILES +=






