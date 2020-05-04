import QtQuick 2.12
import QtQuick.Controls 2.12 as QQC2
import org.kde.kirigami 2.12 as Kirigami

Kirigami.ApplicationWindow {
    id: applicationWindow
    Kirigami.PageRouter {
        initialRoute: "home"
        pageStack: applicationWindow.pageStack.columnView

        Kirigami.PageRoute {
            name: "home"
            cache: false
            Component {
                Kirigami.Page {
                    Column {
                        Kirigami.Heading {
                            text: "Welcome"
                        }
                        QQC2.Button {
                            text: "Red Login"
                            onClicked: Kirigami.PageRouter.navigateToRoute(["home", {"route": "login", "data": "red"}])
                        }
                        QQC2.Button {
                            text: "Blue Login"
                            onClicked: Kirigami.PageRouter.navigateToRoute(["home", {"route": "login", "data": "blue"}])
                        }
                    }
                }
            }
        }
        Kirigami.PageRoute {
            name: "login"
            cache: true
            Component {
                Kirigami.Page {
                    Column {
                        Kirigami.Heading {
                            text: "Login"
                        }
                        Rectangle {
                            height: 50
                            width: 50
                            color: Kirigami.PageRouter.data
                        }
                        QQC2.Button {
                            text: "Back to Home"
                            onClicked: Kirigami.PageRouter.navigateToRoute("home")
                        }
                    }
                }
            }
        }
    }
}
