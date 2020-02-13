/*
 *  SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <QIcon>
#include <QQuickItem>
#include <QVariant>
#include <QPointer>

class QNetworkAccessManager;
class QNetworkReply;

namespace Kirigami {
    class PlatformTheme;
}

class Icon : public QQuickItem
{
    Q_OBJECT

    Q_PROPERTY(QVariant source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(bool smooth READ smooth WRITE setSmooth NOTIFY smoothChanged)
    Q_PROPERTY(int implicitWidth READ implicitWidth CONSTANT)
    Q_PROPERTY(int implicitHeight READ implicitHeight CONSTANT)
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)
    Q_PROPERTY(bool valid READ valid NOTIFY validChanged)
    Q_PROPERTY(bool selected READ selected WRITE setSelected NOTIFY selectedChanged)
    Q_PROPERTY(bool isMask READ isMask WRITE setIsMask NOTIFY isMaskChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(QString fallback READ fallback WRITE setFallback NOTIFY fallbackChanged)

public:
    Icon(QQuickItem *parent = nullptr);
    ~Icon();

    void setSource(const QVariant &source);
    QVariant source() const;

    int implicitWidth() const;
    int implicitHeight() const;

    void setSmooth(const bool smooth);
    bool smooth() const;

    void setActive(bool active = true);
    bool active() const;

    bool valid() const;

    void setSelected(bool selected = true);
    bool selected() const;

    void setIsMask(bool mask);
    bool isMask() const;

    void setColor(const QColor &color);
    QColor color() const;

    QString fallback() const;
    void setFallback(const QString &fallback);

    QSGNode* updatePaintNode(QSGNode* node, UpdatePaintNodeData* data) override;

Q_SIGNALS:
    void sourceChanged();
    void smoothChanged();
    void enabledChanged();
    void activeChanged();
    void validChanged();
    void selectedChanged();
    void isMaskChanged();
    void colorChanged();
    void fallbackChanged(const QString &fallback);

protected:
    void geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry) override;
    QImage findIcon(const QSize& size);
    void handleFinished(QNetworkReply* reply);
    void handleRedirect(QNetworkReply* reply);
    QIcon::Mode iconMode() const;
    bool guessMonochrome(const QImage &img);
    void updatePolish() override;

private:
    Kirigami::PlatformTheme *m_theme = nullptr;
    QPointer<QNetworkReply> m_networkReply;
    QHash<int, bool> m_monochromeHeuristics;
    QVariant m_source;
    bool m_smooth;
    bool m_changed;
    bool m_active;
    bool m_selected;
    bool m_isMask;
    bool m_isMaskHeuristic = false;
    QImage m_loadedImage;
    QColor m_color = Qt::transparent;
    QString m_fallback = QStringLiteral("unknown");

    QImage m_icon;
};

