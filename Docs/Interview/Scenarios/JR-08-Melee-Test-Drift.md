# JR-08: ShooterTests Melee Case Drifted From Data

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-08` |
| Branch | `interview/jr-08-melee-test-drift` |
| Duration | `60 minutes` |
| Type | `test repair` |
| Systems | `ShooterTests`, weapon pickup data, editor validation |
| Main proof | the broken melee case passes again, ideally without weakening the test or hiding the helper-level drift |
| Quick check | the affected `WeaponMelee_*` case resolves the correct weapon data and expected equipped instance through the shared helper |

## Candidate Brief

### Symptom

One of the existing melee automation cases has started failing after a weapon data/content update, while the other melee cases still pass. The failure now comes from the shared equip helper drifting for only one weapon, not from a single obvious stale line in the test body.

### Goal

Repair the broken case so the test once again verifies the intended behavior. Do not remove assertions, skip the failing case, or work around the helper-level drift with a one-off hack in the test body.

### Constraints

- keep the test meaningful
- update the data lookup or expectation only if you can explain why it changed
- be ready to show the repaired case and the affected asset or constant

## Interviewer Setup

### Seed

- Drift one melee case, preferably `WeaponMelee_Shotgun`, by changing the shared helper in [Plugins/GameFeatures/ShooterTests/Source/ShooterTestsRuntime/Private/ShooterTestsActorAnimationTests.cpp](/D:/Projects/sipher_test_project/Plugins/GameFeatures/ShooterTests/Source/ShooterTestsRuntime/Private/ShooterTestsActorAnimationTests.cpp) so it resolves the wrong expected equipped instance name for only that weapon.
- Keep pistol and rifle cases passing so the failure surface stays narrow.

### Expected Fix Shape

- Reproduce or inspect the failing melee case.
- Restore the correct helper-level data/reference expectation for the affected weapon.
- Keep the assertions intact and avoid loosening the test into a false positive.

### Likely Search Surface

- [Plugins/GameFeatures/ShooterTests/Source/ShooterTestsRuntime/Private/ShooterTestsActorAnimationTests.cpp](/D:/Projects/sipher_test_project/Plugins/GameFeatures/ShooterTests/Source/ShooterTestsRuntime/Private/ShooterTestsActorAnimationTests.cpp)
- [ShooterTestsActorTest.h](/D:/Projects/sipher_test_project/Plugins/GameFeatures/ShooterTests/Source/ShooterTestsRuntime/Private/Utilities/ShooterTestsActorTest.h)
- relevant weapon pickup data assets in `Content/` or plugin content

### Red Herrings To Ignore

- unrelated crouch tests
- broad weapon animation rewrites
- disabling the failing test

## Verification

### Manual Proof

If time allows, equip the affected weapon in-editor and confirm the melee action still behaves as expected.

### Quick Check

Run or target the broken `WeaponMelee_*` case and show it now passes with the correct helper-level asset/instance mapping.

## Hint Ladder

- Hint 1: compare the broken melee case against the two passing cases, then inspect the shared helper they all use
- Hint 2: the failure is in helper-level data alignment, not in animation playback logic itself

## Scoring Notes

- Strong signal: candidate keeps the test strict and fixes the actual helper-level drift
- Partial credit: candidate finds the stale reference but patches only the single test body or does not complete the pass/fail proof
- Miss: candidate comments out assertions, disables the test, or changes unrelated animation code
