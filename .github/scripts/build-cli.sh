#!/usr/bin/env bash
set -euo pipefail

# Build blur-cli from fork source and assemble a minimal, storage-safe runtime.
# Mirrors upstream CI: curl deps into ci/out, build via vcpkg preset, strip.
# Expected to run from repo root with VCPKG_ROOT set. Output: ./runtime/

echo "==> Collecting runtime deps/plugins/models (ci/build-dependencies-linux.sh)"
cd ci
bash build-dependencies-linux.sh
cd ..

echo "==> Building blur-cli via vcpkg preset (VCPKG_ROOT=$VCPKG_ROOT)"
cmake --preset linux-release
cmake --build . --preset linux-release

echo "==> Assembling runtime/"
RUNTIME=runtime
rm -rf "$RUNTIME" bin/Release/package
mkdir -p "$RUNTIME"
BIN=bin/Release
cp "$BIN/blur-cli" "$RUNTIME/blur-cli"
cp -r "$BIN/lib" "$RUNTIME/lib"
# upstream copies all of ci/out (lib, vapoursynth-plugins, models) into package
cp -r ci/out/* "$RUNTIME/"

echo "==> Runtime contents (sorted by size)"
du -sh "$RUNTIME"/* | sort -h

echo "==> Stripping GUI + build leftovers (keep only CLI runtime)"
rm -f "$RUNTIME/blur"

echo "==> Verifying dynamic deps of blur-cli"
ldd "$RUNTIME/blur-cli" || true
