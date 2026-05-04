pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property string player: ""
    property string status: "STOPPED"
    property string artist: ""
    property string title: "NO ACTIVE MEDIA"
    property string displayText: "MEDIA // IDLE"
    property string statusLine: "media: fallback"

    function compact(text: string, maxLength: int): string {
        if (text.length <= maxLength)
            return text;
        return text.slice(0, Math.max(0, maxLength - 3)) + "...";
    }

    function updateMetadata(output: string): void {
        const line = output.trim();
        if (line.length === 0) {
            available = false;
            displayText = "MEDIA // IDLE";
            statusLine = "media: no active player";
            return;
        }

        const parts = line.split("|");
        player = parts[0] || "player";
        status = (parts[1] || "UNKNOWN").toUpperCase();
        artist = parts[2] || "";
        title = parts.slice(3).join("|") || "UNKNOWN TRACK";
        available = true;

        const track = artist.length > 0 ? artist + " - " + title : title;
        displayText = compact(status + " // " + track, 44);
        statusLine = "media: " + player + " " + status.toLowerCase();
    }

    function refresh(): void {
        readProcess.running = true;
    }

    function control(action: string): void {
        if (action !== "play-pause" && action !== "next" && action !== "previous")
            return;
        actionProcess.command = ["playerctl", action];
        actionProcess.running = true;
    }

    Component.onCompleted: refresh()

    property Timer poller: Timer {
        interval: SettingsService.updateIntervalMs
        repeat: true
        running: SettingsService.liveDataEnabled
        onTriggered: root.refresh()
    }

    Connections {
        target: SettingsService
        function onLiveDataEnabledChanged(): void {
            if (SettingsService.liveDataEnabled) {
                root.refresh();
                root.poller.restart();
            }
        }
        function onUpdateIntervalMsChanged(): void {
            if (SettingsService.liveDataEnabled)
                root.poller.restart();
        }
    }

    property Process readProcess: Process {
        command: ["playerctl", "metadata", "--format", "{{playerName}}|{{status}}|{{artist}}|{{title}}"]
        stdout: StdioCollector {
            onStreamFinished: root.updateMetadata(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.available = false;
                root.displayText = "MEDIA // IDLE";
                root.statusLine = "media: playerctl fallback";
            }
        }
    }

    property Process actionProcess: Process {
        command: ["playerctl", "metadata"]
        onExited: root.refresh()
    }
}
