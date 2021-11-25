/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#include "jingoscontrolkitplugin.h"

#include <QQmlContext>
#include <QQuickItem>
#include <QQuickStyle>
#include <QGuiApplication>
#include <QClipboard>

static QString s_selectedStyle;

#ifdef JINGOSCONTRILKIT_BUILD_TYPE_STATIC
#include <qrc_jingoscontrolkit.cpp>
#endif

class CopyHelperPirvate : public QObject
{
    Q_OBJECT
    public:
        Q_INVOKABLE static void copyTextToClipboard(const QString& text)
        {
            qGuiApp->clipboard()->setText(text);
        }
};

class LanguageChangeEventFilter : public QObject
{
    Q_OBJECT
public:
    bool eventFilter(QObject *receiver, QEvent *event) override
    {
        if (event->type() == QEvent::LanguageChange && receiver == QCoreApplication::instance()) {
            emit languageChangeEvent();
        }
        return QObject::eventFilter(receiver, event);
    }

Q_SIGNALS:
    void languageChangeEvent();
};

JingOSControlKitPlugin::JingOSControlKitPlugin(QObject *parent)
{
    auto filter = new LanguageChangeEventFilter;
    filter->moveToThread(QCoreApplication::instance()->thread());
    QCoreApplication::instance()->installEventFilter(filter);
    connect(filter, &LanguageChangeEventFilter::languageChangeEvent, this, &JingOSControlKitPlugin::languageChangeEvent);
}

QUrl JingOSControlKitPlugin::componentUrl(const QString &fileName) const
{
    for (const QString &style : qAsConst(m_stylesFallbackChain)) {
        const QString candidate = QStringLiteral("styles/") + style + QLatin1Char('/') + fileName;
        if (QFile::exists(resolveFilePath(candidate))) {
#ifdef JINGOSCONTRILKIT_BUILD_TYPE_STATIC
            return QUrl(QStringLiteral("qrc:/com/jingos/controlkit.1.0/styles/")) + style + QLatin1Char('/') + fileName);
#else
            return QUrl(resolveFileUrl(candidate));
#endif
        }
    }
#ifdef JINGOSCONTRILKIT_BUILD_TYPE_STATIC
    return QUrl(QStringLiteral("qrc:/com/jingso/controlkit.1.0/") + fileName);
#else
    return QUrl(resolveFileUrl(fileName));
#endif
}


void JingOSControlKitPlugin::registerTypes(const char *uri)
{
    qmlRegisterType(componentUrl(QStringLiteral("Button.qml")), uri, 1, 0, "Button");
    qmlRegisterType(componentUrl(QStringLiteral("Label.qml")), uri, 1, 0, "Button");
}

void JingOSControlKitPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    Q_UNUSED(uri);
    connect(this, &JingOSControlKitPlugin::languageChangeEvent, engine, &QQmlEngine::retranslate);
}

#include "jingoscontrolkitplugin.moc"
