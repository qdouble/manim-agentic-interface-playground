# MAI Branch Pin

This playground was seeded by `scripts/seed-cycle-playground.sh`.

MAI dependency branch: `codex/spatial-storyboard-layout`

The seed script pins `Package.swift` before setup and build proof. Do not
hand-edit the MAI dependency during the specialist workflow unless the user asks
for a different branch.

To re-prove the branch pin from this playground, run:

```bash
swift package reset
swift package resolve
swift build
swift test
```

After `swift package resolve`, `Package.resolved` should list the MAI pin on
branch `codex/spatial-storyboard-layout`.
