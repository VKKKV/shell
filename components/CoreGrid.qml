import "../theme"
import QtQuick
import QtQuick.Layouts

GridLayout {
    id: root

    property var cores: []

    Layout.fillWidth: true
    columns: 2
    columnSpacing: 8
    rowSpacing: 4

    Repeater {
        model: root.cores

        MetricRow {
            required property var modelData

            Layout.fillWidth: true
            label: modelData[0]
            value: modelData[1]
            progress: modelData[2]
            accent: modelData.length > 3 ? modelData[3] : false
        }

    }

}
