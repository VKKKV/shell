import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

CentralPanelChrome {
    id: root

    title: "AGENT CORE // NEURAL MESH"
    headerText: "DEPLOYED FROM LEFT AGENT NODE // STAGED VISUAL CONTRACT // PROVIDER API DEFERRED"

    RowLayout {
        anchors.fill: parent
        spacing: Theme.densitySpacing

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 360

            NeuralMeshSphere {
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height) * 0.9
                height: width
                expanded: true
                label: "NEURAL AGENT CORE"
                statusText: AgentService.statusLine.toUpperCase()
            }
        }

        ColumnLayout {
            Layout.preferredWidth: Math.min(380, root.width * 0.34)
            Layout.fillHeight: true
            spacing: Theme.densitySpacing

            PanelStatusStrip {
                Layout.fillWidth: true
                leftText: "AGENT BUS"
                centerText: AgentService.state.toUpperCase()
                rightText: "ESC // CLOSE"
                warning: !AgentService.available
            }

            MetricBlock {
                title: "PROVIDER STAGE"
                rows: [["ACTIVE", AgentService.providerName, -1, AgentService.available], ["STATE", AgentService.state.toUpperCase(), -1, AgentService.running], ["HERMES", "PLANNED", -1, false], ["OPENCLAW", "PLANNED", -1, false], ["CUSTOM", "DEFERRED", -1, false]]
            }

            TextBlock {
                Layout.fillWidth: true
                title: "INTERACTION MODEL"
                lines: ["HOVER: LOCAL NODE PERTURB", "DRAG: ROTATE MESH", "CLICK ENTRY: OPEN PANEL", "CONFIG: FUTURE CONTRACT ONLY", "PERSISTENCE: NOT ENABLED"]
            }

            TextBlock {
                Layout.fillWidth: true
                title: "CONTRACT GUARD"
                lines: [AgentService.statusLine.toUpperCase(), AgentService.responseText, "NO SETTINGS SCHEMA CHANGE", "NO IPC UNTIL CONTRACT EXISTS"]
            }

            Item { Layout.fillHeight: true }

            TacticalLabel {
                Layout.fillWidth: true
                text: "Agent provider selection is intentionally staged as UI language only. Real Hermes/OpenClaw integration needs a command or endpoint contract before persistence is added."
                dim: true
                wrapMode: Text.WordWrap
                size: Theme.fontTiny
            }
        }
    }
}
