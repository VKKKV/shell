import "../../components"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    title: "TACTICAL // THERMAL"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.panelPadding
        anchors.topMargin: 38
        spacing: 12

        MetricBlock {
            title: "TACTICAL LAYER"
            rows: [["STATUS", "ONLINE", -1, true], ["SYNC RATE", "100%", 1, false], ["SIGNAL STR", "98%", 0.98, false], ["ENCRYPTION", "AES-256", -1, false]]
        }

        RadarDisplay {
            Layout.fillWidth: true
            Layout.preferredHeight: 88
        }

        MetricBlock {
            title: "THERMAL MAP"
            rows: [["CPU", "54C", 0.54, false], ["GPU", "48C", 0.48, false], ["VRM", "46C", 0.46, false], ["PCH", "42C", 0.42, false], ["SSD", "39C", 0.39, false]]
        }

        Sparkline {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            values: [0.2, 0.5, 0.32, 0.72, 0.45, 0.9, 0.62, 0.36, 0.78, 0.54, 0.26, 0.66]
        }

        MetricBlock {
            title: "POWER GRID"
            rows: [["TOTAL", "425W", 0.85, true], ["GPU", "186W", 0.62, false], ["CPU", "92W", 0.38, false]]
        }

    }

}
