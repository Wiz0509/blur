# Blur Render Service (fork of f0e/blur)

This public fork adds a 3-workflow GitHub Actions service you drive entirely
from the phone (Actions tab) — no local tools needed. It builds `blur-cli`
from this fork's source, then renders videos you provide by URL and delivers
results as a downloadable GitHub **Release**.

## Storage-safety default (important)

`src/common/config_blur.h` is edited so the Linux default is **safe**:
`interpolate: false`, `deduplicate: false`, `gpu_decoding: false`,
`gpu_interpolation: false`, and interpolation method `rife` (no SVP GPU
plugins). This keeps each render light on CPU/storage. The workflows repeat
these flags explicitly.

## Workflow order (run these three, in order)

Use the **Actions** tab on the phone, select each workflow, **Run workflow**,
fill the inputs.

### 1. `00 - Bootstrap toolchain` (run once)
Builds `blur-cli` from this fork + assembles a minimal stripped runtime, runs
a self-test, and caches it. Re-run with `force_refresh=true` after any source
change.

### 2. `01 - Import video`
Input: `source_url` — a **direct** link to an mp4/mkv/webm.
Downloads it, sniffs the container, and stores it as a `blur-input` artifact
(the hand-off used by `02`).

### 3. `02 - Render`
Inputs:
- `confirm_delete_old_output` — must be `true` to delete the previously
  published `blur-output-*` release before publishing a new one (safety gate).
- `blur_amount` (0-5), `quality` (x264 CRF, lower = better/larger).
- `out_fps` — optional output fps override (e.g. `60`; empty = auto).
- `dry_run` — `true` to only estimate/report, no render.

Flow: guard delete → find latest successful `01` run → download input →
estimate (abort if >330 min) → render → validate → publish
`blur-output-<run_id>` Release + 5-day artifact.

## Getting your result
In the repo `Releases` section, download the `blur-output-*` asset (the
rendered mp4).

## Upstream sync
This is a fork snapshot. To pick up upstream changes, rebuild with
`force_refresh=true`, or fetch upstream and re-apply the config edit.
