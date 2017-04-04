/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *   Copyright 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "desktopicon.h"

#include <QSGSimpleTextureNode>
#include <qquickwindow.h>
#include <QIcon>
#include <QBitmap>
#include <QSGTexture>
#include <QDebug>
#include <QSGSimpleTextureNode>
#include <QSGTexture>
#include <QSharedPointer>
#include <QtQml>
#include <QQuickImageProvider>
#include <QGuiApplication>

class ManagedTextureNode : public QSGSimpleTextureNode
{
Q_DISABLE_COPY(ManagedTextureNode)
public:
    ManagedTextureNode();

    void setTexture(QSharedPointer<QSGTexture> texture);

private:
    QSharedPointer<QSGTexture> m_texture;
};

ManagedTextureNode::ManagedTextureNode()
{}

void ManagedTextureNode::setTexture(QSharedPointer<QSGTexture> texture)
{
    m_texture = texture;
    QSGSimpleTextureNode::setTexture(texture.data());
}

typedef QHash<qint64, QHash<QWindow*, QWeakPointer<QSGTexture> > > TexturesCache;

struct ImageTexturesCachePrivate
{
    TexturesCache cache;
};

class ImageTexturesCache
{
public:
    ImageTexturesCache();
    ~ImageTexturesCache();

    /**
     * @returns the texture for a given @p window and @p image.
     *
     * If an @p image id is the same as one already provided before, we won't create
     * a new texture and return a shared pointer to the existing texture.
     */
    QSharedPointer<QSGTexture> loadTexture(QQuickWindow *window, const QImage &image, QQuickWindow::CreateTextureOptions options);

    QSharedPointer<QSGTexture> loadTexture(QQuickWindow *window, const QImage &image);


private:
    QScopedPointer<ImageTexturesCachePrivate> d;
};


ImageTexturesCache::ImageTexturesCache()
    : d(new ImageTexturesCachePrivate)
{
}

ImageTexturesCache::~ImageTexturesCache()
{
}

QSharedPointer<QSGTexture> ImageTexturesCache::loadTexture(QQuickWindow *window, const QImage &image, QQuickWindow::CreateTextureOptions options)
{
    qint64 id = image.cacheKey();
    QSharedPointer<QSGTexture> texture = d->cache.value(id).value(window).toStrongRef();

    if (!texture) {
        auto cleanAndDelete = [this, window, id](QSGTexture* texture) {
            QHash<QWindow*, QWeakPointer<QSGTexture> >& textures = (d->cache)[id];
            textures.remove(window);
            if (textures.isEmpty())
                d->cache.remove(id);
            delete texture;
        };
        texture = QSharedPointer<QSGTexture>(window->createTextureFromImage(image, options), cleanAndDelete);
        (d->cache)[id][window] = texture.toWeakRef();
    }

    //if we have a cache in an atlas but our request cannot use an atlassed texture
    //create a new texture and use that
    //don't use removedFromAtlas() as that requires keeping a reference to the non atlased version
    if (!(options & QQuickWindow::TextureCanUseAtlas) && texture->isAtlasTexture()) {
        texture = QSharedPointer<QSGTexture>(window->createTextureFromImage(image, options));
    }

    return texture;
}

QSharedPointer<QSGTexture> ImageTexturesCache::loadTexture(QQuickWindow *window, const QImage &image)
{
    return loadTexture(window, image, 0);
}

Q_GLOBAL_STATIC(ImageTexturesCache, s_iconImageCache)

DesktopIcon::DesktopIcon(QQuickItem *parent)
    : QQuickItem(parent),
      m_smooth(false),
      m_changed(false),
      m_active(false),
      m_selected(false)
{
    setFlag(ItemHasContents, true);
}


DesktopIcon::~DesktopIcon()
{
}

void DesktopIcon::setSource(const QVariant &icon)
{
    if (m_source == icon) {
        return;
    }
    m_source = icon;
    m_changed = true;
    update();
    emit sourceChanged();
}

QVariant DesktopIcon::source() const
{
    return m_source;
}

void DesktopIcon::setEnabled(const bool enabled)
{
    if (enabled == QQuickItem::isEnabled()) {
        return;
    }
    QQuickItem::setEnabled(enabled);
    m_changed = true;
    update();
    emit enabledChanged();
}


void DesktopIcon::setActive(const bool active)
{
    if (active == m_active) {
        return;
    }
    m_active = active;
    m_changed = true;
    update();
    emit activeChanged();
}

bool DesktopIcon::active() const
{
    return m_active;
}

bool DesktopIcon::valid() const
{
    return !m_source.isNull();
}

void DesktopIcon::setSelected(const bool selected)
{
    if (selected == m_selected) {
        return;
    }
    m_selected = selected;
    m_changed = true;
    update();
    emit selectedChanged();
}

bool DesktopIcon::selected() const
{
    return m_selected;
}

int DesktopIcon::implicitWidth() const
{
    return 32;
}

int DesktopIcon::implicitHeight() const
{
    return 32;
}

void DesktopIcon::setSmooth(const bool smooth)
{
    if (smooth == m_smooth) {
        return;
    }
    m_smooth = smooth;
    m_changed = true;
    update();
    emit smoothChanged();
}

bool DesktopIcon::smooth() const
{
    return m_smooth;
}

QSGNode* DesktopIcon::updatePaintNode(QSGNode* node, QQuickItem::UpdatePaintNodeData* /*data*/)
{
    if (m_source.isNull()) {
        delete node;
        return Q_NULLPTR;
    }

    if (m_changed || node == 0) {
        QImage img;
        const QSize size = QSize(width(), height()) * (window() ? window()->devicePixelRatio() : qApp->devicePixelRatio());

        switch(m_source.type()){
        case QVariant::Pixmap:
            img = m_source.value<QPixmap>().toImage();
            break;
        case QVariant::Image:
            img = m_source.value<QImage>();
            break;
        case QVariant::Bitmap:
            img = m_source.value<QBitmap>().toImage();
            break;
        case QVariant::Icon:
            img = m_source.value<QIcon>().pixmap(size, iconMode(), QIcon::On).toImage();
            break;
        case QVariant::String:
            img = findIcon(size);
            break;
        case QVariant::Brush:
        case QVariant::Color:
            //perhaps fill image instead?
        default:
            break;
        }

        if (img.isNull()){
            img = QImage(size, QImage::Format_Alpha8);
            img.fill(Qt::transparent);
        }
        if (img.size() != size){
            img = img.scaled(size, Qt::IgnoreAspectRatio, m_smooth ? Qt::SmoothTransformation : Qt::FastTransformation );
        }
        m_changed = false;

        ManagedTextureNode* mNode = dynamic_cast<ManagedTextureNode*>(node);
        if (!mNode) {
            delete node;
            mNode = new ManagedTextureNode;
        }

        mNode->setTexture(s_iconImageCache->loadTexture(window(), img));
        mNode->setRect(QRect(QPoint(0,0), QSize(width(), height())));
        node = mNode;
    }

    return node;
}

void DesktopIcon::geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    if (newGeometry.size() != oldGeometry.size()) {
        m_changed = true;
        update();
    }
    QQuickItem::geometryChanged(newGeometry, oldGeometry);
}

QImage DesktopIcon::findIcon(const QSize &size)
{
    QImage img;
    QString iconSource = m_source.toString();
    if (iconSource.startsWith("image://")){
        QUrl iconUrl(iconSource);
        QString iconProviderId = iconUrl.host();
        QString iconId = iconUrl.path();
        QSize actualSize;
        QQuickImageProvider* imageProvider = dynamic_cast<QQuickImageProvider*>(
                    qmlEngine(this)->imageProvider(iconProviderId));
        if (!imageProvider)
            return img;
        switch(imageProvider->imageType()){
        case QQmlImageProviderBase::Image:
            img = imageProvider->requestImage(iconId, &actualSize, size);
        case QQmlImageProviderBase::Pixmap:
            img = imageProvider->requestPixmap(iconId, &actualSize, size).toImage();
        case QQmlImageProviderBase::Texture:
        case QQmlImageProviderBase::Invalid:
        case QQmlImageProviderBase::ImageResponse:
            //will have to investigate this more
            break;
        }
    } else {
        if (iconSource.startsWith("qrc:/")){
            iconSource = iconSource.mid(3);
        }
        QIcon icon(iconSource);
        if (icon.availableSizes().isEmpty()) {
            icon = QIcon::fromTheme(iconSource);
        }
        if (!icon.availableSizes().isEmpty()){
            img = icon.pixmap(size, iconMode(), QIcon::On).toImage();
        }
    }
    return img;
}

QIcon::Mode DesktopIcon::iconMode() const
{
    if (!isEnabled()) {
        return QIcon::Disabled;
    } else if (m_selected) {
        return QIcon::Selected;
    } else if (m_active) {
        return QIcon::Active;
    }
    return QIcon::Normal;
}
