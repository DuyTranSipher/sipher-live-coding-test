# JR-08: ShooterTests Melee Case Drifted From Data

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-08` |
| Branch | `interview/jr-08-melee-test-drift` |
| Duration | `60 minutes` |
| Type | `test repair` |
| Systems | `ShooterTests`, weapon pickup data, editor validation |
| Main proof | the broken melee case passes again, ideally without weakening the test |
| Quick check | the affected `WeaponMelee_*` case resolves the correct weapon data and equipped instance |

## Candidate Brief

### Symptom

One of the existing melee automation cases has started failing after a weapon data/content update, while the other melee cases still pass.

### Goal

Repair the broken case so the test once again verifies the intended behavior. Do not remove assertions or skip the failing case.

### Constraints

- keep the test meaningful
- update the data lookup or expectation only if you can explain why it changed
- be ready to show the repaired case and the affected asset or constant

## Interviewer Setup

### Seed

- Drift one melee case, preferably `WeaponMelee_Shotgun`, by changing the referenced pickup data asset name or expected equipped instance name used in [Plugins/GameFeatures/ShooterTests/Source/ShooterTestsRuntime/Private/ShooterTestsActorAnimationTests.cpp](/D:/Projects/sipher_test_project/Plugins/GameFeatures/ShooterTests/Source/ShooterTestsRuntime/Private/ShooterTestsActorAnimationTests.cpp).
- Keep pistol and rifle cases passing so the failure surface stays narrow.

### Expected Fix Shape

- Reproduce or inspect the failing melee case.
- Restore the correct test data reference or lookup expectation.
- Keep the assertions intact and avoid loosening the test into a false positive.

### Likely Search Surface

- [Plugins/GameFeatures/ShooterTests/Source/ShooterTestsRuntime/Private/ShooterTestsActorAnimationTests.cpp](/D:/Projects/sipher_test_project/Plugins/GameFeatures/ShooterTests/Source/ShooterTestsRuntime/Private/ShooterTestsActorAnimationTests.cpp)
- relevant weapon pickup data assets in `Content/` or plugin content

### Red Herrings To Ignore

- unrelated crouch tests
- broad weapon animation rewrites
- disabling the failing test

## Verification

### Manual Proof

If time allows, equip the affected weapon in-editor and confirm the melee action still behaves as expected.

### Quick Check

Run or target the broken `WeaponMelee_*` case and show it now passes with the correct asset/instance mapping.

## Hint Ladder

- Hint 1: compare the broken melee case against the two passing cases
- Hint 2: the failure is in test data alignment, not in animation playback logic itself

## Scoring Notes

- Strong signal: candidate keeps the test strict and fixes the actual drift
- Partial credit: candidate finds the stale reference but does not complete the pass/fail proof
- Miss: candidate comments out assertions, disables the test, or changes unrelated animation code
