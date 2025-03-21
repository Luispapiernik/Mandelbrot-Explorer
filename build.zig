const std = @import("std");
const rlz = @import("raylib_zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });

    const raylib = raylib_dep.module("raylib");
    const raygui = raylib_dep.module("raygui");
    const raylib_artifact = raylib_dep.artifact("raylib");

    // This is giving a compilation error
    // const ffmpeg = b.dependency("ffmpeg", .{
    //     .target = target,
    //     .optimize = optimize,
    // });
    // const av = ffmpeg.module("av");
    // const ffmpeg_artifact = ffmpeg.artifact("ffmpeg");

    //web exports are completely separate
    if (target.query.os_tag == .emscripten) {
        const exe_lib = try rlz.emcc.compileForEmscripten(
            b,
            "mandelbrot_explorer",
            "src/main.zig",
            target,
            optimize,
        );

        exe_lib.linkLibrary(raylib_artifact);
        exe_lib.root_module.addImport("raylib", raylib);
        exe_lib.root_module.addImport("raygui", raygui);

        // Note that raylib itself is not actually added to the exe_lib output file, so it also needs to be linked with emscripten.
        const link_step = try rlz.emcc.linkWithEmscripten(
            b,
            // &[_]*std.Build.Step.Compile{ exe_lib, raylib_artifact, ffmpeg_artifact },
            &[_]*std.Build.Step.Compile{
                exe_lib,
                raylib_artifact,
            },
        );
        //this lets your program access files like "resources/my-image.png":
        link_step.addArg("--embed-file");
        link_step.addArg("resources/");

        // Added this line, because after updating from zig 0.13.0 to zig 0.14.0, the web build was not working.
        // The compilation was giving an undefined symbol error: __ubsan_handle_type_mismatch_v1, __ubsan_handle_pointer_overflow, __ubsan_handle_mul_overflow
        link_step.addArg("-fsanitize=undefined");

        b.getInstallStep().dependOn(&link_step.step);
        const run_step = try rlz.emcc.emscriptenRunStep(b);
        run_step.step.dependOn(&link_step.step);
        const run_option = b.step("run", "Run mandelbrot_explorer");
        run_option.dependOn(&run_step.step);
        return;
    }

    const exe = b.addExecutable(
        .{
            .name = "mandelbrot_explorer",
            .root_source_file = b.path("src/main.zig"),
            .optimize = optimize,
            .target = target,
        },
    );

    exe.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);
    exe.root_module.addImport("raygui", raygui);

    // This is giving a compilation error
    // exe.linkLibrary(ffmpeg_artifact);
    // exe.root_module.addImport("av", av);

    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run mandelbrot_explorer");
    run_step.dependOn(&run_cmd.step);

    b.installArtifact(exe);
}
