pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string condition: "UNKNOWN"
    property string temp: "--"
    property string humidity: "--"
    property string wind: "--"
    property bool available: false
    property string displayText: "WEATHER // NO DATA"
    property string statusLine: "weather: initializing"

    function updateWeather(output: string): void {
        const parts = output.trim().split("|");
        if (parts.length < 3) {
            available = false;
            displayText = "WEATHER // NO DATA";
            statusLine = "weather: parse fallback";
            return;
        }

        condition = parts[0] || "UNKNOWN";
        temp = parts[1] || "--";
        humidity = parts[2] || "--";
        wind = parts[3] || "--";
        available = true;
        displayText = "WEATHER // " + condition + " // " + temp;
        statusLine = "weather: " + condition + " " + temp;
    }

    function refresh(): void {
        fetchProcess.running = true;
    }

    function startPollingIfReady(): void {
        if (SettingsService.loading || !SettingsService.liveDataEnabled)
            return;

        poller.start();
    }

    function stopPolling(): void {
        poller.stop();
    }

    Component.onCompleted: startPollingIfReady()

    property Timer poller: Timer {
        interval: 300000
        repeat: true
        triggeredOnStart: true
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
                    root.poller.start();
                }
            } else {
                root.stopPolling();
            }
        }
    }

    property string location: Quickshell.env("WTTR_LOCATION") || ""
    readonly property string weatherUrl: "https://wttr.in/" + encodeURIComponent(location) + "?format=%C|%t|%h|%w"

    property Process fetchProcess: Process {
        command: ["curl", "-m", "6", "-s", root.weatherUrl]
        stdout: StdioCollector {
            onStreamFinished: root.updateWeather(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0 || !root.available) {
                root.available = false;
                root.displayText = "WEATHER // OFFLINE";
                root.statusLine = "weather: fetch fallback";
            }
        }
    }
}
