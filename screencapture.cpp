#include "screencapture.h"
#include <QGuiApplication>
#include <QScreen>
#include <QRect>
#include <QDebug>

ScreenCapture::ScreenCapture(QObject *parent) : QObject(parent) {}

void ScreenCapture::captureScreen(const QString &imagePath, QQuickItem *videoOutput)
{
    if (!videoOutput) return;

    QQuickWindow *window = videoOutput->window();
    if (!window) return;

    // Lấy tọa độ và kích thước của VideoOutput trong không gian của Scene
    QRectF rect = videoOutput->mapRectToScene(videoOutput->boundingRect());

    // Chuyển đổi từ tọa độ Scene sang tọa độ toàn cục (global coordinates)
    QPointF topLeft = window->mapToGlobal(rect.topLeft().toPoint());
    QPointF bottomRight = window->mapToGlobal(rect.bottomRight().toPoint());

    // Chuyển đổi từ QPointF sang QPoint và từ QRectF sang QRect
    QRect rectToGrab(QPoint(topLeft.x(), topLeft.y()), QPoint(bottomRight.x(), bottomRight.y()));

    // In ra tọa độ và kích thước để kiểm tra
    qDebug() << "Global X:" << rectToGrab.x() << " Global Y:" << rectToGrab.y();
    qDebug() << "Global Width:" << rectToGrab.width() << " Global Height:" << rectToGrab.height();

    // Kiểm tra xem tọa độ và kích thước có hợp lệ không
    if (rectToGrab.isEmpty()) {
        qDebug() << "Error: rectToGrab is empty.";
        return;
    }

    // Chụp ảnh từ cửa sổ với tọa độ và kích thước đã lấy
    QPixmap pixmap = window->screen()->grabWindow(
        window->winId(),
        rectToGrab.x(),
        rectToGrab.y(),
        rectToGrab.width(),
        rectToGrab.height()
        );

    // Lưu ảnh
    pixmap.save(imagePath);
}
