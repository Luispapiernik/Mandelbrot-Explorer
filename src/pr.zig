const std = @import("std");

pub fn main() anyerror!void {
    const width: f32 = 1920;
    const height: f32 = 1080;

    const hDivisions: f32 = 10;
    const vDivisions: f32 = 10;

    const hLength: f32 = width / hDivisions;
    const vLength: f32 = height / vDivisions;

    var x: f32 = -1;
    var y: f32 = -1;
    for (0..vDivisions) |_| {
        for (0..hDivisions) |_| {
            // before
            std.debug.print("({}, {})\n", .{ x, y });

            x += hLength;
            y += vLength;
        }
    }

    // var a = try std.math.big.Rational.init(std.heap.page_allocator);
    // defer a.deinit();

    // var b = try std.math.big.Rational.init(std.heap.page_allocator);
    // defer b.deinit();

    // var d = try std.math.big.Rational.init(std.heap.page_allocator);
    // defer d.deinit();

    // var result = try std.math.big.Rational.init(std.heap.page_allocator);
    // defer result.deinit();

    // try a.setInt(-1);
    // try b.setInt(2);
    // try d.setInt(2);

    // var constant: i1113 = 10715086071862673209484250490600018105614048117055336074437503883703510511249361224931983788156958581275946729175531468251871452856923140435984577574698574803934567774824230985421074605062371141877954182153046474983581941267398767559165543946077062914571196477686542167660429831652624386837205668069376;
    // std.debug.print("constant: {}\n", .{constant});
    // for (1..1000) |_| {
    //     // try b.mul(b, d);
    //     // try result.div(a, b);
    //     // // const real = try result.toFloat(f128);

    //     // std.debug.print("{}/{} = {}/{} \n", .{ a.p, b.p, result.p, result.q });
    //     constant = constant * 2;
    //     std.debug.print("constant: {}\n", .{constant});
    // }
}
