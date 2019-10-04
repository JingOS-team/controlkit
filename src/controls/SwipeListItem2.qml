import QtQuick 2.6
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.4 as Controls
import QtQuick.Templates 2.4 as T2
import org.kde.kirigami 2.11 as Kirigami
import "private"

T2.SwipeDelegate {
    id: root

    /**
     * supportsMouseEvents: bool
     * Holds if the item emits signals related to mouse interaction.
     *TODO: remove
     * The default value is false.
     */
    property alias supportsMouseEvents: root.hoverEnabled

    /**
     * containsMouse: bool
     * True when the user hover the mouse over the list item
     * NOTE: on mobile touch devices this will be true only when pressed is also true
     * KF6: remove
     */
    property alias containsMouse: root.hovered

    /**
     * alternatingBackground: bool
     * If true the background of the list items will be alternating between two
     * colors, helping readability with multiple column views.
     * Use it only when implementing a view which shows data visually in multiple columns
     * @ since 2.7 
     */
    property bool alternatingBackground: false

    /**
     * sectionDelegate: bool
     * If true the item will be a delegate for a section, so will look like a
     * "title" for the items under it.
     */
    property bool sectionDelegate: false

    /**
     * separatorVisible: bool
     * True if the separator between items is visible
     * default: true
     */
    property bool separatorVisible: true

    /**
     * actionsVisible: bool
     * True if it's possible to see and access the item actions.
     * Actions should go completely out of the way for instance during
     * the editing of an item.
     * @since 2.5
     */
    readonly property bool actionsVisible: swipe.position != 0

    /**
     * actions: list<Action>
     * Defines the actions for the list item: at most 4 buttons will
     * contain the actions for the item, that can be revealed by
     * sliding away the list item.
     */
    property list<Action> actions

    /**
     * textColor: color
     * Color for the text in the item
     *
     * Note: if custom text elements are inserted in an AbstractListItem,
     * their color property will have to be manually bound with this property
     */
    property color textColor: Kirigami.Theme.textColor

    /**
     * backgroundColor: color
     * Color for the background of the item
     */
    property color backgroundColor: Kirigami.Theme.backgroundColor

    /**
     * alternateBackgroundColor: color
     * The background color to use if alternatingBackground is true.
     * It is advised to leave the default.
     * @since 2.7
     */
    property color alternateBackgroundColor: Kirigami.Theme.alternateBackgroundColor

    /**
     * activeTextColor: color
     * Color for the text in the item when pressed or selected
     * It is advised to leave the default value (Theme.highlightedTextColor)
     *
     * Note: if custom text elements are inserted in an AbstractListItem,
     * their color property will have to be manually bound with this property
     */
    property color activeTextColor: Kirigami.Theme.highlightedTextColor

    /**
     * activeBackgroundColor: color
     * Color for the background of the item when pressed or selected
     * It is advised to leave the default value (Theme.highlightColor)
     */
    property color activeBackgroundColor: Kirigami.Theme.highlightColor


    LayoutMirroring.childrenInherit: true

    Loader {
        id: overlayLoader
        parent: root
        z: contentItem ? contentItem.z + 1 : 0
        sourceComponent: handleComponent
        anchors {
            right: contentItem ? contentItem.right : undefined
            top: parent.top
            bottom: parent.bottom
            rightMargin: -root.leftPadding
        }
    }
    Component {
        id: handleComponent

        MouseArea {
            id: dragButton
            anchors {
                right: parent.right
            }
            implicitWidth: Kirigami.Units.iconSizes.smallMedium

            preventStealing: true
            property real openPosition: (root.width - width - root.leftPadding - root.rightPadding)/root.width
            onClicked: {
                if (root.LayoutMirroring.enabled) {
                    if (root.swipe.position < 0.5) {
                        slideAnim.to = openPosition
                    } else {
                        slideAnim.to = 0
                    }
                } else {
                    if (root.swipe.position > -0.5) {
                        slideAnim.to = -openPosition
                    } else {
                        slideAnim.to = 0
                    }
                }
                slideAnim.restart();
            }
            onPositionChanged: {
                var pos = mapToItem(root, mouse.x, mouse.y);
                
                if (root.LayoutMirroring.enabled) {
                    root.swipe.position = Math.max(0, Math.min(openPosition, (pos.x / root.width)))
                } else {
                    root.swipe.position = Math.min(0, Math.max(-openPosition, (pos.x / root.width - 1)))
                }
            }
            onReleased: {
                if (root.LayoutMirroring.enabled) {
                    if (root.swipe.position > 0.5) {
                        slideAnim.to = openPosition
                    } else {
                        slideAnim.to = 0
                    }
                } else {
                    if (root.swipe.position < -0.5) {
                        slideAnim.to = -openPosition
                    } else {
                        slideAnim.to = 0
                    }
                }
                slideAnim.restart();
            }

            Kirigami.Icon {
                id: handleIcon
                anchors.fill: parent
                selected: root.checked || (root.pressed && !root.checked && !root.sectionDelegate)
                source: (LayoutMirroring.enabled ? (root.background.x < root.background.width/2 ? "overflow-menu-right" : "overflow-menu-left") : (root.background.x < -root.background.width/2 ? "overflow-menu-right" : "overflow-menu-left"))
            }
        }
    }

    property Component behindDelegate: Rectangle {
        anchors.fill: parent

        color: Controls.SwipeDelegate.pressed ? Qt.darker(Kirigami.Theme.backgroundColor, 1.1) : Qt.darker(Kirigami.Theme.backgroundColor, 1.05)

        visible: root.swipe.position != 0
        Controls.SwipeDelegate.onPressedChanged: {
            slideAnim.to = 0;
            slideAnim.restart();
        }

        EdgeShadow {
            edge: Qt.TopEdge
            visible: background.x != 0
            anchors {
                right: parent.right
                left: parent.left
                top: parent.top
            }
        }
        EdgeShadow {
            edge: LayoutMirroring.enabled ? Qt.RightEdge : Qt.LeftEdge
            x: LayoutMirroring.enabled ? root.background.x - width : (root.background.x + root.background.width)
            visible: background.x != 0
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
        }
        RowLayout {
            id: actionsLayout
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }

            Repeater {
                model: {
                    if (root.actions.length === 0) {
                        return null;
                    } else {
                        return root.actions[0].text !== undefined &&
                            root.actions[0].trigger !== undefined ?
                                root.actions :
                                root.actions[0];
                    }
                }
                delegate: Controls.ToolButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon.name: modelData.iconName !== "" ? modelData.iconName : ""
                    icon.source: modelData.iconSource !== "" ? modelData.iconSource : ""
                    enabled: (modelData && modelData.enabled !== undefined) ? modelData.enabled : true;
                    visible: (modelData && modelData.visible !== undefined) ? modelData.visible : true;
                    onVisibleChanged: actionsLayout.updateVisibleActions(visible);
                    Component.onCompleted: actionsLayout.updateVisibleActions(visible);
                    Component.onDestruction: actionsLayout.updateVisibleActions(visible);
                    Controls.ToolTip.delay: Units.toolTipDelay
                    Controls.ToolTip.timeout: 5000
                    Controls.ToolTip.visible: listItem.visible && (Settings.tabletMode ? pressed : hovered) && Controls.ToolTip.text.length > 0
                    Controls.ToolTip.text: modelData.tooltip || modelData.text

                    onClicked: {
                        if (modelData && modelData.trigger !== undefined) {
                            modelData.trigger();
                        }
                        slideAnim.to = 0;
                        slideAnim.restart();
                    }
                }
            }
        }
    }
    background: Rectangle {
        color: Controls.SwipeDelegate.pressed ? Qt.darker("tomato", 1.1) : "tomato"
        radius: 10
    }
    swipe {
        enabled: false
        right: root.LayoutMirroring.enabled ? null : root.behindDelegate
        left: root.LayoutMirroring.enabled ? root.behindDelegate : null
    }
    NumberAnimation {
        id: slideAnim
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InOutQuad
        target: root.swipe
        property: "position"
        from: root.swipe.position
    }
}

