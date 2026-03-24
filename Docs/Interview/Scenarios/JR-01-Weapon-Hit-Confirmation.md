# JR-01: Weapon Hit Confirmation Regression

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-01` |
| Branch | `interview/jr-01-weapon-hit-confirmation` |
| Duration | `60 minutes` |
| Type | `bug fix` |
| Systems | `Weapons`, `UI/Weapons`, `server-side confirmation` |
| Main proof | confirmed enemy hits show feedback consistently after server validation, while invalid hits do not |
| Quick check | inspect or log how confirmed hit markers survive `ClientConfirmTargetData` reconciliation |

## Candidate Brief

### Symptom

Recent combat changes broke hit confirmation feedback after server-side validation was adjusted. Players can still fire normally, but valid hostile hits now lose or mis-handle confirmation during the reconciliation step.

### Goal

Restore correct hit confirmation behavior without rewriting the ranged weapon flow. Valid hostile hits should survive confirmation/reconciliation; misses and invalid targets should not.

### Constraints

- prefer a minimal fix in the existing weapon/UI confirmation path
- keep both team logic and server-validation behavior intact
- be ready to show a short before/after repro in PIE

## Interviewer Setup

### Seed

- Break the confirmed-hit reconciliation in [Source/LyraGame/Weapons/LyraWeaponStateComponent.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/Weapons/LyraWeaponStateComponent.cpp) so valid hostile markers are filtered incorrectly after server response.
- Do not also break `ShouldShowHitAsSuccess` or the widget paint path in the prepared branch.

### Expected Fix Shape

- Trace hit confirmation from marker creation through the confirmed-hit reconciliation path.
- Restore the correct filter for which client-side markers remain after server validation.
- Leave widget drawing and team-comparison code alone unless the candidate proves they are involved.

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

Set a breakpoint or temporary log in `ClientConfirmTargetData` and show that only the intended confirmed markers survive reconciliation.

## Hint Ladder

- Hint 1: start from the code that stores and later confirms recent hit marker screen positions
- Hint 2: the bug is in how confirmed markers are filtered after the server response, not in Slate painting

## Scoring Notes

- Strong signal: candidate reproduces quickly and narrows to `LyraWeaponStateComponent` without getting trapped in widget code
- Partial credit: candidate finds the correct method and explains the intended logic even if proof is incomplete
- Miss: candidate rewrites widget rendering or weapon ability code without establishing the root cause
