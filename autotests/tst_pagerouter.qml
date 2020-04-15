import QtQuick 2.12
import QtQuick.Controls 2.12 as QQC2
import org.kde.kirigami 2.12 as Kirigami
import QtTest 1.0

Kirigami.PageRow {
    id: root
    TestCase {
        name: "PageRouterGeneralTests"
        function test_10_init() {
            compare(router.currentRoutes().length, 1)
        }
        function test_20_navigate() {
            router.navigateToRoute(["home", "login"])
            compare(router.currentRoutes().length, 2)
        }
        function test_30_data() {
            router.navigateToRoute(["home", {"route": "login", "data": "red"}])
            compare(router.routeActive(["home", {"route": "login", "data": "red"}]), true)
            compare(router.routeActive(["home", {"route": "login", "data": "blue"}]), false)
        }
        function test_40_cache_works() {
            router.navigateToRoute(["home", {"route": "login", "data": "red"}, {"route": "login", "data": "blue"}])
            compare(router.currentRoutes().length, 3)
        }
        function test_50_push() {
            router.pushRoute("home")
            compare(router.currentRoutes().length, 4)
        }
        function test_60_pop() {
            router.popRoute()
            compare(router.currentRoutes().length, 3)
        }
        function test_70_bring_to_view() {
            router.bringToView("home")
            compare(root.columnView.currentIndex, 0)
            router.bringToView({"route": "login", "data": "red"})
            compare(root.columnView.currentIndex, 1)
            router.bringToView({"route": "login", "data": "blue"})
            compare(root.columnView.currentIndex, 2)
        }
        function test_80_routeactive() {
            compare(router.routeActive(["home"]), true)
            compare(router.routeActive(["home", "login"]), true)
            compare(router.routeActive(["home", {"route": "login", "data": "red"}]), true)
            compare(router.routeActive(["home", {"route": "login", "data": "blue"}]), false)
        }
        function test_90_initial_route() {
            router.initialRoute = "login"
            compare(router.routeActive(["login"]), false)
            compare(router.currentRoutes().length, 3)
        }
        function test_100_navigation_two() {
            router.navigateToRoute(["home", {"route": "login", "data": "red"}, {"route": "login", "data": "blue"}])
            compare(router.currentRoutes().length, 3)
            router.navigateToRoute(["home"])
            compare(router.currentRoutes().length, 1)
            compare(router.pageStack.count, 1)
        }
    }
    Kirigami.PageRouter {
        id: router
        initialRoute: "home"
        pageStack: root.columnView

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