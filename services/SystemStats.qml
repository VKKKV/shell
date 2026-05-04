pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real ramProgress: 0.629
    property real swapProgress: 0.262
    property string ramText: "19.7G 62.9%"
    property string swapText: "2.1G 26.2%"
    property var filesystemRows: [["/", "72%", 0.72, false], ["/home", "64%", 0.64, false], ["/data", "41%", 0.41, false]]

    function formatGiB(bytes: real): string {
        return (bytes / 1073741824).toFixed(1) + "G";
    }

    function updateMemory(output: string): void {
        const lines = output.trim().split("\n");
        for (const line of lines) {
            const parts = line.trim().split(/\s+/);
            if (parts.length < 3)
                continue;

            if (parts[0] === "Mem:") {
                const total = Number(parts[1]);
                const used = Number(parts[2]);
                root.ramProgress = total > 0 ? used / total : 0;
                root.ramText = `${formatGiB(used)} ${(root.ramProgress * 100).toFixed(1)}%`;
            } else if (parts[0] === "Swap:") {
                const total = Number(parts[1]);
                const used = Number(parts[2]);
                root.swapProgress = total > 0 ? used / total : 0;
                root.swapText = `${formatGiB(used)} ${(root.swapProgress * 100).toFixed(1)}%`;
            }
        }
    }

    function updateFilesystem(output: string): void {
        const wanted = ["/", "/home", "/data"];
        const rows = [];
        const lines = output.trim().split("\n").slice(1);
        for (const mount of wanted) {
            const line = lines.find(entry => entry.trim().split(/\s+/)[5] === mount);
            if (!line)
                continue;

            const parts = line.trim().split(/\s+/);
            const size = Number(parts[1]);
            const used = Number(parts[2]);
            const progress = size > 0 ? used / size : 0;
            rows.push([mount, `${Math.round(progress * 100)}%`, progress, false]);
        }

        if (rows.length > 0)
            root.filesystemRows = rows;
    }

    property Process memoryProcess: Process {
        command: ["free", "-b"]
        stdout: StdioCollector {
            onStreamFinished: root.updateMemory(text)
        }
    }

    property Process filesystemProcess: Process {
        command: ["df", "-B1", "/", "/home", "/data"]
        stdout: StdioCollector {
            onStreamFinished: root.updateFilesystem(text)
        }
    }

    property Timer poller: Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            root.memoryProcess.running = true;
            root.filesystemProcess.running = true;
        }
    }
}
