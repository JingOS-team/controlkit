project(kirigami)

set(kirigami_SRCS
    kirigamiplugin.cpp
    )

add_library(kirigamiplugin SHARED ${kirigami_SRCS})
target_link_libraries(kirigamiplugin Qt5::Core  Qt5::Qml Qt5::Quick)

install(TARGETS kirigamiplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami)

install(DIRECTORY controls/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami)

if (PLASMA_ENABLED)
    install(DIRECTORY styles/Plasma DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami/styles)
endif()
if (DESKTOP_ENABLED)
    install(DIRECTORY styles/Desktop DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami/styles)
endif()

install(FILES ${platformspecific} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami)
