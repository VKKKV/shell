import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

CentralPanelChrome {
    id: root

    title: "EARTH GEO // IP FIX"
    headerText: "TERRESTRIAL LOCATION SURFACE // OFFLINE VECTOR COASTLINE // OPTIONAL IP GEO"

    RowLayout {
        anchors.fill: parent
        spacing: Theme.densitySpacing

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 320

            RotatingGlobe {
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height) * 0.9
                height: width
                expanded: true
                latitude: EarthLocationService.latitude
                longitude: EarthLocationService.longitude
                locationAvailable: EarthLocationService.available
                label: "EARTH GEO SURFACE"
                statusText: EarthLocationService.statusLine.toUpperCase()
            }
        }

        ColumnLayout {
            Layout.preferredWidth: Math.min(360, root.width * 0.34)
            Layout.fillHeight: true
            spacing: Theme.densitySpacing

            PanelStatusStrip {
                Layout.fillWidth: true
                leftText: "IP GEO"
                centerText: EarthLocationService.available ? "LOCATION LOCK" : "FALLBACK"
                rightText: "ESC // CLOSE"
                warning: !EarthLocationService.available
            }

            TextBlock {
                Layout.fillWidth: true
                title: "LOCATION FIX"
                lines: [
                    EarthLocationService.statusLine,
                    "SOURCE: " + EarthLocationService.source.toUpperCase(),
                    "PLACE: " + EarthLocationService.displayText,
                    "COORD: " + EarthLocationService.coordinateText,
                    "REGION: " + (EarthLocationService.region.length > 0 ? EarthLocationService.region : "--"),
                    "IP: " + (EarthLocationService.ip.length > 0 ? EarthLocationService.ip : "--")
                ]
            }

            TextBlock {
                Layout.fillWidth: true
                title: "SURFACE MODEL"
                lines: [
                    "COAST: OFFLINE VECTOR DATASET + TACTICAL OVERLAY",
                    "OCEAN: PROCEDURAL DEPTH HASH + SCAN TEXTURE",
                    "LAND: CLIPPED TERRAIN TINT / CONTOUR NOISE",
                    "DRAG: HORIZONTAL SWIPE ROTATES LONGITUDE",
                    "GRID: 15/30 DEG LAT/LON",
                    "NODES: LOCAL SIGNAL BEACONS",
                    "LIGHT: SYNTHETIC NIGHT TERMINATOR + RIM GLOW",
                    "IP GEO: SETTINGS OPT-IN",
                    "FALLBACK: GLOBE REMAINS LIVE"
                ]
            }

            Item { Layout.fillHeight: true }

            TacticalLabel {
                Layout.fillWidth: true
                text: SettingsService.networkGeolocationEnabled ? "Network IP geolocation is approximate and contacts a third-party endpoint. It depends on the active network egress point; no precision GPS source is used." : "Default location mode is offline timezone inference. It is coarse, avoids network lookup, and can differ from your actual city."
                dim: true
                wrapMode: Text.WordWrap
                size: Theme.fontTiny
            }
        }
    }
}
