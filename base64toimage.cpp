#include "base64toimage.h"
#include <QByteArray>
#include <QBuffer>
#include <QImage>
#include <QPixmap>
#include <QUrl>
#include <QDebug>

Base64ToImage::Base64ToImage(QObject *parent) : QObject(parent)
{

}

QUrl Base64ToImage::base64ToImageUrl(const QString &base64String)
{
    // Chuyển chuỗi base64 thành mảng byte
    QByteArray imageData = QByteArray::fromBase64(base64String.toUtf8());

    // Tạo QImage từ mảng byte
    QImage image;
    if (!image.loadFromData(imageData)) {
        qWarning() << "Failed to load image from data";
        return QUrl();
    }

    // Save image to buffer and get the URL
    return saveImageToBuffer(image);
}

QUrl Base64ToImage::saveImageToBuffer(const QImage &image)
{
    QPixmap pixmap = QPixmap::fromImage(image);

    // Tạo bộ đệm để lưu trữ dữ liệu hình ảnh
    QBuffer buffer;
    buffer.open(QIODevice::ReadWrite);
    if (!pixmap.save(&buffer, "PNG"))
    {
        qWarning() << "Failed to save pixmap to buffer";
        return QUrl();
    }

    // Lấy dữ liệu từ bộ đệm và tạo URL
    QByteArray imageBytes = buffer.data();
    QString imageUrl = "data:image/png;base64," + imageBytes.toBase64();

    return QUrl(imageUrl);
}
