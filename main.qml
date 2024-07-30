//main.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.15


ApplicationWindow
{
    id: root
    visible: true
    width: 480
    height: 900
    title: "Ứng dụng Y Tế"

    property bool registrationConditionsMet: false
    property string globalEmail: ""

    Component
    {
        id: mainPageComponent
        HomePage {}
    }

    Component
    {
        id: loginPageComponent
        Login
        {
            onSignUpClicked:
            { // Load trang đăng ký
                pageLoader.sourceComponent = registrationPageComponent;
            }
        }
    }

    Component
    {
        id: registrationPageComponent
        Signup
        {
            onBackClicked:
            { // back lại trang đăng nhập
                pageLoader.sourceComponent = loginPageComponent;
            }
        }
    }

    Loader
    { // dùng để tải giao diện Login
        id: pageLoader
        anchors.fill: parent
        sourceComponent: loginPageComponent
    }
}

