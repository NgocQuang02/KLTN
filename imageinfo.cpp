#include "imageinfo.h"
#include <opencv2/opencv.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <cmath>

ImageInfo::ImageInfo(QObject *parent)
    : QObject(parent)
{
}

ImageInfo::ImageInfo(const QString& format, const QString& mode, const QSize& size,
                     double brightness, double contrast, double sharpness)
    : m_format(format), m_mode(mode), m_size(size),
    m_brightness(brightness), m_contrast(contrast), m_sharpness(sharpness)
{
}

QString ImageInfo::getFormat() const
{
    return m_format;
}

QString ImageInfo::getMode() const
{
    return m_mode;
}

QSize ImageInfo::getSize() const
{
    return m_size;
}

double ImageInfo::getBrightness() const
{
    return m_brightness;
}

double ImageInfo::getContrast() const
{
    return m_contrast;
}

double ImageInfo::getSharpness() const
{
    return m_sharpness;
}

ImageInfo ImageInfo::fromImagePath(const QString& imagePath)
{
    cv::Mat image = cv::imread(imagePath.toStdString());

    if (image.empty())
    {
        throw std::runtime_error("Image not found or unable to open");
    }

    QString format = QString::fromStdString(cv::imwrite(imagePath.toStdString(), image) ? "JPEG" : "Unknown"); // giả sử định dạng JPEG
    QString mode = image.channels() == 3 ? "RGB" : "Unknown";
    QSize size(image.cols, image.rows);

    cv::Mat gray;
    cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);

    double brightness = cv::mean(gray)[0];

    cv::Mat hist;
    int histSize = 256;
    float range[] = {0, 256};
    const float* histRange = {range};
    cv::calcHist(&gray, 1, 0, cv::Mat(), hist, 1, &histSize, &histRange);
    double total = gray.total();
    double contrast = 0.0;
    for (int i = 0; i < histSize; i++)
    {
        double binVal = hist.at<float>(i);
        contrast += binVal * std::pow(i - brightness, 2);
    }
    contrast = std::sqrt(contrast / total);

    cv::Mat laplacian;
    cv::Laplacian(gray, laplacian, CV_64F);
    cv::Scalar mu, sigma;
    cv::meanStdDev(laplacian, mu, sigma);
    double sharpness = sigma.val[0] * sigma.val[0];

    return ImageInfo(format, mode, size, brightness, contrast, sharpness);
}

bool ImageInfo::compare(const ImageInfo& other) const
{
    return (m_size.width() < other.m_size.width() &&
            m_size.height() < other.m_size.height() &&
            m_brightness < other.m_brightness &&
            m_contrast < other.m_contrast &&
            m_sharpness < other.m_sharpness);
}

bool ImageInfo::checkImage(const QString& imagePath)
{
    ImageInfo standardInfo("JPEG", "RGB", QSize(1920, 2560),
                           123.47334228515625, 26.88525744132929, 7.548558473982768);

    ImageInfo imageInfo = ImageInfo::fromImagePath(imagePath);
    return imageInfo.compare(standardInfo);
}
