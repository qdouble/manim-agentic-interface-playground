#!/usr/bin/env bash
set -euo pipefail

CANONICAL_VENV="$HOME/Library/Application Support/manim-agentic-interface/venv"
TTS_MODELS_DIR="$HOME/Library/Application Support/text-to-speech-interface/models"

if ! command -v python3 >/dev/null 2>&1; then
    echo "ERROR: python3 not found on PATH. Install Python 3.11+ from"
    echo "       https://www.python.org/downloads/ or via Homebrew:"
    echo "       brew install python@3.13"
    exit 1
fi

PY_VERSION="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
PY_MAJOR="$(echo "$PY_VERSION" | cut -d. -f1)"
PY_MINOR="$(echo "$PY_VERSION" | cut -d. -f2)"
if [[ "$PY_MAJOR" -ne 3 ]] || [[ "$PY_MINOR" -lt 11 ]]; then
    echo "ERROR: Python $PY_VERSION found; v0.2 requires Python 3.11+."
    echo "       Install Python 3.11+ from https://www.python.org/downloads/."
    exit 1
fi

MANIM_VERSION="$(
    swift run --quiet --skip-build manim-agentic-interface pinned-manim-version 2>/dev/null \
        | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' \
        | tail -1
)"
if [[ -z "$MANIM_VERSION" ]]; then
    MANIM_VERSION="$(
        swift run --quiet manim-agentic-interface pinned-manim-version 2>/dev/null \
            | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' \
            | tail -1
    )"
fi
if [[ -z "$MANIM_VERSION" ]]; then
    echo "ERROR: failed to read the pinned manim version from"
    echo "       'manim-agentic-interface pinned-manim-version'."
    echo "       Re-run from a clean SwiftPM checkout."
    exit 1
fi

mkdir -p "$(dirname "$CANONICAL_VENV")"

LOCK_DIR="$(dirname "$CANONICAL_VENV")/.setup.lock"
LOCK_WAIT=0
until mkdir "$LOCK_DIR" 2>/dev/null; do
    if [[ "$LOCK_WAIT" -ge 60 ]]; then
        echo "ERROR: another setup.sh is holding the venv lock at"
        echo "       $LOCK_DIR for >60s. Remove the lock dir if no"
        echo "       other setup.sh is running, then re-run."
        exit 1
    fi
    sleep 1
    LOCK_WAIT=$((LOCK_WAIT + 1))
done
trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

if [[ ! -d "$CANONICAL_VENV" ]]; then
    python3 -m venv "$CANONICAL_VENV"
    "$CANONICAL_VENV/bin/pip" install --upgrade pip
    "$CANONICAL_VENV/bin/pip" install "manim==$MANIM_VERSION"
fi

INSTALLED_MANIM="$("$CANONICAL_VENV/bin/python" -c \
    "import manim; print(manim.__version__)" 2>/dev/null || echo "missing")"
if [[ "$INSTALLED_MANIM" != "$MANIM_VERSION" ]]; then
    "$CANONICAL_VENV/bin/pip" install --upgrade "manim==$MANIM_VERSION"
fi

if [[ ! -d "$TTS_MODELS_DIR/kokoro" ]] && [[ ! -d "$TTS_MODELS_DIR/piper" ]]; then
    TTS_REPO=""
    for cand in "../text-to-speech-interface" \
                "$HOME/Developer/Swift-Apps/text-to-speech-interface" \
                "$HOME/text-to-speech-interface"; do
        if [[ -f "$cand/Package.swift" ]]; then
            TTS_REPO="$cand"
            break
        fi
    done

    if [[ -n "$TTS_REPO" ]]; then
        echo "TTS engines missing. Installing kokoro from sibling checkout"
        echo "  at $TTS_REPO ..."
        ( cd "$TTS_REPO" && swift run --quiet tts-interface install kokoro ) \
            || { echo "ERROR: 'tts-interface install kokoro' failed in $TTS_REPO."; exit 1; }
    else
        echo "ERROR: TTS engines not installed AND no sibling"
        echo "       text-to-speech-interface checkout found at any of:"
        echo "         ../text-to-speech-interface"
        echo "         ~/Developer/Swift-Apps/text-to-speech-interface"
        echo "         ~/text-to-speech-interface"
        echo ""
        echo "Remediation: clone the TTS repo as a sibling, then re-run setup.sh:"
        echo "  git clone <text-to-speech-interface URL> ../text-to-speech-interface"
        echo "  cd <playground> && ./setup.sh"
        echo ""
        echo "Or run the install manually:"
        echo "  cd <text-to-speech-interface> && swift run tts-interface install kokoro"
        exit 1
    fi
fi

swift run --quiet manim-agentic-interface dump-skills --dest .claude/skills --provider claude
swift run --quiet manim-agentic-interface dump-skills --dest .codex/skills --provider codex

for provider_dir in .claude/skills .codex/skills; do
    mkdir -p "$provider_dir/text-to-speech-interface-consumer"
    cat > "$provider_dir/text-to-speech-interface-consumer/SKILL.md" <<'EOF'
---
name: text-to-speech-interface-consumer
description: Use when this playground or any consumer repo needs deterministic TTS through the public SwiftPM product/module `TextToSpeechInterface` or the `tts-interface` CLI. Guides sibling-checkout setup, typed Swift usage, local engine proof, and consumer boundaries without crawling implementation files.
---

# Text-to-Speech Interface Consumer (playground pointer)

This is a thin pointer to the canonical global skill at
`~/.claude/skills/text-to-speech-interface-consumer/SKILL.md`
(Claude side) or
`~/.codex/skills/text-to-speech-interface-consumer/SKILL.md`
(Codex side). Load that skill by description match for the full
consumer guidance: sibling-checkout discovery, public-API entry
points (`TTSRequest`, `TTSScript`, `TTSOptions`, `EngineConfig`),
typed Swift usage, local engine proof, and `tts-interface` CLI
commands (install/list/proof/cache).

The playground's setup.sh has already verified at least one TTS
engine (kokoro or piper) is installed at
`~/Library/Application Support/text-to-speech-interface/models/`,
or installed it from the sibling checkout if missing.
EOF
done

echo "Setup complete. Run 'swift build' to verify."
