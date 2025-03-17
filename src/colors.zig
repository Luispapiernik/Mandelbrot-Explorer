const std = @import("std");

const rl = @import("raylib");

const constants = @import("constants.zig");

pub const ColorMap = struct {
    pub const MAX_COLOR_SEGMENTS: u8 = 30;

    redSegments: u8 = undefined,
    greenSegments: u8 = undefined,
    blueSegments: u8 = undefined,

    colorSegments: [ColorMap.MAX_COLOR_SEGMENTS][3]f32 = .{.{0} ** 3} ** ColorMap.MAX_COLOR_SEGMENTS,

    pub fn writeBoneColorMap(self: *ColorMap) void {
        self.redSegments = 3;
        self.greenSegments = 4;
        self.blueSegments = 3;

        // red
        self.colorSegments[0] = [3]f32{ 0.0, 0.0, 0.0 };
        self.colorSegments[1] = [3]f32{ 0.746032, 0.652778, 0.652778 };
        self.colorSegments[2] = [3]f32{ 1.0, 1.0, 1.0 };
        // green
        self.colorSegments[3] = [3]f32{ 0.0, 0.0, 0.0 };
        self.colorSegments[4] = [3]f32{ 0.365079, 0.319444, 0.319444 };
        self.colorSegments[5] = [3]f32{ 0.746032, 0.777778, 0.777778 };
        self.colorSegments[6] = [3]f32{ 1.0, 1.0, 1.0 };
        // blue
        self.colorSegments[7] = [3]f32{ 0.0, 0.0, 0.0 };
        self.colorSegments[8] = [3]f32{ 0.365079, 0.444444, 0.444444 };
        self.colorSegments[9] = [3]f32{ 1.0, 1.0, 1.0 };
    }

    pub fn writeGrayColorMap(self: *ColorMap) void {
        self.redSegments = 2;
        self.greenSegments = 2;
        self.blueSegments = 2;

        // red
        self.colorSegments[0] = [3]f32{ 0.0, 0.0, 0.0 };
        self.colorSegments[1] = [3]f32{ 1.0, 1.0, 1.0 };
        // green
        self.colorSegments[2] = [3]f32{ 0.0, 0.0, 0.0 };
        self.colorSegments[3] = [3]f32{ 1.0, 1.0, 1.0 };
        // blue
        self.colorSegments[4] = [3]f32{ 0.0, 0.0, 0.0 };
        self.colorSegments[5] = [3]f32{ 1.0, 1.0, 1.0 };
    }

    pub fn writeHotColorMap(self: *ColorMap) void {
        self.redSegments = 3;
        self.greenSegments = 4;
        self.blueSegments = 3;

        // red
        self.colorSegments[0] = [3]f32{ 0.0, 0.0416, 0.0416 };
        self.colorSegments[1] = [3]f32{ 0.365079, 1.0, 1.0 };
        self.colorSegments[2] = [3]f32{ 1.0, 1.0, 1.0 };
        // green
        self.colorSegments[3] = [3]f32{ 0.0, 0.0, 0.0 };
        self.colorSegments[4] = [3]f32{ 0.365079, 0.0, 0.0 };
        self.colorSegments[5] = [3]f32{ 0.746032, 1.0, 1.0 };
        self.colorSegments[6] = [3]f32{ 1.0, 1.0, 1.0 };
        // blue
        self.colorSegments[7] = [3]f32{ 0.0, 0.0, 0.0 };
        self.colorSegments[8] = [3]f32{ 0.746032, 0.0, 0.0 };
        self.colorSegments[9] = [3]f32{ 1.0, 1.0, 1.0 };
    }

    pub fn writeHsvColorMap(self: *ColorMap) void {
        self.redSegments = 10;
        self.greenSegments = 7;
        self.blueSegments = 7;

        // red
        self.colorSegments[0] = [3]f32{ 0.0, 1.0, 1.0 };
        self.colorSegments[1] = [3]f32{ 0.158730, 1.0, 1.0 };
        self.colorSegments[2] = [3]f32{ 0.174603, 0.968750, 0.968750 };
        self.colorSegments[3] = [3]f32{ 0.333333, 0.031250, 0.031250 };
        self.colorSegments[4] = [3]f32{ 0.349206, 0.0, 0.0 };
        self.colorSegments[5] = [3]f32{ 0.666667, 0.0, 0.0 };
        self.colorSegments[6] = [3]f32{ 0.682540, 0.031250, 0.031250 };
        self.colorSegments[7] = [3]f32{ 0.841270, 0.968750, 0.968750 };
        self.colorSegments[8] = [3]f32{ 0.857143, 1.0, 1.0 };
        self.colorSegments[9] = [3]f32{ 1.0, 1.0, 1.0 };
        // green
        self.colorSegments[10] = [3]f32{ 0.0, 0.0, 0.0 };
        self.colorSegments[11] = [3]f32{ 0.158730, 0.937500, 0.937500 };
        self.colorSegments[12] = [3]f32{ 0.174603, 1.0, 1.0 };
        self.colorSegments[13] = [3]f32{ 0.507937, 1.0, 1.0 };
        self.colorSegments[14] = [3]f32{ 0.666667, 0.062500, 0.062500 };
        self.colorSegments[15] = [3]f32{ 0.682540, 0.0, 0.0 };
        self.colorSegments[16] = [3]f32{ 1.0, 0.0, 0.0 };
        // blue
        self.colorSegments[17] = [3]f32{ 0.0, 0.0, 0.0 };
        self.colorSegments[18] = [3]f32{ 0.333333, 0.0, 0.0 };
        self.colorSegments[19] = [3]f32{ 0.349206, 0.062500, 0.062500 };
        self.colorSegments[20] = [3]f32{ 0.507937, 1.0, 1.0 };
        self.colorSegments[21] = [3]f32{ 0.841270, 1.0, 1.0 };
        self.colorSegments[22] = [3]f32{ 0.857143, 0.937500, 0.937500 };
        self.colorSegments[23] = [3]f32{ 1.0, 0.09375, 0.09375 };
    }

    pub fn writeJetColorMap(self: *ColorMap) void {
        self.redSegments = 5;
        self.greenSegments = 6;
        self.blueSegments = 5;

        // red
        self.colorSegments[0] = [3]f32{ 0.0, 0.0, 0.0 };
        self.colorSegments[1] = [3]f32{ 0.35, 0.0, 0.0 };
        self.colorSegments[2] = [3]f32{ 0.66, 1.0, 1.0 };
        self.colorSegments[3] = [3]f32{ 0.89, 1.0, 1.0 };
        self.colorSegments[4] = [3]f32{ 1.0, 0.5, 0.5 };
        // green
        self.colorSegments[5] = [3]f32{ 0.0, 0.0, 0.0 };
        self.colorSegments[6] = [3]f32{ 0.125, 0.0, 0.0 };
        self.colorSegments[7] = [3]f32{ 0.375, 1.0, 1.0 };
        self.colorSegments[8] = [3]f32{ 0.64, 1.0, 1.0 };
        self.colorSegments[9] = [3]f32{ 0.91, 0.0, 0.0 };
        self.colorSegments[10] = [3]f32{ 1.0, 0.0, 0.0 };
        // blue
        self.colorSegments[11] = [3]f32{ 0.0, 0.5, 0.5 };
        self.colorSegments[12] = [3]f32{ 0.11, 1.0, 1.0 };
        self.colorSegments[13] = [3]f32{ 0.34, 1.0, 1.0 };
        self.colorSegments[14] = [3]f32{ 0.65, 0.0, 0.0 };
        self.colorSegments[15] = [3]f32{ 1.0, 0.0, 0.0 };
    }

    pub fn writeSpringColorMap(self: *ColorMap) void {
        self.redSegments = 2;
        self.greenSegments = 2;
        self.blueSegments = 2;

        // red
        self.colorSegments[0] = [3]f32{ 0.0, 1.0, 1.0 };
        self.colorSegments[1] = [3]f32{ 1.0, 1.0, 1.0 };
        // green
        self.colorSegments[2] = [3]f32{ 0.0, 0.0, 0.0 };
        self.colorSegments[3] = [3]f32{ 1.0, 1.0, 1.0 };
        // blue
        self.colorSegments[4] = [3]f32{ 0.0, 1.0, 1.0 };
        self.colorSegments[5] = [3]f32{ 1.0, 0.0, 0.0 };
    }

    pub fn writeSummerColorMap(self: *ColorMap) void {
        self.redSegments = 2;
        self.greenSegments = 2;
        self.blueSegments = 2;

        // red
        self.colorSegments[0] = [3]f32{ 0.0, 0.0, 0.0 };
        self.colorSegments[1] = [3]f32{ 1.0, 1.0, 1.0 };
        // green
        self.colorSegments[2] = [3]f32{ 0.0, 0.5, 0.5 };
        self.colorSegments[3] = [3]f32{ 1.0, 1.0, 1.0 };
        // blue
        self.colorSegments[4] = [3]f32{ 0.0, 0.4, 0.4 };
        self.colorSegments[5] = [3]f32{ 1.0, 0.4, 0.4 };
    }

    pub fn writeWinterColorMap(self: *ColorMap) void {
        self.redSegments = 2;
        self.greenSegments = 2;
        self.blueSegments = 2;

        // red
        self.colorSegments[0] = [3]f32{ 0.0, 0.0, 0.0 };
        self.colorSegments[1] = [3]f32{ 1.0, 0.0, 0.0 };
        // green
        self.colorSegments[2] = [3]f32{ 0.0, 0.0, 0.0 };
        self.colorSegments[3] = [3]f32{ 1.0, 1.0, 1.0 };
        // blue
        self.colorSegments[4] = [3]f32{ 0.0, 1.0, 1.0 };
        self.colorSegments[5] = [3]f32{ 1.0, 0.5, 0.5 };
    }

    pub fn writeCmrColorMap(self: *ColorMap) void {
        self.redSegments = 9;
        self.greenSegments = 9;
        self.blueSegments = 9;

        // red
        self.colorSegments[0] = [3]f32{ 0.000, 0.00, 0.00 };
        self.colorSegments[1] = [3]f32{ 0.125, 0.15, 0.15 };
        self.colorSegments[2] = [3]f32{ 0.250, 0.30, 0.30 };
        self.colorSegments[3] = [3]f32{ 0.375, 0.60, 0.60 };
        self.colorSegments[4] = [3]f32{ 0.500, 1.00, 1.00 };
        self.colorSegments[5] = [3]f32{ 0.625, 0.90, 0.90 };
        self.colorSegments[6] = [3]f32{ 0.750, 0.90, 0.90 };
        self.colorSegments[7] = [3]f32{ 0.875, 0.90, 0.90 };
        self.colorSegments[8] = [3]f32{ 1.000, 1.00, 1.00 };
        // green
        self.colorSegments[9] = [3]f32{ 0.000, 0.00, 0.00 };
        self.colorSegments[10] = [3]f32{ 0.125, 0.15, 0.15 };
        self.colorSegments[11] = [3]f32{ 0.250, 0.15, 0.15 };
        self.colorSegments[12] = [3]f32{ 0.375, 0.20, 0.20 };
        self.colorSegments[13] = [3]f32{ 0.500, 0.25, 0.25 };
        self.colorSegments[14] = [3]f32{ 0.625, 0.50, 0.50 };
        self.colorSegments[15] = [3]f32{ 0.750, 0.75, 0.75 };
        self.colorSegments[16] = [3]f32{ 0.875, 0.90, 0.90 };
        self.colorSegments[17] = [3]f32{ 1.000, 1.00, 1.00 };
        // blue
        self.colorSegments[18] = [3]f32{ 0.000, 0.00, 0.00 };
        self.colorSegments[19] = [3]f32{ 0.125, 0.50, 0.50 };
        self.colorSegments[20] = [3]f32{ 0.250, 0.75, 0.75 };
        self.colorSegments[21] = [3]f32{ 0.375, 0.50, 0.50 };
        self.colorSegments[22] = [3]f32{ 0.500, 0.15, 0.15 };
        self.colorSegments[23] = [3]f32{ 0.625, 0.00, 0.00 };
        self.colorSegments[24] = [3]f32{ 0.750, 0.10, 0.10 };
        self.colorSegments[25] = [3]f32{ 0.875, 0.50, 0.50 };
        self.colorSegments[26] = [3]f32{ 1.000, 1.00, 1.00 };
    }

    pub fn writeWistiaColorMap(self: *ColorMap) void {
        self.redSegments = 5;
        self.greenSegments = 5;
        self.blueSegments = 5;

        // red
        self.colorSegments[0] = [3]f32{ 0.0, 0.89411765, 0.89411765 };
        self.colorSegments[1] = [3]f32{ 0.25, 1.0, 1.0 };
        self.colorSegments[2] = [3]f32{ 0.5, 1.0, 1.0 };
        self.colorSegments[3] = [3]f32{ 0.75, 1.0, 1.0 };
        self.colorSegments[4] = [3]f32{ 1.0, 0.98823529, 0.98823529 };
        // green
        self.colorSegments[5] = [3]f32{ 0.0, 1.0, 1.0 };
        self.colorSegments[6] = [3]f32{ 0.25, 0.90980392, 0.90980392 };
        self.colorSegments[7] = [3]f32{ 0.5, 0.74117647, 0.74117647 };
        self.colorSegments[8] = [3]f32{ 0.75, 0.62745098, 0.62745098 };
        self.colorSegments[9] = [3]f32{ 1.0, 0.49803922, 0.49803922 };
        // blue
        self.colorSegments[10] = [3]f32{ 0.0, 0.47843137, 0.47843137 };
        self.colorSegments[11] = [3]f32{ 0.25, 0.10196078, 0.10196078 };
        self.colorSegments[12] = [3]f32{ 0.5, 0.0, 0.0 };
        self.colorSegments[13] = [3]f32{ 0.75, 0.0, 0.0 };
        self.colorSegments[14] = [3]f32{ 1.0, 0.0, 0.0 };
    }

    pub fn toColorVector(self: *ColorMap) [MAX_COLOR_SEGMENTS]rl.Vector3 {
        var colorVector: [MAX_COLOR_SEGMENTS]rl.Vector3 = undefined;

        for (0..self.redSegments + self.greenSegments + self.blueSegments) |index| {
            colorVector[index] = rl.Vector3{
                .x = self.colorSegments[index][0],
                .y = self.colorSegments[index][1],
                .z = self.colorSegments[index][2],
            };
        }
        return colorVector;
    }
};

pub const ColorManager = struct {
    colorMap: ColorMap,
    shader: rl.Shader,

    colorsLoc: i32,
    redSegmentsSizeLoc: i32,
    greenSegmentsSizeLoc: i32,
    blueSegmentsSizeLoc: i32,
    invertColorLoc: i32,

    currentColor: u8 = 1,
    invertColor: i32 = constants.FALSE,

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
            .colorMap = ColorMap{},
            .shader = shader,
        };
    }

    pub fn setColor(self: *ColorManager, option: u8) void {
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

        var colors: [ColorMap.MAX_COLOR_SEGMENTS]rl.Vector3 = self.colorMap.toColorVector();

        const redSegmentsSize: i32 = @intCast(self.colorMap.redSegments);
        const greenSegmentsSize: i32 = @intCast(self.colorMap.greenSegments);
        const blueSegmentsSize: i32 = @intCast(self.colorMap.blueSegments);

        rl.setShaderValue(
            self.shader,
            self.redSegmentsSizeLoc,
            &redSegmentsSize,
            rl.ShaderUniformDataType.int,
        );
        rl.setShaderValue(
            self.shader,
            self.greenSegmentsSizeLoc,
            &greenSegmentsSize,
            rl.ShaderUniformDataType.int,
        );
        rl.setShaderValue(
            self.shader,
            self.blueSegmentsSizeLoc,
            &blueSegmentsSize,
            rl.ShaderUniformDataType.int,
        );
        rl.setShaderValue(
            self.shader,
            self.invertColorLoc,
            &self.invertColor,
            rl.ShaderUniformDataType.int,
        );
        rl.setShaderValueV(
            self.shader,
            self.colorsLoc,
            &colors,
            rl.ShaderUniformDataType.vec3,
            ColorMap.MAX_COLOR_SEGMENTS,
        );
    }

    pub fn switchToPreviousColor(self: *ColorManager) void {
        self.currentColor = if (self.currentColor == 0) 9 else self.currentColor - 1;

        self.setColor(self.currentColor);
    }

    pub fn switchToNextColor(self: *ColorManager) void {
        self.currentColor += 1;
        self.currentColor %= 10;

        self.setColor(self.currentColor);
    }
};
