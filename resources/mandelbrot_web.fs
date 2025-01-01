#version 100

#define CRAZY_MAX_ITERATION 100000
#define MAX_SEGMENTS 10

precision mediump float;

// Inputs from the vertex shader
varying vec2 fragTexCoord;  // Texture coordinates
varying vec4 fragColor;     // Vertex color
varying vec2 coord;         // Vertex position

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

struct Segment {
    float x;
    float iColor;
    float fColor;
};

Segment redSegments[MAX_SEGMENTS];
Segment greenSegments[MAX_SEGMENTS];
Segment blueSegments[MAX_SEGMENTS];

// Generate interpolate functions for different sizes
float interpolate_10(float x, Segment[MAX_SEGMENTS] segments) {
    for (int i = 0; i < MAX_SEGMENTS - 1; i++) {
        if (segments[i].x <= x && x <= segments[i + 1].x) {
            float colorLength = segments[i + 1].iColor - segments[i].fColor;
            float xLength = segments[i + 1].x - segments[i].x;
            return segments[i].fColor + colorLength * (x - segments[i].x) / xLength;
        }
    }
    return segments[MAX_SEGMENTS - 1].fColor; // Return the last color if x is out of bounds
}

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
    initial_x = xi + (xf - xi) * (initial_x + 1.0) / 2.0;
    initial_y = yi + (yf - yi) * (initial_y + 1.0) / 2.0;

    float current_x = 0.0;
    float current_y = 0.0;
    int scape_velocity = 0;

    float x2, y2;
    for (int i = 0; i <= CRAZY_MAX_ITERATION; i++){
        // gsl 100 just allows constant to be in the loop
        // this break is a workaround
        if (i >= maxIterations) {
            break;
        }

        x2 = current_x * current_x;
        y2 = current_y * current_y;

        if (x2 + y2 > 4.0){
            scape_velocity = i;
            break;
        }

        current_y = 2.0 * current_x * current_y + initial_y;
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
    initial_x = xi + (xf - xi) * (initial_x + 1.0) / 2.0;
    initial_y = yi + (yf - yi) * (initial_y + 1.0) / 2.0;

    float current_x = 0.0;
    float current_y = 0.0;
    float scape_velocity = 0.0;

    float x2, y2;
    for (int i = 0; i <= CRAZY_MAX_ITERATION; i++){
        // gsl 100 just allows constant to be in the loop
        // this break is a workaround
        if (i >= maxIterations) {
            break;
        }
        x2 = current_x * current_x;
        y2 = current_y * current_y;

        if (x2 + y2 > 4.0){
            scape_velocity = float(i) + 1.0 - log(log(sqrt(x2 + y2))) / log(2.0);
            break;
        }

        current_y = 2.0 * current_x * current_y + initial_y;
        current_x = x2 - y2 + initial_x;
        scape_velocity = float(i);
    }

    return scape_velocity;
}

void main()
{
    float t;
    if (smoothVelocity == 1) {
        t = get_smooth_scape_velocity() / float(maxIterations);
    } else {
        t = float(get_scape_velocity()) / float(maxIterations);
    }

    // initialize red segments
    for (int i = 0; i < MAX_SEGMENTS; i++) {
        if (i >= redSegmentsSize) {
            break;
        }

        redSegments[i] = Segment(colors[i].x, colors[i].y, colors[i].z);
    }

    int realIndex;
    // initialize green segments
    for (int i = 0; i < MAX_SEGMENTS; i++) {
        if (i >= greenSegmentsSize) {
            break;
        }

        realIndex = i + redSegmentsSize;
        if (realIndex == 0) {
            greenSegments[i] = Segment(colors[0].x, colors[0].y, colors[0].z);
        } else if (realIndex == 1) {
            greenSegments[i] = Segment(colors[1].x, colors[1].y, colors[1].z);
        } else if (realIndex == 2) {
            greenSegments[i] = Segment(colors[2].x, colors[2].y, colors[2].z);
        } else if (realIndex == 3) {
            greenSegments[i] = Segment(colors[3].x, colors[3].y, colors[3].z);
        } else if (realIndex == 4) {
            greenSegments[i] = Segment(colors[4].x, colors[4].y, colors[4].z);
        } else if (realIndex == 5) {
            greenSegments[i] = Segment(colors[5].x, colors[5].y, colors[5].z);
        } else if (realIndex == 6) {
            greenSegments[i] = Segment(colors[6].x, colors[6].y, colors[6].z);
        } else if (realIndex == 7) {
            greenSegments[i] = Segment(colors[7].x, colors[7].y, colors[7].z);
        } else if (realIndex == 8) {
            greenSegments[i] = Segment(colors[8].x, colors[8].y, colors[8].z);
        } else if (realIndex == 9) {
            greenSegments[i] = Segment(colors[9].x, colors[9].y, colors[9].z);
        } else if (realIndex == 10) {
            greenSegments[i] = Segment(colors[10].x, colors[10].y, colors[10].z);
        } else if (realIndex == 11) {
            greenSegments[i] = Segment(colors[11].x, colors[11].y, colors[11].z);
        } else if (realIndex == 12) {
            greenSegments[i] = Segment(colors[12].x, colors[12].y, colors[12].z);
        } else if (realIndex == 13) {
            greenSegments[i] = Segment(colors[13].x, colors[13].y, colors[13].z);
        } else if (realIndex == 14) {
            greenSegments[i] = Segment(colors[14].x, colors[14].y, colors[14].z);
        } else if (realIndex == 15) {
            greenSegments[i] = Segment(colors[15].x, colors[15].y, colors[15].z);
        } else if (realIndex == 16) {
            greenSegments[i] = Segment(colors[16].x, colors[16].y, colors[16].z);
        } else if (realIndex == 17) {
            greenSegments[i] = Segment(colors[17].x, colors[17].y, colors[17].z);
        } else if (realIndex == 18) {
            greenSegments[i] = Segment(colors[18].x, colors[18].y, colors[18].z);
        } else if (realIndex == 19) {
            greenSegments[i] = Segment(colors[19].x, colors[19].y, colors[19].z);
        } else if (realIndex == 20) {
            greenSegments[i] = Segment(colors[20].x, colors[20].y, colors[20].z);
        } else if (realIndex == 21) {
            greenSegments[i] = Segment(colors[21].x, colors[21].y, colors[21].z);
        } else if (realIndex == 22) {
            greenSegments[i] = Segment(colors[22].x, colors[22].y, colors[22].z);
        } else if (realIndex == 23) {
            greenSegments[i] = Segment(colors[23].x, colors[23].y, colors[23].z);
        } else if (realIndex == 24) {
            greenSegments[i] = Segment(colors[24].x, colors[24].y, colors[24].z);
        } else if (realIndex == 25) {
            greenSegments[i] = Segment(colors[25].x, colors[25].y, colors[25].z);
        } else if (realIndex == 26) {
            greenSegments[i] = Segment(colors[26].x, colors[26].y, colors[26].z);
        } else if (realIndex == 27) {
            greenSegments[i] = Segment(colors[27].x, colors[27].y, colors[27].z);
        } else if (realIndex == 28) {
            greenSegments[i] = Segment(colors[28].x, colors[28].y, colors[28].z);
        } else if (realIndex == 29) {
            greenSegments[i] = Segment(colors[29].x, colors[29].y, colors[29].z);
        } else if (realIndex == 30) {
            // greenSegments[i] = Segment(colors[30].x, colors[30].y, colors[30].z);
        }
    }

    // initialize blue segments
    for (int i = 0; i < MAX_SEGMENTS; i++) {
        if (i >= blueSegmentsSize) {
            break;
        }

        realIndex = i + redSegmentsSize + greenSegmentsSize;
        if (realIndex == 0) {
            blueSegments[i] = Segment(colors[0].x, colors[0].y, colors[0].z);
        } else if (realIndex == 1) {
            blueSegments[i] = Segment(colors[1].x, colors[1].y, colors[1].z);
        } else if (realIndex == 2) {
            blueSegments[i] = Segment(colors[2].x, colors[2].y, colors[2].z);
        } else if (realIndex == 3) {
            blueSegments[i] = Segment(colors[3].x, colors[3].y, colors[3].z);
        } else if (realIndex == 4) {
            blueSegments[i] = Segment(colors[4].x, colors[4].y, colors[4].z);
        } else if (realIndex == 5) {
            blueSegments[i] = Segment(colors[5].x, colors[5].y, colors[5].z);
        } else if (realIndex == 6) {
            blueSegments[i] = Segment(colors[6].x, colors[6].y, colors[6].z);
        } else if (realIndex == 7) {
            blueSegments[i] = Segment(colors[7].x, colors[7].y, colors[7].z);
        } else if (realIndex == 8) {
            blueSegments[i] = Segment(colors[8].x, colors[8].y, colors[8].z);
        } else if (realIndex == 9) {
            blueSegments[i] = Segment(colors[9].x, colors[9].y, colors[9].z);
        } else if (realIndex == 10) {
            blueSegments[i] = Segment(colors[10].x, colors[10].y, colors[10].z);
        } else if (realIndex == 11) {
            blueSegments[i] = Segment(colors[11].x, colors[11].y, colors[11].z);
        } else if (realIndex == 12) {
            blueSegments[i] = Segment(colors[12].x, colors[12].y, colors[12].z);
        } else if (realIndex == 13) {
            blueSegments[i] = Segment(colors[13].x, colors[13].y, colors[13].z);
        } else if (realIndex == 14) {
            blueSegments[i] = Segment(colors[14].x, colors[14].y, colors[14].z);
        } else if (realIndex == 15) {
            blueSegments[i] = Segment(colors[15].x, colors[15].y, colors[15].z);
        } else if (realIndex == 16) {
            blueSegments[i] = Segment(colors[16].x, colors[16].y, colors[16].z);
        } else if (realIndex == 17) {
            blueSegments[i] = Segment(colors[17].x, colors[17].y, colors[17].z);
        } else if (realIndex == 18) {
            blueSegments[i] = Segment(colors[18].x, colors[18].y, colors[18].z);
        } else if (realIndex == 19) {
            blueSegments[i] = Segment(colors[19].x, colors[19].y, colors[19].z);
        } else if (realIndex == 20) {
            blueSegments[i] = Segment(colors[20].x, colors[20].y, colors[20].z);
        } else if (realIndex == 21) {
            blueSegments[i] = Segment(colors[21].x, colors[21].y, colors[21].z);
        } else if (realIndex == 22) {
            blueSegments[i] = Segment(colors[22].x, colors[22].y, colors[22].z);
        } else if (realIndex == 23) {
            blueSegments[i] = Segment(colors[23].x, colors[23].y, colors[23].z);
        } else if (realIndex == 24) {
            blueSegments[i] = Segment(colors[24].x, colors[24].y, colors[24].z);
        } else if (realIndex == 25) {
            blueSegments[i] = Segment(colors[25].x, colors[25].y, colors[25].z);
        } else if (realIndex == 26) {
            blueSegments[i] = Segment(colors[26].x, colors[26].y, colors[26].z);
        } else if (realIndex == 27) {
            blueSegments[i] = Segment(colors[27].x, colors[27].y, colors[27].z);
        } else if (realIndex == 28) {
            blueSegments[i] = Segment(colors[28].x, colors[28].y, colors[28].z);
        } else if (realIndex == 29) {
            blueSegments[i] = Segment(colors[29].x, colors[29].y, colors[29].z);
        } else if (realIndex == 30) {
            // blueSegments[i] = Segment(colors[30].x, colors[30].y, colors[30].z);
        }
        
    }

    float colorParameter = invertColor == 1 ? float(1) - t : t;

    vec3 color = vec3(
        interpolate_10(colorParameter, redSegments),
        interpolate_10(colorParameter, greenSegments),
        interpolate_10(colorParameter, blueSegments)
    );

    gl_FragColor = vec4(color, 1.0);
}
