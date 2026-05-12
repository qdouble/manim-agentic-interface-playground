# API Reference Card — v0.2

Signatures-only catalog. Grep for factory, type, or validator code.
v0.2 manually maintained; auto-generation from Swift source.

## TimelineDSL core

`TimelineDSL.document(schemaVersion: Int = RendererContract.currentSchemaVersion, rendererSettings: RendererSettings, assets: [SceneAsset] = [], dataTables: [DataTable] = [], audioAssets: [AudioAsset] = [], equationTemplates: [EquationTemplate] = [], renderEnvironment: RenderEnvironmentSettings = .default, researchComponents: [ResearchComponent] = [], scenes: [Scene]) -> TimelineDocument`
`TimelineDSL.rendererSettings(canvas: CanvasSize, backgroundColor: HexColor, framesPerSecond: Int = 30, quality: RendererQuality = .preview, enabledCapabilities: Set<RendererCapability> = Set(RendererCapability.allCases), allowedOpcodes: Set<RendererOpcode> = Set(RendererOpcode.allCases)) -> RendererSettings`
`TimelineDSL.canvas(width: Double, height: Double) -> CanvasSize`
`TimelineDSL.scene(id: SceneID, title: NonEmptyText, duration: PositiveDuration, layoutRegions: [LayoutRegion] = [], camera: CameraPlan = .init(target: .fullScene), nodes: [VisualNode] = [], animations: [Animation] = [], narrationCues: [NarrationCue] = [], researchReferences: [ResearchComponentID] = [], defaultCueTransition: CueExitTransition? = nil) -> Scene`
`TimelineDSL.absolute(horizontal: Double, vertical: Double) -> LayoutPosition`
`TimelineDSL.style(fill: HexColor? = nil, stroke: HexColor? = nil, opacity: UnitInterval) -> VisualStyle`

### Coordinate system

Manim's default frame for a 1280×720 canvas is **14.2 × 8.0 units** centered
at the origin. Keep node positions within:

| Axis | Safe range | Hard limit |
|---|---|---|
| Horizontal | ±6.5 | ±7.1 |
| Vertical | ±3.5 | ±4.0 |

Positions outside the hard limit will fail the `cameraFrameOffScreen` validator.

### Named duration constants

| Name | Value | Typical use |
|---|---|---|
| `.oneTenth` | 0.1 s | narration fades, short waits |
| `.oneQuarter` | 0.25 s | short transitions, default fadeIn |
| `.oneHalf` | 0.5 s | standard transitions, default tail |
| `.one` | 1.0 s | medium pauses |
| `.two` | 2.0 s | scene holds |
| `.three` | 3.0 s | long holds |

All are `PositiveDuration` statics. You can also use float literals directly:
`PositiveDuration(0.75)` or `let d: PositiveDuration = 0.75`.

## TimelineDSL visual factories

`TimelineDSL.textNode(id: NodeID, text: NonEmptyText, role: TextRole = .body, position: LayoutPosition, style: VisualStyle, lifetime: TimeRange? = nil, zIndex: DrawOrder = DrawOrder(), accessibilityLabel: NonEmptyText? = nil) -> VisualNode`
`TimelineDSL.triangleNode(id: NodeID, position: LayoutPosition, style: VisualStyle, vertices: TriangleVertices? = nil, lifetime: TimeRange? = nil, zIndex: DrawOrder = DrawOrder(), accessibilityLabel: NonEmptyText? = nil) -> VisualNode`
`TimelineDSL.rectangleNode(id: NodeID, position: LayoutPosition, style: VisualStyle, lifetime: TimeRange? = nil, zIndex: DrawOrder = DrawOrder(), accessibilityLabel: NonEmptyText? = nil) -> VisualNode`
`TimelineDSL.lineNode(id: NodeID, from: LayoutPosition, to: LayoutPosition, style: VisualStyle, lifetime: TimeRange? = nil, zIndex: DrawOrder = DrawOrder(), accessibilityLabel: NonEmptyText? = nil) -> VisualNode`
`TimelineDSL.arrowNode(id: NodeID, from: LayoutPosition, to: LayoutPosition, style: VisualStyle, lifetime: TimeRange? = nil, zIndex: DrawOrder = DrawOrder(), accessibilityLabel: NonEmptyText? = nil) -> VisualNode`
`TimelineDSL.circleNode(id: NodeID, position: LayoutPosition, style: VisualStyle, lifetime: TimeRange? = nil, zIndex: DrawOrder = DrawOrder(), accessibilityLabel: NonEmptyText? = nil) -> VisualNode`

## TimelineDSL animation builders

`TimelineDSL.animate(_ build: (inout AnimationBuilder) throws -> Void) rethrows -> [Animation]`
Zero-`try` rule: `TimelineDSL.animate { ... }` does not throw unless the closure
throws; use `try TimelineDSL.animate { ... }` only when the closure includes
throwing runtime validation such as `try Seconds(runtimeValue)`.
`AnimationBuilder.fadeIn(target: NodeID, at start: Seconds, duration: PositiveDuration = .oneQuarter, easing: Easing = .linear)`
`AnimationBuilder.fadeOut(target: NodeID, at start: Seconds, duration: PositiveDuration = .oneQuarter, easing: Easing = .linear)`
`AnimationBuilder.write(target: NodeID, at start: Seconds, duration: PositiveDuration = .oneHalf, easing: Easing = .linear)`
`AnimationBuilder.move(target: NodeID, to position: LayoutPosition, at start: Seconds, duration: PositiveDuration = .oneHalf, easing: Easing = .linear)`
`AnimationBuilder.transform(target: NodeID, scale: Double, at start: Seconds, duration: PositiveDuration = .oneQuarter, easing: Easing = .linear)`
`AnimationBuilder.emphasize(target: NodeID, at start: Seconds, duration: PositiveDuration = .oneHalf, easing: Easing = .linear)`
`AnimationBuilder.apply(_ sorting: SortingAnimation, at start: Seconds)`
`AnimationBuilder.apply(_ attention: AttentionAnimation, at start: Seconds)`
`AnimationBuilder.apply(_ optimization: OptimizationAnimation, at start: Seconds)`
`AnimationBuilder.apply(_ pipeline: PipelineAnimation, at start: Seconds)`
`AnimationBuilder.sequence(on node: NodeID, startingAt start: Seconds, build: (inout NodeSequencer) -> Void)`
`NodeSequencer.then(_ op: NodeOperation)`
`NodeSequencer.then(_ op: NodeOperation, gap: PositiveDuration)`
`NodeSequencer.wait(_ duration: PositiveDuration)`
`TimelineDSL.attentionEdgeID(from query: NodeID, to key: NodeID) -> NodeID`
`TimelineDSL.gradientArrowID(for node: NodeID) -> NodeID`

## TimelineDSL composites

`CompositeBoundingBox.absolute(horizontal: Double, vertical: Double, width: Double, height: Double) -> CompositeBoundingBox`
`TimelineDSL.barChart(id: NodeID, values: [Double], bounds: CompositeBoundingBox, barColor: HexColor = "#3B82F6", labelColor: HexColor = "#F8FAFC") -> BarChartComposite`
`BarChartComposite.bar(at index: Int) -> NodeID`
`BarChartComposite.label(at index: Int) -> NodeID`
`BarChartComposite.position(forBarAt index: Int) -> LayoutPosition`
`BarChartComposite.swap(_ aIndex: Int, _ bIndex: Int, duration: PositiveDuration = .oneHalf) -> (animation: SortingAnimation, aPos: LayoutPosition, bPos: LayoutPosition)`
`TimelineDSL.attentionGrid(id: NodeID, tokens: [String], bounds: CompositeBoundingBox, tokenColor: HexColor = "#F8FAFC", labelColor: HexColor? = nil) -> AttentionGridComposite`
`AttentionGridComposite.token(at index: Int) -> NodeID`
`TimelineDSL.pipelineStages(id: NodeID, stages: [String], bounds: CompositeBoundingBox, boxColor: HexColor = "#1F2937", arrowColor: HexColor = "#3B82F6") -> PipelineStagesComposite`
`PipelineStagesComposite.stage(at index: Int) -> NodeID`
`PipelineStagesComposite.stage(named name: String) -> NodeID?`
`PipelineStagesComposite.position(for stageID: NodeID) -> LayoutPosition?`
`TimelineDSL.coordinatePlane(id: NodeID, bounds: CompositeBoundingBox, xRange: ClosedRange<Double>, yRange: ClosedRange<Double>, gridColor: HexColor = "#374151") -> CoordinatePlaneComposite`
`CoordinatePlaneComposite.position(x: Double, y: Double) -> LayoutPosition`
`TimelineDSL.triangleProof(id: NodeID, legA: Double, legB: Double, bounds: CompositeBoundingBox, triangleColor: HexColor = "#3B82F6", squareAColor: HexColor = "#EF4444", squareBColor: HexColor = "#10B981", squareCColor: HexColor = "#F59E0B") -> TriangleProofComposite`
Factory defaults: omitted `lifetime` = visible for scene, omitted `zIndex` = `DrawOrder()`, omitted
`accessibilityLabel` = `nil`, `attentionGrid(labelColor: nil)` chooses a contrast-safe foreground,
composite color arguments use the literal defaults shown in this section.

## TimelineDSL auto-layout factories

`TimelineDSL.hStack(id: NodeID, spacing: CanvasDistance = 0.5, alignment: VerticalAlignment = .center, position: LayoutPosition = .center, children: [VisualNode]) -> StackComposite`
`TimelineDSL.vStack(id: NodeID, spacing: CanvasDistance = 0.5, alignment: HorizontalAlignment = .center, position: LayoutPosition = .center, children: [VisualNode]) -> StackComposite`
`TimelineDSL.grid(id: NodeID, rows: Int, columns: Int, spacing: CanvasDistance = 0.5, position: LayoutPosition = .center, children: [VisualNode]) -> GridComposite`
`HorizontalAlignment`: `.leading`, `.center`, `.trailing`
`VerticalAlignment`: `.top`, `.center`, `.bottom`

## TimelineDSL container / rebind factories

`TimelineDSL.container(id: NodeID, shape: ContainerShape, bounds: CompositeBoundingBox, padding: EdgeInsets = .symmetric(0.2), children: [ContainerChild] = []) -> ContainerComposite`
`TimelineDSL.rebind(child: NodeID, to destinationContainer: NodeID? = nil, placement: ChildPlacement = .alignment(.center, .center), freePosition: LayoutPosition? = nil, at: Seconds, duration: PositiveDuration = 0.5, easing: Easing = .easeInOut) -> RebindDirective`
`ContainerComposite`: `.id`, `.nodes`, `.bounds`, `.shape: VisualNode`, `.containerShape: ContainerShape`, `.padding: EdgeInsets`, `.children: [ContainerChild]`, `.child(_ id: NodeID) -> VisualNode?`
`ContainerShape`: `.rectangle(fill: HexColor, stroke: HexColor)`, `.rounded(cornerRadius: CanvasDistance, fill: HexColor, stroke: HexColor)`, `.circle(fill: HexColor, stroke: HexColor)`, `.capsule(fill: HexColor, stroke: HexColor)`
`ContainerChild`: `init(node: VisualNode, placement: ChildPlacement)`
`ChildPlacement`: `.alignment(HorizontalAlignment, VerticalAlignment)`, `.relative(x: UnitInterval, y: UnitInterval)`, `.offset(x: Double, y: Double)`, `.freePosition(LayoutPosition)`
`EdgeInsets`: `.symmetric(_ value: CanvasDistance) -> EdgeInsets`, `.only(top:leading:bottom:trailing:) -> EdgeInsets`
Validator codes: `rebindWindowOverlap`, `rebindMissingDestination`, `containerOverflow`, `rebindOrphanedChild`

## TimelineDSL camera factories

`TimelineDSL.camera(frameNodes: [NodeID], at: Seconds, padding: CanvasDistance = 0.5, easing: Easing = .easeInOut) -> CameraDirective`
`TimelineDSL.cameraTransition(from: CameraDirective, to: CameraDirective, duration: PositiveDuration, startingAt: Seconds) -> CameraTransitionDirective`
`CameraDirective`: `.frameNodes: [NodeID]`, `.at: Seconds`, `.padding: CanvasDistance`, `.easing: Easing`
`CameraTransitionDirective`: `.from: CameraDirective`, `.to: CameraDirective`, `.duration: PositiveDuration`, `.startingAt: Seconds`, `.windowStart: Double`, `.windowEnd: Double`, `.isWithinWindow(_ time: Seconds) -> Bool`
Validator codes: `cameraFrameUnknownNode`, `cameraFrameOffScreen`, `cameraTransitionsOverlap`

## TimelineDSL graph factories

`TimelineDSL.directedGraph(id: NodeID, nodes: [GraphNode], edges: [GraphEdge], bounds: CompositeBoundingBox, nodeStyle: VisualStyle = .default, edgeStyle: VisualStyle = .default, seed: UInt64? = nil) -> DirectedGraphComposite`
`TimelineDSL.treeGraph(id: NodeID, root: TreeNode, bounds: CompositeBoundingBox, nodeStyle: VisualStyle = .default, edgeStyle: VisualStyle = .default, orientation: TreeOrientation = .topDown, seed: UInt64? = nil) -> TreeGraphComposite`
Seed semantics: `seed: nil` derives seed from sorted NodeID FNV-1a hash (changes when node set changes); explicit seed overrides for multi-beat layout continuity and skips FR convergence check.
`GraphNode`: `init(id: NodeID, label: NonEmptyText? = nil)`
`GraphEdge`: `init(from: NodeID, to: NodeID, label: NonEmptyText? = nil)`
`TreeNode`: `.leaf(NodeID, label: NonEmptyText?)`, `.branch(NodeID, label: NonEmptyText?, children: [TreeNode])`
`TreeOrientation`: `.topDown`, `.leftRight`
`GraphLayoutAlgorithm`: `.fruchtermanReingold`, `.reingoldTilford`
Validator codes: `graphEdgeUnknownEndpoint`, `graphDuplicateNodeID`, `graphLayoutDidNotConverge`

## TimelineDSL assertion factories

`TimelineDSL.assertWithinBounds(node: NodeID, of referenceNode: NodeID, at: Seconds, actionableHint: String? = nil) -> SceneAssertion`
`TimelineDSL.assertDistinct(_ nodeA: NodeID, _ nodeB: NodeID, at: Seconds, minSeparation: CanvasDistance = 0.1, actionableHint: String? = nil) -> SceneAssertion`
`TimelineDSL.assertVisible(_ node: NodeID, at: Seconds, actionableHint: String? = nil) -> SceneAssertion`
`SceneAssertion`: `.withinBounds(node:of:at:actionableHint:)`, `.distinct(nodeA:nodeB:at:minSeparation:actionableHint:)`, `.visible(node:at:actionableHint:)`
Validator codes: `assertionWithinBoundsFailed`, `assertionDistinctFailed`, `assertionVisibleFailed`

## TTS narration

`ManimTTSNarrationBuilder.init(synthesizer: any ManimTTSNarrationSynthesizing = TextToSpeechNarrationSynthesizer())`
`ManimTTSNarrationBuilder.synthAndCueAll(scripts: [String], voice: Voice? = nil, startingAt: Seconds = 0.0, gap: PositiveDuration = .oneHalf, tail: PositiveDuration = .oneHalf, assetPolicy: ManimTTSNarrationAssetPolicy = .default()) async throws -> ManimTTSNarrationBatchResult`
`ManimTTSNarrationBatchResult.entries: [CueWithAsset]`
`CueWithAsset.cue: NarrationCue`; `CueWithAsset.asset: AudioAsset`
`ManimTTSNarrationBatchResult.recommendedSceneDuration: PositiveDuration`
`ManimTTSNarrationBuilder.cueWithLifecycle(text: String, sceneRelativeStart: Seconds, voice: Voice? = nil, introducing entryNodes: [VisualNode], keeping persistingNodes: [VisualNode] = [], exitTransition: CueExitTransition = .crossfade(duration: 0.3), assetPolicy: ManimTTSNarrationAssetPolicy = .default(), gain: UnitInterval = .threeQuarters, fadeIn: PositiveDuration? = .oneTenth, fadeOut: PositiveDuration? = .oneTenth, transcriptID: NonEmptyText? = nil, leadIn: PositiveDuration = .oneQuarter, tail: PositiveDuration = .oneHalf) async throws -> ManimTTSNarrationCueResult`
`ManimTTSNarrationBuilder.voiceOver(text: String, sceneRelativeStart: Seconds, voice: Voice? = nil, assetPolicy: ManimTTSNarrationAssetPolicy = .default(), gain: UnitInterval = .threeQuarters, fadeIn: PositiveDuration? = .oneTenth, fadeOut: PositiveDuration? = .oneTenth, transcriptID: NonEmptyText? = nil, leadIn: PositiveDuration = .oneQuarter, tail: PositiveDuration = .oneHalf) async throws -> ManimTTSNarrationCueResult`
`ManimTTSNarrationCueResult.cue: NarrationCue`; `ManimTTSNarrationCueResult.audioAsset: AudioAsset`
`ManimTTSNarrationCueResult.cue.timing.start / .duration / .end`
`ValidationIssue.Code.lowContrastText`: text against the scene background or an overlapping filled shape is below 4.5:1 contrast; stroke-only shapes are outlines, not opaque backgrounds. Omit `attentionGrid(labelColor:)` for safe auto-foreground.
`ManimTTSNarrationBuilder.recommendedSceneDuration(covering cues: [NarrationCueProvider], tail: PositiveDuration = .oneHalf) -> PositiveDuration`
`TimelineDSL.cueLifecycleAnimations(_ lifecycleEntries: [CueLifecycleEntry], defaultCueTransition: CueExitTransition? = nil, avoiding authoredAnimations: [Animation] = []) -> [Animation]`
`scripts/check-render-richness.sh <mp4...>`: checks the default configurable video bitrate floor for low-reasoning retest MP4s.
Scratch checks: source-gated visual-only `.build/mai-sdk-scratch/<slug>.swift`
or `.build/mai-sdk-scratch/<slug>/main.swift` uses
`manim-agentic-interface feedback --source` or
`manim-agentic-interface render --source`; TTS runtime examples
use `.build/mai-sdk-scratch/<slug>/Sources/<Exec>/main.swift`, `swift run
--package-path`, in-memory `TimelineFeedbackReporter`, and the richness script.
Committed `examples/sdk/*.swift` require SwiftPM target registration and
`SDKExampleToolingTests`.
`PipelineRenderer.render(document: TimelineDocument, outputRoot: URL? = nil, configuration: PipelineRenderConfiguration = .init()) async -> PipelineRenderEnvelope`
`PipelineRenderer().render(document: TimelineDocument, outputRoot: URL? = nil, configuration: PipelineRenderConfiguration = .init()) async -> PipelineRenderEnvelope`
`PipelineRenderEnvelope.success?.artifactPath`: final rendered MP4 path to pass
to `scripts/check-render-richness.sh <mp4...>`.
`PipelineRenderFailure.actionableHint: String?`
`RendererSubprocessFailure.stderrTail: String`

## Textual feedback reports

`TimelineFeedbackReporter().report(for: TimelineDocument, intendedSequence: [String] = []) throws -> TimelineFeedbackReport`
`TimelineFeedbackReporter().report(sourceText: String, configuration: PipelineRenderConfiguration = .init(), intendedSequence: [String] = []) async throws -> TimelineFeedbackReport`
`TimelineFeedbackMarkdownRenderer().markdown(for: TimelineFeedbackReport) -> String`
CLI: `manim-agentic-interface feedback --source <scene.swift> --output .build/mai-feedback/<Scene>.feedback.md [--intended-sequence "Insert 1; Wait 0.5s; Fade in plus"] [--json]`
Report model: `layout.nodes`, `layout.findings`, `sequence.actions`, and `sequence.findings` carry node IDs, geometry, contrast/overlap/bounds/unknowns, ordered action trace, wait gaps, lifecycle/semantic-helper source, visibility, and optional intent alignment.

## Spatial storyboard layout

Docs: `docs/spatial-storyboard-layout.md` is the no-repo-crawl route guide.
CLI: `manim-agentic-interface feedback --source <scene.swift> --storyboard storyboard.md --output .build/mai-feedback/<Scene>.feedback.md [--json]`
CLI: `manim-agentic-interface matrix --source <scene.swift> --storyboard storyboard.md --output-root .build/mai-feedback/<Scene>-matrix [--json]`
Contract: each beat declares `Spatial grid: <columns>x<rows>`, a fenced ASCII grid, `Visible:`, `Absent:`, `Legend:`, `Motion:`, and `Constraints:`. Only whitespace and trailing `.` placeholder grid slips are sanitized before strict parsing; semantic omissions stay blocking.
Public model types: `StoryboardLayoutDocument`, `StoryboardBeat`, `StoryboardGrid`, `StoryboardLegendEntry`, `StoryboardSlot`, `StoryboardCompiledLayout`, `StoryboardLayoutReport`, `StoryboardFrameObservationDocument`.
Artifact paths: `storyboard-layout/storyboard-layout.json`, `storyboard-layout/storyboard-layout-report.json`, `storyboard-layout/storyboard-layout-report.md`, `storyboard-matrix/storyboard-matrix.png`, `storyboard-matrix/storyboard-matrix.json`, and optional `frame-observations.json`.
Issue codes: `storyboard.gridSanitized`, `storyboard.gridNonRectangular`, `storyboard.legendEntryMissing`, `storyboard.densityTooHigh`, `storyboard.staticGeometryMismatch`, `storyboard.frameObservationMismatch`, `storyboard.rendererObservationMissing`.
Responsibilities: `storyboarding`, `composition`, `timingLifecycle`, `technicalIntegration`, `renderFix`.

## Motion richness

`TimelineFeedbackReporter().estimateMotionRichness(for: TimelineDocument, recommendedMinScore: Double = MotionRichnessEstimate.defaultRecommendedMinScore) -> MotionRichnessEstimate`
`MotionRichnessEstimate`: `.score: UnitInterval`, `.animationsPerSecond: Double`, `.movingNodeCount: Int`, `.recommendedMinScore: Double`, `.actionableHint: String?`
`MotionRichnessEstimate.defaultRecommendedMinScore`: `0.4` (calibrated to the render-richness checker's default bit_rate floor)
`VLMFeedbackPacketManifest.motionRichness: MotionRichnessEstimate`

## Enums and cases

`SortingAnimation`: `.swap(NodeID, NodeID, aPosition: LayoutPosition, bPosition: LayoutPosition, duration: PositiveDuration = .oneHalf)`, `.compare(NodeID, NodeID, duration: PositiveDuration = .oneQuarter)`, `.markSorted(NodeID, duration: PositiveDuration = .oneQuarter)`
`AttentionAnimation`: `.weighted(from: NodeID, to: NodeID, weight: UnitInterval, duration: PositiveDuration = .oneQuarter)`, `.highlight(NodeID, duration: PositiveDuration = .oneQuarter)`, `.decayAll(edges: [NodeID], duration: PositiveDuration = .oneQuarter)`
`OptimizationAnimation`: `.gradientStep(NodeID, to: LayoutPosition, duration: PositiveDuration = .oneHalf)`, `.showGradient(at: NodeID, magnitude: Double, duration: PositiveDuration = .oneQuarter)`, `.settle(at: NodeID, duration: PositiveDuration = .oneHalf)`
`PipelineAnimation`: `.flowToken(tokenID: NodeID, through: [(stage: NodeID, at: LayoutPosition)], stepDuration: PositiveDuration = .oneHalf)`, `.highlightStage(NodeID, duration: PositiveDuration = .oneQuarter)`, `.showStageOutput(stage: NodeID, outputID: NodeID, duration: PositiveDuration = .oneHalf)`
`NodeOperation`: `.fadeIn(duration: PositiveDuration = .oneQuarter, easing: Easing = .linear)`, `.fadeOut(duration: PositiveDuration = .oneQuarter, easing: Easing = .linear)`, `.write(duration: PositiveDuration = .oneHalf, easing: Easing = .linear)`, `.move(to: LayoutPosition, duration: PositiveDuration = .oneHalf, easing: Easing = .linear)`, `.transform(scale: Double, duration: PositiveDuration = .oneQuarter, easing: Easing = .linear)`, `.emphasize(duration: PositiveDuration = .oneHalf, easing: Easing = .linear)`
`CueExitTransition`: `.fadeOut(duration: PositiveDuration = .oneQuarter)`, `.crossfade(duration: PositiveDuration = .oneHalf)`, `.slideOut(direction: SlideDirection, duration: PositiveDuration = .oneHalf)`, `.dissolve(duration: PositiveDuration = .oneHalf)`
`SlideDirection`: `.left`, `.right`, `.up`, `.down`

## Value types

`CanvasDistance`: non-negative canvas-unit measurement; `Sendable`, `Hashable`, `Comparable`, `Codable`, `ExpressibleByFloatLiteral`, `ExpressibleByIntegerLiteral`, `AdditiveArithmetic`
`CanvasDistance.zero: CanvasDistance`
`CanvasDistance + CanvasDistance -> CanvasDistance`; subtraction clamps negative intermediates to `.zero` (emits `canvasDistanceClamped` validator code at construction sites)
`Composite` protocol: `.id: NodeID`, `.nodes: [VisualNode]`, `.bounds: CompositeBoundingBox` — conformed by all composite types
`LayoutPosition` anchor shorthands: `.leading`, `.center`, `.trailing`, `.top`, `.bottom`

## HexColor auto-contrast

`HexColor.autoContrast(against fill: HexColor) -> HexColor`
`HexColor.white: HexColor` (`"#F8FAFC"` near-white label for dark fills)
`HexColor.black: HexColor` (`"#111827"` near-black label for light fills)
Auto-contrast: composite factories that previously hardcoded label colors now call `HexColor.autoContrast(against:)` for safer defaults; author may still pass explicit label colors to override.

## Value wrappers and conformances

`Seconds`: `Codable`, `Hashable`, `Sendable`, `Comparable`, `AdditiveArithmetic`, `ExpressibleByFloatLiteral`, `ExpressibleByIntegerLiteral`
`PositiveDuration`: `Codable`, `Hashable`, `Sendable`, `Comparable`, `AdditiveArithmetic`, `ExpressibleByFloatLiteral`, `ExpressibleByIntegerLiteral`
`UnitInterval`: `Codable`, `Hashable`, `Sendable`, `Comparable`, `ExpressibleByFloatLiteral`, `ExpressibleByIntegerLiteral`
`HexColor`: `Codable`, `Hashable`, `Sendable`, `ExpressibleByStringInterpolation`
`SceneID`: `Codable`, `Hashable`, `Sendable`, `ExpressibleByStringInterpolation`
`NodeID`: `Codable`, `Hashable`, `Sendable`, `ExpressibleByStringInterpolation`
`AssetID`: `Codable`, `Hashable`, `Sendable`, `ExpressibleByStringInterpolation`
`NonEmptyText`: `Codable`, `Hashable`, `Sendable`, `ExpressibleByStringInterpolation`
`MathText`: `Codable`, `Hashable`, `Sendable`, `ExpressibleByStringInterpolation`
`AudioAssetID`: `Codable`, `Hashable`, `Sendable`, `ExpressibleByStringInterpolation`
`RelativeAssetPath`: `Codable`, `Hashable`, `Sendable`, `ExpressibleByStringInterpolation`
`DrawOrder`: `Codable`, `Hashable`, `Sendable`, `Comparable`, `ExpressibleByIntegerLiteral`
`FiniteDouble`: `Codable`, `Hashable`, `Sendable`, `Comparable`, `ExpressibleByFloatLiteral`, `ExpressibleByIntegerLiteral`
`PositiveLength`: `Codable`, `Hashable`, `Sendable`, `Comparable`, `ExpressibleByFloatLiteral`, `ExpressibleByIntegerLiteral`
`MathScalar`: `Codable`, `Hashable`, `Sendable`, `ExpressibleByFloatLiteral`, `ExpressibleByIntegerLiteral`

## Value wrapper arithmetic

`Seconds + Seconds -> Seconds`; `Seconds - Seconds -> Seconds`; `Seconds + PositiveDuration -> Seconds`; `Seconds - PositiveDuration -> Seconds`; `Seconds * Double -> Seconds`; `Seconds / Double -> Seconds`; `Seconds / Seconds -> Double`
`Seconds.min(_:_:) -> Seconds`; `Seconds.max(_:_:) -> Seconds`; `Seconds.clamped(to: ClosedRange<Seconds>) -> Seconds`; `Seconds.interpolated(to: Seconds, at: UnitInterval) -> Seconds`
`PositiveDuration + PositiveDuration -> PositiveDuration`; `PositiveDuration - PositiveDuration -> PositiveDuration`; `PositiveDuration + Double -> PositiveDuration`; `PositiveDuration * Double -> PositiveDuration`; `PositiveDuration / Double -> PositiveDuration`; `PositiveDuration / PositiveDuration -> Double`
`PositiveDuration.min(_:_:) -> PositiveDuration`; `PositiveDuration.max(_:_:) -> PositiveDuration`; `PositiveDuration.clamped(to: ClosedRange<PositiveDuration>) -> PositiveDuration`
`UnitInterval.progress(of: Seconds, from: Seconds, to: Seconds) -> UnitInterval`; `UnitInterval * UnitInterval -> UnitInterval`; `UnitInterval * Double -> Double`
