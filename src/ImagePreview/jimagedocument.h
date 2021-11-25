/*
 *   Copyright 2017 by Atul Sharma <atulsharma406@gmail.com>
 *   Copyright 2020 by Carl Schwan <carl@carlschwan.eu>
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

#ifndef JIMAGEDOCUMENT_H
#define JIMAGEDOCUMENT_H

#include <QMutex>
#include <QImage>
#include <QRunnable>
#include <QQuickImageProvider>
class JImageSaveThread : public QObject, public QRunnable
{
    Q_OBJECT
public:
    JImageSaveThread(QImage &source, const QString &location);
    void run() override;
Q_SIGNALS:
    void finished();
private:
    QString m_location;
    QImage &m_source;
};


class JImageDocument;
class JCropImageProvider : public QQuickImageProvider{
public:
    static JCropImageProvider* instance();
    ~JCropImageProvider();
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
    void setImageSourceItem(JImageDocument* imgDoc);
private:
    JCropImageProvider();
    static JCropImageProvider *g_pSingleton;
    static QMutex m_nMutex;
    JImageDocument* m_pCropImgDoc = nullptr;
};
#define theCropImageInstance JCropImageProvider::instance()

class JImageDocument : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(QImage visualImage READ visualImage NOTIFY visualImageChanged)
    Q_PROPERTY(bool edited READ edited WRITE setEdited NOTIFY editedChanged)
    Q_PROPERTY(bool providerImage READ providerImage WRITE setProviderImage NOTIFY providerImageChanged)

public:
    JImageDocument();
    ~JImageDocument();

    QString path() const;
    void setPath(const QString &url);

    QImage visualImage() const;

    bool edited() const;
    void setEdited(bool value);

    bool providerImage() const;
    void setProviderImage(bool v);

    /**
     * Rotate the image.
     * @param angle The angle of the rotation in degree.
     */
    Q_INVOKABLE void rotate(int angle);

    /**
     * Mirrror the image.
     * @param horizonal Mirror the image horizontally.
     * @param vertical Mirror the image vertically.
     */
    Q_INVOKABLE void mirror(bool horizontal, bool vertical);

    /**
     * Crop the image.
     * @param x The x coordinate of the new image in the old image.
     * @param y The y coordinate of the new image in the old image.
     * @param width The width of the new image.
     * @param height The height of the new image.
     */
    Q_INVOKABLE void crop(int x, int y, int width, int height);

    /**
     * Undo the last edit on the images.
     */
    Q_INVOKABLE void undo();

    /**
     * Cancel all the edit.
     */
    Q_INVOKABLE void cancel();

    /**
     * Save current edited image in place. This is a destructive operation and can't be reverted.
     * @return true iff the file saving operattion was successful.
     */
    Q_INVOKABLE bool save();

    /**
     * Save current edited image as a new image.
     * @param location The location where to save the new image.
     * @return true iff the file saving operattion was successful.
     */
    Q_INVOKABLE bool saveAs(const QString& imagePath = QString());

    Q_INVOKABLE bool clearUndoImage();

Q_SIGNALS:
    void pathChanged(const QString &url);
    void visualImageChanged();
    void editedChanged();
    void providerImageChanged();
    void resetHandle();
    void updateThumbnail();
    void cropImageFinished(const QString& path);
private Q_SLOTS:
    void slotFinished();

private:
    QString m_path;
    QVector<QImage> m_undoImages;
    bool m_edited;
    bool m_nProviderImage = false;
};

#endif
