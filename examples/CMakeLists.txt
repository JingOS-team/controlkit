
add_subdirectory(android)

install(DIRECTORY gallery/ DESTINATION ${KDE_INSTALL_DATAROOTDIR}/kpackage/genericqml/org.kde.kirigami2.gallery)
install(FILES gallery/metadata.desktop DESTINATION ${XDG_APPS_INSTALL_DIR} RENAME org.kde.kirigami2.gallery.desktop)
