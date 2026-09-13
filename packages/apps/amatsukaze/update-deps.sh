#!/usr/bin/env bash
# Regenerate deps.json for the Amatsukaze packages, fully automatically.
#
# Background: AmatsukazeWebUI (Blazor WebAssembly) is built indirectly via an
# MSBuild Exec inside the server publish step, so it is not part of
# `projectFile` and `passthru.fetch-deps` alone never harvests its workload
# packs (e.g. Microsoft.NETCore.App.Runtime.Mono.browser-wasm). Restoring the
# WebUI through buildDotnetModule is not an option either: its restore always
# passes --runtime <rid>, which makes NuGet demand a Mono.linux-x64 pack that
# was never published. Hence this script:
#   1. regenerates the base file with the official `fetch-deps` generator, then
#   2. restores the WebUI project separately (no --runtime) and merges any
#      additional packs into deps.json.
#
# Requires network access. Run from anywhere:
#   ./packages/apps/amatsukaze/update-deps.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
PKGDIR="$SCRIPT_DIR"
cd "$ROOT"

TMPDIR="$(mktemp -d -t amatsukaze-update-deps.XXXXXX)"
export TMPDIR
trap 'chmod -R +w "$TMPDIR" 2>/dev/null; rm -rf "$TMPDIR"' EXIT

# Hermetic dotnet environment (never touch the user's ~/.nuget).
export HOME="$TMPDIR/home"
mkdir -p "$HOME"
export DOTNET_NOLOGO=1 DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

# Pinned nixpkgs from this flake, so tool versions always match the build.
REV="$(jq -r '.nodes.nixpkgs.locked.rev' "$ROOT/flake.lock")"
PINNED="github:nixos/nixpkgs/$REV"

echo "==> [1/3] regenerating base deps.json via passthru.fetch-deps" >&2
# Each split dotnet package harvests only its own closure, so run all four
# generators and merge the results. Explicit output files are required: under
# flakes the scripts' wired default output points into the Nix store.
for pkg in amatsukaze-server-cli amatsukaze-script-command amatsukaze-add-task; do
  nix build ".#$pkg.passthru.fetch-deps" -o "$TMPDIR/fetch-deps-$pkg"
  "$TMPDIR/fetch-deps-$pkg" "$TMPDIR/base-$pkg.json"
done

echo "==> [2/3] restoring AmatsukazeWebUI separately (no --runtime)" >&2
nix build '.#amatsukaze.src' --no-link --print-out-paths --out-link "$TMPDIR/src-link" >/dev/null
# The store copy is read-only and `dotnet restore` writes obj/ next to the
# project, so work on a writable copy (submodules are already materialized).
cp -r "$(readlink -f "$TMPDIR/src-link")" "$TMPDIR/source"
chmod -R +w "$TMPDIR/source"
export NUGET_PACKAGES="$TMPDIR/nuget"
mkdir -p "$NUGET_PACKAGES"
nix shell "$PINNED#dotnet-sdk_10" --command \
  dotnet restore "$TMPDIR/source/AmatsukazeWebUI/AmatsukazeWebUI.csproj"

echo "==> [3/3] harvesting WebUI packs and merging into deps.json" >&2
# NOTE: nuget-to-json shells out to `dotnet nuget list source`, so the SDK must
# be on PATH here as well.
nix shell "$PINNED#dotnet-sdk_10" "$PINNED#nuget-to-json" "$PINNED#jq" --command \
  bash -c 'nuget-to-json "$NUGET_PACKAGES" > "$TMPDIR/webui-deps.json"'
# Packs already shipped by the SDK itself must be excluded: buildDotnetModule
# unconditionally adds dotnet-sdk.packages to every build, and the fallback-dir
# assembly (`ln -s`) fails on duplicates with "File exists".
sdkPacks="$(nix eval --json "$PINNED#dotnetCorePackages.sdk_10_0.packages" \
  --apply 'map (d: d.pname + "|" + d.version)')"
jq --argjson sdk "$sdkPacks" -s '
  add
  | map(select((.pname + "|" + .version) as $k | ($sdk | index($k) | not)))
  | unique_by(.pname + "|" + .version)
  | sort_by(.pname)' \
  "$TMPDIR"/base-*.json "$TMPDIR/webui-deps.json" > "$TMPDIR/deps.json.new"
mv "$TMPDIR/deps.json.new" "$PKGDIR/deps.json"

echo "==> done. Review with: git diff --stat $PKGDIR/deps.json" >&2
