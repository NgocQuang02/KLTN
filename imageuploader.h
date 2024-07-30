// imageuploader.h
#ifndef IMAGEUPLOADER_H
#define IMAGEUPLOADER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QVariant>
#include <QFile>
#include <QHttpMultiPart>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariantList>
#include <QAbstractListModel>

class ImageUploader : public QObject
{
    Q_OBJECT
public:
    explicit ImageUploader(QObject *parent = nullptr);
    Q_INVOKABLE void setFilePermissions(const QString &filePath);

signals:
    void jsonDataParsed(const QVariantList &data, const QString &type);

public slots:
    void uploadImage(const QString &imageUrl, const QString &adName);
    void replyUploadImage(QNetworkReply *reply); // JSON file

    void saveResult(const QString &imageUrl, const QString &adName, const QString &specific, const QString &jsonString); // them String
    void replySaveResult(QNetworkReply *reply); // status_code

    void getTotal(const QString &adName);
    void replyGetTotal(QNetworkReply *reply); // JSON file

    void getResult(const QString &adName, const QString &specific);
    void replyGetResult(QNetworkReply *reply); // JSON file

    void deleteResult(const QString &adName, const QString &specific);
    void replyDeleteResult(QNetworkReply *reply); // status_code

    void updateResult(const QString &adName, const QString &specific, const QString &jsonString, const QString &specific_name);
    void replyUpdateResult(QNetworkReply *reply); // status code

    void setJsonData(const QJsonDocument &jsonDoc)
    {
        m_jsonData = jsonDoc;
    }
    QJsonDocument getJsonData() const {
        return m_jsonData;
    }

private:
    QNetworkAccessManager *networkManager;
    QJsonDocument m_jsonData;
};


#endif
