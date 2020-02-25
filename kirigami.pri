
QT          += core qml quick gui svg network quickcontrols2
HEADERS     += $$PWD/src/kirigamiplugin.h \
               $$PWD/src/enums.h \
               $$PWD/src/settings.h \
               $$PWD/src/columnview_p.h \
               $$PWD/src/columnview.h \
               $$PWD/src/formlayoutattached.h \
               $$PWD/src/mnemonicattached.h \
               $$PWD/src/scenepositionattached.h \
               $$PWD/src/libkirigami/basictheme_p.h \
               $$PWD/src/libkirigami/platformtheme.h \
               $$PWD/src/libkirigami/kirigamipluginfactory.h \
               $$PWD/src/libkirigami/tabletmodewatcher.h \
               $$PWD/src/icon.h \
               $$PWD/src/delegaterecycler.h \
               $$PWD/src/wheelhandler.h \
               $$PWD/src/pagepool.h
SOURCES     += $$PWD/src/kirigamiplugin.cpp \
               $$PWD/src/enums.cpp \
               $$PWD/src/settings.cpp \
               $$PWD/src/columnview.cpp \
               $$PWD/src/formlayoutattached.cpp \
               $$PWD/src/mnemonicattached.cpp \
               $$PWD/src/scenepositionattached.cpp \
               $$PWD/src/libkirigami/basictheme.cpp \
               $$PWD/src/libkirigami/platformtheme.cpp \
               $$PWD/src/libkirigami/kirigamipluginfactory.cpp \
               $$PWD/src/libkirigami/tabletmodewatcher.cpp \
               $$PWD/src/icon.cpp \
               $$PWD/src/delegaterecycler.cpp \
               $$PWD/src/wheelhandler.cpp \
               $$PWD/src/pagepool.cpp

INCLUDEPATH += $$PWD/src $$PWD/src/libkirigami
DEFINES     += KIRIGAMI_BUILD_TYPE_STATIC

API_VER=1.0

RESOURCES += $$PWD/kirigami.qrc

exists($$_PRO_FILE_PWD_/kirigami-icons.qrc) {
    message("Using icons QRC file shipped by the project")
    RESOURCES += $$_PRO_FILE_PWD_/kirigami-icons.qrc
} else {
    message("Using icons QRCfile shipped in kirigami")
    RESOURCES += $$PWD/kirigami-icons.qrc
}
