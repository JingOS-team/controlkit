/*
 *  SPDX-FileCopyrightText: 2009 Alan Alpert <alan.alpert@nokia.com>
 *  SPDX-FileCopyrightText: 2010 Ménard Alexis <menard@kde.org>
 *  SPDX-FileCopyrightText: 2010 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Rui Wang <wangrui@jingos.com>
 *  SPDX-FileCopyrightText: 2021 Lele Huan <huanlele@jingos.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "jingosDisplayPlugin.h"
#include "jdisplaymetrics.h"

#include <QDebug>
#include <QUrl>
#include <QQmlContext>
#include <QQuickItem>
#include <QQmlEngine>

JingosDisplayPlugin::JingosDisplayPlugin(QObject *parent)
    : QQmlExtensionPlugin(parent)
{
}

JingosDisplayPlugin::~JingosDisplayPlugin()
{

}

void JingosDisplayPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("jingos.display"));

    qmlRegisterSingletonType<JDisplayMetrics>(uri, 1, 0, "JDisplayMetrics", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return static_cast<QObject *>(new JDisplayMetrics);
    });

    QUrl url(baseUrl().toString() + QLatin1Char('/') + QStringLiteral("JDisplay.qml"));
    qmlRegisterSingletonType(url, uri, 1, 0, "JDisplay");

}

void JingosDisplayPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    Q_UNUSED(engine);
    Q_UNUSED(uri);
}
