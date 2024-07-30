import QtQuick
import QtMultimedia
import QtQuick.Controls 2.15
import QtQuick.Layouts

Item
{
    id: phoTo
    property alias source: preview.source
    property var searchResult: []
    property bool listViewVisible: false // hiển thị RectangleInfo
    property string searchText

    signal closed
    signal photoClicked(string searchText)

    ListModel
    {
        id: searchList
    }

    ListModel
    {
        id: dataModel
    }

    Image
    {
        id: preview
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        smooth: true
        onSourceChanged:
        {
            if (lastCapturedImagePath !== "")
            {
                console.log(lastCapturedImagePath);
                checkImageTimer.start();
                console.log("Đang kiểm tra chất lượng ảnh!");
                checkQualityImage.visible = true;
            }
        }
    }

    Text
    {
        id: checkQualityImage
        text: "Đang kiểm tra chất lượng ảnh chụp"
        color: "white"
        anchors
        {
            right: preview.right
            margins: 10
        }
        font.pointSize: 13
        visible: false
    }

    Timer
    {
        id: checkImageTimer
        interval: 2000 // 2 giây
        repeat: false
        onTriggered:
        {
            console.log(lastCapturedImagePath);
            var checkImageInfo = imageInfo.checkImage(lastCapturedImagePath);
            updateImageStatus(checkImageInfo);
            checkImageResult.visible = true;
            checkQualityImage.visible = false;
        }
    }

    function updateImageStatus(checkImageInfo)
    {
        if (checkImageInfo)
        {
            checkImageResult.source = "qrc:/Image/tichxanh.png";
        }
        else
        {
            checkImageResult.source = "qrc:/Image/xdo.png";
        }
    }

    Image
    {
        id: checkImageResult
        source: ""
        width: 50
        height: 50
        anchors.right: preview.right
        anchors.topMargin: 20
        visible: false
    }

    Image
    {
        id: processData
        source: "qrc:/Image/processing.png"
        width: 50
        height: 50
        anchors.right: preview.right
        visible: !infoRectangle.visible && !sendImage.visible
        SequentialAnimation on rotation
        {
            loops: Animation.Infinite
            NumberAnimation { from: 0; to: 360; duration: 2000 }
        }
    }

    Rectangle
    {
        id: infoRectangle
        width: parent.width
        height: parent.height / 2
        color: "lightgrey"
        border.color: "black"
        radius: 5
        anchors.centerIn: parent
        visible: dataModel.count > 0

        ColumnLayout
        {
            anchors.fill: parent

            Text
            {
                text: "Thông tin toa thuốc"
                Layout.alignment: Qt.AlignHCenter
                font.bold: true
                font.pointSize: 13
                Layout.topMargin: 5
                Layout.bottomMargin: 10
            }

            ListView
            {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: dataModel
                visible: listViewVisible

                // Header của ListView
                header: Row
                {
                    width: listView.width
                    height: 40 // Chiều cao của header

                    Text
                    {
                        text: "STT"
                        width: listView.width * 0.3 // Chiều rộng cột
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true // Để làm nổi bật header
                    }

                    Text
                    {
                        text: "Tên thuốc"
                        width: listView.width * 0.3 // Chiều rộng cột
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true // Để làm nổi bật header
                    }

                    Text
                    {
                        text: "Liều dùng"
                        width: listView.width * 0.3 // Chiều rộng cột
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true // Để làm nổi bật header
                    }
                }

                // Delegate cho mỗi item trong ListView
                delegate: Item
                {
                    width: listView.width
                    height: 40 // Chiều cao của mỗi hàng

                    Row
                    {
                        anchors.fill: parent

                        Text
                        {
                            text: (index + 1).toString() // STT
                            width: listView.width * 0.3 // Chiều rộng cột
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text
                        {
                            text: model.value
                            width: listView.width * 0.3 // Chiều rộng cột
                            horizontalAlignment: Text.AlignHCenter

                            MouseArea
                            {
                                anchors.fill: parent
                                onClicked:
                                {
                                    console.log("Clicked!");
                                    dataSearch.search(model.value);
                                    addToSearchList();
                                    infoDetailRectangle.visible = true;
                                    searchResult = [];
                                }
                            }
                        }

                        TextField
                        {
                            id: doseField
                            placeholderText: "lần/ngày"
                            visible: !doseText.visible
                            width: listView.width * 0.3 // Chiều rộng cột
                            horizontalAlignment: Text.AlignHCenter
                            onAccepted:
                            {
                                doseText.text = doseField.text + " lần/ngày";
                                doseText.visible = true;
                                doseField.visible = false;
                                dataModel.set(index, {value: model.value, dose: doseField.text});
                            }
                        }

                        Text
                        {
                            id: doseText
                            text: model.dose !== undefined ? model.dose + " lần/ngày" : ""
                            width: listView.width * 0.3
                            horizontalAlignment: Text.AlignHCenter
                            visible: model.dose !== "" && model.dose !== undefined

                            MouseArea
                            {
                                anchors.fill: parent
                                onClicked:
                                {
                                    doseField.visible = true;
                                    doseText.visible = false;
                                    doseField.forceActiveFocus();
                                }
                            }
                        }
                    }
                }
            }

            Row
            {
                id: addButton
                Layout.fillWidth: true
                spacing: 10
                visible: true

                Image
                {
                    source: "qrc:/Image/addButton.png"
                    sourceSize.width: 30
                    sourceSize.height: 30
                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            newMedicineRow.visible = true;
                            addButton.visible = false;
                        }
                    }
                }
            }

            Row
            {
                id: newMedicineRow
                Layout.fillWidth: true
                Layout.bottomMargin: 5
                spacing: 8
                visible: false // Bắt đầu ẩn đi

                Text
                {
                    text: (dataModel.count + 1).toString() // STT của thuốc mới
                    width: listView.width * 0.2 // Chiều rộng cột
                    horizontalAlignment: Text.AlignHCenter
                }

                TextField
                {
                    id: newMedicineName
                    placeholderText: "Tên thuốc mới"
                    Layout.fillWidth: true
                    Layout.bottomMargin: 3
                    width: listView.width * 0.4
                }

                Button
                {
                    text: "Thêm"
                    onClicked:
                    {
                        var newItem = { "value": newMedicineName.text };
                        dataModel.append(newItem);
                        newMedicineName.text = "";
                        newMedicineRow.visible = false;
                        addButton.visible = true;
                    }
                }
            }
        }
    }

    Rectangle
    {
        id: infoDetailRectangle
        width: parent.width
        height: parent.height / 2
        color: "lightgrey"
        border.color: "black"
        radius: 5
        anchors.centerIn: parent
        visible: false // Bắt đầu ẩn đi
        z: 1

        ColumnLayout
        {
            anchors.fill: parent

            Text
            {
                text: "Thông tin thuốc"
                Layout.alignment: Qt.AlignHCenter
                font.bold: true
                font.pointSize: 13
                Layout.topMargin: 5
                Layout.bottomMargin: 10
            }

            ListView
            {
                id: detailProductListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: searchList
                clip: parent

                // Header của ListView
                header: Row
                {
                    width: detailProductListView.width
                    height: 40 // Chiều cao của header

                    Text
                    {
                        text: "STT"
                        width: detailProductListView.width * 0.1 // Chiều rộng cột
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true // Để làm nổi bật header
                    }

                    Text
                    {
                        text: "Tên nhà thuốc"
                        width: detailProductListView.width * 0.3 // Chiều rộng cột
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true // Để làm nổi bật header
                    }

                    Text
                    {
                        text: "Giá"
                        width: detailProductListView.width * 0.3 // Chiều rộng cột
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text
                    {
                        text: "Địa chỉ"
                        width: detailProductListView.width * 0.3 // Chiều rộng cột
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true // Để làm nổi bật header
                    }
                }

                // Delegate cho mỗi item trong ListView
                delegate: Item
                {
                    width: detailProductListView.width
                    height: 40 // Chiều cao của mỗi hàng

                    Row
                    {
                        anchors.fill: parent

                        Text
                        {
                            text: (index + 1).toString() // STT
                            width: detailProductListView.width * 0.1 // Chiều rộng cột
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text
                        {
                            text: model.pharmacy // Tên nhà thuốc
                            width: detailProductListView.width * 0.3 // Chiều rộng cột
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text
                        {
                            text: model.price // Giá
                            width: detailProductListView.width * 0.3 // Chiều rộng cột
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text
                        {
                            text: "Địa chỉ" // Địa chỉ
                            color: "blue"
                            font.underline: true
                            width: detailProductListView.width * 0.3 // Chiều rộng cột
                            horizontalAlignment: Text.AlignHCenter

                            MouseArea
                            {
                                anchors.fill:parent
                                onClicked:
                                {
                                    photoClicked(model.pharmacy)
                                }
                            }
                        }
                    }
                }
            }

            Button
            {
                text: "Đóng"
                Layout.alignment: Qt.AlignRight
                onClicked:
                {
                    infoDetailRectangle.visible = false;
                }
            }
        }
    }

    Rectangle
    {
        id: namePress
        width: parent.width
        height: 150
        color: "white"
        border.color: "black"
        radius: 5
        anchors.centerIn: parent
        visible: false

        ColumnLayout
        {
            anchors.fill: parent
            spacing: 10

            Text
            {
                text: "Tên đơn thuốc"
                Layout.alignment: Qt.AlignHCenter
                font.bold: true
                font.pointSize: 13
            }

            TextField
            {
                Layout.alignment: Qt.AlignHCenter
                id: inputNamePress
                placeholderText: "Tên đơn thuốc"
                Layout.preferredWidth: parent.width * 0.5
            }

            Button
            {
                text: "Ok"
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                onClicked:
                {
                    var jsonArray = [];

                    for (var i = 0; i < dataModel.count; i++)
                    {
                        var item = dataModel.get(i);
                        var jsonItem = {
                            "medicine_name": item.value,
                            "dose": item.dose + " lần/ngày"
                        };
                        jsonArray.push(jsonItem);
                    }
                    var jsonString = JSON.stringify(jsonArray);

                    var email = Qt.application.globalEmail;
                    var pressName = inputNamePress.text;
                    imageUploader.saveResult(lastCapturedImagePath, email, pressName, jsonString);
                    console.log("Email in Upload: ", email);
                    console.log("Press name in Upload: ", pressName);
                    console.log("JSON string: ", jsonString);
                    namePress.visible = false;
                }
            }
        }
    }

    Row
    {
        id: buttonsRow
        anchors
        {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            margins: 20
        }

        CameraButton
        {
            id: reCapture
            text: "Chụp lại"
            onClicked:
            {
                closed();
                sendImage.visible = true;
                saveResult.visible = false;
                checkImageResult.visible = false;
                checkQualityImage.visible = false;
            }
        }

        CameraButton
        {
            id: sendImage
            text: "Trích xuất"
            onClicked:
            {
                var email = Qt.application.globalEmail;
                imageUploader.uploadImage(lastCapturedImagePath, email);
                listViewVisible = true; // Hiển thị ListView khi nhấn Extract
                saveResult.visible = true;
                sendImage.visible = false;
                checkImageResult.visible = false;
            }
        }

        CameraButton
        {
            id: saveResult
            text: "Lưu"
            visible: false
            onClicked:
            {
                namePress.visible = true;
            }
        }
    }

    function getSearchList(result)
    {
        if (!result || result.length ===0)
        {
            return;
        }
        searchResult = result;
    }

    function addToSearchList()
    {
        searchList.clear();

        for (var i = 0; i < searchResult.length; i++)
        {
            if (searchResult[i])
            {
                var item = searchResult[i].match(/(?:[^,"]|"[^"]*")+/g);

                if (item.length >= 4)
                {
                    // Tạo một đối tượng mới từ dữ liệu tìm kiếm và thêm vào ListModel
                    var Items = { category: item[0], productName: item[1], price: item[2], pharmacy: item[3] };
                    searchList.append(Items);
                }
            }
            else
            {
                console.log("searchResults[i] is undefined or invalid");
            }
        }
    }

    Connections
    {
        target: imageUploader
        function onJsonDataParsed(data, type)
        {
            if (type === "uploadImage")
            {
                dataModel.clear();
                for (var i = 0; i < data.length; i++)
                {
                    dataModel.append(data[i]);
                }
            }
        }
    }

    Component.onCompleted:
    {
        dataSearch.searchResult.connect(getSearchList);
    }
}
