# Claude Guidance

This is a **consumer playground** for the Manim Agentic Interface (MAI).

## ⚠️ Rule #1 — The Director MUST delegate

The Director (`manim-tts-narration-author`) is an **orchestrator only**.
It must dispatch every specialist task to a dedicated subagent. The
Director does NOT write Swift code, does NOT fix compile errors, does NOT
pick voices, does NOT author animations, and does NOT debug renders.

When a compile error or test failure occurs, the Director must spawn
the appropriate specialist subagent (e.g., Technical Lead for build
errors, Bug Fixer for runtime failures) rather than attempting the fix
itself. A Director that absorbs specialist work will exhaust its context
window and produce incoherent output.

See `docs/playground-workflow.md` for the full subagent dispatch table.

## Project objective

Author a TTS-narrated Manim animation using the MAI SDK's studio-team
specialist skills. The animation must render cleanly with motion-richness
≥ 0.4 and pass the default video richness floor enforced by
`scripts/check-render-richness.sh`.

## Workflow

Follow `docs/playground-workflow.md`. It is the single procedural entry
point — do not improvise outside its steps.
Spatial storyboard work also reads `docs/spatial-storyboard-layout.md`
for the CLI `--storyboard` route and diagnostics artifact contract.
For pre-merge branch testing, read `docs/mai-branch-pin.md` to confirm
which MAI branch this seeded playground consumes.

## Skills — loading isolation

The Director ONLY loads its own skill:
`.claude/skills/manim-tts-narration-author/SKILL.md`

The Director must NOT open or read any other skill file. Specialist
skills are at `.claude/skills/<slug>/SKILL.md` but they are for the
**subagent** to read when it is spawned — not the Director. Loading
specialist skills into the Director's context pollutes it with
implementation detail and causes the Director to attempt specialist
work. Each spawned subagent reads its own skill file independently.

## Subagent file

`.claude/agents/manim-tts-narration-author.md` loads only the Director
skill. It names the 9 specialists as delegation targets; each spawned
specialist subagent loads its own `.claude/skills/<slug>/SKILL.md` body.

## Hard rules

- Do NOT edit the MAI dependency (anything under `.build/checkouts/`).
- Do NOT invoke `manim`, `python3`, `uv`, or `pip` directly.
- Do NOT inspect `.venv/`.
- Do NOT write output to `/tmp/` or other system-temp directories.
  All renders, frames, and scratch output must stay inside the project.
- Record workarounds in `WORKAROUNDS.md`.
- Keep render output under `.build/`.
- Do NOT change the `Package.swift` dependency pin without user approval.
- Write scene code in `Sources/<TargetName>/`, NOT in `.build/`.
  `.build/` is gitignored — code written there is invisible to the user.

## Rendering

Use the library route (`swift run <target>`). Register your target in
`Package.swift` and write code under `Sources/<TargetName>/`.

## Shareable-repo rules

- No personal absolute paths in committed files.
- No tokens, emails, or provider artifacts in committed files.
- `.build`, `.venv`, `.claude/skills/` are gitignored.
