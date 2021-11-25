cmake_minimum_required(VERSION 3.5)

project(jingosMultimediaModule)
set(AUTOMOC_MOC_OPTIONS -Muri=jingos.multimedia)

find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Gui Quick Multimedia)
find_package(Taglib REQUIRED)
#find_package(gstreamer-1.0 REQUIRED)
#find_package(gstreamer-pbutils-1.0 REQUIRED)


find_package(PkgConfig)
pkg_search_module(GSTREAMER REQUIRED gstreamer-1.0)
MESSAGE(STATUS "gstreamer dirs:" ${GSTREAMER_INCLUDE_DIRS})
MESSAGE(STATUS "gstreamer lib:" ${GSTREAMER_LIBRARIES})
include_directories(${GSTREAMER_INCLUDE_DIRS})
link_directories(${GSTREAMER_LIBRARY_DIRS})

pkg_search_module(PBUTILS REQUIRED gstreamer-pbutils-1.0)
MESSAGE(STATUS "gstreamer-pbutils dirs:" ${PBUTILS_INCLUDE_DIRS})
MESSAGE(STATUS "gstreamer-pbutils lib:" ${PBUTILS_LIBRARIES})
include_directories(${PBUTILS_INCLUDE_DIRS})
link_directories(${PBUTILS_LIBRARY_DIRS})



find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
	Config FileMetaData KIO 
)
set(jmultimediaModule_SRCS
    jmultimediaModuleplugin.cpp
	mpvobject.cpp
	mpvrenderitem.cpp
	MediaDbusSet.cpp
        jbasevideosurface.cpp
	player.cpp
	jgstmediainfo.cpp
    )

add_library(jingosMultimediaModule ${jmultimediaModule_SRCS})
target_link_libraries(jingosMultimediaModule
			Qt5::DBus
			Qt5::Core 
			Qt5::Qml
			Qt5::Quick
			Qt5::Widgets
			mediainfo 
			Qt5::Multimedia
			mpv  
		    ${GSTREAMER_LIBRARIES}
			${PBUTILS_LIBRARIES}	
			tag
			KF5::ConfigCore
			KF5::CoreAddons
			KF5::KIOCore 
			KF5::KIOWidgets
			KF5::FileMetaData
    )
if (BUILD_SHARED_LIBS)
    add_custom_target(copyMultimedia_to_bin ALL
        COMMAND ${CMAKE_COMMAND} -E
                make_directory ${CMAKE_BINARY_DIR}/bin/jingos/multimedia/
        COMMAND ${CMAKE_COMMAND} -E
                copy $<TARGET_FILE:jingosMultimediaModule> ${CMAKE_BINARY_DIR}/bin/jingos/multimedia/
	COMMAND ${CMAKE_COMMAND} -E
                copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/image  ${CMAKE_BINARY_DIR}/bin/jingos/multimedia/image
    )

endif()


install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/jingos/multimedia/)
install(TARGETS jingosMultimediaModule DESTINATION ${KDE_INSTALL_QMLDIR}/jingos/multimedia/)
install(DIRECTORY image DESTINATION ${KDE_INSTALL_QMLDIR}/jingos/multimedia)
