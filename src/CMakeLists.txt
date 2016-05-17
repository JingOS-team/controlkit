project(kirigami)

set(kirigami_SRCS
    kirigamiplugin.cpp
    )

add_library(kirigamiplugin SHARED ${kirigami_SRCS})
target_link_libraries(kirigamiplugin Qt5::Core  Qt5::Qml Qt5::Quick)

install(TARGETS kirigamiplugin DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami)


install(DIRECTORY qml/ DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami)

#TODO: selectively install plasma and Desktop styles
install(DIRECTORY styles/Fallback DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami/styles/Fallback)
if (PLASMA_ENABLED)
    install(DIRECTORY styles/Plasma DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami/styles/Plasma)
endif()
if (DESKTOP_ENABLED)
    install(DIRECTORY styles/Desktop DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami/styles/Desktop)
endif()

install(FILES ${platformspecific} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami)
