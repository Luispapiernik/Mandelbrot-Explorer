const rl = @import("raylib");
const rg = @import("raygui");

const colors = @import("colors.zig");
const geometry = @import("geometry.zig");
const globalSettings = @import("settings.zig");

pub fn processEvents(
    settings: *globalSettings.GlobalSettings,
    colorManager: *colors.ColorManager,
    visor: *geometry.Visor,
) void {
    _ = rg.guiLabel(.{ .height = 300, .width = 300, .x = 300, .y = 300 }, "Hello, World!");
    _ = rg.guiButton(.{ .height = 100, .width = 100, .x = 10, .y = 10 }, "Click me!");
    nicheInputHandler(settings, colorManager, visor);
}

fn nicheInputHandler(
    settings: *globalSettings.GlobalSettings,
    colorManager: *colors.ColorManager,
    visor: *geometry.Visor,
) void {
    const mouseWheelDelta: rl.Vector2 = rl.getMouseWheelMoveV();
    const mousePosition = rl.getMousePosition();

    // This are the position of the mouse mapped to the coordinate system
    // where the vertical axis goes from -1 to 1 bottom up, and horizontal, goes from -1 to 1 left to right
    const mouseX = (mousePosition.x - @as(f32, @floatFromInt(settings.screenWidth)) / 2) / (@as(f32, @floatFromInt(settings.screenWidth)) / 2);
    const mouseY = -1.0 * (mousePosition.y - @as(f32, @floatFromInt(settings.screenHeight)) / 2) / (@as(f32, @floatFromInt(settings.screenHeight)) / 2);

    // Color inputs
    if (rl.isKeyDown(rl.KeyboardKey.c)) {
        if (rl.isKeyPressed(rl.KeyboardKey.left)) {
            colorManager.switchToPreviousColor();
        } else if (rl.isKeyPressed(rl.KeyboardKey.right)) {
            colorManager.switchToNextColor();
        } else if (rl.isKeyPressed(rl.KeyboardKey.i)) {
            colorManager.invertColor *= -1;
            colorManager.setColor(colorManager.currentColor);
        } else if (rl.isKeyPressed(rl.KeyboardKey.r)) {
            colorManager.currentColor = 0;
            colorManager.setColor(colorManager.currentColor);
        }
    }

    // Coordinate transformations
    if (rl.isKeyDown(rl.KeyboardKey.m)) {
        var xDelta: f32 = 0;
        var yDelta: f32 = 0;
        var zoomFactor: f32 = 1;

        if (rl.isKeyDown(rl.KeyboardKey.left) or mouseWheelDelta.x > 0) {
            if (rl.isKeyDown(rl.KeyboardKey.z)) {
                zoomFactor = 1.1;
            } else {
                xDelta += 0.05;
            }
        }

        if (rl.isKeyDown(rl.KeyboardKey.right) or mouseWheelDelta.x < 0) {
            if (rl.isKeyDown(rl.KeyboardKey.z)) {
                zoomFactor = 0.9;
            } else {
                xDelta -= 0.05;
            }
        }

        if (rl.isKeyDown(rl.KeyboardKey.up) or mouseWheelDelta.y > 0) {
            if (rl.isKeyDown(rl.KeyboardKey.z)) {
                zoomFactor = 0.9;
            } else {
                yDelta += 0.05;
            }
        }

        if (rl.isKeyDown(rl.KeyboardKey.down) or mouseWheelDelta.y < 0) {
            if (rl.isKeyDown(rl.KeyboardKey.z)) {
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

        if (rl.isKeyPressed(rl.KeyboardKey.r)) {
            visor.reset();
        }

        visor.loadView();
    }

    // Iterations
    if (rl.isKeyDown(rl.KeyboardKey.i)) {
        if (rl.isKeyPressed(rl.KeyboardKey.s)) {
            settings.smoothVelocity *= -1;
            settings.loadSettings();
        }

        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            settings.maxIterations = if (settings.maxIterations > 10) settings.maxIterations - 10 else 1;
            settings.loadSettings();
        }
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            settings.maxIterations += 10;
            settings.loadSettings();
        }

        if (rl.isKeyPressed(rl.KeyboardKey.r)) {
            settings.reset();
            settings.loadSettings();
        }
    }
}
