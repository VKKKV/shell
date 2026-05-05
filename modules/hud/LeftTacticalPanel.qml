import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    id: root

    title: "ORBITAL // GLOBE"
    implicitWidth: Math.max(Theme.sidePanelMinWidth, content.implicitWidth + Theme.panelPadding * 2)
    implicitHeight: content.implicitHeight + Theme.panelPadding + 38

    Flickable {
        anchors.fill: parent
        anchors.margins: Theme.panelPadding
        anchors.topMargin: 38
        contentWidth: width
        contentHeight: content.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        interactive: contentHeight > height

        ColumnLayout {
            id: content

            width: parent.width
            spacing: 12

            RotatingGlobe {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(260, Math.max(180, root.height * 0.36))
                onActivated: ExpansionService.show("orbital", "left-globe")
            }

            MetricBlock {
                title: "GLOBAL LINK"
                rows: [["STATUS", "TRACKING", -1, true], ["ORBIT", "LEO", -1, false], ["SIGNAL", "98%", 0.98, false], ["LATENCY", "18MS", 0.18, false]]
            }

            MetricBlock {
                title: "WINDOW AREA"
                rows: [["CENTER", "HYPRLAND", -1, true], ["HUD", "EDGE ONLY", -1, false], ["INPUT", "PASSTHRU", -1, false]]
            }

            Sparkline {
                Layout.fillWidth: true
                Layout.preferredHeight: 34
                values: [0.2, 0.5, 0.32, 0.72, 0.45, 0.9, 0.62, 0.36, 0.78, 0.54, 0.26, 0.66]
            }

            MetricBlock {
                title: "TELEMETRY"
                rows: [["AUDIO", AudioService.volumeText, AudioService.available ? AudioService.volume : -1, AudioService.available], ["POWER", BatteryService.valueText, BatteryService.available ? BatteryService.progress : -1, BatteryService.available], ["MEDIA", MediaService.status, -1, MediaService.available]]
            }
        }

    }

}
