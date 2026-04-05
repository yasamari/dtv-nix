# AGENTS.md for dtv-nix

This guide is for autonomous coding agents working in this repository.
Use it as the default contract for edits, validation, and style.

## 1) Repository Scope
- Primary language: Nix (`.nix`) with embedded Bash in derivations/modules.
- Project type: Nix flake exposing packages and NixOS modules for DTV tooling.
- Validation model: Nix builds and checks, not a unit-test framework.
- Formatter: `nix fmt` via flake `formatter` output (`nixfmt-tree`).

## 2) Rule File Precedence (Cursor/Copilot)
Always check for additional rule files before editing:
- `.cursorrules`
- `.cursor/rules/`
- `.github/copilot-instructions.md`

Status at time of writing:
- `.cursorrules`: not found
- `.cursor/rules/`: not found
- `.github/copilot-instructions.md`: not found

If these files are later added, treat them as higher priority than this file.

## 3) Repository Layout
- `flake.nix`, `flake.lock`: flake inputs/outputs and pinning.
- `packages/<name>/default.nix`: package derivations and wrappers.
- `modules/nixos/*.nix`: NixOS service modules.
- `modules/nixos/edcb/default.nix`: EDCB module directory form.
- `modules/nixos/dtv.nix`: aggregate module importing multiple services.
- `result`, `result-*`: local build symlinks from `nix build`.

## 4) Build, Lint, and Test Commands
Run commands from repo root

### 4.1 Discover attrs before building
```bash
nix flake show
nix flake show --all-systems
```
Use this to confirm exact package/check names.

### 4.2 Formatting (lint equivalent)
```bash
nix fmt
```
Equivalent explicit form:
```bash
nix run .#formatter -- .
```
Notes:
- No dedicated lint stack (statix/deadnix/treefmt) is committed.
- Formatting is expected for every Nix change.

### 4.3 Build a single package
```bash
nix build -L .#akebi
nix build -L .#edcb
nix build -L .#konomitv
```
System-qualified form:
```bash
nix build -L .#packages.x86_64-linux.edcb
```
Helpful flags:
- `-L` shows full logs.
- `--no-link` builds without writing `./result`.

### 4.4 Run complete checks
```bash
nix flake check -L
nix flake check -L --all-systems
```

### 4.5 Run one test/check (important)
In this repo, a "single test" usually means building one check derivation.

Portable host-system form:
```bash
SYSTEM="$(nix eval --impure --raw --expr builtins.currentSystem)"
nix build -L .#checks.${SYSTEM}.pkgs-edcb
```

Direct examples:
```bash
nix build -L .#checks.x86_64-linux.pkgs-akebi
nix build -L .#checks.x86_64-linux.pkgs-konomitv
nix build -L .#checks.aarch64-linux.pkgs-tsreadex
```

### 4.6 Eval-only quick sanity
```bash
nix flake check --no-build
nix eval --raw .#packages.x86_64-linux.edcb.pname
```

## 5) Code Style Guidelines
Conventions below are inferred from existing `packages/` and `modules/nixos/` files.

### 5.1 Imports and function arguments
- Prefer argument-set signatures: `{ pkgs, ... }:` or `{ perSystem, pkgs, ... }:`.
- For modules needing flake attrs, use curried form: `{ flake, ... }:` then `{ config, lib, pkgs, ... }:`.
- Keep module argument order stable: `config`, `lib`, `pkgs`, `...`.
- Define `cfg = config.services.<name>;` near the top of the module `let` block.

### 5.2 Formatting and structure
- Run `nix fmt` after edits.
- Use two-space indentation and no tabs.
- Prefer multiline attrsets/lists when one-line readability drops.
- Keep shell snippets in `'' ... ''` blocks.
- Group `let` bindings by concern (defaults, helpers, generated scripts).

### 5.3 Types and module options
- Use `lib.mkOption` / `lib.mkEnableOption` for module options.
- Always specify explicit types (`bool`, `str`, `path`, `package`, etc.).
- Use constrained types for ports (`lib.types.ints.between` / `lib.types.ints.port`).
- Include `default` and clear `description` for each option.
- Use `defaultText = lib.literalExpression ...` when defaults reference flake attrs.
- Gate emitted config with `lib.mkIf cfg.enable`.

### 5.4 Derivations, dependencies, and pinning
- Set `pname` and `version` explicitly.
- Use `rec` when attributes reference each other.
- Prefer `strictDeps = true;` for non-trivial derivations.
- Keep dependency roles clear:
  - `nativeBuildInputs`: build-time tools
  - `buildInputs`: libs/tools used during build/runtime
  - `propagatedBuildInputs`: dependencies that must propagate to consumers
- Preserve standard hooks (`runHook preBuild`, `postBuild`, etc.).
- Use `substituteInPlace --replace-fail` for deterministic source patching.
- Pin fetches with fixed `rev`/`tag` and `hash`.

### 5.5 Naming conventions
- Package directory names are lowercase.
- Preserve existing underscore names (for example `chapter_exe`, `join_logo_scp`).
- Use descriptive helper names (`stateDir`, `runtimeTools`, `pythonEnv`).
- Name generated scripts by action (`edcb-initialize-state`, `amatsukaze-initialize-state`).

### 5.6 Shell and error handling
- Start scripts with strict mode: `set -eu` or `set -eo pipefail`.
- Quote variable expansions unless intentional splitting/globbing is required.
- Validate required files/dirs before use.
- Emit clear failures (`echo "..." >&2; exit 1`) for missing prerequisites.
- Prefer explicit Nix store tool paths in scripts when needed.
- Prefer `makeWrapper` / `wrapProgram` over ad-hoc PATH mutation.

### 5.7 Service and platform patterns
- Use explicit service users/groups and state directories.
- Prefer `ExecStart = lib.getExe cfg.package;` when package has `mainProgram`.
- Keep firewall behavior opt-in (`openFirewall = false` default).
- Gate architecture-specific behavior with `pkgs.stdenv.hostPlatform` checks.
- Keep x86_64-only encoder wiring explicit and isolated.

### 5.8 Metadata conventions
- Keep `meta` fields consistent: `description`, `homepage`, `license`, `platforms`.
- Set `meta.mainProgram` when a primary executable exists.
- Keep platform declarations explicit (`platforms.linux` or exact list).

## 6) Agent Workflow Checklist
1. Check for Cursor/Copilot rule files.
2. Confirm attrs with `nix flake show --all-systems` when unsure.
3. Make minimal edits focused on the requested behavior.
4. Run `nix fmt`.
5. Build the smallest affected package.
6. Run one relevant single-check derivation.
7. Run full `nix flake check -L` only for broad/cross-package changes.

## 7) Safety and Hygiene
- Do not edit `flake.lock` unless dependency updates are requested.
- Do not commit `result` symlinks or machine-local artifacts.
- Avoid unrelated refactors in focused change requests.
- Keep option descriptions aligned with existing language/style.

Use this document as the baseline guidance for autonomous edits in this repo.
