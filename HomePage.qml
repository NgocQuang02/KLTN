import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item
{
    id: homePage

    StatusBar
    {
        id: statusBar
    }

    Loader
    {
        id: mainLoader
        source: "qrc:/QML_RESOURCES/Ttcanhan.qml"
        anchors
        {
            left: parent.left
            right: parent.right
            top: statusBar.bottom
            bottom: parent.bottom
        }
    }
}
