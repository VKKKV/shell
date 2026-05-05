pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property var events: []
    property string statusLine: "service log: standby"

    function push(source: string, level: string, message: string): void {
        const normalizedLevel = ["info", "warn", "error"].indexOf(level) >= 0 ? level : "info";
        const entry = {
            time: Qt.formatDateTime(new Date(), "hh:mm:ss"),
            source,
            level: normalizedLevel,
            message
        };
        events = [entry].concat(events).slice(0, 16);
        statusLine = "service log: " + normalizedLevel + " " + source;
    }

    function clear(): void {
        events = [];
        statusLine = "service log: cleared";
    }
}
