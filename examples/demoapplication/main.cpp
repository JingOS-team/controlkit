/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Rui Wang <wangrui@jingos.com>
 * Lele Huan <huanlele@jingos.com>
 *
 */

#include <QApplication>
#include <QQuickView>
#include <QtQml>
#include <QUrl>
#include <QQuickStyle>

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    const QString style = QQuickStyle::name();

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
