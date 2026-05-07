import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

CentralPanelChrome {
    id: root

    title: "POWER GRID // ENERGY DRILLDOWN"
    headerText: "DEPLOYED FROM RIGHT POWER NODE // BATTERY + POWERPROFILECTL CONTROL"

    readonly property var profileRows: ["power-saver", "balanced", "performance"]

    function profileActive(profile: string): bool {
        return PowerProfileService.profile.toLowerCase() === profile;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.densitySpacing

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.densitySpacing

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Theme.densitySpacing

                MetricBlock {
                    title: "POWER SOURCE"
                    rows: [[BatteryService.label, BatteryService.valueText, BatteryService.available ? BatteryService.progress : -1, BatteryService.available], ["STATE", BatteryService.state, BatteryService.available ? BatteryService.progress : -1, BatteryService.state === "CHARGING"], ["PROFILE", PowerProfileService.profile, PowerProfileService.available ? 1 : -1, PowerProfileService.available], ["IDLE", PowerProfileService.idleInhibited ? "INHIBITED" : "NORMAL", PowerProfileService.idleInhibited ? 1 : 0, PowerProfileService.idleInhibited]]
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(120, Theme.densityGraphHeight + Theme.densityControlHeight)
                    color: "#55000000"
                    border.color: BatteryService.available ? Theme.line : Theme.lineDim
                    border.width: Theme.lineWidth

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.panelPadding
                        spacing: Theme.densitySpacing

                        TacticalLabel {
                            Layout.fillWidth: true
                            text: BatteryService.available ? "BATTERY CELL CHARGE // " + BatteryService.percentage + "%" : "AC BUS // BATTERY NOT DETECTED"
                            accent: BatteryService.available
                            dim: !BatteryService.available
                            elide: Text.ElideRight
                        }

                        ProgressBar {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.densityProgressHeight + 6
                            value: BatteryService.available ? BatteryService.progress : 1
                            fillColor: BatteryService.available ? Theme.line : Theme.lineDim
                        }

                        TextBlock {
                            Layout.fillWidth: true
                            title: "BATTERY TELEMETRY"
                            lines: [BatteryService.statusLine, "STATE: " + BatteryService.state, "VALUE: " + BatteryService.valueText, "POLL: " + (SettingsService.updateIntervalMs / 1000).toFixed(0) + "S"]
                        }
                    }
                }

                TextBlock {
                    title: "POWER HINT"
                    lines: [PowerProfileService.statusLine, PowerProfileService.powerHintLine, PowerProfileService.idleStatusLine, "CLICK PROFILE TO DISPATCH POWERPROFILECTL", "CLICK IDLE CONTROL TO TOGGLE INHIBITOR"]
                }
            }

            ColumnLayout {
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                spacing: Theme.densitySpacing

                TacticalLabel {
                    Layout.fillWidth: true
                    text: "PROFILE CONTROL // " + PowerProfileService.profile
                    accent: PowerProfileService.available
                    dim: !PowerProfileService.available
                    elide: Text.ElideRight
                }

                Repeater {
                    model: root.profileRows

                    Rectangle {
                        required property string modelData

                        readonly property bool active: root.profileActive(modelData)

                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.densityControlHeight
                        color: active ? Theme.lineDim : (profileArea.containsMouse ? Theme.panelSoft : "transparent")
                        border.color: active ? Theme.line : Theme.lineDim
                        border.width: Theme.lineWidth
                        opacity: PowerProfileService.available ? 1 : 0.45

                        MouseArea {
                            id: profileArea

                            anchors.fill: parent
                            cursorShape: PowerProfileService.available ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: PowerProfileService.available
                            hoverEnabled: true
                            onClicked: PowerProfileService.setProfile(parent.modelData)
                        }

                        TacticalLabel {
                            anchors.centerIn: parent
                            text: parent.modelData.toUpperCase()
                            accent: parent.active
                            dim: !parent.active
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.densityControlHeight
                    color: PowerProfileService.idleInhibited ? Theme.lineDim : (idleArea.containsMouse ? Theme.panelSoft : "transparent")
                    border.color: PowerProfileService.idleInhibited ? Theme.line : Theme.lineDim
                    border.width: Theme.lineWidth

                    MouseArea {
                        id: idleArea

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: PowerProfileService.toggleIdleInhibitor()
                    }

                    TacticalLabel {
                        anchors.centerIn: parent
                        text: PowerProfileService.idleInhibited ? "IDLE INHIBITOR // ACTIVE" : "IDLE INHIBITOR // STANDBY"
                        accent: PowerProfileService.idleInhibited
                        dim: !PowerProfileService.idleInhibited
                    }
                }

                TextBlock {
                    Layout.fillWidth: true
                    title: "CONTROL STATUS"
                    lines: [PowerProfileService.statusLine, PowerProfileService.idleStatusLine, BatteryService.statusLine, "MODE: CENTRAL DRILLDOWN", "BACKDROP OR CLOSE BUTTON DISMISSES"]
                }
            }
        }
    }
}
