
#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:fog.glsl>
#include <minecraft:dynamictransforms.glsl>
#include <minecraft:oit.glsl>
#include <minecraft:globals.glsl>

layout(location = 0) in float sphericalVertexDistance;
layout(location = 1) in float cylindricalVertexDistance;
layout(location = 2) in vec4 vertexColor;

#ifndef OIT_ALPHA_ONLY
layout(location = 0) out vec4 fragColor;
#endif

vec4 calculateFinalColor(vec4 color) {
    #ifdef OIT_ACCUMULATE
    color = sampleColorForAccumulation(color);
    vec4 fogColor = vec4(FogColor.rgb * color.a, FogColor.a);
    #else
    vec4 fogColor = FogColor;
    #endif

    return apply_fog(
        color,
        sphericalVertexDistance,
        cylindricalVertexDistance,
        FogEnvironmentalStart,
        FogEnvironmentalEnd,
        FogRenderDistanceStart,
        FogRenderDistanceEnd,
        fogColor
    );
}

void main() {
    vec4 color = vertexColor * ColorModulator;

    // Remove the entire hitbox: white, red, and blue parts.
    bool is_white_hitbox =
        color.r >= 0.9 && color.g >= 0.9 && color.b >= 0.9;

    bool is_red_vector =
        color.r >= 0.8 && color.g <= 0.2 && color.b <= 0.2;

    bool is_blue_vector =
        color.r <= 0.2 && color.g <= 0.2 && color.b >= 0.8;

    if (is_white_hitbox || is_red_vector || is_blue_vector) {
        discard;
    }

    #ifdef OIT_ALPHA_ONLY
    float color_a = color.a;
    if (color_a <= 0.5)
        color_a = 1;
    executeAlphaOnlyPhase(gl_FragCoord.z, color_a);
    #else
    fragColor = calculateFinalColor(color);
    #endif
}
