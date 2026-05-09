# Manim Agentic Interface Playground

Bare-bones consumer playground for cycle testing
`ManimAgenticInterface` from outside the maintainer repository.

## Current status

This repository is the external consumer playground for MAI v0.2 pre-release
proof. The setup/render route has landed for the active pre-release branch:
`setup.sh` delegates canonical Manim virtual-environment setup to the MAI CLI,
verifies or installs a supported TTS engine, and dumps generated provider skill
outputs for local agent use. The `v0.2-base` tag exists as the clean external
baseline for rerunning setup/render proof.

## Expected cycle workflow

```bash
git clone https://github.com/qdouble/manim-agentic-interface-playground cycle-4-agent
cd cycle-4-agent
./setup.sh
swift run minimal-scene
```

During the v0.2 patch route this repository depends on the active MAI
pre-release branch. Final closeout must retarget the dependency to the proved
MAI v0.2 tag and rerun clone + setup + render proof.

## What setup does

`setup.sh`:

1. runs `manim-agentic-interface setup --venv`, whose Swift CLI owns Python
   candidate selection, the pinned Manim version, and the canonical
   machine-level virtual environment;
2. verifies or installs a supported TTS engine from a sibling
   `text-to-speech-interface` checkout;
3. dumps the MAI studio-role skills into `.claude/skills/` and
   `.codex/skills/`; and
4. writes the `text-to-speech-interface-consumer` pointer skill beside them.

The generated `.claude/skills/` and `.codex/skills/` directories are ignored
and must not be committed. Source truth stays in MAI and the global TTS
consumer skill.

## Package dependency

During the v0.2 plan, `Package.swift` points at the active MAI pre-release
branch. The only remaining dependency carry-forward before final closeout is
to update it to the proved MAI v0.2 remote tag and rerun clone + setup +
render proof.

## Create scene sources here

- Put throwaway or cycle-specific scenes under `examples/`.
- Keep durable executable entry points under `Sources/`.
- Do not edit the MAI maintainer repository from this playground.

See `WORKAROUNDS.md` for temporary findings a cycle agent needs to record.
