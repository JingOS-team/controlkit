QT          += core qml quick gui svg network quickcontrols2 concurrent
HEADERS     += $$PWD/src/jingoscontrolkitplugin.h

SOURCES     += $$PWD/src/jingoscontrolkitplugin.cpp

INCLUDEPATH += $$PWD/src
DEFINES     += JINGOSCONTRILKIT_BUILD_TYPE_STATIC

API_VER=1.0

RESOURCES += $$PWD/src/jingoscontrolkit.qrc

