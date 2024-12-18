#version 100

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

#define CRAZY_MAX_ITERATION 100000


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
    float t = get_smooth_scape_velocity() / float(maxIterations);
    gl_FragColor = vec4(t, 0.0, 0.0, 1.0);
}
