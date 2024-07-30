#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QLabel>
#include "imageuploader.h"
#include "datasearch.h"
#include "base64toimage.h"
#include "imageinfo.h"
#include <QNetworkAccessManager>
#include <QScreen>
#include <QPixmap>
#include <QQuickItem>
#include <QQuickWindow>
#include <QtMultimedia>
#include <QtMultimediaWidgets>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    ImageUploader imageUploader;
    DataSearch dataSearch;
    Base64ToImage base64Converter;
    ImageInfo imageInfo;

    QNetworkAccessManager manager;
    QQmlApplicationEngine engine;

    qputenv("QML_XHR_ALLOW_FILE_READ", QByteArray("1"));

    qmlRegisterType<DataSearch>("DisplayData", 1, 0, "DataSearch");

    engine.rootContext()->setContextProperty("imageUploader", &imageUploader);
    engine.rootContext()->setContextProperty("dataSearch", &dataSearch);
    engine.rootContext()->setContextProperty("base64Converter", &base64Converter);
    engine.rootContext()->setContextProperty("imageInfo", &imageInfo);

    QObject::connect(&manager, &QNetworkAccessManager::finished, &imageUploader, &ImageUploader::replyUploadImage);

    const QUrl url(QStringLiteral("qrc:/QML_RESOURCES/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
