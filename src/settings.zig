const std = @import("std");

const rl = @import("raylib");

const FALSE: i32 = -1;
const TRUE: i32 = 1;
pub const DEFAULT_MAX_ITERATIONS: i32 = 100;
pub const FPS: i32 = 60;

pub const GlobalSettings = struct {
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
        self.maxIterations = DEFAULT_MAX_ITERATIONS;
        self.smoothVelocity = FALSE;
    }

    pub fn showFields(self: *GlobalSettings) void {
        std.debug.print("screenWidth: {}\n", .{self.screenWidth});
        std.debug.print("screenHeight: {}\n", .{self.screenHeight});
        std.debug.print("maxIterations: {}\n", .{self.maxIterations});
        std.debug.print("smoothVelocity: {}\n", .{self.smoothVelocity});
    }
};
