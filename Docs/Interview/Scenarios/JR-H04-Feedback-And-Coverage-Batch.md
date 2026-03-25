# JR-H04: Feedback And Coverage Contracts

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-H04` |
| Branch | `interview/jr-h04-feedback-and-coverage` |
| Duration | `60 minutes` |
| Type | `contract-and-coverage scenario` |
| Systems | `Quick bar`, `HUD lifecycle`, `Gameplay messages`, `ShooterTests`, `Weapon expectations` |
| Main proof | HUD shows the active slot correctly across lifecycle transitions and the broken melee test passes without weakening coverage |
| Quick check | the HUD initializes from current quick-bar state and the test fix restores shared helper semantics instead of patching one failing case |

## Candidate Brief

### Symptom

Player feedback and automated coverage have drifted apart. The HUD still does not expose the real active quick-bar slot across startup and state changes, and one melee automation case now fails because the expected weapon identity no longer lines up with the shared test contract.

### Goal

Bring player feedback and validation back into alignment. Add a small but correct active-slot HUD indicator that survives lifecycle transitions, and repair the broken melee automation case without disabling, weakening, or special-casing the test.

### Constraints

- keep the HUD change intentionally small and driven by existing quick-bar state
- initialize from current state; do not depend only on future updates
- keep the test strict and repair the shared contract rather than only the single failing assertion
- be ready to communicate what you finished and what still needs proof if time runs out

## Interviewer Setup

### Seed

- Start from a baseline with no active-slot indicator present in the assigned HUD widget.
- Seed lifecycle friction so the UI can miss the current active slot if it only listens for future changes.
- Drift one melee case by changing shared helper semantics or expectation construction in `Plugins/GameFeatures/ShooterTests/Source/ShooterTestsRuntime/Private/ShooterTestsActorAnimationTests.cpp` so a narrow case fails while the root cause lives above the single assertion.

### Expected Fix Shape

- Reuse existing quick-bar state or messages to add a lightweight HUD indicator that initializes from current state and updates as the active slot changes.
- Restore the correct helper-level melee expectation so strict coverage remains meaningful for the full family of cases.
- Avoid hardcoding slot values, patching only the single failing assertion body, or redesigning the HUD.

### Likely Search Surface

- quick-bar state exposure and UI-facing messages
- HUD widget lifecycle or initialization path
- ShooterTests helper logic or shared expectation construction for weapon identity

### Red Herrings To Ignore

- hardcoded slot labels that only work after a future change event
- full HUD redesigns
- weakening, skipping, or special-casing the failing melee test

## Verification

### Manual Proof

Show the HUD with the new active-slot indicator and prove it stays correct on initial load, after the first pickup, while cycling slots, and after clearing the active slot. If time allows, show that the affected melee behavior still lines up with expectations in-game.

### Quick Check

Demonstrate that the indicator reads current quick-bar state before the first change event and stays in sync through later transitions. Then run or target the broken `WeaponMelee_*` case and show it now passes because the shared helper or expectation contract is correct again.

## Hint Ladder

- Hint 1: quick-bar already knows the state the HUD needs, and the broken melee test should be traced through shared expectations instead of the single failing line.
- Hint 2: the UI needs both current-state initialization and transition updates, and the test failure comes from contract drift above the leaf assertion.

## Scoring Notes

- Strong signal: candidate lands a small, correct HUD feature that survives lifecycle edges and repairs the strict test at the helper-contract level.
- Partial credit: candidate completes one side cleanly and narrows the other to the right lifecycle or helper boundary.
- Miss: candidate hardcodes a slot number, patches only the visible widget text, disables the test, or special-cases the single failing case.
