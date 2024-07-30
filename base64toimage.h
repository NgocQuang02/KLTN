#ifndef BASE64TOIMAGE_H
#define BASE64TOIMAGE_H

#include <QObject>
#include <QString>
#include <QImage>
#include <QUrl>
#include <opencv2/opencv.hpp>

class Base64ToImage : public QObject
{
    Q_OBJECT

public:
    explicit Base64ToImage(QObject *parent = nullptr);

    Q_INVOKABLE QUrl base64ToImageUrl(const QString &base64String);

private:
    QUrl saveImageToBuffer(const QImage &image);
};

#endif
