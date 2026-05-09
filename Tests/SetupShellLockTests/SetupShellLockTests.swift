import Foundation
import Testing

@Test func setupScriptCreatesVenvParentBeforeAcquiringLock() throws {
    let script = try setupScriptText()

    let parentIndex = try #require(script.range(of: #"mkdir -p "$(dirname "$CANONICAL_VENV")""#))
    let lockIndex = try #require(script.range(of: #"until mkdir "$LOCK_DIR" 2>/dev/null; do"#))

    #expect(parentIndex.lowerBound < lockIndex.lowerBound)
}

@Test func setupScriptUsesMkdirMutexWithTimeoutAndTrapCleanup() throws {
    let script = try setupScriptText()

    #expect(script.contains(#"LOCK_DIR="$(dirname "$CANONICAL_VENV")/.setup.lock""#))
    #expect(script.contains(#"LOCK_WAIT=0"#))
    #expect(script.contains(#"if [[ "$LOCK_WAIT" -ge 60 ]]; then"#))
    #expect(script.contains(#"another setup.sh is holding the venv lock"#))
    #expect(script.contains(#"trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT"#))
}

@Test func setupScriptFiltersPinnedManimStdoutToSemver() throws {
    let script = try setupScriptText()

    #expect(script.contains(
        "swift run --quiet --skip-build manim-agentic-interface pinned-manim-version"
    ))
    #expect(script.contains("swift run --quiet manim-agentic-interface pinned-manim-version"))
    #expect(script.contains(#"grep -oE '[0-9]+\.[0-9]+\.[0-9]+'"#))
    #expect(script.contains("tail -1"))
    #expect(script.contains("failed to read the pinned manim version"))
}

@Test func setupScriptWiresTTSInstallAndSkillPointer() throws {
    let script = try setupScriptText()

    #expect(script.contains(#""$HOME/Library/Application Support/text-to-speech-interface/models""#))
    #expect(script.contains(#""../text-to-speech-interface""#))
    #expect(script.contains(#""$HOME/Developer/Swift-Apps/text-to-speech-interface""#))
    #expect(script.contains(#""$HOME/text-to-speech-interface""#))
    #expect(script.contains("swift run --quiet tts-interface install kokoro"))
    #expect(script.contains("swift run --quiet manim-agentic-interface dump-skills --dest .claude/skills --provider claude"))
    #expect(script.contains("swift run --quiet manim-agentic-interface dump-skills --dest .codex/skills --provider codex"))
    #expect(script.contains("text-to-speech-interface-consumer/SKILL.md"))
    #expect(script.contains("Text-to-Speech Interface Consumer (playground pointer)"))
}

private func setupScriptText() throws -> String {
    try String(contentsOf: packageRoot().appendingPathComponent("setup.sh"), encoding: .utf8)
}

private func packageRoot() -> URL {
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
}
