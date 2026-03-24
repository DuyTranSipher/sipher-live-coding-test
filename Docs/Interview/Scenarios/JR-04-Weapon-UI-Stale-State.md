# JR-04: Weapon HUD Stays Stale After Unequip

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-04` |
| Branch | `interview/jr-04-weapon-ui-stale-state` |
| Duration | `60 minutes` |
| Type | `bug fix` |
| Systems | `UI/Weapons`, `Equipment`, widget Blueprint integration |
| Main proof | weapon HUD clears or refreshes correctly when no weapon is equipped |
| Quick check | `OnWeaponChanged` is triggered for both equip and unequip transitions, including the `NewWeapon == nullptr` path |

## Candidate Brief

### Symptom

The weapon HUD updates when a weapon is equipped, but after switching into a state with no weapon the old HUD state still lingers. Recent cleanup work partially clears internal state, but the real widget update path still does not run on weapon removal.

### Goal

Make the weapon UI respond correctly to both weapon acquisition and weapon removal without rewriting the HUD system or masking the issue purely in Blueprint.

### Constraints

- keep the change small and local to the weapon UI path
- do not pollute unrelated equipment code
- be ready to show the before/after transition in PIE

## Interviewer Setup

### Seed

Partially handle the no-weapon case in [Source/LyraGame/UI/Weapons/LyraWeaponUserInterface.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/UI/Weapons/LyraWeaponUserInterface.cpp) by clearing the cached instance without rebuilding or firing the existing `OnWeaponChanged` event path.

### Expected Fix Shape

- Handle the transition from a valid `CurrentInstance` back to `nullptr`.
- Rebuild or clear the widget state through the existing `OnWeaponChanged` event path.
- Avoid adding broad per-frame UI rebuild work or a second, parallel null-clear path.

### Likely Search Surface

- [Source/LyraGame/UI/Weapons/LyraWeaponUserInterface.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/UI/Weapons/LyraWeaponUserInterface.cpp)
- [Source/LyraGame/UI/Weapons/LyraWeaponUserInterface.h](/D:/Projects/sipher_test_project/Source/LyraGame/UI/Weapons/LyraWeaponUserInterface.h)
- the Blueprint implementing `OnWeaponChanged`

### Red Herrings To Ignore

- reticle spread math
- hit marker drawing
- quick-bar slot replication

## Verification

### Manual Proof

Show the HUD with a weapon equipped, then transition to a no-weapon state and confirm the stale HUD no longer remains visible.

### Quick Check

Demonstrate that `OnWeaponChanged` runs for both equip and unequip transitions, including the `OldWeapon != nullptr` to `NewWeapon == nullptr` case.

## Hint Ladder

- Hint 1: inspect the `NativeTick` transition logic closely, especially the null branch
- Hint 2: the cache may be cleared already, but the event/rebuild path is still incomplete

## Scoring Notes

- Strong signal: candidate fixes the state transition instead of masking it in Blueprint only
- Partial credit: candidate clears the HUD but introduces unnecessary per-tick rebuilds
- Miss: candidate edits unrelated weapon classes without proving the UI update path is at fault
