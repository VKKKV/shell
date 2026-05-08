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
    property var lyricLines: ["lyrics: no active media"]
    property string lyricStatusLine: "lyrics: standby"

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
        lyricsProcess.running = true;
    }

    function updateLyrics(output: string): void {
        const next = [];
        for (const line of output.trim().split("\n")) {
            const clean = line.replace(/^\[[^\]]*\]/, "").trim();
            if (clean.length > 0)
                next.push(compact(clean, 58));
        }

        lyricLines = next.length > 0 ? next.slice(0, 5) : ["lyrics: local file not indexed", "place .lrc/.txt under ~/Music/Lyrics", "format: Artist - Title.lrc"];
        lyricStatusLine = next.length > 0 ? "lyrics: local file" : "lyrics: local fallback";
    }

    function refresh(): void {
        readProcess.running = true;
    }

    function startPollingIfReady(): void {
        if (SettingsService.loading || !SettingsService.liveDataEnabled)
            return;

        startupPoll.start();
    }

    function stopPolling(): void {
        startupPoll.stop();
        poller.stop();
    }

    function control(action: string): void {
        if (action !== "play-pause" && action !== "next" && action !== "previous")
            return;
        actionProcess.command = ["playerctl", action];
        actionProcess.running = true;
    }

    Component.onCompleted: startPollingIfReady()

    property Timer startupPoll: Timer {
        interval: PollingSchedule.startupDelay(3)
        repeat: false
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
        function onLoadingChanged(): void {
            if (SettingsService.loading)
                root.stopPolling();
            else
                root.startPollingIfReady();
        }
        function onLiveDataEnabledChanged(): void {
            if (SettingsService.liveDataEnabled) {
                if (!SettingsService.loading) {
                    root.refresh();
                    root.poller.restart();
                }
            } else {
                root.stopPolling();
            }
        }
        function onUpdateIntervalMsChanged(): void {
            if (!SettingsService.loading && SettingsService.liveDataEnabled)
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

    property Process lyricsProcess: Process {
        command: ["sh", "-c", "artist=$(printf '%s' \"$1\" | tr '/:' '__'); title=$(printf '%s' \"$2\" | tr '/:' '__'); for dir in \"$HOME/Music/Lyrics\" \"$HOME/.local/share/lyrics\"; do for ext in lrc txt; do file=\"$dir/$artist - $title.$ext\"; [ -f \"$file\" ] && { sed -n '1,12p' \"$file\"; exit 0; }; file=\"$dir/$title.$ext\"; [ -f \"$file\" ] && { sed -n '1,12p' \"$file\"; exit 0; }; done; done", "void-shell-lyrics", root.artist, root.title]
        stdout: StdioCollector {
            onStreamFinished: root.updateLyrics(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0)
                root.lyricStatusLine = "lyrics: local fallback";
        }
    }
}
