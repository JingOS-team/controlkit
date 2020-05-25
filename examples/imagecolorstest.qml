
import QtQuick 2.12
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.12 as Controls
import org.kde.kirigami 2.13 as Kirigami

RowLayout {
    id: root
    width: 500
    height: 500

    property var icons: ["desktop", "firefox", "vlc", "blender", "applications-games", "blinken", "adjustlevels", "adjustrgb", "cuttlefish", "folder-games", "applications-network", "multimedia-player", "applications-utilities", "accessories-dictionary", "calligraflow", "calligrakrita", "view-left-close","calligraauthor"]
    property int i

    Kirigami.ImageColors {
        id: palette
        source: icon.source
    }
    Kirigami.ImageColors {
        id: imgPalette
        source: image
    }

    ColumnLayout {
        Rectangle {
            Layout.preferredWidth: 200
            Layout.preferredHeight: 200
            z: -1
            color: palette.dominantContrast
            Kirigami.Icon {
                id: icon
                anchors.centerIn: parent
                width: 128
                height: 128
                source: "desktop"
            }
        }
        Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            color: palette.average
        }
        Controls.Button {
            text: "Next"
            onClicked: {
                i = (i+1)%icons.length
                icon.source = icons[i]
               // palette.update()
            }
        }

        Repeater {
            model: palette.palette
            delegate: RowLayout {
                Layout.fillWidth: true
                Rectangle {
                    implicitWidth: 10 + 300 * modelData.ratio
                    implicitHeight: 30
                    color: modelData.color
                }
                Item {
                    Layout.fillWidth: true
                }
                Rectangle {
                    color: modelData.contrastColor
                    implicitWidth: 30
                    implicitHeight: 30
                }
            }
        }
    }
    Item {
        Layout.preferredWidth: 500
        Layout.preferredHeight: 500/(image.sourceSize.width/image.sourceSize.height)
        Image {
            id: image
            source: "https://source.unsplash.com/random"
            anchors.fill: parent
            onStatusChanged: imgPalette.update()
        }
        ColumnLayout {
            Controls.Button {
                text: "Update"
                onClicked: {
                    image.source = "https://source.unsplash.com/random#" + (new Date()).getMilliseconds()
                }
            }
            Repeater {
                model: imgPalette.palette
                delegate: RowLayout {
                    Layout.fillWidth: true
                    Rectangle {
                        implicitWidth: 10 + 300 * modelData.ratio
                        implicitHeight: 30
                        color: modelData.color
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    Rectangle {
                        color: modelData.contrastColor
                        implicitWidth: 30
                        implicitHeight: 30
                    }
                }
            }
        }
        Item {
            width: 300
            height: 150
            Kirigami.Theme.backgroundColor: imgPalette.background
            Kirigami.Theme.textColor: imgPalette.foreground
            Kirigami.Theme.highlightColor: imgPalette.highlight

            anchors {
                bottom: parent.bottom
                right: parent.right
            }

            Rectangle {
                anchors.fill: parent
                opacity: 0.8
                color: Kirigami.Theme.backgroundColor
            }
            ColumnLayout {
                anchors.centerIn: parent
                RowLayout {
                    Rectangle {
                        Layout.alignment: Qt.AlignCenter
                        implicitWidth: 10
                        implicitHeight: 10
                        color: Kirigami.Theme.highlightColor
                    }
                    Controls.Label {
                        text: "Lorem Ipsum dolor sit amet"
                        color: Kirigami.Theme.textColor
                    }
                }
                RowLayout {
                    Controls.TextField {
                        Kirigami.Theme.inherit: true
                        text: "text"
                    }
                    Controls.Button {
                        Kirigami.Theme.inherit: true
                        text: "Ok"
                    }
                }
            }
        }
    }
}
