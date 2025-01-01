const builtin = @import("builtin");

const rl = @import("raylib");

const colors = @import("colors.zig");

pub fn loadMandelbrotShader() rl.Shader {
    // TODO: Actually the web version works also for desktop, not changing
    // it still because in the future we might want to use specific  features on version 100
    var vertexShaderPath: ?[*:0]const u8 = "resources/mandelbrot.vs";
    var fragmentShaderPath: ?[*:0]const u8 = "resources/mandelbrot.fs";
    if (builtin.target.isWasm()) {
        vertexShaderPath = "resources/mandelbrot_web.vs";
        fragmentShaderPath = "resources/mandelbrot_web.fs";
    }

    return rl.loadShader(vertexShaderPath, fragmentShaderPath);
}

pub fn executeShader(shader: rl.Shader, screenWidth: i32, screenHeight: i32) void {
    rl.beginShaderMode(shader);
    defer rl.endShaderMode();

    rl.drawRectangle(
        0,
        0,
        screenWidth,
        screenHeight,
        rl.Color.ray_white,
    );
}