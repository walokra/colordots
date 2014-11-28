#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QScopedPointer>
#include <QQuickView>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QQmlContext>
#include <QtQml>

#include <sailfishapp.h>

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    app->setApplicationName("Colordots");
    app->setOrganizationName("harbour-colordots");
    app->setApplicationVersion(APP_VERSION);

    view->setSource(SailfishApp::pathTo("qml/main.qml"));
    view->rootContext()->setContextProperty("APP_VERSION", APP_VERSION);
    view->rootContext()->setContextProperty("APP_RELEASE", APP_RELEASE);

    view->show();

    return app->exec();

}
