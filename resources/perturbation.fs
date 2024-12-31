#version 330 core

precision highp float;
precision highp vec2;

#define DEFINE_INTERPOLATE_FUNCTION(N)                         \
float interpolate_##N(float x, Segment segments[N]) {          \
    for (int i = 0; i < N - 1; i++) {                          \
        if (segments[i].x <= x && x <= segments[i + 1].x) {    \
            float colorLength = segments[i + 1].iColor - segments[i].fColor; \
            float xLength = segments[i + 1].x - segments[i].x; \
            return segments[i].fColor + colorLength * (x - segments[i].x) / xLength; \
        }                                                     \
    }                                                         \
    return segments[N - 1].fColor;                            \
}

// Inputs from the vertex shader
in vec2 fragTexCoord;  // Texture coordinates
in vec4 fragColor;     // Vertex color
in vec2 coord;         // Vertex position

// uniforms
uniform int screenWidth;
uniform int screenHeight;
uniform int maxIterations;
uniform float xi;
uniform float xf;
uniform float yi;
uniform float yf;

#define ROWS 25
#define COLS 25
uniform vec2 referencePoints[ROWS * COLS];

uniform int redSegmentsSize;
uniform int greenSegmentsSize;
uniform int blueSegmentsSize;
uniform int invertColor;
uniform int smoothVelocity;
uniform vec3 colors[30];

out vec4 finalFragColor;

struct Segment {
    float x;
    float iColor;
    float fColor;
};

Segment[10] redSegments;
Segment[10] greenSegments;
Segment[10] blueSegments;

// Generate interpolate functions for different sizes
DEFINE_INTERPOLATE_FUNCTION(10)


vec2 cmul(vec2 a, vec2 b) {
    return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

vec2 get_current_point() {
    float x = coord.x;
    float y = coord.y;

    // Adjust for non-square screens
    if (screenHeight > screenWidth) {
        x = x * float(screenWidth) / float(screenHeight);
    } else {
        y = y * float(screenHeight) / float(screenWidth);
    }

    // Adjust for zoom and translation
    x = xi + (xf - xi) * (x + 1.0) / 2.0;
    y = yi + (yf - yi) * (y + 1.0) / 2.0;

    return vec2(x, y);
}


vec2 get_reference_point(vec2 current_point) {
    float xLength = (xf - xi) / float(COLS);
    float yLength = (yf - yi) / float(ROWS);

    int i = int((current_point.y - yi) / yLength);
    int j = int((current_point.x - xi) / xLength);

    i = clamp(i, 0, ROWS - 1);
    j = clamp(j, 0, COLS - 1);

    return referencePoints[i * COLS + j];
}


int get_scape_velocity(){
    vec2 a = vec2(1.0, 0.0);
    vec2 b = vec2(0.0, 0.0);
    vec2 c = vec2(0.0, 0.0);

    vec2 current_point = get_current_point();
    // vec2 reference_point = vec2(current_point.x - 1e-14, current_point.y);
    vec2 reference_point = get_reference_point(current_point);

    vec2 delta_0 = current_point - reference_point;

    vec2 z = vec2(0.0, 0.0);
    for (int i = 0; i <= maxIterations; i++){
        // This is Zn for the reference point
        z = cmul(z, z) + reference_point;

        // This is An, Bn and Cn for the DeltaN approximation
        c = 2 * cmul(z, c) + 2 * cmul(a, b);
        b = 2 * cmul(z, b) + cmul(a, a);
        a = 2 * cmul(z, a) + vec2(1.0, 0.0);

        // This is DeltaN to approximate Zn for the current point
        vec2 delta_n = cmul(a, delta_0) + cmul(b, cmul(delta_0, delta_0)) + cmul(c, cmul(delta_0, cmul(delta_0, delta_0)));

        // Checking just for DeltaN is equivalent to checking for Zn + DeltaN
        if (dot(delta_n, delta_n) > 4){
            return i;
        }
    }

    return maxIterations;
}


void main()
{
    float t = get_scape_velocity() / float(maxIterations);

    // initialize red segments
    for (int i = 0; i < redSegmentsSize; i++) {
        redSegments[i] = Segment(colors[i].x, colors[i].y, colors[i].z);
    }

    int realIndex;
    // initialize green segments
    for (int i = 0; i < greenSegmentsSize; i++) {
        realIndex = i + redSegmentsSize;
        greenSegments[i] = Segment(colors[realIndex].x, colors[realIndex].y, colors[realIndex].z);
    }

    // initialize blue segments
    for (int i = 0; i < blueSegmentsSize; i++) {
        realIndex = i + redSegmentsSize + greenSegmentsSize;
        blueSegments[i] = Segment(colors[realIndex].x, colors[realIndex].y, colors[realIndex].z);
    }

    float colorParameter = invertColor == 1 ? t : 1 - t;

    vec3 color = vec3(
        interpolate_10(colorParameter, redSegments),
        interpolate_10(colorParameter, greenSegments),
        interpolate_10(colorParameter, blueSegments)
    );

    finalFragColor = vec4(color, 1.0);
}
