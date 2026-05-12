# Swift-Manim TTS Narration Walkthrough

## 1. Mental model

Use this route when a Swift executable synthesizes narration, builds typed MAI
timeline state, renders with the SDK, and receives an mp4 with audio muxed in.
The consumer surface is Swift-first:

1. `ManimTTSNarrationBuilder` resolves voice/bootstrap and stages audio.
2. `TimelineDSL` builds strongly typed nodes, composites, animations, scenes,
   and documents.
3. `PipelineRenderer.render(document:)` runs the bundled static Python renderer.
4. MAI owns muxing, diagnostics, and render failure envelopes.

Default posture: **automagic by default; granularity is advanced opt-in.**
Do not inspect the sibling TTS repo to author a scene.

## 2. Setup checklist

- Depend on `ManimAgenticInterface` and `ManimAgenticInterfaceTTS`.
- Keep render output under ignored roots such as `.build/manim-renders/<slug>/`.
- Ask the user to install Kokoro or Piper once if they want neural narration.
- Agents must not run `tts-interface install` themselves.
- Use `docs/api-reference-card.md` for exact signatures and
  `docs/composition-catalog.md` for worked composite examples.

Recommended ignored output:

```gitignore
.build/
.build/manim-renders/
.build/tts-output/
```

## 3. Canonical 19-element order

The canonical bundled skill snippet at
`Sources/ManimAgenticInterface/Resources/skills/manim-tts-narration-author/SKILL.md`
keeps one end-to-end flow in this order:

1. `import ManimAgenticInterface` and `import ManimAgenticInterfaceTTS`.
2. `let settings = TimelineDSL.rendererSettings(...)`.
3. `let barIDs: [NodeID] = (0..<n).map { "bar-\($0)" }`.
4. `NodeID(someStringVar)` from a `String`-typed variable.
5. Composite construction such as `TimelineDSL.barChart(...)`.
6. Shape-specific factory such as `TimelineDSL.triangleNode(...)`.
7. Builder and `ManimTTSNarrationBuilder` construction.
8. `synthAndCueAll` returning `ManimTTSNarrationBatchResult` and `.entries`.
9. `cueWithLifecycle` returning `ManimTTSNarrationCueResult` for cue-bound
   visuals; `voiceOver` returning `ManimTTSNarrationCueResult` for voice-only
   narration.
10. `recommendedSceneDuration(covering:)` over `[NarrationCueProvider]`.
11. `TimelineDSL.animate { ... }` without `try` by default, or
    `try TimelineDSL.animate { ... }` only when the closure performs a
    runtime-validated explicit throwing proof such as `try Seconds(runtimeValue)`.
12. Semantic animation enum plus `b.apply(.compare(barIDs[0], barIDs[1]), at: 1.0)`.
13. `b.sequence(on: barIDs[0], startingAt: 1.0) { s in ... }` with at least
    three chained operations.
14. Arithmetic operators such as `let currentTime: Seconds = runtimeStart + 0.5`.
15. `TimelineDSL.scene` and `TimelineDSL.document` using `.entries[i].cue` /
    `.entries[i].asset` or equivalent `.map(\.cue)` / `.map(\.asset)`.
16. `let envelope = await PipelineRenderer.render(document: document)`.
17. Render-failure idiom:
    `failure.actionableHint`, then `failure.rendererSubprocess?.stderrTail`,
    then legacy `failure.detail`.
18. The anti-pattern callout in §11.
19. The composition-catalog table in §6.

Keep default wrapper construction zero-ceremony. Explicit throwing validation is
only for runtime data inside labeled advanced/runtime-validation blocks.

## 4. Default narration path

Use `synthAndCueAll(scripts:)` for a sequence of narrated beats:

```swift
let builder = ManimTTSNarrationBuilder()
let batch = try await builder.synthAndCueAll(scripts: [
    "Open with the data.",
    "Compare the bars.",
    "Render and mux automatically."
])
```

Use `batch.entries` everywhere you need paired cue/asset data:

```swift
let scene = TimelineDSL.scene(
    id: "narrated-scene",
    title: "Narrated Scene",
    duration: batch.recommendedSceneDuration,
    nodes: chart.nodes + chart.labels,
    animations: animations,
    narrationCues: batch.entries.map(\.cue)
)
let document = TimelineDSL.document(
    rendererSettings: settings,
    audioAssets: batch.entries.map(\.asset),
    scenes: [scene]
)
```

When mixing batch and single-cue workflows, keep the paired fields explicit:
`CueWithAsset.cue` goes to `TimelineDSL.scene(..., narrationCues:)`, and
`CueWithAsset.asset` goes to `TimelineDSL.document(..., audioAssets:)`.

## 5. Canonical narrated-cue authoring

v0.2 ships two per-cue factories on `ManimTTSNarrationBuilder`. Pick by
intent: visual content or no visual content.

- **`cueWithLifecycle(...)`** — narrated cue that **introduces** visual
  content. `introducing:` is required so every visual cue carries a
  measurable lifetime; pass `keeping:` for already-on-stage nodes that
  should persist past the cue end. The default `exitTransition` is
  `.crossfade(duration: 0.3)` so successive cues connect smoothly.
- **`voiceOver(...)`** — narrated cue that does **not** change visual
  state. Use it for narrative transitions, conceptual asides, and payoff
  narration over persistent context.

Both return `ManimTTSNarrationCueResult` carrying `cue: NarrationCue`,
`audioAsset: AudioAsset`, and (only `cueWithLifecycle`) populated
`lifecycleEntries`.

### 5.1 Visual cue with lifecycle

```swift
let lifecycleCue = try await builder.cueWithLifecycle(
    text: "This triangle appears for one narrated beat.",
    sceneRelativeStart: 0.5,
    introducing: [triangle],
    exitTransition: .crossfade(duration: 0.3)
)
```

Add `lifecycleCue.cue` and `lifecycleCue.audioAsset` to the final document,
build authored animations first, then append
`TimelineDSL.cueLifecycleAnimations(lifecycleCue.lifecycleEntries, avoiding: authoredAnimations)`
to scene animations. The `avoiding:` argument shifts generated lifecycle
entry or exit transitions away from authored move/transform/semantic
animations on the same node, so overlap diagnostics should not be fixed by
deleting lifecycle animations.
Argument order is `introducing:`, then `keeping:`, then `exitTransition:`.
Timing lives at `cue.cue.timing.start`, `cue.cue.timing.duration`, and
`cue.cue.timing.end`; start the next cue after the previous `.end` plus a
gap to avoid overlap.

### 5.2 Voice-only cue over persistent state

```swift
let aside = try await builder.voiceOver(
    text: "Listen for the next observation; nothing new appears.",
    sceneRelativeStart: lifecycleCue.cue.timing.end + 0.25
)
```

`voiceOver` does not emit `lifecycleEntries`, so do not pass it to
`TimelineDSL.cueLifecycleAnimations(...)`. Treat `aside.cue` and
`aside.audioAsset` like any other narration entry.

### 5.3 Mixing batch + per-cue factories

```swift
let narrationEntries = batch.entries + [
    CueWithAsset(cue: lifecycleCue.cue, asset: lifecycleCue.audioAsset),
    CueWithAsset(cue: aside.cue, asset: aside.audioAsset),
]
let providers: [NarrationCueProvider] = batch.entries.map { $0 as NarrationCueProvider }
    + [lifecycleCue, aside]
let duration = ManimTTSNarrationBuilder.recommendedSceneDuration(covering: providers)
let scene = TimelineDSL.scene(
    id: "mixed-narration",
    title: "Mixed Narration",
    duration: duration,
    nodes: baseNodes + [triangle],
    animations: authoredAnimations + TimelineDSL.cueLifecycleAnimations(
        lifecycleCue.lifecycleEntries,
        avoiding: authoredAnimations
    ),
    narrationCues: narrationEntries.map(\.cue)
)
let document = TimelineDSL.document(
    rendererSettings: settings,
    audioAssets: narrationEntries.map(\.asset),
    scenes: [scene]
)
```

## 6. Composition catalog by use case

Prefer semantic composites before hand-placing primitives:

| Use case | Composite | Animation enum | Canonical example |
|---|---|---|---|
| Sorting algorithm | `barChart` | `SortingAnimation` | `sorting-tour` |
| Attention mechanism | `attentionGrid` | `AttentionAnimation` | `transformer-paper` |
| Pipeline / compiler | `pipelineStages` | `PipelineAnimation` | `interpreter-pipeline` |
| Optimization / gradient descent | `coordinatePlane` | `OptimizationAnimation` | `gradient-descent` |
| Geometric proof | `triangleProof` | shape-specific factories | `pythagorean` |

Worked code for every row lives in `docs/composition-catalog.md`.
For quality, pick the visible state change before writing code: Pythagorean
proofs reveal sides/squares then the relation, sorting compares/swaps/marks
sorted bars, attention highlights tokens and weighted edges, gradient descent
shows gradient then step then settle, and pipeline scenes move a token through
stage boxes instead of only flashing labels. Before a low-reasoning retest claims
done, run `scripts/check-render-richness.sh <mp4...>` and add moving objects or
longer visible transitions if the video bitrate proxy fails its default floor.

## 7. Semantic animations and sequencing

Use semantic animation enums for the domain move, then use `NodeSequencer` for
per-node choreography:

```swift
let animations = TimelineDSL.animate { b in
    b.apply(.compare(barIDs[0], barIDs[1]), at: 1.0)
    b.apply(.highlight(attention.token(at: 0)), at: 0.25)
    b.apply(.gradientStep(theta.id, to: plane.position(x: -0.2, y: 1.4)), at: 1.0)
    b.apply(.flowToken(tokenID: token.id, through: route), at: 0.5)
    b.sequence(on: barIDs[0], startingAt: 1.0) { s in
        s.then(.fadeIn())
        s.then(.emphasize())
        s.then(.move(to: TimelineDSL.absolute(horizontal: -1.5, vertical: 2.2)))
    }
}
```

Add `try` to the `TimelineDSL.animate` call only when the closure itself calls a
throwing initializer or helper, for example `let start = try
Seconds(runtimeStartSeconds)`. Literal wrapper values and semantic animation
builders do not throw.

Sorting, attention, optimization, and pipeline enums lower to typed MAI
animations. Shape-specific factories are the only current shape-authoring path.
When authoring helper-owned nodes, set the edge id with
`TimelineDSL.attentionEdgeID(from:to:)` and the gradient arrow id with
`TimelineDSL.gradientArrowID(for:)`; missing-node diagnostics point back to
those builders.

## 8. Textual feedback before manual review

Low-reasoning lanes must generate and read textual feedback after writing final
source, not just inspect bitrate or storyboard images. For TTS runtime packages,
use `TimelineFeedbackReporter().report(for: document)` as in the canonical
skill snippet. For source-gated visual-only scratch files, use the CLI:

```bash
manim-agentic-interface feedback --source .build/mai-sdk-scratch/scene.swift \
  --output .build/mai-feedback/scene.feedback.md \
  --intended-sequence "Insert title; Wait 0.5s; Fade in key object"
```

The Markdown report summarizes canvas/grid scale, node IDs, positions, bounds,
text extents, contrast/overlap/out-of-bounds/unknown findings, ordered actions,
wait gaps, cue lifecycle/semantic helper actions, and intent alignment. Fix
actionable `error`/`warning` findings before asking for visual review.

## 9. Render and failure handling

Render the in-memory document directly:

```swift
let envelope = await PipelineRenderer.render(document: document)
if case .failure = envelope.status, let failure = envelope.failure {
    if let hint = failure.actionableHint { print(hint) }
    if let stderrTail = failure.rendererSubprocess?.stderrTail {
        print(stderrTail)
    } else if let detail = failure.detail {
        print(detail)
    }
}
if case .success = envelope.status, let success = envelope.success {
    print("Rendered MP4: \(success.artifactPath)")
    print("Run: scripts/check-render-richness.sh \"\(success.artifactPath)\"")
}
```

Treat a thin failure as SDK signal to report upstream; do not debug the bundled
renderer or Python environment by hand.

## 10. Advanced opt-in granularity

Only drop below the default APIs when the user asks for pinned voice, custom
asset policy, transcript IDs, manual cache identity, neural-engine-only
rejection, or runtime-computed values that need throwing validation.

Advanced route:

1. Build `ManimTTSNarrationRequest.synthesisOnly(...)`.
2. Call `ManimTTSNarrationBuilder.buildNarration(...)`.
3. Attach timing with `ManimTTSNarrationResult.makeNarrationCue(...)`.
4. Put the result's cue and asset into `TimelineDSL.document(...)`.

## 11. Anti-pattern callout

**Never invoke `manim`, `python3`, `uv`, or `pip` directly. Never inspect
`.venv/`.** The MAI SDK manages the Python runtime for you. The pipeline is:
Swift entrypoint → SDK → bundled Python renderer → mp4. If a render fails,
capture `failure.actionableHint`, `failure.rendererSubprocess?.stderrTail`, and
legacy `failure.detail`, then surface that SDK evidence. If the
detail is thin, record the thin-failure case as SDK signal. **Do not debug the
renderer, TTS engine internals, Python environment, or Manim outside the SDK.**

Also avoid `TextToSpeechInterface.mux(...)` for MAI video narration, local path
hardcoding, source-gated rendering for synthesize-first scenes, and resurrecting
`examples/sdk/tts-narrated-*` or `examples/sdk/tts-narrated/`.

## 12. Governance lint troubleshooting

Use `scripts/swift-build-with-governance-lints.sh --skip-update` as the build
path that runs the consumer-surface governance lints plus SourceKit-LSP IDE
diagnostics before compilation.
Plain `swift build --skip-update` compiles without those wrapper lints. There
is no bypass flag for the wrapper route.

- Autofix-supported: `bash scripts/check-zero-try-canonical.sh --fix`,
  `bash scripts/check-no-throwaway-scripts.sh --fix`, and
  `bash scripts/check-no-cross-repo-mai-edits.sh --fix`.
- No autofix: `bash scripts/check-no-raw-process-invocation.sh`. Replace raw
  subprocess guidance with typed MAI/TTS SDK calls.
- SourceKit diagnostics: `bash scripts/check-sourcekit-diagnostics.sh`. Fix the
  reported Swift source instead of excluding files or demoting severities.
- Rerun `bash scripts/swift-build-with-governance-lints.sh --skip-update`.

## 13. Studio team and Director subagent (v0.2)

v0.2 decomposes TTS-narrated authoring into a Director orchestrator plus 9
specialist roles. Each specialist owns one concern and is loaded as a
separate skill so a mid-tier model cannot accidentally absorb another role's
work. The orchestrator skill (`manim-tts-narration-author`) carries the
studio sequence, anti-pattern callouts, multi-act guidance for animations
longer than 90 seconds, and the Director handoff contract. The 9 specialist
skills carry the per-role contracts and remain bundled for spawned subagents.

Studio sequence (orchestrator delegates in this order):

1. `manim-tts-narration-script` — Writer. Drafts narration script + beat
   structure + wps budget; produces `script.md`.
2. `manim-tts-narration-storyboard` — Storyboard artist. Per-beat text
   storyboard from the script; produces `storyboard.md`.
3. `manim-tts-narration-technical-lead` — Technical lead. Swift file
   scaffold, dual-registration contract, validator coverage, lint inner
   loop, scratch-shape guidance.
4. `manim-tts-narration-composition` — Animation programmer. Visual node
   selection only (composites + children).
5. `manim-tts-narration-timing` — Editor. Cue start/duration/lifecycle
   and per-cue audio crossfade timing.
6. `manim-tts-narration-sound` — Scene-wide audio policy (engine, voice, wps).
7. `manim-tts-narration-technical-lead` — Integration pass. Integrates
   Steps 3-6 artifacts and runs `swift run`; Director does not assemble.
8. `manim-tts-narration-render-fix-loop` — Bug fixer. 3-attempt circuit
   breaker for render failures and validator errors.
9. `manim-tts-narration-visual-review` — Visual reviewer. Render vs.
   `storyboard.md` verdict.
10. `manim-tts-narration-executive-producer` — Brief-satisfaction verdict.

### Dual verdict-artifact gate

Before declaring a scene done, **both** verdict artifacts must exist with
`STATUS: CLEAR`:

- `.build/feedback/<scene>/visual-review-verdict.md` — sole writer is the
  visual reviewer. Internal coherence (render matches `storyboard.md`).
- `.build/feedback/<scene>/executive-producer-verdict.md` — sole writer is
  the executive producer. External coherence (render matches the user's
  original brief). Names the upstream specialist to escalate to in the
  `ESCALATION:` field if `STATUS: BLOCKING`.

If either verdict file is missing or BLOCKING, the Director must escalate
per the executive-producer's escalation table; "build passed" or "render
rendered" is not a substitute for either CLEAR verdict.

### Claude Code subagent companion

`.claude/agents/manim-tts-narration-author.md` is the Claude Code subagent
companion. It loads only the Director skill, lists specialists as delegation
targets, and requires each spawned specialist subagent to read its own skill.

## 14. Engine fallback and cleanup

If voice discovery falls back to AVSpeech, narration may sound robotic and run
slowly. Ask the user to install Kokoro or Piper once; do not install engines as
the agent.

`metadata_not_drawn` is intentionally not emitted in v0.1.2. Do not wait for it
or branch on it.

Use source-gated `.build/mai-sdk-scratch/<slug>.swift` or
`.build/mai-sdk-scratch/<slug>/main.swift` only for visual-only DSL examples
that run through `manim-agentic-interface feedback --source` or
`manim-agentic-interface render --source`. TTS synthesize-first examples are scratch SwiftPM runtime packages
under `.build/mai-sdk-scratch/<slug>/Sources/<Exec>/main.swift`; run them with
`swift run --package-path .build/mai-sdk-scratch/<slug> <Exec>`, read the
in-memory feedback Markdown they emit, then pass the printed
`envelope.success.artifactPath` to `scripts/check-render-richness.sh <mp4...>`.
Commit a flat `examples/sdk/<name>.swift` only for durable source-gated
examples; then register one executable target, exclude every other flat example
file, and update the SDK tooling test scene-file list.
