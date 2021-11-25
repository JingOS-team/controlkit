/*
 *   Copyright 2017 by Atul Sharma <atulsharma406@gmail.com>
 *   Copyright 2021 Rui Wang <wangrui@jingos.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
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
        setEdited(false);
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
    m_path = url;
    Q_EMIT pathChanged(url);
}

QImage JImageDocument::visualImage() const
{
    if (m_undoImages.isEmpty()) {
        return {};
    }
    QImage img = m_undoImages.last();
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
    Q_EMIT visualImageChanged();
    return true;
}

bool JImageDocument::edited() const
{
    return m_edited;
}

void JImageDocument::setEdited(bool value)
{
    if(m_edited != value){
        m_edited = value;
        Q_EMIT editedChanged();
    }
}

bool JImageDocument::providerImage() const
{
    return m_nProviderImage;
}

void JImageDocument::setProviderImage(bool v)
{
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
    Q_EMIT visualImageChanged();
}

void JImageDocument::mirror(bool horizontal, bool vertical)
{
    setEdited(true);
    m_undoImages.append(m_undoImages.last().mirrored(horizontal, vertical));
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
    Q_EMIT visualImageChanged();
}

bool JImageDocument::saveAs(const QString& imagePath)
{
    QString updatedPath = imagePath;
    bool isSaveSuc = true;
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
        isSaveSuc = lastImage.save(updatedPath, nullptr, 100);

        JExiv2Extractor extractor;
        extractor.setFileDateTime(location,updatedPath);
    } else {
        QImage lastImage =  m_undoImages.last();
        isSaveSuc = lastImage.save(updatedPath, nullptr, 100);
    }

    if(isSaveSuc){
        setPath(updatedPath);
        Q_EMIT cropImageFinished(updatedPath);
    }

    return isSaveSuc;
}

void JImageDocument::undo()
{
    Q_ASSERT(m_undoImages.count() > 1);
    m_undoImages.pop_back();

    if (m_undoImages.count() == 1) {
        setEdited(false);
    }
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
