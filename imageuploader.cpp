#include "imageuploader.h"
#include <QCoreApplication>
#include <QDebug>
#include <QHttpMultiPart>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariant>
#include <QJsonArray>
#include <QHttpPart>
#include <QUrl>
#include <QUrlQuery>


ImageUploader::ImageUploader(QObject *parent) : QObject(parent) // constructor tạo ra 1 object để quản lý các request mạng
{
    networkManager = new QNetworkAccessManager(this);
}

void ImageUploader::uploadImage(const QString &imageUrl, const QString &adName)
{
    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType); // tạo 1 object để xây dựng data theo form multipart/form-data

    // Send Image
    QHttpPart imagePart;
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("multipart/form-data"));

    qDebug() << "Image URL:" << imageUrl;

    // Tách tên file từ imageUrl
    QString fileName = QFileInfo(imageUrl).fileName();

    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"file\"; filename=\"" + fileName + "\""));

    QFile *file = new QFile(imageUrl);

    // Check file tồn tại
    if (!file->exists())
    {
        qWarning() << "File does not exist:" << imageUrl;
        return;
    }

    //Check mở folder
    if (!file->open(QIODevice::ReadOnly))
    {
        qWarning() << "Failed to open file:" << file->errorString();
        return;
    }

    imagePart.setBodyDevice(file);
    file->setParent(multiPart); // quản lý vòng đời
    multiPart->append(imagePart);

    // Send adName
    QHttpPart adNamePart;
    adNamePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"ad_name\""));
    adNamePart.setBody(adName.toUtf8());
    multiPart->append(adNamePart);

    QUrl url("http://103.20.97.112:8000/upload-image/");
    QNetworkRequest request(url);

    // Check response from request
    QNetworkReply *reply = networkManager->post(request, multiPart);

    connect(reply, &QNetworkReply::finished, this, [this, reply, multiPart, file, imageUrl]()
    {
        replyUploadImage(reply);
        file->close();
        multiPart->deleteLater();
        reply->deleteLater();
    });
}

void ImageUploader::replyUploadImage(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError)
    {
        qDebug() << "Upload Image Successful!";
        QByteArray responseData = reply->readAll();
        qDebug() << "Response:" << responseData;
        qDebug() << "HTTP status code: " << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

        // Convert QByteArray to QString
        QString jsonString = QString(responseData);

        // Remove outer quotes if they exist
        if (jsonString.startsWith("\"") && jsonString.endsWith("\""))
        {
            jsonString = jsonString.mid(1, jsonString.size() - 2);
        }

        // Replace escaped quotes
        jsonString = jsonString.replace("\\\"", "\"");

        // Parse the JSON string
        QJsonDocument doc = QJsonDocument::fromJson(jsonString.toUtf8());
        if (!doc.isNull() && doc.isObject())
        {
            QVariantList jsonDataList;
            QJsonObject jsonObject = doc.object();

            for (auto it = jsonObject.begin(); it != jsonObject.end(); ++it)
            {
                QVariantMap item;
                QString key = it.key();
                QString value = it.value().toString();

                item["name"] = key;
                qDebug() << "Ten thuoc: " << item["name"];
                item["value"] = value;
                qDebug() << "Gia tri: " << item["value"];

                jsonDataList.append(item);
            }
            emit jsonDataParsed(jsonDataList, "uploadImage");
        }
        else
        {
            qDebug() << "Failed to parse JSON response.";
        }
    }
    else
    {
        qDebug() << "Error to Upload Image: " << reply->errorString();
        qDebug() << "Detailed error: " << reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toString();
        qDebug() << "HTTP status code: " << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    }
}


void ImageUploader::saveResult(const QString &imageUrl, const QString &adName, const QString &specific, const QString &jsonString)
{
    qDebug() << "JSON string file: " << jsonString;

    QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    // Send Image
    QHttpPart imagePart;
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("multipart/form-data"));

    qDebug() << "Image URL:" << imageUrl;

    QString fileName = QFileInfo(imageUrl).fileName();
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"file\"; filename=\"" + fileName + "\""));

    QFile *file = new QFile(imageUrl);

    if (!file->exists())
    {
        qWarning() << "File does not exist:" << imageUrl;
        return;
    }

    if (!file->open(QIODevice::ReadOnly))
    {
        qWarning() << "Failed to open file:" << file->errorString();
        return;
    }

    imagePart.setBodyDevice(file);
    file->setParent(multiPart);
    multiPart->append(imagePart);

    // Send adName
    QHttpPart adNamePart;
    adNamePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"ad_name\""));
    adNamePart.setBody(adName.toUtf8());
    multiPart->append(adNamePart);

    // Send specific
    QHttpPart specificPart;
    specificPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"specific\""));
    specificPart.setBody(specific.toUtf8());
    multiPart->append(specificPart);

    // Send Json
    QHttpPart jsonPart;
    jsonPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"result_js\""));
    jsonPart.setBody(jsonString.toUtf8());
    multiPart->append(jsonPart);

    QUrl url("http://103.20.97.112:8000/save-result/");
    QNetworkRequest request(url);

    QNetworkReply *reply = networkManager->post(request, multiPart);

    connect(reply, &QNetworkReply::finished, this, [this, reply, multiPart, file, imageUrl]()
    {
        replySaveResult(reply);
        file->close();
        multiPart->deleteLater();
        reply->deleteLater();
    });
}

void ImageUploader::replySaveResult(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError)
    {
        qDebug() << "Save Result to Database Successful!";
        QByteArray responseData = reply->readAll();
        qDebug() << "Response:" << responseData;
        qDebug() << "HTTP status code: " << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    }
    else
    {
        qDebug() << "Error to Save Result: " << reply->errorString();
        qDebug() << "Detailed error: " << reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toString();
        qDebug() << "HTTP status code: " << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    }
}

void ImageUploader::getTotal(const QString &adName)
{
    QUrl url("http://103.20.97.112:8000/get-total/");
    QUrlQuery query;
    query.addQueryItem("ad_name", adName);
    url.setQuery(query);

    QNetworkRequest request(url);

    qDebug() << "Lấy Total từ URL: " << url.toString();

    QNetworkReply *reply = networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]()
    {
        replyGetTotal(reply);
        reply->deleteLater();
    });
}

void ImageUploader::replyGetTotal(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError)
    {
        qDebug() << "Get Total Successful!";
        QByteArray responseData = reply->readAll();
        qDebug() << "Response:" << responseData;
        qDebug() << "HTTP status code: " << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

        // Parse JSON response
        QJsonDocument doc = QJsonDocument::fromJson(responseData);
        if (!doc.isNull())
        {
            if (doc.isArray())
            {
                QJsonArray jsonArray = doc.array();
                QVariantList jsonDataList;
                for (int i = 0; i < jsonArray.size(); ++i)
                {
                    QJsonObject jsonObject = jsonArray.at(i).toObject();
                    QVariantMap item;
                    item["specific"] = jsonObject.value("specific").toString();
                    item["time"] = jsonObject.value("time").toString();
                    item["day"] = jsonObject.value("day").toString();

                    qDebug() << "Specific:" << item["specific"];
                    qDebug() << "Time:" << item["time"];
                    qDebug() << "Day:" << item["day"];

                    jsonDataList.append(item);
                }
                emit jsonDataParsed(jsonDataList, "getTotal");
            } else {
                qDebug() << "Expected JSON array.";
            }
        }
        else
        {
            qDebug() << "Failed to parse JSON response.";
        }

    }
    else
    {
        qDebug() << "Error to Get Total: " << reply->errorString();
        qDebug() << "Detailed error: " << reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toString();
        qDebug() << "HTTP status code: " << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    }
}

void ImageUploader::getResult(const QString &adName, const QString &specific)
{
    QUrl url("http://103.20.97.112:8000/get-result/");
    QUrlQuery query;
    query.addQueryItem("ad_name", adName);
    query.addQueryItem("specific", specific);
    url.setQuery(query);

    QNetworkRequest request(url);

    qDebug() << "Lấy data từ URL: " << url.toString();

    QNetworkReply *reply = networkManager->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]()
    {
        replyGetResult(reply);
        reply->deleteLater();
    });
}

void ImageUploader::replyGetResult(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError)
    {
        qDebug() << "Request Successful!";
        QByteArray responseData = reply->readAll();
        qDebug() << "HTTP status code: " << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

        // Parse JSON response
        QJsonDocument doc = QJsonDocument::fromJson(responseData);
        if (!doc.isNull() && doc.isObject())
        {
            QJsonObject jsonObject = doc.object();
            QVariantList jsonDataList;

            // Extract image data
            QString base64Image = jsonObject.value("image").toString();

            QVariantMap imageItem;
            imageItem["base64image"] = base64Image;
            imageItem["type"] = "image";
            jsonDataList.append(imageItem);

            // Extract specific data
            QString specificData = jsonObject.value("specific").toString();

            QVariantMap specificItem;
            specificItem["specific"] = specificData;
            specificItem["type"] = "specific";
            jsonDataList.append(specificItem);

            // Extract prescription data
            QJsonArray presDataArray = jsonObject.value("presData").toArray();

            // Extract medicine_name and dose from presData array
            for (const QJsonValue &value : presDataArray)
            {
                if (value.isObject())
                {
                    QJsonObject obj = value.toObject();
                    QString medicineName = obj.value("medicine_name").toString();
                    QString dose = obj.value("dose").toString();

                    QVariantMap item;
                    item["medicine_name"] = medicineName;
                    qDebug() << "Value:" << item["medicine_name"];
                    item["dose"] = dose;
                    qDebug() << "Dose:" << item["dose"];
                    item["type"] = "prescription";

                    jsonDataList.append(item);
                }
            }
            emit jsonDataParsed(jsonDataList, "getResult");
        }
        else
        {
            qDebug() << "Failed to parse JSON response.";
        }
    }
    else
    {
        qDebug() << "Error in request: " << reply->errorString();
        qDebug() << "Detailed error: " << reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toString();
        qDebug() << "HTTP status code: " << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    }
}

void ImageUploader::deleteResult(const QString &adName, const QString &specific)
{
    QUrl url("http://103.20.97.112:8000/delete-result/");
    QUrlQuery query;
    query.addQueryItem("ad_name", adName);
    query.addQueryItem("specific", specific);
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    qDebug() << "Sending DELETE request to URL: " << url.toString();

    QNetworkReply *reply = networkManager->deleteResource(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply]()
    {
        replyDeleteResult(reply);
        reply->deleteLater();
    });
}

void ImageUploader::replyDeleteResult(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError)
    {
        qDebug() << "Delete Result from Database Successful!";
        QByteArray responseData = reply->readAll();
        qDebug() << "Response:" << responseData;
        qDebug() << "HTTP status code: " << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    }
    else
    {
        qDebug() << "Error to Delete Result: " << reply->errorString();
        qDebug() << "Detailed error: " << reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toString();
        qDebug() << "HTTP status code: " << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    }
}

void ImageUploader::updateResult(const QString &adName, const QString &specific, const QString &jsonString, const QString &specific_new)
{
    QJsonObject json;
    json["ad_name"] = adName;
    json["result_js"] = jsonString;
    json["specific"] = specific;
    json["specificN"] = specific_new;

    QJsonDocument doc(json);
    QByteArray data = doc.toJson();

    QUrl url("http://103.20.97.112:8000/update-result/");
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    QNetworkReply *reply = networkManager->put(request, data);

    connect(reply, &QNetworkReply::finished, this, [this, reply]()
            {
                replyUpdateResult(reply);
                reply->deleteLater();
            });
}

void ImageUploader::replyUpdateResult(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError)
    {
        qDebug() << "Update Result to Database Successful!";
        QByteArray responseData = reply->readAll();
        qDebug() << "Response:" << responseData;
        qDebug() << "HTTP status code: " << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    }
    else
    {
        qDebug() << "Error to Update Result: " << reply->errorString();
        qDebug() << "Detailed error: " << reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toString();
        qDebug() << "HTTP status code: " << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    }
}

void ImageUploader::setFilePermissions(const QString &filePath)
{
    QFile file(filePath);

    if (file.exists())
    {
        QFileInfo fileInfo(file);
        QFile::Permissions permissions = fileInfo.permissions();

        // Set your desired permissions here
        permissions |= QFile::ReadOwner | QFile::WriteOwner | QFile::ReadGroup | QFile::ReadOther;

        // Set the permissions for the file
        if (!file.setPermissions(permissions))
        {
            qWarning() << "Failed to set permissions for the file:" << file.errorString();
        }
    }
    else
    {
        qWarning() << "File does not exist:" << filePath;
    }
}
