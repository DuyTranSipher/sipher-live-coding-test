# JR-H03: Gameplay Presentation Parity

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-H03` |
| Branch | `interview/jr-h03-gameplay-presentation-parity` |
| Duration | `60 minutes` |
| Type | `config-versus-runtime discrimination` |
| Systems | `Weapon data`, `Reticle config`, `Character state`, `Replication`, `ShooterTests` |
| Main proof | the affected weapon shows its full reticle again and network crouch parity is restored in a 2-player session |
| Quick check | the candidate proves whether the break is data drift, runtime state drift, or both, and verifies the chosen fix path with targeted evidence |

## Candidate Brief

### Symptom

The project has lost parity between what players should see and what the game now delivers. One weapon has lost part of its reticle presentation, and crouch no longer presents the same way for both sides of a multiplayer session even though standalone play can still look plausible.

### Goal

Restore the intended gameplay presentation with the smallest safe fixes. The affected weapon should recover its complete reticle setup, and crouch should once again present correctly across a 2-player networked session instead of only looking acceptable locally.

### Constraints

- do not assume the reticle issue is purely data or the crouch issue is purely code until you prove it
- reproduce crouch in a networked context, not only standalone
- use existing ShooterTests as evidence where helpful, but do not treat a single test name as the answer
- be ready to explain which issue you verified fully and what remains if time runs out

## Interviewer Setup

### Seed

- Break the affected weapon's reticle presentation by drifting part of its reticle reference chain so the symptom looks like simple content loss.
- Introduce a local-only crouch regression in `Source/LyraGame/Character/LyraCharacter.cpp` so local crouch still appears plausible while remote state parity breaks.
- Keep enough nearby noise that a candidate can waste time debating config versus runtime state if they do not validate each path.

### Expected Fix Shape

- Find and restore the full reticle reference chain or data contract for the affected weapon rather than patching a single visible layer.
- Reproduce the crouch issue in 2-player PIE or via the existing network coverage and restore the intended crouch state path.
- Keep other weapons and the local movement experience unchanged.

### Likely Search Surface

- per-weapon reticle data and item-definition fragments
- crouch gameplay state, tags, and replication-facing presentation
- existing ShooterTests or multiplayer repro paths that can distinguish local from remote truth

### Red Herrings To Ignore

- broad reticle rendering rewrites before checking weapon data
- camera offset tuning that does not explain remote parity
- trusting standalone crouch as sufficient proof

## Verification

### Manual Proof

Equip the affected weapon and show that its full reticle presentation appears again. Then run a 2-player PIE session and show crouch behavior from both the local and remote perspectives.

### Quick Check

Show evidence that the reticle issue was actually in the affected weapon's data or reference chain. Then use a targeted multiplayer check or ShooterTests coverage to prove that crouch parity is restored for the remote view, not just the local player.

## Hint Ladder

- Hint 1: prove whether each symptom is caused by data drift or runtime state drift before rewriting shared systems.
- Hint 2: compare the broken weapon against a working weapon for the reticle chain, and compare local versus remote crouch evidence before trusting the first plausible fix.

## Scoring Notes

- Strong signal: candidate cleanly separates config drift from runtime state drift and uses the existing test surface to validate the harder multiplayer path.
- Partial credit: candidate restores one issue fully and shows evidence-based narrowing on the other.
- Miss: candidate rewrites broad UI or movement systems without proving whether the break lives in the asset chain or the replicated crouch state.
