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
        const value = text.trim();
        if (value.length === 0)
            return;
        if (history.length > 0 && history[0].text === value)
            return;

        const next = history.filter(entry => entry.text !== value);
        next.unshift({
            text: value,
            preview: compact(value),
            time: Qt.formatDateTime(new Date(), "hh:mm:ss")
        });
        history = next.slice(0, 8);
        statusLine = "clipboard: " + history.length + " entries";
    }

    function copy(text: string): void {
        pendingText = text;
        copyProcess.running = true;
    }

    function clear(): void {
        history = [];
        statusLine = "clipboard: history cleared";
    }

    function refresh(): void {
        pasteProcess.running = true;
    }

    Component.onCompleted: refresh()

    property Timer poller: Timer {
        interval: 3000
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
        command: ["sh", "-c", "printf %s \"$1\" | wl-copy", "void-shell-clipboard", root.pendingText]
        onExited: (exitCode) => {
            root.statusLine = exitCode === 0 ? "clipboard: copied entry" : "clipboard: wl-copy fallback";
        }
    }
}
