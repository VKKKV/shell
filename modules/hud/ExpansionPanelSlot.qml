import "../../theme"
import QtQuick

Item {
    id: root

    required property bool active
    required property real originX
    required property real originY
    required property real targetX
    required property real targetY
    default property alias content: contentHost.data

    visible: active
    x: active ? targetX : originX - width / 2
    y: active ? targetY : originY - height / 2
    scale: active ? 1 : Theme.motionCollapsedScale
    opacity: active ? 1 : 0
    transformOrigin: Item.Center

    Behavior on x {
        NumberAnimation { duration: Theme.motionDeployMs; easing.type: Easing.OutCubic }
    }

    Behavior on y {
        NumberAnimation { duration: Theme.motionDeployMs; easing.type: Easing.OutCubic }
    }

    Behavior on scale {
        NumberAnimation { duration: Theme.motionDeployMs; easing.type: Easing.OutBack }
    }

    Behavior on opacity {
        NumberAnimation { duration: Theme.motionFadeMs; easing.type: Easing.OutCubic }
    }

    Item {
        id: contentHost

        anchors.fill: parent
    }
}
