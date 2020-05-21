import QtQuick 2.0
import org.kde.kirigami 2.13 as Kirigami

Kirigami.ApplicationWindow {
    Kirigami.SwipeNavigator {
        anchors.fill: parent
        Kirigami.Page {
            icon.name: "globe"
            title: "World Clocks"
        }
        Kirigami.Page {
            icon.name: "clock"
            title: "Alarms"
            needsAttention: true
        }
        Kirigami.Page {
            icon.name: "clock"
            title: "Stopwatch"
        }
        Kirigami.Page {
            icon.name: "clock"
            title: "Timers"
            progress: 0.5
        }
    }
}
