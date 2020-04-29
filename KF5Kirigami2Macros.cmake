
include(CMakeParseArguments)
include(ExternalProject)


function(kirigami_package_breeze_icons)
    set(_multiValueArgs ICONS)
    cmake_parse_arguments(ARG "" "" "${_multiValueArgs}" ${ARGN} )

    if(NOT ARG_ICONS)
        message(FATAL_ERROR "No ICONS argument given to kirigami_package_breeze_icons")
    endif()

    #include icons used by Kirigami components themselves
    set(ARG_ICONS ${ARG_ICONS} go-next go-previous go-up handle-sort overflow-menu-left overflow-menu-right go-next-symbolic go-next-symbolic-rtl go-previous-symbolic go-previous-symbolic-rtl overflow-menu user view-left-new view-right-new view-left-close view-right-close dialog-positive dialog-warning dialog-error dialog-information)

    function(_find_breeze_icon icon varName)
        #HACKY
        SET(path "")
        file(GLOB_RECURSE path ${_BREEZEICONS_DIR}/icons/*/48/${icon}.svg )

        #search in other sizes as well
        if (path STREQUAL "")
            file(GLOB_RECURSE path ${_BREEZEICONS_DIR}/icons/*/32/${icon}.svg )
            if (path STREQUAL "")
                file(GLOB_RECURSE path ${_BREEZEICONS_DIR}/icons/*/22/${icon}.svg )
                if (path STREQUAL "")
                    file(GLOB_RECURSE path ${_BREEZEICONS_DIR}/icons/*/16/${icon}.svg )
                endif()
            endif()
        endif()
        if (path STREQUAL "")
            file(GLOB_RECURSE path ${_BREEZEICONS_DIR}/icons/*/symbolic/${icon}.svg )
        endif()
        if (path STREQUAL "")
            return()
        endif()

        list(LENGTH path _count_paths)
        if (_count_paths GREATER 1)
            message(WARNING "Found more than one version of '${icon}': ${path}")
        endif()
        list(GET path 0 path)
        get_filename_component(path "${path}" REALPATH)

        SET(${varName} ${path} PARENT_SCOPE)
    endfunction()

    if (BREEZEICONS_DIR AND NOT EXISTS ${BREEZEICONS_DIR})
        message(FATAL_ERROR "BREEZEICONS_DIR variable does not point to existing dir: \"${BREEZEICONS_DIR}\"")
    endif()

    set(_BREEZEICONS_DIR "${BREEZEICONS_DIR}")

    #FIXME: this is a terrible hack
    if(NOT _BREEZEICONS_DIR)
        set(_BREEZEICONS_DIR "${CMAKE_BINARY_DIR}/breeze-icons/src/breeze-icons")

        # replacement for ExternalProject_Add not yet working
        # first time config?
        if (NOT EXISTS ${_BREEZEICONS_DIR})
            find_package(Git)
            execute_process(COMMAND ${GIT_EXECUTABLE} clone --depth 1 git://anongit.kde.org/breeze-icons.git ${_BREEZEICONS_DIR})
        endif()

        # external projects are only pulled at make time, not configure time
        # so this is too late to work with the _find_breeze_icon() method
        # _find_breeze_icon() would need to be turned into a target/command
        if (FALSE)
        ExternalProject_Add(
            breeze-icons
            PREFIX breeze-icons
            GIT_REPOSITORY git://anongit.kde.org/breeze-icons.git
            CONFIGURE_COMMAND ""
            BUILD_COMMAND ""
            INSTALL_COMMAND ""
            LOG_DOWNLOAD ON
        )
        endif()
    endif()

    message (STATUS "Found external breeze icons:")
    foreach(_iconName ${ARG_ICONS})
        set(_iconPath "")
        _find_breeze_icon(${_iconName} _iconPath)
        message (STATUS ${_iconPath})
        if (EXISTS ${_iconPath})
            install(FILES ${_iconPath} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami.2/icons/ RENAME ${_iconName}.svg)
        endif()
    endforeach()

    #generate an index.theme that qiconloader can understand
    file(WRITE ${CMAKE_BINARY_DIR}/index.theme "[Icon Theme]\nName=Breeze\nDirectories=icons\n[icons]\nSize=32\nType=Scalable")
    install(FILES ${CMAKE_BINARY_DIR}/index.theme DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami.2/)
endfunction()

