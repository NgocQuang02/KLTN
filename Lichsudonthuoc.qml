import QtQuick
import QtMultimedia
import QtQuick.Controls 2.15
import QtQuick.Layouts

Item
{
    property string base64ImageSource: ""
    property string specificText: ""
    property string specificText_new: ""

    ListModel
    {
        id: lGetTotal
    }

    ListModel
    {
        id: lGetResult
    }

    Connections
    {
        target: imageUploader
        function onJsonDataParsed(data, type)
        {
            if (type === "getTotal")
            {
                historyAI.visible = true;
                lGetTotal.clear();
                for (var it = 0; it < data.length; it++)
                {
                    lGetTotal.append(data[it]);
                }
            }
            else if (type === "getResult")
            {
                getResultRectangle.visible = true;
                lGetResult.clear();
                for (var iti = 0; iti < data.length; iti++)
                {
                    var item = data[iti];
                    if (item.type === "image")
                    {
                        base64ImageSource = item.base64image;
                    }
                    else if (item.type === "specific")
                    {
                        specificText = item.specific;
                    }
                    else if (item.type === "prescription")
                    {
                        lGetResult.append({"medicine_name" : item.medicine_name, "dose": item.dose});
                    }
                }
            }
        }
    }

    // Hiển thị lịch sử tra cứu
    Rectangle
    {
        id: historyAI
        width: parent.width
        height: parent.height
        color: "lightgrey"
        border.color: "black"
        radius: 5
        anchors.centerIn: parent
        visible: false // Bắt đầu ẩn đi

        ColumnLayout
        {
            anchors.fill: parent

            Text
            {
                text: "Lịch sử tra cứu"
                Layout.alignment: Qt.AlignHCenter
                font.bold: true
                font.pointSize: 13
                Layout.topMargin: 10
                Layout.bottomMargin: 5
            }

            ListView
            {
                id: historyAIListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: lGetTotal
                clip: parent

                header: Row
                {
                    width: historyAIListView.width
                    height: 40

                    Text
                    {
                        text: "Tên đơn thuốc"
                        width: historyAIListView.width * 0.45
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                    }

                    Text
                    {
                        text: "Thời gian"
                        width: historyAIListView.width * 0.45
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                    }
                }

                delegate: Item
                {
                    width: historyAIListView.width
                    height: 40

                    Row
                    {
                        anchors.fill: parent

                        Text
                        {
                            id: specificvalue
                            text: model.specific
                            width: historyAIListView.width * 0.45
                            horizontalAlignment: Text.AlignHCenter

                            MouseArea
                            {
                                anchors.fill: parent
                                onClicked:
                                {
                                    var email = Qt.application.globalEmail;
                                    imageUploader.getResult(email, model.specific);
                                    getResultRectangle.visible = true;
                                }
                            }
                        }

                        Text
                        {
                            text:  addDateTime(model.day, model.time, 7)
                            // text: model.time + " : " + model.day
                            width: historyAIListView.width * 0.45
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text
                        {
                            text: "Xóa"
                            color: "blue"
                            font.underline: true
                            width: historyAIListView.width * 0.1
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter

                            MouseArea
                            {
                                width: parent.width
                                height: parent.height
                                onClicked:
                                {
                                    var email = Qt.application.globalEmail;
                                    imageUploader.deleteResult(email, model.specific);
                                    lGetTotal.remove(specificvalue);
                                    imageUploader.getTotal(email);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // hiển thị kết quả tra cứu
    Rectangle
    {
        id: getResultRectangle
        width: parent.width
        height: parent.height
        color: "white"
        border.color: "black"
        radius: 5
        anchors.top: parent.top
        visible: false
        z: 1

        ColumnLayout
        {
            anchors.fill: parent

            Image
            {
                height: parent.height
                source: base64ImageSource !== "" ? base64Converter.base64ToImageUrl(base64ImageSource) : ""
                sourceSize.width: 250
                sourceSize.height: 250
                fillMode: Image.PreserveAspectFit
                Layout.alignment: Qt.AlignTop | Qt.AlignCenter
            }

            // Rectangle bao quanh ListView bao gồm header và các giá trị
            Rectangle
            {
                id: resultNameInfo
                Layout.fillWidth: true
                Layout.fillHeight: true
                border.color: "black"
                color: "lightgrey"
                radius: 5

                ColumnLayout
                {
                    anchors.fill: parent

                    TextField
                    {
                        id: specific_textfield
                        placeholderText: "Đơn thuốc"
                        visible: !specific_text.visible
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        Layout.topMargin: 15
                        Layout.bottomMargin: 15
                        Layout.preferredWidth: parent.width * 0.5

                        onAccepted:
                        {
                            specific_text.text = specific_textfield.text;
                            specific_text.visible = true;
                            specific_textfield.visible = false;
                            specificText_new = specific_textfield.text;
                            console.log("Specific New Name: ", specificText_new);
                        }
                    }

                    Text
                    {
                        id: specific_text
                        text: specificText !== "" ? specificText : "Đơn thuốc"
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                        font.pointSize: 13
                        Layout.topMargin: 15
                        Layout.bottomMargin: 15

                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked:
                            {
                                specific_textfield.visible = true;
                                specific_text.visible = false;
                                specific_textfield.forceActiveFocus();
                            }
                        }
                    }

                    // ListView chứa các giá trị
                    ListView
                    {
                        id: detailGetResultListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: lGetResult

                        // Header của ListView
                        header: Row
                        {
                            width: detailGetResultListView.width
                            height: 40 // Chiều cao của header

                            Text
                            {
                                text: "STT"
                                width: detailGetResultListView.width * 0.3 // Chiều rộng cột
                                horizontalAlignment: Text.AlignHCenter
                                font.bold: true // Để làm nổi bật header
                            }

                            Text
                            {
                                text: "Tên thuốc"
                                width: detailGetResultListView.width * 0.3 // Chiều rộng cột
                                horizontalAlignment: Text.AlignHCenter
                                font.bold: true // Để làm nổi bật header
                            }

                            Text
                            {
                                text: "Liều dùng"
                                width: detailGetResultListView.width * 0.3 // Chiều rộng cột
                                horizontalAlignment: Text.AlignHCenter
                                font.bold: true // Để làm nổi bật header
                            }
                        }

                        // Delegate cho mỗi item trong ListView
                        delegate: Item
                        {
                            width: detailGetResultListView.width
                            height: 40

                            property string originalText: model.medicine_name
                            property string originalDose: model.dose

                            Row
                            {
                                anchors.fill: parent

                                Text
                                {
                                    text: (index + 1).toString() // STT
                                    width: detailGetResultListView.width * 0.3 // Chiều rộng cột
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                TextField
                                {
                                    id: medicineNameResultField
                                    placeholderText: "Tên thuốc"
                                    visible: !medicineNameResult.visible
                                    width: detailGetResultListView.width * 0.3
                                    horizontalAlignment: Text.AlignHCenter

                                    onAccepted:
                                    {
                                        medicineNameResult.text = medicineNameResultField.text;
                                        medicineNameResult.visible = true;
                                        medicineNameResultField.visible = false;
                                        lGetResult.set(index, {medicine_name: medicineNameResultField.text, dose: model.dose});
                                    }
                                    onActiveFocusChanged: if (!activeFocus && medicineNameResultField.visible)
                                    {
                                        medicineNameResultField.visible = false;
                                        medicineNameResult.text = originalText;
                                        medicineNameResult.visible = true;
                                    }
                                }

                                Text
                                {
                                    id: medicineNameResult
                                    text: model.medicine_name
                                    width: detailGetResultListView.width * 0.3
                                    horizontalAlignment: Text.AlignHCenter

                                    MouseArea
                                    {
                                        anchors.fill: parent
                                        onClicked:
                                        {
                                            originalText = medicineNameResult.text; //
                                            medicineNameResultField.text = originalText; //
                                            medicineNameResultField.visible = true;
                                            medicineNameResult.visible = false;
                                            medicineNameResultField.forceActiveFocus();
                                        }
                                    }
                                }

                                TextField
                                {
                                    id: doseResultField
                                    placeholderText: "lần/ngày"
                                    visible: !doseResult.visible
                                    width: detailGetResultListView.width * 0.3
                                    horizontalAlignment: Text.AlignHCenter

                                    onAccepted:
                                    {
                                        doseResult.text = doseResultField.text +  " lần/ngày";
                                        doseResult.visible = true;
                                        doseResultField.visible = false;
                                        lGetResult.set(index, {medicine_name: model.medicine_name, dose: doseResult.text});
                                    }

                                    onActiveFocusChanged: if (!activeFocus && doseResultField.visible)
                                    {
                                        doseResultField.visible = false;
                                        doseResult.text = originalDose;
                                        doseResult.visible = true;
                                    }
                                }

                                Text
                                {
                                    id: doseResult
                                    text: model.dose !== "" ? model.dose : "lần/ngày"
                                    width: detailGetResultListView.width * 0.3
                                    horizontalAlignment: Text.AlignHCenter

                                    MouseArea
                                    {
                                        anchors.fill: parent
                                        onClicked:
                                        {
                                            doseResultField.visible = true;
                                            doseResult.visible = false;
                                            doseResultField.forceActiveFocus();
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
                        visible: false

                        Text
                        {
                            text: ""
                            width: detailGetResultListView.width * 0.2 // Chiều rộng cột
                            horizontalAlignment: Text.AlignHCenter
                        }

                        TextField
                        {
                            id: newMedicineName
                            placeholderText: "Tên thuốc mới"
                            Layout.fillWidth: true
                            Layout.bottomMargin: 3
                            width: detailGetResultListView.width * 0.4
                        }

                        Button
                        {
                            text: "Thêm"
                            onClicked:
                            {
                                var newItem = { "medicine_name": newMedicineName.text };
                                lGetResult.append(newItem);
                                newMedicineName.text = "";
                                newMedicineRow.visible = false;
                                addButton.visible = true;
                            }
                        }
                    }
                }
            }

            // Nút đóng
            Button
            {
                id: closeButton
                text: "Đóng"
                Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                onClicked:
                {
                    getResultRectangle.visible = false;
                    var email = Qt.application.globalEmail;
                    imageUploader.getTotal(email);
                }
            }

            Button
            {
                id: updateButton
                text: "Cập nhật"
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                onClicked:
                {
                    var jsonArray = [];

                    for (var i = 0; i < lGetResult.count; i++)
                    {
                        var item = lGetResult.get(i);

                        if (item.medicine_name && item.dose)
                        {
                            var jsonItem = {
                                "medicine_name": item.medicine_name,
                                "dose": item.dose
                            };
                            jsonArray.push(jsonItem);
                        }
                    }
                    var jsonString = JSON.stringify(jsonArray);

                    var email = Qt.application.globalEmail;
                    var specificName = specificText;
                    var specificName_new = "";

                    if (specificText_new)
                    {
                        specificName_new = specificText_new;
                        console.log ("Have changed: ", specificName_new);
                    }
                    else
                    {
                        specificName_new = specificText;
                        console.log ("No changed: ", specificName_new);
                    }

                    imageUploader.updateResult(email, specificName, jsonString, specificName_new);
                    console.log("Email in Donthuoc: ", email);
                    console.log("Specific name in Donthuoc: ", specificName);
                    console.log("JSON string: ", jsonString);
                    console.log("Specific name new in Donthuoc: ", specificName_new);
                }
            }
        }
    }

    function addDateTime(dayString, timeString, hoursToAdd)
    {
        // Split the time string into hours, minutes, and seconds
        var timeParts = timeString.split(":");
        var hours = parseInt(timeParts[0]);
        var minutes = parseInt(timeParts[1]);
        var seconds = parseInt(timeParts[2]);

        // Split the day string into year, month, and day
        var dateParts = dayString.split("-");
        var year = parseInt(dateParts[0]);
        var month = parseInt(dateParts[1]) - 1; // Months are 0-based in JavaScript Date
        var day = parseInt(dateParts[2]);

        // Create a Date object using the provided date and time
        var date = new Date(year, month, day, hours, minutes, seconds);

        // Add the specified number of hours
        date.setHours(date.getHours() + hoursToAdd);

        // Format the new date and time string
        var newYear = date.getFullYear();
        var newMonth = String(date.getMonth() + 1).padStart(2, '0'); // Months are 0-based
        var newDay = String(date.getDate()).padStart(2, '0');
        var newHours = String(date.getHours()).padStart(2, '0');
        var newMinutes = String(date.getMinutes()).padStart(2, '0');
        var newSeconds = String(date.getSeconds()).padStart(2, '0');

        var newDateString = newDay + "-" + newMonth + "-" + newYear;
        var newTimeString = newHours + ":" + newMinutes + ":" + newSeconds;

        return newDateString + "   " + newTimeString;
    }
}
