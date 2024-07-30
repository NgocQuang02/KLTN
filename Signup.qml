import QtQuick 2.2
import QtQuick.Controls 2.15
import "functionLogin.js" as Lfunction

Rectangle
{
    width: parent.width
    height: parent.height

    Rectangle
    {
        width: parent.width
        height: parent.height

        Image
        {
            source: "qrc:/Image/loginl.jpg"
            width: parent.width
            height: parent.height
        }

        Rectangle
        {
            width: parent.width
            height: parent.height
            opacity: 0.5

            Column
            {
                anchors.centerIn: parent
                spacing: 10

                    Image
                    {
                        source: "qrc:/Image/Login_Signup.png"
                        width: 150
                        height: 150
                        fillMode: Image.PreserveAspectFit
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle
                    {
                        width: 280
                        height: 50
                        color: "white"
                        border.color: "gray"
                        radius: 50

                        TextField
                        {
                            id: regEmail
                            placeholderText: "Email"
                            font.bold: true
                            width: 280
                            height: 50
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            background: null
                        }
                    }

                    Rectangle
                    {
                        width: 280
                        height: 50
                        color: "white"
                        border.color: "gray"
                        radius: 50

                        TextField
                        {
                            id: regPasswordInput
                            placeholderText: "Mật khẩu"
                            font.bold: true
                            width: 280
                            height: 50
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            echoMode: TextInput.Password
                            background: null

                        }
                    }

                    Rectangle
                    {
                        width: 280
                        height: 50
                        color: "white"
                        border.color: "gray"
                        radius: 50

                        TextField
                        {
                            id: regRePasswordInput
                            placeholderText: "Nhập lại mật khẩu"
                            font.bold: true
                            width: 280
                            height: 50
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            echoMode: TextInput.Password
                            background: null
                        }
                    }

                    Rectangle
                    {
                        width: 280
                        height: 50
                        color: "white"
                        border.color: "gray"
                        radius: 50

                        TextField
                        {
                            id: regUsernameInput
                            placeholderText: "Tên tài khoản"
                            font.bold: true
                            width: 280
                            height: 50
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            background: null
                        }
                    }

                    RoundButton //lưu thông tin vào database
                    {
                        text: "Đăng ký"
                        width: 280
                        height: 50
                        radius: 100
                        font.bold: true
                        onClicked:
                        {
                            var email = regEmail.text;
                            var password = regPasswordInput.text;
                            var rePassword = regRePasswordInput.text;
                            var username = regUsernameInput.text;

                            if (Lfunction.isValidRegistration(password, rePassword)) // nếu password == re-password thì thực hiện lưu thông tin
                            {
                                Lfunction.saveUserDataToFirebase(email, password, username, notiSignup, errorTimer);
                                console.log("Đăng ký thành công!");
                            }
                            else
                            {
                                console.log("Đăng ký không thành công. Vui lòng kiểm tra lại thông tin.");
                                notiSignup.text = "Mật khẩu không khớp. Vui lòng nhập lại.";
                                errorTimer.start();
                            }
                        }
                    }

                    Image
                    {
                        source: "qrc:/Image/left-arrow.png"
                        width: 30
                        height: 30
                        anchors.top: parent.TopLeft

                        MouseArea
                        {
                            width: parent.width
                            height: parent.width
                            onClicked:
                            {
                                backClicked();
                            }
                        }
                    }

                    // Text
                    // {
                    //     text: "Quay lại"
                    //     font.bold: true
                    //     font.pointSize: 10
                    //     color: "blue"
                    //     anchors.left: parent
                    //     anchors.bottomMargin: 5

                    //     MouseArea
                    //     {
                    //         width: parent.width
                    //         height: parent.width
                    //         onClicked:
                    //         {
                    //             backClicked();
                    //         }
                    //     }
                    // }

                    Text
                    {
                        id: notiSignup
                        color: "red"
                        text: ""
                    }

                    Timer
                    {
                        id: errorTimer
                        interval: 2000
                        onTriggered:
                        {
                            notiSignup.text = "";
                        }
                    }
                }
            }
        }
    signal backClicked();
}
