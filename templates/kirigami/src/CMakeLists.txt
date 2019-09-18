qt5_add_resources(%{APPNAMELC}_SRCS resources.qrc)
add_executable(%{APPNAMELC} main.cpp ${%{APPNAMELC}_SRCS})
target_link_libraries(%{APPNAMELC} Qt5::Core Qt5::Gui Qt5::Qml Qt5::Quick Qt5::QuickControls2 Qt5::Svg KF5::I18n)
install(TARGETS %{APPNAMELC} ${KF5_INSTALL_TARGETS_DEFAULT_ARGS})
