var scriptPath = Qt.resolvedUrl("qrc:/QML_RESOURCES/crypto-js/crypto-js.js");
var cryptoJs = Qt.include(scriptPath);

function saveUserDataToFirebase(email, password, username, notiSignup, errorTimer) // đăng ký, lưu thông tin vào Firebase
{
    var hashedPassword = CryptoJS.SHA256(password).toString ();  // pass User đăng ký
    console.log(hashedPassword);

    var firebaseURL = "https://databaseapp-c992e-default-rtdb.firebaseio.com/" + username + ".json";

    var requestRegister = new XMLHttpRequest();
    requestRegister.open("GET", firebaseURL, true);

    requestRegister.onreadystatechange = function ()
    {
        if (requestRegister.readyState === XMLHttpRequest.DONE) // request done
        {
            if (requestRegister.status === 200)
            {
                var postRequest = new XMLHttpRequest();
                postRequest.open("PUT", firebaseURL, true);
                postRequest.setRequestHeader("Content-Type", "application/json");

                var userData =
                {
                    email: email,
                    password: hashedPassword
                };

                postRequest.onreadystatechange = function ()
                {
                    if (postRequest.readyState === XMLHttpRequest.DONE)
                    {
                        if (postRequest.status === 200 || postRequest.status === 201)
                        {
                            console.log("Dữ liệu người dùng đã được lưu vào Firebase");
                            registrationConditionsMet = true;
                            registrationSuccessSignal();
                        }
                        else
                        {
                            console.error("Lỗi khi lưu dữ liệu người dùng vào Firebase:", postRequest.responseText);
                        }
                    }
                };
                postRequest.send(JSON.stringify(userData));
            }
            else
            {
                console.error("Lỗi khi kiểm tra dữ liệu người dùng từ Firebase:", requestRegister.responseText);
            }
        }
    };
    requestRegister.send();
}

function validateLogin(email, password, errorLogin, errorTimer)
{
    var hashedPassword = CryptoJS.SHA256(password).toString(); // pass User đăng nhập
    console.log(hashedPassword);

    var firebaseURL = "https://databaseapp-c992e-default-rtdb.firebaseio.com/.json?orderBy=\"email\"&equalTo=\"" + email + "\"";

    var requestLogin = new XMLHttpRequest();
    requestLogin.open("GET", firebaseURL, true);

    requestLogin.onreadystatechange = function ()
    {
        if (requestLogin.readyState === XMLHttpRequest.DONE)
        {
            if (requestLogin.status === 200)
            {
                var userData = JSON.parse(requestLogin.responseText);

                if (userData)
                {
                    // Duyệt qua dữ liệu để tìm email và kiểm tra password
                    var userFound = false;
                    var username = '';

                    for (var key in userData)
                    {
                        if (userData.hasOwnProperty(key) && userData[key].password === hashedPassword)
                        {
                            console.log("Đăng nhập thành công!");
                            username = key;
                            console.log("Chào mừng quay trở lại " + username + "!");
                            Qt.application.globalEmail = email;
                            Qt.application.globalUsername = username;
                            loadStackViewPage();
                            userFound = true;
                            break;
                        }
                    }
                    // Nếu không tìm thấy email hoặc password không khớp
                    if (!userFound)
                    {
                        console.log("Đăng nhập không thành công. Vui lòng kiểm tra lại thông tin.");
                        errorLogin.text = "Sai tài khoản hoặc mật khẩu!";
                        errorTimer.start();
                    }
                }
                else
                {
                    // Nếu không tìm thấy email trong cơ sở dữ liệu
                    console.log("Email không tồn tại trong cơ sở dữ liệu.");
                    errorLogin.text = "Email không tồn tại!";
                    errorTimer.start();
                }
            }
            else
            {
                console.error("Lỗi khi kiểm tra dữ liệu người dùng từ Firebase:", requestLogin.responseText);
            }
        }
    };
    requestLogin.send();
}

function loadStackViewPage() // Login thành công thì chuyển sang màn hình chính
{
    pageLoader.sourceComponent = mainPageComponent;
}

function isValidRegistration(password, rePassword)
{
    return (password === rePassword);
}

function registrationSuccessSignal() // nếu đăng ký thành công thì chuyển về lại trang Login
{
    if (registrationConditionsMet)
    {
        pageLoader.sourceComponent = loginPageComponent;
    }
}
