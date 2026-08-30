#!/usr/bin/env bash
set -euo pipefail

# Build blur-cli from fork source and assemble a minimal, storage-safe runtime.
# Expected to run from the repo root. Output: ./runtime/ (CLI + configs + deps).

echo "==> Configuring build (linux-release, minimal storage)"
cmake --preset linux-release -DBLUR_CLI_ONLY=ON

echo "==> Building"
cmake --build --preset linux-release --target blur-cli -j"$(nproc)"

BIN=bin/Release
RUNTIME=runtime
mkdir -p "$RUNTIME"

echo "==> Fetching runtime resources (configs/plugins/models) via upstream helper"
# ci/build-dependencies-linux.sh populates ci/out with plugins+models; we copy
# only what the CLI actually needs into runtime/ to keep the cache small.
if [ -f ci/build-dependencies-linux.sh ]; then
  bash ci/build-dependencies-linux.sh 2>/dev/null || true
fi

echo "==> Assembling stripped runtime"
cp "$BIN/blur-cli" "$RUNTIME/blur-cli"
# Keep scripts/libs/models that the CLI resolves at runtime (get_resources_path
# = binary's parent dir). Strip anything large/unused to minimize cache size.
cp -r ci/out/lib "$RUNTIME/lib" 2>/dev/null || true
cp -r ci/out/vapoursynth-plugins "$RUNTIME/vapoursynth-plugins" 2>/dev/null || true
cp -r ci/out/models "$RUNTIME/models" 2>/dev/null || true
# Clean intermediate build artifacts and helper dirs we don't ship.
rm -rf ci/out lib bin

echo "==> Runtime contents"
du -sh "$RUNTIME"/* | sort -h

echo "==> Verifying dynamic deps of blur-cli"
ldd "$RUNTIME/blur-cli" || true
