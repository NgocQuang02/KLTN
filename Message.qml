import QtQuick

MessageForm {
    property string title
    property string message
    property var backPage

    signal closeForm(var backPage)

    button.onClicked: {
        closeForm(backPage)
    }

    Component.onCompleted: {
        messageText.text = message
        messageTitle.text = title
    }
}
