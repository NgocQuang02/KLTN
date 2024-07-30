import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: statusBar
    property var userNameSignUp: Qt.application.globalUsername

    anchors
    {
        right: parent.right
        left: parent.left
    }

    height: 126
    width: 480

    function updateUserInfo(userName, age)
    {
        userNametext.text = userName;
        ageText.text = age;
    }

    Connections
    {
        target: mainLoader.item
        function onSaveInfoUser(userName, age)
        {
            updateUserInfo(userName, age);
        }
    }

    Rectangle
    {
        id: infoBar
        width: parent.width
        height: 90
        color:"dodgerblue"

        RowLayout {
            id: avaPic
            spacing: 10
            Image
            {
                source:"qrc:/Image/Avatar.png"
                sourceSize.width: 90
                sourceSize.height: 70
                fillMode: Image.PreserveAspectFit
                MouseArea
                {
                    anchors.fill: parent
                    onClicked:
                    {
                        console.log("Clicked on Mục 4 - Setting source to Ttcanhan.qml");
                        mainLoader.source = "Ttcanhan.qml";
                    }
                }
            }

            ColumnLayout
            {
                spacing: 2

                Text
                {
                    id: userNametext
                    font.pixelSize: 18
                    text: userNameSignUp
                    font.bold: true
                    color:"white"
                }
                Text
                {
                    id: ageText
                    font.pixelSize: 18
                    text: "null"
                    color:"white"
                    font.italic: true
                }
            }
        }
    }

    Rectangle{
        width:  parent.width
        height: 36
        color:"dodgerblue"
        anchors{
            left: parent.left
            right: parent.right
            top: infoBar.bottom
        }
        ToolButton {
            id: button1
            text: "Chụp Ảnh"
            anchors{
                rightMargin: 20
                leftMargin: 20
                left: parent.left
            }
            font.pixelSize: 20
            onClicked:
            {
                console.log("Clicked on Mục 1 - Setting source to ../Camera/camera.qml");
                mainLoader.source = "../Camera/camera.qml";
            }

            Rectangle {
                anchors.fill:parent
                border.width: 2
                border.color: "blue"
                opacity: 1.0
                radius:10
            }
        }

        ToolButton {
            id: button2
            anchors{
                rightMargin: 40
                leftMargin: 40
                left: button1.right
                right: button3.left
            }
            text: "Tìm kiếm"
            font.pixelSize: 20
            onClicked: {
                console.log("Clicked on Mục 2 - Setting source to ../database/donthuoc.qml");
                mainLoader.source = "../database/donthuoc.qml";
            }

            Rectangle {
                anchors.fill:parent
                border.width: 2
                border.color: "blue"
                opacity: 1.0
                radius:10
            }
        }

        ToolButton {
            id: button3
            anchors{
                rightMargin: 20
                leftMargin: 20
                right: parent.right
            }
            font.pixelSize: 20
            text: "Đơn thuốc"
            onClicked: {
                console.log("Clicked on Mục 3 - Setting source to Lichsudonthuoc.qml");
                mainLoader.source = "Lichsudonthuoc.qml";
                var email = Qt.application.globalEmail;
                imageUploader.getTotal(email);
            }

            Rectangle
            {
                anchors.fill:parent
                border.width: 2
                border.color: "blue"
                opacity: 1.0
                radius: 10
            }
        }
    }
}
