project(kirigami)

if (NOT STATIC_LIBRARY)
    ecm_create_qm_loader(kirigami_QM_LOADER libkirigami2plugin_qt)
else()
    set(KIRIGAMI_STATIC_FILES
        libkirigami/basictheme.cpp
        libkirigami/platformtheme.cpp
        libkirigami/kirigamipluginfactory.cpp)
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/libkirigami ${CMAKE_CURRENT_BINARY_DIR}/libkirigami)

set(kirigami_SRCS
    kirigamiplugin.cpp
    enums.cpp
    desktopicon.cpp
    settings.cpp
    ${kirigami_QM_LOADER}
    ${KIRIGAMI_STATIC_FILES}
    )

IF(STATIC_LIBRARY)

qt5_add_resources(RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/../kirigami.qrc)

add_library(kirigamiplugin STATIC ${kirigami_SRCS} ${RESOURCES})
target_link_libraries(kirigamiplugin Qt5::Core  Qt5::Qml Qt5::Quick)

ELSE(STATIC_LIBRARY)

add_subdirectory(libkirigami)
add_library(kirigamiplugin SHARED ${kirigami_SRCS})

set_target_properties(kirigamiplugin PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin/org/kde/kirigami.2)
target_link_libraries(kirigamiplugin KF5::Kirigami2 Qt5::Core  Qt5::Qml Qt5::Quick)


add_custom_target(copy)

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/bin/org/kde/kirigami.2)
add_custom_command(TARGET copy PRE_BUILD
                    COMMAND ${CMAKE_COMMAND} -E
                        copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/controls ${CMAKE_BINARY_DIR}/bin/org/kde/kirigami.2/)
add_custom_command(TARGET copy PRE_BUILD
                    COMMAND ${CMAKE_COMMAND} -E
                        copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/styles  ${CMAKE_BINARY_DIR}/bin/org/kde/kirigami.2/styles)

add_dependencies(kirigamiplugin copy)


install(TARGETS kirigamiplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami.2)

install(DIRECTORY controls/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami.2)

if (PLASMA_ENABLED)
    install(DIRECTORY styles/Plasma DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami.2/styles)
endif()
if (DESKTOP_ENABLED)
    install(DIRECTORY styles/org.kde.desktop DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami.2/styles)
endif()
if (PLASMA_ENABLED AND DESKTOP_ENABLED)
install(DIRECTORY styles/org.kde.desktop.plasma DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami.2/styles)
endif()
install(DIRECTORY styles/Material DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami.2/styles)

install(FILES ${platformspecific} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami.2)

include(ECMGeneratePriFile)
ecm_generate_pri_file(BASE_NAME Kirigami2 LIB_NAME KF5Kirigami2 DEPS "core qml quick svg" FILENAME_VAR PRI_FILENAME )
install(FILES ${PRI_FILENAME}
        DESTINATION ${ECM_MKSPECS_INSTALL_DIR})

ENDIF(STATIC_LIBRARY)
