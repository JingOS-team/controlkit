if(NOT Qt5QuickTest_FOUND)
    message(STATUS "Qt5QuickTest not found, autotests will not be built.")
    return()
endif()

add_executable(qmltest qmltest.cpp)
target_link_libraries(qmltest Qt5::QuickTest)

macro(kirigami_add_tests)
    if (WIN32)
        set(_extra_args -platform offscreen)
    endif()

    foreach(test ${ARGV})
        add_test(NAME ${test}
                 COMMAND qmltest
                        ${_extra_args}
                        -import ${CMAKE_BINARY_DIR}/bin
                        -input ${test}
                 WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        )
    endforeach()
endmacro()

kirigami_add_tests(
    tst_keynavigation.qml
    tst_listskeynavigation.qml
    tst_pagerow.qml
    tst_icon.qml
    tst_actiontoolbar.qml
    tst_pagerouter.qml
    tst_routerwindow.qml
    tst_avatar.qml
    pagepool/tst_pagepool.qml
    pagepool/tst_layers.qml
)

