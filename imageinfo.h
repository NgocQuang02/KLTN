#ifndef IMAGEINFO_H
#define IMAGEINFO_H

#include <QObject>
#include <QString>
#include <QSize>

class ImageInfo : public QObject
{
    Q_OBJECT
public:
    explicit ImageInfo(QObject *parent = nullptr);
    ImageInfo(const QString& format, const QString& mode, const QSize& size,
              double brightness, double contrast, double sharpness);

    static ImageInfo fromImagePath(const QString& imagePath);
    bool compare(const ImageInfo& other) const;

    QString getFormat() const;
    QString getMode() const;
    QSize getSize() const;
    double getBrightness() const;
    double getContrast() const;
    double getSharpness() const;

public slots:
    bool checkImage(const QString& imagePath);

private:
    QString m_format;
    QString m_mode;
    QSize m_size;
    double m_brightness;
    double m_contrast;
    double m_sharpness;
};

#endif
