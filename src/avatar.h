// SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
//
// SPDX-License-Identifier: LGPL-2.0-or-later

#pragma once

#include <QObject>
#include <QColor>
#include <QVariant>

class NameUtils : public QObject {
    Q_OBJECT

public:
    Q_INVOKABLE QString initialsFromString(const QString& name);
    Q_INVOKABLE QColor colorsFromString(const QString& name);
    Q_INVOKABLE bool isStringUnsuitableForInitials(const QString& name);
};

class AvatarGroup : public QObject {
    Q_OBJECT

public:
    Q_PROPERTY(QVariant main MEMBER mainAction NOTIFY mainActionChanged)
    QVariant mainAction;
    Q_SIGNAL void mainActionChanged();

    Q_PROPERTY(QVariant secondary MEMBER secondaryAction NOTIFY secondaryActionChanged)
    QVariant secondaryAction;
    Q_SIGNAL void secondaryActionChanged();
};
