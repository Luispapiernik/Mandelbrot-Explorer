#version 330 core

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

int get_scape_velocity(){
    // This is the point we are actually calculating the scape velocity for
    float initial_x = coord.x;
    float initial_y =  coord.y;

    // We need to take into account non square screens
    if (screenHeight > screenWidth){
        initial_x = initial_x * float(screenWidth) / float(screenHeight);
    } else {
        initial_y = initial_y * float(screenHeight) / float(screenWidth);
    }

    // We need to take into account the zoom and the translation
    initial_x = xi + (xf - xi) * (initial_x + 1) / 2;
    initial_y = yi + (yf - yi) * (initial_y + 1) / 2;

    float current_x = 0;
    float current_y = 0;
    int scape_velocity = 0;

    float x2, y2;
    for (int i = 0; i <= maxIterations; i++){
        x2 = current_x * current_x;
        y2 = current_y * current_y;

        if (x2 + y2 > 4){
            scape_velocity = i;
            break;
        }

        current_y = 2 * current_x * current_y + initial_y;
        current_x = x2 - y2 + initial_x;
        scape_velocity = i;
    }

    return scape_velocity;
}


float get_smooth_scape_velocity() {
    // This is the point we are actually calculating the scape velocity for
    float initial_x = coord.x;
    float initial_y = coord.y;

    // We need to take into account non square screens
    if (screenHeight > screenWidth){
        initial_x = initial_x * float(screenWidth) / float(screenHeight);
    } else {
        initial_y = initial_y * float(screenHeight) / float(screenWidth);
    }

    // We need to take into account the zoom and the translation
    initial_x = xi + (xf - xi) * (initial_x + 1) / 2;
    initial_y = yi + (yf - yi) * (initial_y + 1) / 2;

    float current_x = 0;
    float current_y = 0;
    float scape_velocity = 0;

    float x2, y2;
    for (int i = 0; i <= maxIterations; i++){
        x2 = current_x * current_x;
        y2 = current_y * current_y;

        if (x2 + y2 > 4){
            scape_velocity = i + 1 - log(log(sqrt(x2 + y2))) / log(2);
            break;
        }

        current_y = 2 * current_x * current_y + initial_y;
        current_x = x2 - y2 + initial_x;
        scape_velocity = i;
    }

    return scape_velocity;
}

void main()
{
    float t;
    if (smoothVelocity == 1) {
        t = get_smooth_scape_velocity() / float(maxIterations);
    } else {
        t = get_scape_velocity() / float(maxIterations);
    }

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
