/*
 * Copyright 2021 Lele Huan <huanlele@jingos.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "jimagedocument.h"
#include <QMatrix>
#include <QUrl>
#include <QDebug>
#include <QFileInfo>
#include <QDateTime>
#include "jexiv2extractor.h"
#include <QThreadPool>
#include <QImageReader>
#include <QMutexLocker>

JImageSaveThread::JImageSaveThread(QImage &source, const QString &location)
    :QObject()
    ,m_location(location)
    ,m_source(source)
{
}

void JImageSaveThread::run()
{
    if (!m_source.isNull()) {
        m_source.save(m_location);
    }
    Q_EMIT finished();
}

JCropImageProvider* JCropImageProvider::g_pSingleton = nullptr;
QMutex JCropImageProvider::m_nMutex;

JCropImageProvider::JCropImageProvider():QQuickImageProvider(QQmlImageProviderBase::Image)
{
}

JCropImageProvider::~JCropImageProvider()
{
    g_pSingleton = nullptr;
    qDebug() << Q_FUNC_INFO;
}

JCropImageProvider *JCropImageProvider::instance()
{
    QMutexLocker locker(&JCropImageProvider::m_nMutex);
    if(g_pSingleton == nullptr){
        g_pSingleton = new JCropImageProvider();
    }
    return g_pSingleton;
}

QImage JCropImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(id)
    Q_UNUSED(size)
    Q_UNUSED(requestedSize)
    //id is    image://cropImageProvider/ip:xxx.xxx.xxx.xxx
    if(m_pCropImgDoc)
        return m_pCropImgDoc->visualImage();
    else {
        qDebug() << "jCropiamgeproivder crop image document is null, return empty image";
        return QImage();
    }
}

void JCropImageProvider::setImageSourceItem(JImageDocument *imgDoc)
{
    m_pCropImgDoc = imgDoc;
}

JImageDocument::JImageDocument()
{
    connect(this, &JImageDocument::pathChanged,
    this, [this] (const QString &url) {
        Q_EMIT resetHandle();
        /** Since the url passed by the model in the ImageViewer.qml contains 'file://' prefix */
        const QString location = QUrl(url).path();
        QImageReader imageRead(location);
        imageRead.setAutoTransform(true);
        m_undoImages.append(imageRead.read());
        m_edited = false;
        Q_EMIT editedChanged();
        qDebug() << Q_FUNC_INFO << "visual image changed";
        Q_EMIT visualImageChanged();
    });
}

JImageDocument::~JImageDocument()
{
    m_undoImages.clear();
}

QString JImageDocument::path() const
{
    return m_path;
}

void JImageDocument::setPath(const QString& url)
{
    //qDebug() << Q_FUNC_INFO << url;
    m_path = url;
    Q_EMIT pathChanged(url);
}

QImage JImageDocument::visualImage() const
{
    if (m_undoImages.isEmpty()) {
        return {};
    }
    QImage img = m_undoImages.last();
    qDebug() << Q_FUNC_INFO << img;
    return img;
}

bool JImageDocument::clearUndoImage()
{
    if (m_undoImages.isEmpty()) {
        return {};
    }
    while (m_undoImages.count() > 1) {
        m_undoImages.pop_back();
    }
    qDebug() << Q_FUNC_INFO << "visual image changed";
    Q_EMIT visualImageChanged();
    return true;
}

bool JImageDocument::edited() const
{
    return m_edited;
}

void JImageDocument::setEdited(bool value)
{
    m_edited = value;
    Q_EMIT editedChanged();
}

bool JImageDocument::providerImage() const
{
    return m_nProviderImage;
}

void JImageDocument::setProviderImage(bool v)
{
    //qDebug() << Q_FUNC_INFO << v;
    if(m_nProviderImage != v){
        m_nProviderImage = v;
        if(m_nProviderImage == true){
            theCropImageInstance->setImageSourceItem(this);
        }
        Q_EMIT providerImageChanged();
    }
}

void JImageDocument::rotate(int angle)
{
    QTransform tranform;
    tranform.rotate(angle);
    setEdited(true);
    m_undoImages.append(m_undoImages.last().transformed(tranform,  Qt::FastTransformation));
    qDebug() << Q_FUNC_INFO << "visual image changed";
    Q_EMIT visualImageChanged();
}

void JImageDocument::mirror(bool horizontal, bool vertical)
{
    setEdited(true);
    m_undoImages.append(m_undoImages.last().mirrored(horizontal, vertical));
    qDebug() << Q_FUNC_INFO << "visual image changed";
    Q_EMIT visualImageChanged();
}

void JImageDocument::crop(int x, int y, int width, int height)
{
    if (x < 0) {
        width += x;
        x = 0;
    }
    if (y < 0) {
        height += y;
        y = 0;
    }
    if (m_undoImages.last().width() < width + x) {
        width = m_undoImages.last().width() - x;
    }
    if (m_undoImages.last().height() < height + y) {
        height = m_undoImages.last().height() - y;
    }

    const QRect rect(x, y, width, height);
    setEdited(true);
    QImage cropImage = m_undoImages.last().copy(rect);
    m_undoImages.append(cropImage);
    qDebug() << Q_FUNC_INFO << "visual image changed";
    Q_EMIT visualImageChanged();
}

bool JImageDocument::save()
{
    QString location = QUrl(m_path).path();

    QFileInfo lt(location);
    if (!lt.isWritable()) {
        return false;
    }

    JImageSaveThread *saveThread = new JImageSaveThread(m_undoImages.last(),location);
    connect(saveThread, SIGNAL(finished()), this, SLOT(slotFinished()));
    QThreadPool::globalInstance()->start(saveThread);
    return true;
}

void JImageDocument::slotFinished()
{

    while (m_undoImages.count() > 1) {
        m_undoImages.pop_front();
    }
    Q_EMIT resetHandle();
    Q_EMIT updateThumbnail();
    setEdited(false);
    qDebug() << Q_FUNC_INFO << "visual image changed";
    Q_EMIT visualImageChanged();
}

bool JImageDocument::saveAs(const QString& imagePath)
{
    QString updatedPath = imagePath;
    if(updatedPath.isEmpty()){
        QString location = QUrl(m_path).path();

        QFileInfo lt(location);
        if (!lt.isWritable()) {
            return false;
        }
        QStringList sqlits = lt.fileName().split(QString(QStringLiteral(".")));
        QString locationPath = lt.path();
        QString suffix = sqlits.size() > 0 ? QString(QStringLiteral(".")) + sqlits.last() : QString(QStringLiteral(""));
        QString newFileName =  lt.fileName().replace(suffix, QString(QStringLiteral("")));
        QString newFilePath = locationPath + QString(QStringLiteral("/")) + newFileName + QString(QStringLiteral("_copy"));

        int cur = 1;
        QString updatedPath = newFilePath + suffix;
        QFileInfo check(newFilePath + suffix);
        while (check.exists()) {
            updatedPath = QString(QStringLiteral("%1_%2%3")).arg(newFilePath, QString::number(cur), suffix);
            check = QFileInfo(updatedPath);
            cur++;
        }
        QImage lastImage =  m_undoImages.last();
        bool isSaveSuc = lastImage.save(updatedPath);
        qDebug() << Q_FUNC_INFO << updatedPath << "  " << isSaveSuc;

        JExiv2Extractor extractor;
        extractor.setFileDateTime(location,updatedPath);
    } else {
        QImage lastImage =  m_undoImages.last();
        bool isSaveSuc = lastImage.save(updatedPath);
        qDebug() << Q_FUNC_INFO << updatedPath << "  " << isSaveSuc;
    }

    Q_EMIT resetHandle();
    setEdited(false);
    setPath(updatedPath);
    qDebug() << Q_FUNC_INFO << "visual image changed";
    Q_EMIT visualImageChanged();
    Q_EMIT cropImageFinished(updatedPath);
    return true;
}

void JImageDocument::undo()
{
    Q_ASSERT(m_undoImages.count() > 1);
    m_undoImages.pop_back();

    if (m_undoImages.count() == 1) {
        setEdited(false);
    }
    qDebug() << Q_FUNC_INFO << "visual image changed";
    Q_EMIT visualImageChanged();
}

void JImageDocument::cancel()
{
    while (m_undoImages.count() > 1) {
        m_undoImages.pop_back();
    }
    Q_EMIT resetHandle();
    m_edited = false;
    Q_EMIT editedChanged();
}
