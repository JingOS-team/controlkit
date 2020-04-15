import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami

Kirigami.ApplicationWindow {
    id: applicaionWindow
    Kirigami.PageRouter {
        pageStack: applicaionWindow.pageStack.columnView

        Kirigami.PageRoute {
            name: "home"
            Component {
                Kirigami.Page {
                    // Page contents...
                }
            }
        }
        initialRoute: "home"
        Component.onCompleted: navigateToRoute("home", "home")
    }
}