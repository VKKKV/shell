import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

CentralPanelChrome {
    id: root

    property string promptText: ""

    function submitPrompt(): void {
        const clean = promptText.trim();
        if (clean.length === 0)
            return;

        AgentService.submit(clean);
        promptText = "";
    }

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
                rows: [["ACTIVE", AgentService.providerName, -1, AgentService.available], ["STATE", AgentService.state.toUpperCase(), -1, AgentService.running], ["HERMES", AgentService.hermesAvailable ? "AVAILABLE" : "NOT FOUND", -1, AgentService.hermesAvailable], ["OPENCLAW", AgentService.openClawAvailable ? "AVAILABLE" : "NOT FOUND", -1, AgentService.openClawAvailable], ["CUSTOM", "DEFERRED", -1, false]]
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                rowSpacing: Theme.densitySmallSpacing
                columnSpacing: Theme.densitySmallSpacing

                Repeater {
                    model: AgentService.providerPresets

                    Rectangle {
                        required property var modelData

                        readonly property bool selected: AgentService.providerName === modelData.name

                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.densityControlHeight
                        color: selected ? Theme.lineDim : (providerArea.containsMouse ? Theme.panelSoft : "transparent")
                        border.color: selected ? Theme.line : Theme.lineDim
                        border.width: Theme.lineWidth
                        opacity: modelData.available || modelData.id === "disabled" ? 1 : 0.55

                        MouseArea {
                            id: providerArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: AgentService.selectProvider(parent.modelData.id)
                            onEntered: TooltipService.show("AGENT PROVIDER", parent.modelData.detail, "agent-provider-" + parent.modelData.id)
                            onExited: TooltipService.clear("agent-provider-" + parent.modelData.id)
                        }

                        TacticalLabel {
                            anchors.centerIn: parent
                            text: parent.modelData.name
                            accent: parent.selected
                            dim: !parent.selected
                        }
                    }
                }
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

            TacticalFrame {
                Layout.fillWidth: true
                implicitHeight: 84
                title: "PROMPT // STAGED"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.panelPadding
                    anchors.rightMargin: Theme.panelPadding
                    anchors.topMargin: 28
                    anchors.bottomMargin: 8
                    spacing: Theme.densitySmallSpacing

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Theme.panelSoft
                        border.color: promptInput.activeFocus ? Theme.line : Theme.lineDim
                        border.width: Theme.lineWidth

                        TextInput {
                            id: promptInput

                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: TextInput.AlignVCenter
                            color: Theme.text
                            selectionColor: Theme.lineDim
                            selectedTextColor: Theme.background
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSmall
                            text: root.promptText
                            clip: true
                            onTextChanged: root.promptText = text
                            onAccepted: root.submitPrompt()
                        }

                        TacticalLabel {
                            visible: promptInput.text.length === 0 && !promptInput.activeFocus
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            text: "ENTER LOCAL AGENT PROMPT"
                            dim: true
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 86
                        Layout.fillHeight: true
                        color: submitArea.containsMouse ? Theme.panelSoft : "transparent"
                        border.color: root.promptText.trim().length > 0 ? Theme.line : Theme.lineDim
                        border.width: Theme.lineWidth
                        opacity: root.promptText.trim().length > 0 ? 1 : 0.45

                        MouseArea {
                            id: submitArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: root.promptText.trim().length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: root.submitPrompt()
                            onEntered: TooltipService.show("AGENT SUBMIT", "Dispatch prompt to the active provider when its command is available.", "agent-submit")
                            onExited: TooltipService.clear("agent-submit")
                        }

                        TacticalLabel {
                            anchors.centerIn: parent
                            text: "SUBMIT"
                            accent: root.promptText.trim().length > 0
                            dim: root.promptText.trim().length === 0
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            TacticalLabel {
                Layout.fillWidth: true
                text: "Provider selection persists across sessions. Commands execute only when the selected provider binary is available on PATH."
                dim: true
                wrapMode: Text.WordWrap
                size: Theme.fontTiny
            }
        }
    }
}
