/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "shadowedtexture.h"

#include <QQuickWindow>
#include <QSGRendererInterface>
#include <QSGRectangleNode>

#include "scenegraph/shadowedtexturenode.h"

ShadowedTexture::ShadowedTexture(QQuickItem *parentItem)
    : ShadowedRectangle(parentItem)
{
}

ShadowedTexture::~ShadowedTexture()
{
}

QQuickItem *ShadowedTexture::source() const
{
    return m_source;
}

void ShadowedTexture::setSource(QQuickItem *newSource)
{
    if (newSource == m_source) {
        return;
    }

    m_source = newSource;
    if (!m_source->parentItem()) {
        m_source->setParentItem(this);
    }

    update();
    Q_EMIT sourceChanged();
}

QSGNode *ShadowedTexture::updatePaintNode(QSGNode *node, QQuickItem::UpdatePaintNodeData *data)
{
    Q_UNUSED(data);

    if (!node) {
        node = new ShadowedTextureNode{};
    }

    auto shadowNode = static_cast<ShadowedTextureNode*>(node);
    shadowNode->setBorderEnabled(border()->isEnabled());
    shadowNode->setRect(boundingRect());
    shadowNode->setSize(shadow()->size());
    shadowNode->setRadius(corners()->toVector4D(radius()));
    shadowNode->setOffset(QVector2D{float(shadow()->xOffset()), float(shadow()->yOffset())});
    shadowNode->setColor(color());
    shadowNode->setShadowColor(shadow()->color());
    shadowNode->setBorderWidth(border()->width());
    shadowNode->setBorderColor(border()->color());

    if (m_source) {
        shadowNode->setTextureSource(m_source->textureProvider());
    }

    shadowNode->updateGeometry();
    return shadowNode;
}

// void ShadowedTexture::checkSoftwareItem()
// {
//     if (!m_softwareItem && window() && window()->rendererInterface()->graphicsApi() == QSGRendererInterface::Software) {
//         m_softwareItem = new PaintedRectangleItem{this};
//
//         auto updateItem = [this]() {
//             auto borderWidth = m_border->width();
//             auto rect = boundingRect().adjusted(-borderWidth / 2, -borderWidth / 2, borderWidth / 2, borderWidth / 2);
//             m_softwareItem->setX(-borderWidth / 2);
//             m_softwareItem->setY(-borderWidth / 2);
//             m_softwareItem->setSize(rect.size());
//             m_softwareItem->setColor(m_color);
//             m_softwareItem->setRadius(m_radius);
//             m_softwareItem->setBorderWidth(borderWidth);
//             m_softwareItem->setBorderColor(m_border->color());
//         };
//
//         updateItem();
//
//         connect(this, &ShadowedTexture::widthChanged, m_softwareItem, updateItem);
//         connect(this, &ShadowedTexture::heightChanged, m_softwareItem, updateItem);
//         connect(this, &ShadowedRectangle::colorChanged, m_softwareItem, updateItem);
//         connect(this, &ShadowedRectangle::radiusChanged, m_softwareItem, updateItem);
//         connect(m_border.get(), &BorderGroup::changed, m_softwareItem, updateItem);
//         setFlag(QQuickItem::ItemHasContents, false);
//     }
// }
