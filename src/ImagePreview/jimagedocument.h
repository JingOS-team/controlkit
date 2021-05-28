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
    // 唯一单实例对象指针
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
