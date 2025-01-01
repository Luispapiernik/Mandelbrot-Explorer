const builtin = @import("builtin");
const std = @import("std");

const rl = @import("raylib");

const colors = @import("colors.zig");
const geometry = @import("geometry.zig");
const shaders = @import("shaders.zig");

const FALSE: i32 = -1;
const TRUE: i32 = 1;

pub fn main() anyerror!void {
    // Setting this to cero will start window with monitor width and height
    // but for our coordinates transformation, we need to set it to a fixed value
    // after initialization
    var width: i32 = 0;
    var height: i32 = 0;

    if (builtin.target.isWasm()) {
        const args = try std.process.argsAlloc(std.heap.c_allocator);
        defer std.process.argsFree(std.heap.c_allocator, args);

        width = try std.fmt.parseInt(i32, args[1], 10);
        height = try std.fmt.parseInt(i32, args[2], 10);
    }

    var settings = GlobalSettings{
        .screenWidthLoc = undefined,
        .screenHeightLoc = undefined,
        .maxIterationsLoc = undefined,
        .smoothVelocityLoc = undefined,
        .shader = undefined,
        .screenWidth = width,
        .screenHeight = height,
        .maxIterations = GlobalSettings.DEFAULT_MAX_ITERATIONS,
        .smoothVelocity = FALSE,
    };

    const configFlags: rl.ConfigFlags = rl.ConfigFlags{ .msaa_4x_hint = true, .fullscreen_mode = false };
    rl.setConfigFlags(configFlags);

    // TODO: Initializing with zero is introducing a where translation bug in the y axis
    rl.initWindow(settings.screenWidth, settings.screenHeight, settings.title);
    defer rl.closeWindow();

    // If we call this before window initialization, we get cero values
    settings.screenWidth = rl.getScreenWidth();
    settings.screenHeight = rl.getScreenHeight();

    const mandelbrotShader: rl.Shader = shaders.loadMandelbrotShader();
    defer rl.unloadShader(mandelbrotShader);

    var visor = geometry.Visor.init(mandelbrotShader);
    visor.loadView();

    settings.setSettingsLocations(mandelbrotShader);
    settings.loadSettings();

    var colorManager = colors.ColorManager.init(mandelbrotShader);
    colorManager.setColor(0);

    rl.setTargetFPS(GlobalSettings.FPS);
    while (!rl.windowShouldClose()) {
        const mouseWheelDelta: rl.Vector2 = rl.getMouseWheelMoveV();
        const mousePosition = rl.getMousePosition();

        // This are the position of the mouse mapped to the coordinate system
        // where the vertical axis goes from -1 to 1 bottom up, and horizontal, goes from -1 to 1 left to right
        const mouseX = (mousePosition.x - @as(f32, @floatFromInt(settings.screenWidth)) / 2) / (@as(f32, @floatFromInt(settings.screenWidth)) / 2);
        const mouseY = -1.0 * (mousePosition.y - @as(f32, @floatFromInt(settings.screenHeight)) / 2) / (@as(f32, @floatFromInt(settings.screenHeight)) / 2);

        // Color inputs
        if (rl.isKeyDown(rl.KeyboardKey.key_c)) {
            if (rl.isKeyPressed(rl.KeyboardKey.key_left)) {
                colorManager.switchToPreviousColor();
            } else if (rl.isKeyPressed(rl.KeyboardKey.key_right)) {
                colorManager.switchToNextColor();
            } else if (rl.isKeyPressed(rl.KeyboardKey.key_i)) {
                colorManager.invertColor *= -1;
                colorManager.setColor(colorManager.currentColor);
            } else if (rl.isKeyPressed(rl.KeyboardKey.key_r)) {
                colorManager.currentColor = 0;
                colorManager.setColor(colorManager.currentColor);
            }
        }

        // Coordinate transformations
        if (rl.isKeyDown(rl.KeyboardKey.key_m)) {
            var xDelta: f32 = 0;
            var yDelta: f32 = 0;
            var zoomFactor: f32 = 1;

            if (rl.isKeyDown(rl.KeyboardKey.key_left) or mouseWheelDelta.x > 0) {
                if (rl.isKeyDown(rl.KeyboardKey.key_z)) {
                    zoomFactor = 1.1;
                } else {
                    xDelta += 0.05;
                }
            }

            if (rl.isKeyDown(rl.KeyboardKey.key_right) or mouseWheelDelta.x < 0) {
                if (rl.isKeyDown(rl.KeyboardKey.key_z)) {
                    zoomFactor = 0.9;
                } else {
                    xDelta -= 0.05;
                }
            }

            if (rl.isKeyDown(rl.KeyboardKey.key_up) or mouseWheelDelta.y > 0) {
                if (rl.isKeyDown(rl.KeyboardKey.key_z)) {
                    zoomFactor = 0.9;
                } else {
                    yDelta += 0.05;
                }
            }

            if (rl.isKeyDown(rl.KeyboardKey.key_down) or mouseWheelDelta.y < 0) {
                if (rl.isKeyDown(rl.KeyboardKey.key_z)) {
                    zoomFactor = 1.1;
                } else {
                    yDelta -= 0.05;
                }
            }

            const xSensibility: f32 = if (@abs(mouseWheelDelta.x) > 0) 0.2 else 1;
            const ySensibility: f32 = if (@abs(mouseWheelDelta.y) > 0) 0.2 else 1;

            visor.translate(rl.Vector2{
                .x = xDelta * xSensibility,
                .y = yDelta * ySensibility,
            });
            visor.zoom(zoomFactor, mouseX, mouseY);

            if (rl.isKeyPressed(rl.KeyboardKey.key_r)) {
                visor.reset();
            }
        }

        // Iterations
        if (rl.isKeyDown(rl.KeyboardKey.key_i)) {
            if (rl.isKeyPressed(rl.KeyboardKey.key_s)) {
                settings.smoothVelocity *= -1;
                settings.loadSettings();
            }

            if (rl.isKeyDown(rl.KeyboardKey.key_left)) {
                settings.maxIterations = if (settings.maxIterations > 10) settings.maxIterations - 10 else 1;
                settings.loadSettings();
            }
            if (rl.isKeyDown(rl.KeyboardKey.key_right)) {
                settings.maxIterations += 10;
                settings.loadSettings();
            }

            if (rl.isKeyPressed(rl.KeyboardKey.key_r)) {
                settings.reset();
                settings.loadSettings();
            }
        }

        // Copy coordinate params to the shader
        visor.loadView();

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.ray_white);
        shaders.executeShader(
            mandelbrotShader,
            settings.screenWidth,
            settings.screenHeight,
        );

        rl.drawFPS(10, 10);
    }
}

const GlobalSettings = struct {
    const DEFAULT_MAX_ITERATIONS: i32 = 100;
    const FPS: i32 = 60;

    title: [*:0]const u8 = "Mandelbrot Explorer",

    shader: rl.Shader,

    screenWidth: i32,
    screenHeight: i32,
    maxIterations: i32,
    smoothVelocity: i32,

    screenWidthLoc: i32,
    screenHeightLoc: i32,
    maxIterationsLoc: i32,
    smoothVelocityLoc: i32,

    pub fn setSettingsLocations(self: *GlobalSettings, shader: rl.Shader) void {
        self.shader = shader;

        self.screenWidthLoc = rl.getShaderLocation(
            shader,
            "screenWidth",
        );
        self.screenHeightLoc = rl.getShaderLocation(
            shader,
            "screenHeight",
        );
        self.maxIterationsLoc = rl.getShaderLocation(
            shader,
            "maxIterations",
        );
        self.smoothVelocityLoc = rl.getShaderLocation(
            shader,
            "smoothVelocity",
        );
    }

    pub fn loadSettings(self: *GlobalSettings) void {
        rl.setShaderValue(
            self.shader,
            self.screenWidthLoc,
            &self.screenWidth,
            rl.ShaderUniformDataType.shader_uniform_int,
        );
        rl.setShaderValue(
            self.shader,
            self.screenHeightLoc,
            &self.screenHeight,
            rl.ShaderUniformDataType.shader_uniform_int,
        );
        rl.setShaderValue(
            self.shader,
            self.maxIterationsLoc,
            &self.maxIterations,
            rl.ShaderUniformDataType.shader_uniform_int,
        );
        rl.setShaderValue(
            self.shader,
            self.smoothVelocityLoc,
            &self.smoothVelocity,
            rl.ShaderUniformDataType.shader_uniform_int,
        );
    }

    pub fn reset(self: *GlobalSettings) void {
        self.maxIterations = GlobalSettings.DEFAULT_MAX_ITERATIONS;
        self.smoothVelocity = FALSE;

        self.loadSettings();
    }

    pub fn showFields(self: *GlobalSettings) void {
        std.debug.print("screenWidth: {}\n", .{self.screenWidth});
        std.debug.print("screenHeight: {}\n", .{self.screenHeight});
        std.debug.print("maxIterations: {}\n", .{self.maxIterations});
        std.debug.print("smoothVelocity: {}\n", .{self.smoothVelocity});
    }
};
