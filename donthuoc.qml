import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.1
import DisplayData 1.0
import QtPositioning
import QtLocation

Rectangle {
    id: red
    width: parent.width
    height: parent.height
    visible: true

    property var component
    property var sprite
    property var component2
    property var sprite2
    property int itemsPerPage: 6
    property var shouldUpdateListModel
    property int currentPage: 0
    property string searchKeyword: ""
    property var searchLocation: QtPositioning.coordinate(10.869783290998388, 106.80261646844893)
    property var searchRegion: QtPositioning.circle(searchLocation, 10000)
    property var lines: []
    property var searchResults: []
    property var searchHistory: []

    Image {
        source: "qrc:/Image/loginl.jpg"
        opacity: 1
        sourceSize.width: parent.width
        sourceSize.height: parent.height
        fillMode: Image.PreserveAspectFit
    }

    ListModel {
        id: searchList
    }

    ListModel {
        id: lCategory
    }

    ListModel {
        id: lHistory
    }

    ListModel {
        id: lDetailProduct
    }

    Timer {
        id: reSearch
        interval: 1000
        repeat: false
        onTriggered: {
            stackView.pop();
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
                if (count > 0) {
                    stackView.showPlaces()
                    reSearch.stop()
                } else {
                    stackView.showMessage(qsTr("Search Place Error"),qsTr("Place not found !"))
                    reSearch.stop()
                }
                break;
            case PlaceSearchModel.Error:
                stackView.showMessage(qsTr("Search Place Error"),errorString())
                reSearch.start()
                break;
            }
        }
    }

    // StackView to manage different views
    StackView {
        id: stackView

        function showMessage(title,message,backPage)
        {
            stackView.push(Qt.resolvedUrl("qrc:/Map/Message.qml") ,
                 {
                     "title" : title,
                     "message" : message,
                     "backPage" : backPage
                 })
            currentItem.closeForm.connect(closeMessage)
        }

        function closeMessage(backPage)
        {
            stackView.pop(backPage)
        }

        function showPlaces()
        {
            stackView.pop({tem:grid,immediate: true})
            stackView.push(Qt.resolvedUrl("qrc:/Map/SearchResultView.qml"),
                 {
                     "placeSearchModel": placeSearchModel,
                     "width": stackView.width,
                     "height": stackView.height
                 })
            currentItem.goBack.connect(closeMessage)
            currentItem.showRoute.connect(showRoute)
        }

        function showRoute(destination,pharmacy){
            stackView.push(mapComponent);
            view.addRoute(destination);
            view.addName(destination,pharmacy);
            backButton.visible = true
        }

        width: parent.width
        height: parent.height
        initialItem: grid
    }

    // Define the initial search view
    Item {
        id: grid
        visible: false
        width: parent.width
        height: parent.height

        GridLayout {
            id: gridLayout
            anchors.fill: parent
            columns: 1
            columnSpacing: 5
            anchors.margins: 5

            TextField {
                id: searchField
                placeholderText: "Nhập tên thuốc"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: parent.width - 100
                font.pixelSize: 20
                anchors.topMargin: 20

                property Timer searchTimer: null

                onTextChanged: {
                    if (searchTimer !== null) {
                        searchTimer.stop();
                    }

                    searchTimer = Qt.createQmlObject('import QtQuick 2.0; Timer {}', searchField);
                    searchTimer.interval = 500;
                    searchTimer.triggered.connect(function() {
                        updateSearch(searchField.text);
                    });
                    searchTimer.start();
                }

                onAccepted: {
                    updateSearchHistory(text);
                }
            }

            Text {
                text: "Lịch sử tìm kiếm"
                color: "blue"
                font.underline: true
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        historyInfo.visible = !historyInfo.visible
                    }
                }
            }

            GridView {
                width: parent.width
                height: parent.height
                model: lCategory
                cellWidth: width / 2
                cellHeight: 200
                delegate: Item {
                    width: GridView.view.cellWidth
                    height: GridView.view.cellHeight
                    Rectangle {
                        width: parent.width
                        height: 200
                        border.color: "lightgray"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Image {
                                fillMode: Image.PreserveAspectFit
                                source: model.image
                                sourceSize.width: 100
                                sourceSize.height: 100
                                Layout.alignment: Qt.AlignHCenter
                                onStatusChanged: {
                                    if (status === Image.Error && model.image.endsWith(".jpg")) {
                                        source = "https://nhathuocminhchau.com/uploads/images/no-photo.png";
                                    }
                                }
                            }

                            Text {
                                text: model.productName.substring(0, 50) + (model.productName.length > 50 ? "..." : "")
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                Layout.alignment: Qt.AlignHCenter
                                Layout.fillWidth: true
                            }

                            Text {
                                text: model.price
                                Layout.alignment: Qt.AlignLeft
                                font.bold: true
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            onClicked: {
                                placeSearchModel.searchForText(model.pharmacy);
                            }
                        }
                    }
                }
            }
        }
        Row
        {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter : parent.horizontalCenter
            spacing: 10

            Button
            {
                text: "Trang trước"
                onClicked:
                {
                    currentPage--;
                    if (shouldUpdateListModel){
                        if (currentPage > 0)
                        {
                            console.log("Trang: ", currentPage);
                            updateListModel();
                        }
                    } else {
                        if (currentPage > 0)
                        {
                            updateGridView();
                        }
                    }
                }
                enabled: currentPage > 0;
            }

            ComboBox
            {
                // Model hiển thị số trang
                model: shouldUpdateListModel ? Math.ceil(searchResults.length / itemsPerPage) : Math.ceil(lines.length / itemsPerPage)
                currentIndex: currentPage
                visible: shouldUpdateListModel !==1
                onCurrentIndexChanged:
                {
                    currentPage = currentIndex;
                    if (shouldUpdateListModel){
                        updateListModel();
                    } else {
                        updateGridView();
                    }
                }
            }

            Button
            {
                text: "Trang sau"
                onClicked:
                {
                    currentPage++;
                    if (shouldUpdateListModel){
                        if (currentPage < Math.ceil(searchResults.length / itemsPerPage) - 1)
                        {
                            console.log("Trang: ", currentPage);
                            updateListModel();
                        }
                    } else {
                        if (currentPage < Math.ceil(lines.length / itemsPerPage) - 1)
                        {
                            updateGridView();
                        }
                    }
                }
                enabled:
                {
                    if (shouldUpdateListModel) {
                        return currentPage < Math.ceil(searchResults.length / itemsPerPage) - 1;
                    } else {
                        return currentPage < Math.ceil(lines.length / itemsPerPage) - 1;
                    }
                }
            }
        }
    }

    // Define the map view
    Item {
        id: mapComponent
        MapComponent {
            id: view
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
                    stackView.pop()
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

    Rectangle
    {
        id: historyInfo
        width: parent.width
        height: parent.height / 2
        color: "lightgrey"
        border.color: "black"
        radius: 5
        anchors.centerIn: parent
        visible: false
        z: 1

        ColumnLayout
        {
            anchors.fill: parent

            Text
            {
                text: "Lịch sử tìm kiếm"
                Layout.alignment: Qt.AlignCenter
                font.bold: true
                font.pointSize: 13
                Layout.topMargin: 10
                Layout.bottomMargin: 5
            }

            ListView
            {
                id: historyListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: lHistory

                header: Row
                {
                    width: historyListView.width
                    height: 40

                    Text
                    {
                        text: "Tên thuốc"
                        width: historyListView.width * 0.5
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                    }

                    Text
                    {
                        text: "Thời gian"
                        width: historyListView.width * 0.5
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                    }
                }

                delegate: Item
                {
                    width: historyListView.width
                    height: 40

                    Row
                    {
                        anchors.fill: parent

                        Text
                        {
                            text: model.keyword
                            width: historyListView.width * 0.5
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text
                        {
                            text: model.timestamp
                            width: historyListView.width * 0.5
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            // Thực hiện tìm kiếm lại khi người dùng nhấp vào một mục trong lịch sử
                            searchField.text = model.keyword;
                            searchField.forceActiveFocus();
                            console.log("clicked here");
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted:
    {
        // Khởi tạo một đối tượng DataSearch từ C++
        // dataSearch = new DataSearch();

        // Kết nối tín hiệu searchResulttừ lớp C++
        dataSearch.searchResult.connect(getSearchResult);
        //searchResults = dataSearch.searchResult();
        readTextFile("data_merge.csv");
        console.log("Component.onCompleted");
    }
    // Function lưu lịch sử từ khóa tìm kiếm
    function updateSearchHistory(keyword)
    {
        var timestamp = formatDate(new Date());
        var searchHistoryItem = { keyword: keyword, timestamp: timestamp };

        if (searchHistory.length > 0 && searchHistory[0].keyword === keyword)
        {
            // Nếu từ khóa đã tồn tại trong lịch sử, chỉ cập nhật timestamp mới nhất
            searchHistory[0].timestamp = timestamp;
        }
        else
        {
            // Nếu từ khóa chưa tồn tại trong lịch sử, thêm mới vào đầu mảng
            searchHistory.unshift(searchHistoryItem);
        }

        // Sau đó, thêm từ khóa và timestamp vào lHistory ListModel
        lHistory.clear(); // Xóa dữ liệu hiện có
        for (var i = 0; i < searchHistory.length; i++)
        {
            lHistory.append({ "keyword": searchHistory[i].keyword, "timestamp": searchHistory[i].timestamp });
        }
        console.log("updateSearchHistory", searchHistory);
    }

    // Function format timestamp
    function formatDate(date)
    {
        var year = date.getFullYear();
        var month = ('0' + (date.getMonth() + 1)).slice(-2);
        var day = ('0' + date.getDate()).slice(-2);
        var hours = ('0' + date.getHours()).slice(-2);
        var minutes = ('0' + date.getMinutes()).slice(-2);
        var seconds = ('0' + date.getSeconds()).slice(-2);
        return hours + ':' + minutes + ':' + seconds + ' ' + day + '/' + month + '/' + year;
    }

    // Nhập tìm kiếm và lọc ra kết quả theo từng ký tự
    function updateSearch(keyword)
    {
        searchKeyword = keyword;
        shouldUpdateListModel = true;
        if (searchKeyword.trim() !== "")
        {
            // Gọi phương thức tìm kiếm từ C++
            dataSearch.search(searchKeyword.trim());
            console.log("Đang nhập...");
            updateListModel();

            // updateSearchHistory(keyword.trim());
        }
        else
        {
            lCategory.clear(); // Xóa dữ liệu hiện có nếu từ khóakhóa trống
            console.log("Chưa nhập...");
            updateGridView();
        }
    }

    function getSearchResult(result)
    {
        if (!result || result.length === 0)
        {
            return;
        }
        searchResults = result;
        console.log("getSearchResult");
    }

    //Hàm hiển thị list trả về kết quả tìm kiếm
    function updateListModel(result)
    {
        var startIndex = currentPage * itemsPerPage;
        var endIndex = Math.min(startIndex + itemsPerPage, searchResults.length);

        lCategory.clear(); // Xóa dữ liệu hiện có trong ListModel

        // Thêm dữ liệu từ kết quả tìm kiếm vào ListModel
        for (var i = startIndex; i < endIndex; i++)
        {
            if (searchResults[i])
            {
                var item = searchResults[i].match(/(?:[^,"]|"[^"]*")+/g);
                var ImageUrl = item[4].trim().replace(/[\r\n]/g, '');
                var price = item[2].replace(/"/g, '');

                if (item.length >= 4)
                {
                    // Tạo một đối tượng mới từ dữ liệu tìm kiếm và thêm vào ListModel
                    var Items = { category: item[0], productName: item[1], price: price, pharmacy: item[3], image: ImageUrl };
                    lCategory.append(Items);
                }
            }
        }
        console.log("updateListModel");
    }

    //Hàm hiển thị tất cả đơn thuốc theo grid view
    function updateGridView()
    {
        var startIdx = currentPage * itemsPerPage;
        var endIdx = Math.min(startIdx + itemsPerPage, lines.length);

        // xóa dữ liệu trong ListModel trước khi thêm dữ liệu mới
        lCategory.clear();

        // thêm từng dòng vào ListModel
        for (var i = startIdx ; i < endIdx; i++)
        {
            // tách dữ liệu từ dòng văn bản
            var parts = lines[i].match(/(?:[^,"]|"[^"]*")+/g);
            var ImageUrl = parts[4].trim().replace(/[\r\n]/g, '');
            var price = parts[2].replace(/"/g, '');
            var newItem = { category: parts[0], productName: parts[1], price: price, pharmacy: parts[3], image: ImageUrl };
            // thêm dữ liệu vào ListModel
            lCategory.append(newItem);
        }
        console.log("updateGridView");
    }

    // Đọc file csv để hiển thị lên giao diện
    function readTextFile(fileUrl)
    {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", fileUrl);
        xhr.onreadystatechange = function ()
        {
            if (xhr.readyState === XMLHttpRequest.DONE)
            {   // if request_status == DONE
                var response = xhr.responseText;
                lines = response.split("\n");
                currentPage = 0;
                updateGridView();
            }
        }
        xhr.send(); // begin the request
        console.log("readTextFile");
    }
}
