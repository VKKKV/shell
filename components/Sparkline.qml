import "../theme"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var values: []
    property color barColor: Theme.line

    implicitHeight: 42

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: Theme.lineDim
        border.width: Theme.lineWidth
        opacity: 0.45
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 3
        spacing: 3

        Repeater {
            model: root.values.length

            Rectangle {
                required property int index

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBottom
                Layout.preferredHeight: 8 + Math.max(0, Math.min(1, root.values[index])) * Math.max(1, root.height - 16)
                color: root.barColor
                opacity: 0.42 + Math.max(0, Math.min(1, root.values[index])) * 0.5
            }

        }

    }

}
