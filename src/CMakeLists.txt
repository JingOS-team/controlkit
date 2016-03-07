project(kirigami)

set(kirigami_SRCS
    kirigamiplugin.cpp
    )

add_library(kirigamiplugin SHARED ${kirigami_SRCS})
target_link_libraries(kirigamiplugin Qt5::Core  Qt5::Qml Qt5::Quick)

install(TARGETS kirigamiplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami)


install(DIRECTORY qml/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami)


#TODO: install the plasmaless version at build time
#TODO: use the same way qquickcontrols2 uses to select if possible
FILE(GLOB platformspecific ${PROJECT_SOURCE_DIR}/plasmatheme/*)


install(FILES ${platformspecific} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami)

install(DIRECTORY example/ DESTINATION ${CMAKE_INSTALL_PREFIX}/${DATA_INSTALL_DIR}/kpackage/genericqml/org.kde.kirigami.gallery)
install(FILES example/metadata.desktop DESTINATION ${XDG_APPS_INSTALL_DIR} RENAME org.kde.kirigami.gallery.desktop)
