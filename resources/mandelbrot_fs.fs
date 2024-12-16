#version 330 core

// Inputs from the vertex shader
in vec2 fragTexCoord;  // Texture coordinates
in vec4 fragColor;     // Vertex color
in vec2 coord;         // Vertex position

// uniforms
uniform int screenWidth;
uniform int screenHeight;
uniform float xOffset;
uniform float yOffset;
uniform float zoomLevel;

out vec4 finalFragColor;

// TODO: Change this to be a uniform
#define MAX_ITERATIONS 50

int get_scape_velocity(){
    float aspectRatio = float(screenWidth) / float(screenHeight);
    float initial_x = aspectRatio * coord.x;
    float initial_y = coord.y;

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
    float aspectRatio = float(screenWidth) / float(screenHeight);
    float initial_x = aspectRatio * coord.x + xOffset;
    float initial_y = coord.y + yOffset;

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
    float t = get_smooth_scape_velocity() / float(MAX_ITERATIONS);
    finalFragColor = vec4(t, 0.0, 0.0, 1.0);
}
