import QtQuick.Controls 2.15
import QtQuick 2.15
import QtLocation 6.7
import QtPositioning 6.0

Rectangle {
    id: root
    anchors.fill: parent
    color: "transparent"

    property var waypointStart : QtPositioning.coordinate(10.869553228865, 106.803020238876)
    signal closeMap

    Plugin{
        id: mapPlugin
        name: 'osm'
        PluginParameter
        {
            name: 'osm.mapping.highdpi_tiles'
            value: true
        }
    }

    Text{
        anchors{
            topMargin: 20
            leftMargin: 100
            right: parent.right
            left: parent.left
        }
        text: "Tìm kiếm trong bán kính 10km"
        opacity: 0.8
        z:1
        font.pointSize: 15
    }

    RoundButton{
        height: 45
        width: 45
        z:1
        anchors{
            topMargin: 20
            rightMargin: 20
            top: parent.top
            right: parent.right
        }
        icon.source: "https://www.iconsdb.com/icons/preview/black/x-mark-xxl.png"
        icon.height: height
        icon.width: width
        onClicked: closeMap();
    }

    PositionSource{
        id: src
        active: true
        // updateInterval :1000
        // onPositionChanged: {
        //     var test = src.position.coordinate;
        //     console.log(test);
        //     waypointStart = test;
        //     mapView.center = position.coordinate;
        // }
    }

    PlaceSearchModel{
        id: searchModel
        plugin: mapPlugin
        searchTerm: ""
        //searchTerm: "pharmacity"
        searchArea: QtPositioning.circle(waypointStart,10000)
        Component.onCompleted: update();
    }

    Map {
        id: mapView
        anchors.fill: parent
        plugin: mapPlugin
        zoomLevel: 14
        visible: true
        activeMapType: mapView.supportedMapTypes[mapView.supportedMapTypes.length - 1]
        PinchHandler
        {
            id: pinch
            target: null
            onActiveChanged: if (active) {
                mapView.startCentroid = mapView.toCoordinate(pinch.centroid.position, false)
            }
            onScaleChanged: (delta) => {
                mapView.zoomLevel += Math.log2(delta)
                mapView.alignCoordinateToPoint(mapView.startCentroid, pinch.centroid.position)
            }
            onRotationChanged: (delta) => {
                mapView.bearing -= delta
                mapView.alignCoordinateToPoint(mapView.startCentroid, pinch.centroid.position)
            }
            grabPermissions: PointerHandler.TakeOverForbidden
        }
        WheelHandler {
            id: wheel
            acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
                             ? PointerDevice.Mouse | PointerDevice.TouchPad
                             : PointerDevice.Mouse
            rotationScale: 1/120
            property: "zoomLevel"
        }
        DragHandler {
            id: drag
            target: null
            onTranslationChanged: (delta) => mapView.pan(-delta.x, -delta.y)
        }
        Shortcut {
            enabled: mapView.zoomLevel < mapView.maximumZoomLevel
            sequence: StandardKey.ZoomIn
            onActivated: mapView.zoomLevel = Math.round(mapView.zoomLevel + 1)
        }
        Shortcut {
            enabled: mapView.zoomLevel > mapView.minimumZoomLevel
            sequence: StandardKey.ZoomOut
            onActivated: mapView.zoomLevel = Math.round(mapView.zoomLevel - 1)
        }

        MapQuickItem
        {
            anchorPoint.x: sourceItem.width/2
            anchorPoint.y: sourceItem.height
            coordinate: waypointStart
            sourceItem: Image{
                id:marker
                source:"qrc:/Image/mylocation.png"
                sourceSize.width: 30
                sourceSize.height: 30
                fillMode: Image.PreserveAspectFit
            }
        }

        MapItemView{
            model: searchModel
            parent: mapView.map
            delegate: MapQuickItem{
                coordinate: place.location.coordinate
                anchorPoint.x: image.width*0.5
                anchorPoint.y: image.height
                sourceItem: Column{
                    Image{
                        id: image
                        source: "https://cdn3.iconfinder.com/data/icons/elasto-map-markers/26/00-MAP_map-marker-09-512.png"
                        sourceSize.width: 30
                        sourceSize.height: 30
                        fillMode: Image.PreserveAspectFit
                    }
                    Text{
                        text: title
                        font.bold: true
                    }
                }
            }
        }
    }

    function searchAddress(address){
        searchModel.searchTerm = address;
        searchModel.update();
        console.log("ĐÃ TÌM");
    }

    Component.onCompleted:{
        waypointStart = QtPositioning.coordinate(10.869553228865, 106.803020238876)
        mapView.center = waypointStart
    }

    // Connections {
    //     target: parent // Listen to the signal from photo.qml
    //     onMapSearch: function(searchText) {
    //         console.log("ĐÃ TÌM");
    //         searchAddress(searchText); // Perform the search with the search term
    //     }
    // }
}
