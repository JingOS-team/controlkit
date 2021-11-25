/*
 *  SPDX-FileCopyrightText: 2009 Alan Alpert <alan.alpert@nokia.com>
 *  SPDX-FileCopyrightText: 2010 Ménard Alexis <menard@kde.org>
 *  SPDX-FileCopyrightText: 2010 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Rui Wang <wangrui@jingos.com>
 *  SPDX-FileCopyrightText: 2021 Lele Huan <huanlele@jingos.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "jmultimediaModuleplugin.h"
#include "mpvobject.h"
#include "MediaDbusSet.h"
#include "player.h"
#include "jgstmediainfo.h"
#include "mpvrenderitem.h"
#include "jbasevideosurface.h"

#include <QQmlContext>
#include <QQuickItem>

JMultimediaModulePlugin::JMultimediaModulePlugin(QObject *parent)
    : QQmlExtensionPlugin(parent)
{
}

JMultimediaModulePlugin::~JMultimediaModulePlugin()
{

}

void JMultimediaModulePlugin::registerTypes(const char *uri)
{
    Q_ASSERT(QLatin1String(uri) == QLatin1String("jingos.multimedia"));

    std::setlocale(LC_NUMERIC, "C");
    qmlRegisterType<MpvObject>(uri, 1, 0, "MpvObject");
    qmlRegisterType<MpvRenderItem>(uri, 1, 0, "MpvRenderItem");
    qmlRegisterType<Player>(uri, 1, 0, "Player");
    qmlRegisterType<Mpris2>(uri, 1, 0, "Mpris2");
    qmlRegisterType<JGstMediaInfo>(uri, 1, 0, "GstMediaInfo");
    qmlRegisterType<JBaseVideoSurface>(uri, 1, 0, "JBaseVideoSurface");
}

void JMultimediaModulePlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    Q_UNUSED(engine);
    Q_UNUSED(uri);
    theMutliMediaFileImageInstance->setBaseUrl(baseUrl().toString());
    engine->addImageProvider(QLatin1String("multiMediaFileImageProvider"), theMutliMediaFileImageInstance);
}
