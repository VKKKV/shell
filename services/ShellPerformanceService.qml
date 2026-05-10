pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int shellPid: 0
    property real cpuProgress: 0
    property int memoryKiB: 0
    property int childCount: 0
    property int processCount: 0
    property int uptimeSeconds: 0
    property var rows: [["CPU", "INIT", 0, false], ["RSS", "WAIT", -1, false], ["CHILD", "0", 0, false], ["UP", "--", -1, false], ["HEALTH", "STANDBY", -1, false]]
    property var history: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    property string statusLine: "shell perf: initializing"
    property string healthLine: "NOMINAL"
    property bool available: false
    property real previousProcJiffies: 0
    property real previousSystemJiffies: 0
    property string lastFailure: ""

    function pushHistory(value: real): void {
        const next = root.history.slice();
        next.push(Math.max(0, Math.min(1, value)));
        while (next.length > 18)
            next.shift();
        root.history = next;
    }

    function formatMemory(kib: int): string {
        if (kib <= 0)
            return "UNKNOWN";
        if (kib >= 1048576)
            return (kib / 1048576).toFixed(1) + " GiB";
        return Math.round(kib / 1024) + " MiB";
    }

    function formatUptime(seconds: int): string {
        if (seconds <= 0)
            return "--";
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        if (hours > 0)
            return `${hours}h ${minutes}m`;
        return `${minutes}m ${Math.floor(seconds % 60)}s`;
    }

    function updateHealth(): void {
        const warning = ServiceLogService.events.find(entry => entry.level === "warn" || entry.level === "error");
        if (warning)
            root.healthLine = `${warning.level.toUpperCase()} ${warning.source}`;
        else
            root.healthLine = "NOMINAL";
        root.updateRows();
    }

    function updateRows(): void {
        if (!SettingsService.liveDataEnabled) {
            root.rows = [["CPU", "PAUSED", -1, false], ["RSS", "PAUSED", -1, false], ["CHILD", "PAUSED", -1, false], ["UP", "LIVE OFF", -1, false], ["HEALTH", root.healthLine, -1, false]];
            root.statusLine = "shell perf: paused";
            return;
        }

        if (!root.available) {
            root.rows = [["CPU", "FALLBACK", -1, false], ["RSS", "UNKNOWN", -1, false], ["CHILD", "UNKNOWN", -1, false], ["UP", root.lastFailure || "NO /PROC", -1, false], ["HEALTH", root.healthLine, -1, root.healthLine !== "NOMINAL"]];
            return;
        }

        root.rows = [["CPU", `${Math.round(root.cpuProgress * 100)}%`, root.cpuProgress, root.cpuProgress > 0.2], ["RSS", formatMemory(root.memoryKiB), Math.min(1, root.memoryKiB / 524288), root.memoryKiB > 262144], ["CHILD", `${root.childCount} direct`, Math.min(1, root.childCount / 6), root.childCount > 0], ["UP", formatUptime(root.uptimeSeconds), -1, false], ["HEALTH", root.healthLine, -1, root.healthLine === "NOMINAL"]];
        root.statusLine = `shell perf: ${root.processCount} proc // ${Math.round(root.cpuProgress * 100)}% cpu`;
    }

    function startPollingIfReady(): void {
        if (SettingsService.loading || !SettingsService.liveDataEnabled)
            return;

        if (root.shellPid <= 0)
            pidProcess.running = true;
        startupPoll.start();
    }

    function stopPolling(): void {
        startupPoll.stop();
        poller.stop();
        updateRows();
    }

    function refresh(): void {
        if (!SettingsService.liveDataEnabled)
            return;
        if (root.shellPid <= 0) {
            pidProcess.running = true;
            return;
        }
        sampleProcess.command = ["sh", "-c", sampleScript, "shell-perf", String(root.shellPid)];
        sampleProcess.running = true;
    }

    function parseKeyValue(output: string): var {
        const result = {};
        const lines = output.trim().split("\n");
        for (const line of lines) {
            const index = line.indexOf("=");
            if (index <= 0)
                continue;
            result[line.slice(0, index)] = line.slice(index + 1);
        }
        return result;
    }

    function updateSample(output: string): void {
        const sample = parseKeyValue(output);
        const procJiffies = Number(sample.procJiffies || 0);
        const systemJiffies = Number(sample.systemJiffies || 0);
        const rssKiB = Number(sample.rssKiB || 0);
        const children = Number(sample.childCount || 0);
        const processes = Number(sample.processCount || 0);
        const uptime = Number(sample.uptimeSeconds || 0);

        if (processes <= 0 || systemJiffies <= 0) {
            root.available = false;
            root.lastFailure = "PROC MISS";
            root.statusLine = "shell perf: /proc fallback";
            ServiceLogService.push("shell-perf", "warn", root.statusLine);
            root.updateRows();
            return;
        }

        let cpu = 0;
        if (root.previousSystemJiffies > 0 && root.previousProcJiffies > 0) {
            const procDelta = Math.max(0, procJiffies - root.previousProcJiffies);
            const systemDelta = Math.max(1, systemJiffies - root.previousSystemJiffies);
            cpu = Math.min(1, procDelta / systemDelta);
        }

        root.previousProcJiffies = procJiffies;
        root.previousSystemJiffies = systemJiffies;
        root.cpuProgress = cpu;
        root.memoryKiB = rssKiB;
        root.childCount = children;
        root.processCount = processes;
        root.uptimeSeconds = uptime;
        root.available = true;
        root.lastFailure = "";
        root.pushHistory(cpu);
        root.updateRows();
    }

    readonly property string sampleScript: "pid=\"$1\"\nread_proc() {\n  p=\"$1\"\n  stat=\"$(cat \"/proc/$p/stat\" 2>/dev/null)\" || return 1\n  rest=\"${stat##*) }\"\n  set -- $rest\n  proc_jiffies=$((proc_jiffies + ${12:-0} + ${13:-0}))\n  rss=$(awk '/^VmRSS:/ {print $2}' \"/proc/$p/status\" 2>/dev/null)\n  rss_kib=$((rss_kib + ${rss:-0}))\n  process_count=$((process_count + 1))\n}\nsystem_jiffies=$(awk '/^cpu / {sum=0; for (i=2; i<=NF; i++) sum += $i; print sum; exit}' /proc/stat 2>/dev/null)\nstart_ticks=$(awk '{print $22}' \"/proc/$pid/stat\" 2>/dev/null)\nuptime_ticks=$(awk -v start=\"${start_ticks:-0}\" '{printf \"%d\", ($1 * 100) - start}' /proc/uptime 2>/dev/null)\nproc_jiffies=0\nrss_kib=0\nchild_count=0\nprocess_count=0\nread_proc \"$pid\"\nfor statfile in /proc/[0-9]*/stat; do\n  stat=\"$(cat \"$statfile\" 2>/dev/null)\" || continue\n  child_pid=\"${stat%% *}\"\n  rest=\"${stat##*) }\"\n  set -- $rest\n  if [ \"${2:-}\" = \"$pid\" ]; then\n    child_count=$((child_count + 1))\n    read_proc \"$child_pid\"\n  fi\ndone\nprintf 'procJiffies=%s\\n' \"$proc_jiffies\"\nprintf 'systemJiffies=%s\\n' \"${system_jiffies:-0}\"\nprintf 'rssKiB=%s\\n' \"$rss_kib\"\nprintf 'childCount=%s\\n' \"$child_count\"\nprintf 'processCount=%s\\n' \"$process_count\"\nprintf 'uptimeSeconds=%s\\n' \"$(( ${uptime_ticks:-0} / 100 ))\""

    Component.onCompleted: startPollingIfReady()

    property Process pidProcess: Process {
        command: ["sh", "-c", "printf '%s' \"$PPID\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const pid = Number(text.trim());
                if (pid > 0) {
                    root.shellPid = pid;
                    root.refresh();
                } else {
                    root.available = false;
                    root.lastFailure = "PID MISS";
                    root.statusLine = "shell perf: pid fallback";
                    ServiceLogService.push("shell-perf", "warn", root.statusLine);
                    root.updateRows();
                }
            }
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.available = false;
                root.lastFailure = "PID CMD";
                root.statusLine = "shell perf: pid command fallback";
                ServiceLogService.push("shell-perf", "warn", root.statusLine);
                root.updateRows();
            }
        }
    }

    property Process sampleProcess: Process {
        stdout: StdioCollector {
            onStreamFinished: root.updateSample(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.available = false;
                root.lastFailure = "SAMPLE CMD";
                root.statusLine = "shell perf: sample command fallback";
                ServiceLogService.push("shell-perf", "warn", root.statusLine);
                root.updateRows();
            }
        }
    }

    property Timer startupPoll: Timer {
        interval: PollingSchedule.startupDelay(2)
        repeat: false
        onTriggered: {
            root.refresh();
            root.poller.start();
        }
    }

    property Timer poller: Timer {
        interval: Math.max(SettingsService.updateIntervalMs, 3000)
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

    Connections {
        target: ServiceLogService
        function onEventsChanged(): void {
            root.updateHealth();
        }
    }
}
