
set(kirigami2gallery_SRCS
    main.cpp
    )

qt5_add_resources(RESOURCES resources.qrc)

if (CMAKE_SYSTEM_NAME STREQUAL "Android")
    set(kirigami2gallery_EXTRA_LIBS Qt5::AndroidExtras Qt5::QuickControls2)
endif()

add_executable(kirigami2gallery ${kirigami2gallery_SRCS} ${RESOURCES})
target_link_libraries(kirigami2gallery Qt5::Core  Qt5::Qml Qt5::Quick Qt5::Svg ${kirigami2gallery_EXTRA_LIBS})

install(TARGETS kirigami2gallery ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})

include(${CMAKE_SOURCE_DIR}/KF5Kirigami2Macros.cmake)
kirigami_package_breeze_icons(ICONS applications-graphics view-list-icons folder-sync view-list-details configure document-edit dialog-cancel document-decrypt mail-reply-sender bookmarks folder)
