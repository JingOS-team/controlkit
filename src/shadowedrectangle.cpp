/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "shadowedrectangle.h"

#include <QQuickWindow>
#include <QSGRendererInterface>
#include <QSGRectangleNode>

#include "scenegraph/shadowedrectanglenode.h"
#include "scenegraph/paintedrectangleitem.h"

BorderGroup::BorderGroup(QObject* parent)
    : QObject(parent)
{
}

qreal BorderGroup::width() const
{
    return m_width;
}

void BorderGroup::setWidth(qreal newWidth)
{
    if (newWidth == m_width) {
        return;
    }

    m_width = newWidth;
    Q_EMIT changed();
}

QColor BorderGroup::color() const
{
    return m_color;
}

void BorderGroup::setColor(const QColor & newColor)
{
    if (newColor == m_color) {
        return;
    }

    m_color = newColor;
    Q_EMIT changed();
}

ShadowGroup::ShadowGroup(QObject *parent)
    : QObject(parent)
{
}

qreal ShadowGroup::size() const
{
    return m_size;
}

void ShadowGroup::setSize(qreal newSize)
{
    if (newSize == m_size) {
        return;
    }

    m_size = newSize;
    Q_EMIT changed();
}

qreal ShadowGroup::xOffset() const
{
    return m_xOffset;
}

void ShadowGroup::setXOffset(qreal newXOffset)
{
    if (newXOffset == m_xOffset) {
        return;
    }

    m_xOffset = newXOffset;
    Q_EMIT changed();
}

qreal ShadowGroup::yOffset() const
{
    return m_yOffset;
}

void ShadowGroup::setYOffset(qreal newYOffset)
{
    if (newYOffset == m_yOffset) {
        return;
    }

    m_yOffset = newYOffset;
    Q_EMIT changed();
}

QColor ShadowGroup::color() const
{
    return m_color;
}

void ShadowGroup::setColor(const QColor & newColor)
{
    if (newColor == m_color) {
        return;
    }

    m_color = newColor;
    Q_EMIT changed();
}

ShadowedRectangle::ShadowedRectangle(QQuickItem *parentItem)
    : QQuickItem(parentItem), m_border(new BorderGroup), m_shadow(new ShadowGroup)
{
    setFlag(QQuickItem::ItemHasContents, true);

    connect(m_border.get(), &BorderGroup::changed, this, &ShadowedRectangle::update);
    connect(m_shadow.get(), &ShadowGroup::changed, this, &ShadowedRectangle::update);
}

ShadowedRectangle::~ShadowedRectangle()
{
}

BorderGroup *ShadowedRectangle::border() const
{
    return m_border.get();
}

ShadowGroup *ShadowedRectangle::shadow() const
{
    return m_shadow.get();
}

qreal ShadowedRectangle::radius() const
{
    return m_radius;
}

void ShadowedRectangle::setRadius(qreal newRadius)
{
    if (newRadius == m_radius) {
        return;
    }

    m_radius = newRadius;
    update();
    Q_EMIT radiusChanged();
}

QColor ShadowedRectangle::color() const
{
    return m_color;
}

void ShadowedRectangle::setColor(const QColor & newColor)
{
    if (newColor == m_color) {
        return;
    }

    m_color = newColor;
    update();
    Q_EMIT colorChanged();
}

void ShadowedRectangle::componentComplete()
{
    QQuickItem::componentComplete();

    checkSoftwareItem();
}

void ShadowedRectangle::checkSoftwareItem()
{
    if (!m_softwareItem && window() && window()->rendererInterface()->graphicsApi() == QSGRendererInterface::Software) {
        m_softwareItem = new PaintedRectangleItem{this};

        auto updateItem = [this]() {
            auto borderWidth = m_border->width();
            auto rect = boundingRect().adjusted(-borderWidth / 2, -borderWidth / 2, borderWidth / 2, borderWidth / 2);
            m_softwareItem->setX(-borderWidth / 2);
            m_softwareItem->setY(-borderWidth / 2);
            m_softwareItem->setSize(rect.size());
            m_softwareItem->setColor(m_color);
            m_softwareItem->setRadius(m_radius);
            m_softwareItem->setBorderWidth(borderWidth);
            m_softwareItem->setBorderColor(m_border->color());
        };

        updateItem();

        connect(this, &ShadowedRectangle::widthChanged, m_softwareItem, updateItem);
        connect(this, &ShadowedRectangle::heightChanged, m_softwareItem, updateItem);
        connect(this, &ShadowedRectangle::colorChanged, m_softwareItem, updateItem);
        connect(this, &ShadowedRectangle::radiusChanged, m_softwareItem, updateItem);
        connect(m_border.get(), &BorderGroup::changed, m_softwareItem, updateItem);
        setFlag(QQuickItem::ItemHasContents, false);
    }
}

void ShadowedRectangle::itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value)
{
    if (change == QQuickItem::ItemSceneChange && value.window) {
        checkSoftwareItem();
    }
}

QSGNode *ShadowedRectangle::updatePaintNode(QSGNode *node, QQuickItem::UpdatePaintNodeData *data)
{
    Q_UNUSED(data);

    if (!node) {
        node = new ShadowedRectangleNode;
    }

    auto elevatedNode = static_cast<ShadowedRectangleNode*>(node);
    elevatedNode->setBorderEnabled(!qFuzzyIsNull(m_border->width()));
    elevatedNode->setRect(boundingRect());
    elevatedNode->setSize(m_shadow->size());
    elevatedNode->setRadius(m_radius);
    elevatedNode->setOffset(QVector2D{float(m_shadow->xOffset()), float(m_shadow->yOffset())});
    elevatedNode->setColor(m_color);
    elevatedNode->setShadowColor(m_shadow->color());
    elevatedNode->setBorderWidth(m_border->width());
    elevatedNode->setBorderColor(m_border->color());
    elevatedNode->updateGeometry();

    return elevatedNode;
}
