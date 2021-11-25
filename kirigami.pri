QT          += core qml quick gui svg network quickcontrols2 concurrent dbus multimedia
HEADERS     += $$PWD/src/kirigamiplugin.h \
               $$PWD/jingosDisplay/jdisplaymetrics.h \
               $$PWD/jingosDisplay/jingosDisplayPlugin.h \
               $$PWD/jingosMultimedia/jbasevideosurface.h \
               $$PWD/jingosMultimedia/jmultimediaModuleplugin.h \
               $$PWD/jingosMultimedia/mpvobject.h \
               $$PWD/jingosMultimedia/mpvrenderitem.h \
               $$PWD/jingosMultimedia/player.h \
               $$PWD/jingosMultimedia/qthelper.h \
               $$PWD/src/ImagePreview/jexiv2extractor.h \
               $$PWD/src/ImagePreview/jimagedocument.h \
               $$PWD/src/ImagePreview/jresizehandle.h \
               $$PWD/src/ImagePreview/jresizerectangle.h \
               $$PWD/src/ImagePreview/jwallpapersettings.h \
               $$PWD/src/ThemePrivate/jbasictheme.h \
               $$PWD/src/ThemePrivate/jbasictheme_p.h \
               $$PWD/src/ThemePrivate/jplatformtheme_p.h \
               $$PWD/src/ThemePrivate/jthememanager_p.h \
               $$PWD/src/enums.h \
               $$PWD/src/jdisplaymetrics.h \
               $$PWD/src/jfont.h \
               $$PWD/src/jplatformtheme.h \
               $$PWD/src/jthememanager.h \
               $$PWD/src/player.h \
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
               $$PWD/src/scenegraph/managedtexturenode.h \
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
               $$PWD/src/sizegroup.h \
               $$PWD/src/pagerouter.h \
               $$PWD/src/pagepool.h \
               $$PWD/src/avatar.h \
               $$PWD/src/toolbarlayout.h \
               $$PWD/src/toolbarlayoutdelegate.h
SOURCES     += $$PWD/src/kirigamiplugin.cpp \
               $$PWD/jingosDisplay/jdisplaymetrics.cpp \
               $$PWD/jingosDisplay/jingosDisplayPlugin.cpp \
               $$PWD/jingosMultimedia/jbasevideosurface.cpp \
               $$PWD/jingosMultimedia/jmultimediaModuleplugin.cpp \
               $$PWD/jingosMultimedia/mpvobject.cpp \
               $$PWD/jingosMultimedia/mpvrenderitem.cpp \
               $$PWD/jingosMultimedia/player.cpp \
               $$PWD/src/ImagePreview/jexiv2extractor.cpp \
               $$PWD/src/ImagePreview/jimagedocument.cpp \
               $$PWD/src/ImagePreview/jresizehandle.cpp \
               $$PWD/src/ImagePreview/jresizerectangle.cpp \
               $$PWD/src/ImagePreview/jwallpapersettings.cpp \
               $$PWD/src/ThemePrivate/jbasictheme.cpp \
               $$PWD/src/ThemePrivate/jplatformtheme_p.cpp \
               $$PWD/src/ThemePrivate/jthememanager_p.cpp \
               $$PWD/src/enums.cpp \
               $$PWD/src/jdisplaymetrics.cpp \
               $$PWD/src/jfont.cpp \
               $$PWD/src/jplatformtheme.cpp \
               $$PWD/src/jthememanager.cpp \
               $$PWD/src/player.cpp \
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
               $$PWD/src/scenegraph/managedtexturenode.cpp \
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
               $$PWD/src/sizegroup.cpp \
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

SUBDIRS += \
    $$PWD/jingosDisplay/jingosDisplay.pro \
    $$PWD/jingosMultimedia/jingosMultimedia.pro

DISTFILES += \
    $$PWD/jingosDisplay/CMakeLists.txt \
    $$PWD/jingosDisplay/JDisplay.qml \
    $$PWD/jingosDisplay/qmldir \
    $$PWD/jingosMultimedia/CMakeLists.txt \
    $$PWD/jingosMultimedia/qmldir
