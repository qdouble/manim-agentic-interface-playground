# Playground Workflow

Single procedural trigger for authoring a TTS-narrated Manim animation
using the MAI SDK's studio-team specialist skills. Follow every step in
order. Do not skip steps or absorb specialist work into the Director.

## What this project is

**Manim Agentic Interface (MAI)** is a Swift-first pipeline for
agent-driven Manim motion graphics. You define animation states and
timelines through strongly-typed Swift structs; Swift validates the
timeline and streams structured data to a static Python renderer over
standard input. Python is a deterministic Manim adapter — you never
touch it.

The **TTS narration layer** (`ManimAgenticInterfaceTTS`) synthesizes
speech via Kokoro/Piper/AVSpeech and muxes it into the final MP4. The
consumer entry point is `ManimTTSNarrationBuilder` which returns typed
`NarrationCue` and `AudioAsset` values that plug directly into
`TimelineDSL.scene(narrationCues:)` and
`TimelineDSL.document(audioAssets:)`.

The **studio team** is 10 specialist skills (1 Director + 9 specialists)
that decompose scene authoring into discrete, non-overlapping roles.
Each specialist has a SKILL.md body under
`Sources/ManimAgenticInterface/Resources/skills/<slug>/SKILL.md` in the
MAI package. After `setup.sh` runs, these are dumped into local
`.claude/skills/`, `.codex/skills/`, and `.gemini/skills/` directories in
your playground.

## Rules (binding)

- Do NOT invoke `manim`, `python3`, `uv`, or `pip` directly.
- Do NOT inspect `.venv/`.
- Do NOT edit the MAI dependency (anything under `.build/checkouts/`).
- Do NOT change `Package.swift`'s dependency pin without user approval.
- Record workarounds in `WORKAROUNDS.md`, not as code hacks.
- Keep all output under `.build/`.
- Each subagent reads ONLY its assigned skill body.
- Each subagent loads `docs/api-reference-card.md` FIRST.
- No subagent does work outside its role.
- The Director routes artifacts between subagents — it does not do
  specialist work itself.

## Testing an MAI feature branch before merge

When the user asks the playground to test an unmerged MAI branch, use the MAI
source repo seed script so branch pinning, setup, docs copy, and build proof all
come from one supported path:

```bash
scripts/seed-cycle-playground.sh --mai-branch codex/spatial-storyboard-layout \
  --build-proof /path/to/cycle-playground pythagorean
```

The script pins the playground `Package.swift` before running setup, then runs
`swift package reset`, `swift package resolve`, `swift build`, and `swift test`
unless `--skip-build-proof` is explicitly passed. It also writes
`docs/mai-branch-pin.md` into the playground with the selected branch and the
exact proof commands. Do not inspect `.build/checkouts/` to discover behavior;
use the copied docs and public CLI outputs.

## Your assignment

Create a TTS-narrated animated video that is at least 30 seconds long
(no maximum). Pick one topic from this catalog, or use the topic in
`.cycle-topic` if that file exists:

| Topic | Composite | Animation Enum |
|---|---|---|
| Pythagorean theorem | `triangleProof` | shape-specific |
| Sorting tour | `barChart` | `SortingAnimation` |
| Transformer paper | `attentionGrid` | `AttentionAnimation` |
| Gradient descent | `coordinatePlane` | `OptimizationAnimation` |
| Interpreter pipeline | `pipelineStages` | `PipelineAnimation` |

See `docs/composition-catalog.md` for the worked code example behind
each row.

## Reference docs to load first

Load these local copied docs before authoring:

1. **`docs/api-reference-card.md`** — signatures-only catalog of every
   public DSL factory, composite, validator code, and value type.
   Load this FIRST, always.
2. **`docs/composition-catalog.md`** — worked code per composite use
   case (sorting, attention, pipeline, gradient descent, Pythagorean).
3. **`docs/swift-manim-tts-narration-walkthrough.md`** — end-to-end
   narration path including the canonical 19-element order.
4. **`docs/spatial-storyboard-layout.md`** — required `Spatial grid`,
   legend, motion, constraints, CLI `--storyboard` route, diagnostics
   artifacts, and frame-observation contract.

## Procedural steps

### Step 0 — You are the Director (orchestrator only)

Read **only** the Director skill body:
`<skills-dir>/manim-tts-narration-author/SKILL.md`

Where `<skills-dir>` is `.claude/skills`, `.codex/skills`, or
`.gemini/skills` depending on your provider.

**Do NOT read any other skill file.** Specialist skill files exist at
`<skills-dir>/<slug>/SKILL.md` but they are for the **subagent** to
read — not the Director. Loading specialist skills into the Director's
context pollutes it with implementation detail and causes the Director
to attempt specialist work.

**Critical:** The Director does NOT do specialist work. For each step
below marked `[SUBAGENT]`, you MUST spawn a separate subagent (child
agent with its own context window). Give each subagent:
- The specialist's slug — tell the subagent to read its own skill at
  `<skills-dir>/<slug>/SKILL.md`
- `docs/api-reference-card.md` as required context
- The upstream artifact(s) from the previous step

The subagent reads its own skill file, does its work, and returns its
artifact to you. You hand that artifact to the next subagent. This is
mandatory because a single agent doing all 9 roles will exhaust its
context window and produce incoherent output.

### Step 1 — [SUBAGENT: Writer]

**Skill:** `manim-tts-narration-script`
**Input:** chosen topic + `docs/api-reference-card.md`
**Output:** `script.md` (beat structure, narration prose, wps budget)
**Confined to:** narration prose, beat structure, tone parameters.
The Writer does NOT write Swift code.

### Step 2 — [SUBAGENT: Storyboard artist]

**Skill:** `manim-tts-narration-storyboard`
**Input:** `script.md` + `docs/api-reference-card.md`
**Output:** `storyboard.md` (per-beat visual breakdown)
**Confined to:** visual breakdown, `Spatial grid`, legend, motion,
constraints, primitive picks, and persistence hints.
The Storyboard artist does NOT write Swift code.

### Step 3 — [SUBAGENT: Technical lead]

**Skill:** `manim-tts-narration-technical-lead`
**Input:** `storyboard.md` + `docs/api-reference-card.md`
**Output:** Swift file scaffold + `Package.swift` target registration
**Confined to:** file structure, imports, builder bootstrap, canonical
snippet shape. Registers a new executable target in the playground's
`Package.swift` and creates `Sources/<TargetName>/main.swift`.

Do NOT create throwaway packages under `.build/` — that path is
gitignored and makes code invisible to the user.

### Step 4 — [SUBAGENT: Animation programmer] (per beat)

**Skill:** `manim-tts-narration-composition`
**Input:** `storyboard.md` beat N + `docs/api-reference-card.md`
**Output:** composite + child node catalog for beat N
**Confined to:** visual node selection and slot-to-node placement ONLY.
Consumes compiled storyboard slots; does NOT decide cue start times,
durations, or `introducing:/keeping:/exitTransition:` values.
That is the Editor's call (Decision 11 binding).

### Step 5 — [SUBAGENT: Editor] (per beat)

**Skill:** `manim-tts-narration-timing`
**Input:** beat N catalog + `script.md` durations
**Output:** `cueWithLifecycle` / `voiceOver` calls with timing filled in
**Confined to:** `sceneRelativeStart:`, durations, `introducing:`,
`keeping:`, `exitTransition:`, per-cue `fadeIn/fadeOut/leadIn/tail`.
Does NOT pick TTS engine or voice — that is the Sound designer's call.

### Step 6 — [SUBAGENT: Sound designer]

**Skill:** `manim-tts-narration-sound`
**Input:** `script.md` tone field
**Output:** engine + voice + scene-wide audio policy
**Confined to:** TTS engine selection (Kokoro/Piper/AVSpeech), base
voice selection, wps budget enforcement. Invoked once per scene, not
per beat.

### Step 7 — [SUBAGENT: Technical Lead integration]

**Skill:** `manim-tts-narration-technical-lead`
**Input:** all production artifacts from Steps 3-6
**Output:** final Swift source path + `swift run <target-name>` result
**Confined to:** integrating scaffold, animation catalogs, timing cues,
and sound policy into the executable target. The Director must not
assemble or combine final Swift source.

```bash
swift run <target-name>
```

After integration succeeds and before visual review, run the
storyboard-aware gate with explicit roots:

```bash
manim-agentic-interface matrix --source Sources/<TargetName>/main.swift \
  --storyboard storyboard.md --output-root .build/feedback/<scene>/matrix

manim-agentic-interface feedback --source Sources/<TargetName>/main.swift \
  --storyboard storyboard.md --output .build/feedback/<scene>/feedback.md --json
```

On success, the rendered MP4 is at `.build/manim-renders/<slug>/`.
Storyboard-aware diagnostics are under:

```text
.build/feedback/<scene>/feedback.md
.build/feedback/<scene>/feedback.json
.build/feedback/<scene>/matrix/storyboard-layout/storyboard-layout.json
.build/feedback/<scene>/matrix/storyboard-layout/storyboard-layout-report.json
.build/feedback/<scene>/matrix/storyboard-layout/storyboard-layout-report.md
.build/feedback/<scene>/matrix/storyboard-matrix/storyboard-matrix.png
.build/feedback/<scene>/matrix/storyboard-matrix/storyboard-matrix.json
.build/feedback/<scene>/matrix/frame-observations.json
```

### Step 8 — [SUBAGENT: Bug fixer] (if Step 7 failed)

**Skill:** `manim-tts-narration-render-fix-loop`
**Input:** `PipelineRenderFailure` envelope
**Procedure:** 3-attempt circuit-breaker loop. Read
`failure.actionableHint`, then `failure.rendererSubprocess?.stderrTail`,
then `failure.detail`. Map validator codes to the fix template in the
skill body's mapping table. After 3 attempts, write a blocker artifact
and surface to the Director.

### Step 9 — [SUBAGENT: Visual reviewer]

**Skill:** `manim-tts-narration-visual-review`
**Input:** rendered MP4 + Director-supplied scene source path + `storyboard.md`
**Output:** `.build/feedback/<scene>/visual-review-verdict.md`
**Procedure:** 5-step multi-modal review loop. Compare rendered frames
and machine findings from `storyboard-layout-report.md`,
`storyboard-matrix.png`, and frame observations to `storyboard.md`
beat-by-beat. Classify mismatches per Decision 12: validator-code
mismatches → Bug fixer; composition mismatches → Animation programmer;
storyboard bugs → Storyboard artist.

### Step 10 — [SUBAGENT: Executive producer]

**Skill:** `manim-tts-narration-executive-producer`
**Input:** rendered MP4 + user's brief + `script.md` + `storyboard.md`
**Output:** `.build/feedback/<scene>/executive-producer-verdict.md`
**Procedure:** compare the final render against the user's original
assignment. Check for the 5 drift modes: topic drift, scope creep,
scope shrink, wrong audience level, aesthetic drift.

### Step 11 — Declare done

The Director declares done ONLY when BOTH verdict artifacts exist
with `STATUS: CLEAR`:

1. `.build/feedback/<scene>/visual-review-verdict.md` → `STATUS: CLEAR`
2. `.build/feedback/<scene>/executive-producer-verdict.md` → `STATUS: CLEAR`

If either is `BLOCKING`, escalate per the verdict's `ESCALATION:` field
and re-run the affected leg of the studio sequence.

A "build passed" or "render rendered" signal is NOT a substitute for
either CLEAR verdict.

## Subagent delegation rules

- Each subagent MUST read its assigned SKILL.md body before starting.
- Each subagent loads `docs/api-reference-card.md` FIRST.
- Subagents hand artifacts back to the Director; they do not invoke
  each other directly.
- The Director passes upstream artifacts to each downstream subagent.
- For multi-beat scenes, Steps 4 and 5 iterate per beat; the Writer's
  beat structure is the loop index.
- The Sound designer (Step 6) is invoked once per scene, not per beat.

## What "done" looks like

- [ ] Rendered MP4 with video + audio under `.build/manim-renders/`
- [ ] `storyboard-layout-report.md` has no blocking parser, quality,
      static-geometry, or frame-observation findings
- [ ] Video bitrate passes `scripts/check-render-richness.sh` default floor
- [ ] Motion richness score ≥ 0.4
- [ ] `visual-review-verdict.md` exists with `STATUS: CLEAR`
- [ ] `executive-producer-verdict.md` exists with `STATUS: CLEAR`
- [ ] Workarounds (if any) logged in `WORKAROUNDS.md`
