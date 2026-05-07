pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var history: []
    property string statusLine: "clipboard: initializing"
    property string pendingText: ""

    function compact(text: string): string {
        const clean = text.replace(/\s+/g, " ").trim();
        return clean.length > 72 ? clean.slice(0, 69) + "..." : clean;
    }

    function updateClipboard(text: string): void {
        if (text.trim().length === 0)
            return;
        if (history.length > 0 && history[0].text === text)
            return;

        const next = history.filter(entry => entry.text !== text);
        next.unshift({
            text: text,
            preview: compact(text),
            time: Qt.formatDateTime(new Date(), "hh:mm:ss")
        });
        history = next.slice(0, 8);
        statusLine = "clipboard: " + history.length + " entries";
    }

    function copy(text: string): void {
        pendingText = text;
        copyProcess.command = ["wl-copy", pendingText];
        copyProcess.running = true;
    }

    function clear(): void {
        history = [];
        statusLine = "clipboard: history cleared";
    }

    function refresh(): void {
        pasteProcess.running = true;
    }

    Component.onCompleted: startupPoll.start()

    property Timer startupPoll: Timer {
        interval: PollingSchedule.startupDelay(6)
        repeat: false
        running: SettingsService.liveDataEnabled
        onTriggered: {
            root.refresh();
            root.poller.start();
        }
    }

    property Timer poller: Timer {
        interval: 3000
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
    }

    property Process pasteProcess: Process {
        command: ["wl-paste", "--no-newline", "--type", "text"]
        stdout: StdioCollector {
            onStreamFinished: root.updateClipboard(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0)
                root.statusLine = "clipboard: wl-paste fallback";
        }
    }

    property Process copyProcess: Process {
        command: ["wl-copy", root.pendingText]
        onExited: (exitCode) => {
            root.statusLine = exitCode === 0 ? "clipboard: copied entry" : "clipboard: wl-copy fallback";
        }
    }
}
