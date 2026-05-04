pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real volume: 0
    property bool muted: false
    property bool available: false
    property string volumeText: "--%"
    property string statusLine: "audio: fallback"

    function updateVolume(output: string): void {
        const match = output.match(/Volume:\s+([0-9.]+)(\s+\[MUTED\])?/);
        if (!match) {
            available = false;
            volumeText = "--%";
            statusLine = "audio: parse fallback";
            return;
        }

        volume = Math.max(0, Math.min(1.5, Number(match[1])));
        muted = match[2] !== undefined;
        available = true;
        volumeText = muted ? "MUTED" : Math.round(volume * 100) + "%";
        statusLine = muted ? "audio: sink muted" : "audio: sink online";
    }

    function refresh(): void {
        readProcess.running = true;
    }

    function toggleMute(): void {
        actionProcess.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"];
        actionProcess.running = true;
    }

    function changeVolume(delta: real): void {
        const next = Math.max(0, Math.min(1.5, volume + delta));
        actionProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", next.toFixed(2)];
        actionProcess.running = true;
    }

    Component.onCompleted: refresh()

    property Timer poller: Timer {
        interval: 5000
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
    }

    property Process readProcess: Process {
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: root.updateVolume(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.available = false;
                root.volumeText = "--%";
                root.statusLine = "audio: wpctl fallback";
            }
        }
    }

    property Process actionProcess: Process {
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        onExited: root.refresh()
    }
}
