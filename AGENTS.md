# Agent Guide for dtv-nix

This guide is for coding agents working in this repository.
It defines build/check workflows and project coding conventions.

## Scope and Stack
- Primary language: Nix (`.nix`) with embedded Bash in build/service helpers.
- Main purpose: package definitions and NixOS modules for Japanese DTV tooling.
- Build system: Nix flakes (Blueprint-style outputs).
- Formatter: `nixfmt-tree` via flake output `formatter`.
- Validation style: derivation builds and flake checks, not unit-test suites.

## Cursor/Copilot Rules
Checked paths:
- `.cursorrules`
- `.cursor/rules/`
- `.github/copilot-instructions.md`
Status:
- No Cursor rules files were found.
- No Copilot instructions file was found.
- If these files are added later, treat them as higher-priority constraints.

## Repository Layout
- `flake.nix` / `flake.lock`: flake inputs and outputs.
- `packages/<name>/default.nix`: one derivation (or wrapper) per package.
- `modules/nixos/<name>.nix` and `modules/nixos/<name>/default.nix`: NixOS modules.
- `scanned/`: scanned runtime/channel artifacts, not primary packaging logic.
- `result` and `result-*`: local build outputs, ignored by git.

## Build, Lint, and Test Commands
Run commands from repo root: `/home/nina/Documents/projects/dtv-nix`.

### Discover outputs and attrs
```bash
nix flake show
nix flake show --all-systems
```
Use this first to confirm package/check attribute names.

### Formatting / linting
```bash
# Canonical formatter
nix fmt

# Equivalent explicit formatter invocation
nix run .#formatter -- .
```
Notes:
- No dedicated lint stack is wired in (no statix/deadnix/treefmt config in-repo).
- `nix fmt` is the expected formatting step for `.nix` files.

### Build a package
```bash
# Shorthand attrs
nix build -L .#akebi
nix build -L .#konomitv

# System-qualified attr
nix build -L .#packages.x86_64-linux.akebi
```
Useful options:
- `-L`: keep full logs.
- `--no-link`: validate build without creating `./result` symlink.

### Run checks
```bash
# All checks for host system
nix flake check -L

# All checks for all systems declared in flake outputs
nix flake check -L --all-systems
```

### Run a single test/check (important)
In this repo, a "single test" means building one check derivation.
```bash
# Single check on x86_64-linux
nix build -L .#checks.x86_64-linux.pkgs-akebi

# Another single-check example
nix build -L .#checks.x86_64-linux.pkgs-edcb
```
Portable host-system variant:
```bash
SYSTEM="$(nix eval --impure --raw --expr builtins.currentSystem)"
nix build -L .#checks.${SYSTEM}.pkgs-akebi
```

### Fast eval-only sanity checks
```bash
# Evaluate flake without building derivations
nix flake check --no-build

# Inspect one attribute quickly
nix eval --raw .#edcb.pname
```

## Code Style Guidelines
These conventions are inferred from current files under `packages/` and `modules/nixos/`.

### 1) Imports and argument style
- Prefer top-level argument sets: `{ pkgs, ... }:` or `{ perSystem, pkgs, ... }:`.
- For modules, use curried form when needed: `{ flake, ... }:` then `{ config, lib, pkgs, ... }:`.
- Keep module arg order stable: `config`, `lib`, `pkgs`, then `...`.
- In modules, bind `cfg = config.services.<name>` near the top.
- Group `let` bindings by purpose (defaults, helpers, scripts, then body).

### 2) Formatting and structure
- Run `nix fmt` after edits.
- Use two-space indentation and no tabs.
- Follow `nixfmt` output for braces, semicolons, and list/attrset layout.
- Prefer multiline lists/attrsets once lines stop being immediately readable.
- Keep substantial shell snippets in `'' ... ''` blocks.

### 3) Types and options in NixOS modules
- Use `lib.mkOption` / `lib.mkEnableOption` for all options.
- Always set explicit option types (`lib.types.bool`, `lib.types.str`, `lib.types.package`, etc.).
- Constrain ports with `lib.types.ints.between`.
- Provide `default` and meaningful `description` for options.
- Use `defaultText = lib.literalExpression ...` when defaults reference flake attrs.
- Gate emitted config with `lib.mkIf cfg.enable`.

### 4) Naming conventions
- Keep package directory names lowercase; preserve existing underscore names (for example `chapter_exe`).
- In derivations, set `pname` and `version` explicitly.
- Use `rec` when `version` or other attrs are referenced in the same derivation.
- Use descriptive helper names (`stateDir`, `defaultUser`, `runtimeTools`, `pythonEnv`).
- Name scripts by action (`edcb-initialize-state`, `konomitv-prepare-config`).

### 5) Build and dependency conventions
- Prefer `strictDeps = true;` for non-trivial builds where applicable.
- Keep dependency roles clear: `nativeBuildInputs` for build tools, `buildInputs` for runtime/build deps.
- Fetch sources with pinned hashes (`pkgs.fetchFromGitHub` / `pkgs.fetchurl`).
- Prefer deterministic refs (`tag` or pinned `rev`).
- Use `substituteInPlace --replace-fail` for source patching.
- Preserve standard hooks in custom phases (`runHook preBuild`, `postBuild`, etc.).

### 6) Error handling and shell practices
- Start shell scripts with strict mode (`set -eu` or `set -eo pipefail`).
- Quote variable expansions unless intentional globbing is needed.
- Validate required files/dirs and fail with clear messages.
- Use explicit tool paths in scripts where needed (`${pkgs.coreutils}/bin/...`).
- Prefer `makeWrapper` / `wrapProgram` over manual PATH mutation.
- In modules, prefer `lib.getExe cfg.package` for service `ExecStart` where applicable.

### 7) Platform/metadata conventions
- Declare supported platforms with `meta.platforms`.
- Gate x86_64-only behavior with `pkgs.stdenv.hostPlatform.isx86_64`.
- Keep hardware-specific choices explicit (Intel/NVIDIA runtime logic, CUDA flags).
- Keep `meta` fields complete and consistent: `description`, `homepage`, `license`, `platforms`.
- Set `mainProgram` when a principal executable exists.

## Agent Change Checklist
1. Run `nix fmt` on changed Nix files.
2. Build the smallest relevant package target (for example `nix build -L .#tsreadex`).
3. Run one relevant single-check target (for example `nix build -L .#checks.x86_64-linux.pkgs-tsreadex`).
4. If the change is broad, run `nix flake check -L`.
5. Confirm no accidental edits to scanned/generated artifacts unless requested.

Keep changes minimal, reproducible, and aligned with existing Nix idioms in this repository.
