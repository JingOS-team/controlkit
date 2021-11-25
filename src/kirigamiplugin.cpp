/*
 *  SPDX-FileCopyrightText: 2009 Alan Alpert <alan.alpert@nokia.com>
 *  SPDX-FileCopyrightText: 2010 Ménard Alexis <menard@kde.org>
 *  SPDX-FileCopyrightText: 2010 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Rui Wang <wangrui@jingos.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "kirigamiplugin.h"
#include "columnview.h"
#include "enums.h"
#include "icon.h"
#include "settings.h"
#include "formlayoutattached.h"
#include "mnemonicattached.h"
#include "delegaterecycler.h"
#include "pagepool.h"
#include "scenepositionattached.h"
#include "wheelhandler.h"
#include "shadowedrectangle.h"
#include "shadowedtexture.h"
#include "colorutils.h"
#include "pagerouter.h"
#include "imagecolors.h"
#include "avatar.h"
#include "toolbarlayout.h"
#include "sizegroup.h"
#include "jmediasettool.h"

#include "ImagePreview/jresizehandle.h"
#include "ImagePreview/jresizerectangle.h"
#include "ImagePreview/jimagedocument.h"
#include "ImagePreview/jwallpapersettings.h"
#include "jthememanager.h"
#include "jplatformtheme.h"

#include <QStandardItemModel>
#include <QQmlContext>
#include <QQuickItem>
#include <QQuickStyle>
#include <QGuiApplication>
#include <QClipboard>
#include <QKeyEvent>

#include <QThread>
#include "libkirigami/platformtheme.h"

static QString s_selectedStyle;

//Q_INIT_RESOURCE(kirigami);
#ifdef KIRIGAMI_BUILD_TYPE_STATIC
#include <qrc_kirigami.cpp>
#endif


class KeyEventHelperPrivate : public QObject
{
    Q_OBJECT
public:
    KeyEventHelperPrivate(QObject *parent = nullptr)
        :QObject(parent)
        ,m_object(NULL)
    {
    }

    ~KeyEventHelperPrivate(){

    }
    Q_INVOKABLE void setKeyEventObject(QObject* object)
    {
        m_object = object;
    }

    Q_INVOKABLE  QObject* getKeyEventObject() const
    {
        return m_object;
    }

    static KeyEventHelperPrivate* instance()
    {
        if(m_instance == NULL)
        {
            m_instance = new KeyEventHelperPrivate();
        }
        return m_instance;
    }
Q_SIGNALS:
    void backKeyEvent();
private:
    static KeyEventHelperPrivate* m_instance;
    QObject *m_object;
};

KeyEventHelperPrivate *KeyEventHelperPrivate::m_instance = nullptr;

class CopyHelperPrivate : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE static void copyTextToClipboard(const QString& text)
    {
        qGuiApp->clipboard()->setText(text);
    }
};

// we can't do this in the plugin object directly, as that can live in a different thread
// and event filters are only allowed in the same thread as the filtered object
class LanguageChangeEventFilter : public QObject
{
    Q_OBJECT
public:
    bool eventFilter(QObject *receiver, QEvent *event) override
    {
        if (event->type() == QEvent::LanguageChange && receiver == QCoreApplication::instance()) {
            Q_EMIT languageChangeEvent();
        } else if(event->type() == QEvent::KeyPress && receiver == KeyEventHelperPrivate::instance()->getKeyEventObject()) {
            QKeyEvent *keyEvent = static_cast<QKeyEvent*>(event);

            if(keyEvent->nativeScanCode() == 269025070) {
                Q_EMIT KeyEventHelperPrivate::instance()->backKeyEvent();
            }
        }
        return QObject::eventFilter(receiver, event);
    }

Q_SIGNALS:
    void languageChangeEvent();
};

KirigamiPlugin::KirigamiPlugin(QObject *parent)
    : QQmlExtensionPlugin(parent)
{
    auto filter = new LanguageChangeEventFilter;
    filter->moveToThread(QCoreApplication::instance()->thread());
    QCoreApplication::instance()->installEventFilter(filter);
    connect(filter, &LanguageChangeEventFilter::languageChangeEvent, this, &KirigamiPlugin::languageChangeEvent);
}

KirigamiPlugin::~KirigamiPlugin()
{

}

QUrl KirigamiPlugin::componentUrl(const QString &fileName) const
{
    for (const QString &style : qAsConst(m_stylesFallbackChain)) {
        const QString candidate = QStringLiteral("styles/") + style + QLatin1Char('/') + fileName;
        if (QFile::exists(resolveFilePath(candidate))) {
#ifdef KIRIGAMI_BUILD_TYPE_STATIC
            return QUrl(QStringLiteral("qrc:/org/kde/kirigami.2/styles/") + style + QLatin1Char('/') + fileName);
#else
            return QUrl(resolveFileUrl(candidate));
#endif
        }
    }

#ifdef KIRIGAMI_BUILD_TYPE_STATIC
    return QUrl(QStringLiteral("qrc:/org/kde/kirigami.2/") + fileName);
#else
    return QUrl(resolveFileUrl(fileName));
#endif
}

void KirigamiPlugin::registerTypes(const char *uri)
{
#if defined(Q_OS_ANDROID)
    QResource::registerResource(QStringLiteral("assets:/android_rcc_bundle.rcc"));
#endif

    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.kde.kirigami"));
    const QString style = QQuickStyle::name();

    if (QIcon::themeName().isEmpty() && !qEnvironmentVariableIsSet("XDG_CURRENT_DESKTOP")) {
        QIcon::setThemeSearchPaths({resolveFilePath(QStringLiteral(".")), QStringLiteral(":/icons")});
        QIcon::setThemeName(QStringLiteral("breeze-internal"));
    }

#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    //org.kde.desktop.plasma is a couple of files that fall back to desktop by purpose
    if ((style.isEmpty() || style == QStringLiteral("org.kde.desktop.plasma")) && QFile::exists(resolveFilePath(QStringLiteral("/styles/org.kde.desktop")))) {
        m_stylesFallbackChain.prepend(QStringLiteral("org.kde.desktop"));
    }
#elif defined(Q_OS_ANDROID)
    if (!m_stylesFallbackChain.contains(QLatin1String("Material"))) {
        m_stylesFallbackChain.prepend(QStringLiteral("Material"));
    }
#else // do we have an iOS specific style?
    if (!m_stylesFallbackChain.contains(QLatin1String("Material"))) {
        m_stylesFallbackChain.prepend(QStringLiteral("Material"));
    }
#endif

    if (!style.isEmpty() && QFile::exists(resolveFilePath(QStringLiteral("/styles/") + style)) && !m_stylesFallbackChain.contains(style)) {
        m_stylesFallbackChain.prepend(style);
        //if we have plasma deps installed, use them for extra integration
        if (style == QStringLiteral("org.kde.desktop") && QFile::exists(resolveFilePath(QStringLiteral("/styles/org.kde.desktop.plasma")))) {
            m_stylesFallbackChain.prepend(QStringLiteral("org.kde.desktop.plasma"));
        }
    } else {
#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
        m_stylesFallbackChain.prepend(QStringLiteral("org.kde.desktop"));
#endif
    }
    //At this point the fallback chain will be selected->org.kde.desktop->Fallback
    s_selectedStyle = m_stylesFallbackChain.first();

    qmlRegisterSingletonType<Settings>(uri, 2, 0, "Settings",
                                       [](QQmlEngine *e, QJSEngine*) -> QObject* {
        Settings *settings = Settings::self();
        //singleton managed internally, qml should never delete it
        e->setObjectOwnership(settings, QQmlEngine::CppOwnership);
        settings->setStyle(s_selectedStyle);
        return settings;
    }
    );

    qmlRegisterUncreatableType<ApplicationHeaderStyle>(uri, 2, 0, "ApplicationHeaderStyle", QStringLiteral("Cannot create objects of type ApplicationHeaderStyle"));

    //old legacy retrocompatible Theme
    qmlRegisterSingletonType(componentUrl(QStringLiteral("Theme.qml")), uri, 2, 0, "Theme");

    qmlRegisterSingletonType(componentUrl(QStringLiteral("Units.qml")), uri, 2, 0, "Units");

    qmlRegisterType(componentUrl(QStringLiteral("Action.qml")), uri, 2, 0, "Action");
    qmlRegisterType(componentUrl(QStringLiteral("AbstractApplicationHeader.qml")), uri, 2, 0, "AbstractApplicationHeader");
    qmlRegisterType(componentUrl(QStringLiteral("AbstractApplicationWindow.qml")), uri, 2, 0, "AbstractApplicationWindow");
    qmlRegisterType(componentUrl(QStringLiteral("AbstractListItem.qml")), uri, 2, 0, "AbstractListItem");
    qmlRegisterType(componentUrl(QStringLiteral("ApplicationHeader.qml")), uri, 2, 0, "ApplicationHeader");
    qmlRegisterType(componentUrl(QStringLiteral("ToolBarApplicationHeader.qml")), uri, 2, 0, "ToolBarApplicationHeader");
    qmlRegisterType(componentUrl(QStringLiteral("ApplicationWindow.qml")), uri, 2, 0, "ApplicationWindow");
    qmlRegisterType(componentUrl(QStringLiteral("BasicListItem.qml")), uri, 2, 0, "BasicListItem");
    qmlRegisterType(componentUrl(QStringLiteral("OverlayDrawer.qml")), uri, 2, 0, "OverlayDrawer");
    qmlRegisterType(componentUrl(QStringLiteral("ContextDrawer.qml")), uri, 2, 0, "ContextDrawer");
    qmlRegisterType(componentUrl(QStringLiteral("GlobalDrawer.qml")), uri, 2, 0, "GlobalDrawer");
    qmlRegisterType(componentUrl(QStringLiteral("Heading.qml")), uri, 2, 0, "Heading");
    qmlRegisterType(componentUrl(QStringLiteral("Separator.qml")), uri, 2, 0, "Separator");
    qmlRegisterType(componentUrl(QStringLiteral("PageRow.qml")), uri, 2, 0, "PageRow");

    qmlRegisterType<Icon>(uri, 2, 0, "Icon");

    qmlRegisterType(componentUrl(QStringLiteral("Label.qml")), uri, 2, 0, "Label");
    //TODO: uncomment for 2.3 release
    //qmlRegisterTypeNotAvailable(uri, 2, 3, "Label", "Label type not supported anymore, use QtQuick.Controls.Label 2.0 instead");
    qmlRegisterType(componentUrl(QStringLiteral("OverlaySheet.qml")), uri, 2, 0, "OverlaySheet");
    qmlRegisterType(componentUrl(QStringLiteral("Page.qml")), uri, 2, 0, "Page");
    qmlRegisterType(componentUrl(QStringLiteral("ScrollablePage.qml")), uri, 2, 0, "ScrollablePage");
    qmlRegisterType(componentUrl(QStringLiteral("SplitDrawer.qml")), uri, 2, 0, "SplitDrawer");
    qmlRegisterType(componentUrl(QStringLiteral("SwipeListItem.qml")), uri, 2, 0, "SwipeListItem");

    //2.1
    qmlRegisterType(componentUrl(QStringLiteral("AbstractItemViewHeader.qml")), uri, 2, 1, "AbstractItemViewHeader");
    qmlRegisterType(componentUrl(QStringLiteral("ItemViewHeader.qml")), uri, 2, 1, "ItemViewHeader");
    qmlRegisterType(componentUrl(QStringLiteral("AbstractApplicationItem.qml")), uri, 2, 1, "AbstractApplicationItem");
    qmlRegisterType(componentUrl(QStringLiteral("ApplicationItem.qml")), uri, 2, 1, "ApplicationItem");

    //2.2
    //Theme changed from a singleton to an attached property
    qmlRegisterUncreatableType<Kirigami::PlatformTheme>(uri, 2, 2, "Theme", QStringLiteral("Cannot create objects of type Theme, use it as an attached property"));

    //2.3
    qmlRegisterType(componentUrl(QStringLiteral("FormLayout.qml")), uri, 2, 3, "FormLayout");
    qmlRegisterUncreatableType<FormLayoutAttached>(uri, 2, 3, "FormData", QStringLiteral("Cannot create objects of type FormData, use it as an attached property"));
    qmlRegisterUncreatableType<MnemonicAttached>(uri, 2, 3, "MnemonicData", QStringLiteral("Cannot create objects of type MnemonicData, use it as an attached property"));

    //2.4
    qmlRegisterType(componentUrl(QStringLiteral("AbstractCard.qml")), uri, 2, 4, "AbstractCard");
    qmlRegisterType(componentUrl(QStringLiteral("Card.qml")), uri, 2, 4, "Card");
    qmlRegisterType(componentUrl(QStringLiteral("CardsListView.qml")), uri, 2, 4, "CardsListView");
    qmlRegisterType(componentUrl(QStringLiteral("CardsGridView.qml")), uri, 2, 4, "CardsGridView");
    qmlRegisterType(componentUrl(QStringLiteral("CardsLayout.qml")), uri, 2, 4, "CardsLayout");
    qmlRegisterType(componentUrl(QStringLiteral("InlineMessage.qml")), uri, 2, 4, "InlineMessage");
    qmlRegisterUncreatableType<MessageType>(uri, 2, 4, "MessageType", QStringLiteral("Cannot create objects of type MessageType"));
    qmlRegisterType<DelegateRecycler>(uri, 2, 4, "DelegateRecycler");

    //2.5
    qmlRegisterType(componentUrl(QStringLiteral("ListItemDragHandle.qml")), uri, 2, 5, "ListItemDragHandle");
    qmlRegisterType(componentUrl(QStringLiteral("ActionToolBar.qml")), uri, 2, 5, "ActionToolBar");
    qmlRegisterUncreatableType<ScenePositionAttached>(uri, 2, 5, "ScenePosition", QStringLiteral("Cannot create objects of type ScenePosition, use it as an attached property"));

    //2.6
    qmlRegisterType(componentUrl(QStringLiteral("AboutPage.qml")), uri, 2, 6, "AboutPage");
    qmlRegisterType(componentUrl(QStringLiteral("LinkButton.qml")), uri, 2, 6, "LinkButton");
    qmlRegisterType(componentUrl(QStringLiteral("UrlButton.qml")), uri, 2, 6, "UrlButton");
    qmlRegisterSingletonType<CopyHelperPrivate>("org.kde.kirigami.private", 2, 6, "CopyHelperPrivate", [] (QQmlEngine*, QJSEngine*) -> QObject* { return new CopyHelperPrivate; });

    //2.7
    qmlRegisterType<ColumnView>(uri, 2, 7, "ColumnView");
    qmlRegisterType(componentUrl(QStringLiteral("ActionTextField.qml")), uri, 2, 7, "ActionTextField");

    //2.8
    qmlRegisterType(componentUrl(QStringLiteral("SearchField.qml")), uri, 2, 8, "SearchField");
    qmlRegisterType(componentUrl(QStringLiteral("PasswordField.qml")), uri, 2, 8, "PasswordField");

    //2.9
    qmlRegisterType<WheelHandler>(uri, 2, 9, "WheelHandler");
    qmlRegisterUncreatableType<KirigamiWheelEvent>(uri, 2, 9, "WheelEvent", QStringLiteral("Cannot create objects of type WheelEvent."));

    //2.10
    qmlRegisterType(componentUrl(QStringLiteral("ListSectionHeader.qml")), uri, 2, 10, "ListSectionHeader");

    // 2.11
    qmlRegisterType<PagePool>(uri, 2, 11, "PagePool");
    qmlRegisterType(componentUrl(QStringLiteral("PagePoolAction.qml")), uri, 2, 11, "PagePoolAction");

    //TODO: remove
    qmlRegisterType(componentUrl(QStringLiteral("SwipeListItem2.qml")), uri, 2, 11, "SwipeListItem2");

    // 2.12
    qmlRegisterType<ShadowedRectangle>(uri, 2, 12, "ShadowedRectangle");
    qmlRegisterType<ShadowedTexture>(uri, 2, 12, "ShadowedTexture");
    qmlRegisterType(componentUrl(QStringLiteral("ShadowedImage.qml")), uri, 2, 12, "ShadowedImage");
    qmlRegisterType(componentUrl(QStringLiteral("PlaceholderMessage.qml")), uri, 2, 12, "PlaceholderMessage");

    qmlRegisterUncreatableType<BorderGroup>(uri, 2, 12, "BorderGroup", QStringLiteral("Used as grouped property"));
    qmlRegisterUncreatableType<ShadowGroup>(uri, 2, 12, "ShadowGroup", QStringLiteral("Used as grouped property"));
    qmlRegisterSingletonType<ColorUtils>(uri, 2, 12, "ColorUtils", [] (QQmlEngine*, QJSEngine*) -> QObject* { return new ColorUtils; });

    qmlRegisterUncreatableType<CornersGroup>(uri, 2, 12, "CornersGroup", QStringLiteral("Used as grouped property"));
    qmlRegisterType<PageRouter>(uri, 2, 12, "PageRouter");
    qmlRegisterType<PageRoute>(uri, 2, 12, "PageRoute");
    qmlRegisterUncreatableType<PageRouterAttached>(uri, 2, 12, "PageRouterAttached", QStringLiteral("PageRouterAttached cannot be created"));
    qmlRegisterType(componentUrl(QStringLiteral("RouterWindow.qml")), uri, 2, 12, "RouterWindow");

    // 2.13
    qmlRegisterType<ImageColors>(uri, 2, 13, "ImageColors");
    qmlRegisterType(componentUrl(QStringLiteral("Avatar.qml")), uri, 2, 13, "Avatar");
    qmlRegisterType(componentUrl(QStringLiteral("swipenavigator/SwipeNavigator.qml")), uri, 2, 13, "SwipeNavigator");

    // 2.14
    qmlRegisterUncreatableType<PreloadRouteGroup>(uri, 2, 14, "PreloadRouteGroup", QStringLiteral("PreloadRouteGroup cannot be created"));
    qmlRegisterType(componentUrl(QStringLiteral("FlexColumn.qml")), uri, 2, 14, "FlexColumn");
    qmlRegisterType<ToolBarLayout>(uri, 2, 14, "ToolBarLayout");
    qmlRegisterSingletonType<DisplayHint>(uri, 2, 14, "DisplayHint", [](QQmlEngine*, QJSEngine*) -> QObject* { return new DisplayHint; });
    qmlRegisterType<SizeGroup>(uri, 2, 14, "SizeGroup");
    qmlRegisterType<AvatarGroup>("org.kde.kirigami.private", 2, 14, "AvatarGroup");
    qmlRegisterType(componentUrl(QStringLiteral("CheckableListItem.qml")), uri, 2, 14, "CheckableListItem");
    qmlRegisterSingletonType<NameUtils>(uri, 2, 14, "NameUtils", [] (QQmlEngine*, QJSEngine*) -> QObject* { return new NameUtils; });

    qmlRegisterType(componentUrl(QStringLiteral("Hero.qml")), uri, 2, 15, "Hero");

    // 2.15
    qmlRegisterType(componentUrl(QStringLiteral("JButton.qml")), uri, 2, 15, "JButton");
    qmlRegisterType(componentUrl(QStringLiteral("JIconButton.qml")), uri, 2, 15, "JIconButton");
    qmlRegisterType(componentUrl(QStringLiteral("JSwitchButton.qml")), uri, 2, 15, "JSwitchButton");
    qmlRegisterType(componentUrl(QStringLiteral("JLabel.qml")), uri, 2, 15, "JLabel");
    qmlRegisterType(componentUrl(QStringLiteral("JSolidButton.qml")), uri, 2, 15, "JSolidButton");
    qmlRegisterType(componentUrl(QStringLiteral("JArrowPopup.qml")), uri, 2, 15, "JArrowPopup");
    qmlRegisterType(componentUrl(QStringLiteral("JMouseSolid.qml")), uri, 2, 15, "JMouseSolid");
    qmlRegisterType(componentUrl(QStringLiteral("JSearchField.qml")), uri, 2, 15, "JSearchField");
    qmlRegisterType(componentUrl(QStringLiteral("JPopupMenu.qml")), uri, 2, 15, "JPopupMenu");
    qmlRegisterType(componentUrl(QStringLiteral("JSwitch.qml")), uri, 2, 15, "JSwitch");
    qmlRegisterType(componentUrl(QStringLiteral("JSlider.qml")), uri, 2, 15, "JSlider");
    qmlRegisterType(componentUrl(QStringLiteral("JDialog.qml")), uri, 2, 15, "JDialog");
    qmlRegisterType(componentUrl(QStringLiteral("JInputDialog.qml")), uri, 2, 15, "JInputDialog");
    qmlRegisterType(componentUrl(QStringLiteral("JBlurBackground.qml")), uri, 2, 15, "JBlurBackground");
    qmlRegisterType(componentUrl(QStringLiteral("JMouseHover.qml")), uri, 2, 15, "JMouseHover");
    qmlRegisterType(componentUrl(QStringLiteral("JMenuSeparator.qml")), uri, 2, 15, "JMenuSeparator");
    qmlRegisterType(componentUrl(QStringLiteral("JMouseHoverMask.qml")), uri, 2, 15, "JMouseHoverMask");
    qmlRegisterType(componentUrl(QStringLiteral("JOpenModeDialog.qml")), uri, 2, 15, "JOpenModeDialog");
    qmlRegisterType(componentUrl(QStringLiteral("JRoundRectangle.qml")), uri, 2, 15, "JRoundRectangle");
    qmlRegisterType(componentUrl(QStringLiteral("JArrowPopup.qml")), uri, 2, 15, "JArrowPopup");
    qmlRegisterType(componentUrl(QStringLiteral("JToolTip.qml")), uri, 2, 15, "JToolTip");
    qmlRegisterType(componentUrl(QStringLiteral("JVerticalScrollBar.qml")), uri, 2, 15, "JVerticalScrollBar");
    qmlRegisterType(componentUrl(QStringLiteral("JTextField.qml")), uri, 2, 15, "JTextField");

    qmlRegisterType(componentUrl(QStringLiteral("JPasswdKeyBd.qml")), uri, 2, 15, "JPasswdKeyBd");
    qmlRegisterType(componentUrl(QStringLiteral("JKeyBdLineEdit.qml")), uri, 2, 15, "JKeyBdLineEdit");

    qmlRegisterType(componentUrl(QStringLiteral("JVideoView.qml")), uri, 2, 15, "JVideoView");
    qmlRegisterType(componentUrl(QStringLiteral("JMusicView.qml")), uri, 2, 15, "JMusicView");
    qmlRegisterSingletonType<JMediaSetTool>(uri, 2, 15, "JMediaSetTool", [] (QQmlEngine*, QJSEngine*) -> QObject* { return new JMediaSetTool; });

    qmlRegisterType<JResizeHandle>(uri, 2, 15, "JResizeHandle");
    qmlRegisterType<JResizeRectangle>(uri, 2, 15, "JResizeRectangle");
    qmlRegisterType<JImageDocument>(uri, 2, 15, "JImageDocument");
    qmlRegisterType<JWallPaperSettings>(uri, 2, 15, "JWallPaperSettings");

    qmlRegisterType(componentUrl(QStringLiteral("JImagePreviewItem.qml")), uri, 2, 15, "JImagePreviewItem");
    qmlRegisterType(componentUrl(QStringLiteral("JWallPaperItem.qml")), uri, 2, 15, "JWallPaperItem");

    qmlRegisterType<JThemeManager>(uri, 2, 15, "JThemeManager");
    qmlRegisterType<QStandardItemModel>(uri, 2, 15, "QStandardItemModel");
    qmlRegisterUncreatableType<JPlatformTheme>(uri, 2, 15, "JPlatformTheme", QStringLiteral("Cannot create objects of type Theme, use it as an attached property"));
    qmlRegisterSingletonType(componentUrl(QStringLiteral("JTheme.qml")), uri, 2, 15, "JTheme");

    qmlRegisterSingletonType(componentUrl(QStringLiteral("private/ConstValue.qml")), uri, 2, 15, "ConstValue");

    qmlRegisterSingletonType<KeyEventHelperPrivate>(uri, 2, 15, "KeyEventHelper", [](QQmlEngine *, QJSEngine *) -> QObject * {
        return static_cast<QObject *>(KeyEventHelperPrivate::instance());
    });


    qmlProtectModule(uri, 2);
}

void KirigamiPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    Q_UNUSED(uri);
    engine->addImageProvider(QLatin1String("cropImageProvider"), theCropImageInstance);
    connect(this, &KirigamiPlugin::languageChangeEvent, engine, &QQmlEngine::retranslate);
}


#include "kirigamiplugin.moc"
