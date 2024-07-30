import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item
{
    signal saveInfoUser(string userName, string age)

    Rectangle
    {
        id: page3
        width: parent.width
        height: parent.height

        Image
        {
            source : "qrc:/Image/Ttcanhan.jpeg"
            opacity: 0.8
            sourceSize.width: parent.width
            sourceSize.height: parent.height
            fillMode: Image.PreserveAspectFit
        }

        Image
        {
            id: aV
            source: "qrc:/Image/Avatar.png"
            anchors
            {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 40
            }
        }

        ColumnLayout
        {
            anchors
            {
                top: aV.bottom
                horizontalCenter: aV.horizontalCenter
                topMargin: 40
            }

            TextField
            {
                id: userNameField
                placeholderText: "Tên Người Dùng"
                font.pixelSize: 22
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                color: "black"
                Layout.preferredWidth: page3.width * 0.5// Đặt chiều rộng của trường nhập liệu
            }

            TextField
            {
                id: ageField
                placeholderText: "Tuổi"
                font.pixelSize: 22
                Layout.alignment: Qt.AlignHCenter
                color: "black"
                font.bold: true
                Layout.preferredWidth: page3.width * 0.5 // Đặt chiều rộng của trường nhập liệu
            }

            TextField
            {
                id: addressStatusField
                placeholderText: "Địa chỉ"
                font.pixelSize: 22
                Layout.alignment: Qt.AlignHCenter
                color: "black"
                font.bold: true
                Layout.preferredWidth: page3.width * 0.5 // Đặt chiều rộng của trường nhập liệu
            }

            TextField
            {
                id: phonestatusField
                placeholderText: "Số điện thoại"
                font.pixelSize: 22
                Layout.alignment: Qt.AlignHCenter
                color: "black"
                font.bold: true
                Layout.preferredWidth: page3.width * 0.5 // Đặt chiều rộng của trường nhập liệu
            }
            Button
            {
                text: "Lưu"
                Layout.alignment: Qt.AlignHCenter
                onClicked:
                {
                    saveInfoUser(userNameField.text, ageField.text)
                }
            }
        }
    }
}
