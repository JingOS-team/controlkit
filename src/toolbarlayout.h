/*
 * SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 * 
 * SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

#ifndef TOOLBARLAYOUT_H
#define TOOLBARLAYOUT_H

#include <memory>
#include <QQuickItem>

class ToolBarLayoutAttached : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject *action READ action CONSTANT)
public:
    ToolBarLayoutAttached(QObject *parent = nullptr);

    QObject *action() const;
    void setAction(QObject *action);

private:
    QObject *m_action = nullptr;
};

class ToolBarLayout : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<QObject> actions READ actionsProperty NOTIFY actionsChanged)
    Q_PROPERTY(QList<QObject*> hiddenActions READ hiddenActions NOTIFY hiddenActionsChanged)
    Q_PROPERTY(QQmlComponent *fullDelegate READ fullDelegate WRITE setFullDelegate NOTIFY fullDelegateChanged)
    Q_PROPERTY(QQmlComponent *iconDelegate READ iconDelegate WRITE setIconDelegate NOTIFY iconDelegateChanged)
    Q_PROPERTY(QQmlComponent *moreButton READ moreButton WRITE setMoreButton NOTIFY moreButtonChanged)
    Q_PROPERTY(qreal spacing READ spacing WRITE setSpacing NOTIFY spacingChanged)
    Q_PROPERTY(Qt::Alignment alignment READ alignment WRITE setAlignment NOTIFY alignmentChanged)
    Q_PROPERTY(qreal visibleWidth READ visibleWidth NOTIFY visibleWidthChanged)
    Q_PROPERTY(qreal minimumWidth READ minimumWidth NOTIFY minimumWidthChanged)
    Q_PROPERTY(Qt::LayoutDirection layoutDirection READ layoutDirection WRITE setLayoutDirection NOTIFY layoutDirectionChanged)

public:
    using ActionsProperty = QQmlListProperty<QObject>;

    ToolBarLayout(QQuickItem *parent = nullptr);
    ~ToolBarLayout();

    ActionsProperty actionsProperty() const;
    void addAction(QObject *action);
    void removeAction(QObject *action);
    void clearActions();
    Q_SIGNAL void actionsChanged();

    QList<QObject*> hiddenActions() const;
    Q_SIGNAL void hiddenActionsChanged();

    QQmlComponent *fullDelegate() const;
    void setFullDelegate(QQmlComponent *newFullDelegate);
    Q_SIGNAL void fullDelegateChanged();

    QQmlComponent *iconDelegate() const;
    void setIconDelegate(QQmlComponent *newIconDelegate);
    Q_SIGNAL void iconDelegateChanged();

    QQmlComponent *moreButton() const;
    void setMoreButton(QQmlComponent *newMoreButton);
    Q_SIGNAL void moreButtonChanged();

    qreal spacing() const;
    void setSpacing(qreal newSpacing);
    Q_SIGNAL void spacingChanged();

    Qt::Alignment alignment() const;
    void setAlignment(Qt::Alignment newAlignment);
    Q_SIGNAL void alignmentChanged();

    qreal visibleWidth() const;
    Q_SIGNAL void visibleWidthChanged();

    qreal minimumWidth() const;
    Q_SIGNAL void minimumWidthChanged();

    Qt::LayoutDirection layoutDirection() const;
    void setLayoutDirection(Qt::LayoutDirection &newLayoutDirection);
    Q_SIGNAL void layoutDirectionChanged();

    Q_SLOT void relayout();

    static ToolBarLayoutAttached *qmlAttachedProperties(QObject *object)
    {
        return new ToolBarLayoutAttached(object);
    }

protected:
    void componentComplete() override;
    void geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry) override;
    void itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &data) override;
    void updatePolish() override;

private:
    class Private;
    const std::unique_ptr<Private> d;
};

QML_DECLARE_TYPEINFO(ToolBarLayout, QML_HAS_ATTACHED_PROPERTIES)

#endif // TOOLBARLAYOUT_H
