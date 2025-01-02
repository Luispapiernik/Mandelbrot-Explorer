#version 330 core

precision highp float;
precision highp vec2;
precision highp vec4;

// Input attributes from Raylib Mesh/ From vertex attributes
in vec3 vertexPosition;
in vec4 vertexColor;
in vec2 vertexTexCoord;

// Extra attributes from CPU
uniform mat4 mvp;

// Outputs to the fragment shader
out vec2 fragTexCoord;
out vec4 fragColor;
out vec2 coord;

void main()
{
    gl_Position = mvp * vec4(vertexPosition, 1.0);

    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;

    coord = gl_Position.xy;
}
