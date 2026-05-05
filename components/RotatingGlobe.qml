import "../theme"
import QtQuick

Item {
    id: root

    property real rotationPhase: 0
    signal activated()

    implicitWidth: 180
    implicitHeight: 180

    NumberAnimation on rotationPhase {
        from: 0
        to: 360
        duration: 16000
        loops: Animation.Infinite
        running: true
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height)
        height: width
        radius: width / 2
        color: "transparent"
        border.color: Theme.line
        border.width: Theme.lineWidth
        opacity: 0.95
    }

    Repeater {
        model: 5

        Rectangle {
            required property int index

            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height / 2 - height / 2
            width: Math.min(parent.width, parent.height) * (0.28 + index * 0.13)
            height: Math.min(parent.width, parent.height) * 0.92
            radius: width / 2
            color: "transparent"
            border.color: Theme.lineDim
            border.width: Theme.lineWidth
            rotation: root.rotationPhase + index * 18
            opacity: 0.55
        }
    }

    Repeater {
        model: 5

        Rectangle {
            required property int index

            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height) * 0.92
            height: 1
            color: Theme.lineDim
            y: parent.height / 2 + (index - 2) * parent.height * 0.12
            opacity: 0.55
        }
    }

    Rectangle {
        width: Math.min(parent.width, parent.height) * 0.42
        height: Theme.lineWidth
        color: Theme.line
        anchors.centerIn: parent
        rotation: -24
        opacity: 0.8
    }

    Rectangle {
        width: 8
        height: 8
        radius: 4
        color: Theme.line
        x: parent.width / 2 + Math.cos(root.rotationPhase * Math.PI / 180) * parent.width * 0.31 - width / 2
        y: parent.height / 2 + Math.sin(root.rotationPhase * Math.PI / 180) * parent.height * 0.2 - height / 2
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.1
        height: width
        radius: width / 2
        color: Theme.line
        opacity: 0.2
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.activated()
    }
}
