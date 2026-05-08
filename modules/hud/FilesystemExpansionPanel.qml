import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

CentralPanelChrome {
    id: root

    title: "FILESYSTEM MATRIX // STORAGE DRILLDOWN"
    headerText: "DEPLOYED FROM RIGHT FILESYSTEM NODE // DF -B1 STORAGE TELEMETRY"

    function glyph(value: real): string {
        if (value >= 0.85)
            return "CRITICAL";
        if (value >= 0.7)
            return "WARN";
        if (value >= 0.45)
            return "ACTIVE";
        return "STABLE";
    }

    function totalUsage(): real {
        if (SystemStats.filesystemRows.length === 0)
            return 0;
        let total = 0;
        for (const row of SystemStats.filesystemRows)
            total += Math.max(0, Math.min(1, row[2]));
        return total / SystemStats.filesystemRows.length;
    }

    function mountSummary(): string {
        if (SystemStats.filesystemRows.length === 0)
            return "MOUNT GLYPHS // NO MOUNTS TRACKED";
        let stable = 0, active = 0, warn = 0, critical = 0;
        for (const row of SystemStats.filesystemRows) {
            const pct = row[2];
            if (pct >= 0.85) critical++;
            else if (pct >= 0.7) warn++;
            else if (pct >= 0.45) active++;
            else stable++;
        }
        let parts = [];
        if (critical > 0) parts.push(critical + " CRIT");
        if (warn > 0) parts.push(warn + " WARN");
        parts.push(active + " ACTIVE");
        parts.push(stable + " STABLE");
        return "MOUNT GLYPHS // " + parts.join(" // ");
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.densitySpacing

        PanelStatusStrip {
            leftText: "STORAGE // LIVE"
            centerText: "MOUNT BUS // " + SystemStats.filesystemRows.length + " MOUNTS"
            rightText: "ESC // CLOSE"
            warning: SystemStats.statusLine.toLowerCase().indexOf("fallback") >= 0
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.densitySpacing

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Theme.densitySpacing

                Repeater {
                    model: SystemStats.filesystemRows

                    Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.densityCardHeight
                        color: modelData[2] >= 0.7 ? Theme.lineDim : "#44000000"
                        border.color: modelData[2] >= 0.7 ? Theme.line : Theme.lineDim
                        border.width: Theme.lineWidth

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: Theme.densitySmallSpacing * 0.75

                            RowLayout {
                                Layout.fillWidth: true

                                TacticalLabel {
                                    Layout.fillWidth: true
                                    text: modelData[0]
                                    accent: true
                                }

                                TacticalLabel {
                                    text: root.glyph(modelData[2]) + " // " + modelData[1]
                                    accent: modelData[2] >= 0.7
                                    dim: modelData[2] < 0.7
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: Theme.densityProgressHeight
                                color: "transparent"
                                border.color: Theme.lineDim
                                border.width: Theme.lineWidth

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: parent.width * Math.max(0, Math.min(1, modelData[2]))
                                    color: modelData[2] >= 0.7 ? Theme.line : Theme.lineDim
                                }
                            }

                            TacticalLabel {
                                Layout.fillWidth: true
                                text: "MOUNT_STATUS // " + (modelData[3] ? "PRIORITY" : "MONITORED")
                                dim: true
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#33000000"
                    border.color: Theme.lineDim
                    border.width: Theme.lineWidth

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.panelPadding
                        spacing: Theme.densitySpacing

                        TacticalLabel {
                            Layout.fillWidth: true
                            text: "STORAGE ARRAY LOAD // " + Math.round(root.totalUsage() * 100) + "%"
                            accent: true
                        }

                        ProgressBar {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.densityProgressHeight + 8
                            value: root.totalUsage()
                            fillColor: root.totalUsage() >= 0.7 ? Theme.line : Theme.lineDim
                        }

                        TextBlock {
                            Layout.fillWidth: true
                            title: "MOUNT MAP"
                            lines: SystemStats.filesystemRows.map(row => row[0] + " // " + row[1] + " // " + root.glyph(row[2]))
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.preferredWidth: 280
                Layout.fillHeight: true
                spacing: Theme.densitySpacing

                TextBlock {
                    title: "STORAGE STATUS"
                    lines: [SystemStats.filesystemStatus, root.mountSummary(), "MOUNTS: " + SystemStats.filesystemRows.length, "SOURCE: df -B1", "TARGETS: / /home /data", "FAILSAFE: missing mounts skipped"]
                }

                MetricBlock {
                    title: "MEMORY COUPLING"
                    rows: [["RAM", SystemStats.ramText, SystemStats.ramProgress, true], ["SWAP", SystemStats.swapText, SystemStats.swapProgress, false]]
                }

                TextBlock {
                    title: "TACTICAL NOTES"
                    lines: ["BACKDROP / ESC CLOSES PANEL", "USAGE >= 70% // WARN GLYPH", "USAGE >= 85% // CRITICAL GLYPH", "READ-ONLY TELEMETRY BUS", "DF -B1 LIVE POLL // SYSTEMSTATS", "MOUNT STATUS TIERS VISIBLE IN ARRAY"]
                }
            }
        }
    }
}
