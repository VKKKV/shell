import "../../components"
import "../../theme"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        opacity: 0.88
    }

    ScanlineOverlay {
        anchors.fill: parent
        lineOpacity: 0.025
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
                Layout.preferredWidth: Theme.sidePanelWidth
                Layout.fillHeight: true
            }

            CenterTerminalPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            RightMonitorPanel {
                Layout.preferredWidth: Theme.rightPanelWidth
                Layout.fillHeight: true
            }

        }

        BottomStatusBar {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.bottomBarHeight
        }

    }

}
