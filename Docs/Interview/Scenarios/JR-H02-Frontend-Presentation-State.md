# JR-H02: Frontend Presentation Source Of Truth

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-H02` |
| Branch | `interview/jr-h02-frontend-presentation-state` |
| Duration | `60 minutes` |
| Type | `presentation source-of-truth mismatch` |
| Systems | `Frontend state`, `Asset discovery`, `Primary data`, `Weapon UI`, `Presentation contracts` |
| Main proof | lobby background returns from the intended source and weapon HUD clears correctly on no-weapon transitions |
| Quick check | the chosen fix restores the real presentation source-of-truth path instead of only repairing a missing reference or masking stale HUD state |

## Candidate Brief

### Symptom

The project now falls back to a flatter presentation state than intended. The frontend still opens, but the expected lobby backdrop is gone, and during gameplay the weapon HUD can stay stale after the player transitions into a no-weapon state.

### Goal

Restore the intended presentation behavior without rewriting the frontend or HUD systems. The fix should re-enable the correct background path and make the weapon UI respond correctly to both equip and unequip transitions through the same contract the rest of the experience expects.

### Constraints

- treat this as a source-of-truth and fallback problem before treating it as a rendering problem
- avoid pure asset-name or one-off reference repair as the main fix path unless the state contract proves correct
- keep changes small and local to the existing presentation flow
- be ready to explain which symptom you prioritized and what evidence told you it mattered first

## Interviewer Setup

### Seed

- Misconfigure the `LyraLobbyBackground` discovery path in `Config/DefaultGame.ini` so the obvious symptom looks like a missing asset registration.
- Add nearby fallback drift in the frontend presentation path so the durable fix requires confirming which state source is supposed to provide the background.
- Partially handle the no-weapon case in `Source/LyraGame/UI/Weapons/LyraWeaponUserInterface.cpp` by clearing cached data without routing through the existing weapon-change contract.

### Expected Fix Shape

- Restore the intended source-of-truth path for lobby background discovery or fallback selection instead of only patching the most visible missing reference.
- Make weapon UI transitions to `nullptr` use the same update contract as valid weapon equips.
- Avoid changing unrelated session flow, loading-screen logic, or per-frame HUD refresh behavior.

### Likely Search Surface

- frontend state and presentation ownership
- asset-manager or config-backed discovery for lobby backgrounds
- weapon UI state-transition and rebuild contract

### Red Herrings To Ignore

- renaming assets until something appears by accident
- material or layout redesign
- per-frame widget refresh hacks that hide stale no-weapon state

## Verification

### Manual Proof

Open the frontend and show the intended background experience again. Then enter gameplay, equip a weapon, transition to a no-weapon state, and show that the stale weapon HUD no longer remains visible.

### Quick Check

Show evidence that the lobby background now comes from the intended registered source or fallback path, not from an incidental reference repair. Then prove that weapon UI updates run for both equip and unequip transitions, including the `nullptr` path.

## Hint Ladder

- Hint 1: verify which system is supposed to own presentation state before you repair the most visible asset symptom.
- Hint 2: one path is bypassing the real source of truth, and the other clears presentation state without going through the same contract used for valid updates.

## Scoring Notes

- Strong signal: candidate separates visible asset symptoms from the underlying presentation contract and avoids getting trapped in cosmetic fixes.
- Partial credit: candidate restores one presentation path fully and clearly proves the missing state transition on the other.
- Miss: candidate spends most of the session renaming assets, rewriting UI rendering, or masking stale state without proving ownership.
