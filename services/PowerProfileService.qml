pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string profile: "UNKNOWN"
    property bool idleInhibited: false
    property bool available: false
    property bool idleAvailable: false
    property bool commandAvailable: false
    property string statusLine: "power profile: initializing"
    property string idleStatusLine: "idle inhibitor: initializing"
    property string powerHintLine: "power hint: probing"

    function updateProfile(output: string): void {
        const text = output.trim();
        if (text.length === 0) {
            available = false;
            profile = "UNKNOWN";
            statusLine = "power profile: fallback";
            return;
        }

        available = true;
        profile = text.toUpperCase();
        statusLine = "power profile: " + profile;
        powerHintLine = profile === "PERFORMANCE" ? "power hint: maximum clocks, higher drain" : (profile === "POWER-SAVER" ? "power hint: reduced clocks, extended runtime" : "power hint: balanced tactical envelope");
    }

    function setProfile(next: string): void {
        if (!commandAvailable || !available)
            return;
        profileProcess.command = ["powerprofilesctl", "set", next];
        profileProcess.running = true;
    }

    function toggleIdleInhibitor(): void {
        if (idleInhibited) {
            idleProcess.running = false;
            idleInhibited = false;
            idleStatusLine = "idle inhibitor: released";
            return;
        }

        idleProcess.running = true;
    }

    function refresh(): void {
        availabilityProcess.running = true;
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

    property Process availabilityProcess: Process {
        command: ["sh", "-c", "command -v powerprofilesctl >/dev/null 2>&1"]
        onExited: (exitCode) => {
            root.commandAvailable = exitCode === 0;
            if (root.commandAvailable)
                root.refreshProcess.running = true;
            else {
                root.available = false;
                root.profile = "UNAVAILABLE";
                root.statusLine = "power profile: command missing";
                root.powerHintLine = "power hint: install powerprofilesctl";
            }
        }
    }

    property Process refreshProcess: Process {
        command: ["sh", "-c", "powerprofilesctl get"]
        stdout: StdioCollector {
            onStreamFinished: root.updateProfile(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.available = false;
                root.profile = "UNAVAILABLE";
                root.statusLine = "power profile: command fallback";
                root.powerHintLine = "power hint: profile read failed";
            }
        }
    }

    property Process profileProcess: Process {
        command: ["sh", "-c", "powerprofilesctl get"]
        onExited: (exitCode) => {
            if (exitCode === 0)
                root.refresh();
            else
                root.statusLine = "power profile: set fallback";
        }
    }

    property Process idleProcess: Process {
        command: ["systemd-inhibit", "--what=idle", "--who=void-shell", "--why=HUD idle inhibitor", "sleep", "infinity"]
        onStarted: {
            root.idleAvailable = true;
            root.idleInhibited = true;
            root.idleStatusLine = "idle inhibitor: active";
        }
        onExited: (exitCode) => {
            root.idleInhibited = false;
            if (exitCode === 0)
                root.idleStatusLine = "idle inhibitor: released";
            else {
                root.idleAvailable = false;
                root.idleStatusLine = "idle inhibitor: fallback";
            }
        }
    }
}
