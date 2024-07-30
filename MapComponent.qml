import QtQuick
import QtQuick.Controls
import QtPositioning
import QtLocation

MapView {
    id: view

    map.center {
        latitude: 10.869783290998388
        longitude: 106.80261646844893
    }
    map.zoomLevel: 14
    map.onCopyrightLinkActivated: Qt.openUrlExternally(link)

    MapQuickItem {
        parent: view.map
        id: mePosition
        sourceItem: Rectangle { width: 14; height: 14; color: "#251ee4"; border.width: 2; border.color: "white"; smooth: true; radius: 7 }
        coordinate {
            latitude: 10.869783290998388
            longitude: 106.80261646844893
        }
        opacity:1.0
        anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
    }

    MapQuickItem {
        parent: view.map
        sourceItem: Text {
            text: "Bạn đang ở đây"
            color:"#242424"
            font.bold: true
            styleColor: "#ECECEC"
            style: Text.Outline
        }
        coordinate: mePosition.coordinate
        anchorPoint: Qt.point(-mePosition.sourceItem.width * 0.5,mePosition.sourceItem.height * 1.5)
    }

    // PositionSource{
    //     id: positionSource
    //     active: true

    //     onPositionChanged: {
    //         view.map.center = positionSource.position.coordinate
    //     }
    // }
}
