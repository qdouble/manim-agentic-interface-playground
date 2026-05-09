#!/usr/bin/env bash
set -euo pipefail

TTS_MODELS_DIR="$HOME/Library/Application Support/text-to-speech-interface/models"

swift run --quiet manim-agentic-interface setup --venv

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
