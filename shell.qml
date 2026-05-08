//@ pragma UseQApplication

import QtQuick
import Quickshell
import "modules/hud"
import "services"

ShellRoot {
    id: root

    settings.watchFiles: true

    Loader {
        active: SettingsService.backgroundMode === "nixie"
        sourceComponent: Component { NixieBackgroundWindow {} }
    }

    HudWindow {
    }

    HudExclusionZone {
        edge: "top"
    }

    HudExclusionZone {
        edge: "bottom"
    }

    HudExclusionZone {
        edge: "left"
    }

    HudExclusionZone {
        edge: "right"
    }

}
