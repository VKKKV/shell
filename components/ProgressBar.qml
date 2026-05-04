import "../theme"
import QtQuick

Item {
    id: root

    property real value: 0
    property color fillColor: Theme.line

    implicitHeight: 8

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: Theme.lineDim
        border.width: Theme.lineWidth
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 2
        width: Math.max(0, Math.min(1, root.value)) * Math.max(0, parent.width - 4)
        color: root.fillColor
        opacity: 0.86
    }

}
