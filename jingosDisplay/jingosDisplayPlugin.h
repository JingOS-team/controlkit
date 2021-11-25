/*
 *  SPDX-FileCopyrightText: 2009 Alan Alpert <alan.alpert@nokia.com>
 *  SPDX-FileCopyrightText: 2010 Ménard Alexis <menard@kde.org>
 *  SPDX-FileCopyrightText: 2010 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Lele Huan <huanlele@jingos.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef JINGOSDISPLAYPLUGIN_H 
#define JINGOSDISPLAYPLUGIN_H

#include <QUrl>
#include <QQmlExtensionPlugin>

class JingosDisplayPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    JingosDisplayPlugin(QObject *parent = nullptr);
    virtual ~JingosDisplayPlugin();
    void registerTypes(const char *uri) override;
    void initializeEngine(QQmlEngine *engine, const char *uri) override;
};

#endif
