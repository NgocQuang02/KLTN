import QtQuick
import QtMultimedia
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtPositioning
import QtLocation
import "../database"

Rectangle {
    id : cameraUI

    width: 800
    height: 480
    color: "black"
    state: "PhotoCapture"

    //map property
    property var searchLocation: QtPositioning.coordinate(10.869783290998388, 106.80261646844893)
    property var searchRegion: QtPositioning.circle(searchLocation, 10000)
    property var component
    property var sprite
    property var component2
    property var sprite2

    // property string textSearch: ""
    property string platformScreen: ""
    property string lastCapturedImagePath: ""
    property bool isCameraUIVisible: true
    property int buttonsPanelLandscapeWidth: 328
    property int buttonsPanelPortraitHeight: 180

    signal initiatedSearch(string searchText)

    states: [
        State {
            name: "PhotoCapture"
            StateChangeScript {
                script: {
                    camera.start()
                }
            }
        },
        State {
            name: "PhotoPreview"
        },
        State {
            name: "WhiteScreen"
        }
    ]

    CaptureSession {
        id: captureSession
        camera: Camera {
            id: camera
        }
        imageCapture: ImageCapture {
            id: imageCapture
        }
        videoOutput: viewfinder
    }

    PhotoPreview {
        id : photoPreview
        anchors.fill : parent
        onClosed: cameraUI.state = "PhotoCapture"
        visible: (cameraUI.state === "PhotoPreview")
        focus: visible
        source: imageCapture.preview
        onPhotoClicked: function (searchText){
            // textSearch = searchText;
            cameraUI.state =  "WhiteScreen";
            console.log("Tìm kiếm: ",searchText);
            // whiteScreen.searchForText(searchText)
            cameraUI.initiatedSearch(searchText);
        }
    }

    VideoOutput {
        id: viewfinder
        visible: (cameraUI.state === "PhotoCapture")
        anchors.fill: parent
    }

    Item {
        id: controlLayout

        readonly property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"
        readonly property bool isLandscape: Screen.desktopAvailableWidth >= Screen.desktopAvailableHeight
        property int buttonsWidth: state === "MobilePortrait" ? Screen.desktopAvailableWidth / 3.4 : 114

        states: [
            State {
                name: "MobileLandscape"
                when: controlLayout.isMobile && controlLayout.isLandscape
            },
            State {
                name: "MobilePortrait"
                when: controlLayout.isMobile && !controlLayout.isLandscape
            },
            State {
                name: "Other"
                when: !controlLayout.isMobile
            }
        ]

        onStateChanged: {
            console.log("State: " + controlLayout.state)
        }
    }

    PhotoCaptureControls {
        id: stillControls
        state: controlLayout.state
        anchors.fill: parent
        buttonsWidth: controlLayout.buttonsWidth
        buttonsPanelPortraitHeight: cameraUI.buttonsPanelPortraitHeight
        buttonsPanelWidth: cameraUI.buttonsPanelLandscapeWidth
        captureSession: captureSession
        visible: cameraUI.state === "PhotoCapture"
        onPreviewSelected: cameraUI.state = "PhotoPreview"
        previewAvailable: imageCapture.preview.length !== 0
    }

    Rectangle
    {
        id: whiteScreen
        anchors.fill: parent
        visible: cameraUI.state === "WhiteScreen"

        Image
        {
            id: backgroundMap
            source: "qrc:/Image/loginl.jpg"
            opacity: 1
            sourceSize.width: parent.width
            sourceSize.height: parent.height
            fillMode: Image.PreserveAspectFit
        }

        Connections {
            target: cameraUI
            onInitiatedSearch: function(searchText) {placeSearchModel.searchForText(searchText)}
        }

        Timer {
            id: reSearch
            interval: 1000
            repeat: false
            onTriggered: {
                placeSearchModel.searchForText(placeSearchModel.searchTerm);
            }
        }

        Plugin {
            id: mapPlugin
            name: "osm"
        }

        PlaceSearchModel {
            id: placeSearchModel
            searchArea: searchRegion
            plugin: mapPlugin

            function searchForText(text) {
                searchTerm = text;
                categories = null;
                recommendationId = "";
                searchArea = searchRegion
                limit = -1;
                update();
            }

            onStatusChanged: {
                switch (status) {
                case PlaceSearchModel.Ready:
                    if (count > 0){
                        popupMap.showPlaces();
                        reSearch.stop();}
                    else {
                        popupMap.showMessage(qsTr("Search Place Error"),qsTr("Place not found !"))
                        reSearch.stop()}
                    break;
                case PlaceSearchModel.Error:
                    popupMap.showMessage(qsTr("Search Place Error"),errorString())
                    reSearch.start();
                    break;
                }
            }
        }

        //mapp.qml
        StackView{
            id: popupMap

            function showMessage(title,message,backPage)
            {
                popupMap.visible = true
                popupMap.push(Qt.resolvedUrl("qrc:/Map/Message.qml") ,
                {
                    "title" : title,
                    "message" : message,
                    "backPage" : backPage
                })
                currentItem.closeForm.connect(closeMessage)
            }

            function closeMessage(backPage)
            {
                popupMap.pop(backPage)
                popupMap.visible = false
                cameraUI.state = "PhotoPreview"
            }

            function showPlaces()
            {
                popupMap.visible = true
                popupMap.push(Qt.resolvedUrl("qrc:/Map/SearchResultView.qml"),
                {
                    "placeSearchModel": placeSearchModel,
                    "width": popupMap.width,
                    "height": popupMap.height
                })
                currentItem.goBack.connect(closeMessage)
                currentItem.showRoute.connect(showRoute)
            }

            function showRoute(destination,pharmacy){
                popupMap.push(mapComponent);
                view.addRoute(destination);
                view.addName(destination,pharmacy);
                backButton.visible = true
            }

            z:2
            visible: false
            anchors.fill: parent
        }

        //ItemMap
        Item{
            id:mapComponent
            MapComponent{
                id:view
                width: parent.width
                height: parent.height
                map.plugin: mapPlugin
                anchors.fill: parent

                RouteQuery{
                    id: routeQuery
                    routeOptimizations: RouteQuery.FastestRoute
                    travelModes: RouteQuery.CarTravel
                }

                RouteModel{
                    id: routeModel
                    query: routeQuery
                    plugin: mapPlugin
                    autoUpdate: false
                    onStatusChanged: {
                        if (routeModel.status === RouteModel.Ready) {
                            console.log("Route ready");
                        } else {
                            console.log("Route status:", routeModel.status);
                        }
                    }
                }

                MapItemView{
                    model: routeModel
                    parent: view.map
                    delegate: MapRoute {
                        id: route
                        route: routeData
                        line.color: "#46a2da"
                        line.width: 5
                        smooth: true
                        opacity: 0.8
                    }
                }

                function addRoute(destination){
                    routeModel.reset();
                    routeQuery.clearWaypoints();
                    console.log("Adding start waypoint:", searchLocation);
                    routeQuery.addWaypoint(searchLocation);
                    console.log("Adding destination waypoint:", destination);
                    routeQuery.addWaypoint(destination);
                    routeModel.update();
                }

                function addName(destination,pharmacy){
                    component = Qt.createComponent("qrc:/Map/Marker.qml");
                    component2 = Qt.createComponent("qrc:/Map/NameMarker.qml");
                    if (component.status === Component.Ready){
                        finishCreation(destination,pharmacy);
                        // console.log("Item Ready, name is: ", destination);
                    } else component.statusChanged.connect(finishCreation);
                }

                function finishCreation(destination,pharmacy){
                    if (component.status === Component.Ready) {
                        // console.log("tester" + destination);
                        sprite = component.createObject(view.map, {coor:destination});
                        sprite2 = component2.createObject(view.map, {coor:destination,name: pharmacy});
                        view.map.addMapItem(sprite);
                        view.map.addMapItem(sprite2);
                        if (sprite === null) {
                            // Error Handling
                            console.log("Error creating object");
                        }
                    } else if (component.status === Component.Error) {
                        // Error Handling
                        console.log("Error loading component:", component.errorString());
                    }
                }

                function removeMarkers()
                {
                    if (sprite)
                    {
                        view.map.removeMapItem(sprite);
                        sprite.destroy();
                        sprite = null;
                    }
                    if (sprite2)
                    {
                        view.map.removeMapItem(sprite2);
                        sprite2.destroy();
                        sprite2 = null;
                    }
                }

                RoundButton{
                    id: backButton
                    height: 45
                    width: 45
                    visible: false
                    z: 3
                    anchors{
                        topMargin: 20
                        leftMargin: 20
                        top: parent.top
                        left: parent.left
                    }
                    icon.source: "qrc:/Image/Back-Map.jpeg"
                    icon.height: height
                    icon.width: width
                    onClicked: {
                        popupMap.pop()
                        view.removeMarkers()
                        backButton.visible = false
                    }
                }
            }
        }

        Rectangle {
            color: "white"
            opacity: busyIndicator.running ? 0.8 : 0
            anchors.fill: parent
            Behavior on opacity { NumberAnimation{} }
        }

        BusyIndicator {
            id: busyIndicator
            anchors.centerIn: parent
            running: placeSearchModel.status == PlaceSearchModel.Loading || routeModel.status == RouteModel.Loading
        }
    }
}
