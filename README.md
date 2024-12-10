# Mandelbrot-Explorer

# Build Desktop Locally
`zig build run`

# Build WebAssembly Locally
`zig build -Dtarget=wasm32-emscripten --sysroot $EMSCRIPTEN_PATH/upstream/emscripten`
