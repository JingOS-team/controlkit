/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Yu Jiashu <yujiashu@jingos.com>
 *
 */

#include "jmediasettool.h"
#include <QString>
#include <QDir>
#include <QFileInfo>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QLocale>
#include <QStandardPaths>
#include <QTime>
#include <QApplication>
#include <QDebug>
#include <KConfigGroup>
#include <KSharedConfig>

bool JMediaSetTool::m_nIsInhibiting = false;
uint32_t JMediaSetTool::m_nInhibitCookie = 0;

JMediaSetTool::JMediaSetTool(QObject *parent) : QObject(parent)
{

}

JMediaSetTool::~JMediaSetTool()
{

}

QString JMediaSetTool::formatTime(const int time)
{
    QTime t(0, 0, 0);
    QString formattedTime = t.addSecs(static_cast<qint64>(time)).toString
            (QString(QStringLiteral("hh:mm:ss")));
    return formattedTime;
}

void JMediaSetTool::hideCursor()
{
    QApplication::setOverrideCursor(Qt::BlankCursor);
}

void JMediaSetTool::showCursor()
{
    QApplication::setOverrideCursor(Qt::ArrowCursor);
}

void JMediaSetTool::writeVolume(int volume)
{
    auto kdeglobals = KSharedConfig::openConfig("mpvsetting");
    KConfigGroup cfg(kdeglobals, "mpv");
    cfg.writeEntry("volume", QVariant(volume));
    kdeglobals->sync();
}

int JMediaSetTool::readVolume()
{
    auto kdeglobals = KSharedConfig::openConfig(QString(QStringLiteral("mpvsetting")));
    KConfigGroup cfg(kdeglobals, QString(QStringLiteral("mpv")));

    int temp= cfg.readEntry(QString(QStringLiteral("volume")), QVariant(50)).toInt();
    return temp;
}

void JMediaSetTool::setInhibit(bool v)
{
#if defined (__arm64__) || defined (__aarch64__)
    if(v) {
        if(m_nIsInhibiting == false) {
            QDBusMessage message = QDBusMessage::createMethodCall("org.freedesktop.PowerManagement",
                                                                  "/org/freedesktop/PowerManagement/Inhibit",
                                                                  "org.freedesktop.PowerManagement.Inhibit",
                                                                  "Inhibit");

            message << QCoreApplication::applicationFilePath();
            message << "Video Wake Lock";
            QDBusMessage response = QDBusConnection::sessionBus().call(message);

            if (response.type() == QDBusMessage::ReplyMessage){
                m_nIsInhibiting = true;
                m_nInhibitCookie = response.arguments().takeFirst().toUInt();
            } else {
                m_nIsInhibiting = false;
            }
        }
    } else {
        if(m_nIsInhibiting == true) {
            QDBusMessage message = QDBusMessage::createMethodCall("org.freedesktop.PowerManagement",
                                                                  "/org/freedesktop/PowerManagement/Inhibit",
                                                                  "org.freedesktop.PowerManagement.Inhibit",
                                                                  "UnInhibit");

            message << m_nInhibitCookie;

            QDBusMessage response = QDBusConnection::sessionBus().call(message);

            if (response.type() == QDBusMessage::ReplyMessage){
                m_nIsInhibiting = false;
            } else {
                qDebug() << Q_FUNC_INFO << "dbus UnInhibit fail " << response.type() << response.errorMessage();
            }
        }
    }
#else
    if(v){
        if(m_nIsInhibiting == false) {
            QDBusMessage message = QDBusMessage::createMethodCall("org.freedesktop.ScreenSaver",
                                                                  "/org/freedesktop/ScreenSaver",
                                                                  "org.freedesktop.ScreenSaver",
                                                                  "Inhibit");

            message << QCoreApplication::applicationFilePath();
            message << "Video Wake Lock";
            QDBusMessage response = QDBusConnection::sessionBus().call(message);

            if (response.type() == QDBusMessage::ReplyMessage){
                m_nIsInhibiting = true;
                m_nInhibitCookie = response.arguments().takeFirst().toUInt();
            } else {
                m_nIsInhibiting = false;
            }
        }
    } else {
        if(m_nIsInhibiting == true) {
            QDBusMessage message = QDBusMessage::createMethodCall("org.freedesktop.ScreenSaver",
                                                                  "/org/freedesktop/ScreenSaver",
                                                                  "org.freedesktop.ScreenSaver",
                                                                  "UnInhibit");

            message << m_nInhibitCookie;

            QDBusMessage response = QDBusConnection::sessionBus().call(message);

            if (response.type() == QDBusMessage::ReplyMessage){
                m_nIsInhibiting = false;
            } else {
                qDebug() << Q_FUNC_INFO << "dbus UnInhibit fail " << response.type() << response.errorMessage();
            }
        }
    }
#endif
}

