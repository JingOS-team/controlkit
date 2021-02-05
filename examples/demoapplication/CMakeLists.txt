
set(demoapplication_SRCS
    main.cpp
    )

qt5_add_resources(RESOURCES resources.qrc)

add_executable(demoapplication ${demoapplication_SRCS} ${RESOURCES})
target_link_libraries(demoapplication Qt5::Core  Qt5::Qml Qt5::Quick Qt5::Svg Qt5::QuickControls2)

install(TARGETS demoapplication ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})

include(${CMAKE_SOURCE_DIR}/KF5Kirigami2Macros.cmake)
