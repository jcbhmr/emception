#!/bin/bash
# We aren't using Git submodules because that takes WAYYY too long because these
# are such huge repos. Instead, we clone a SPECIFIC tag of each repo and ONLY
# that tag. This is much faster. We could also use a curl ...tag.tar.gz | tar
# approach since GitHub does offer archives of each tag, but this is simpler.
set -e

llvm_project_version=16.0.0
cpython_version=3.11.2
binaryen_version=110

if [[ ! -d vendor ]]; then
  mkdir vendor
  echo "🟩 Created vendor/ directory"
fi

if [[ ! -d vendor/llvm-project ]]; then
  echo "🟪 Downloading LLVM v$llvm_project_version..."
  git clone https://github.com/llvm/llvm-project.git --branch "llvmorg-$llvm_project_version" --single-branch --depth 1 vendor/llvm-project
  echo "🟩 Downloaded LLVM v$llvm_project_version"
else
  echo "🟦 LLVM already downloaded"
fi

if [[ ! -d vendor/cpython ]]; then
  echo "🟪 Downloading CPython v$cpython_version..."
  git clone https://github.com/python/cpython.git --branch "v$cpython_version" --single-branch --depth 1 vendor/cpython
  echo "🟩 Downloaded CPython v$cpython_version"
else
  echo "🟦 CPython already downloaded"
fi

if [[ ! -d vendor/binaryen ]]; then
  echo "🟪 Downloading Binaryen..."
  git clone https://github.com/WebAssembly/binaryen.git --branch "version_$binaryen_version" --single-branch --depth 1 vendor/binaryen --recurse-submodules
  echo "🟩 Downloaded Binaryen"
else
  echo "🟦 Binaryen already downloaded"
fi

if [[ ! -f vendor/llvm-project/patch.lock ]]; then
  echo "🟪 Applying LLVM patch..."
  touch vendor/llvm-project/patch.lock
  git apply --directory=vendor/llvm-project patches/llvm-project.patch
  echo "🟩 Applied LLVM patch"
fi

if [[ ! -f vendor/cpython/patch.lock ]]; then
  echo "🟪 Applying CPython patch..."
  touch vendor/cpython/patch.lock
  git apply --directory=vendor/cpython patches/cpython.patch
  echo "🟩 Applied CPython patch"
fi
