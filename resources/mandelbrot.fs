#version 330 core

// Inputs from the vertex shader
in vec2 fragTexCoord;  // Texture coordinates
in vec4 fragColor;     // Vertex color
in vec2 coord;         // Vertex position

// uniforms
uniform int screenWidth;
uniform int screenHeight;
uniform float xi;
uniform float xf;
uniform float yi;
uniform float yf;

out vec4 finalFragColor;

// TODO: Change this to be a uniform
#define MAX_ITERATIONS 1000

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
    for (int i = 0; i <= MAX_ITERATIONS; i++){
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
    for (int i = 0; i <= MAX_ITERATIONS; i++){
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
    float t = get_scape_velocity() / float(MAX_ITERATIONS);
    finalFragColor = vec4(t, 0.0, 0.0, 1.0);
}
