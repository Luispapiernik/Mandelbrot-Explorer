#version 100

precision mediump float;

// Input attributes from raylib Mesh
attribute vec3 vertexPosition;
attribute vec4 vertexColor;
attribute vec2 vertexTexCoord;

// Extra attributes from CPU
uniform mat4 mvp;

// Outputs to the fragment shader
varying vec2 fragTexCoord;
varying vec4 fragColor;
varying vec2 coord;

void main()
{
    gl_Position = mvp * vec4(vertexPosition, 1.0);

    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;

    coord = gl_Position.xy;
}
