import "../theme"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property var lines: []

    Layout.fillWidth: true
    spacing: 4

    TacticalLabel {
        Layout.fillWidth: true
        text: "LOG STREAM // SYSTEM"
        accent: true
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Theme.lineDim
    }

    Repeater {
        model: root.lines

        RowLayout {
            required property string modelData

            Layout.fillWidth: true
            spacing: 6

            TacticalLabel {
                text: ">"
                accent: true
            }

            TacticalLabel {
                Layout.fillWidth: true
                text: modelData
                dim: modelData.indexOf("audit") < 0
                elide: Text.ElideRight
            }

        }

    }

}
