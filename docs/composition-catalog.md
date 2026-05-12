# Composition Catalog

Use the typed composite that matches the explanation before hand-placing
primitive nodes. Each example below is literal-driven and avoids default-path
value-wrapper construction ceremony.

| Use case | Composite | Animation enum | Canonical example |
|---|---|---|---|
| Sorting algorithm | `TimelineDSL.barChart` | `SortingAnimation` | `sorting-tour` |
| Attention mechanism | `TimelineDSL.attentionGrid` | `AttentionAnimation` | `transformer-paper` |
| Pipeline / compiler | `TimelineDSL.pipelineStages` | `PipelineAnimation` | `interpreter-pipeline` |
| Optimization / gradient descent | `TimelineDSL.coordinatePlane` | `OptimizationAnimation` | `gradient-descent` |
| Geometric proof | `TimelineDSL.triangleProof` | shape-specific factories | `pythagorean` |
| Auto-layout (row / column / grid) | `TimelineDSL.hStack` / `vStack` / `grid` | n/a (positions are eager) | `auto-layout-row` / `auto-layout-column` / `auto-layout-grid` |
| Topology graph (directed) | `TimelineDSL.directedGraph` | n/a (positions are eager) | `topology-graph-directed` |
| Topology graph (tree) | `TimelineDSL.treeGraph` | n/a (positions are eager) | `topology-graph-tree` |
| Semantic camera framing | `TimelineDSL.camera` / `cameraTransition` | n/a (timeline-time direction) | see `composition-catalog.page-2.md` |

## sorting-tour

```swift
let bounds = CompositeBoundingBox.absolute(horizontal: 0, vertical: 0, width: 6, height: 3)
let chart = TimelineDSL.barChart(id: "sort", values: [4, 1, 3], bounds: bounds)
let swap = chart.swap(0, 1)
let animations = TimelineDSL.animate { b in
    b.apply(swap.animation, at: 0.5)
    b.apply(.compare(chart.bar(at: 1), chart.bar(at: 2)), at: 1.25)
    b.apply(.markSorted(chart.bar(at: 0)), at: 2.0)
}
let nodes = chart.nodes + chart.labels
```

## transformer-paper

```swift
let bounds = CompositeBoundingBox.absolute(horizontal: 0, vertical: 0, width: 7, height: 2)
let grid = TimelineDSL.attentionGrid(
    id: "attention",
    tokens: ["query", "key", "value"],
    bounds: bounds
)
let edge = TimelineDSL.arrowNode(
    id: TimelineDSL.attentionEdgeID(from: grid.token(at: 0), to: grid.token(at: 1)),
    from: grid.nodes[0].position,
    to: grid.nodes[1].position,
    style: VisualStyle(stroke: "#38BDF8", opacity: 1.0)
)
let animations = TimelineDSL.animate { b in
    b.apply(.highlight(grid.token(at: 0)), at: 0.25)
    b.apply(.weighted(from: grid.token(at: 0), to: grid.token(at: 1), weight: 0.8), at: 0.75)
    b.apply(.decayAll(edges: [edge.id]), at: 1.5)
}
let nodes = grid.nodes + grid.labels + [edge]
```

## interpreter-pipeline

```swift
let bounds = CompositeBoundingBox.absolute(horizontal: 0, vertical: 0, width: 8, height: 2)
let stages = TimelineDSL.pipelineStages(
    id: "compiler",
    stages: ["Lex", "Parse", "Typecheck", "Emit"],
    bounds: bounds
)
let token = TimelineDSL.circleNode(
    id: "work-token",
    position: stages.position(for: stages.stage(at: 0)) ?? TimelineDSL.absolute(horizontal: -3, vertical: 0),
    style: VisualStyle(fill: "#F59E0B", opacity: 1.0)
)
let route = stages.stageIDs.compactMap { id in stages.position(for: id).map { (stage: id, at: $0) } }
let animations = TimelineDSL.animate { b in
    b.apply(.flowToken(tokenID: token.id, through: route), at: 0.5)
    b.apply(.highlightStage(stages.stage(at: 2)), at: 1.5)
}
let nodes = stages.nodes + stages.labels + [token]
```

## gradient-descent

```swift
let bounds = CompositeBoundingBox.absolute(horizontal: 0, vertical: 0, width: 6, height: 4)
let plane = TimelineDSL.coordinatePlane(id: "loss", bounds: bounds, xRange: -2...2, yRange: 0...4)
let point = TimelineDSL.circleNode(
    id: "theta",
    position: plane.position(x: -1.5, y: 3.0),
    style: VisualStyle(fill: "#38BDF8", opacity: 1.0)
)
let gradArrow = TimelineDSL.arrowNode(
    id: TimelineDSL.gradientArrowID(for: point.id),
    from: plane.position(x: -1.5, y: 3.0),
    to: plane.position(x: -0.5, y: 1.5),
    style: VisualStyle(stroke: "#F97316", opacity: 1.0)
)
let animations = TimelineDSL.animate { b in
    b.apply(.showGradient(at: point.id, magnitude: 0.7), at: 0.25)
    b.apply(.gradientStep(point.id, to: plane.position(x: -0.5, y: 1.5)), at: 0.75)
    b.apply(.settle(at: point.id), at: 1.5)
}
let nodes = plane.nodes + plane.labels + [point, gradArrow]
```

## pythagorean

```swift
let bounds = CompositeBoundingBox.absolute(horizontal: 0, vertical: 0, width: 6, height: 4)
let proof = TimelineDSL.triangleProof(id: "pythagorean", legA: 3, legB: 4, bounds: bounds)
let highlight = TimelineDSL.rectangleNode(
    id: "area-highlight",
    position: TimelineDSL.absolute(horizontal: 1.5, vertical: 1.0),
    style: VisualStyle(stroke: "#FBBF24", opacity: 1.0)
)
let animations = TimelineDSL.animate { b in
    b.sequence(on: proof.triangleID, startingAt: 0.25) { s in
        s.then(.fadeIn())
        s.then(.emphasize())
    }
    b.fadeIn(target: highlight.id, at: 1.25)
}
let nodes = proof.nodes + proof.labels + [highlight]
```

## Auto-layout

`hStack`, `vStack`, and `grid` place equally-spaced children around a single
anchor. Spacing is the center-to-center pitch (matches SwiftUI's stack
semantics for fixed-pitch children). Per-child positions, the
`CompositeBoundingBox`, and any `canvasDistanceClamped` issue all materialize
at factory call time; no separate validator pass runs.

### auto-layout-row

```swift
let row = TimelineDSL.hStack(
    id: "stages",
    spacing: 1.0,
    alignment: .center,
    position: .center,
    children: ["lex", "parse", "emit"].enumerated().map { index, label in
        TimelineDSL.rectangleNode(
            id: NodeID("stage-\(index)"),
            position: .center,
            style: VisualStyle(fill: "#1F2937", stroke: "#3B82F6", opacity: 1.0)
        )
    }
)
let nodes = row.nodes
```

### auto-layout-column

```swift
let column = TimelineDSL.vStack(
    id: "legend",
    spacing: 0.6,
    alignment: .leading,
    position: .center,
    children: ["query", "key", "value"].enumerated().map { index, label in
        TimelineDSL.circleNode(
            id: NodeID("legend-\(index)"),
            position: .center,
            style: VisualStyle(fill: "#3B82F6", opacity: 1.0)
        )
    }
)
let nodes = column.nodes
```

### auto-layout-grid

```swift
let lattice = TimelineDSL.grid(
    id: "attention-grid",
    rows: 2,
    columns: 3,
    spacing: 0.8,
    position: .center,
    children: (0..<6).map { index in
        TimelineDSL.rectangleNode(
            id: NodeID("cell-\(index)"),
            position: .center,
            style: VisualStyle(fill: "#3B82F6", opacity: 1.0)
        )
    }
)
let cell = lattice.child(row: 1, column: 2)
let nodes = lattice.nodes
```

### When to use which alignment system

v0.2 ships two alignment systems that serve distinct authoring intents.
Both are public API; pick by use case.

- `Alignment` (existing, v0.1.x): `center / topLeading / topTrailing /
  bottomLeading / bottomTrailing` — corner-based anchors. Use when an
  API asks for a single anchor point that combines horizontal and
  vertical (for example, `LayoutPosition.region(_, alignment: .topTrailing)`
  pins a region to its parent's top-right corner). It encodes
  *placement of* a composite within its parent canvas region.
- `HorizontalAlignment` + `VerticalAlignment` (NEW, v0.2):
  `.leading/.center/.trailing` and `.top/.center/.bottom` independent
  axes. Use when horizontal and vertical alignment are decided
  independently — exactly the case for stack layouts (`hStack` picks a
  vertical alignment for children of varying heights; `vStack` picks
  horizontal), and for `ChildPlacement.alignment(H, V)` in
  containers. It encodes *placement between* children inside a stack
  or grid.

The two systems are not duplicates and not interchangeable. The
parameter type-checks against exactly one (the stack factory's
`alignment:` parameter takes a `VerticalAlignment` for `hStack` or a
`HorizontalAlignment` for `vStack`; `LayoutPosition.region` takes an
`Alignment`), so authoring code cannot accidentally mix them.

## Containers and child rebinding

`TimelineDSL.container(...)` pairs a shape (rectangle, rounded,
circle, capsule) with explicitly-placed children inside the
shape's inner area (post-padding). Each `ContainerChild` carries a
declarative `ChildPlacement`; the factory resolves placements to
absolute positions eagerly so Python sees literal coordinates.

`TimelineDSL.rebind(...)` re-parents a child from one container
into another at a given timestamp. The hop pattern is the
canonical authoring shape for elements that traverse pipeline
stages, attention positions, or array slots while persisting via
`keeping:`. During the `[at, at + duration]` rebind window the
runtime envelope z-elevates the migrating child to the top of the
draw order so it never slides visually underneath its destination
container; the elevation is automatic and bounded to the window.

### container-and-hop

```swift
let label = TimelineDSL.textNode(
    id: "label",
    text: try! NonEmptyText(validating: "token"),
    position: .center,
    style: VisualStyle(opacity: 1.0)
)

let stageA = TimelineDSL.container(
    id: "stageA",
    shape: .rounded(
        cornerRadius: 0.1,
        fill: try! HexColor(validating: "#3B82F6"),
        stroke: try! HexColor(validating: "#000000")
    ),
    bounds: CompositeBoundingBox(center: .leading, width: 2.0, height: 1.5),
    children: [
        ContainerChild(node: label, placement: .alignment(.center, .center))
    ]
)

let stageB = TimelineDSL.container(
    id: "stageB",
    shape: .rounded(
        cornerRadius: 0.1,
        fill: try! HexColor(validating: "#10B981"),
        stroke: try! HexColor(validating: "#000000")
    ),
    bounds: CompositeBoundingBox(center: .center, width: 2.0, height: 1.5)
)

let stageC = TimelineDSL.container(
    id: "stageC",
    shape: .rounded(
        cornerRadius: 0.1,
        fill: try! HexColor(validating: "#F59E0B"),
        stroke: try! HexColor(validating: "#000000")
    ),
    bounds: CompositeBoundingBox(center: .trailing, width: 2.0, height: 1.5)
)

let hopAtoB = TimelineDSL.rebind(
    child: "label",
    to: "stageB",
    at: 2.0,
    duration: 0.5
)

let hopBtoC = TimelineDSL.rebind(
    child: "label",
    to: "stageC",
    at: 4.0,
    duration: 0.5
)
```

### Validator codes

`RebindValidator.validate(_:)` surfaces four `ValidationIssue.Code`
cases for rebind authoring mistakes:

- `rebindWindowOverlap` — two rebind directives on the same child
  whose `[at, at + duration]` windows overlap. Stagger the second
  directive's `at:` past the first's `at + duration`.
- `rebindMissingDestination` — `to:` references a container ID
  that does not exist in the supplied container set. Add the
  container factory or correct the destination ID.
- `containerOverflow` — the child's resolved placement falls
  outside the destination container's inner area (post-padding).
  The actionable hint names the overflow axis and slack.
- `rebindOrphanedChild` — the destination container's lifecycle
  ends before `at + duration`. Extend the container's lifetime or
  rebind to a container that survives the transition.

### Unbinding

Pass `to: nil` and supply `freePosition:` to detach a child from
its current container without re-parenting; the child floats at
`freePosition` until the next rebind. Reach for this only when no
destination container is appropriate; the canonical hop pattern
prefers a non-nil destination.

## Topology graphs

`TimelineDSL.directedGraph` and `TimelineDSL.treeGraph` lay out
research-paper topologies (state machines, syntax trees, neural-net
layers) without hand-placing each vertex. Both factories run a
deterministic seeded layout so the same input produces the same
positions across reruns; the optional `seed:` parameter locks the
spatial layout across multi-beat sequences (R2-Risk 5).

### topology-graph-directed

```swift
let bounds = CompositeBoundingBox.absolute(horizontal: 0, vertical: 0, width: 8, height: 4.5)
let graph = TimelineDSL.directedGraph(
    id: "states",
    nodes: [GraphNode(id: "start"), GraphNode(id: "running"), GraphNode(id: "done")],
    edges: [
        GraphEdge(from: "start", to: "running"),
        GraphEdge(from: "running", to: "done")
    ],
    bounds: bounds,
    nodeStyle: VisualStyle(fill: "#3B82F6", opacity: .full),
    edgeStyle: VisualStyle(stroke: "#94A3B8", opacity: .full)
)
let nodes = graph.nodes + graph.edges + graph.labels
```

### topology-graph-tree

```swift
let bounds = CompositeBoundingBox.absolute(horizontal: 0, vertical: 0, width: 8, height: 4.5)
let tree = TimelineDSL.treeGraph(
    id: "ast",
    root: .branch("expr", label: nil, children: [
        .leaf("lhs", label: nil),
        .branch("op", label: nil, children: [
            .leaf("op-a", label: nil),
            .leaf("op-b", label: nil)
        ]),
        .leaf("rhs", label: nil)
    ]),
    bounds: bounds,
    orientation: .topDown
)
let nodes = tree.nodes + tree.edges + tree.labels
```

### Multi-beat continuity (R2-Risk 5)

When the storyboard grows or shrinks the node set across beats, lock
the explicit `seed:` to the same `UInt64` so the original nodes keep
their coordinates and only the new node settles into available space.
Without the lock, the auto-derived ID hash changes between beats and
every node teleports.

```swift
// Beat 1 — initial 6 nodes
let beat1 = TimelineDSL.directedGraph(
    id: "graph",
    nodes: initialNodes,
    edges: initialEdges,
    bounds: bounds,
    seed: 0x4D41_4901  // locked
)

// Beat 2 — adds a 7th node; original 6 stay where they were
let beat2 = TimelineDSL.directedGraph(
    id: "graph",
    nodes: initialNodes + [GraphNode(id: "n6")],
    edges: initialEdges + [GraphEdge(from: "n5", to: "n6")],
    bounds: bounds,
    seed: 0x4D41_4901  // SAME locked seed
)
```

When `seed:` is non-nil, the layout favours continuity over force
optimisation: each node's position is derived purely from
`(seed, NodeID)` so a node added between beats does not perturb the
positions of any other node.

## Maintenance note

This catalog is manually maintained in v0.1.2. A v0.2 follow-up should generate
the table and signature links from Swift source or DocC.
