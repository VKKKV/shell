pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real latitude: 0
    property real longitude: 0
    property string city: "UNKNOWN"
    property string region: ""
    property string country: ""
    property string ip: ""
    property bool available: false
    property string source: "timezone"
    property string statusLine: "earth: geolocation initializing"
    readonly property string displayText: available ? city + (country.length > 0 ? ", " + country : "") : "LOCATION UNAVAILABLE"
    readonly property string coordinateText: available ? latitude.toFixed(3) + " / " + longitude.toFixed(3) : "-- / --"

    property string timezoneLabel: "UTC"
    readonly property var timezoneLocations: ({
        "CST": { lat: 31.2304, lon: 121.4737, city: "Shanghai", country: "China" },
        "HKT": { lat: 22.3193, lon: 114.1694, city: "Hong Kong", country: "China" },
        "JST": { lat: 35.6762, lon: 139.6503, city: "Tokyo", country: "Japan" },
        "KST": { lat: 37.5665, lon: 126.9780, city: "Seoul", country: "South Korea" },
        "SGT": { lat: 1.3521, lon: 103.8198, city: "Singapore", country: "Singapore" },
        "ICT": { lat: 13.7563, lon: 100.5018, city: "Bangkok", country: "Thailand" },
        "IST": { lat: 28.6139, lon: 77.2090, city: "Delhi", country: "India" },
        "GMT": { lat: 51.5072, lon: -0.1276, city: "London", country: "United Kingdom" },
        "BST": { lat: 51.5072, lon: -0.1276, city: "London", country: "United Kingdom" },
        "CET": { lat: 48.8566, lon: 2.3522, city: "Paris", country: "France" },
        "CEST": { lat: 48.8566, lon: 2.3522, city: "Paris", country: "France" },
        "MSK": { lat: 55.7558, lon: 37.6173, city: "Moscow", country: "Russia" },
        "EST": { lat: 40.7128, lon: -74.0060, city: "New York", country: "United States" },
        "EDT": { lat: 40.7128, lon: -74.0060, city: "New York", country: "United States" },
        "CDT": { lat: 41.8781, lon: -87.6298, city: "Chicago", country: "United States" },
        "MDT": { lat: 39.7392, lon: -104.9903, city: "Denver", country: "United States" },
        "PDT": { lat: 34.0522, lon: -118.2437, city: "Los Angeles", country: "United States" },
        "BRT": { lat: -23.5505, lon: -46.6333, city: "Sao Paulo", country: "Brazil" },
        "AEST": { lat: -33.8688, lon: 151.2093, city: "Sydney", country: "Australia" },
        "AEDT": { lat: -33.8688, lon: 151.2093, city: "Sydney", country: "Australia" },
        "UTC": { lat: 0, lon: 0, city: "Null Island", country: "UTC" }
    })

    function applyTimezoneLocation(): void {
        const tz = timezoneLabel.length > 0 ? timezoneLabel : "UTC";
        const location = timezoneLocations[tz] || timezoneLocations.UTC;
        latitude = location.lat;
        longitude = location.lon;
        city = location.city;
        root.region = "timezone " + tz;
        country = location.country;
        ip = "";
        available = true;
        source = timezoneLocations[tz] ? "timezone" : "timezone-fallback";
        statusLine = "earth: timezone location // " + tz;
    }

    function refresh(): void {
        if (!timezoneProcess.running)
            timezoneProcess.running = true;
        if (!SettingsService.liveDataEnabled) {
            applyTimezoneLocation();
            statusLine = "earth: live data disabled";
            return;
        }
        if (!SettingsService.networkGeolocationEnabled) {
            applyTimezoneLocation();
            return;
        }
        if (!fetchProcess.running)
            fetchProcess.running = true;
    }

    function updateLocation(output: string): void {
        try {
            const payload = JSON.parse(output || "{}");
            const lat = Number(payload.latitude ?? payload.lat);
            const lon = Number(payload.longitude ?? payload.lon);
            if (!Number.isFinite(lat) || !Number.isFinite(lon))
                throw new Error("missing coordinates");

            latitude = Math.max(-90, Math.min(90, lat));
            longitude = ((lon + 180) % 360 + 360) % 360 - 180;
            city = payload.city || "UNKNOWN";
            region = payload.region || payload.region_name || "";
            country = payload.country_name || payload.country || "";
            ip = payload.ip || "";
            available = true;
            source = "network-ip";
            statusLine = "earth: ip location locked";
        } catch (error) {
            applyTimezoneLocation();
            statusLine = "earth: ip parse fallback // timezone";
        }
    }

    Component.onCompleted: startupPoll.start()

    function updateTimezone(output: string): void {
        const value = output.trim();
        timezoneLabel = value.length > 0 ? value : "UTC";
        if (!SettingsService.networkGeolocationEnabled)
            applyTimezoneLocation();
    }

    Timer {
        id: startupPoll
        interval: PollingSchedule.startupDelay(9)
        repeat: false
        running: SettingsService.liveDataEnabled
        onTriggered: root.refresh()
    }

    Timer {
        interval: 1800000
        repeat: true
        running: SettingsService.liveDataEnabled
        onTriggered: root.refresh()
    }

    Connections {
        target: SettingsService
        function onLiveDataEnabledChanged(): void {
            root.refresh();
        }
        function onNetworkGeolocationEnabledChanged(): void {
            root.refresh();
        }
    }

    Process {
        id: fetchProcess
        command: ["curl", "-m", "5", "-s", "https://ipapi.co/json/"]
        stdout: StdioCollector {
            onStreamFinished: root.updateLocation(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0 || !root.available) {
                root.applyTimezoneLocation();
                root.statusLine = "earth: ip fetch fallback // timezone";
            }
        }
    }

    Process {
        id: timezoneProcess
        command: ["date", "+%Z"]
        stdout: StdioCollector {
            onStreamFinished: root.updateTimezone(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.timezoneLabel = "UTC";
                if (!SettingsService.networkGeolocationEnabled)
                    root.applyTimezoneLocation();
            }
        }
    }
}
