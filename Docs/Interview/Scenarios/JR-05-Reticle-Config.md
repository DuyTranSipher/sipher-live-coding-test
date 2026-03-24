# JR-05: Reticle Config Broken For One Weapon

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-05` |
| Branch | `interview/jr-05-reticle-config` |
| Duration | `60 minutes` |
| Type | `editor/data fix` |
| Systems | `Weapons`, `InventoryFragment_ReticleConfig`, item definition assets |
| Main proof | affected weapon shows the expected reticle again |
| Quick check | active item definition contains a valid `ReticleWidgets` entry |

## Candidate Brief

### Symptom

Only one weapon has lost its reticle after a recent data update. Other weapons still show their reticles correctly.

### Goal

Restore the missing reticle for the affected weapon with the smallest safe fix.

### Constraints

- treat this as a per-weapon data/config problem first
- avoid rewriting reticle rendering code unless the data path is confirmed healthy
- be ready to show the affected asset and in-game result

## Interviewer Setup

### Seed

- In the chosen weapon's item definition, clear or replace the `ReticleWidgets` entry from its `UInventoryFragment_ReticleConfig`.
- Leave [Source/LyraGame/Weapons/InventoryFragment_ReticleConfig.h](/D:/Projects/sipher_test_project/Source/LyraGame/Weapons/InventoryFragment_ReticleConfig.h) unchanged in the default branch.

### Expected Fix Shape

- Find the affected weapon item definition.
- Restore a valid reticle widget class in the fragment config.
- Confirm other weapons remain unchanged.

### Likely Search Surface

- [Source/LyraGame/Weapons/InventoryFragment_ReticleConfig.h](/D:/Projects/sipher_test_project/Source/LyraGame/Weapons/InventoryFragment_ReticleConfig.h)
- [Source/LyraGame/UI/Weapons/LyraReticleWidgetBase.h](/D:/Projects/sipher_test_project/Source/LyraGame/UI/Weapons/LyraReticleWidgetBase.h)
- weapon item definition assets in `Content/`

### Red Herrings To Ignore

- quick-bar activation logic
- weapon hit confirmation widgets
- frontend UI classes

## Verification

### Manual Proof

Equip the affected weapon and show that its reticle appears again while unaffected weapons still behave normally.

### Quick Check

Inspect the item definition asset and show a valid `ReticleWidgets` entry in the `InventoryFragment_ReticleConfig`.

## Hint Ladder

- Hint 1: compare the broken weapon's definition with a working one
- Hint 2: search for the fragment type that stores reticle widget classes

## Scoring Notes

- Strong signal: candidate isolates the broken data asset quickly and validates the fix in-game
- Partial credit: candidate finds the correct fragment but does not finish validation
- Miss: candidate rewrites reticle rendering code for what is really an asset configuration issue
