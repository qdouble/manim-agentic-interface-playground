# Manim Agentic Interface Playground

Bare-bones consumer playground for cycle testing
`ManimAgenticInterface` from outside the maintainer repository.

## Current status

This repository is a W1 scaffold. It intentionally does **not** prove
setup, compile, render, or generated skill output yet. W2 owns the final
`setup.sh` behavior; W3 owns the MAI CLI/resource commands and the first
clean clone + setup + render proof. The `v0.2-base` tag is deferred until
that W3 proof exists.

## Expected cycle workflow

```bash
git clone https://github.com/qdouble/manim-agentic-interface-playground cycle-4-agent
cd cycle-4-agent
./setup.sh
swift run minimal-scene
```

If this scaffold has not been published yet, clone from the local W1 repo
with a `file://` URL instead. Do not claim remote clone proof until the
GitHub repository exists.

## What setup will eventually do

The final `setup.sh` contract is owned by W2/W3 and will:

1. probe Python 3.11+;
2. read the pinned Manim version from MAI;
3. create/update one canonical machine-level Manim virtual environment;
4. verify or install a supported TTS engine from a sibling
   `text-to-speech-interface` checkout;
5. dump the MAI studio-role skills into `.claude/skills/` and
   `.codex/skills/`; and
6. write the `text-to-speech-interface-consumer` pointer skill beside them.

The generated `.claude/skills/` and `.codex/skills/` directories are ignored
and must not be committed. Source truth stays in MAI and the global TTS
consumer skill.

## Package dependency

During the v0.2 plan, `Package.swift` points at the active MAI pre-release
branch. Before final closeout, the dependency must be updated to the proved
MAI v0.2 remote tag and the clone + setup + render proof rerun.

## Create scene sources here

- Put throwaway or cycle-specific scenes under `examples/`.
- Keep durable executable entry points under `Sources/`.
- Do not edit the MAI maintainer repository from this playground.

See `WORKAROUNDS.md` for temporary findings a cycle agent needs to record.
