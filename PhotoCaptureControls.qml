import QtQuick
import QtMultimedia
import QtQuick.Layouts

FocusScope {
    id : captureControls
    property CaptureSession captureSession
    property bool previewAvailable : false

    property int buttonsmargin: 8
    property int buttonsPanelWidth
    property int buttonsPanelPortraitHeight
    property int buttonsWidth
    property int captureCount: 1 // Biến đếm số lần chụp ảnh

    signal previewSelected
    signal videoModeSelected

    Rectangle {
        id: buttonPaneShadow
        color: Qt.rgba(0.08, 0.08, 0.08, 1)

        //left button
        GridLayout {
            id: buttonsColumn
            anchors.margins: captureControls.buttonsmargin
            flow: captureControls.state === "MobilePortrait" ? GridLayout.LeftToRight : GridLayout.TopToBottom

            CameraButton {
                text: "Chụp ảnh"
                implicitWidth: captureControls.buttonsWidth
                visible: captureControls.captureSession.imageCapture.readyForCapture
                onClicked: {
                    var fileName = "donthuoc" + captureCount + ".jpg";
                    var imagePath = "/home/quang/Pictures/" + fileName;

                    // Chụp, lưu ảnh
                    captureControls.captureSession.imageCapture.captureToFile(fileName);
                    captureCount++;

                    console.log("Sau khi chụp ảnh xong!!!!!!!!!!!!!!");

                    // Lưu đường dẫn tệp ảnh cuối cùng
                    lastCapturedImagePath = imagePath;

                    // Preview ngay sau khi chụp
                    captureControls.previewSelected();
                }
            }
        }

        //right button
        GridLayout {
            id: bottomColumn
            anchors.margins: captureControls.buttonsmargin
            flow: captureControls.state === "MobilePortrait" ? GridLayout.LeftToRight : GridLayout.TopToBottom

            CameraListButton {
                implicitWidth: captureControls.buttonsWidth
                state: captureControls.state
                onValueChanged: captureControls.captureSession.camera.cameraDevice = value
            }
        }
    }

    states: [
        State {
            name: "MobilePortrait"
            PropertyChanges {
                buttonPaneShadow.width: parent.width
                buttonPaneShadow.height: captureControls.buttonsPanelPortraitHeight
                buttonsColumn.height: captureControls.buttonsPanelPortraitHeight / 2 - buttonsmargin
                bottomColumn.height: captureControls.buttonsPanelPortraitHeight / 2 - buttonsmargin
            }
            AnchorChanges {
                target: buttonPaneShadow
                // qmllint disable incompatible-type
                anchors.bottom: captureControls.bottom
                anchors.left: captureControls.left
                anchors.right: captureControls.right
                // qmllint enable incompatible-type
            }
            AnchorChanges {
                target: buttonsColumn
                // qmllint disable incompatible-type
                anchors.left: buttonPaneShadow.left
                anchors.right: buttonPaneShadow.right
                anchors.top: buttonPaneShadow.top
                // qmllint enable incompatible-type
            }
            AnchorChanges {
                target: bottomColumn
                // qmllint disable incompatible-type
                anchors.bottom: buttonPaneShadow.bottom
                anchors.left: buttonPaneShadow.left
                anchors.right: buttonPaneShadow.right
                // qmllint enable incompatible-type
            }
        },
        State {
            name: "MobileLandscape"
            PropertyChanges {
                buttonPaneShadow.width: buttonsPanelWidth
                buttonPaneShadow.height: parent.height
                buttonsColumn.height: parent.height
                buttonsColumn.width: buttonPaneShadow.width / 2
                bottomColumn.height: parent.height
                bottomColumn.width: buttonPaneShadow.width / 2
            }
            AnchorChanges {
                target: buttonPaneShadow
                // qmllint disable incompatible-type
                anchors.top: captureControls.top
                anchors.right: captureControls.right
                // qmllint enable incompatible-type
            }
            AnchorChanges {
                target: buttonsColumn
                // qmllint disable incompatible-type
                anchors.top: buttonPaneShadow.top
                anchors.bottom: buttonPaneShadow.bottom
                anchors.left: buttonPaneShadow.left
                // qmllint enable incompatible-type
            }
            AnchorChanges {
                target: bottomColumn
                // qmllint disable incompatible-type
                anchors.top: buttonPaneShadow.top
                anchors.bottom: buttonPaneShadow.bottom
                anchors.right: buttonPaneShadow.right
                // qmllint enable incompatible-type
            }
        },
        State {
            name: "Other"
            PropertyChanges {
                // buttonPaneShadow.width: bottomColumn.width + 16
                // buttonPaneShadow.height: parent.height
                buttonPaneShadow.width: parent.width
                buttonPaneShadow.height: bottomColumn.height + 16
            }
            AnchorChanges {
                target: buttonPaneShadow
                // qmllint disable incompatible-type
                anchors.left: captureControls.left
                anchors.bottom: captureControls.bottom
                // qmllint enable incompatible-type
            }
            AnchorChanges {
                target: buttonsColumn
                // qmllint disable incompatible-type
                anchors.left: buttonPaneShadow.left
                anchors.bottom: buttonPaneShadow.bottom
                // qmllint enable incompatible-type
            }
            //
            AnchorChanges {
                target: bottomColumn
                // qmllint disable incompatible-type
                anchors.bottom: buttonPaneShadow.bottom
                anchors.right: buttonPaneShadow.right
                // qmllint enable incompatible-type
            }
        }
    ]
}
