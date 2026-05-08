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
    property real micVolume: 0
    property bool micMuted: false
    property bool micAvailable: false
    property string volumeText: "--%"
    property string micText: "--%"
    property var spectrum: [0.12, 0.32, 0.18, 0.48, 0.28, 0.62, 0.34, 0.72, 0.42, 0.58, 0.24, 0.44]
    property real spectrumPhase: 0
    property string statusLine: "audio: fallback"
    property string micStatusLine: "mic: fallback"
    property bool pendingSinkRefresh: false
    property bool pendingMicRefresh: false
    property var sinkActionQueue: []
    property var micActionQueue: []

    function updateSpectrum(): void {
        const base = available && !muted ? Math.max(0.08, Math.min(1, volume)) : 0.05;
        const next = [];
        for (let i = 0; i < 18; i++) {
            const wave = Math.abs(Math.sin(spectrumPhase + i * 0.72));
            const pulse = Math.abs(Math.cos(spectrumPhase * 0.7 + i * 0.31));
            next.push(Math.min(1, base * (0.25 + wave * 0.55 + pulse * 0.2)));
        }
        spectrum = next;
        spectrumPhase += 0.42;
    }

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

    function updateMic(output: string): void {
        const match = output.match(/Volume:\s+([0-9.]+)(\s+\[MUTED\])?/);
        if (!match) {
            micAvailable = false;
            micText = "--%";
            micStatusLine = "mic: parse fallback";
            return;
        }

        micVolume = Math.max(0, Math.min(1.5, Number(match[1])));
        micMuted = match[2] !== undefined;
        micAvailable = true;
        micText = micMuted ? "MUTED" : Math.round(micVolume * 100) + "%";
        micStatusLine = micMuted ? "mic: source muted" : "mic: source online";
    }

    function refresh(): void {
        refreshSink();
        refreshMic();
    }

    function refreshSink(): void {
        pendingSinkRefresh = true;
        if (readProcess.running) {
            return;
        }
        pendingSinkRefresh = false;
        readProcess.running = true;
    }

    function refreshMic(): void {
        pendingMicRefresh = true;
        if (micReadProcess.running) {
            return;
        }
        pendingMicRefresh = false;
        micReadProcess.running = true;
    }

    function runNextSinkAction(): void {
        if (actionProcess.running || sinkActionQueue.length === 0)
            return;

        const next = sinkActionQueue[0];
        sinkActionQueue = sinkActionQueue.slice(1);
        actionProcess.command = next;
        actionProcess.running = true;
    }

    function queueSinkAction(command: var): void {
        sinkActionQueue = sinkActionQueue.concat([command]);
        runNextSinkAction();
    }

    function runNextMicAction(): void {
        if (micActionProcess.running || micActionQueue.length === 0)
            return;

        const next = micActionQueue[0];
        micActionQueue = micActionQueue.slice(1);
        micActionProcess.command = next;
        micActionProcess.running = true;
    }

    function queueMicAction(command: var): void {
        micActionQueue = micActionQueue.concat([command]);
        runNextMicAction();
    }

    function toggleMute(): void {
        queueSinkAction(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
    }

    function changeVolume(delta: real): void {
        const next = Math.max(0, Math.min(1.5, volume + delta));
        queueSinkAction(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", next.toFixed(2)]);
    }

    function toggleMicMute(): void {
        queueMicAction(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]);
    }

    function changeMicVolume(delta: real): void {
        const next = Math.max(0, Math.min(1.5, micVolume + delta));
        queueMicAction(["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", next.toFixed(2)]);
    }

    Component.onCompleted: {
        if (SettingsService.liveDataEnabled) {
            refresh();
            poller.start();
            spectrumTimer.start();
        }
    }

    property Timer poller: Timer {
        interval: 5000
        repeat: true
        onTriggered: root.refresh()
    }

    property Timer spectrumTimer: Timer {
        interval: 180
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateSpectrum()
    }

    Connections {
        target: SettingsService
        function onLiveDataEnabledChanged(): void {
            if (SettingsService.liveDataEnabled) {
                root.refresh();
                root.poller.start();
                root.spectrumTimer.start();
            } else {
                root.poller.stop();
                root.spectrumTimer.stop();
                root.pendingSinkRefresh = false;
                root.pendingMicRefresh = false;
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
            if (root.pendingSinkRefresh) {
                root.pendingSinkRefresh = false;
                root.readProcess.running = true;
            }
        }
    }

    property Process actionProcess: Process {
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        onExited: {
            root.refreshSink();
            root.runNextSinkAction();
        }
    }

    property Process micReadProcess: Process {
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        stdout: StdioCollector {
            onStreamFinished: root.updateMic(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.micAvailable = false;
                root.micText = "--%";
                root.micStatusLine = "mic: wpctl fallback";
            }
            if (root.pendingMicRefresh) {
                root.pendingMicRefresh = false;
                root.micReadProcess.running = true;
            }
        }
    }

    property Process micActionProcess: Process {
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        onExited: {
            root.refreshMic();
            root.runNextMicAction();
        }
    }
}
