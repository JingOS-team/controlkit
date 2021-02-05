project(jingoscontrolkit)

if (BUILD_SHARED_LIBS)
    ecm_create_qm_loader(JingOSControlKit_QM_LOADER libjingoscontrolkitplugin_qt)
else()
#    set(JINGOSCONTROLKIT_STATIC_FILES
#        libkirigami/basictheme.cpp
#        libkirigami/platformtheme.cpp
#        libkirigami/tabletmodewatcher.cpp
#        libkirigami/kirigamipluginfactory.cpp)
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/libjingoscontrolkit ${CMAKE_CURRENT_BINARY_DIR}/libjingoscontrolkit)

set(JingOSControlKit_SRCS
    jingoscontrolkitplugin.cpp
    ${jingoscontrolkit_QM_LOADER}
    ${JINGOSCONTROLKIT_STATIC_FILES}
    )

#qt5_add_resources(SHADERS scenegraph/shaders/shaders.qrc)

#add_subdirectory(libkirigami)

if(NOT BUILD_SHARED_LIBS)
    # `rcc` is a bit dumb and isn't designed to use auto generated files, to
    # avoid poluting the source directory, use absolute paths
    set(Jingoscontrolkit_QML_DIR ${CMAKE_CURRENT_SOURCE_DIR}/controls1.0)

    # First, pre-process the QRC to add the files associated with the right Qt
    # version.
    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/../jingoscontrolkit.qrc.in
        ${CMAKE_CURRENT_BINARY_DIR}/../jingoscontrolkit.qrc
        @ONLY
    )

    # When using the static library, all QML files need to be shipped within the
    # .a file.
    qt5_add_resources(
        RESOURCES ${CMAKE_CURRENT_BINARY_DIR}/../jingoscontrolkit.qrc
    )

#    if (UNIX AND NOT ANDROID AND NOT(APPLE) AND NOT(DISABLE_DBUS))
#        qt5_add_dbus_interface(kirigami_SRCS libkirigami/org.kde.KWin.TabletModeManager.xml tabletmodemanager_interface)
#    endif()
endif()


add_library(jingoscontrolkitplugin ${JingOSControlKit_SRCS} ${RESOURCES}) #${SHADERS})

if(NOT BUILD_SHARED_LIBS)
    SET_TARGET_PROPERTIES(jingoscontrolkitplugin PROPERTIES
        AUTOMOC_MOC_OPTIONS -Muri=com.jingos.controlkit)
    if (UNIX AND NOT ANDROID AND NOT(APPLE) AND NOT(DISABLE_DBUS))
        set(JingOSControlKit_EXTRA_LIBS Qt5::DBus)
    else()
        set(JingOSControlKit_EXTRA_LIBS "")
    endif()
else()
    if(WIN32)
        set_target_properties(jingoscontrolkitplugin PROPERTIES PREFIX "")
    endif()
#    set(Kirigami_EXTRA_LIBS KF5::Kirigami2)
endif()


target_link_libraries(jingoscontrolkitplugin
        PUBLIC
            Qt5::Core
        PRIVATE
            ${JingOSControlKit_EXTRA_LIBS} Qt5::Qml Qt5::Quick Qt5::QuickControls2 Qt5::Concurrent
    )

if (BUILD_SHARED_LIBS)
    add_custom_target(copy_to_bin ALL
        COMMAND ${CMAKE_COMMAND} -E
                make_directory ${CMAKE_BINARY_DIR}/bin/com/jingos/controlkit.1.0/
        COMMAND ${CMAKE_COMMAND} -E
                copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/controls ${CMAKE_BINARY_DIR}/bin/com/jingos/controlkit.1.0/
#        COMMAND ${CMAKE_COMMAND} -E
#                copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/styles  ${CMAKE_BINARY_DIR}/bin/com/jingos/controlkit.1.0/styles
        COMMAND ${CMAKE_COMMAND} -E
                copy $<TARGET_FILE:jingoscontrolkitplugin> ${CMAKE_BINARY_DIR}/bin/com/jingos/controlkit.1.0/
    )

    install(DIRECTORY controls/ DESTINATION ${KDE_INSTALL_QMLDIR}/com/jingos/controlkit.1.0/)

#    if (DESKTOP_ENABLED)
#        install(DIRECTORY styles/org.kde.desktop DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami.2/styles)
#    endif()
#    install(DIRECTORY styles/Material DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami.2/styles)

    install(FILES ${platformspecific} DESTINATION ${KDE_INSTALL_QMLDIR}/com/jingos/controlkit.1.0/)

    include(ECMGeneratePriFile)
    ecm_generate_pri_file(BASE_NAME JingOSControlKit1.0 LIB_NAME JingOSControlKit1.0 DEPS "core qml quick svg" FILENAME_VAR PRI_FILENAME )
    install(FILES ${PRI_FILENAME}
            DESTINATION ${ECM_MKSPECS_INSTALL_DIR})

endif()

install(TARGETS jingoscontrolkitplugin DESTINATION ${KDE_INSTALL_QMLDIR}/com/jingos/controlkit.1.0/)
