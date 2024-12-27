const rl = @import("raylib");
const std = @import("std");

// TODO: This need to be highly improved
pub const colorMap = struct {
    redSegments: u8 = undefined,
    greenSegments: u8 = undefined,
    blueSegments: u8 = undefined,

    colorSegments: [30][3]f32 = .{.{0} ** 3} ** 30,

    pub fn writeBoneColorMap(self: *colorMap) void {
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

    pub fn toColorVector(self: *colorMap) [30]rl.Vector3 {
        var colorVector: [30]rl.Vector3 = undefined;

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
