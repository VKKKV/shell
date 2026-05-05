//@ pragma UseQApplication

import Quickshell
import "modules/hud"

ShellRoot {
    id: root

    settings.watchFiles: true

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
