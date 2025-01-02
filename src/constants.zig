// This is because raylib can not send bool to shaders
pub const FALSE: i32 = -1;
pub const TRUE: i32 = 1;

pub const DEFAULT_MAX_ITERATIONS: i32 = 100;
pub const FPS: i32 = 60;

pub const Event = enum {
    Quit,
    KeyDown,
    KeyUp,
    MouseMove,
    MouseDown,
    MouseUp,
    MouseWheel,
};
