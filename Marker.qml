import QtQuick
import QtPositioning
import QtLocation

MapQuickItem{
    property var coor
    sourceItem: Image {
        id: image
        source:"qrc:/Image/mylocation.png";
        sourceSize.width: 35
        sourceSize.height: 35
        fillMode: Image.PreserveAspectFit
    }
    coordinate: coor
    opacity: 1.0
    anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height)
    visible: true
}
