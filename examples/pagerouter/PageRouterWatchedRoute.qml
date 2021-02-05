import QtQuick 2.12
import QtQuick.Controls 2.12 as QQC2
import org.kde.kirigami 2.12 as Kirigami

Kirigami.ApplicationWindow {
    id: applicaionWindow
    Kirigami.PageRouter {
        initialRoute: "one"
        pageStack: applicaionWindow.pageStack.columnView
        Kirigami.PageRoute {
            name: "one"
            Kirigami.Page {
                Column {
                    Kirigami.Heading {
                        Kirigami.PageRouter.watchedRoute: ["one", "two"]
                        text: Kirigami.PageRouter.watchedRouteActive ? "/one/two is active" : "only /one is active"
                    }
                    QQC2.Button {
                        text: "Push Two"
                        onClicked: Kirigami.PageRouter.navigateToRoute(["one", "two"])
                    }
                }
            }
        }
        Kirigami.PageRoute {
            name: "two"
            Kirigami.Page {
                // Page contents...
            }
        }
    }
}
