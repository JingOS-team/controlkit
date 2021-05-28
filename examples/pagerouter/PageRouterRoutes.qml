import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami

Kirigami.ApplicationWindow {
    id: applicationWindow
    Kirigami.PageRouter {
        pageStack: applicationWindow.pageStack.columnView

        Kirigami.PageRoute {
            name: "routeOne"
            Component {
                Kirigami.Page {
                    // Page contents...
                }
            }
        }
        Kirigami.PageRoute {
            name: "routeTwo"
            Component {
                Kirigami.Page {
                    // Page contents...
                }
            }
        }
        Kirigami.PageRoute {
            name: "routeThree"
            Component {
                Kirigami.Page {
                    // Page contents...
                }
            }
        }
    }
}