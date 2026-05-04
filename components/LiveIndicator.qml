import "../theme"
import QtQuick

Row {
    id: root

    property string label: ">> LIVE"

    spacing: 6
    implicitHeight: Math.max(7, labelText.implicitHeight)
    implicitWidth: dot.width + spacing + labelText.implicitWidth
    opacity: 0.95

    Rectangle {
        id: dot

        width: 7
        height: 7
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.line
    }

    TacticalLabel {
        id: labelText

        text: root.label
        accent: true
    }

    SequentialAnimation on opacity {
        loops: Animation.Infinite

        NumberAnimation {
            to: 0.42
            duration: 650
        }

        NumberAnimation {
            to: 1
            duration: 650
        }

    }

}
