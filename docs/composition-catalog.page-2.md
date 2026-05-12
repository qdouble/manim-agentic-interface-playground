# Composition Catalog — Page 2

> Continuation of `docs/composition-catalog.md`. Page 1 carries the
> composite tour (bar chart, attention grid, pipeline, coordinate plane,
> triangle proof, auto-layout, topology graphs). This page carries the
> v0.2 timeline-time direction surfaces that operate over a scene's
> existing nodes.

## Camera framing

`TimelineDSL.camera(frameNodes:at:padding:easing:)` declares which nodes
the camera should frame at a given timestamp. The renderer reads the
returned `CameraDirective`, computes the union axis-aligned bounding box
of those nodes' positions, applies `padding` (default `0.5` canvas
units) on every side, and derives a Manim camera zoom/pan from the
resulting `CameraFramingRect`. Direction is timeline-time; the agent
names nodes, not coordinates.

`TimelineDSL.cameraTransition(from:to:duration:startingAt:)` animates
between two `CameraDirective` endpoints over a `PositiveDuration`. The
window is `[startingAt, startingAt + duration]`.

`CameraValidator` verifies framing direction at validation time and
emits three `ValidationIssue.Code` cases (all `severity: .error`):

- `cameraFrameUnknownNode` — `frameNodes` references a node not in the
  scene's node set.
- `cameraFrameOffScreen` — the union framing rect (after padding)
  extends past the renderable canvas (Manim 16:9 default: |x| ≤ 7.5,
  |y| ≤ 4.0).
- `cameraTransitionsOverlap` — two transitions on the same camera have
  intersecting time windows.

### Worked example — frame three nodes, then animate to a wider frame

```swift
let bounds = CompositeBoundingBox.absolute(
    horizontal: 0, vertical: 0, width: 6, height: 3
)
let chart = TimelineDSL.barChart(id: "sort", values: [4, 1, 3, 2], bounds: bounds)

// Beat 1 — zoom in on the three left bars at 2.0s.
let beat1 = TimelineDSL.camera(
    frameNodes: [chart.bar(at: 0), chart.bar(at: 1), chart.bar(at: 2)],
    at: 2.0
)

// Beat 2 — pull out to the full chart at 6.0s.
let beat2 = TimelineDSL.camera(
    frameNodes: chart.barIDs,
    at: 6.0,
    padding: 0.75
)

// Animate from beat 1 to beat 2 over 1.0 second starting at 5.0s.
let pullOut = TimelineDSL.cameraTransition(
    from: beat1,
    to: beat2,
    duration: 1.0,
    startingAt: 5.0
)
```

Author code passes the directives + transitions and the scene's
resolved node positions to `CameraValidator.validate(_:path:)` before
manifest assembly. The validator's `Input` carries `nodePositions:
[NodeID: LayoutPosition]` (resolved to `.absolute` positions through
the scene's geometry resolver) and an optional `canvasHalfWidth` /
`canvasHalfHeight` override for non-default render canvases.

### Why direction not coordinates

Manual camera coordinate authoring guarantees off-screen rendering when
the scene's composite layout shifts between iterations. Naming nodes
keeps direction stable across layout changes: the bounding box is
recomputed from current positions every render. Cycle-3's
`fullSceneCamera()` default left no zoom/pan affordance; the camera
factories give the agent semantic camera control without reaching for
Manim camera APIs.

## Test-driven animation assertions

`TimelineDSL.assertWithinBounds(node:of:at:)`,
`TimelineDSL.assertDistinct(_:_:at:minSeparation:)`, and
`TimelineDSL.assertVisible(_:at:)` declare visual invariants the agent
expects to hold at specific timeline timestamps. Each factory returns a
`SceneAssertion`; failures surface during validation as
`ValidationIssue`s with `severity: .error`, blocking render until the
intent and the resolved layout agree.

```swift
let chartBounds = CompositeBoundingBox.absolute(
    horizontal: 0.0, vertical: 0.0, width: 6.0, height: 3.0
)
let chart = TimelineDSL.barChart(id: "sort", values: [4, 1, 3, 2], bounds: chartBounds)

let assertions: [SceneAssertion] = [
    // The first bar must stay inside the chart's bounding box at 1.0s.
    TimelineDSL.assertWithinBounds(
        node: chart.bar(at: 0),
        of: "sort",
        at: 1.0
    ),
    // The first and last bars must remain at least 0.4 canvas units
    // apart when the swap completes at 2.5s, so they don't visually
    // collide during the transition.
    TimelineDSL.assertDistinct(
        chart.bar(at: 0),
        chart.bar(at: 3),
        at: 2.5,
        minSeparation: 0.4
    ),
    // The pivot bar must stay visible — inside the active camera frame
    // when one is set at 4.0s, otherwise inside the renderable canvas.
    TimelineDSL.assertVisible(chart.bar(at: 1), at: 4.0)
]
```

Author code passes the assertions, the resolved per-node positions, the
composite bounds map, and any active camera directives to
`AssertionValidator.validate(_:path:)` before manifest assembly:

```swift
let issues = AssertionValidator.validate(.init(
    assertions: assertions,
    nodePositions: scene.resolvedAbsolutePositions,
    nodeBounds: ["sort": chart.bounds],
    cameraDirectives: scene.cameraDirectives
))
```

Failed assertions emit one of:

- `assertionWithinBoundsFailed` — node lies outside the reference
  node's rectangle on the named axis.
- `assertionDistinctFailed` — node centres are closer than the supplied
  `minSeparation`.
- `assertionVisibleFailed` — node falls outside the active camera frame
  (when a `CameraDirective` matches the assertion's timestamp) or the
  renderable canvas (otherwise).

Pass an `actionableHint:` to any factory to override the validator's
default recovery suggestion with domain-specific guidance the agent
should see when the assertion fails.

### Why declarative invariants

The cycling-test feedback loop showed that Swift can catch intent-vs-
output mismatches before Python renders, but only when the invariant is
named in code rather than left to visual review. Assertions give the
agent a deterministic gate the storyboard / animation programmer roles
can use to refuse the manifest, with concrete `actionableHint`s that
direct the next cycle's fix. Validator-issue parity (no separate
`AnimationAssertionFailure` type) keeps the failure surface uniform with
container, camera, and graph emissions.
