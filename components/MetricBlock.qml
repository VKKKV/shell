import "../theme"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string title: ""
    property var rows: []

    Layout.fillWidth: true
    spacing: 6

    TacticalLabel {
        Layout.fillWidth: true
        text: root.title
        accent: true
    }

    Repeater {
        model: root.rows

        MetricRow {
            required property var modelData

            label: modelData[0]
            value: modelData[1]
            progress: modelData[2]
            accent: modelData[3]
        }

    }

}
