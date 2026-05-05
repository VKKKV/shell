import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 12

    TextBlock {
        title: "SESSION // POWER"
        lines: [SessionService.statusLine, "click once to arm, click same action again to execute"]
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 8
        columnSpacing: 8

        Repeater {
            model: ["lock", "logout", "reboot", "shutdown"]

            Rectangle {
                required property string modelData

                Layout.fillWidth: true
                Layout.preferredHeight: 34
                color: SessionService.pendingAction === modelData ? Theme.lineDim : "transparent"
                border.color: SessionService.pendingAction === modelData ? Theme.line : Theme.lineDim
                border.width: Theme.lineWidth

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SessionService.confirm(parent.modelData)
                }

                TacticalLabel {
                    anchors.centerIn: parent
                    text: parent.modelData.toUpperCase()
                    accent: SessionService.pendingAction === parent.modelData
                    dim: SessionService.pendingAction !== parent.modelData
                }
            }
        }
    }

    TextBlock {
        title: "CONFIG"
        lines: ["$XDG_CONFIG_HOME/void-shell/settings.json", "schema normalization: active", "helper: void-shell-settings"]
    }

    TacticalLabel {
        Layout.fillWidth: true
        text: "CLIPBOARD BUFFER"
        accent: true
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            color: "transparent"
            border.color: Theme.lineDim
            border.width: Theme.lineWidth

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: ClipboardService.refresh()
            }

            TacticalLabel {
                anchors.centerIn: parent
                text: "REFRESH"
                accent: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            color: "transparent"
            border.color: Theme.lineDim
            border.width: Theme.lineWidth

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: ClipboardService.clear()
            }

            TacticalLabel {
                anchors.centerIn: parent
                text: "CLEAR"
                dim: true
            }
        }
    }

    Repeater {
        model: ClipboardService.history.slice(0, 4)

        Rectangle {
            required property var modelData

            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: clipArea.containsMouse ? Theme.panelSoft : "transparent"
            border.color: Theme.lineDim
            border.width: Theme.lineWidth

            MouseArea {
                id: clipArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: ClipboardService.copy(parent.modelData.text)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                TacticalLabel {
                    text: modelData.time
                    dim: true
                }

                TacticalLabel {
                    Layout.fillWidth: true
                    text: modelData.preview
                    accent: clipArea.containsMouse
                    elide: Text.ElideRight
                }
            }
        }
    }

    TacticalLabel {
        Layout.fillWidth: true
        text: "NOTIFICATION HISTORY"
        accent: true
    }

    Repeater {
        model: NotificationService.history.slice(0, 4)

        Rectangle {
            required property var modelData

            Layout.fillWidth: true
            Layout.preferredHeight: 34
            color: "transparent"
            border.color: Theme.lineDim
            border.width: Theme.lineWidth

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 0

                TacticalLabel {
                    Layout.fillWidth: true
                    text: modelData.appName + " // " + modelData.time
                    dim: true
                    elide: Text.ElideRight
                }

                TacticalLabel {
                    Layout.fillWidth: true
                    text: modelData.summary
                    accent: true
                    elide: Text.ElideRight
                }
            }
        }
    }

    TacticalLabel {
        Layout.fillWidth: true
        text: "LAUNCHER // RESULTS"
        accent: true
    }

    Repeater {
        model: LauncherService.filtered

        Rectangle {
            required property var modelData

            Layout.fillWidth: true
            Layout.preferredHeight: 28
            color: resultArea.containsMouse ? Theme.panelSoft : "transparent"
            border.color: modelData.type === "action" ? Theme.line : Theme.lineDim
            border.width: Theme.lineWidth

            MouseArea {
                id: resultArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: LauncherService.launch(parent.modelData)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                TacticalLabel {
                    text: modelData.type.toUpperCase()
                    accent: modelData.type === "action"
                    dim: modelData.type !== "action"
                }

                TacticalLabel {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: modelData.name
                    accent: resultArea.containsMouse
                }
            }
        }
    }
}
