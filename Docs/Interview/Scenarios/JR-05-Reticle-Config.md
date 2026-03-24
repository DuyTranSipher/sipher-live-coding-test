# JR-05: Reticle Config Broken For One Weapon

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-05` |
| Branch | `interview/jr-05-reticle-config` |
| Duration | `60 minutes` |
| Type | `editor/data fix` |
| Systems | `Weapons`, `InventoryFragment_ReticleConfig`, item definition assets |
| Main proof | the affected weapon shows its full reticle again |
| Quick check | the affected weapon restores all required reticle assets or widget references, not just one partial layer |

## Candidate Brief

### Symptom

Only one weapon has lost its reticle presentation after a recent HUD asset cleanup. Other weapons still show their reticles correctly, but the affected weapon is now missing more than one reticle layer.

### Goal

Restore the missing reticle for the affected weapon with the smallest safe fix. The candidate should restore the full per-weapon reticle setup rather than patching only one visible layer.

### Constraints

- treat this as a per-weapon data/config problem first
- avoid rewriting reticle rendering code unless the data path is confirmed healthy
- be ready to show the affected asset and in-game result

## Interviewer Setup

### Seed

- Break the affected weapon's reticle presentation by removing or renaming multiple shotgun reticle assets so existing references resolve to missing content.
- Leave [Source/LyraGame/Weapons/InventoryFragment_ReticleConfig.h](/D:/Projects/sipher_test_project/Source/LyraGame/Weapons/InventoryFragment_ReticleConfig.h) unchanged in the prepared branch.

### Expected Fix Shape

- Find the affected weapon's reticle reference chain.
- Restore all missing reticle pieces required for that weapon's expected HUD presentation.
- Confirm other weapons remain unchanged.

### Likely Search Surface

- [Source/LyraGame/Weapons/InventoryFragment_ReticleConfig.h](/D:/Projects/sipher_test_project/Source/LyraGame/Weapons/InventoryFragment_ReticleConfig.h)
- [Source/LyraGame/UI/Weapons/LyraReticleWidgetBase.h](/D:/Projects/sipher_test_project/Source/LyraGame/UI/Weapons/LyraReticleWidgetBase.h)
- shotgun reticle assets under [Content/UI/Hud/Art](/D:/Projects/sipher_test_project/Content/UI/Hud/Art)

### Red Herrings To Ignore

- quick-bar activation logic
- weapon hit confirmation widgets
- frontend UI classes

## Verification

### Manual Proof

Equip the affected weapon and show that its reticle appears again while unaffected weapons still behave normally.

### Quick Check

Inspect the affected weapon's reticle assets or references and show that all required shotgun reticle pieces are valid again.

## Hint Ladder

- Hint 1: compare the broken weapon's HUD asset chain with a working weapon before rewriting code
- Hint 2: the issue may involve more than one missing reticle asset, not just a single widget class

## Scoring Notes

- Strong signal: candidate isolates the broken weapon-specific asset chain quickly and validates the full reticle in-game
- Partial credit: candidate restores one missing layer but leaves the weapon partially broken
- Miss: candidate rewrites reticle rendering code for what is really an asset/configuration issue
