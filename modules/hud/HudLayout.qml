import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    readonly property bool compact: width > 0 && width < Theme.compactWidth
    readonly property int contentWidth: Math.max(0, width - Theme.margin * 2)
    readonly property int sideWidth: Math.max(Theme.sidePanelMinWidth, Math.min(Theme.sidePanelMaxWidth, Math.round(contentWidth * (compact ? 0.18 : 0.19))))
    readonly property int rightWidth: Math.max(Theme.rightPanelMinWidth, Math.min(Theme.rightPanelMaxWidth, Math.round(contentWidth * (compact ? 0.25 : 0.26))))

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        opacity: 0.72 + 0.16 * SettingsService.intensity
    }

    ScanlineOverlay {
        visible: SettingsService.scanlinesEnabled
        anchors.fill: parent
        lineOpacity: 0.025 * SettingsService.intensity
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.margin
        spacing: Theme.gap

        TopStatusBar {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.topBarHeight
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.gap

            LeftTacticalPanel {
                Layout.preferredWidth: root.sideWidth
                Layout.minimumWidth: Theme.sidePanelMinWidth
                Layout.maximumWidth: Theme.sidePanelMaxWidth
                Layout.fillHeight: true
            }

            CenterTerminalPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            RightMonitorPanel {
                Layout.preferredWidth: root.rightWidth
                Layout.minimumWidth: Theme.rightPanelMinWidth
                Layout.maximumWidth: Theme.rightPanelMaxWidth
                Layout.fillHeight: true
            }

        }

        BottomStatusBar {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.bottomBarHeight
        }

    }

    SettingsPanel {
        anchors.fill: parent
    }

    Shortcut {
        sequence: "Ctrl+Alt+S"
        onActivated: SettingsService.togglePanel()
    }

}
