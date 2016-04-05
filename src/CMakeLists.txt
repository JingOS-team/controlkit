project(kirigami)

set(kirigami_SRCS
    kirigamiplugin.cpp
    )

add_library(kirigamiplugin SHARED ${kirigami_SRCS})
target_link_libraries(kirigamiplugin Qt5::Core  Qt5::Qml Qt5::Quick)

install(TARGETS kirigamiplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami)


install(DIRECTORY qml/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami)


#TODO: use the same way qquickcontrols2 uses to select if possible (needs a C++ plugin)
if(HAVE_PLASMA)
    FILE(GLOB platformspecific ${PROJECT_SOURCE_DIR}/plasmatheme/*)
else()
    FILE(GLOB platformspecific ${PROJECT_SOURCE_DIR}/fallbacktheme/*)
endif()


install(FILES ${platformspecific} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami)
