/*
 * SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 * 
 * SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
 */

#include "toolbarlayout.h"

#include <unordered_map>
#include <cmath>

#include <QQmlComponent>
#include <QTimer>
#include <QDeadlineTimer>

#include "enums.h"
#include "toolbarlayoutdelegate.h"

ToolBarLayoutAttached::ToolBarLayoutAttached(QObject *parent)
    : QObject(parent)
{
}

QObject *ToolBarLayoutAttached::action() const
{
    return m_action;
}

void ToolBarLayoutAttached::setAction(QObject *action)
{
    m_action = action;
}

class ToolBarLayout::Private
{
public:
    Private(ToolBarLayout *qq) : q(qq) { }

    void performLayout();
    QVector<ToolBarLayoutDelegate*> createDelegates();
    ToolBarLayoutDelegate *createDelegate(QObject *action);
    qreal layoutStart(qreal layoutWidth);
    void maybeHideDelegate(ToolBarLayoutDelegate *delegate, qreal &currentWidth, qreal totalWidth);

    ToolBarLayout *q;

    QVector<QObject*> actions;
    ActionsProperty actionsProperty;
    QList<QObject*> hiddenActions;
    QQmlComponent *fullDelegate = nullptr;
    QQmlComponent *iconDelegate = nullptr;
    QQmlComponent *moreButton = nullptr;
    qreal spacing = 0.0;
    Qt::Alignment alignment = Qt::AlignLeft;
    qreal visibleWidth = 0.0;

    bool completed = false;
    bool layoutQueued = false;
    bool layouting = false;
    std::unordered_map<QObject*, std::unique_ptr<ToolBarLayoutDelegate>> delegates;
    QVector<ToolBarLayoutDelegate*> sortedDelegates;
    QQuickItem *moreButtonInstance = nullptr;

    QVector<QObject*> removedActions;
    QTimer *removalTimer = nullptr;

    QElapsedTimer performanceTimer;

    static void appendAction(ToolBarLayout::ActionsProperty *list, QObject *action);
    static int actionCount(ToolBarLayout::ActionsProperty *list);
    static QObject *action(ToolBarLayout::ActionsProperty *list, int index);
    static void clearActions(ToolBarLayout::ActionsProperty *list);
};

ToolBarLayout::ToolBarLayout(QQuickItem *parent)
    : QQuickItem(parent)
    , d(new Private{this})
{
    d->actionsProperty = ActionsProperty(this, this, Private::appendAction, Private::actionCount, Private::action, Private::clearActions);

    // To prevent multiple assignments to actions from constantly recreating
    // delegates, we cache the delegates and only remove them once they are no
    // longer being used. This timer is responsible for triggering that removal.
    d->removalTimer = new QTimer{this};
    d->removalTimer->setInterval(1000);
    d->removalTimer->setSingleShot(true);
    connect(d->removalTimer, &QTimer::timeout, this, [this]() {
        for (auto action : d->removedActions) {
            if (!d->actions.contains(action)) {
                d->delegates.erase(action);
            }
        }
        d->removedActions.clear();
    });
}

ToolBarLayout::~ToolBarLayout()
{
}

ToolBarLayout::ActionsProperty ToolBarLayout::actionsProperty() const
{
    return d->actionsProperty;
}

void ToolBarLayout::addAction(QObject* action)
{
    d->actions.append(action);
    relayout();
}

void ToolBarLayout::removeAction(QObject* action)
{
    auto itr = d->delegates.find(action);
    if (itr != d->delegates.end()) {
        itr->second->hide();
    }

    d->actions.removeOne(action);
    d->removedActions.append(action);
    d->removalTimer->start();
    relayout();
}

void ToolBarLayout::clearActions()
{
    for (auto action : d->actions) {
        auto itr = d->delegates.find(action);
        if (itr != d->delegates.end()) {
            itr->second->hide();
        }
    }

    d->removedActions.append(d->actions);
    d->actions.clear();
    relayout();
}

QList<QObject*> ToolBarLayout::hiddenActions() const
{
    return d->hiddenActions;
}

QQmlComponent * ToolBarLayout::fullDelegate() const
{
    return d->fullDelegate;
}

void ToolBarLayout::setFullDelegate(QQmlComponent *newFullDelegate)
{
    if (newFullDelegate == d->fullDelegate) {
        return;
    }

    d->fullDelegate = newFullDelegate;
    d->delegates.clear();
    relayout();
    Q_EMIT fullDelegateChanged();
}

QQmlComponent * ToolBarLayout::iconDelegate() const
{
    return d->iconDelegate;
}

void ToolBarLayout::setIconDelegate(QQmlComponent *newIconDelegate)
{
    if (newIconDelegate == d->iconDelegate) {
        return;
    }

    d->iconDelegate = newIconDelegate;
    d->delegates.clear();
    relayout();
    Q_EMIT iconDelegateChanged();
}


QQmlComponent *ToolBarLayout::moreButton() const
{
    return d->moreButton;
}

void ToolBarLayout::setMoreButton(QQmlComponent *newMoreButton)
{
    if (newMoreButton == d->moreButton) {
        return;
    }

    d->moreButton = newMoreButton;
    if (d->moreButtonInstance) {
        d->moreButtonInstance->deleteLater();
        d->moreButtonInstance = nullptr;
    }
    relayout();
    Q_EMIT moreButtonChanged();
}

qreal ToolBarLayout::spacing() const
{
    return d->spacing;
}

void ToolBarLayout::setSpacing(qreal newSpacing)
{
    if (newSpacing == d->spacing) {
        return;
    }

    d->spacing = newSpacing;
    relayout();
    Q_EMIT spacingChanged();
}

Qt::Alignment ToolBarLayout::alignment() const
{
    return d->alignment;
}

void ToolBarLayout::setAlignment(Qt::Alignment newAlignment)
{
    if (newAlignment == d->alignment) {
        return;
    }

    d->alignment = newAlignment;
    relayout();
    Q_EMIT alignmentChanged();
}

qreal ToolBarLayout::visibleWidth() const
{
    return d->visibleWidth;
}

void ToolBarLayout::relayout()
{
    if (d->completed && !d->layouting) {
        polish();
    }
}

void ToolBarLayout::componentComplete()
{
    QQuickItem::componentComplete();
    d->completed = true;
    relayout();
}

void ToolBarLayout::geometryChanged(const QRectF& newGeometry, const QRectF& oldGeometry)
{
    relayout();
    QQuickItem::geometryChanged(newGeometry, oldGeometry);
}

void ToolBarLayout::itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData& data)
{
    relayout();
    QQuickItem::itemChange(change, data);
}

void ToolBarLayout::updatePolish()
{
    d->performLayout();
}

void ToolBarLayout::Private::performLayout()
{
    if (!fullDelegate || !iconDelegate || !moreButton) {
        qWarning() << "ToolBarLayout: Unable to layout, required properties are not set";
        return;
    }

    if (actions.isEmpty()) {
        q->setImplicitWidth(0);
        q->setImplicitHeight(0);
        return;
    }

    layouting = true;

    hiddenActions.clear();

    sortedDelegates = createDelegates();

    if (sortedDelegates.size() != actions.size() || !moreButtonInstance) {
        layouting = false;
        q->relayout();
        return;
    }

    qreal maxHeight = moreButtonInstance->isVisible() ? moreButtonInstance->height() : 0.0;
    qreal maxWidth = 0.0;

    // First, calculate the total width and maximum height of all delegates.
    // This will be used to determine which actions to show, which ones to
    // collapse to icon-only etc.
    for (auto entry : sortedDelegates) {
        if (!entry->isActionVisible()) {
            entry->hide();
            continue;
        }

        if (entry->isHidden()) {
            entry->hide();
            hiddenActions.append(entry->action());
            continue;
        }

        if (entry->isIconOnly()) {
            entry->showIcon();
        } else {
            entry->showFull();
        }

        maxWidth += entry->width() + spacing;
        maxHeight = std::max(maxHeight, entry->maxHeight());
    }

    // The last entry also gets spacing but shouldn't, so remove that.
    maxWidth -= spacing;

    qreal layoutWidth = q->width() - (moreButtonInstance->width() + spacing);

    qreal visibleActionsWidth = 0.0;

    if (maxWidth > layoutWidth) {
        // We have more items than fit into the view, so start hiding some.
        for (int i = 0; i < sortedDelegates.size(); ++i) {
            auto delegate = sortedDelegates.at(i);

            maybeHideDelegate(delegate, visibleActionsWidth, layoutWidth);

            if (delegate->isVisible()) {
                visibleActionsWidth += delegate->width() + spacing;
            }
        }
        if (!qFuzzyIsNull(visibleActionsWidth)) {
            // Like above, remove spacing on the last element that incorrectly gets spacing added.
            visibleActionsWidth -= spacing;
        }
    } else {
        visibleActionsWidth = maxWidth;
    }

    if (!hiddenActions.isEmpty()) {
        moreButtonInstance->setVisible(true);
        moreButtonInstance->setX(q->width() - moreButtonInstance->width());
        moreButtonInstance->setY(qRound((maxHeight - moreButtonInstance->height()) / 2.0));
    } else {
        moreButtonInstance->setVisible(false);
    }

    qreal currentX = layoutStart(visibleActionsWidth);
    for (auto entry : sortedDelegates) {
        if (!entry->isVisible()) {
            continue;
        }

        entry->setPosition(currentX, qRound((maxHeight - entry->height()) / 2.0));

        currentX += entry->width() + spacing;
    }

    q->setImplicitSize(maxWidth, maxHeight);
    Q_EMIT q->hiddenActionsChanged();

    qreal newVisibleWidth = visibleActionsWidth + (moreButtonInstance->isVisible() ? moreButtonInstance->width() : 0.0);
    if (!qFuzzyCompare(newVisibleWidth, visibleWidth)) {
        visibleWidth = newVisibleWidth;
        Q_EMIT q->visibleWidthChanged();
    }

    sortedDelegates.clear();
    layouting = false;
}

QVector<ToolBarLayoutDelegate*> ToolBarLayout::Private::createDelegates()
{
    QVector<ToolBarLayoutDelegate*> result;

    // To prevent long delays when creating a ToolBarLayout, this limits the
    // maximum amount of time that can be taken to create delegates. Should the
    // deadline pass, we will return a partial list of delegates and layouting
    // will be skipped, to be resumed at the next frame. Since we cache
    // delegates, the next run will continue where we left off. This way we can
    // spread delegate creation over several frames. There are probably other
    // ways to do this, but this approach is nice and compact code-wise.
    QDeadlineTimer timer(10);

    int index = 0;
    do {
        auto action = actions.at(index++);
        if (delegates.find(action) != delegates.end()) {
            result.append(delegates.at(action).get());
        } else {
            auto delegate = std::unique_ptr<ToolBarLayoutDelegate>(createDelegate(action));
            if (delegate) {
                result.append(delegate.get());
                delegates.emplace(action, std::move(delegate));
            }
        }
    } while (!timer.hasExpired() && index < actions.size());

    if (!moreButtonInstance && !timer.hasExpired()) {
        moreButtonInstance = qobject_cast<QQuickItem*>(moreButton->beginCreate(qmlContext(q)));
        moreButtonInstance->setParentItem(q);
        connect(moreButtonInstance, &QQuickItem::visibleChanged, q, [this]() {
            moreButtonInstance->setVisible(!hiddenActions.isEmpty());
        });
        moreButton->completeCreate();
    }

    return result;
}

ToolBarLayoutDelegate *ToolBarLayout::Private::createDelegate(QObject* action)
{
    auto create = [this, action](QQmlComponent *component) -> QQuickItem * {
        auto delegate = qobject_cast<QQuickItem*>(component->beginCreate(qmlContext(q)));
        if (!delegate) {
            qWarning() << "Could not create delegate for ToolBarLayout: " << component << "does not provide an Item";
            if (component->isError()) {
                qWarning() << component->errorString();
            }
            component->completeCreate();
            return nullptr;
        }

        delegate->setParentItem(q);

        auto attached = static_cast<ToolBarLayoutAttached *>(qmlAttachedPropertiesObject<ToolBarLayout>(delegate, true));
        attached->setAction(action);

        component->completeCreate();

        return delegate;
    };

    QQmlComponent *fullComponent = nullptr;
    auto displayComponent = action->property("displayComponent");
    if (displayComponent.isValid()) {
        fullComponent = displayComponent.value<QQmlComponent*>();
    }

    if (!fullComponent) {
        fullComponent = fullDelegate;
    }

    auto result = new ToolBarLayoutDelegate(q);
    result->setAction(action);
    result->setFull(create(fullComponent));
    result->setIcon(create(iconDelegate));

    return result;
}

qreal ToolBarLayout::Private::layoutStart(qreal layoutWidth)
{
    qreal availableWidth = moreButtonInstance->isVisible() ? q->width() - (moreButtonInstance->width() + spacing) : q->width();

    if (alignment & Qt::AlignLeft) {
        return 0.0;
    } else if (alignment & Qt::AlignHCenter) {
        return std::floor((availableWidth - layoutWidth) / 2.0);
    } else if (alignment & Qt::AlignRight) {
        return availableWidth - layoutWidth;
    }
    return 0.0;
}

void ToolBarLayout::Private::maybeHideDelegate(ToolBarLayoutDelegate* delegate, qreal &currentWidth, qreal totalWidth)
{
    if (!delegate->isVisible() || currentWidth + delegate->width() < totalWidth) {
        // If the delegate isn't visible anyway, or is visible but fits within
        // the current layout, do nothing.
        return;
    }

    if (delegate->isKeepVisible()) {
        // If the action is marked as KeepVisible, we need to try our best to
        // keep it in view. If the full size delegate does not fit, we try the
        // icon-only delegate. If that also does not fit, try and find other
        // actions to hide. Finally, if that also fails, we will hide the
        // delegate.
        if (currentWidth + delegate->iconWidth() > totalWidth) {
            auto currentIndex = sortedDelegates.indexOf(delegate);
            for (; currentIndex >= 0; --currentIndex) {
                auto previousDelegate = sortedDelegates.at(currentIndex);
                if (!previousDelegate->isVisible()) {
                    continue;
                }

                if (previousDelegate->isKeepVisible()) {
                    continue;
                } else {
                    auto width = previousDelegate->width();
                    previousDelegate->hide();
                    hiddenActions.append(previousDelegate->action());
                    currentWidth -= (width + spacing);
                }

                if (currentWidth + delegate->fullWidth() <= totalWidth) {
                    break;
                } else if (currentWidth + delegate->iconWidth() <= totalWidth) {
                    delegate->showIcon();
                    break;
                }
            }

            if (currentWidth + delegate->width() > totalWidth) {
                delegate->hide();
                hiddenActions.append(delegate->action());
            }
        } else {
            delegate->showIcon();
        }
    } else {
        // The action is not marked as KeepVisible and it does not fit within
        // the current layout, so hide it.
        delegate->hide();
        hiddenActions.append(delegate->action());
    }
}

void ToolBarLayout::Private::appendAction(ToolBarLayout::ActionsProperty *list, QObject *action)
{
    auto layout = reinterpret_cast<ToolBarLayout*>(list->data);
    layout->addAction(action);
}

int ToolBarLayout::Private::actionCount(ToolBarLayout::ActionsProperty *list)
{
    return reinterpret_cast<ToolBarLayout*>(list->data)->d->actions.count();
}

QObject *ToolBarLayout::Private::action(ToolBarLayout::ActionsProperty *list, int index)
{
    return reinterpret_cast<ToolBarLayout *>(list->data)->d->actions.at(index);
}

void ToolBarLayout::Private::clearActions(ToolBarLayout::ActionsProperty *list)
{
    reinterpret_cast<ToolBarLayout *>(list->data)->clearActions();
}
