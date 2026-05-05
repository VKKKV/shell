import "../services"
import "../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    id: root

    property alias headerText: headerLabel.text
    default property alias content: contentHost.data
    property bool commandCenter: false

    highlighted: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.panelPadding
        anchors.topMargin: 42
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            TacticalLabel {
                id: headerLabel

                Layout.fillWidth: true
                accent: true
                elide: Text.ElideRight
            }

            PanelCloseButton {
                Layout.preferredWidth: implicitWidth
                Layout.preferredHeight: implicitHeight
                onCloseRequested: {
                    if (root.commandCenter)
                        SettingsService.panelOpen = false;
                    else
                        ExpansionService.close();
                }
            }
        }

        Item {
            id: contentHost

            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
