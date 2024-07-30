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
            fillMode: Image.PreserveAspectCrop
        }


        Rectangle
        {
            width: parent.width
            height: parent.height
            color: "white"
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

                Row
                {
                    spacing: 5
                    Rectangle
                    {
                        width: 300
                        height: 50
                        color: "lightblue"
                        border.color: "gray"
                        radius: 100

                        Row
                        {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 5

                            Image
                            {
                                source: "qrc:/Image/login_account.png"
                                width: 30
                                height: 30
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            TextField
                            {
                                id: emailInput
                                placeholderText: "Email"
                                font.bold: true
                                width: 300
                                height: 50
                                anchors.verticalCenter: parent.verticalCenter
                                background: null
                            }
                        }
                    }
                }

                // Password Field with Show/Hide Icon
                Rectangle
                {
                    width: 300
                    height: 50
                    color: "lightblue"
                    border.color: "gray"
                    radius: 100

                    Row
                    {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 5

                        Image
                        {
                            source: "qrc:/Image/login_password.png"
                            width: 30
                            height: 30
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        TextField
                        {
                            id: passwordInput
                            placeholderText: "Mật khẩu"
                            font.bold: true
                            width: 200
                            height: 50
                            anchors.verticalCenter: parent.verticalCenter
                            echoMode: TextInput.Password
                            background: null
                        }

                        MouseArea
                        {
                            width: 25
                            height: 25
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked:
                            {
                                passwordInput.echoMode = (passwordInput.echoMode === TextInput.Password) ? TextInput.Normal : TextInput.Password;
                            }

                            Rectangle
                            {
                                width: 25
                                height: 25
                                color: "transparent"
                                radius: 3

                                Image
                                {
                                    anchors.fill: parent
                                    source: (passwordInput.echoMode === TextInput.Password) ? "qrc:/Image/hidden.png" : "qrc:/Image/visible.png"
                                    fillMode: Image.PreserveAspectFit
                                }
                            }
                        }
                    }
                }

                Text // Đăng ký
                {
                    text: "Đăng ký tài khoản"
                    font.bold: true
                    font.pointSize: 10
                    color: "blue"
                    anchors.right: parent.right
                    anchors.bottomMargin: 5
                    MouseArea
                    {
                        width: parent.width
                        height: parent.width
                        onClicked:
                        {
                            signUpClicked();
                        }
                    }
                }

                RoundButton //gọi hàm validateLogin để ktra thông tin đăng nhập
                {
                    text: "Đăng nhập"
                    width: 300
                    height: 50
                    radius: 100
                    font.bold: true
                    onClicked:
                    {
                        var email = emailInput.text;
                        var password = passwordInput.text;
                        Lfunction.validateLogin(email, password, errorLogin, errorTimer);
                    }
                }

                Text // Hiển thị thông báo lỗi
                {
                    id: errorLogin
                    color: "red"
                    text: ""
                }

                Timer // Timer cho thông báo lỗi
                {
                    id: errorTimer
                    interval: 2000
                    onTriggered:
                    {
                        errorLogin.text = "";
                    }
                }
            }
        }
    }
    signal signUpClicked();
}
