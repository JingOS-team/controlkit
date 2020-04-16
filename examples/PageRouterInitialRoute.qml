import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami

Kirigami.ApplicationWindow {
    id: applicaionWindow
    Kirigami.PageRouter {
        initialRoute: "home"
        pageStack: applicaionWindow.pageStack.columnView

        Kirigami.PageRoute {
            name: "home"
            Component {
                Kirigami.Page {
                    // This page will show up when starting the application
                }
            }
        }
        Kirigami.PageRoute {
            name: "login"
            Component {
                Kirigami.Page {
                    // Page contents...
                }
            }
        }
    }
}