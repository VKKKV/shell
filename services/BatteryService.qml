pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property int percentage: 0
    property real progress: 0
    property string state: "UNKNOWN"
    property string label: "POWER"
    property string valueText: "AC POWER"
    property string statusLine: "battery: no battery detected"

    function updateBattery(output: string): void {
        const lines = output.trim().split("\n").filter(line => line.length > 0);
        if (lines.length < 2 || lines[0] === "none") {
            available = false;
            percentage = 0;
            progress = 0;
            state = "AC";
            valueText = "AC POWER";
            statusLine = "battery: no battery detected";
            return;
        }

        const capacity = Number(lines[0]);
        available = !Number.isNaN(capacity);
        percentage = available ? Math.max(0, Math.min(100, Math.round(capacity))) : 0;
        progress = percentage / 100;
        state = lines[1].toUpperCase();
        valueText = available ? percentage + "% " + state : "AC POWER";
        statusLine = available ? "battery: sysfs online" : "battery: sysfs fallback";
    }

    function refresh(): void {
        readProcess.running = true;
    }

    Component.onCompleted: startupPoll.start()

    property Timer startupPoll: Timer {
        interval: PollingSchedule.startupDelay(2)
        repeat: false
        running: SettingsService.liveDataEnabled
        onTriggered: {
            root.refresh();
            root.poller.start();
        }
    }

    property Timer poller: Timer {
        interval: SettingsService.updateIntervalMs
        repeat: true
        running: false
        onTriggered: root.refresh()
    }

    Connections {
        target: SettingsService
        function onLiveDataEnabledChanged(): void {
            if (SettingsService.liveDataEnabled) {
                root.refresh();
                root.poller.restart();
            } else {
                root.startupPoll.stop();
                root.poller.stop();
            }
        }
        function onUpdateIntervalMsChanged(): void {
            if (SettingsService.liveDataEnabled)
                root.poller.restart();
        }
    }

    property Process readProcess: Process {
        command: ["sh", "-c", "set -- /sys/class/power_supply/BAT*; [ -e \"$1\" ] || { printf 'none\\n'; exit 0; }; printf '%s\\n' \"$(cat \"$1/capacity\" 2>/dev/null)\" \"$(cat \"$1/status\" 2>/dev/null)\""]
        stdout: StdioCollector {
            onStreamFinished: root.updateBattery(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.available = false;
                root.valueText = "AC POWER";
                root.statusLine = "battery: sysfs fallback";
            }
        }
    }
}
