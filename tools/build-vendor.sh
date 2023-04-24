#!/bin/bash
set -e

wasm_ld_js_library="$PWD/src/fsroot.js"

(
  cd vendor/llvm-project
  echo "🟦 Inside vendor/llvm-project"

  echo "🟪 Generating Ninja build files for clang for WebAssembly..."
  cmake -S llvm -B build-1 -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_TARGETS_TO_BUILD=WebAssembly \
    -DLLVM_ENABLE_PROJECTS=clang
  echo "🟩 Generated Ninja build-1 files for clang for WebAssembly"

  echo "🟪 Building llvm-tblgen and clang-tblgen for WebAssembly..."
  cmake --build build-1 -- llvm-tblgen clang-tblgen
  echo "🟩 Built llvm-tblgen and clang-tblgen for WebAssembly"

  echo "🟪 Generating Ninja build files for clang, lld, and clang-tools-extra for WebAssembly..."
  CXXFLAGS='-Dwait4=__syscall_wait4' \
  LDFLAGS="\
    -s LLD_REPORT_UNDEFINED=1 \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s EXPORTED_FUNCTIONS=_main,_free,_malloc \
    -s EXPORTED_RUNTIME_METHODS=FS,PROXYFS,ERRNO_CODES,allocateUTF8 \
    -lproxyfs.js \
    --js-library=\"$wasm_ld_js_library\" \
  " \
  emcmake cmake -S llvm -B build-2 -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_TARGETS_TO_BUILD=WebAssembly \
    -DLLVM_ENABLE_PROJECTS='clang;lld;clang-tools-extra' \
    -DLLVM_TABLEGEN="$PWD/build-1/bin/llvm-tblgen" \
    -DCLANG_TABLEGEN="$PWD/build-1/bin/clang-tblgen" \
    -DLLVM_EXTERNAL_CLANG_SOURCE_DIR="$PWD/clang" \
    -DLLVM_EXTERNAL_LLD_SOURCE_DIR="$PWD/lld" \
    -DLLVM_EXTERNAL_CLANG_TOOLS_EXTRA_SOURCE_DIR="$PWD/clang-tools-extra"
  echo "🟩 Generated Ninja build files for clang, lld, and clang-tools-extra for WebAssembly"

  echo "🟪 Building llvm-box for WebAssembly..."
  cmake --build build -- llvm-box
  echo "🟩 Built llvm-box for WebAssembly"
)

(
  cd vendor/cpython
  echo "🟦 Inside vendor/cpython"

  echo "🟪 Configuring settings to build python for WebAssembly..."
  CONFIG_SITE="$PWD/Tools/wasm/config.site-wasm32-emscripten" \
  LIBSQLITE3_CFLAGS=' ' \
  BZIP2_CFLAGS=' ' \
  LDFLAGS="\
    -s ALLOW_MEMORY_GROWTH=1 \
    -s EXPORTED_FUNCTIONS=_main,_free,_malloc \
    -s EXPORTED_RUNTIME_METHODS=FS,PROXYFS,ERRNO_CODES,allocateUTF8 \
    -lproxyfs.js \
    --js-library=\"$wasm_ld_js_library\" \
  " \
  emconfigure ./configure -C \
    --host=wasm32-unknown-emscripten \
    --build="$(./config.guess)" \
    --with-emscripten-target=browser \
    --disable-wasm-dynamic-linking \
    --disable-wasm-preload \
    --enable-wasm-js-module \
    --with-build-python="$(command -v python)"
  echo "🟩 Configured settings to build python for WebAssembly"

  echo "🟪 Building python for WebAssembly..."
  emmake make -j"$(nproc)"
  echo "🟩 Built python for WebAssembly"
)
