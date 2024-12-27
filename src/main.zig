const std = @import("std");
const rl = @import("raylib");
const builtin = @import("builtin");
const colorsMaps = @import("colors.zig");

const GlobalSettings = struct {
    screenWidth: i32 = 1000,
    screenHeight: i32 = 1000,
    maxIterations: i32 = 100,

    title: [*:0]const u8 = "Mandelbrot Explorer",

    screenWidthLoc: i32,
    screenHeightLoc: i32,
    maxIterationsLoc: i32,

    pub fn setLocations(self: *GlobalSettings, mandelbrotShader: rl.Shader) void {
        self.screenWidthLoc = rl.getShaderLocation(mandelbrotShader, "screenWidth");
        self.screenHeightLoc = rl.getShaderLocation(mandelbrotShader, "screenHeight");
        self.maxIterationsLoc = rl.getShaderLocation(mandelbrotShader, "maxIterations");
    }

    pub fn loadSettings(self: *GlobalSettings, mandelbrotShader: rl.Shader) void {
        rl.setShaderValue(mandelbrotShader, self.screenWidthLoc, &self.screenWidth, rl.ShaderUniformDataType.shader_uniform_int);
        rl.setShaderValue(mandelbrotShader, self.screenHeightLoc, &self.screenHeight, rl.ShaderUniformDataType.shader_uniform_int);
        rl.setShaderValue(mandelbrotShader, self.maxIterationsLoc, &self.maxIterations, rl.ShaderUniformDataType.shader_uniform_int);
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
    xi: f32 = -1,
    xf: f32 = 1,
    yi: f32 = -1,
    yf: f32 = 1,
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
        self.xi = -1;
        self.xf = 1;
        self.yi = -1;
        self.yf = 1;
        self.centerX = 0;
        self.centerY = 0;
    }

    pub fn loadView(self: *Visor, mandelbrotShader: rl.Shader) void {
        rl.setShaderValue(mandelbrotShader, self.xiLoc, &self.xi, rl.ShaderUniformDataType.shader_uniform_float);
        rl.setShaderValue(mandelbrotShader, self.xfLoc, &self.xf, rl.ShaderUniformDataType.shader_uniform_float);
        rl.setShaderValue(mandelbrotShader, self.yiLoc, &self.yi, rl.ShaderUniformDataType.shader_uniform_float);
        rl.setShaderValue(mandelbrotShader, self.yfLoc, &self.yf, rl.ShaderUniformDataType.shader_uniform_float);
    }

    pub fn zoom(self: *Visor, zoomFactor: f32, fixedXCoordinate: f32, fixedYCoordinate: f32) void {
        const xiCandidate = (self.xi - self.centerX) * zoomFactor + self.centerX;
        const xfCandidate = (self.xf - self.centerX) * zoomFactor + self.centerX;
        const yiCandidate = (self.yi - self.centerY) * zoomFactor + self.centerY;
        const yfCandidate = (self.yf - self.centerY) * zoomFactor + self.centerY;

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

pub fn main() anyerror!void {
    var settings = GlobalSettings{ .screenWidthLoc = undefined, .screenHeightLoc = undefined, .maxIterationsLoc = undefined };

    rl.initWindow(settings.screenWidth, settings.screenHeight, settings.title);
    defer rl.closeWindow();

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
    const colorsLoc = rl.getShaderLocation(mandelbrotShader, "colors");
    const redSegmentsSizeLoc = rl.getShaderLocation(mandelbrotShader, "redSegmentsSize");
    const greenSegmentsSizeLoc = rl.getShaderLocation(mandelbrotShader, "greenSegmentsSize");
    const blueSegmentsSizeLoc = rl.getShaderLocation(mandelbrotShader, "blueSegmentsSize");

    var visor = Visor.init(mandelbrotShader);
    settings.setLocations(mandelbrotShader);

    var colorMap = colorsMaps.colorMap{};
    colorMap.writeBoneColorMap();

    var colors: [30]rl.Vector3 = colorMap.toColorVector();

    const redSegmentsSize: i32 = @intCast(colorMap.redSegments);
    const greenSegmentsSize: i32 = @intCast(colorMap.greenSegments);
    const blueSegmentsSize: i32 = @intCast(colorMap.blueSegments);

    rl.setShaderValueMatrix(mandelbrotShader, mvpLoc, mvp);
    rl.setShaderValueV(mandelbrotShader, colorsLoc, &colors, rl.ShaderUniformDataType.shader_uniform_vec3, 30);
    rl.setShaderValue(mandelbrotShader, redSegmentsSizeLoc, &redSegmentsSize, rl.ShaderUniformDataType.shader_uniform_int);
    rl.setShaderValue(mandelbrotShader, greenSegmentsSizeLoc, &greenSegmentsSize, rl.ShaderUniformDataType.shader_uniform_int);
    rl.setShaderValue(mandelbrotShader, blueSegmentsSizeLoc, &blueSegmentsSize, rl.ShaderUniformDataType.shader_uniform_int);
    visor.loadView(mandelbrotShader);
    settings.loadSettings(mandelbrotShader);

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        const mov: rl.Vector2 = rl.getMouseWheelMoveV();
        const mousePosition = rl.getMousePosition();

        // This are the real positions
        const mouseX = (mousePosition.x - @as(f32, @floatFromInt(settings.screenWidth)) / 2) / (@as(f32, @floatFromInt(settings.screenWidth)) / 2);
        const mouseY = -1.0 * (mousePosition.y - @as(f32, @floatFromInt(settings.screenHeight)) / 2) / (@as(f32, @floatFromInt(settings.screenHeight)) / 2);

        // Reset
        if (rl.isKeyPressed(rl.KeyboardKey.key_r)) {
            visor.reset();
            settings.maxIterations = 100;
        } else if (rl.isKeyDown(rl.KeyboardKey.key_z)) {
            // TODO: We need a way to avoid zooming more than what precision admits
            if (@abs(mov.y) > 0 or @abs(mov.x) > 0) {
                const zoomFactor: f32 = if ((mov.y + mov.x) >= 0) 0.9 else 1.1;

                visor.zoom(zoomFactor, mouseX, mouseY);
                visor.showParams();
            }
        } else {
            visor.translate(rl.Vector2{
                .x = mov.x * 0.05,
                .y = mov.y * 0.05,
            });
        }

        visor.loadView(mandelbrotShader);

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.ray_white);
        {
            rl.beginShaderMode(mandelbrotShader);
            defer rl.endShaderMode();

            rl.drawRectangle(0, 0, settings.screenWidth, settings.screenHeight, rl.Color.ray_white);
        }

        rl.drawFPS(10, 10);
    }
}
