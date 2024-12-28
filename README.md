# Mandelbrot-Explorer

# Build Desktop Locally
`zig build run`

# Build WebAssembly Locally
First compile the source code with
`zig build -Dtarget=wasm32-emscripten --sysroot $EMSCRIPTEN_PATH/upstream/emscripten`

Then copy `index.js` and `index.wasm` to `docs`

Then in `index.js` in the function `run(args=arguments_)` in the first line copy `arguments_.push(`${window.innerWidth}`);arguments_.push(`${window.innerHeight}`);`
