#!/bin/bash

# Function to build for desktop
build_desktop() {
    echo "Building for desktop..."
    zig build run
}

# Function to build for WebAssembly
build_web() {
    echo "Building for WebAssembly..."
    zig build -Dtarget=wasm32-emscripten --sysroot $EMSCRIPTEN_PATH/upstream/emscripten
    echo "Copying index.js and index.wasm to docs..."
    cp zig-out/htmlout/index.js docs/
    cp zig-out/htmlout/index.wasm docs/
    echo "Updating index.js..."
    sed -i '' 's/function run(args=arguments_){/function run(args=arguments_) { arguments_.push(`${window.innerWidth}`); arguments_.push(`${window.innerHeight}`);/' docs/index.js
}

# Check the command-line argument
if [ "$1" == "desktop" ]; then
    build_desktop
elif [ "$1" == "web" ]; then
    build_web
else
    echo "Usage: $0 {desktop|web}"
    exit 1
fi
