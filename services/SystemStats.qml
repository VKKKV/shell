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
    property var cpuRows: [["C00", "12%", 0.12, false], ["C06", "41%", 0.41, false], ["C01", "08%", 0.08, false], ["C07", "37%", 0.37, false], ["C02", "22%", 0.22, false], ["C08", "19%", 0.19, false], ["C03", "16%", 0.16, false], ["C09", "55%", 0.55, true], ["C04", "31%", 0.31, false], ["C10", "28%", 0.28, false], ["C05", "44%", 0.44, false], ["C11", "33%", 0.33, false]]
    property var cpuHistory: [0.32, 0.36, 0.44, 0.28, 0.58, 0.67, 0.42, 0.5, 0.74, 0.62, 0.46, 0.7, 0.55, 0.38, 0.48, 0.8, 0.52, 0.34]
    property var networkRows: [["DOWN", "924.4 KiB/s", 0.76, true], ["UP", "88.1 KiB/s", 0.24, false], ["LINK", "SECURE", -1, true]]
    property var networkHistory: [0.18, 0.42, 0.3, 0.74, 0.52, 0.64, 0.21, 0.82, 0.36, 0.57, 0.7, 0.25]
    property var filesystemRows: [["/", "72%", 0.72, false], ["/home", "64%", 0.64, false], ["/data", "41%", 0.41, false]]
    property string statusLine: "stats: fallback values active"
    property var logLines: ["stats: initializing collectors"]
    property var previousCpu: ({})
    property real previousNetworkRx: 0
    property real previousNetworkTx: 0
    property real previousNetworkTime: 0
    property string memoryStatus: "memory: initializing"
    property string filesystemStatus: "filesystem: initializing"
    property string cpuStatus: "cpu: initializing"
    property string networkStatus: "network: initializing"

    function formatGiB(bytes: real): string {
        return (bytes / 1073741824).toFixed(1) + "G";
    }

    function formatRate(bytesPerSecond: real): string {
        if (bytesPerSecond >= 1048576)
            return (bytesPerSecond / 1048576).toFixed(1) + " MiB/s";
        return (bytesPerSecond / 1024).toFixed(1) + " KiB/s";
    }

    function pushHistory(history: var, value: real, maxLength: int): var {
        const next = history.slice();
        next.push(Math.max(0, Math.min(1, value)));
        while (next.length > maxLength)
            next.shift();
        return next;
    }

    function log(message: string): void {
        const next = root.logLines.slice();
        next.push(message);
        while (next.length > 4)
            next.shift();
        root.logLines = next;
        root.statusLine = message;
        ServiceLogService.push("stats", message.indexOf("fallback") >= 0 ? "warn" : "info", message);
    }

    function updateStatus(): void {
        root.statusLine = memoryStatus + " // " + filesystemStatus + " // " + cpuStatus + " // " + networkStatus;
    }

    function updateMemory(output: string): void {
        const lines = output.trim().split("\n");
        let foundMemory = false;
        for (const line of lines) {
            const parts = line.trim().split(/\s+/);
            if (parts.length < 3)
                continue;

            if (parts[0] === "Mem:") {
                const total = Number(parts[1]);
                const used = Number(parts[2]);
                root.ramProgress = total > 0 ? used / total : 0;
                root.ramText = `${formatGiB(used)} ${(root.ramProgress * 100).toFixed(1)}%`;
                foundMemory = total > 0;
            } else if (parts[0] === "Swap:") {
                const total = Number(parts[1]);
                const used = Number(parts[2]);
                root.swapProgress = total > 0 ? used / total : 0;
                root.swapText = total > 0 ? `${formatGiB(used)} ${(root.swapProgress * 100).toFixed(1)}%` : "0.0G 0.0%";
            }
        }
        memoryStatus = foundMemory ? "memory: online" : "memory: fallback";
        log(memoryStatus);
        updateStatus();
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
        filesystemStatus = rows.length > 0 ? `filesystem: online (${rows.length})` : "filesystem: fallback";
        log(filesystemStatus);
        updateStatus();
    }

    function updateCpu(output: string): void {
        const rows = [];
        let aggregate = 0;
        let count = 0;
        const nextPrevious = {};
        const lines = output.trim().split("\n");
        for (const line of lines) {
            const parts = line.trim().split(/\s+/);
            if (!parts[0].match(/^cpu\d+$/))
                continue;

            const name = parts[0].replace("cpu", "C").padEnd(3, "0");
            const values = parts.slice(1).map(Number);
            const idle = values[3] + (values[4] || 0);
            const total = values.reduce((sum, value) => sum + value, 0);
            const previous = root.previousCpu[parts[0]];
            let progress = 0;
            if (previous) {
                const totalDiff = total - previous.total;
                const idleDiff = idle - previous.idle;
                progress = totalDiff > 0 ? 1 - idleDiff / totalDiff : 0;
            }
            nextPrevious[parts[0]] = {
                total,
                idle
            };

            if (count < 12) {
                rows.push([name, `${Math.round(progress * 100)}%`, progress, progress > 0.75]);
                aggregate += progress;
                count++;
            }
        }

        root.previousCpu = nextPrevious;
        if (rows.length > 0) {
            root.cpuRows = rows;
            root.cpuHistory = pushHistory(root.cpuHistory, aggregate / rows.length, 18);
            cpuStatus = `cpu: online (${rows.length})`;
            log(cpuStatus);
        } else {
            cpuStatus = "cpu: fallback";
            log(cpuStatus);
        }
        updateStatus();
    }

    function updateNetwork(output: string): void {
        let rx = 0;
        let tx = 0;
        const lines = output.trim().split("\n").slice(2);
        for (const line of lines) {
            const parts = line.trim().split(/[:\s]+/);
            const iface = parts[0];
            if (!iface || iface === "lo")
                continue;

            rx += Number(parts[1]) || 0;
            tx += Number(parts[9]) || 0;
        }

        const now = Date.now();
        if (root.previousNetworkTime > 0) {
            const seconds = Math.max(1, (now - root.previousNetworkTime) / 1000);
            const downRate = Math.max(0, (rx - root.previousNetworkRx) / seconds);
            const upRate = Math.max(0, (tx - root.previousNetworkTx) / seconds);
            const scale = Math.max(1048576, downRate, upRate);
            root.networkRows = [["DOWN", formatRate(downRate), Math.min(1, downRate / scale), true], ["UP", formatRate(upRate), Math.min(1, upRate / scale), false], ["LINK", "SECURE", -1, true]];
            root.networkHistory = pushHistory(root.networkHistory, downRate / scale, 12);
            networkStatus = "network: online";
            log(networkStatus);
            updateStatus();
        }

        root.previousNetworkRx = rx;
        root.previousNetworkTx = tx;
        root.previousNetworkTime = now;
    }

    property Process memoryProcess: Process {
        command: ["free", "-b"]
        stdout: StdioCollector {
            onStreamFinished: root.updateMemory(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.memoryStatus = "memory: command fallback";
                root.log(root.memoryStatus);
                root.updateStatus();
            }
        }
    }

    property Process filesystemProcess: Process {
        command: ["sh", "-c", "set -- / /home /data; targets=''; for mount in \"$@\"; do [ -e \"$mount\" ] && targets=\"$targets '$mount'\"; done; if [ -n \"$targets\" ]; then eval df -B1 $targets; else df -B1 /; fi"]
        stdout: StdioCollector {
            onStreamFinished: root.updateFilesystem(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.filesystemStatus = "filesystem: command fallback";
                root.filesystemRows = [["/", "UNKNOWN", -1, false], ["/home", "SKIPPED", -1, false], ["/data", "MISSING", -1, false]];
                root.log(root.filesystemStatus);
                root.updateStatus();
            }
        }
    }

    property Process cpuProcess: Process {
        command: ["cat", "/proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: root.updateCpu(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.cpuStatus = "cpu: command fallback";
                root.log(root.cpuStatus);
                root.updateStatus();
            }
        }
    }

    property Process networkProcess: Process {
        command: ["cat", "/proc/net/dev"]
        stdout: StdioCollector {
            onStreamFinished: root.updateNetwork(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.networkStatus = "network: command fallback";
                root.networkRows = [["DOWN", "0.0 KiB/s", 0, false], ["UP", "0.0 KiB/s", 0, false], ["LINK", "FALLBACK", -1, false]];
                root.log(root.networkStatus);
                root.updateStatus();
            }
        }
    }

    property Timer poller: Timer {
        interval: SettingsService.updateIntervalMs
        repeat: true
        running: SettingsService.liveDataEnabled
        triggeredOnStart: true
        onTriggered: {
            root.memoryProcess.running = true;
            root.filesystemProcess.running = true;
            root.cpuProcess.running = true;
            root.networkProcess.running = true;
        }
    }

    Connections {
        target: SettingsService
        function onLiveDataEnabledChanged(): void {
            if (SettingsService.liveDataEnabled)
                root.poller.restart();
        }
        function onUpdateIntervalMsChanged(): void {
            if (SettingsService.liveDataEnabled)
                root.poller.restart();
        }
    }
}
