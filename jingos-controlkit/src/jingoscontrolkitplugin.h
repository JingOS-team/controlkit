/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Rui Wang <wangrui@jingos.com>
 * Lele Huan <huanlele@jingos.com>
 *
 */

#ifndef JINGOSCONTROLKITPLUGIN_H
#define JINGOSCONTROLKITPLUGIN_H

#include <QQmlEngine>
#include <QQmlExtensionPlugin>

class JingOSControlKitPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    JingOSControlKitPlugin(QObject *parent = nullptr);
    void registerTypes(const char *uri) override;
    void initializeEngine(QQmlEngine *engine, const char *uri) override;

#ifdef JINGOSCONTRILKIT_BUILD_TYPE_STATIC
    static void registerTypes(QQmlEngine *engine = nullptr)
    {
        Q_INIT_RESOURCE(shaders);
        if (engine) {
            engine->addImportPath(QLatin1String(":/"));
        } else {
            qWarning() << "Registering JingOSControlKit on a null QQmlEngine instance - you likely want to pass a valid engine, or you will want to manually add the qrc root path :/ to your import paths list so the engine is able to load the plugin";

        }
    }
#endif

Q_SIGNALS:
    void languageChangeEvent();

private:
    QUrl componentUrl(const QString &fileName) const;
    QString resolveFilePath(const QString &path)  const
    {
#if defined(JINGOSCONTRILKIT_BUILD_TYPE_STATIC)
        return QStringLiteral(":/com/jingos/controlkit.1.0/") + path;
#else
        return baseUrl().toString() + QLatin1Char('/') + path;
#endif
    }
    QString resolveFileUrl(const QString &filePath) const
    {
#if defined(JINGOSCONTRILKIT_BUILD_TYPE_STATIC)
        return filePath;
#else
        return baseUrl().toString() + QLatin1Char('/') + filePath;
#endif
    }
    QStringList m_stylesFallbackChain;
};

#endif


