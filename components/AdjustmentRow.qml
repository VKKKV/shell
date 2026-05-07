import "../theme"
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    property string decrementText: "-"
    property string incrementText: "+"

    signal decrement()
    signal increment()

    Layout.fillWidth: true
    spacing: Theme.densitySmallSpacing

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.densityControlHeight
        color: "transparent"
        border.color: Theme.lineDim

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.decrement()
        }

        TacticalLabel {
            anchors.centerIn: parent
            text: root.decrementText
            accent: true
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.densityControlHeight
        color: "transparent"
        border.color: Theme.lineDim

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.increment()
        }

        TacticalLabel {
            anchors.centerIn: parent
            text: root.incrementText
            accent: true
        }
    }
}
