const builtin = @import("builtin");
const std = @import("std");

const rl = @import("raylib");
const rg = @import("raygui");

const colors = @import("colors.zig");
const constants = @import("constants.zig");
const geometry = @import("geometry.zig");
const handler = @import("handler.zig");
const settings = @import("settings.zig");
const shaders = @import("shaders.zig");

pub fn main() anyerror!void {
    // Setting this to cero will start window with monitor width and height
    // but for our coordinates transformation, we need to set it to a fixed value
    // after initialization
    var width: i32 = 1000;
    var height: i32 = 1000;

    // av.FormatContext.open_input;
    if (builtin.target.os.tag == std.Target.Os.Tag.emscripten) {
        const args = try std.process.argsAlloc(std.heap.c_allocator);
        defer std.process.argsFree(std.heap.c_allocator, args);

        width = try std.fmt.parseInt(i32, args[1], 10);
        height = try std.fmt.parseInt(i32, args[2], 10);
    }

    var globalSettings = settings.GlobalSettings{
        .screenWidthLoc = undefined,
        .screenHeightLoc = undefined,
        .maxIterationsLoc = undefined,
        .smoothVelocityLoc = undefined,
        .shader = undefined,
        .screenWidth = width,
        .screenHeight = height,
        .maxIterations = constants.DEFAULT_MAX_ITERATIONS,
        .smoothVelocity = constants.FALSE,
    };

    // const configFlags: rl.ConfigFlags = rl.ConfigFlags{ .msaa_4x_hint = true, .fullscreen_mode = false };
    // rl.setConfigFlags(configFlags);

    // TODO: Initializing with zero is introducing a weird translation bug in the y axis
    rl.initWindow(globalSettings.screenWidth, globalSettings.screenHeight, globalSettings.title);
    defer rl.closeWindow();

    // If we call this before window initialization, we get cero values
    globalSettings.screenWidth = rl.getScreenWidth();
    globalSettings.screenHeight = rl.getScreenHeight();

    const shader: rl.Shader = shaders.loadMandelbrotShader();
    defer rl.unloadShader(shader);

    var visor = geometry.Visor.init(shader);
    visor.loadView();

    globalSettings.setSettingsLocations(shader);
    globalSettings.loadSettings();

    var colorManager = colors.ColorManager.init(shader);
    colorManager.setColor(colorManager.currentColor);

    const events = std.fifo.LinearFifo(
        constants.Event,
        std.fifo.LinearFifoBufferType.Dynamic,
    ).init(std.heap.page_allocator);
    defer events.deinit();

    rl.setTargetFPS(constants.FPS);
    while (!rl.windowShouldClose()) {
        handler.processEvents(
            &globalSettings,
            &colorManager,
            &visor,
        );

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.ray_white);
        shaders.executeShader(
            shader,
            globalSettings.screenWidth,
            globalSettings.screenHeight,
        );
    }
}
