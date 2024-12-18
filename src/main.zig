const std = @import("std");
const rl = @import("raylib");

pub fn main() anyerror!void {
    rl.initWindow(1000, 1000, "Mandelbrot Explorer");
    defer rl.closeWindow();

    const screenWidth = rl.getScreenWidth();
    const screenHeight = rl.getScreenHeight();
    std.debug.print("Screen width: {}\n", .{screenWidth});
    std.debug.print("Screen height: {}\n", .{screenHeight});

    const mandelbrotShader: rl.Shader = rl.loadShader("resources/mandelbrot_vs.fs", "resources/mandelbrot_fs.fs");
    defer rl.unloadShader(mandelbrotShader);

    const camera = rl.Camera3D{
        .position = rl.Vector3{ .x = 0, .y = 0, .z = 2 },
        .target = rl.Vector3{ .x = 0, .y = 0, .z = 0 },
        .up = rl.Vector3{ .x = 0, .y = 1, .z = 0 },
        .fovy = 45.0,
        .projection = rl.CameraProjection.camera_perspective,
    };
    const mvp = rl.getCameraMatrix(camera);
    var xi: f32 = -1;
    var xf: f32 = 1;
    var yi: f32 = -1;
    var yf: f32 = 1;
    var centerX: f32 = 0;
    var centerY: f32 = 0;

    // Shader locations
    const screenWidthLoc = rl.getShaderLocation(mandelbrotShader, "screenWidth");
    const screenHeightLoc = rl.getShaderLocation(mandelbrotShader, "screenHeight");
    const mvpLoc = rl.getShaderLocation(mandelbrotShader, "mvp");
    const xiLoc = rl.getShaderLocation(mandelbrotShader, "xi");
    const xfLoc = rl.getShaderLocation(mandelbrotShader, "xf");
    const yiLoc = rl.getShaderLocation(mandelbrotShader, "yi");
    const yfLoc = rl.getShaderLocation(mandelbrotShader, "yf");

    rl.setShaderValue(mandelbrotShader, xiLoc, &xi, rl.ShaderUniformDataType.shader_uniform_float);
    rl.setShaderValue(mandelbrotShader, xfLoc, &xf, rl.ShaderUniformDataType.shader_uniform_float);
    rl.setShaderValue(mandelbrotShader, yiLoc, &yi, rl.ShaderUniformDataType.shader_uniform_float);
    rl.setShaderValue(mandelbrotShader, yfLoc, &yf, rl.ShaderUniformDataType.shader_uniform_float);
    rl.setShaderValue(mandelbrotShader, screenWidthLoc, &screenWidth, rl.ShaderUniformDataType.shader_uniform_int);
    rl.setShaderValue(mandelbrotShader, screenHeightLoc, &screenHeight, rl.ShaderUniformDataType.shader_uniform_int);
    rl.setShaderValueMatrix(mandelbrotShader, mvpLoc, mvp);
    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        const mov: rl.Vector2 = rl.getMouseWheelMoveV();
        const mousePosition = rl.getMousePosition();

        // This are the real positions
        const mouseX = (mousePosition.x - @as(f32, @floatFromInt(screenWidth)) / 2) / (@as(f32, @floatFromInt(screenWidth)) / 2);
        const mouseY = -1.0 * (mousePosition.y - @as(f32, @floatFromInt(screenHeight)) / 2) / (@as(f32, @floatFromInt(screenHeight)) / 2);

        if (rl.isKeyPressed(rl.KeyboardKey.key_r)) {
            xi = -1;
            xf = 1;
            yi = -1;
            yf = 1;
            centerX = 0;
            centerY = 0;
        } else if (rl.isKeyDown(rl.KeyboardKey.key_z)) {
            if (@abs(mov.y) > 0 or @abs(mov.x) > 0) {
                const zoomFactor: f32 = if ((mov.y + mov.x) >= 0) 0.9 else 1.1;
                const oldMouseX = xi + (xf - xi) * (mouseX + 1) / 2;
                const oldMouseY = yi + (yf - yi) * (mouseY + 1) / 2;

                xi = (xi - centerX) * zoomFactor + centerX;
                xf = (xf - centerX) * zoomFactor + centerX;
                yi = (yi - centerY) * zoomFactor + centerY;
                yf = (yf - centerY) * zoomFactor + centerY;

                const newMouseX = xi + (xf - xi) * (mouseX + 1) / 2;
                const newMouseY = yi + (yf - yi) * (mouseY + 1) / 2;

                centerX += oldMouseX - newMouseX;
                centerY += oldMouseY - newMouseY;

                xi += oldMouseX - newMouseX;
                xf += oldMouseX - newMouseX;
                yi += oldMouseY - newMouseY;
                yf += oldMouseY - newMouseY;
            }
        } else {
            const movFactor: f32 = 0.1;
            xi += movFactor * mov.x;
            xf += movFactor * mov.x;
            yi += movFactor * mov.y;
            yf += movFactor * mov.y;
            centerX += movFactor * mov.x;
            centerY += movFactor * mov.y;
        }

        rl.setShaderValue(mandelbrotShader, xiLoc, &xi, rl.ShaderUniformDataType.shader_uniform_float);
        rl.setShaderValue(mandelbrotShader, xfLoc, &xf, rl.ShaderUniformDataType.shader_uniform_float);
        rl.setShaderValue(mandelbrotShader, yiLoc, &yi, rl.ShaderUniformDataType.shader_uniform_float);
        rl.setShaderValue(mandelbrotShader, yfLoc, &yf, rl.ShaderUniformDataType.shader_uniform_float);

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
