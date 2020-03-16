/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "shadowedrectanglenode.h"
#include "shadowedrectanglematerial.h"
#include "shadowedborderrectanglematerial.h"

QColor premultiply(const QColor &color)
{
    return QColor::fromRgbF(
        color.redF() * color.alphaF(),
        color.greenF() * color.alphaF(),
        color.blueF() * color.alphaF(),
        color.alphaF()
    );
}

ShadowedRectangleNode::ShadowedRectangleNode()
{
    m_geometry = new QSGGeometry{QSGGeometry::defaultAttributes_TexturedPoint2D(), 4};
    setGeometry(m_geometry);

    m_material = new ShadowedRectangleMaterial{};
    setMaterial(m_material);

    setFlags(QSGNode::OwnsGeometry | QSGNode::OwnsMaterial);
}

void ShadowedRectangleNode::setBorderEnabled(bool enabled)
{
    // We can achieve more performant shaders by splitting the two into separate
    // shaders. This requires separating the materials as well. So when
    // borderWidth is increased to something where the border should be visible,
    // switch to the with-border material. Otherwise use the no-border version.

    if (enabled) {
        if (m_material->type() == &ShadowedRectangleMaterial::staticType) {
            auto newMaterial = new ShadowedBorderRectangleMaterial();
            setMaterial(newMaterial);
            m_material = newMaterial;
            m_rect = QRectF{};
            markDirty(QSGNode::DirtyMaterial);
        }
    } else {
        if (m_material->type() == &ShadowedBorderRectangleMaterial::staticType) {
            auto newMaterial = new ShadowedRectangleMaterial();
            setMaterial(newMaterial);
            m_material = newMaterial;
            m_material->aspect = m_aspect;
            m_rect = QRectF{};
            markDirty(QSGNode::DirtyMaterial);
        }
    }
}

void ShadowedRectangleNode::setRect(const QRectF& rect)
{
    if (rect == m_rect) {
        return;
    }

    m_rect = rect;

    QVector2D newAspect{1.0, 1.0};
    if (m_rect.width() >= m_rect.height()) {
        newAspect.setX(m_rect.width() / m_rect.height());
    } else {
        newAspect.setY(m_rect.height() / m_rect.width());
    }

    if (m_material->aspect != newAspect) {
        m_material->aspect = newAspect;
        markDirty(QSGNode::DirtyMaterial);
        m_aspect = newAspect;
    }
}

void ShadowedRectangleNode::setSize(qreal size)
{
    auto minDimension = std::min(m_rect.width(), m_rect.height());
    float uniformSize = (size / minDimension) * 2.0;

    if (!qFuzzyCompare(m_material->size, uniformSize)) {
        m_material->size = uniformSize;
        markDirty(QSGNode::DirtyMaterial);
        m_size = size;
    }
}

void ShadowedRectangleNode::setRadius(qreal radius)
{
    auto minDimension = std::min(m_rect.width(), m_rect.height());
    float uniformRadius = radius * 2.0 / minDimension;

    if (!qFuzzyCompare(m_material->radius, uniformRadius)) {
        m_material->radius = std::min(uniformRadius, 1.0f);
        markDirty(QSGNode::DirtyMaterial);
        m_radius = radius;
    }
}

void ShadowedRectangleNode::setColor(const QColor &color)
{
    auto premultiplied = premultiply(color);
    if (m_material->color != premultiplied) {
        m_material->color = premultiplied;
        markDirty(QSGNode::DirtyMaterial);
    }
}

void ShadowedRectangleNode::setShadowColor(const QColor& color)
{
    auto premultiplied = premultiply(color);
    if (m_material->shadowColor != premultiplied) {
        m_material->shadowColor = premultiplied;
        markDirty(QSGNode::DirtyMaterial);
    }
}

void ShadowedRectangleNode::setOffset(const QVector2D& offset)
{
    auto minDimension = std::min(m_rect.width(), m_rect.height());
    auto uniformOffset = offset / minDimension;

    if (m_material->offset != uniformOffset) {
        m_material->offset = uniformOffset;
        markDirty(QSGNode::DirtyMaterial);
        m_offset = offset;
    }
}

void ShadowedRectangleNode::setBorderWidth(qreal width)
{
    if (m_material->type() != &ShadowedBorderRectangleMaterial::staticType) {
        return;
    }

    auto minDimension = std::min(m_rect.width(), m_rect.height());
    float uniformBorderWidth = width / minDimension;

    auto borderMaterial = static_cast<ShadowedBorderRectangleMaterial*>(m_material);
    if (!qFuzzyCompare(borderMaterial->borderWidth, uniformBorderWidth)) {
        borderMaterial->borderWidth = uniformBorderWidth;
        markDirty(QSGNode::DirtyMaterial);
        m_borderWidth = width;
    }
}

void ShadowedRectangleNode::setBorderColor(const QColor& color)
{
    if (m_material->type() != &ShadowedBorderRectangleMaterial::staticType) {
        return;
    }

    auto borderMaterial = static_cast<ShadowedBorderRectangleMaterial*>(m_material);
    auto premultiplied = premultiply(color);
    if (borderMaterial->borderColor != premultiplied) {
        borderMaterial->borderColor = premultiplied;
        markDirty(QSGNode::DirtyMaterial);
    }
}

void ShadowedRectangleNode::updateGeometry()
{
    auto rect = m_rect.adjusted(-m_size * m_aspect.x(), -m_size * m_aspect.y(),
                                m_size * m_aspect.x(), m_size * m_aspect.y());

    auto offsetLength = m_offset.length();

    rect = rect.adjusted(-offsetLength * m_aspect.x(), -offsetLength * m_aspect.y(),
                         offsetLength * m_aspect.x(), offsetLength * m_aspect.y());

    QSGGeometry::updateTexturedRectGeometry(m_geometry, rect, QRectF{0.0, 0.0, 1.0, 1.0});
    markDirty(QSGNode::DirtyGeometry);
}
