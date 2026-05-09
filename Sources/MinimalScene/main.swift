import Darwin
import Foundation
import ManimAgenticInterface
import ManimAgenticInterfaceTTS

@main
struct MinimalScene {
    static func main() async throws {
        let outputRoot = URL(fileURLWithPath: ".build/manim-renders/minimal-scene", isDirectory: true)
        let title = TimelineDSL.textNode(
            id: NodeID("title"),
            text: NonEmptyText("MAI v0.2 setup proof"),
            role: .title,
            position: TimelineDSL.absolute(horizontal: 0, vertical: 0.6),
            style: TimelineDSL.style(fill: HexColor("#FFFFFF"), opacity: UnitInterval(1))
        )
        let builder = ManimTTSNarrationBuilder()
        let narration = try await builder.synthAndCue(
            text: "This is the first pre-release MAI v0.2 playground render proof.",
            sceneRelativeStart: 0.1
        )
        let scene = TimelineDSL.scene(
            id: SceneID("minimal-tts-proof"),
            title: NonEmptyText("Minimal TTS Proof"),
            duration: try PositiveDuration(max(1.5, narration.cue.timing.end + 0.4)),
            camera: TimelineDSL.fullSceneCamera(),
            elements: [
                TimelineDSL.create(title),
                TimelineDSL.fadeIn(target: title.id, duration: PositiveDuration(0.4)),
                TimelineDSL.narrationCue(narration.cue),
            ]
        )
        let document = TimelineDSL.document(
            rendererSettings: TimelineDSL.rendererSettings(
                canvas: TimelineDSL.canvas(width: 1280, height: 720),
                backgroundColor: HexColor("#101820"),
                framesPerSecond: 24,
                quality: .draft,
                enabledCapabilities: [.staticTimeline, .text, .narrationMetadata, .audioMuxing],
                allowedOpcodes: [.createText, .animateFade, .attachNarrationCue, .attachAudioCue]
            ),
            audioAssets: [narration.audioAsset],
            scenes: [scene]
        )
        let envelope = await PipelineRenderer().render(document: document, outputRoot: outputRoot)
        if let success = envelope.success {
            print("Rendered pre-release MAI v0.2 playground proof: \(success.artifactPath)")
        } else {
            let failure = envelope.failure
            fputs("Render failed: \(failure?.stableCode ?? "unknown") \(failure?.message ?? "")\n", stderr)
            if let detail = failure?.detail {
                fputs("\(detail)\n", stderr)
            }
            Darwin.exit(Int32(envelope.exitCode.rawValue))
        }
    }
}
