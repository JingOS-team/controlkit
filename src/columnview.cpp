/*
 *   Copyright 2019 Marco Martin <mart@kde.org>
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

#include "columnview.h"
#include "columnview_p.h"

#include <QAbstractItemModel>
#include <QGuiApplication>
#include <QStyleHints>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QDebug>
#include <QPropertyAnimation>


QHash<QObject *, ColumnViewAttached *> ColumnView::m_attachedObjects = QHash<QObject *, ColumnViewAttached *>();

class QmlComponentsPoolSingleton
{
public:
    QmlComponentsPoolSingleton()
    {}

    QmlComponentsPool self;
};

Q_GLOBAL_STATIC(QmlComponentsPoolSingleton, privateQmlComponentsPoolSelf)


QmlComponentsPool::QmlComponentsPool(QObject *parent)
    : QObject(parent)
{}

void QmlComponentsPool::initialize(QQmlEngine *engine)
{
    if (!engine || m_instance) {
        return;
    }

    QQmlComponent *component = new QQmlComponent(engine, this);

    component->setData(QByteArrayLiteral("import QtQuick 2.7\n"
        "import org.kde.kirigami 2.7 as Kirigami\n"
        "QtObject {\n"
            "id: root\n"
            "readonly property Kirigami.Units units: Kirigami.Units\n"
            "readonly property Component separator: Kirigami.Separator {"
                "property Item column\n"
                "visible: column.Kirigami.ColumnView.view.contentX < column.x;"
                "anchors.top: column.top;"
                "anchors.bottom: column.bottom;"
            "}"
        "}"), QUrl());

    m_instance = component->create();
    //qWarning()<<component->errors();
    Q_ASSERT(m_instance);

    m_separatorComponent = m_instance->property("separator").value<QQmlComponent *>();
    Q_ASSERT(m_separatorComponent);

    m_units = m_instance->property("units").value<QObject *>();
    Q_ASSERT(m_units);

    connect(m_units, SIGNAL(gridUnitChanged()), this, SIGNAL(gridUnitChanged()));
    connect(m_units, SIGNAL(longDurationChanged()), this, SIGNAL(longDurationChanged()));
}

QmlComponentsPool::~QmlComponentsPool()
{}


/////////

ColumnViewAttached::ColumnViewAttached(QObject *parent)
    : QObject(parent)
{}

ColumnViewAttached::~ColumnViewAttached()
{}

void ColumnViewAttached::setIndex(int index)
{
    if (!m_customFillWidth && m_view) {
        const bool oldFillWidth = m_fillWidth;
        m_fillWidth = index == m_view->count() - 1;
        if (oldFillWidth != m_fillWidth) {
            emit fillWidthChanged();
        }
    }

    if (index == m_index) {
        return;
    }

    m_index = index;
    emit indexChanged();
}

int ColumnViewAttached::index() const
{
    return m_index;
}

void ColumnViewAttached::setFillWidth(bool fill)
{
    if (m_view) {
        disconnect(m_view.data(), &ColumnView::countChanged, this, nullptr);
    }
    m_customFillWidth = true;

    if (fill == m_fillWidth) {
        return;
    }

    m_fillWidth = fill;
    emit fillWidthChanged();
}

bool ColumnViewAttached::fillWidth() const
{
    return m_fillWidth;
}

qreal ColumnViewAttached::reservedSpace() const
{
    return m_reservedSpace;
}

void ColumnViewAttached::setReservedSpace(qreal space)
{
    if (m_view) {
        disconnect(m_view.data(), &ColumnView::columnWidthChanged, this, nullptr);
    }
    m_customReservedSpace = true;

    if (qFuzzyCompare(space, m_reservedSpace)) {
        return;
    }

    m_reservedSpace = space;
    emit reservedSpaceChanged();
}

ColumnView *ColumnViewAttached::view()
{
    return m_view;
}

void ColumnViewAttached::setView(ColumnView *view)
{
    if (view == m_view) {
        return;
    }

    if (m_view) {
        disconnect(m_view.data(), nullptr, this, nullptr);
    }
    m_view = view;

    if (!m_customFillWidth && m_view) {
        m_fillWidth = m_index == m_view->count() - 1;
        connect(m_view.data(), &ColumnView::countChanged, this, [this]() {
            m_fillWidth = m_index == m_view->count() - 1;
            emit fillWidthChanged();
        });
    }
    if (!m_customReservedSpace && m_view) {
        m_reservedSpace = m_view->columnWidth();
        connect(m_view.data(), &ColumnView::columnWidthChanged, this, [this]() {
            m_reservedSpace = m_view->columnWidth();
            emit reservedSpaceChanged();
        });
    }

    emit viewChanged();
}

QQuickItem *ColumnViewAttached::originalParent() const
{
    return m_originalParent;
}

void ColumnViewAttached::setOriginalParent(QQuickItem *parent)
{
    m_originalParent = parent;
}

bool ColumnViewAttached::shouldDeleteOnRemove() const
{
    return m_shouldDeleteOnRemove;
}

void ColumnViewAttached::setShouldDeleteOnRemove(bool del)
{
    m_shouldDeleteOnRemove = del;
}

bool ColumnViewAttached::preventStealing() const
{
    return m_preventStealing;
}

void ColumnViewAttached::setPreventStealing(bool prevent)
{
    if (prevent == m_preventStealing) {
        return;
    }

    m_preventStealing = prevent;
    emit preventStealingChanged();
}



/////////

ContentItem::ContentItem(ColumnView *parent)
    : QQuickItem(parent),
      m_view(parent)
{
    m_slideAnim = new QPropertyAnimation(this);
    m_slideAnim->setTargetObject(this);
    m_slideAnim->setPropertyName("x");
    //NOTE: the duration will be taked from kirigami units upon classBegin
    m_slideAnim->setDuration(0);
    m_slideAnim->setEasingCurve(QEasingCurve(QEasingCurve::InOutQuad));
    connect(m_slideAnim, &QPropertyAnimation::finished, this, [this] () {
        if (!m_view->currentItem()) {
            m_view->setCurrentIndex(m_items.indexOf(m_viewAnchorItem));
        } else {
            QRectF mapped = m_view->currentItem()->mapRectToItem(m_view, QRectF(QPointF(0, 0), m_view->currentItem()->size()));
            if (!QRectF(QPointF(0, 0), m_view->size()).intersects(mapped)) {
                m_view->setCurrentIndex(m_items.indexOf(m_viewAnchorItem));
            }
        }
    });
}

ContentItem::~ContentItem()
{}

void ContentItem::setBoundedX(qreal x)
{
    if (!parentItem()) {
        return;
    }
    m_slideAnim->stop();
    setX(qRound(qBound(qMin(0.0, -width()+parentItem()->width()), x, 0.0)));
}

void ContentItem::animateX(qreal newX)
{
    if (!parentItem()) {
        return;
    }

    const qreal to = qRound(qBound(qMin(0.0, -width()+parentItem()->width()), newX, 0.0));

    m_slideAnim->stop();
    m_slideAnim->setStartValue(x());
    m_slideAnim->setEndValue(to);
    m_slideAnim->start();
}

void ContentItem::snapToItem()
{
    QQuickItem *firstItem = childAt(-x(), 0);
    if (!firstItem) {
        return;
    }
    QQuickItem *nextItem = childAt(firstItem->x() + firstItem->width() + 1, 0);

    //need to make the last item visible?
    if (nextItem && width() - (-x() + m_view->width()) < -x() - firstItem->x()) {
        m_viewAnchorItem = nextItem;
        animateX(-nextItem->x());

    //The first one found?
    } else if (-x() <= firstItem->x() + firstItem->width()/2 || !nextItem) {
        m_viewAnchorItem = firstItem;
        animateX(-firstItem->x());

    //the second?
    } else {
        m_viewAnchorItem = nextItem;
        animateX(-nextItem->x());
    }
}

qreal ContentItem::childWidth(QQuickItem *child)
{
    if (!parentItem()) {
        return 0.0;
    }

    ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(child, true));

    if (m_columnResizeMode == ColumnView::SingleColumn) {
        return qRound(parentItem()->width());

    } else if (attached->fillWidth()) {
        return qRound(qBound(m_columnWidth, (parentItem()->width() - attached->reservedSpace()), parentItem()->width()));

    } else if (m_columnResizeMode == ColumnView::FixedColumns) {
        return qRound(qMin(parentItem()->width(), m_columnWidth));

    // DynamicColumns
    } else {
        //TODO:look for Layout size hints
        qreal width = child->implicitWidth();

        if (width < 1.0) {
            width = m_columnWidth;
        }

        return qRound(qMin(m_view->width(), width));
    }
}

void ContentItem::layoutItems()
{
    qreal partialWidth = 0;
    int i = 0;
    for (QQuickItem *child : m_items) {
        if (child->isVisible()) {
            child->setSize(QSizeF(childWidth(child), height()));
            child->setPosition(QPointF(partialWidth, 0.0));
            partialWidth += child->width();
        }
        ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(child, true));
        attached->setIndex(i++);
    }
    setWidth(partialWidth);

    const qreal newContentX = m_viewAnchorItem ? -m_viewAnchorItem->x() : 0.0;
    if (m_shouldAnimate) {
        animateX(newContentX);
    } else {
        setBoundedX(newContentX);
    }
    setY(0);
    updateVisibleItems();
}

void ContentItem::updateVisibleItems()
{
    QList <QObject *> newItems;

    for (auto *item : m_items) {
        if (item->isVisible() && item->x() + x() < width() && item->x() + item->width() + x() > 0) {
            newItems << item;
        }
    }

    const QQuickItem *oldFirstVisibleItem = m_visibleItems.isEmpty() ? nullptr : qobject_cast<QQuickItem *>(m_visibleItems.first());
    const QQuickItem *oldLastVisibleItem = m_visibleItems.isEmpty() ? nullptr : qobject_cast<QQuickItem *>(m_visibleItems.last());

    if (newItems != m_visibleItems) {
        m_visibleItems = newItems;
        emit m_view->visibleItemsChanged();
        if (!newItems.isEmpty() && m_visibleItems.first() != oldFirstVisibleItem) {
            emit m_view->firstVisibleItemChanged();
        }
        if (!newItems.isEmpty() && m_visibleItems.last() != oldLastVisibleItem) {
            emit m_view->lastVisibleItemChanged();
        }
    }
}

void ContentItem::forgetItem(QQuickItem *item)
{
    if (!m_items.contains(item)) {
        return;
    }

    ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(item, true));
    attached->setView(nullptr);
    attached->setIndex(-1);

    disconnect(attached, nullptr, this, nullptr);
    disconnect(item, nullptr, this, nullptr);
    disconnect(item, nullptr, m_view, nullptr);

    QQuickItem *separatorItem = m_separators.take(item);
    if (separatorItem) {
        separatorItem->deleteLater();
    }

    const int index = m_items.indexOf(item);
    m_items.removeAll(item);
    updateVisibleItems();
    m_shouldAnimate = true;
    m_view->polish();
    item->setVisible(false);

    if (index <= m_view->currentIndex()) {
        m_view->setCurrentIndex(qBound(0, index - 1, m_items.count() - 1));
    }
    emit m_view->countChanged();
}

QQuickItem *ContentItem::ensureSeparator(QQuickItem *item)
{
    QQuickItem *separatorItem = m_separators.value(item);
    
    if (!separatorItem) {
        separatorItem = qobject_cast<QQuickItem *>(privateQmlComponentsPoolSelf->self.m_separatorComponent->beginCreate(QQmlEngine::contextForObject(item)));
        if (separatorItem) {
            separatorItem->setParentItem(item);
            separatorItem->setZ(9999);
            separatorItem->setProperty("column", QVariant::fromValue(item));
            privateQmlComponentsPoolSelf->self.m_separatorComponent->completeCreate();
            m_separators[item] = separatorItem;
        }
    }

    return separatorItem;
}

void ContentItem::itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value)
{
    switch (change) {
    case QQuickItem::ItemChildAddedChange: {
        ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(value.item, true));
        attached->setView(m_view);

        //connect(attached, &ColumnViewAttached::fillWidthChanged, m_view, &ColumnView::polish);
         connect(attached, &ColumnViewAttached::fillWidthChanged, this, [this, attached](){
             m_view->polish();
             
        });
        connect(attached, &ColumnViewAttached::reservedSpaceChanged, m_view, &ColumnView::polish);

        value.item->setVisible(true);

        if (!m_items.contains(value.item)) {
            connect(value.item, &QQuickItem::widthChanged, m_view, &ColumnView::polish);
            m_items << value.item;
        }

        if (m_view->separatorVisible()) {
            ensureSeparator(value.item);
        }

        m_shouldAnimate = true;
        m_view->polish();
        emit m_view->countChanged();
        break;
    }
    case QQuickItem::ItemChildRemovedChange: {
        forgetItem(value.item);
        break;
    }
    case QQuickItem::ItemVisibleHasChanged:
        updateVisibleItems();
        break;
    default:
        break;
    }
    QQuickItem::itemChange(change, value);
}

void ContentItem::geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    updateVisibleItems();
    QQuickItem::geometryChanged(newGeometry, oldGeometry);
}

void ContentItem::syncItemsOrder()
{
    if (m_items == childItems()) {
        return;
    }

    m_items = childItems();
    polish();
}

void ContentItem::updateRepeaterModel()
{
    if (!sender()) {
        return;
    }

    QObject *modelObj = sender()->property("model").value<QObject *>();

    if (!modelObj) {
        m_models.remove(sender());
        return;
    }

    if (m_models[sender()]) {
        disconnect(m_models[sender()], nullptr, this, nullptr);
    }

    m_models[sender()] = modelObj;

    QAbstractItemModel *qaim = qobject_cast<QAbstractItemModel *>(modelObj);

    if (qaim) {
        connect(qaim, &QAbstractItemModel::rowsMoved, this, &ContentItem::syncItemsOrder);

    } else {
        connect(modelObj, SIGNAL(childrenChanged()), this, SLOT(syncItemsOrder()));
    }
}







ColumnView::ColumnView(QQuickItem *parent)
    : QQuickItem(parent),
      m_contentItem(nullptr)
{
    //NOTE: this is to *not* trigger itemChange
    m_contentItem = new ContentItem(this);
    setAcceptedMouseButtons(Qt::LeftButton);
    setFiltersChildMouseEvents(true);

    connect(m_contentItem->m_slideAnim, &QPropertyAnimation::finished, this, [this] () {
        m_moving = false;
        emit movingChanged();
    });
    connect(m_contentItem, &ContentItem::widthChanged, this, &ColumnView::contentWidthChanged);
    connect(m_contentItem, &ContentItem::xChanged, this, &ColumnView::contentXChanged);

    ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(this, true));
    attached->setView(this);
    attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(m_contentItem, true));
    attached->setView(this);
}

ColumnView::~ColumnView()
{
}

ColumnView::ColumnResizeMode ColumnView::columnResizeMode() const
{
    return m_contentItem->m_columnResizeMode;
}

void ColumnView::setColumnResizeMode(ColumnResizeMode mode)
{
    if (m_contentItem->m_columnResizeMode == mode) {
        return;
    }

    m_contentItem->m_columnResizeMode = mode;
    if (mode == SingleColumn && m_currentItem) {
        m_contentItem->m_viewAnchorItem = m_currentItem;
    }
    m_contentItem->m_shouldAnimate = false;
    polish();
    emit columnResizeModeChanged();
}

qreal ColumnView::columnWidth() const
{
    return m_contentItem->m_columnWidth;
}

void ColumnView::setColumnWidth(qreal width)
{
    // Always forget the internal binding when the user sets anything, even the same value
    disconnect(&privateQmlComponentsPoolSelf->self, &QmlComponentsPool::gridUnitChanged, this, nullptr);

    if (m_contentItem->m_columnWidth == width) {
        return;
    }

    m_contentItem->m_columnWidth = width;
    m_contentItem->m_shouldAnimate = false;
    polish();
    emit columnWidthChanged();
}

int ColumnView::currentIndex() const
{
    return m_currentIndex;
}

void ColumnView::setCurrentIndex(int index)
{
    if (m_currentIndex == index || index < -1 || index >= m_contentItem->m_items.count()) {
        return;
    }

    m_currentIndex = index;

    if (index == -1) {
        m_currentItem.clear();

    } else {
        m_currentItem = m_contentItem->m_items[index];
        Q_ASSERT(m_currentItem);
        m_currentItem->forceActiveFocus();

        // If the current item is not on view, scroll
        QRectF mappedCurrent = m_currentItem->mapRectToItem(this,
                                            QRectF(QPointF(0, 0),
                                                   m_currentItem->size()));

        if (m_contentItem->m_slideAnim->state() == QAbstractAnimation::Running) {
            mappedCurrent.moveLeft(mappedCurrent.left() + m_contentItem->x() + m_contentItem->m_slideAnim->endValue().toInt());
        }

        //m_contentItem->m_slideAnim->stop();

        QRectF contentsRect(QPointF(0, 0), size());

        m_contentItem->m_shouldAnimate = true;

        if (!contentsRect.contains(mappedCurrent)) {
            m_contentItem->m_viewAnchorItem = m_currentItem;
            m_contentItem->animateX(-m_currentItem->x());
        } else {
            m_contentItem->snapToItem();
        }
    }

    emit currentIndexChanged();
    emit currentItemChanged();
}

QQuickItem *ColumnView::currentItem()
{
    return m_currentItem;
}

QList<QObject *>ColumnView::visibleItems() const
{
    return m_contentItem->m_visibleItems;
}

QQuickItem *ColumnView::firstVisibleItem() const
{
    if (m_contentItem->m_visibleItems.isEmpty()) {
        return nullptr;
    }

    return qobject_cast<QQuickItem *>(m_contentItem->m_visibleItems.first());
}

QQuickItem *ColumnView::lastVisibleItem() const
{
    if (m_contentItem->m_visibleItems.isEmpty()) {
        return nullptr;
    }

    return qobject_cast<QQuickItem *>(m_contentItem->m_visibleItems.last());
}

int ColumnView::count() const
{
    return m_contentItem->m_items.count();
}

QQuickItem *ColumnView::contentItem() const
{
    return m_contentItem;
}

int ColumnView::scrollDuration() const
{
    return m_contentItem->m_slideAnim->duration();
}

void ColumnView::setScrollDuration(int duration)
{
    disconnect(&privateQmlComponentsPoolSelf->self, &QmlComponentsPool::longDurationChanged, this, nullptr);

    if (m_contentItem->m_slideAnim->duration() == duration) {
        return;
    }

    m_contentItem->m_slideAnim->setDuration(duration);
    emit scrollDurationChanged();
}

bool ColumnView::separatorVisible() const
{
    return m_separatorVisible;
}

void ColumnView::setSeparatorVisible(bool visible)
{
    if (visible == m_separatorVisible) {
        return;
    }

    m_separatorVisible = visible;

    if (visible) {
        for (QQuickItem *item : m_contentItem->m_items) {
            QQuickItem *sep = m_contentItem->ensureSeparator(item);
            if (sep) {
                sep->setVisible(true);
            }
        }
    } else {
        for (QQuickItem *sep : m_contentItem->m_separators.values()) {
            sep->setVisible(false);
        }
    }

    emit separatorVisibleChanged();
}

bool ColumnView::dragging() const
{
    return m_dragging;
}

bool ColumnView::moving() const
{
    return m_moving;
}

qreal ColumnView::contentWidth() const
{
    return m_contentItem->width();
}

qreal ColumnView::contentX() const
{
    return -m_contentItem->x();
}

void ColumnView::setContentX(qreal x) const
{
    m_contentItem->setX(qRound(-x));
}

bool ColumnView::interactive() const
{
    return m_interactive;
}

void ColumnView::setInteractive(bool interactive)
{
    if (m_interactive != interactive) {
        return;
    }

    m_interactive = interactive;

    if (!m_interactive) {
        if (m_dragging) {
            m_dragging = false;
            emit draggingChanged();
        }

        m_contentItem->snapToItem();
        setKeepMouseGrab(false);
    }

    emit interactiveChanged();
}

void ColumnView::addItem(QQuickItem *item)
{
    insertItem(m_contentItem->m_items.length(), item);
}

void ColumnView::insertItem(int pos, QQuickItem *item)
{
    if (!item || m_contentItem->m_items.contains(item)) {
        return;
    }

    m_contentItem->m_items.insert(qBound(0, pos, m_contentItem->m_items.length()), item);

    ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(item, true));
    attached->setOriginalParent(item->parentItem());
    attached->setShouldDeleteOnRemove(item->parentItem() == nullptr && QQmlEngine::objectOwnership(item) == QQmlEngine::JavaScriptOwnership);
    item->setParentItem(m_contentItem);

    item->forceActiveFocus();
    // We layout immediately to be sure all geometries are final after the return of this call
    m_contentItem->m_shouldAnimate = false;
    m_contentItem->layoutItems();
    emit contentChildrenChanged();

    // In order to keep the same current item we need to increase the current index if displaced
    // NOTE: just updating m_currentIndex does *not* update currentItem (which is what we need atm) while setCurrentIndex will update also currentItem
    if (m_currentIndex >= pos) {
        ++m_currentIndex;
        emit currentIndexChanged();
    }

    emit itemInserted(pos, item);
}

void ColumnView::moveItem(int from, int to)
{
    if (m_contentItem->m_items.isEmpty()
        || from < 0 || from >= m_contentItem->m_items.length()
        || to < 0 || to >= m_contentItem->m_items.length()) {
        return;
    }

    m_contentItem->m_items.move(from, to);
    m_contentItem->m_shouldAnimate = true;

    if (from == m_currentIndex) {
        m_currentIndex = to;
        emit currentIndexChanged();
    } else if (from < m_currentIndex && to > m_currentIndex) {
        --m_currentIndex;
        emit currentIndexChanged();
    } else if (from > m_currentIndex && to <= m_currentIndex) {
        ++m_currentIndex;
        emit currentIndexChanged();
    }

    polish();
}

QQuickItem *ColumnView::removeItem(const QVariant &item)
{
    if (item.canConvert<QQuickItem *>()) {
        return removeItem(item.value<QQuickItem *>());
    } else if (item.canConvert<int>()) {
        return removeItem(item.toInt());
    } else {
        return nullptr;
    }
}

QQuickItem *ColumnView::removeItem(QQuickItem *item)
{
    if (m_contentItem->m_items.isEmpty() || !m_contentItem->m_items.contains(item)) {
        return nullptr;
    }

    const int index = m_contentItem->m_items.indexOf(item);

    // In order to keep the same current item we need to increase the current index if displaced
    if (m_currentIndex >= index) {
        setCurrentIndex(m_currentIndex - 1);
    }

    m_contentItem->forgetItem(item);

    ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(item, false));

    if (attached && attached->shouldDeleteOnRemove()) {
        item->deleteLater();
    } else {
        item->setParentItem(attached ? attached->originalParent() : nullptr);
    }

    emit itemRemoved(item);

    return item;
}

QQuickItem *ColumnView::removeItem(int pos)
{
    if (m_contentItem->m_items.isEmpty()
        || pos < 0 || pos >= m_contentItem->m_items.length()) {
        return nullptr;
    }

    return removeItem(m_contentItem->m_items[pos]); 
}

QQuickItem *ColumnView::pop(QQuickItem *item)
{
    QQuickItem *removed = nullptr;

    while (!m_contentItem->m_items.isEmpty() && m_contentItem->m_items.last() != item) {
        removed = removeItem(m_contentItem->m_items.last());
        // if no item has been passed, just pop one
        if (!item) {
            break;
        }
    }
    return removed;
}

void ColumnView::clear()
{
    ColumnViewAttached *attached = nullptr;

    for (QQuickItem *item : m_contentItem->m_items) {
        attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(item, false));
        if (attached && attached->shouldDeleteOnRemove()) {
            item->deleteLater();
        } else {
            item->setParentItem(attached ? attached->originalParent() : nullptr);
        }
    }
    m_contentItem->m_items.clear();
    emit contentChildrenChanged();
}

bool ColumnView::containsItem(QQuickItem *item)
{
    return m_contentItem->m_items.contains(item);
}

ColumnViewAttached *ColumnView::qmlAttachedProperties(QObject *object)
{
    return new ColumnViewAttached(object);
}

void ColumnView::geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    m_contentItem->setHeight(newGeometry.height());
    m_contentItem->m_shouldAnimate = false;
    polish();

    m_contentItem->updateVisibleItems();
    QQuickItem::geometryChanged(newGeometry, oldGeometry);
}

bool ColumnView::childMouseEventFilter(QQuickItem *item, QEvent *event)
{
    if (!m_interactive || item == m_contentItem) {
        return QQuickItem::childMouseEventFilter(item, event);
    }

    switch (event->type()) {
    case QEvent::MouseButtonPress: {
        m_contentItem->m_slideAnim->stop();
        if (item->property("preventStealing").toBool()) {
            m_contentItem->snapToItem();
            return false;
        }
        QMouseEvent *me = static_cast<QMouseEvent *>(event);
        m_oldMouseX = m_startMouseX = mapFromItem(item, me->localPos()).x();

        me->setAccepted(false);
        setKeepMouseGrab(false);

        // On press, we set the current index of the view to the root item 
        QQuickItem *candidateItem = item;
        while (candidateItem->parentItem() && candidateItem->parentItem() != m_contentItem) {
            candidateItem = candidateItem->parentItem();
        }
        if (candidateItem->parentItem() == m_contentItem) {
            setCurrentIndex(m_contentItem->m_items.indexOf(candidateItem));
        }
        
        break;
    }
    case QEvent::MouseMove: {
        if ((!keepMouseGrab() && item->keepMouseGrab()) || item->property("preventStealing").toBool()) {
            m_contentItem->snapToItem();
            return false;
        }

        QQuickItem *candidateItem = item;
        while (candidateItem->parentItem() && candidateItem->parentItem() != m_contentItem) {
            candidateItem = candidateItem->parentItem();
        }
        if (candidateItem->parentItem() == m_contentItem) {
            ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(item, true));
            if (attached->preventStealing()) {
                return false;
            }
        }

        QMouseEvent *me = static_cast<QMouseEvent *>(event);
        const QPointF pos = mapFromItem(item, me->localPos());

        const bool wasDragging = m_dragging;
        // If a drag happened, start to steal all events, use startDragDistance * 2 to give time to widgets to take the mouse grab by themselves
        m_dragging = keepMouseGrab() || qAbs(mapFromItem(item, me->localPos()).x() - m_startMouseX) > qApp->styleHints()->startDragDistance() * 3;

        if (m_dragging != wasDragging) {
            m_moving = true;
            emit movingChanged();
            emit draggingChanged();
        }

        if (m_dragging) {
            m_contentItem->setBoundedX(m_contentItem->x() + pos.x() - m_oldMouseX);
        }

        m_oldMouseX = pos.x();

        setKeepMouseGrab(m_dragging);
        me->setAccepted(m_dragging);
        return m_dragging;
        break;
    }
    case QEvent::MouseButtonRelease: {
        m_contentItem->snapToItem();
        if (m_dragging) {
            m_dragging = false;
            emit draggingChanged();
        }

        if (item->property("preventStealing").toBool()) {
            return false;
        }
        QMouseEvent *me = static_cast<QMouseEvent *>(event);
        event->accept();

        //if a drag happened, don't pass the event
        const bool block = keepMouseGrab();
        setKeepMouseGrab(false);

        me->setAccepted(block);
        return block;
        break;
    }
    default:
        break;
    }

    return QQuickItem::childMouseEventFilter(item, event);
}

void ColumnView::mousePressEvent(QMouseEvent *event)
{
    if (!m_interactive) {
        return;
    }

    m_contentItem->snapToItem();
    m_oldMouseX = event->localPos().x();
    m_startMouseX = event->localPos().x();
    setKeepMouseGrab(false);
    event->accept();
}

void ColumnView::mouseMoveEvent(QMouseEvent *event)
{
    if (!m_interactive) {
        return;
    }

    const bool wasDragging = m_dragging;
    // Same startDragDistance * 2 as the event filter
    m_dragging = keepMouseGrab() || qAbs(event->localPos().x() - m_startMouseX) > qApp->styleHints()->startDragDistance() * 2;
    if (m_dragging != wasDragging) {
        m_moving = true;
        emit movingChanged();
        emit draggingChanged();
    }

    setKeepMouseGrab(m_dragging);

    if (m_dragging) {
        m_contentItem->setBoundedX(m_contentItem->x() + event->pos().x() - m_oldMouseX);
    }

    m_oldMouseX = event->pos().x();
    event->accept();
}

void ColumnView::mouseReleaseEvent(QMouseEvent *event)
{
    if (!m_interactive) {
        return;
    }

    if (m_dragging) {
        m_dragging = false;
        emit draggingChanged();
    }

    m_contentItem->snapToItem();
    setKeepMouseGrab(false);
    event->accept();
}

void ColumnView::mouseUngrabEvent()
{
    if (m_dragging) {
        m_dragging = false;
        emit draggingChanged();
    }

    m_contentItem->snapToItem();
    setKeepMouseGrab(false);
}

void ColumnView::classBegin()
{
    privateQmlComponentsPoolSelf->self.initialize(qmlEngine(this));

    auto syncColumnWidth = [this]() {
        m_contentItem->m_columnWidth = privateQmlComponentsPoolSelf->self.m_units->property("gridUnit").toInt() * 20;
        emit columnWidthChanged();
    };

    connect(&privateQmlComponentsPoolSelf->self, &QmlComponentsPool::gridUnitChanged, this, syncColumnWidth);
    syncColumnWidth();

    auto syncDuration = [this]() {
        m_contentItem->m_slideAnim->setDuration(privateQmlComponentsPoolSelf->self.m_units->property("longDuration").toInt());
        emit scrollDurationChanged();
    };

    connect(&privateQmlComponentsPoolSelf->self, &QmlComponentsPool::longDurationChanged, this, syncDuration);
    syncDuration();

    QQuickItem::classBegin();
}

void ColumnView::componentComplete()
{
    m_complete = true;
    QQuickItem::componentComplete();
}

void ColumnView::updatePolish()
{
    m_contentItem->layoutItems();
}

void ColumnView::itemChange(QQuickItem::ItemChange change, const QQuickItem::ItemChangeData &value)
{
    switch (change) {
    case QQuickItem::ItemChildAddedChange:
        if (m_contentItem && value.item != m_contentItem && !value.item->inherits("QQuickRepeater")) {
            addItem(value.item);
        }
        break;
    default:
        break;
    }
    QQuickItem::itemChange(change, value);
}

void ColumnView::contentChildren_append(QQmlListProperty<QQuickItem> *prop, QQuickItem *item)
{
    // This can only be called from QML
    ColumnView *view = static_cast<ColumnView *>(prop->object);
    if (!view) {
        return;
    }

    view->m_contentItem->m_items.append(item);

    ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(item, true));
    attached->setOriginalParent(item->parentItem());
    attached->setShouldDeleteOnRemove(item->parentItem() == nullptr && QQmlEngine::objectOwnership(item) == QQmlEngine::JavaScriptOwnership);

    item->setParentItem(view->m_contentItem);
}

int ColumnView::contentChildren_count(QQmlListProperty<QQuickItem> *prop)
{
    ColumnView *view = static_cast<ColumnView *>(prop->object);
    if (!view) {
        return 0;
    }

    return view->m_contentItem->m_items.count();
}

QQuickItem *ColumnView::contentChildren_at(QQmlListProperty<QQuickItem> *prop, int index)
{
    ColumnView *view = static_cast<ColumnView *>(prop->object);
    if (!view) {
        return nullptr;
    }

    if (index < 0 || index >= view->m_contentItem->m_items.count()) {
        return nullptr;
    }
    return view->m_contentItem->m_items.value(index);
}

void ColumnView::contentChildren_clear(QQmlListProperty<QQuickItem> *prop)
{
    ColumnView *view = static_cast<ColumnView *>(prop->object);
    if (!view) {
        return;
    }

    return view->m_contentItem->m_items.clear();
}

QQmlListProperty<QQuickItem> ColumnView::contentChildren()
{
    return QQmlListProperty<QQuickItem>(this, nullptr,
                                     contentChildren_append,
                                     contentChildren_count,
                                     contentChildren_at,
                                     contentChildren_clear);
}

void ColumnView::contentData_append(QQmlListProperty<QObject> *prop, QObject *object)
{
    ColumnView *view = static_cast<ColumnView *>(prop->object);
    if (!view) {
        return;
    }

    view->m_contentData.append(object);
    QQuickItem *item = qobject_cast<QQuickItem *>(object);
    //exclude repeaters from layout
    if (item && item->inherits("QQuickRepeater")) {
        item->setParentItem(view);

        connect(item, SIGNAL(modelChanged()), view->m_contentItem, SLOT(updateRepeaterModel()));

    } else if (item) {
        view->m_contentItem->m_items.append(item);

        ColumnViewAttached *attached = qobject_cast<ColumnViewAttached *>(qmlAttachedPropertiesObject<ColumnView>(item, true));
        attached->setOriginalParent(item->parentItem());
        attached->setShouldDeleteOnRemove(view->m_complete && !item->parentItem() && QQmlEngine::objectOwnership(item) == QQmlEngine::JavaScriptOwnership);

        item->setParentItem(view->m_contentItem);

    } else {
        object->setParent(view);
    }
}

int ColumnView::contentData_count(QQmlListProperty<QObject> *prop)
{
    ColumnView *view = static_cast<ColumnView *>(prop->object);
    if (!view) {
        return 0;
    }

    return view->m_contentData.count();
}

QObject *ColumnView::contentData_at(QQmlListProperty<QObject> *prop, int index)
{
    ColumnView *view = static_cast<ColumnView *>(prop->object);
    if (!view) {
        return nullptr;
    }

    if (index < 0 || index >= view->m_contentData.count()) {
        return nullptr;
    }
    return view->m_contentData.value(index);
}

void ColumnView::contentData_clear(QQmlListProperty<QObject> *prop)
{
    ColumnView *view = static_cast<ColumnView *>(prop->object);
    if (!view) {
        return;
    }

    return view->m_contentData.clear();
}

QQmlListProperty<QObject> ColumnView::contentData()
{
    return QQmlListProperty<QObject>(this, nullptr,
                                     contentData_append,
                                     contentData_count,
                                     contentData_at,
                                     contentData_clear);
}

#include "moc_columnview.cpp"
