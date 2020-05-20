#pragma once

#include <QObject>
#include <QColor>

class AvatarPrivate : public QObject {
    Q_OBJECT

public:
    Q_INVOKABLE QString initialsFromString(const QString& name);
    Q_INVOKABLE QColor colorsFromString(const QString& name);
    Q_INVOKABLE bool stringHasNonLatinCharacters(const QString& name);
};
