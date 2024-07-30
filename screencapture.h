#ifndef SCREENCAPTURE_H
#define SCREENCAPTURE_H

#include <QObject>
#include <QQuickItem>
#include <QPixmap>
#include <QQuickWindow>

class ScreenCapture : public QObject
{
    Q_OBJECT
public:
    explicit ScreenCapture(QObject *parent = nullptr);
    Q_INVOKABLE void captureScreen(const QString &imagePath, QQuickItem *videoOutput);

signals:

};

#endif // SCREENCAPTURE_H
