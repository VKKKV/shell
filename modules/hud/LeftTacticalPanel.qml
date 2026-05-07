import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    id: root

    title: "ORBITAL // CLOCK"
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

            AnalogOrbitClock {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(260, Math.max(180, root.height * 0.36))
                onActivated: ExpansionService.show("orbital", "left-clock")
            }

            RotatingGlobe {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Math.min(parent.width, 170)
                Layout.preferredHeight: Layout.preferredWidth
                latitude: EarthLocationService.latitude
                longitude: EarthLocationService.longitude
                locationAvailable: EarthLocationService.available
                label: "EARTH FIX"
                statusText: EarthLocationService.statusLine.toUpperCase()
                onActivated: ExpansionService.show("earth", "left-earth")

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: TooltipService.show("EARTH GEO", "Open the central rotating Earth panel. IP geolocation marks the approximate current network location when available.", "left-earth")
                    onExited: TooltipService.clear("left-earth")
                    onClicked: ExpansionService.show("earth", "left-earth")
                }
            }

            MetricBlock {
                title: "GLOBAL LINK"
                rows: [["STATUS", EarthLocationService.available ? "GEO LOCK" : "TRACKING", -1, EarthLocationService.available], ["PLACE", EarthLocationService.displayText, -1, EarthLocationService.available], ["COORD", EarthLocationService.coordinateText, -1, EarthLocationService.available], ["SIGNAL", "98%", 0.98, false]]
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

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: telemetryBlock.implicitHeight

                MetricBlock {
                    id: telemetryBlock

                    title: "TELEMETRY"
                    rows: [["AUDIO", AudioService.volumeText, AudioService.available ? AudioService.volume : -1, AudioService.available], ["POWER", BatteryService.valueText, BatteryService.available ? BatteryService.progress : -1, BatteryService.available], ["MEDIA", MediaService.status, -1, MediaService.available]]
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: TooltipService.show("TELEMETRY DRILLDOWN", "Open media/audio/link telemetry expansion in the central safe area.", "left-telemetry")
                    onExited: TooltipService.clear("left-telemetry")
                    onClicked: ExpansionService.show("media", "left-telemetry")
                }
            }
        }

    }

}
