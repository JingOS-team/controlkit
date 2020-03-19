/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "colorutils.h"

#include <QIcon>
#include <QtMath>
#include <QtConcurrent>
#include <cmath>
#include <map>

ColorUtils::ColorUtils(QObject *parent) : QObject(parent) {}

ColorUtils::Brightness ColorUtils::brightnessForColor(QColor color) {
    auto luma = [](QColor color) {
        return (0.299*color.red() + 0.587*color.green() + 0.114*color.blue())/255;
    };

    return luma(color) > 0.5 ? ColorUtils::Brightness::Light : ColorUtils::Brightness::Dark;
}

QColor ColorUtils::alphaBlend(QColor foreground, QColor background) {
    const auto foregroundAlpha = foreground.alpha();
    const auto inverseForegroundAlpha = 0xff - foregroundAlpha;
    const auto backgroundAlpha = background.alpha();

    if (foregroundAlpha == 0x00) return background;

    if (backgroundAlpha == 0xff) {
        return QColor::fromRgb(
            (foregroundAlpha*foreground.red()) + (inverseForegroundAlpha*background.red()),
            (foregroundAlpha*foreground.green()) + (inverseForegroundAlpha*background.green()),
            (foregroundAlpha*foreground.blue()) + (inverseForegroundAlpha*background.blue()),
            0xff
        );
    } else {
        const auto inverseBackgroundAlpha = (backgroundAlpha * inverseForegroundAlpha) / 255;
        const auto finalAlpha = foregroundAlpha + inverseBackgroundAlpha;
        Q_ASSERT(finalAlpha != 0x00);
        return QColor::fromRgb(
            (foregroundAlpha*foreground.red()) + (inverseBackgroundAlpha*background.red()),
            (foregroundAlpha*foreground.green()) + (inverseBackgroundAlpha*background.green()),
            (foregroundAlpha*foreground.blue()) + (inverseBackgroundAlpha*background.blue()),
            finalAlpha
        );
    }
}

QColor ColorUtils::linearInterpolation(QColor one, QColor two, double balance) {

    auto scaleAlpha = [](QColor color, double factor) {
        return QColor::fromRgb(color.red(), color.green(), color.blue(), color.alpha()*factor);
    };
    auto linearlyInterpolateDouble = [](double one, double two, double factor) {
        return one + (two - one) * factor;
    };

    if (one == Qt::transparent) return scaleAlpha(two, balance);
    if (two == Qt::transparent) return scaleAlpha(one, 1 - balance);

    return QColor::fromHsv(
        std::fmod(linearlyInterpolateDouble(one.hue(), two.hue(), balance), 360.0),
        qBound(0.0, linearlyInterpolateDouble(one.saturation(), two.saturation(), balance), 255.0),
        qBound(0.0, linearlyInterpolateDouble(one.value(), two.value(), balance), 255.0),
        qBound(0.0, linearlyInterpolateDouble(one.alpha(), two.alpha(), balance), 255.0)
    );
}

// Some private things for the adjust, change, and scale properties
struct ParsedAdjustments
{
    double red = 0.0;
    double green = 0.0;
    double blue = 0.0;

    double hue = 0.0;
    double saturation = 0.0;
    double value = 0.0;

    double alpha = 0.0;
};

ParsedAdjustments parseAdjustments(QJSValue value)
{
    ParsedAdjustments parsed;

    auto checkProperty = [](QJSValue value, QString property) {
        if (value.hasProperty(property)) {
            auto val = value.property(property);
            if (val.isNumber()) {
                return QVariant::fromValue(val.toNumber());
            }
        }
        return QVariant();
    };

    std::map<QString, double&> map = {
        { QStringLiteral("red"), parsed.red },
        { QStringLiteral("green"), parsed.green },
        { QStringLiteral("blue"), parsed.blue },
        //
        { QStringLiteral("hue"), parsed.hue },
        { QStringLiteral("saturation"), parsed.saturation },
        { QStringLiteral("value"), parsed.value },
        { QStringLiteral("lightness"), parsed.value },
        //
        { QStringLiteral("alpha"), parsed.alpha }
    };

    for (std::pair<QString, double&> item : map) {
        auto val = checkProperty(value, item.first);
        if (val != QVariant()) item.second = val.toDouble();
    }

    if ((parsed.red || parsed.green || parsed.blue) && (parsed.hue || parsed.saturation || parsed.value)) {
        qCritical() << "It is an error to have both RGB and HSL values in an adjustment.";
    }

    return parsed;
}

QColor ColorUtils::adjustColor(QColor color, QJSValue adjustments)
{
    auto adjusts = parseAdjustments(adjustments);

    if (qBound(-360.0, adjusts.hue, 360.0) != adjusts.hue) qCritical() << "Hue is out of bounds";

    if (qBound(-255.0, adjusts.red, 255.0) != adjusts.red) qCritical() << "Red is out of bounds";
    if (qBound(-255.0, adjusts.green, 255.0) != adjusts.green) qCritical() << "Green is out of bounds";
    if (qBound(-255.0, adjusts.blue, 255.0) != adjusts.blue) qCritical() << "Green is out of bounds";
    if (qBound(-255.0, adjusts.saturation, 255.0) != adjusts.saturation) qCritical() << "Saturation is out of bounds";
    if (qBound(-255.0, adjusts.value, 255.0) != adjusts.value) qCritical() << "Value is out of bounds";
    if (qBound(-255.0, adjusts.alpha, 255.0) != adjusts.alpha) qCritical() << "Alpha is out of bounds";

    auto copy = color;

    if (adjusts.alpha) {
        copy.setAlpha(adjusts.alpha);
    }

    if (adjusts.red || adjusts.green || adjusts.blue) {
        copy.setRed(copy.red() + adjusts.red);
        copy.setGreen(copy.green() + adjusts.green);
        copy.setBlue(copy.blue() + adjusts.blue);
    } else if (adjusts.hue || adjusts.saturation || adjusts.value) {
        copy.setHsl(
            std::fmod(copy.hue()+adjusts.hue, 360.0),
            copy.saturation()+adjusts.saturation,
            copy.value()+adjusts.value,
            copy.alpha()
        );
    }

    return copy;
}

QColor ColorUtils::scaleColor(QColor color, QJSValue adjustments)
{
    auto adjusts = parseAdjustments(adjustments);
    auto copy = color;

    if (qBound(-100.0, adjusts.red, 100.00) != adjusts.red) qCritical() << "Red is out of bounds";
    if (qBound(-100.0, adjusts.green, 100.00) != adjusts.green) qCritical() << "Green is out of bounds";
    if (qBound(-100.0, adjusts.blue, 100.00) != adjusts.blue) qCritical() << "Blue is out of bounds";
    if (qBound(-100.0, adjusts.saturation, 100.00) != adjusts.saturation) qCritical() << "Saturation is out of bounds";
    if (qBound(-100.0, adjusts.value, 100.00) != adjusts.value) qCritical() << "Value is out of bounds";
    if (qBound(-100.0, adjusts.alpha, 100.00) != adjusts.alpha) qCritical() << "Alpha is out of bounds";
    
    if (adjusts.hue != 0) qCritical() << "Hue cannot be scaled";

    auto shiftToAverage = [](double current, double factor) {
        auto scale = qBound(-100.0, factor, 100.0)/100;
        return current + (scale > 0 ? 255 - current : current) * scale;
    };

    if (adjusts.red || adjusts.green || adjusts.blue) {
        copy.setRed(qBound(0.0, shiftToAverage(copy.red(), adjusts.red), 255.0));
        copy.setGreen(qBound(0.0, shiftToAverage(copy.green(), adjusts.green), 255.0));
        copy.setBlue(qBound(0.0, shiftToAverage(copy.blue(), adjusts.blue), 255.0));
    } else {
        copy.setHsl(
            copy.hue(),
            qBound(0.0, shiftToAverage(copy.saturation(), adjusts.saturation), 255.0),
            qBound(0.0, shiftToAverage(copy.value(), adjusts.value), 255.0),
            qBound(0.0, shiftToAverage(copy.alpha(), adjusts.alpha), 255.0)
        );
    }

    return copy;
}