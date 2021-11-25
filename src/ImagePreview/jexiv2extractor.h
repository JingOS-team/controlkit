/*
 * SPDX-FileCopyrightText: (C) 2012-2015 Vishesh Handa <vhanda@kde.org>
 * SPDX-FileCopyrightText: (C) 2021 Rui Wang <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#ifndef JEXIV2EXTRACTOR_H
#define JEXIV2EXTRACTOR_H

#include <exiv2/exiv2.hpp>
#include <QDateTime>
#include <QString>

class JExiv2Extractor
{
public:
    JExiv2Extractor();

    void extract(const QString &filePath);

    double gpsLatitude()
    {
        return m_latitude;
    }
    double gpsLongitude()
    {
        return m_longitude;
    }
    QDateTime dateTime()
    {
        return m_dateTime;
    }

    bool error() const;

    bool setFileDateTime(QString locationPath,QString newFilePath);

private:
    double fetchGpsDouble(const Exiv2::ExifData &data, const char *name);
    QByteArray fetchByteArray(const Exiv2::ExifData &data, const char *name);

    double m_latitude;
    double m_longitude;
    QDateTime m_dateTime;

    bool m_error;
};

#endif // JEXIV2EXTRACTOR_H
