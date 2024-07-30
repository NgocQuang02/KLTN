import QtQuick
import QtLocation
import QtQuick.Controls
import QtQuick.Layouts

//! [PlaceSearchModel place list]
ListView {
    id: searchView

    property var placeSearchModel
    signal goBack()
    signal showPlaceDetails(var place, var distance)
    signal showRoute(var destination, var pharmacy)

    header: Text{
        width: parent.width
        anchors{
            topMargin: 10
            bottomMargin: 10
        }
        text: "       Kết quả tìm kiếm được trong vòng 10km!"
        color:"#242424"
        font.bold: true
        font.pixelSize: 20
        styleColor: "#ECECEC"
        style: Text.Outline
    }

    model: placeSearchModel
    delegate: SearchResultDelegate
    {
        width: ListView.view.width
        onShowPlaceDetails: function (place, distance) { searchView.showPlaceDetails(place, distance) }
        onSearchFor: function (query) { placeSearchModel.searchForText(query) }
        onShowRoute: function(destination,pharmacy) {searchView.showRoute(destination,pharmacy)}
    }

    footer: RowLayout {
        width: parent.width

        // Button {
        //     text: qsTr("Clear")
        //     onClicked: {
        //         placeSearchModel.reset()
        //         goBack()
        //     }
        //     Layout.alignment: Qt.AlignHCenter
        // }

        Button {
            text: qsTr("Back")
            onClicked:{
                goBack()
            }
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
//! [PlaceSearchModel place list]
