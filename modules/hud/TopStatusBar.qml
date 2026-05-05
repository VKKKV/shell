import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    id: root

    property int activeWorkspace: HyprlandService.activeWorkspace

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
                model: 5

                Rectangle {
                    id: workspaceButton

                    required property int index
                    readonly property bool active: index + 1 === root.activeWorkspace
                    readonly property bool occupied: HyprlandService.isOccupied(index + 1)
                    property bool hovered: false

                    width: 34
                    height: 24
                    color: active ? Theme.line : (hovered ? Theme.lineDim : (occupied ? Theme.panelSoft : "transparent"))
                    border.color: active || occupied || hovered ? Theme.line : Theme.lineDim
                    border.width: Theme.lineWidth

                    TacticalLabel {
                        anchors.centerIn: parent
                        text: index + 1
                        color: parent.active ? Theme.background : Theme.line
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: workspaceButton.hovered = true
                        onExited: workspaceButton.hovered = false
                        onClicked: HyprlandService.switchWorkspace(parent.index + 1)
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
                text: HyprlandService.available ? "HYPRLAND // QML RENDERER" : "HYPRLAND // FALLBACK MODE"
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
                    text: "ACTIVE // " + HyprlandService.activeWindowClass + " // " + HyprlandService.activeWindowTitle
                    accent: HyprlandService.activeToplevel !== null
                    dim: HyprlandService.activeToplevel === null
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
