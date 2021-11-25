cmake_minimum_required(VERSION 3.0)

project(jingOSTheme)
set(PROJECT_VERSION "1.0.0")
set(PROJECT_VERSION_MAJOR 1)

set(KF5_MIN_VERSION "5.68")

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})
find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS Plasma )

#include(FeatureSummary)
#include(KDECMakeSettings)

plasma_install_package(jingosLight org.jingos.light.desktop jingosTheme jingosLight)
plasma_install_package(jingosDark  org.jingos.dark.desktop  jingosTheme jingosDark)
