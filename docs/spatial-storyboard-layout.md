# Spatial Storyboard Layout

Use this route when a scene needs machine-checkable spatial intent instead of
prose-only visual notes. The storyboard is still Markdown, but each beat also
declares a typed ASCII grid that Swift parses, validates, compiles, and compares
against rendered frames.

## Storyboard contract

Each beat must include:

````markdown
## Beat 1 — setup

Initial frame: title, chart
Final frame: title, chart, callout
Primitive picks: title, chart, callout
Persisted into next beat: title, chart

Spatial grid: 16x9
```
..TTTTTT........
..TTTTTT........
................
..CCCCCC....AAAA
..CCCCCC....AAAA
..CCCCCC........
................
................
................
```

Visible: title, chart, callout
Absent: old-chart

Legend:
- T: title role=title kind=text
- C: chart role=mainDiagram kind=chart
- A: callout role=callout kind=arrow

Motion:
- chart -> callout kind=emphasisArrow reason=explain-delta

Constraints:
- title above chart
- callout rightOf chart
````

Rules:

- `Spatial grid: <columns>x<rows>` must match the fenced grid dimensions.
- Before strict parsing, MAI applies only deterministic grid hygiene: common
  fence indentation, line endings, trailing spaces, missing trailing `.`
  placeholders, surplus trailing `.`, and explicitly blank declared rows may be
  normalized. Repairs are reported as non-blocking `storyboard.gridSanitized`
  findings with source pointers and dimensions.
- `.` is background; every other printable ASCII glyph must have one `Legend`
  row.
- Legend rows bind glyphs to typed `NodeID`s, semantic roles, primitive kinds,
  optional groups, and text budgets.
- `Visible:` and `Absent:` are frame expectations for matrix and frame-observation
  review.
- `Motion:` and `Constraints:` declare responsibility-bearing spatial intent;
  do not leave meaningful motion as prose.

## CLI route

Run storyboard-aware diagnostics through the public CLI; do not inspect package
dependency checkouts or renderer internals for normal use.

Expected setup path for the current pre-merge spatial-storyboard branch:

1. From a checked-out MAI source repo, seed a fresh playground with the branch
   pin and build proof:

   ```bash
   scripts/seed-cycle-playground.sh --mai-branch codex/spatial-storyboard-layout \
     --build-proof /path/to/playground-clone pythagorean
   ```

   The seed helper pins the playground dependency before setup, runs SwiftPM
   resolve/build/test proof unless `--skip-build-proof` is passed, and writes
   `docs/mai-branch-pin.md` in the playground.
2. Confirm the CLI is on `PATH` before asking an agent to run diagnostics:

   ```bash
   command -v manim-agentic-interface
   manim-agentic-interface preflight
   ```

If `command -v` fails, re-run playground setup or ask the operator to expose the
MAI CLI on `PATH`. Do not fall back to raw `python`, raw `manim`,
dependency-checkout spelunking, or home-directory manifests.

```bash
manim-agentic-interface feedback \
  --source Sources/MyScene/main.swift \
  --storyboard storyboard.md \
  --output .build/mai-feedback/my-scene.feedback.md \
  --json

manim-agentic-interface matrix \
  --source Sources/MyScene/main.swift \
  --storyboard storyboard.md \
  --output-root .build/mai-feedback/my-scene-matrix \
  --json
```

The `feedback` route embeds storyboard layout findings into the feedback report.
The `matrix` route blocks before render when parser, quality, or static-geometry
findings are blocking.

Concrete artifact roots:

```text
.build/mai-feedback/my-scene.feedback.md
.build/mai-feedback/my-scene.feedback.json
.build/mai-feedback/my-scene/storyboard-layout/storyboard-layout.json
.build/mai-feedback/my-scene/storyboard-layout/storyboard-layout-report.json
.build/mai-feedback/my-scene/storyboard-layout/storyboard-layout-report.md
.build/mai-feedback/my-scene-matrix/storyboard-matrix/storyboard-matrix.png
.build/mai-feedback/my-scene-matrix/storyboard-matrix/storyboard-matrix.json
.build/mai-feedback/my-scene-matrix/frame-observations.json
```

## Diagnostics artifacts

Storyboard-aware runs write these public artifacts under the chosen `.build`
output root:

- `storyboard-layout/storyboard-layout.json` — parsed typed storyboard document
  when parsing succeeds.
- `storyboard-layout/storyboard-layout-report.json` — machine-readable parser,
  quality, compiled-slot, static-geometry, and post-render findings.
- `storyboard-layout/storyboard-layout-report.md` — human-readable summary with
  issue codes, responsibility labels, and artifact links.
- `storyboard-matrix/storyboard-matrix.png` — primary contact sheet for visual
  review.
- `storyboard-matrix/storyboard-matrix.json` and `.md` — sampled-frame
  expectations and notes.
- `frame-observations.json` — renderer-emitted bounding boxes, visibility,
  z-index, opacity, and camera-frame metadata when frame observations are
  requested.

Stable issue codes use the `storyboard.*` namespace, including sanitizer
metadata such as `storyboard.gridSanitized`, parser/quality codes such as
`storyboard.gridNonRectangular`, static-geometry codes such as
`storyboard.staticGeometryMismatch`, and post-render codes such as
`storyboard.frameObservationMismatch` and
`storyboard.rendererObservationMissing`.

## Responsibility routing

- `storyboarding` — malformed grids, missing legend rows, prose/grid mismatch,
  weak spatial structure, or missing motion/constraints.
- `composition` — Swift nodes do not occupy the compiled storyboard slots.
- `timingLifecycle` — expected visible/absent state diverges because cue
  lifecycle persistence is wrong.
- `technicalIntegration` — CLI/source-gate/render observation wiring is broken.
- `renderFix` — renderer metadata or frame-observation output is missing or
  invalid.

## Supported and unsupported surfaces

Supported:

- Public Swift model types (`StoryboardLayoutDocument`, `StoryboardBeat`,
  `StoryboardGrid`, `StoryboardLegendEntry`, `StoryboardCompiledLayout`,
  `StoryboardLayoutReport`, `StoryboardFrameObservationDocument`).
- CLI `feedback --storyboard` and `matrix --storyboard` routes.
- `.build` diagnostics artifacts listed above.

Unsupported:

- Agent-generated Python or renderer edits.
- Treating prose-only storyboard notes as a substitute for `Spatial grid`,
  `Legend`, `Motion`, and `Constraints`.
- Reading dependency checkouts, home-directory manifests, or provider-local plan
  files as normal route documentation.
