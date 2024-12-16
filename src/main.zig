const std = @import("std");
const rl = @import("raylib");

pub fn main() anyerror!void {
    rl.initWindow(1000, 1000, "Mandelbrot Explorer");
    defer rl.closeWindow();

    const screenWidth = rl.getScreenWidth();
    const screenHeight = rl.getScreenHeight();

    const mandelbrotShader: rl.Shader = rl.loadShader("resources/mandelbrot_vs.fs", "resources/mandelbrot_fs.fs");
    defer rl.unloadShader(mandelbrotShader);

    const camera = rl.Camera3D{
        // TODO: Need to do the math here to parametrize Z value based on the zoom level
        .position = rl.Vector3{ .x = 0, .y = 0, .z = 2 },
        .target = rl.Vector3{ .x = 0, .y = 0, .z = 0 },
        .up = rl.Vector3{ .x = 0, .y = 1, .z = 0 },
        .fovy = 45.0,
        .projection = rl.CameraProjection.camera_perspective,
    };
    const mvp = rl.getCameraMatrix(camera);
    var xOffset: f32 = 0;
    var yOffset: f32 = 0;
    var zoomLevel: f32 = 1.0;

    // Shader locations
    const screenWidthLoc = rl.getShaderLocation(mandelbrotShader, "screenWidth");
    const screenHeightLoc = rl.getShaderLocation(mandelbrotShader, "screenHeight");
    const mvpLoc = rl.getShaderLocation(mandelbrotShader, "mvp");
    const xOffsetLoc = rl.getShaderLocation(mandelbrotShader, "xOffset");
    const yOffsetLoc = rl.getShaderLocation(mandelbrotShader, "yOffset");
    const zoomLevelLoc = rl.getShaderLocation(mandelbrotShader, "zoomLevel");

    rl.setShaderValue(mandelbrotShader, xOffsetLoc, &xOffset, rl.ShaderUniformDataType.shader_uniform_float);
    rl.setShaderValue(mandelbrotShader, yOffsetLoc, &yOffset, rl.ShaderUniformDataType.shader_uniform_float);
    rl.setShaderValue(mandelbrotShader, zoomLevelLoc, &zoomLevel, rl.ShaderUniformDataType.shader_uniform_float);
    rl.setShaderValue(mandelbrotShader, screenWidthLoc, &screenWidth, rl.ShaderUniformDataType.shader_uniform_int);
    rl.setShaderValue(mandelbrotShader, screenHeightLoc, &screenHeight, rl.ShaderUniformDataType.shader_uniform_int);
    rl.setShaderValueMatrix(mandelbrotShader, mvpLoc, mvp);

    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        const mov: rl.Vector2 = rl.getMouseWheelMoveV();

        if (rl.isKeyPressed(rl.KeyboardKey.key_r)) {
            xOffset = 0;
            yOffset = 0;
        } else if (rl.isKeyDown(rl.KeyboardKey.key_z)) {
            zoomLevel += mov.y * 0.1 + mov.x * 0.1;
            std.debug.print("Zoom level: {}\n", .{zoomLevel});
        } else {
            xOffset += mov.x * 0.1;
            yOffset += mov.y * 0.1;
        }

        rl.setShaderValue(mandelbrotShader, xOffsetLoc, &xOffset, rl.ShaderUniformDataType.shader_uniform_float);
        rl.setShaderValue(mandelbrotShader, yOffsetLoc, &yOffset, rl.ShaderUniformDataType.shader_uniform_float);

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.ray_white);
        {
            rl.beginShaderMode(mandelbrotShader);
            defer rl.endShaderMode();

            rl.drawRectangle(0, 0, screenWidth, screenHeight, rl.Color.ray_white);
        }
        rl.drawFPS(10, 10);
    }
}
