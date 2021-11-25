/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Lele Huan <huanlele@jingos.com>
 *
 */

#ifndef JDISPLAYMETRICS_H
#define JDISPLAYMETRICS_H

#include <QObject>
class QAbstractItemModel;
class QStandardItemModel;
class JDisplayMetrics : public QObject
{
    Q_OBJECT
    Q_PROPERTY(qreal dpi READ dpi WRITE setDpi NOTIFY dpiChanged)
    Q_PROPERTY(qreal fontScale READ fontScale WRITE setFontScale NOTIFY fontScaleChanged)
    Q_PROPERTY(int fontSize READ fontSize WRITE setFontSize NOTIFY fontSizeChanged)
    Q_PROPERTY(int defaultFontSize READ defaultFontSize WRITE setDefaultFontSize NOTIFY defaultFontSizeChanged)
    Q_PROPERTY(QString fontFamily READ fontFamily NOTIFY fontFamilyChanged)
    Q_PROPERTY(QAbstractItemModel* fontFamilyModel READ fontFamilyModel CONSTANT)
public:
    explicit JDisplayMetrics(QObject *parent = nullptr);
    ~JDisplayMetrics();

    qreal dpi() const;
    void setDpi(qreal v);

    qreal fontScale() const;
    void setFontScale(qreal v);

    QString fontFamily() const;
    void setFontFamily(const QString& v);

    int fontSize() const;
    void setFontSize(int v);

    int defaultFontSize() const;
    void setDefaultFontSize(int v);

    QAbstractItemModel* fontFamilyModel();

    Q_INVOKABLE void setSystemFont(const QString& fontFamily, int fontSize);
Q_SIGNALS:
    void dpiChanged();
    void fontScaleChanged();
    void fontFamilyChanged();
    void fontSizeChanged();
    void defaultFontSizeChanged();
private:
    qreal m_nDpi = 1.0;
    qreal m_nFontScale = 1.0;

    int m_nFontSize = 14;
    int m_nDefaultFontSize = 14;

    QString m_nFontFamily;
    QStandardItemModel* m_pFontFamilyModel = nullptr;


};

#endif // JDISPLAYMETRICS_H
