/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Yu Jiashu <yujiashu@jingos.com>
 *
 */

#ifndef JMEDIASETTOOL_H
#define JMEDIASETTOOL_H

#include <QObject>

class JMediaSetTool : public QObject
{
    Q_OBJECT
public:
    explicit JMediaSetTool(QObject *parent = nullptr);
    ~JMediaSetTool();
    Q_INVOKABLE QString formatTime(const int time);
    Q_INVOKABLE void hideCursor();
    Q_INVOKABLE void showCursor();
    Q_INVOKABLE void writeVolume(int volume);
    Q_INVOKABLE int readVolume();
    Q_INVOKABLE static void setInhibit(bool v);

private:
    static uint32_t m_nInhibitCookie ;
    static bool m_nIsInhibiting;

};

#endif // JMEDIASETTOOL_H
