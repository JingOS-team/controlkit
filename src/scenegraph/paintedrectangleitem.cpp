/*
 * SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "paintedrectangleitem.h"

#include <QPainter>
#include <QQuickItemGrabResult>

PaintedRectangleItem::PaintedRectangleItem(QQuickItem* parent)
    : QQuickPaintedItem(parent)
{
}

void PaintedRectangleItem::setColor(const QColor& color)
{
    m_color = color;
    update();
}

void PaintedRectangleItem::setRadius(qreal radius)
{
    m_radius = radius;
    update();
}

void PaintedRectangleItem::setBorderColor(const QColor& color)
{
    m_borderColor = color;
    update();
}

void PaintedRectangleItem::setBorderWidth(qreal width)
{
    m_borderWidth = width;
    update();
}

void PaintedRectangleItem::paint(QPainter* painter)
{
    painter->setRenderHint(QPainter::Antialiasing, true);
    painter->setBrush(m_color);
    if (m_borderWidth > 0.0) {
        painter->setPen(QPen(m_borderColor, m_borderWidth));
    } else {
        painter->setPen(Qt::transparent);
    }
    const QRectF targetRect(m_borderWidth / 2, m_borderWidth / 2, width() - m_borderWidth, height() - m_borderWidth);
    painter->drawRoundedRect(targetRect, m_radius, m_radius);

    if (!m_softwareTexture.isNull()) {
        QPainter p(&m_softwareTexture);
        p.setCompositionMode(QPainter::CompositionMode_DestinationIn);
        p.setPen(QPen(Qt::transparent, m_radius));
        p.setRenderHint(QPainter::Antialiasing);
        p.setBrush(Qt::white);
        p.drawRoundedRect(targetRect.adjusted(-m_radius/2, -m_radius/2, m_radius/2, m_radius/2), m_radius*1.5, m_radius*1.5);
        p.end();
        painter->drawImage(targetRect, m_softwareTexture, m_softwareTexture.rect().intersected(targetRect.toRect()));
    }
}

void PaintedRectangleItem::updatePolish()
{
    QQuickPaintedItem::updatePolish();

    if (!m_source) {
        return;
    }

    m_grabResult = m_source->grabToImage(QSize(qRound(m_source->width()), qRound(m_source->height())));

    if (m_grabResult) {
        connect(m_grabResult.data(), &QQuickItemGrabResult::ready, this, [this]() {
            m_softwareTexture = m_grabResult->image();
            m_grabResult.clear();
            update();
        });
    }
}

void PaintedRectangleItem::setSource(QQuickItem *source)
{
    m_source = source;
    m_softwareTexture = QImage();
    polish();
}

QQuickItem *PaintedRectangleItem::source() const
{
    return m_source;
}
