import "../theme"
import QtQuick

Text {
    property bool accent: false
    property bool dim: false
    property int size: Theme.fontSmall

    color: accent ? Theme.line : (dim ? Theme.textDim : Theme.text)
    elide: Text.ElideRight
    font.family: Theme.fontFamily
    font.pixelSize: size
    font.bold: accent
    font.letterSpacing: accent ? 1.1 : 0
}
