# JR-01: Weapon Hit Confirmation Regression

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-01` |
| Branch | `interview/jr-01-weapon-hit-confirmation` |
| Duration | `60 minutes` |
| Type | `bug fix` |
| Systems | `Weapons`, `UI/Weapons`, `Teams` |
| Main proof | enemy hits show confirmation, wall hits do not |
| Quick check | inspect or log `ShouldShowHitAsSuccess` decisions for enemy vs non-enemy hits |

## Candidate Brief

### Symptom

Recent combat changes broke hit confirmation feedback. Players can still fire normally, but the on-screen hit confirmation no longer behaves correctly for valid enemy hits.

### Goal

Restore correct hit confirmation behavior without rewriting the ranged weapon flow. Valid hostile hits should produce confirmation feedback; misses and invalid targets should not.

### Constraints

- prefer a minimal fix in the existing weapon/UI path
- keep team logic intact
- be ready to show a short before/after repro in PIE

## Interviewer Setup

### Seed

- Change `ULyraWeaponStateComponent::ShouldShowHitAsSuccess` in [Source/LyraGame/Weapons/LyraWeaponStateComponent.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/Weapons/LyraWeaponStateComponent.cpp) so it returns the wrong result for valid enemy hits.
- Keep the seed to one logic change only. Do not also break the widget brush or Slate drawing path in the default version.

### Expected Fix Shape

- Trace hit confirmation from `ULyraWeaponStateComponent` into the hit marker widget path.
- Restore the correct success predicate using the existing team subsystem behavior.
- Leave `SHitMarkerConfirmationWidget` drawing logic alone unless the candidate proves it is involved.

### Likely Search Surface

- [Source/LyraGame/Weapons/LyraWeaponStateComponent.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/Weapons/LyraWeaponStateComponent.cpp)
- [Source/LyraGame/UI/Weapons/SHitMarkerConfirmationWidget.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/UI/Weapons/SHitMarkerConfirmationWidget.cpp)
- [Source/LyraGame/UI/Weapons/HitMarkerConfirmationWidget.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/UI/Weapons/HitMarkerConfirmationWidget.cpp)

### Red Herrings To Ignore

- reticle spread rendering
- weapon fire prediction internals
- unrelated HUD layout assets

## Verification

### Manual Proof

Open a combat map in PIE, fire at a valid enemy target, then fire at world geometry. Show that only the valid enemy hit produces confirmation feedback.

### Quick Check

Set a breakpoint or temporary log in `ShouldShowHitAsSuccess` and show that the method evaluates `true` for the hostile target and `false` for an invalid target.

## Hint Ladder

- Hint 1: start from the code that stores recent hit marker screen positions, not from the Slate paint function
- Hint 2: check the team-based success decision before chasing widget code

## Scoring Notes

- Strong signal: candidate reproduces quickly and narrows to `LyraWeaponStateComponent`
- Partial credit: candidate finds the correct method and explains the intended logic even if proof is incomplete
- Miss: candidate rewrites widget rendering or weapon ability code without establishing the root cause
