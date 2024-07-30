import QtQuick
import QtPositioning
import QtLocation

MapQuickItem{
    property var coor
    property string name
    sourceItem: Text {
        text: name
        color:"#242424"
        font.bold: true
        styleColor: "#ECECEC"
        style: Text.Outline
    }
    coordinate: coor
    opacity: 1.0
    anchorPoint: Qt.point(0,-5)
    visible: true
}

