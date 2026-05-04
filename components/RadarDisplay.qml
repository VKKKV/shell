import "../theme"
import QtQuick

Item {
    id: root

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: width
        color: "transparent"
        border.color: Theme.lineDim
        border.width: Theme.lineWidth
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.62
        height: width
        color: "transparent"
        border.color: Theme.lineDim
        border.width: Theme.lineWidth
    }

    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: Theme.lineWidth
        color: Theme.lineDim
    }

    Rectangle {
        anchors.centerIn: parent
        width: Theme.lineWidth
        height: parent.height
        color: Theme.lineDim
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.42
        height: Theme.heavyLineWidth
        color: Theme.line

        transform: Rotation {
            angle: -28
            origin.x: width / 2
            origin.y: height / 2
        }

    }

    Repeater {
        model: [[0.28, 0.2], [0.68, 0.35], [0.42, 0.72], [0.77, 0.78]]

        Rectangle {
            required property var modelData

            x: modelData[0] * root.width - width / 2
            y: modelData[1] * root.height - height / 2
            width: 5
            height: 5
            color: Theme.line
        }

    }

}
