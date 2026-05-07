pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var wallpapers: []
    property string selectedPath: ""
    property string dominantColor: "#8a8a8a"
    property string suggestedProfile: "gray"
    property string statusLine: "wallpaper: initializing"
    property string applyStatusLine: "wallpaper apply: standby"

    function updateList(output: string): void {
        const next = [];
        for (const line of output.trim().split("\n")) {
            const path = line.trim();
            if (path.length === 0)
                continue;

            const parts = path.split("/");
            next.push({
                path,
                name: parts[parts.length - 1]
            });
        }

        wallpapers = next.slice(0, 18);
        if (selectedPath.length === 0 && wallpapers.length > 0)
            selectedPath = wallpapers[0].path;
        statusLine = wallpapers.length > 0 ? "wallpaper: " + wallpapers.length + " local images" : "wallpaper: no local images";
    }

    function select(path: string): void {
        selectedPath = path;
        sampleDebounce.restart();
    }

    function applySelected(): void {
        if (selectedPath.length === 0) {
            applyStatusLine = "wallpaper apply: no selection";
            return;
        }

        applyProcess.running = true;
        applyStatusLine = "wallpaper apply: dispatch";
    }

    function updateColor(output: string): void {
        const color = output.trim();
        if (/^#[0-9a-fA-F]{6}$/.test(color)) {
            dominantColor = color;
            const red = parseInt(color.slice(1, 3), 16);
            const green = parseInt(color.slice(3, 5), 16);
            const blue = parseInt(color.slice(5, 7), 16);
            suggestedProfile = Math.abs(red - green) < 24 && Math.abs(green - blue) < 24 ? "gray" : (blue > red && blue > green ? "blue" : (green > red ? "green" : (red > green + blue ? "red" : "amber")));
            applyStatusLine = "wallpaper color: " + color;
        } else {
            dominantColor = "#8a8a8a";
            suggestedProfile = "gray";
            applyStatusLine = "wallpaper color: sample fallback";
        }
    }

    function applySuggestedProfile(): void {
        SettingsService.accentColor = dominantColor;
        SettingsService.themeProfile = suggestedProfile;
        applyStatusLine = "wallpaper color: " + dominantColor + " // " + suggestedProfile;
    }

    function refresh(): void {
        listProcess.running = true;
    }

    Component.onCompleted: refresh()

    property Timer sampleDebounce: Timer {
        interval: 180
        repeat: false
        onTriggered: {
            if (root.sampleProcess.running) {
                restart();
                return;
            }
            root.sampleProcess.running = true;
        }
    }

    property Process listProcess: Process {
        command: ["sh", "-c", "for dir in \"$HOME/Pictures\" \"$HOME/Pictures/Wallpapers\" \"$HOME/.local/share/wallpapers\" /usr/share/backgrounds; do [ -d \"$dir\" ] || continue; find \"$dir\" -maxdepth 2 -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \\); done 2>/dev/null | sort -u"]
        stdout: StdioCollector {
            onStreamFinished: root.updateList(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0)
                root.statusLine = "wallpaper: scan fallback";
        }
    }

    property Process applyProcess: Process {
        command: ["sh", "-c", "if command -v swww >/dev/null 2>&1; then swww img \"$1\"; elif command -v hyprctl >/dev/null 2>&1 && command -v hyprpaper >/dev/null 2>&1; then hyprctl hyprpaper preload \"$1\"; hyprctl hyprpaper wallpaper \",\"$1\"; else exit 127; fi", "void-shell-wallpaper", root.selectedPath]
        onExited: (exitCode) => {
            root.applyStatusLine = exitCode === 0 ? "wallpaper apply: ok" : "wallpaper apply: swww/hyprpaper fallback";
        }
    }

    property Process sampleProcess: Process {
        command: ["sh", "-c", "if command -v magick >/dev/null 2>&1; then magick \"$1\" -resize 1x1! -format '%[hex:p{0,0}]' info: | sed 's/^/#/'; elif command -v convert >/dev/null 2>&1; then convert \"$1\" -resize 1x1! -format '%[hex:p{0,0}]' info: | sed 's/^/#/'; else echo '#8a8a8a'; fi", "void-shell-wallpaper", root.selectedPath]
        stdout: StdioCollector {
            onStreamFinished: root.updateColor(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0)
                root.applyStatusLine = "wallpaper color: tool fallback";
        }
    }
}
