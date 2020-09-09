add_executable(%{APPNAMELC} main.cpp resources.qrc)
target_link_libraries(%{APPNAMELC}
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::QuickControls2
    Qt5::Svg
    KF5::I18n)
install(TARGETS %{APPNAMELC} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
