QT          += core qml quick gui svg network quickcontrols2 concurrent
HEADERS     += $$PWD/src/kirigamiplugin.h \
               $$PWD/src/enums.h \
               $$PWD/src/settings.h \
               $$PWD/src/colorutils.h \
               $$PWD/src/columnview_p.h \
               $$PWD/src/columnview.h \
               $$PWD/src/formlayoutattached.h \
               $$PWD/src/mnemonicattached.h \
               $$PWD/src/scenepositionattached.h \
               $$PWD/src/libkirigami/basictheme_p.h \
               $$PWD/src/libkirigami/platformtheme.h \
               $$PWD/src/libkirigami/kirigamipluginfactory.h \
               $$PWD/src/libkirigami/tabletmodewatcher.h \
               $$PWD/src/scenegraph/paintedrectangleitem.h \
               $$PWD/src/scenegraph/shadowedrectanglenode.h \
               $$PWD/src/scenegraph/shadowedborderrectanglematerial.h \
               $$PWD/src/scenegraph/shadowedbordertexturematerial.h \
               $$PWD/src/scenegraph/shadowedrectanglematerial.h \
               $$PWD/src/scenegraph/shadowedtexturematerial.h \
               $$PWD/src/scenegraph/shadowedtexturenode.h \
               $$PWD/src/icon.h \
               $$PWD/src/imagecolors.h \
               $$PWD/src/delegaterecycler.h \
               $$PWD/src/wheelhandler.h \
               $$PWD/src/shadowedrectangle.h \
               $$PWD/src/shadowedtexture.h \
               $$PWD/src/pagerouter.h \
               $$PWD/src/pagepool.h \
               $$PWD/src/avatar.h \
               $$PWD/src/toolbarlayout.h \
               $$PWD/src/toolbarlayoutdelegate.h
SOURCES     += $$PWD/src/kirigamiplugin.cpp \
               $$PWD/src/enums.cpp \
               $$PWD/src/settings.cpp \
               $$PWD/src/colorutils.cpp \
               $$PWD/src/columnview.cpp \
               $$PWD/src/formlayoutattached.cpp \
               $$PWD/src/mnemonicattached.cpp \
               $$PWD/src/scenepositionattached.cpp \
               $$PWD/src/libkirigami/basictheme.cpp \
               $$PWD/src/libkirigami/platformtheme.cpp \
               $$PWD/src/libkirigami/kirigamipluginfactory.cpp \
               $$PWD/src/libkirigami/tabletmodewatcher.cpp \
               $$PWD/src/scenegraph/paintedrectangleitem.cpp \
               $$PWD/src/scenegraph/shadowedrectanglenode.cpp \
               $$PWD/src/scenegraph/shadowedborderrectanglematerial.cpp \
               $$PWD/src/scenegraph/shadowedbordertexturematerial.cpp \
               $$PWD/src/scenegraph/shadowedrectanglematerial.cpp \
               $$PWD/src/scenegraph/shadowedtexturematerial.cpp \
               $$PWD/src/scenegraph/shadowedtexturenode.cpp \
               $$PWD/src/icon.cpp \
               $$PWD/src/imagecolors.cpp \
               $$PWD/src/delegaterecycler.cpp \
               $$PWD/src/wheelhandler.cpp \
               $$PWD/src/shadowedrectangle.cpp \
               $$PWD/src/shadowedtexture.cpp \
               $$PWD/src/pagerouter.cpp \
               $$PWD/src/pagepool.cpp \
               $$PWD/src/avatar.cpp \
               $$PWD/src/toolbarlayout.cpp \
               $$PWD/src/toolbarlayoutdelegate.cpp

INCLUDEPATH += $$PWD/src $$PWD/src/libkirigami
DEFINES     += KIRIGAMI_BUILD_TYPE_STATIC

API_VER=1.0

RESOURCES += $$PWD/kirigami.qrc $$PWD/src/scenegraph/shaders/shaders.qrc

exists($$_PRO_FILE_PWD_/kirigami-icons.qrc) {
    message("Using icons QRC file shipped by the project")
    RESOURCES += $$_PRO_FILE_PWD_/kirigami-icons.qrc
} else {
    message("Using icons QRCfile shipped in kirigami")
    RESOURCES += $$PWD/kirigami-icons.qrc
}
