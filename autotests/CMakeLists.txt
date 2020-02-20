if(NOT Qt5Test_FOUND)
    message(STATUS "Qt5Test not found, autotests will not be built.")
    return()
endif()

macro(kirigami_add_tests)
    foreach(test ${ARGV})
        add_test(NAME ${test}
                 COMMAND qmltestrunner -import ${CMAKE_BINARY_DIR}/bin -input ${test}
                 WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        )
    endforeach()
endmacro()

kirigami_add_tests(
    tst_keynavigation.qml
    tst_listskeynavigation.qml
    tst_pagerow.qml
    tst_icon.qml
)

