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
    property string statusLine: "network detail: initializing"

    function updateNetwork(output: string): void {
        const next = [];
        const rowsNext = [];
        let primary = null;
        let vpn = false;

        for (const line of output.trim().split("\n")) {
            if (line.length === 0)
                continue;

            const parts = line.split(":");
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

    function refresh(): void {
        networkProcess.running = true;
        bluetoothProcess.running = true;
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
}
