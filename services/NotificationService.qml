pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool dndEnabled: false
    property var history: []
    property var latest: null
    property bool toastVisible: false
    property bool serverEnabled: false
    property string statusLine: "notifications: probing server"

    function notificationData(notification: Notification): var {
        return {
            id: notification.id,
            appName: notification.appName || "unknown",
            summary: notification.summary || "notification",
            body: notification.body || "",
            urgency: notification.urgency,
            time: Qt.formatDateTime(new Date(), "hh:mm:ss")
        };
    }

    function pushNotification(notification: Notification): void {
        notification.tracked = true;
        const data = notificationData(notification);
        latest = data;
        history = [data].concat(history).slice(0, 12);
        statusLine = "notifications: " + history.length + " captured";

        if (!dndEnabled) {
            toastVisible = true;
            toastTimer.restart();
        }
    }

    function clear(): void {
        history = [];
        latest = null;
        toastVisible = false;
        statusLine = "notifications: history cleared";
    }

    function toggleDnd(): void {
        dndEnabled = !dndEnabled;
        statusLine = dndEnabled ? "notifications: dnd enabled" : "notifications: dnd disabled";
    }

    property Timer toastTimer: Timer {
        interval: 5000
        repeat: false
        onTriggered: root.toastVisible = false
    }

    Component.onCompleted: probeProcess.running = true

    property Process probeProcess: Process {
        command: ["sh", "-c", "dbus-send --session --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.NameHasOwner string:org.freedesktop.Notifications 2>/dev/null | grep -q 'boolean true'"]
        onExited: (exitCode) => {
            root.serverEnabled = exitCode !== 0;
            root.statusLine = root.serverEnabled ? "notifications: server online" : "notifications: external daemon active";
        }
    }

    Loader {
        active: root.serverEnabled
        sourceComponent: NotificationServer {
            keepOnReload: false
            actionsSupported: false
            bodyMarkupSupported: false
            imageSupported: false
            persistenceSupported: false
            onNotification: (notification) => root.pushNotification(notification)
        }
    }
}
