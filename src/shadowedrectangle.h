/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#pragma once

#include <memory>
#include <QQuickItem>

class PaintedRectangleItem;

/**
 * Grouped property for rectangle border.
 */
class BorderGroup : public QObject
{
    Q_OBJECT
    /**
     * The width of the border in pixels.
     *
     * Default is 0.
     */
    Q_PROPERTY(qreal width READ width WRITE setWidth NOTIFY changed)
    /**
     * The color of the border.
     *
     * Full RGBA colors are supported. The default is fully opaque black.
     */
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY changed)

public:
    explicit BorderGroup(QObject *parent = nullptr);

    qreal width() const;
    void setWidth(qreal newWidth);

    QColor color() const;
    void setColor(const QColor &newColor);

    Q_SIGNAL void changed();

    inline bool isEnabled() const
    {
        return !qFuzzyIsNull(m_width);
    }

private:
    qreal m_width = 0.0;
    QColor m_color = Qt::black;
};

/**
 * Grouped property for rectangle shadow.
 */
class ShadowGroup : public QObject
{
    Q_OBJECT
    /**
     * The size of the shadow.
     *
     * This is the approximate size of the shadow in pixels. However, due to falloff
     * the actual shadow size can differ. The default is 0, which means no shadow will
     * be rendered.
     */
    Q_PROPERTY(qreal size READ size WRITE setSize NOTIFY changed)
    /**
     * Offset of the shadow on the X axis.
     *
     * In pixels. The default is 0.
     */
    Q_PROPERTY(qreal xOffset READ xOffset WRITE setXOffset NOTIFY changed)
    /**
     * Offset of the shadow on the Y axis.
     *
     * In pixels. The default is 0.
     */
    Q_PROPERTY(qreal yOffset READ yOffset WRITE setYOffset NOTIFY changed)
    /**
     * The color of the shadow.
     *
     * Full RGBA colors are supported. The default is fully opaque black.
     */
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY changed)

public:
    explicit ShadowGroup(QObject *parent = nullptr);

    qreal size() const;
    void setSize(qreal newSize);

    qreal xOffset() const;
    void setXOffset(qreal newXOffset);

    qreal yOffset() const;
    void setYOffset(qreal newYOffset);

    QColor color() const;
    void setColor(const QColor &newShadowColor);

    Q_SIGNAL void changed();

private:
    qreal m_size = 0.0;
    qreal m_xOffset = 0.0;
    qreal m_yOffset = 0.0;
    QColor m_color = Qt::black;
};

/**
 * A rectangle with a shadow.
 *
 * This item will render a rectangle, with a shadow below it. The rendering is done
 * using distance fields, which provide greatly improved performance. The shadow is
 * rendered outside of the item's bounds, so the item's width and height are the
 * rectangle's width and height.
 *
 * @since 5.69 / 2.12
 */
class ShadowedRectangle : public QQuickItem
{
    Q_OBJECT
    /**
     * Corner radius of the rectangle.
     *
     * This is the amount of rounding to apply to the rectangle's corners, in pixels.
     * The default is 0.
     */
    Q_PROPERTY(qreal radius READ radius WRITE setRadius NOTIFY radiusChanged)
    /**
     * The color of the rectangle.
     *
     * Full RGBA colors are supported. The default is fully opaque white.
     */
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    /**
     * Border properties.
     *
     * \sa BorderGroup
     */
    Q_PROPERTY(BorderGroup *border READ border CONSTANT)
    /**
     * Shadow properties.
     *
     * \sa ShadowGroup
     */
    Q_PROPERTY(ShadowGroup *shadow READ shadow CONSTANT)

public:
    ShadowedRectangle(QQuickItem *parent = nullptr);
    ~ShadowedRectangle() override;

    BorderGroup *border() const;
    ShadowGroup *shadow() const;

    qreal radius() const;
    void setRadius(qreal newRadius);
    Q_SIGNAL void radiusChanged();

    QColor color() const;
    void setColor(const QColor &newColor);
    Q_SIGNAL void colorChanged();

    void componentComplete() override;

protected:
    void itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value) override;
    QSGNode *updatePaintNode(QSGNode *node, QQuickItem::UpdatePaintNodeData *data) override;

private:
    void checkSoftwareItem();
    const std::unique_ptr<BorderGroup> m_border;
    const std::unique_ptr<ShadowGroup> m_shadow;
    qreal m_radius = 0.0;
    QColor m_color = Qt::white;
    PaintedRectangleItem *m_softwareItem = nullptr;
};
