# scenes/

This directory holds HTML/SVG scene payloads that any mid-tier reasoning
model (Flash-class, open-source, or otherwise) can author and feed into
the MAI render-storyboard pipeline.

## Format

Each scene is a single self-contained HTML file. The accepted shape:

- One outer absolutely-positioned `<div>` (`position:absolute;inset:0`)
  that sets the background, base color, and `font-family`.
- Inline `style="..."` attributes only — no external stylesheets, no
  `<style>` blocks, no JavaScript.
- Inline `<svg viewBox="...">` for geometric primitives (rects,
  circles, lines, polygons, text). Use `text-anchor`, `fill`, `stroke`,
  and `font-family` directly on SVG elements.
- Title row, illustration region, and caption / narration row are the
  conventional layout — see `hello-storyboard.html` for the worked
  example.

## How to run

From the playground root:

```bash
swift run manim-agentic-interface render-storyboard scenes/hello-storyboard.html
```

This:

1. Parses the HTML/SVG into typed Swift nodes.
2. Opens the Scene Editor canvas for user manipulation.
3. On save, returns control to the chain so downstream Manim render can
   continue.

## Authoring contract

The model's contract for authoring scenes lives in the bundled consumer
skill at:

- `.claude/skills/spatial-storyboard-layout-consumer/SKILL.md`
- `.codex/skills/spatial-storyboard-layout-consumer/SKILL.md`
- `.gemini/skills/spatial-storyboard-layout-consumer/SKILL.md`

Load that skill into your model session before authoring; it covers
spatial grid conventions, the `--storyboard` CLI flag, matrix
artifacts, and frame-observation reporting.

## Not the Swift route

This playground also ships a Swift TimelineDSL entry point
(`swift run minimal-scene`). That route is for Swift-authoring; the
HTML/SVG route in this directory is what mid-tier models drive. The
two coexist; pick whichever fits the work.
