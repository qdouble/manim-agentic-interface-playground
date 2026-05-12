import Foundation
import Testing

@Test func setupScriptDelegatesCanonicalVenvSetupToMAICLI() throws {
    let script = try setupScriptText()

    #expect(script.contains("swift run --quiet manim-agentic-interface setup --venv"))
    #expect(!script.contains("python3.14"))
    #expect(!script.contains("-m venv"))
    #expect(!script.contains(".setup.lock"))
    #expect(!script.contains("pip install"))
    #expect(!script.contains("pinned-manim-version"))
}

@Test func setupScriptWiresTTSInstallAndProviderSkillPointers() throws {
    let script = try setupScriptText()

    #expect(script.contains(#""$HOME/Library/Application Support/text-to-speech-interface/models""#))
    #expect(script.contains(#""../text-to-speech-interface""#))
    #expect(script.contains(#""$HOME/Developer/Swift-Apps/text-to-speech-interface""#))
    #expect(script.contains(#""$HOME/text-to-speech-interface""#))
    #expect(script.contains("swift run --quiet tts-interface install kokoro"))
    #expect(script.contains("swift run --quiet manim-agentic-interface dump-skills --dest .claude/skills --provider claude"))
    #expect(script.contains("swift run --quiet manim-agentic-interface dump-skills --dest .codex/skills --provider codex"))
    #expect(script.contains("swift run --quiet manim-agentic-interface dump-skills --dest .gemini/skills --provider gemini"))
    #expect(script.contains("for provider_dir in .claude/skills .codex/skills .gemini/skills"))
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
