pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var rows: [["LINK", "SCANNING", -1, false]]
    property var activeConnections: []
    property string primaryName: "UNKNOWN"
    property string primaryType: "UNKNOWN"
    property string vpnStatus: "OFFLINE"
    property string bluetoothStatus: "UNKNOWN"
    property var wifiNetworks: []
    property string wifiStatus: "SCANNING"
    property string actionStatusLine: "network actions: standby"
    property string pendingWifiSsid: ""
    property string pendingActionLabel: ""
    property var actionQueue: []
    property string statusLine: "network detail: initializing"

    function runNextAction(): void {
        if (actionProcess.running || actionQueue.length === 0)
            return;

        const next = actionQueue[0];
        actionQueue = actionQueue.slice(1);
        pendingActionLabel = next.label;
        actionProcess.command = next.command;
        actionProcess.running = true;
        actionStatusLine = next.status;
    }

    function queueAction(command: var, label: string, status: string): void {
        actionQueue = actionQueue.concat([{ command, label, status }]);
        runNextAction();
    }

    function refreshConnection(name: string): void {
        queueAction(["nmcli", "connection", "up", name], name, "network actions: reconnect " + name);
    }

    function deactivateConnection(name: string): void {
        queueAction(["nmcli", "connection", "down", name], name, "network actions: down " + name);
    }

    function connectWifi(ssid: string): void {
        if (ssid.length === 0 || ssid === "HIDDEN") {
            actionStatusLine = "network actions: hidden SSID skipped";
            return;
        }

        pendingWifiSsid = ssid;
        wifiConnectProcess.command = ["nmcli", "device", "wifi", "connect", ssid];
        wifiConnectProcess.running = true;
        actionStatusLine = "network actions: wifi connect " + ssid;
    }

    function rescanWifi(): void {
        wifiRescanProcess.running = true;
        actionStatusLine = "network actions: wifi rescan";
    }

    function toggleBluetoothPower(): void {
        const nextPower = bluetoothStatus === "POWERED" ? "off" : "on";
        queueAction(["bluetoothctl", "power", nextPower], "bluetooth " + nextPower, "network actions: bluetooth " + nextPower);
    }

    function splitNmcliFields(line: string): var {
        const fields = [];
        let current = "";
        let escaped = false;
        for (const char of line) {
            if (escaped) {
                current += char;
                escaped = false;
            } else if (char === "\\") {
                escaped = true;
            } else if (char === ":") {
                fields.push(current);
                current = "";
            } else {
                current += char;
            }
        }
        if (escaped)
            current += "\\";
        fields.push(current);
        return fields;
    }

    function updateNetwork(output: string): void {
        const next = [];
        const rowsNext = [];
        let primary = null;
        let vpn = false;

        for (const line of output.trim().split("\n")) {
            if (line.length === 0)
                continue;

            const parts = splitNmcliFields(line);
            const name = parts[0] || "UNKNOWN";
            const type = parts[1] || "unknown";
            const device = parts[2] || "";
            if (type === "loopback" || type === "bridge")
                continue;

            const entry = {
                name,
                type,
                device
            };
            next.push(entry);
            if (!primary && type !== "tun" && type !== "vpn")
                primary = entry;
            if (type === "tun" || type === "vpn" || name.toLowerCase().indexOf("vpn") >= 0 || name.toLowerCase().indexOf("clash") >= 0)
                vpn = true;
        }

        activeConnections = next;
        primaryName = primary ? primary.name : (next[0]?.name || "DISCONNECTED");
        primaryType = primary ? primary.type.toUpperCase() : (next[0]?.type?.toUpperCase() || "NONE");
        vpnStatus = vpn ? "ACTIVE" : "OFFLINE";
        rowsNext.push(["PRIMARY", primaryName, -1, primary !== null]);
        rowsNext.push(["TYPE", primaryType, -1, primary !== null]);
        rowsNext.push(["VPN", vpnStatus, -1, vpn]);
        rowsNext.push(["ACTIVE", next.length.toString(), Math.min(1, next.length / 6), next.length > 0]);
        rowsNext.push(["BT", bluetoothStatus, -1, bluetoothStatus === "POWERED"]);
        rows = rowsNext;
        statusLine = "network detail: " + next.length + " active links";
    }

    function updateBluetooth(output: string): void {
        const powered = output.indexOf("Powered: yes") >= 0;
        const missing = output.trim().length === 0 || output.indexOf("No default controller") >= 0;
        bluetoothStatus = missing ? "OFFLINE" : (powered ? "POWERED" : "DISABLED");
    }

    function updateWifi(output: string): void {
        const seen = {};
        const next = [];
        for (const line of output.trim().split("\n")) {
            if (line.length === 0)
                continue;

            const parts = splitNmcliFields(line);
            const active = parts[0] === "yes";
            const ssid = parts[1] || "HIDDEN";
            const signal = Number(parts[2] || 0);
            const security = parts.slice(3).join(":") || "OPEN";
            if (seen[ssid])
                continue;
            seen[ssid] = true;
            next.push({
                ssid,
                signal,
                security,
                active
            });
        }

        next.sort((a, b) => b.signal - a.signal);
        wifiNetworks = next.slice(0, 5);
        wifiStatus = next.length > 0 ? next.length + " AP" : "NO AP";
    }

    function refresh(): void {
        networkProcess.running = true;
        bluetoothProcess.running = true;
        wifiProcess.running = true;
    }

    Component.onCompleted: startupPoll.start()

    property Timer startupPoll: Timer {
        interval: PollingSchedule.startupDelay(5)
        repeat: false
        running: SettingsService.liveDataEnabled
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
        function onLiveDataEnabledChanged(): void {
            if (SettingsService.liveDataEnabled) {
                root.refresh();
                root.poller.restart();
            } else {
                root.startupPoll.stop();
                root.poller.stop();
            }
        }
        function onUpdateIntervalMsChanged(): void {
            if (SettingsService.liveDataEnabled)
                root.poller.restart();
        }
    }

    property Process networkProcess: Process {
        command: ["nmcli", "-t", "-f", "NAME,TYPE,DEVICE", "connection", "show", "--active"]
        stdout: StdioCollector {
            onStreamFinished: root.updateNetwork(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.rows = [["LINK", "NMCLI FALLBACK", -1, false]];
                root.statusLine = "network detail: nmcli fallback";
            }
        }
    }

    property Process bluetoothProcess: Process {
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector {
            onStreamFinished: root.updateBluetooth(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0)
                root.bluetoothStatus = "OFFLINE";
        }
    }

    property Process wifiProcess: Process {
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: root.updateWifi(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.wifiNetworks = [];
                root.wifiStatus = "WIFI FALLBACK";
            }
        }
    }

    property Process actionProcess: Process {
        command: ["true"]
        onExited: (exitCode) => {
            root.actionStatusLine = exitCode === 0 ? "network actions: ok " + root.pendingActionLabel : "network actions: action fallback " + root.pendingActionLabel;
            root.refresh();
            root.runNextAction();
        }
    }

    property Process wifiConnectProcess: Process {
        command: ["true"]
        onExited: (exitCode) => {
            root.actionStatusLine = exitCode === 0 ? "network actions: wifi ok " + root.pendingWifiSsid : "network actions: wifi password/manual required";
            root.refresh();
        }
    }

    property Process wifiRescanProcess: Process {
        command: ["nmcli", "device", "wifi", "rescan"]
        onExited: (exitCode) => {
            root.actionStatusLine = exitCode === 0 ? "network actions: rescan ok" : "network actions: rescan fallback";
            root.refresh();
        }
    }

}
