
QT          += qml quick gui svg
HEADERS     += $$PWD/src/kirigamiplugin.h $$PWD/src/enums.h
SOURCES     += $$PWD/src/kirigamiplugin.cpp $$PWD/src/enums.cpp
INCLUDEPATH += $$PWD/src
DEFINES     += KIRIGAMI_BUILD_TYPE_STATIC

API_VER=1.0

RESOURCES += $$PWD/kirigami.qrc

#QML_IMPORT_PATH += $$PWD
