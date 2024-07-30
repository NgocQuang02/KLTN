// #include "imageurl.h"

// CustomImageProvider::CustomImageProvider(Base64ToImage *converter)
//     : QQuickImageProvider(QQuickImageProvider::Pixmap), m_converter(converter)
// {
// }

// QPixmap CustomImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
// {
//     Q_UNUSED(size);

//     // Chuyển đổi Base64 thành QImage
//     QImage image = m_converter->convertBase64ToImage(id);
//     if (image.isNull()) {
//         qWarning() << "Failed to convert Base64 string to QImage";
//         return QPixmap();
//     }

//     // Resize the image to a fixed size, e.g., 100x100 pixels
//     QSize fixedSize(100, 100); // Set the desired fixed size here
//     QImage resizedImage = image.scaled(fixedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

//     // Chuyển đổi QImage thành QPixmap và trả về
//     return QPixmap::fromImage(resizedImage);
// }
