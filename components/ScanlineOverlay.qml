import "../theme"
import QtQuick

Item {
    id: root

    property real lineOpacity: 0.08

    clip: true

    Repeater {
        model: Math.max(0, Math.ceil(Math.max(0, root.height) / 8))

        Rectangle {
            required property int index

            x: 0
            y: index * 8
            width: root.width
            height: 1
            color: Theme.line
            opacity: root.lineOpacity
        }

    }

}
