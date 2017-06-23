

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <QColor>

#ifdef Q_OS_ANDROID
#include <QtAndroid>

// WindowManager.LayoutParams
#define FLAG_TRANSLUCENT_STATUS 0x04000000
#define FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS 0x80000000
// View
#define SYSTEM_UI_FLAG_LIGHT_STATUS_BAR 0x00002000

#endif


Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    qputenv("QML_IMPORT_TRACE", "1");
    //FIXME
    qputenv("QT_QUICK_CONTROLS_STYLE", "Material");
    QQmlApplicationEngine engine;
    
    engine.load(QUrl(QStringLiteral("qrc:///contents/ui/ExampleApp.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    //HACK to color the system bar on Android, use qtandroidextras and call the appropriate Java methods 
#ifdef Q_OS_ANDROID
    QtAndroid::runOnAndroidThread([=]() {
        QAndroidJniObject window = QtAndroid::androidActivity().callObjectMethod("getWindow", "()Landroid/view/Window;");
        window.callMethod<void>("addFlags", "(I)V", FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        window.callMethod<void>("clearFlags", "(I)V", FLAG_TRANSLUCENT_STATUS);
        window.callMethod<void>("setStatusBarColor", "(I)V", QColor("#2196f3").rgba());
        window.callMethod<void>("setNavigationBarColor", "(I)V", QColor("#2196f3").rgba());
    });
#endif

    return app.exec();
}
