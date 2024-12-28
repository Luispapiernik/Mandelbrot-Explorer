const std = @import("std");
const rl = @import("raylib");
const builtin = @import("builtin");
const colorsMaps = @import("colors.zig");

const GlobalSettings = struct {
    // Setting this to cero will start window with monitor width and height
    // but for our coordinates transformation, we need to set it to a fixed value
    // after initialization
    screenWidth: i32 = 0,
    screenHeight: i32 = 0,
    maxIterations: i32 = 100,
    smoothVelocity: i32 = -1,

    title: [*:0]const u8 = "Mandelbrot Explorer",

    screenWidthLoc: i32,
    screenHeightLoc: i32,
    maxIterationsLoc: i32,
    smoothVelocityLoc: i32,

    pub fn setLocations(self: *GlobalSettings, mandelbrotShader: rl.Shader) void {
        self.screenWidthLoc = rl.getShaderLocation(
            mandelbrotShader,
            "screenWidth",
        );
        self.screenHeightLoc = rl.getShaderLocation(
            mandelbrotShader,
            "screenHeight",
        );
        self.maxIterationsLoc = rl.getShaderLocation(
            mandelbrotShader,
            "maxIterations",
        );
        self.smoothVelocityLoc = rl.getShaderLocation(
            mandelbrotShader,
            "smoothVelocity",
        );
    }

    pub fn loadSettings(self: *GlobalSettings, mandelbrotShader: rl.Shader) void {
        rl.setShaderValue(
            mandelbrotShader,
            self.screenWidthLoc,
            &self.screenWidth,
            rl.ShaderUniformDataType.shader_uniform_int,
        );
        rl.setShaderValue(
            mandelbrotShader,
            self.screenHeightLoc,
            &self.screenHeight,
            rl.ShaderUniformDataType.shader_uniform_int,
        );
        rl.setShaderValue(
            mandelbrotShader,
            self.maxIterationsLoc,
            &self.maxIterations,
            rl.ShaderUniformDataType.shader_uniform_int,
        );
        rl.setShaderValue(
            mandelbrotShader,
            self.smoothVelocityLoc,
            &self.smoothVelocity,
            rl.ShaderUniformDataType.shader_uniform_int,
        );
    }

    pub fn reset(self: *GlobalSettings) void {
        self.maxIterations = 100;
        self.smoothVelocity = -1;
    }

    pub fn showFields(self: *GlobalSettings) void {
        std.debug.print("screenWidth: {}\n", .{self.screenWidth});
        std.debug.print("screenHeight: {}\n", .{self.screenHeight});
        std.debug.print("maxIterations: {}\n", .{self.maxIterations});
        std.debug.print("screenWidthLoc: {}\n", .{self.screenWidthLoc});
        std.debug.print("screenHeightLoc: {}\n", .{self.screenHeightLoc});
        std.debug.print("maxIterationsLoc: {}\n", .{self.maxIterationsLoc});
    }
};

const Visor = struct {
    const initialXI: f32 = -2;
    const initialXF: f32 = 2;
    const initialYI: f32 = -2;
    const initialYF: f32 = 2;

    xi: f32 = Visor.initialXI,
    xf: f32 = Visor.initialXF,
    yi: f32 = Visor.initialYI,
    yf: f32 = Visor.initialYF,

    centerX: f32 = 0,
    centerY: f32 = 0,

    xiLoc: i32,
    xfLoc: i32,
    yiLoc: i32,
    yfLoc: i32,

    pub fn init(mandelbrotShader: rl.Shader) Visor {
        const xiLoc = rl.getShaderLocation(mandelbrotShader, "xi");
        const xfLoc = rl.getShaderLocation(mandelbrotShader, "xf");
        const yiLoc = rl.getShaderLocation(mandelbrotShader, "yi");
        const yfLoc = rl.getShaderLocation(mandelbrotShader, "yf");

        return Visor{ .xiLoc = xiLoc, .xfLoc = xfLoc, .yiLoc = yiLoc, .yfLoc = yfLoc };
    }

    pub fn reset(self: *Visor) void {
        self.xi = Visor.initialXI;
        self.xf = Visor.initialXF;
        self.yi = Visor.initialYI;
        self.yf = Visor.initialYF;
        self.centerX = 0;
        self.centerY = 0;
    }

    pub fn loadView(self: *Visor, mandelbrotShader: rl.Shader) void {
        rl.setShaderValue(
            mandelbrotShader,
            self.xiLoc,
            &self.xi,
            rl.ShaderUniformDataType.shader_uniform_float,
        );
        rl.setShaderValue(
            mandelbrotShader,
            self.xfLoc,
            &self.xf,
            rl.ShaderUniformDataType.shader_uniform_float,
        );
        rl.setShaderValue(
            mandelbrotShader,
            self.yiLoc,
            &self.yi,
            rl.ShaderUniformDataType.shader_uniform_float,
        );
        rl.setShaderValue(
            mandelbrotShader,
            self.yfLoc,
            &self.yf,
            rl.ShaderUniformDataType.shader_uniform_float,
        );
    }

    pub fn zoom(self: *Visor, zoomFactor: f32, fixedXCoordinate: f32, fixedYCoordinate: f32) void {
        const xiCandidate = (self.xi - self.centerX) * zoomFactor + self.centerX;
        const xfCandidate = (self.xf - self.centerX) * zoomFactor + self.centerX;
        const yiCandidate = (self.yi - self.centerY) * zoomFactor + self.centerY;
        const yfCandidate = (self.yf - self.centerY) * zoomFactor + self.centerY;

        // This prevent us from reaching the limit of the precision
        if (@abs(xfCandidate - xiCandidate) <= 1e-5 or @abs(yfCandidate - yiCandidate) < 1e-5) {
            return;
        }

        const fixedXCoordinateVisorSystem = self.xi + (self.xf - self.xi) * (fixedXCoordinate + 1) / 2;
        const fixedYCoordinateVisorSystem = self.yi + (self.yf - self.yi) * (fixedYCoordinate + 1) / 2;

        self.xi = xiCandidate;
        self.xf = xfCandidate;
        self.yi = yiCandidate;
        self.yf = yfCandidate;

        const fixedXCoordinateZoomed = self.xi + (self.xf - self.xi) * (fixedXCoordinate + 1) / 2;
        const fixedYCoordinateZoomed = self.yi + (self.yf - self.yi) * (fixedYCoordinate + 1) / 2;

        self.centerX += fixedXCoordinateVisorSystem - fixedXCoordinateZoomed;
        self.centerY += fixedYCoordinateVisorSystem - fixedYCoordinateZoomed;

        self.xi += fixedXCoordinateVisorSystem - fixedXCoordinateZoomed;
        self.xf += fixedXCoordinateVisorSystem - fixedXCoordinateZoomed;
        self.yi += fixedYCoordinateVisorSystem - fixedYCoordinateZoomed;
        self.yf += fixedYCoordinateVisorSystem - fixedYCoordinateZoomed;
    }

    pub fn translate(self: *Visor, movFactor: rl.Vector2) void {
        const xMoveFactor = (self.xf - self.xi) * movFactor.x;
        const yMoveFactor = (self.yf - self.yi) * movFactor.y;

        self.xi += xMoveFactor;
        self.xf += xMoveFactor;
        self.centerX += xMoveFactor;

        self.yi += yMoveFactor;
        self.yf += yMoveFactor;
        self.centerY += yMoveFactor;
    }

    pub fn showParams(self: *Visor) void {
        std.debug.print("xi: {}\n", .{self.xi});
        std.debug.print("xf: {}\n", .{self.xf});
        std.debug.print("yi: {}\n", .{self.yi});
        std.debug.print("yf: {}\n", .{self.yf});
        std.debug.print("centerX: {}\n", .{self.centerX});
        std.debug.print("centerY: {}\n", .{self.centerY});
        std.debug.print("Difference X: {}\n", .{self.xf - self.xi});
        std.debug.print("Difference Y: {}\n", .{self.yf - self.yi});
    }
};

const ColorManager = struct {
    colorMap: colorsMaps.colorMap,

    colorsLoc: i32,
    redSegmentsSizeLoc: i32,
    greenSegmentsSizeLoc: i32,
    blueSegmentsSizeLoc: i32,
    invertColorLoc: i32,

    currentColor: u8 = 0,
    invertColor: i32 = 1,

    pub fn init(shader: rl.Shader) ColorManager {
        const colorsLoc = rl.getShaderLocation(shader, "colors");
        const redSegmentsSizeLoc = rl.getShaderLocation(shader, "redSegmentsSize");
        const greenSegmentsSizeLoc = rl.getShaderLocation(shader, "greenSegmentsSize");
        const blueSegmentsSizeLoc = rl.getShaderLocation(shader, "blueSegmentsSize");
        const invertColorLoc = rl.getShaderLocation(shader, "invertColor");

        return ColorManager{
            .colorsLoc = colorsLoc,
            .redSegmentsSizeLoc = redSegmentsSizeLoc,
            .greenSegmentsSizeLoc = greenSegmentsSizeLoc,
            .blueSegmentsSizeLoc = blueSegmentsSizeLoc,
            .invertColorLoc = invertColorLoc,
            .colorMap = colorsMaps.colorMap{},
        };
    }

    pub fn setColor(self: *ColorManager, option: u8, shader: rl.Shader) void {
        switch (option) {
            0 => self.colorMap.writeGrayColorMap(),
            1 => self.colorMap.writeBoneColorMap(),
            2 => self.colorMap.writeCmrColorMap(),
            3 => self.colorMap.writeHotColorMap(),
            4 => self.colorMap.writeHsvColorMap(),
            5 => self.colorMap.writeJetColorMap(),
            6 => self.colorMap.writeSpringColorMap(),
            7 => self.colorMap.writeSummerColorMap(),
            8 => self.colorMap.writeWinterColorMap(),
            else => self.colorMap.writeWistiaColorMap(),
        }

        var colors: [colorsMaps.colorMap.MAX_COLOR_SEGMENTS]rl.Vector3 = self.colorMap.toColorVector();

        const redSegmentsSize: i32 = @intCast(self.colorMap.redSegments);
        const greenSegmentsSize: i32 = @intCast(self.colorMap.greenSegments);
        const blueSegmentsSize: i32 = @intCast(self.colorMap.blueSegments);

        rl.setShaderValue(
            shader,
            self.redSegmentsSizeLoc,
            &redSegmentsSize,
            rl.ShaderUniformDataType.shader_uniform_int,
        );
        rl.setShaderValue(
            shader,
            self.greenSegmentsSizeLoc,
            &greenSegmentsSize,
            rl.ShaderUniformDataType.shader_uniform_int,
        );
        rl.setShaderValue(
            shader,
            self.blueSegmentsSizeLoc,
            &blueSegmentsSize,
            rl.ShaderUniformDataType.shader_uniform_int,
        );
        rl.setShaderValue(
            shader,
            self.invertColorLoc,
            &self.invertColor,
            rl.ShaderUniformDataType.shader_uniform_int,
        );
        rl.setShaderValueV(
            shader,
            self.colorsLoc,
            &colors,
            rl.ShaderUniformDataType.shader_uniform_vec3,
            colorsMaps.colorMap.MAX_COLOR_SEGMENTS,
        );
    }

    pub fn switchToPreviousColor(self: *ColorManager, shader: rl.Shader) void {
        self.currentColor = if (self.currentColor == 0) 9 else self.currentColor - 1;

        self.setColor(self.currentColor, shader);
    }

    pub fn switchToNextColor(self: *ColorManager, shader: rl.Shader) void {
        self.currentColor += 1;
        self.currentColor %= 10;

        self.setColor(self.currentColor, shader);
    }
};

pub fn main() anyerror!void {
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
        .screenWidth = width,
        .screenHeight = height,
    };

    const configFlags: rl.ConfigFlags = rl.ConfigFlags{ .msaa_4x_hint = true, .fullscreen_mode = false };
    rl.setConfigFlags(configFlags);

    // TODO: Initializing with zero is introducing a where translation bug in the y axis
    rl.initWindow(settings.screenWidth, settings.screenHeight, settings.title);
    defer rl.closeWindow();

    // If we call this before window initialization, we get cero values
    settings.screenWidth = rl.getScreenWidth();
    settings.screenHeight = rl.getScreenHeight();

    // TODO: Actually the web version works also for desktop, not changing
    // it still because in the future we might want to use specific  features on version 100
    var vertexShaderName: ?[*:0]const u8 = "resources/mandelbrot.vs";
    var fragmentShaderName: ?[*:0]const u8 = "resources/mandelbrot.fs";
    if (builtin.target.isWasm()) {
        vertexShaderName = "resources/mandelbrot_web.vs";
        fragmentShaderName = "resources/mandelbrot_web.fs";
    }
    const mandelbrotShader: rl.Shader = rl.loadShader(vertexShaderName, fragmentShaderName);
    defer rl.unloadShader(mandelbrotShader);

    const camera = rl.Camera3D{
        .position = rl.Vector3{ .x = 0, .y = 0, .z = 2 },
        .target = rl.Vector3{ .x = 0, .y = 0, .z = 0 },
        .up = rl.Vector3{ .x = 0, .y = 1, .z = 0 },
        .fovy = 45.0,
        .projection = rl.CameraProjection.camera_perspective,
    };
    const mvp = rl.getCameraMatrix(camera);
    const mvpLoc = rl.getShaderLocation(mandelbrotShader, "mvp");
    rl.setShaderValueMatrix(mandelbrotShader, mvpLoc, mvp);

    var visor = Visor.init(mandelbrotShader);
    visor.loadView(mandelbrotShader);

    settings.setLocations(mandelbrotShader);
    settings.loadSettings(mandelbrotShader);

    var colorManager = ColorManager.init(mandelbrotShader);
    colorManager.setColor(0, mandelbrotShader);

    rl.setTargetFPS(60);
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
                colorManager.switchToPreviousColor(mandelbrotShader);
            } else if (rl.isKeyPressed(rl.KeyboardKey.key_right)) {
                colorManager.switchToNextColor(mandelbrotShader);
            } else if (rl.isKeyPressed(rl.KeyboardKey.key_i)) {
                colorManager.invertColor *= -1;
                colorManager.setColor(colorManager.currentColor, mandelbrotShader);
            } else if (rl.isKeyPressed(rl.KeyboardKey.key_r)) {
                colorManager.currentColor = 0;
                colorManager.setColor(colorManager.currentColor, mandelbrotShader);
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
                settings.loadSettings(mandelbrotShader);
            }

            if (rl.isKeyDown(rl.KeyboardKey.key_left)) {
                settings.maxIterations = if (settings.maxIterations > 10) settings.maxIterations - 10 else 1;
                settings.loadSettings(mandelbrotShader);
            }
            if (rl.isKeyDown(rl.KeyboardKey.key_right)) {
                settings.maxIterations += 10;
                settings.loadSettings(mandelbrotShader);
            }

            if (rl.isKeyPressed(rl.KeyboardKey.key_r)) {
                settings.reset();
                settings.loadSettings(mandelbrotShader);
            }
        }

        // Copy coordinate params to the shader
        visor.loadView(mandelbrotShader);

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.ray_white);
        {
            rl.beginShaderMode(mandelbrotShader);
            defer rl.endShaderMode();

            rl.drawRectangle(
                0,
                0,
                settings.screenWidth,
                settings.screenHeight,
                rl.Color.ray_white,
            );
        }

        rl.drawFPS(10, 10);
    }
}
