const std = @import("std");

const rl = @import("raylib");

fn toDDFloat(number: f128) rl.Vector2 {
    var result: rl.Vector2 = rl.Vector2{ .x = 0.0, .y = 0.0 };

    result.x = @floatCast(number);
    result.y = @floatCast(number - result.x);
    return result;
}

pub const Visor = struct {
    const initialXI: i8 = -2;
    const initialXF: i8 = 2;
    const initialYI: i8 = -2;
    const initialYF: i8 = 2;

    shader: rl.Shader,

    xi: f128 = Visor.initialXI,
    xf: f128 = Visor.initialXF,
    yi: f128 = Visor.initialYI,
    yf: f128 = Visor.initialYF,

    _xi: rl.Vector2 = undefined,
    _xf: rl.Vector2 = undefined,
    _yi: rl.Vector2 = undefined,
    _yf: rl.Vector2 = undefined,

    centerX: f128 = 0,
    centerY: f128 = 0,

    zoomLevel: f128 = 1,

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
        self._xi = toDDFloat(self.xi);
        self._xf = toDDFloat(self.xf);
        self._yi = toDDFloat(self.yi);
        self._yf = toDDFloat(self.yf);

        rl.setShaderValue(
            self.shader,
            self.xiLoc,
            &self._xi,
            rl.ShaderUniformDataType.shader_uniform_vec2,
        );
        rl.setShaderValue(
            self.shader,
            self.xfLoc,
            &self._xf,
            rl.ShaderUniformDataType.shader_uniform_vec2,
        );
        rl.setShaderValue(
            self.shader,
            self.yiLoc,
            &self._yi,
            rl.ShaderUniformDataType.shader_uniform_vec2,
        );
        rl.setShaderValue(
            self.shader,
            self.yfLoc,
            &self._yf,
            rl.ShaderUniformDataType.shader_uniform_vec2,
        );
    }

    pub fn zoom(self: *Visor, zoomFactor: f128, fixedXCoordinate: f128, fixedYCoordinate: f128) void {
        self.zoomLevel *= (1 / zoomFactor);
        const xiCandidate = (self.xi - self.centerX) * zoomFactor + self.centerX;
        const xfCandidate = (self.xf - self.centerX) * zoomFactor + self.centerX;
        const yiCandidate = (self.yi - self.centerY) * zoomFactor + self.centerY;
        const yfCandidate = (self.yf - self.centerY) * zoomFactor + self.centerY;

        // This prevent us from reaching the limit of the precision
        if (@abs(xfCandidate - xiCandidate) <= 1e-8 or @abs(yfCandidate - yiCandidate) < 1e-8) {
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

        self.showParams();
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
        std.debug.print("zoomLevel: {d:.2}\n", .{self.zoomLevel});
    }
};
