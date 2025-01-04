const std = @import("std");

const DDFloat = struct {
    x: f32,
    y: f32,
    err: f32,
};

fn toDDFloat(number: f64) DDFloat {
    var result: DDFloat = DDFloat{ .x = 0.0, .y = 0.0, .err = 0.0 };

    result.x = @floatCast(number);
    result.y = @floatCast(number - result.x);

    return result;
}

fn toDFloat(ddNumber: DDFloat) f64 {
    return @as(f64, ddNumber.x) + @as(f64, ddNumber.y);
}

fn split(number: f32) DDFloat {
    // 8193.0 = 2^14 + 1, a constant used for splitting
    const splitConstant = 8193.0;
    const temp = splitConstant * number;
    const high = temp - (temp - number);
    const low = number - high;
    return DDFloat{
        .x = @floatCast(high),
        .y = @floatCast(low),
        .err = 0.0,
    };
}

fn quick_two_sum(a: f32, b: f32) DDFloat {
    const s = a + b;
    const err = b - (s - a);
    return DDFloat{ .x = s, .y = 0.0, .err = err };
}

fn two_sum(a: f32, b: f32) DDFloat {
    const s = a + b;
    const bb = s - a;
    const err = (a - (s - bb)) + (b - bb);
    return DDFloat{ .x = s, .y = 0.0, .err = err };
}

pub fn sum(a: DDFloat, b: DDFloat) DDFloat {
    var s1: f32 = 0;
    var s2: f32 = 0;
    var t1: f32 = 0;
    var t2: f32 = 0;

    const result_1 = two_sum(a.x, b.x);
    s1 = result_1.x;
    s2 = result_1.err;

    const result_2 = two_sum(a.y, b.y);
    t1 = result_2.x;
    t2 = result_2.err;
    s2 += t1;

    const result_3 = quick_two_sum(s1, s2);
    s1 = result_3.x;
    s2 = result_3.err;
    s2 += t2;

    const result_4 = quick_two_sum(s1, s2);
    s1 = result_4.x;
    s2 = result_4.err;
    return DDFloat{ .x = s1, .y = s2, .err = 0.0 };
}

pub fn two_prod(a: f32, b: f32) DDFloat {
    const p = a * b;
    const a_split = split(a);
    const b_split = split(b);
    const err = ((a_split.x * b_split.x - p) + a_split.x * b_split.y + a_split.y * b_split.x) + a_split.y * b_split.y;
    return DDFloat{ .x = p, .y = 0.0, .err = err };
}

pub fn multiply(a: DDFloat, b: DDFloat) DDFloat {
    var p1: f32 = 0;
    var p2: f32 = 0;

    const result_1 = two_prod(a.x, b.x);
    p1 = result_1.x;
    p2 = result_1.err;
    p2 += (a.x * b.y + a.y * b.x);

    const result_2 = quick_two_sum(p1, p2);
    p1 = result_2.x;
    p2 = result_2.err;
    return DDFloat{ .x = p1, .y = p2, .err = 0.0 };
}

pub fn main() !void {
    const pi: f64 = std.math.pi;
    std.debug.print("pi: {}\n", .{pi});

    const ddPI: DDFloat = toDDFloat(pi);
    std.debug.print("PI: {}\n", .{toDFloat(ddPI)});

    const phi: f64 = std.math.phi;
    std.debug.print("phi: {}\n", .{phi});

    const ddPhi: DDFloat = toDDFloat(phi);
    std.debug.print("PHI: {}\n", .{toDFloat(ddPhi)});

    const result_2 = sum(ddPI, ddPI);
    std.debug.print("pi + pi: {}\n", .{pi + pi});
    std.debug.print("PI + PI: {}\n", .{toDFloat(result_2)});

    const mult_result = multiply(ddPI, ddPI);
    std.debug.print("pi * pi: {}\n", .{pi * pi});
    std.debug.print("PI * PI: {}\n", .{toDFloat(mult_result)});

    const result_3 = sum(ddPI, ddPhi);
    std.debug.print("pi + phi: {}\n", .{pi + phi});
    std.debug.print("PI + PHI: {}\n", .{toDFloat(result_3)});

    const mult_result_2 = multiply(ddPI, ddPhi);
    std.debug.print("pi * phi: {}\n", .{pi * phi});
    std.debug.print("PI * PHI: {}\n", .{toDFloat(mult_result_2)});
}
