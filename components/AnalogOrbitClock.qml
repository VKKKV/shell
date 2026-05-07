import "../services"
import "../theme"
import QtQuick

Item {
    id: root

    signal activated()

    implicitWidth: 180
    implicitHeight: 180

    readonly property real dialSize: Math.min(width, height)
    readonly property real dialLeft: (width - dialSize) / 2
    readonly property real dialTop: (height - dialSize) / 2
    readonly property real hourAngle: ((Time.now.getHours() % 12) + Time.now.getMinutes() / 60) * 30
    readonly property real minuteAngle: (Time.now.getMinutes() + Time.now.getSeconds() / 60) * 6
    readonly property real secondAngle: Time.now.getSeconds() * 6

    Item {
        id: dialFace

        anchors.centerIn: parent
        width: root.dialSize
        height: width

        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: width
            radius: width / 2
            color: clockArea.containsMouse ? Theme.panelSoft : "#22000000"
            border.color: clockArea.containsMouse ? Theme.line : Theme.lineDim
            border.width: Theme.heavyLineWidth
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.86
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

                x: dialFace.width / 2 - width / 2
                y: major ? 8 : 12
                width: major ? Theme.heavyLineWidth : Theme.lineWidth
                height: major ? dialFace.width * 0.1 : dialFace.width * 0.055
                color: major ? Theme.line : Theme.lineDim
                opacity: major ? 0.95 : 0.42
                transform: Rotation {
                    origin.x: width / 2
                    origin.y: dialFace.width / 2 - (parent.major ? 8 : 12)
                    angle: parent.index * 6
                }
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: dialFace.width * 0.68
            height: Theme.lineWidth
            color: Theme.lineDim
            opacity: 0.38
        }

        Rectangle {
            anchors.centerIn: parent
            width: Theme.lineWidth
            height: dialFace.width * 0.68
            color: Theme.lineDim
            opacity: 0.38
        }

        Item {
            anchors.fill: parent
            rotation: root.hourAngle

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                width: 5
                height: dialFace.width * 0.25
                radius: width / 2
                color: Theme.text
            }
        }

        Item {
            anchors.fill: parent
            rotation: root.minuteAngle

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                width: 3
                height: dialFace.width * 0.34
                radius: width / 2
                color: Theme.line
            }
        }

        Item {
            anchors.fill: parent
            rotation: root.secondAngle

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.verticalCenter
                width: 2
                height: dialFace.width * 0.39
                radius: width / 2
                color: Theme.danger
                opacity: 0.9
                antialiasing: true
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.verticalCenter
                width: 2
                height: dialFace.width * 0.11
                radius: width / 2
                color: Theme.danger
                opacity: 0.38
                antialiasing: true
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: dialFace.width * 0.12
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
    }

    TacticalLabel {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.dialTop + root.dialSize * 0.2
        text: "ORBITAL CLOCK"
        accent: true
        size: Theme.fontTiny
    }

    TacticalLabel {
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.dialTop + root.dialSize * 0.82 - height
        text: Time.timeText
        dim: !clockArea.containsMouse
        accent: clockArea.containsMouse
        size: Theme.fontTiny
    }

    MouseArea {
        id: clockArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: TooltipService.show("ORBITAL CLOCK", "Open the fixed central J2000 orbital map. The expanded sensor keeps drag, zoom, and planet targeting controls.", "analog-orbit-clock")
        onExited: TooltipService.clear("analog-orbit-clock")
        onClicked: root.activated()
    }
}
