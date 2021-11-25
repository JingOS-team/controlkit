cmake_minimum_required(VERSION 3.5)

project(jingosDisplay)
set(AUTOMOC_MOC_OPTIONS -Muri=jingos.display)

find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Gui Quick)
set(jingosDisplay_SRCS
    jingosDisplayPlugin.cpp
	jdisplaymetrics.cpp
    )

add_library(jingosDisplay ${jingosDisplay_SRCS})
target_link_libraries(jingosDisplay
			Qt5::Core 
			Qt5::Qml
			Qt5::Quick
            KF5::ConfigCore
            KF5::ConfigGui

    )
if (BUILD_SHARED_LIBS)
    add_custom_target(copyDisplay_to_bin ALL
        COMMAND ${CMAKE_COMMAND} -E
                make_directory ${CMAKE_BINARY_DIR}/bin/jingos/display/
        COMMAND ${CMAKE_COMMAND} -E
                copy $<TARGET_FILE:jingosDisplay> ${CMAKE_BINARY_DIR}/bin/jingos/display/
    )

endif()
install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/jingos/display/)
install(FILES JDisplay.qml DESTINATION ${KDE_INSTALL_QMLDIR}/jingos/display/)
install(TARGETS jingosDisplay DESTINATION ${KDE_INSTALL_QMLDIR}/jingos/display/)
