/*
 *  SPDX-FileCopyrightText: 2020 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

// This is based on the 2D SDF functions provided by Inigo Quilez:
// https://iquilezles.org/www/articles/distfunctions2d/distfunctions2d.htm

// This shader renders a rectangle with rounded corners and a shadow below it.

uniform lowp float opacity;
uniform lowp float size;
uniform lowp float radius;
uniform lowp vec4 color;
uniform lowp vec4 shadowColor;
uniform lowp vec2 offset;
uniform lowp vec2 aspect;

varying lowp vec2 uv;

const lowp float minimum_shadow_radius = 0.05;

// Calculate the distance to a rectangle with rounded corners.
// \param point The point to calculate the distance of.
// \param rect The rectangle to calculate the distance of.
// \param translation The amount of translation to apply to the rectangle.
// \param radius A vec4 with the radius of each corner. Order is top right, bottom right, top left, bottom left.
lowp float sdf_rounded_rectangle(in lowp vec2 point, in lowp vec2 rect, in lowp vec2 translation, in lowp vec4 radius)
{
    radius.xy = (point.x > 0.0) ? radius.xy : radius.zw;
    radius.x = (point.y > 0.0) ? radius.x : radius.y;
    lowp vec2 d = abs(point - translation) - rect + radius.x;
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - radius.x;
}

void main()
{
    // Scaling factor that is the inverse of the amount of scaling applied to the geometry.
    lowp float inverse_scale = 1.0 / (1.0 + size + length(offset) * 2.0);

    // Correction factor to round the corners of a larger shadow.
    // We want to account for size in regards to shadow radius, so that a larger shadow is
    // more rounded, but only if we are not already rounding the corners due to corner radius.
    lowp float size_factor = 0.5 * (minimum_shadow_radius / max(radius, minimum_shadow_radius));

    lowp float shadowRadius = radius + size * size_factor;

    lowp vec4 col = vec4(0.0);

    // Calculate the shadow's distance field.
    lowp float shadow = sdf_rounded_rectangle(uv, aspect * inverse_scale, offset * 2.0 * inverse_scale, vec4(shadowRadius * inverse_scale));
    // Render it, interpolating the color over the distance.
    col = mix(col, shadowColor * sign(size), 1.0 - smoothstep(-size * 0.5, size * 0.5, shadow));

    // Calculate the main rectangle distance field.
    lowp float rect = sdf_rounded_rectangle(uv, aspect * inverse_scale, vec2(0.0), vec4(radius * inverse_scale));

    lowp float g = fwidth(rect);

    // First, remove anything that was rendered by the shadow if it is inside the rectangle.
    // This allows us to use colors with alpha without rendering artifacts.
    col = mix(col, vec4(0.0), 1.0 - smoothstep(0.001 - g, 0.001 + g, rect));

    // Then, render it again but this time with the proper color and properly alpha blended.
    col = mix(col, color, 1.0 - smoothstep(0.001 - g, 0.001 + g, rect));

    gl_FragColor = col * opacity;
}
