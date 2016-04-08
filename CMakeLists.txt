project(kirigami)

cmake_minimum_required(VERSION 2.8.12)
set(KF5_MIN_VERSION "5.18.0")
set(QT_MIN_VERSION "5.5.0")

################# Disallow in-source build #################

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
   message(FATAL_ERROR "kirigami requires an out of source build. Please create a separate build directory and run 'cmake path_to_kirigami [options]' there.")
endif()

option(NO_PLASMA "Don't use the Plasma library" OFF)
option(BUILD_EXAMPLES "Build and install examples" OFF)

# Make CPack available to easy generate binary packages
include(CPack)
include(FeatureSummary)

################# set KDE specific information #################

find_package(ECM 0.0.8 REQUIRED NO_MODULE)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

find_package(Qt5 ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui)

if(NOT NO_PLASMA)
# treat plasma as an optinal dep: full functionality is expected with only Qt
find_package(KF5Plasma ${KF5_MIN_VERSION})
set_package_properties(KF5Plasma PROPERTIES DESCRIPTION "Plasma framework"
                       TYPE OPTIONAL
                       PURPOSE "Optional Look and feel integration with Plasma Mobile."
                      )
endif()

if(KF5Plasma_FOUND AND NOT NO_PLASMA)
  set(HAVE_PLASMA 1)
endif()


################# Enable C++11 features for clang and gcc #################

if(UNIX)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -std=c++0x")
endif()

################# now find all used packages #################

set (QT_MIN_VERSION "5.5.0")

find_package(PkgConfig)
#########################################################################

add_subdirectory(src)
#TODO: conditional
if (BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)

