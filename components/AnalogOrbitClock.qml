import "../services"
import "../theme"
import QtQuick

Item {
    id: root

    signal activated()

    implicitWidth: 180
    implicitHeight: 180

    readonly property real dialSize: Math.min(width, height)
    readonly property real hourAngle: ((Time.now.getHours() % 12) + Time.now.getMinutes() / 60) * 30
    readonly property real minuteAngle: (Time.now.getMinutes() + Time.now.getSeconds() / 60) * 6
    readonly property real secondAngle: Time.now.getSeconds() * 6

    Rectangle {
        anchors.centerIn: parent
        width: root.dialSize
        height: width
        radius: width / 2
        color: clockArea.containsMouse ? Theme.panelSoft : "#22000000"
        border.color: clockArea.containsMouse ? Theme.line : Theme.lineDim
        border.width: Theme.heavyLineWidth
    }

    Rectangle {
        anchors.centerIn: parent
        width: root.dialSize * 0.86
        height: width
        radius: width / 2
        color: "transparent"
        border.color: Theme.border
        border.width: Theme.lineWidth
    }

    Repeater {
        model: 60

        Rectangle {
            required property int index

            readonly property bool major: index % 5 === 0

            x: parent.width / 2 - width / 2
            y: parent.height / 2 - root.dialSize / 2 + (major ? 8 : 12)
            width: major ? Theme.heavyLineWidth : Theme.lineWidth
            height: major ? root.dialSize * 0.1 : root.dialSize * 0.055
            color: major ? Theme.line : Theme.lineDim
            opacity: major ? 0.95 : 0.42
            transform: Rotation {
                origin.x: width / 2
                origin.y: root.dialSize / 2 - (parent.major ? 8 : 12)
                angle: parent.index * 6
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: root.dialSize * 0.68
        height: Theme.lineWidth
        color: Theme.lineDim
        opacity: 0.38
    }

    Rectangle {
        anchors.centerIn: parent
        width: Theme.lineWidth
        height: root.dialSize * 0.68
        color: Theme.lineDim
        opacity: 0.38
    }

    Rectangle {
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height + width / 2
        width: 5
        height: root.dialSize * 0.25
        radius: width / 2
        color: Theme.text
        transform: Rotation {
            origin.x: 2.5
            origin.y: parent.height - 2.5
            angle: root.hourAngle
        }
    }

    Rectangle {
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height + width / 2
        width: 3
        height: root.dialSize * 0.34
        radius: width / 2
        color: Theme.line
        transform: Rotation {
            origin.x: 1.5
            origin.y: parent.height - 1.5
            angle: root.minuteAngle
        }
    }

    Rectangle {
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height + width / 2
        width: Theme.lineWidth
        height: root.dialSize * 0.39
        color: Theme.danger
        opacity: 0.85
        transform: Rotation {
            origin.x: 0.5
            origin.y: parent.height - 0.5
            angle: root.secondAngle
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: root.dialSize * 0.12
        height: width
        radius: width / 2
        color: Theme.line
        opacity: 0.22
    }

    Rectangle {
        anchors.centerIn: parent
        width: 7
        height: 7
        radius: width / 2
        color: Theme.line
    }

    TacticalLabel {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: root.dialSize * 0.2
        text: "ORBITAL CLOCK"
        accent: true
        size: Theme.fontTiny
    }

    TacticalLabel {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.dialSize * 0.18
        text: Time.timeText + " // CLICK EPHEMERIS"
        dim: !clockArea.containsMouse
        accent: clockArea.containsMouse
        size: Theme.fontTiny
    }

    MouseArea {
        id: clockArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.activated()
    }
}
