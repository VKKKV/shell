pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool nightLightAvailable: false
    property bool nightLightActive: false
    property string nightLightText: "NIGHT LIGHT // UNKNOWN"
    property string statusLine: "environment: initializing"

    function updateNightLight(output: string): void {
        const text = output.trim().toLowerCase();
        if (text.length === 0) {
            nightLightAvailable = false;
            nightLightActive = false;
            nightLightText = "NIGHT LIGHT // FALLBACK";
            statusLine = "environment: night light fallback";
            return;
        }

        nightLightAvailable = true;
        nightLightActive = text.indexOf("true") >= 0 || text.indexOf("yes") >= 0 || text.indexOf("1") === 0 || text.indexOf("temperature") >= 0;
        nightLightText = nightLightActive ? "NIGHT LIGHT // ACTIVE" : "NIGHT LIGHT // STANDBY";
        statusLine = nightLightActive ? "environment: night light active" : "environment: night light standby";
    }

    function refresh(): void {
        nightLightProcess.running = true;
    }

    Component.onCompleted: {
        if (SettingsService.liveDataEnabled) {
            refresh();
            poller.start();
        }
    }

    property Timer poller: Timer {
        interval: 30000
        repeat: true
        onTriggered: root.refresh()
    }

    Connections {
        target: SettingsService
        function onLiveDataEnabledChanged(): void {
            if (SettingsService.liveDataEnabled) {
                root.refresh();
                root.poller.start();
            } else
                root.poller.stop();
        }
    }

    property Process nightLightProcess: Process {
        command: ["sh", "-c", "if command -v hyprsunset >/dev/null 2>&1; then pgrep -x hyprsunset >/dev/null && echo true || echo false; elif command -v gammastep >/dev/null 2>&1; then pgrep -x gammastep >/dev/null && echo true || echo false; elif command -v redshift >/dev/null 2>&1; then pgrep -x redshift >/dev/null && echo true || echo false; else echo ''; fi"]
        stdout: StdioCollector {
            onStreamFinished: root.updateNightLight(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.nightLightAvailable = false;
                root.nightLightActive = false;
                root.nightLightText = "NIGHT LIGHT // FALLBACK";
                root.statusLine = "environment: command fallback";
            }
        }
    }
}
