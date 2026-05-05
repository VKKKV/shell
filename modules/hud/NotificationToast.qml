import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    id: root

    readonly property var notification: NotificationService.latest

    width: 360
    height: 116
    visible: NotificationService.toastVisible && notification !== null
    opacity: visible ? 1 : 0
    title: "ALERT // NOTIFICATION"
    highlighted: true

    Behavior on opacity {
        NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.panelPadding
        anchors.topMargin: 36
        spacing: 6

        TacticalLabel {
            Layout.fillWidth: true
            text: root.notification ? root.notification.appName + " // " + root.notification.time : ""
            dim: true
            elide: Text.ElideRight
        }

        TacticalLabel {
            Layout.fillWidth: true
            text: root.notification ? root.notification.summary : ""
            accent: true
            elide: Text.ElideRight
        }

        TacticalLabel {
            Layout.fillWidth: true
            text: root.notification ? root.notification.body : ""
            dim: true
            elide: Text.ElideRight
        }
    }
}
