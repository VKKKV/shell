pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root

    readonly property string standbyTitle: "HOVER HINT"
    readonly property string standbyDetail: "Hover a HUD control to inspect its action. Tooltip output is fixed to this tactical box."
    property string title: standbyTitle
    property string detail: standbyDetail
    property string source: "standby"
    property bool active: false

    function show(nextTitle: string, nextDetail: string, nextSource: string): void {
        title = nextTitle.length > 0 ? nextTitle : standbyTitle;
        detail = nextDetail.length > 0 ? nextDetail : standbyDetail;
        source = nextSource.length > 0 ? nextSource : "hud";
        active = true;
    }

    function clear(nextSource: string): void {
        if (nextSource.length > 0 && source !== nextSource)
            return;
        title = standbyTitle;
        detail = standbyDetail;
        source = "standby";
        active = false;
    }
}
