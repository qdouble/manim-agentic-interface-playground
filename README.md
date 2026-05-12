# Manim Agentic Interface Playground

Bare-bones consumer playground for cycle testing
`ManimAgenticInterface` from outside the maintainer repository.

## Current status

This repository is the external consumer playground for the current
Manim Agentic Interface workflow. `setup.sh` delegates canonical Manim
virtual-environment setup to the MAI CLI, verifies or installs a supported TTS
engine, and dumps generated Claude, Codex, and Gemini provider skill outputs for
local agent use. Historical cycle tags remain available as clean external
baselines when a plan needs to rerun setup/render proof from scratch.

## Expected cycle workflow

```bash
git clone https://github.com/qdouble/manim-agentic-interface-playground mai-playground-cycle
cd mai-playground-cycle
./setup.sh
swift run minimal-scene
```

During active MAI development this repository follows the configured MAI
dependency in `Package.swift`. Release closeout should retarget that dependency
to the proved release tag when a plan explicitly requires tag-based consumer
proof, then rerun clone + setup + render proof.

## What setup does

`setup.sh`:

1. runs `manim-agentic-interface setup --venv`, whose Swift CLI owns Python
   candidate selection, the pinned Manim version, and the canonical
   machine-level virtual environment;
2. verifies or installs a supported TTS engine from a sibling
   `text-to-speech-interface` checkout;
3. dumps the MAI studio-role skills into `.claude/skills/`,
   `.codex/skills/`, and `.gemini/skills/`; and
4. writes the `text-to-speech-interface-consumer` pointer skill beside them.

The generated `.claude/skills/`, `.codex/skills/`, and `.gemini/skills/`
directories are ignored and must not be committed. Source truth stays in MAI
and the global TTS consumer skill.

## Package dependency

During active development, `Package.swift` may point at an MAI branch. When a
release plan needs shareable consumer proof, update it to the proved MAI remote
tag and rerun clone + setup + render proof.

## Create scene sources here

- Put throwaway or cycle-specific scenes under `examples/`.
- Keep durable executable entry points under `Sources/`.
- Do not edit the MAI maintainer repository from this playground.

See `WORKAROUNDS.md` for temporary findings a cycle agent needs to record.
