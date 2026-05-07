import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    id: root

    implicitHeight: Math.min(Theme.topBarMaxHeight, Math.max(Theme.topBarMinHeight, content.implicitHeight + Theme.panelPadding * 2))
    highlighted: true

    RowLayout {
        id: content

        anchors.fill: parent
        anchors.margins: Theme.panelPadding
        spacing: Theme.gap

        Column {
            Layout.preferredWidth: 260
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            TacticalLabel {
                text: Time.timeText
                accent: true
                size: Theme.fontClock
            }

            TacticalLabel {
                text: Time.dateText
                dim: true
            }

        }

        Row {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            spacing: 10

            Repeater {
                model: CompositorService.workspaces

                Rectangle {
                    id: workspaceButton

                    required property var modelData

                    readonly property int workspaceId: Number(modelData.id)
                    readonly property string label: String(modelData.label ?? modelData.id)
                    readonly property bool active: modelData.active
                    readonly property bool occupied: modelData.occupied
                    property bool hovered: false

                    width: Math.max(34, Math.min(86, workspaceLabel.implicitWidth + 18))
                    height: 24
                    color: active ? Theme.line : (hovered ? Theme.lineDim : (occupied ? Theme.panelSoft : "transparent"))
                    border.color: active || occupied || hovered ? Theme.line : Theme.lineDim
                    border.width: Theme.lineWidth

                    TacticalLabel {
                        id: workspaceLabel

                        anchors.centerIn: parent
                        width: parent.width - 10
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        text: parent.label
                        color: parent.active ? Theme.background : Theme.line
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: {
                            workspaceButton.hovered = true;
                            TooltipService.show("WORKSPACE " + workspaceButton.label, "Switch compositor workspace. Active backend: " + CompositorService.compositorName + ".", "workspace-" + workspaceButton.workspaceId);
                        }
                        onExited: {
                            workspaceButton.hovered = false;
                            TooltipService.clear("workspace-" + workspaceButton.workspaceId);
                        }
                        onClicked: CompositorService.switchWorkspace(workspaceButton.workspaceId)
                    }

                }

            }

        }

        ColumnLayout {
            Layout.preferredWidth: 500
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            spacing: 6

            TacticalLabel {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: "// VOID.SYS.V2.0"
                accent: true
                size: Theme.fontNormal
            }

            TacticalLabel {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                elide: Text.ElideRight
                text: CompositorService.compositorName.toUpperCase() + " // " + (CompositorService.available ? "ONLINE" : "FALLBACK")
                dim: true
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                spacing: 6

                TacticalLabel {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                    text: "ACTIVE // " + CompositorService.activeWindowClass + " // " + CompositorService.activeWindowTitle
                    accent: CompositorService.activeWindowAvailable
                    dim: !CompositorService.activeWindowAvailable
                }

                TacticalLabel {
                    text: "AUDIO " + AudioService.volumeText
                    accent: AudioService.available && !AudioService.muted
                    dim: !AudioService.available || AudioService.muted
                }

                Sparkline {
                    Layout.preferredWidth: 70
                    Layout.preferredHeight: 18
                    values: AudioService.spectrum.slice(0, 10)
                    barColor: AudioService.available && !AudioService.muted ? Theme.line : Theme.lineDim
                }

                Rectangle {
                    width: 22
                    height: 18
                    color: "transparent"
                    border.color: Theme.lineDim
                    border.width: Theme.lineWidth

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: TooltipService.show("AUDIO DOWN", "Lower sink volume by 5 percent via wpctl.", "audio-down")
                        onExited: TooltipService.clear("audio-down")
                        onClicked: AudioService.changeVolume(-0.05)
                    }

                    TacticalLabel {
                        anchors.centerIn: parent
                        text: "-"
                        accent: true
                    }

                }

                Rectangle {
                    width: 22
                    height: 18
                    color: AudioService.muted ? Theme.lineDim : "transparent"
                    border.color: AudioService.available ? Theme.line : Theme.lineDim
                    border.width: Theme.lineWidth

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: TooltipService.show("AUDIO MUTE", "Toggle default sink mute. Current: " + AudioService.volumeText + ".", "audio-mute")
                        onExited: TooltipService.clear("audio-mute")
                        onClicked: AudioService.toggleMute()
                    }

                    TacticalLabel {
                        anchors.centerIn: parent
                        text: "M"
                        accent: AudioService.available
                        dim: !AudioService.available
                    }

                }

                Rectangle {
                    width: 22
                    height: 18
                    color: "transparent"
                    border.color: Theme.lineDim
                    border.width: Theme.lineWidth

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: TooltipService.show("AUDIO UP", "Raise sink volume by 5 percent via wpctl.", "audio-up")
                        onExited: TooltipService.clear("audio-up")
                        onClicked: AudioService.changeVolume(0.05)
                    }

                    TacticalLabel {
                        anchors.centerIn: parent
                        text: "+"
                        accent: true
                    }

                }

            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Rectangle {
                    Layout.preferredWidth: 84
                    Layout.preferredHeight: 20
                    color: settingsArea.containsMouse || SettingsService.panelOpen ? Theme.lineDim : "transparent"
                    border.color: settingsArea.containsMouse || SettingsService.panelOpen ? Theme.line : Theme.border
                    border.width: Theme.lineWidth

                    MouseArea {
                        id: settingsArea

                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: TooltipService.show("COMMAND CENTER", "Open the tactical command/settings panel. Shortcut: Ctrl+Alt+S.", "settings-entry")
                        onExited: TooltipService.clear("settings-entry")
                        onClicked: SettingsService.togglePanel()
                    }

                    TacticalLabel {
                        anchors.centerIn: parent
                        text: "SETTINGS"
                        accent: settingsArea.containsMouse || SettingsService.panelOpen
                        size: Theme.fontTiny
                    }
                }

                TrayStrip {
                }

                TacticalLabel {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                    text: MediaService.displayText
                    accent: MediaService.available && MediaService.status === "PLAYING"
                    dim: !MediaService.available
                }

                Rectangle {
                    width: 22
                    height: 18
                    color: "transparent"
                    border.color: Theme.lineDim
                    border.width: Theme.lineWidth

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: TooltipService.show("MEDIA PREVIOUS", "Dispatch previous-track through MediaService/playerctl.", "media-prev")
                        onExited: TooltipService.clear("media-prev")
                        onClicked: MediaService.control("previous")
                    }

                    TacticalLabel {
                        anchors.centerIn: parent
                        text: "<"
                        accent: MediaService.available
                        dim: !MediaService.available
                    }

                }

                Rectangle {
                    width: 22
                    height: 18
                    color: MediaService.status === "PLAYING" ? Theme.lineDim : "transparent"
                    border.color: MediaService.available ? Theme.line : Theme.lineDim
                    border.width: Theme.lineWidth

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: TooltipService.show("MEDIA PLAY/PAUSE", "Toggle active MPRIS playback. Current: " + MediaService.status + ".", "media-toggle")
                        onExited: TooltipService.clear("media-toggle")
                        onClicked: MediaService.control("play-pause")
                    }

                    TacticalLabel {
                        anchors.centerIn: parent
                        text: MediaService.status === "PLAYING" ? "||" : ">"
                        accent: MediaService.available
                        dim: !MediaService.available
                    }

                }

                Rectangle {
                    width: 22
                    height: 18
                    color: "transparent"
                    border.color: Theme.lineDim
                    border.width: Theme.lineWidth

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: TooltipService.show("MEDIA NEXT", "Dispatch next-track through MediaService/playerctl.", "media-next")
                        onExited: TooltipService.clear("media-next")
                        onClicked: MediaService.control("next")
                    }

                    TacticalLabel {
                        anchors.centerIn: parent
                        text: ">"
                        accent: MediaService.available
                        dim: !MediaService.available
                    }

                }

            }

        }

    }

}
