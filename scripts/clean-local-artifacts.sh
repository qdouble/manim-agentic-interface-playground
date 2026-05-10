#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_root="$repo_root/.build"
dry_run=0
swiftpm_clean=0
auto_mode=0
include_index_build=0
size_warn_gb=5

usage() {
  cat <<'USAGE'
Usage: scripts/clean-local-artifacts.sh [--dry-run] [--swiftpm-clean] [--auto] [--include-index-build]

Removes repo-local generated proof/build artifacts under .build/ that are
safe to recreate. Persistent SwiftPM-owned state (arm64-apple-macosx,
index-build, repositories, checkouts, artifacts, workspace-state.json,
build.db, debug.yaml, plugin-tools.yaml, plugins, prebuilts) is preserved.

Removal proceeds in three layers:
  1. Always-cleanable named scratch dirs (explicit allowlist).
  2. Pattern sweep under .build/ for wave-scratch / proof / smoke /
     fixture / cache scratch directories that match well-known shapes.
  3. Nested-.build detection: any directory under .build/ (other than
     the persistent-keep set) that contains its own .build/ subdir is
     removed wholesale (catches stale worktrees with embedded builds).

After cleanup, the script reports the .build/ size; if still above the
soft size budget, it prints a warning naming the largest remaining
subdirs and suggests --swiftpm-clean.

Options:
  --dry-run              Print what would be removed without deleting it.
  --swiftpm-clean        Also run `swift package clean`.
                         Nukes the main Swift cache; rebuilds on next build.
  --auto                 Non-interactive mode for hooks / post-lane cleanup.
                         No prompts, no extra noise.
  --include-index-build  FULL-DISK RESCUE ONLY: also remove .build/index-build
                         (the SourceKit-LSP index). The IDE will reindex on
                         next open (~5-10 min for large projects). Do not use
                         during normal cleanup; the index rebuild is expensive.
  -h, --help             Show this help.
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=1 ;;
    --swiftpm-clean) swiftpm_clean=1 ;;
    --auto) auto_mode=1 ;;
    --include-index-build) include_index_build=1 ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      usage >&2
      exit 64
      ;;
  esac
done

# Persistent-keep set: SwiftPM-owned top-level entries under .build/ that
# the script must NEVER remove. Anything matching one of these basenames
# at the top level of .build/ is treated as live state.
persistent_keep=(
  "arm64-apple-macosx"
  "x86_64-apple-macosx"
  "index-build"
  "repositories"
  "checkouts"
  "artifacts"
  "prebuilts"
  "plugins"
  "workspace-state.json"
  "build.db"
  "debug.yaml"
  "plugin-tools.yaml"
  "manifest.db"
  "package.resolved"
)

is_persistent_keep() {
  local name="$1"
  local keep
  for keep in "${persistent_keep[@]}"; do
    [[ "$name" == "$keep" ]] && return 0
  done
  return 1
}

remove_path() {
  local path="$1"
  [[ -e "$path" ]] || return 0
  case "$path" in
    "$build_root"/*) ;;
    *)
      echo "Refusing to remove path outside repo .build: $path" >&2
      exit 65
      ;;
  esac

  local size
  size="$(du -sh "$path" 2>/dev/null | awk '{print $1}')"
  if [[ "$dry_run" -eq 1 ]]; then
    echo "would remove $size $path"
  else
    echo "removing $size $path"
    # Tolerate transient ENOTEMPTY from concurrent index writers (sourcekit-lsp,
    # SwiftPM watchers); retry once after a brief settle, then fall through.
    if ! rm -rf "$path" 2>/dev/null; then
      sleep 1
      if ! rm -rf "$path" 2>/dev/null; then
        echo "  warning: could not fully remove $path (concurrent writer?); leaving residual" >&2
      fi
    fi
  fi
}

# Layer 1: explicit always-cleanable allowlist.
# Playground-relevant scratch dirs; pattern sweep below catches future ones.
named_targets=(
  "external-consumer-fixtures"
  "example-renders"
  "research-study-renders"
  "plan-completion-audit"
  "skill-snippet-proof"
  "source-gate-cache"
  "manim-agentic-interface"
  "manim-renders"
  "tts-output"
  "sourcekit-lsp-diagnostics"
  "sourcekit-lsp-test"
  "manim-source-gate-cache"
  "feedback"
  "local-tts-proof"
  "manual-matrix-test"
  "sdk-examples"
  "debug"
)

if [[ -d "$build_root" ]]; then
  for name in "${named_targets[@]}"; do
    remove_path "$build_root/$name"
  done

  # Layer 2: pattern sweep. Glob under .build/ top level. Patterns are
  # chosen to match wave-scratch / proof / smoke / fixture / worktree
  # shapes without colliding with the persistent-keep set above.
  shopt -s nullglob
  pattern_globs=(
    "$build_root"/w[0-9]*
    "$build_root"/*-proof
    "$build_root"/*-proof-*
    "$build_root"/*-fixtures
    "$build_root"/*-fixtures-*
    "$build_root"/*-smoke
    "$build_root"/*-smoke-*
    "$build_root"/*-worktree
    "$build_root"/*-worktree-*
    "$build_root"/*scratch*
    "$build_root"/*-cache
    "$build_root"/*.log
    "$build_root"/*.json
    "$build_root"/*.out
  )
  for path in "${pattern_globs[@]}"; do
    base="$(basename "$path")"
    if is_persistent_keep "$base"; then
      continue
    fi
    remove_path "$path"
  done

  # Layer 3: nested-.build detection. Catches stale worktree clones and
  # consumer-fixture trees with their own .build/ inside.
  while IFS= read -r nested_build; do
    container="$(dirname "$nested_build")"
    [[ "$container" == "$build_root" ]] && continue
    base="$(basename "$container")"
    if is_persistent_keep "$base"; then
      continue
    fi
    # Walk up to the top-level .build child that contains this nested build.
    rel="${container#"$build_root"/}"
    top_child="${rel%%/*}"
    if is_persistent_keep "$top_child"; then
      continue
    fi
    remove_path "$build_root/$top_child"
  done < <(find "$build_root" -mindepth 2 -maxdepth 6 -type d -name ".build" 2>/dev/null)
  shopt -u nullglob
fi

if [[ "$swiftpm_clean" -eq 1 ]]; then
  if [[ "$dry_run" -eq 1 ]]; then
    echo "would run: swift package clean"
  else
    (cd "$repo_root" && swift package clean)
  fi
fi

if [[ "$include_index_build" -eq 1 ]]; then
  index_build_path="$build_root/index-build"
  if [[ "$dry_run" -eq 1 ]]; then
    if [[ -d "$index_build_path" ]]; then
      local_size="$(du -sh "$index_build_path" 2>/dev/null | awk '{print $1}')"
      echo "would remove $local_size $index_build_path (SourceKit-LSP index)"
    else
      echo "would remove (not present) $index_build_path (SourceKit-LSP index)"
    fi
  else
    echo "WARNING: Removing SourceKit-LSP index ($index_build_path)."
    echo "Next IDE open will reindex (~5-10 min for large projects)."
    if [[ -d "$index_build_path" ]]; then
      local_size="$(du -sh "$index_build_path" 2>/dev/null | awk '{print $1}')"
      echo "removing $local_size $index_build_path"
      if ! rm -rf "$index_build_path" 2>/dev/null; then
        sleep 1
        if ! rm -rf "$index_build_path" 2>/dev/null; then
          echo "  warning: could not fully remove $index_build_path (concurrent writer?); leaving residual" >&2
        fi
      fi
    else
      echo "  (not present — nothing to remove)"
    fi
  fi
fi

# Size budget guard. Soft warning only; exit 0.
if [[ -d "$build_root" ]]; then
  size_human="$(du -sh "$build_root" 2>/dev/null | awk '{print $1}')"
  size_kb="$(du -sk "$build_root" 2>/dev/null | awk '{print $1}')"
  size_gb=$(( size_kb / 1024 / 1024 ))
  echo "$size_human	$build_root"
  if [[ "$size_gb" -ge "$size_warn_gb" && "$auto_mode" -eq 0 ]]; then
    echo ""
    echo "warning: .build/ is still ${size_human} after cleanup (soft budget ${size_warn_gb}G)."
    echo "largest remaining subdirs:"
    du -sh "$build_root"/* 2>/dev/null | sort -rh | head -5 | sed 's/^/  /'
    echo "consider re-running with --swiftpm-clean to nuke the main Swift cache."
  fi
fi
