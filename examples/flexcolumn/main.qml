import QtQuick 2.10
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.14 as Kirigami

Kirigami.FlexColumn {
    Rectangle {
        color: "red"

        Layout.preferredHeight: 200
        Layout.fillWidth: true
    }
    Rectangle {
        color: "orange"

        Layout.preferredHeight: 100
        Layout.fillWidth: true
    }
    Rectangle {
        color: "yellow"

        Layout.preferredHeight: 50
        Layout.fillWidth: true
    }
    Rectangle {
        color: "green"

        Layout.preferredHeight: 25
        Layout.fillWidth: true
    }
}