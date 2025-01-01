const std = @import("std");

const rl = @import("raylib");

pub const Visor = struct {
    const initialXI: f32 = -2;
    const initialXF: f32 = 2;
    const initialYI: f32 = -2;
    const initialYF: f32 = 2;

    shader: rl.Shader,

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

        return Visor{
            .xiLoc = xiLoc,
            .xfLoc = xfLoc,
            .yiLoc = yiLoc,
            .yfLoc = yfLoc,
            .shader = mandelbrotShader,
        };
    }

    pub fn reset(self: *Visor) void {
        self.xi = Visor.initialXI;
        self.xf = Visor.initialXF;
        self.yi = Visor.initialYI;
        self.yf = Visor.initialYF;

        self.centerX = 0;
        self.centerY = 0;
    }

    pub fn loadView(self: *Visor) void {
        rl.setShaderValue(
            self.shader,
            self.xiLoc,
            &self.xi,
            rl.ShaderUniformDataType.shader_uniform_float,
        );
        rl.setShaderValue(
            self.shader,
            self.xfLoc,
            &self.xf,
            rl.ShaderUniformDataType.shader_uniform_float,
        );
        rl.setShaderValue(
            self.shader,
            self.yiLoc,
            &self.yi,
            rl.ShaderUniformDataType.shader_uniform_float,
        );
        rl.setShaderValue(
            self.shader,
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
        std.debug.print("xf - xi: {}\n", .{self.xf - self.xi});
        std.debug.print("yf - yi: {}\n", .{self.yf - self.yi});
    }
};
