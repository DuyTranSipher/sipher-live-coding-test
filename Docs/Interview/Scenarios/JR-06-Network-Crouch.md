# JR-06: Network Crouch Regression

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-06` |
| Branch | `interview/jr-06-network-crouch` |
| Duration | `60 minutes` |
| Type | `gameplay bug fix` |
| Systems | `Character`, `Input`, `Replication`, `ShooterTests` |
| Main proof | crouch works correctly in 2-player PIE for local and remote views |
| Quick check | `InputAnimationTest::NetworkPlayers_Crouch` passes again |

## Candidate Brief

### Symptom

Single-player crouch still looks fine, but in a networked session the crouch behavior is no longer correct for at least one side of the connection.

### Goal

Restore correct crouch behavior across a 2-player PIE session without breaking the local experience.

### Constraints

- reproduce in a networked context, not only standalone
- prefer a narrow gameplay fix over broad movement rewrites
- use the existing ShooterTests coverage if it helps you validate

## Interviewer Setup

### Seed

- Introduce a local-only guard or equivalent regression in [Source/LyraGame/Character/LyraCharacter.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/Character/LyraCharacter.cpp), for example around `ToggleCrouch`, so network parity breaks while local crouch still appears plausible.
- Keep [Plugins/GameFeatures/ShooterTests/Source/ShooterTestsRuntime/Private/ShooterTestsActorNetworkTests.cpp](/D:/Projects/sipher_test_project/Plugins/GameFeatures/ShooterTests/Source/ShooterTestsRuntime/Private/ShooterTestsActorNetworkTests.cpp) unchanged so it can act as the verification target.

### Expected Fix Shape

- Reproduce the issue in 2-player PIE or through the existing network automation coverage.
- Restore the intended crouch path in the character/input flow.
- Verify that the fix does not depend on a listen-server-only special case.

### Likely Search Surface

- [Source/LyraGame/Character/LyraCharacter.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/Character/LyraCharacter.cpp)
- [Source/LyraGame/Character/LyraHeroComponent.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/Character/LyraHeroComponent.cpp)
- [Plugins/GameFeatures/ShooterTests/Source/ShooterTestsRuntime/Private/ShooterTestsActorNetworkTests.cpp](/D:/Projects/sipher_test_project/Plugins/GameFeatures/ShooterTests/Source/ShooterTestsRuntime/Private/ShooterTestsActorNetworkTests.cpp)

### Red Herrings To Ignore

- camera crouch offset tuning
- unrelated acceleration replication
- frontend or inventory systems

## Verification

### Manual Proof

Run a 2-player PIE session and show crouch behavior from both the local and remote perspectives.

### Quick Check

Run or at least target the `NetworkPlayers_Crouch` path in `InputAnimationTest` and confirm it now passes.

## Hint Ladder

- Hint 1: do not trust standalone play as sufficient proof
- Hint 2: compare where crouch input is bound with where the character actually toggles crouch

## Scoring Notes

- Strong signal: candidate chooses a network repro path early and uses the existing test suite intelligently
- Partial credit: candidate finds the right gameplay function but does not fully validate both perspectives
- Miss: candidate spends the session adjusting animation assets or camera offsets instead of fixing crouch state flow
