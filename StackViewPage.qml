//StackViewPage.qml
import QtQuick 2.15
import QtQuick.Controls 2.12

Item
{
    anchors.fill: parent

    StackView
    {
        id: stackView
        anchors.fill: parent
        initialItem: "Ttcanhan.qml"
    }
}
