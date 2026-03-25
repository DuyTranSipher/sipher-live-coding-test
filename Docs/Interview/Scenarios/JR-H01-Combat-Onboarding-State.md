# JR-H01: Combat Onboarding State Ownership

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-H01` |
| Branch | `interview/jr-h01-combat-onboarding-state` |
| Duration | `60 minutes` |
| Type | `state-ownership bug fix` |
| Systems | `Quick bar`, `Equipment`, `HUD messages`, `Weapon confirmation`, `Combat feedback` |
| Main proof | first weapon pickup becomes the true active and equipped item, and confirmed hostile hits keep feedback after reconciliation |
| Quick check | active-slot ownership, HUD feedback, and hostile-hit confirmation all agree on the same state transition instead of only looking correct locally |

## Candidate Brief

### Symptom

The first minute of combat feels unreliable. On a fresh run, the first picked-up weapon can look selected without behaving like the true active weapon, and once combat starts, some valid enemy hits lose their confirmation feedback after the game settles the result.

### Goal

Restore a stable first-combat experience with the smallest safe fix. The first usable pickup should become the real active weapon through the normal game flow, and confirmed hostile hits should keep their intended feedback while misses and invalid targets still fail cleanly.

### Constraints

- prefer a minimal fix in the existing ownership, equipment, and feedback paths
- prove whether the break is lifecycle ordering, wrong authority, stale messaging, or a combination before broad edits
- keep team validation and server-confirmation behavior intact
- be ready to explain what you fixed first if you do not complete every symptom

## Interviewer Setup

### Seed

- Partially implement first-slot activation in `Source/LyraGame/Equipment/LyraQuickBarComponent.cpp` by mutating active state directly before the normal equip and message path runs.
- Seed nearby HUD drift so the player can see a plausible active-slot signal even when ownership is wrong.
- Break confirmed-hit reconciliation in `Source/LyraGame/Weapons/LyraWeaponStateComponent.cpp` so valid hostile markers are filtered using stale or non-authoritative state after the server response.

### Expected Fix Shape

- Route the first-usable-item case through the real active-slot ownership path instead of a partial shortcut.
- Keep HUD feedback driven by the same source of truth as equipment state.
- Restore the correct hostile-hit reconciliation logic without weakening team or validity checks.
- Leave widget painting, broad inventory replication, and weapon ability prediction alone unless the candidate proves they are on the critical path.

### Likely Search Surface

- quick-bar to equipment activation handoff
- gameplay-message or HUD feedback path that reflects the active slot
- weapon-state reconciliation and hostile-target validation

### Red Herrings To Ignore

- repainting the HUD widget so it only looks correct
- broad inventory replication rewrites
- unrelated weapon prediction or reticle rendering internals

## Verification

### Manual Proof

Start from a state with no equipped quick-bar item, pick up the first weapon, and show that it becomes the real active and equipped weapon without manual slot cycling. Then fire at a valid enemy and at world geometry to show that only the valid hostile hit keeps confirmation feedback after reconciliation.

### Quick Check

Show evidence that the first pickup now travels through the normal ownership transition instead of a direct state mutation. Then confirm that the hostile-hit reconciliation step preserves only markers that still pass the authoritative hostile-target rules.

## Hint Ladder

- Hint 1: verify where active-weapon ownership is supposed to change, and which downstream systems only mirror that state.
- Hint 2: one issue comes from bypassing the real ownership transition, and the other comes from validating confirmed hits against the wrong post-reconciliation state.

## Scoring Notes

- Strong signal: candidate proves the difference between looking active and being active, then fixes the true ownership path before touching presentation drift.
- Partial credit: candidate fully repairs the first-pickup ownership issue and clearly narrows the confirmation-feedback issue with evidence.
- Miss: candidate patches only the HUD, hardcodes slot behavior, or rewrites broad combat systems without proving where state ownership diverges.
