const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const freetype = b.dependency("freetype", .{ .target = target, .optimize = optimize });
    const glad = b.dependency("glad", .{});

    const lib = b.addStaticLibrary(.{
        .name = "freetype-gl",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.linkLibrary(freetype.artifact("freetype"));
    lib.addIncludePath(glad.path("include"));
    lib.addCSourceFile(.{ .file = glad.path("src/glad.c"), .flags = &.{} });
    lib.addIncludePath(.{ .path = "." });
    lib.addCSourceFiles(.{ .files = &.{
        "texture-font.c",
        "texture-atlas.c",
        "vector.c",
        "font-manager.c",
        "makefont.c",
    } });

    const config_header = b.addConfigHeader(.{}, .{
        .FREETYPE_GL_USE_GLEW = 1,
        .FREETYPE_GL_USE_VAO = 1,
        .GL_WITH_GLAD = 1,
    });
    lib.addConfigHeader(config_header);

    b.installArtifact(lib);
}
