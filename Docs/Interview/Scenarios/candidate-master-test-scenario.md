# Candidate Master Test Scenario

## Metadata

| Field | Value |
| --- | --- |
| ID | `MASTER` |
| Branch | `interview-master` |
| Duration | `60 minutes` |
| Type | `AI-orchestrated cross-system recovery` |
| Systems | `Frontend asset discovery`, `Quick bar`, `Equipment`, `Weapon HUD`, `Combat feedback`, `Character movement`, `ULyraGameplayAbility startup logic`, `Gameplay ability grants`, `Gameplay ability input binding`, `Gameplay ability execution`, `Replication` |
| Main proof | frontend presentation, first-weapon ownership, weapon HUD transitions, hostile-hit feedback, auto-run and crouch behavior, on-spawn ability behavior, feature-granted ability behavior, ability-bound input behavior, heal-effect behavior, and remote crouch parity are all restored to the intended state |
| Quick check | the candidate uses AI to narrow config, runtime, movement, shared `ULyraGameplayAbility` logic, ability-grant, ability-input, and GAS boundaries separately, then validates the accepted fixes with runtime evidence instead of trusting generated edits |

## Candidate Brief

### Symptom

Several gameplay regressions have landed together:

- the lobby background no longer loads from the intended source, so the frontend opens in a flatter state
  **Expected:** the frontend should open with the intended lobby background loaded from the correct asset source
- the first weapon pickup can appear to succeed without becoming the true active or equipped weapon
  **Expected:** the first pickup should become the true active and equipped weapon with proper ownership
- when the player transitions to no weapon, the weapon HUD can remain in a stale state
  **Expected:** the weapon HUD should clear correctly when transitioning to a no-weapon state
- some valid hostile hits lose their confirmation feedback even though the shot should count
  **Expected:** valid hostile hits should retain their confirmation feedback after server reconciliation
- auto-run state no longer matches the requested movement behavior, and remote crouch presentation is no longer reliable in multiplayer
  **Expected:** auto-run should toggle the intended movement behavior, and crouch should replicate with parity across all clients
- at least one shared on-spawn ability path no longer starts correctly, so expected interaction-style behavior can fail to come online
  **Expected:** on-spawn abilities should come online through the shared base activation path
- some game-feature-granted abilities are missing when the actor becomes ready
  **Expected:** feature-granted abilities should attach when the owning actor becomes ready
- some additional ability-bound inputs behave like the wrong press or release path
  **Expected:** ability-bound inputs should route through the intended press and release flow
- healing through the gameplay-effect path no longer restores health as expected
  **Expected:** heal execution should restore health correctly through the gameplay-effect path

### Goal

Fix the real gameplay bugs, not just the visible symptoms. A full solution restores the intended frontend background, true first-weapon equip ownership, correct no-weapon HUD clearing, hostile-hit confirmation, auto-run behavior, replicated crouch parity, shared on-spawn ability startup, game-feature ability grants, additional ability input routing, and heal execution.

### Constraints

- use AI agents or tools deliberately
- start by grouping the symptoms into likely subsystem boundaries instead of treating them as one file hunt
- prefer prompts that ask for source of truth, ownership transitions, or shared contracts
- validate AI suggestions before applying them broadly
- do not patch only the visible widget layer
- be ready to explain what you fixed, what you intentionally deferred, and why
- export and hand back your full AI prompting history (chat logs, agent transcripts, or equivalent) alongside the code changes

### Required Read And Solve

- Read the shared gameplay-ability base path in `Source/LyraGame/AbilitySystem/Abilities/LyraGameplayAbility.cpp` before patching any single derived ability.
- Read the game-feature ability lifecycle path in `Source/LyraGame/GameFeatures/GameFeatureAction_AddAbilities.cpp` and the additional input path in `Source/LyraGame/Character/LyraHeroComponent.cpp` before changing mappings or assets.
- Solve the broken shared `ULyraGameplayAbility` startup behavior, not just one derived ability symptom.
- Solve the gameplay-ability execution path so heal behavior is correct in runtime.

## Interviewer Setup

### Seed

- Drift the lobby-background asset scan in `Config/DefaultGame.ini` so the obvious symptom looks like a simple missing reference.
- Partially handle no-weapon transitions in `Source/LyraGame/UI/Weapons/LyraWeaponUserInterface.cpp` by clearing cached state without routing through the normal weapon-change contract.
- Break first-pickup ownership in `Source/LyraGame/Equipment/LyraQuickBarComponent.cpp` by mutating active-slot behavior before the normal slot state is in place.
- Break hostile-hit reconciliation in `Source/LyraGame/Weapons/LyraWeaponStateComponent.cpp` so valid confirmed enemy hits can be filtered using the wrong replacement index progression.
- Drift auto-run state transitions in `Source/LyraGame/Player/LyraPlayerController.cpp` so movement-facing status no longer matches the requested controller action.
- Break shared `ULyraGameplayAbility` on-spawn activation logic in `Source/LyraGame/AbilitySystem/Abilities/LyraGameplayAbility.cpp` so abilities that should auto-start from their activation policy no longer come online through the base path.
- Break the game-feature ability-ready grant path in `Source/LyraGame/GameFeatures/GameFeatureAction_AddAbilities.cpp` so feature-provided abilities stop attaching when the owning actor becomes ready.
- Drift game-feature ability input binding in `Source/LyraGame/Character/LyraHeroComponent.cpp` so additional ability-bound inputs are routed through the wrong press or release contract.
- Break healing execution in `Source/LyraGame/AbilitySystem/Executions/LyraHealExecution.cpp` so the gameplay-effect path no longer restores health as intended.
- Introduce remote crouch presentation drift in `Source/LyraGame/Character/LyraCharacter.cpp` by making a replication callback conditional on movement-mode state.

### Expected Fix Shape

- Restore the intended asset-scan source for the lobby background instead of renaming assets until one appears.
- Make no-weapon UI transitions flow through the same update contract as real weapon equips.
- Route first-pickup activation through the real quick-bar ownership path.
- Restore the authoritative hostile-hit reconciliation logic.
- Restore auto-run state so controller intent, gameplay tags, and movement behavior agree again.
- Restore the shared `ULyraGameplayAbility` startup contract instead of patching a single derived ability to compensate.
- Restore the game-feature ability grant readiness contract so feature-provided abilities appear on the intended actor lifecycle.
- Restore additional ability-input routing so game-feature ability tags once again activate through the intended press and release flow.
- Restore heal-effect execution through the shared gameplay ability pipeline.
- Restore replicated crouch presentation for the remote view, not just the local player.

### Expected AI Workflow

- Use one focused search or agent pass to separate frontend/config issues from combat, movement, shared-ability startup, ability-grant, ability-input, and GAS runtime issues.
- Ask AI for ownership boundaries, call flow, or validation surfaces, not for broad “fix the bug” patches.
- Reject AI output that proposes widget repaint hacks or broad movement rewrites without evidence.

### Likely Search Surface

- frontend asset discovery and presentation ownership
- quick-bar to equipment state transitions
- weapon UI transition contracts
- server-confirmed hit-marker reconciliation
- controller-driven movement state and auto-run tags
- `ULyraGameplayAbility` activation policy and on-spawn startup flow
- game-feature ability grant readiness and actor-extension contracts
- hero-component ability input routing and game-feature input configs
- gameplay-effect execution and health restoration
- shared replication and crouch callbacks

### Red Herrings To Ignore

- renaming frontend assets until something renders by accident
- repainting the HUD so it only looks correct
- patching only a movement widget or input surface without restoring the underlying state tag or controller contract
- patching only `LyraGameplayAbility_Interact` or one other derived ability without restoring the shared base startup path
- patching only one gameplay ability asset without restoring the shared game-feature grant readiness contract
- patching only one ability asset or key mapping without restoring the shared ability-input routing path
- broad movement rewrites before proving the remote crouch path is broken

## Verification

### Manual Proof

Show the intended frontend background again. Start from a fresh run, pick up the first weapon, and prove it becomes the true active and equipped item. Transition into a no-weapon state and show the weapon UI clears correctly. Fire at a valid hostile target and at invalid geometry and show only the valid hostile hit keeps confirmation feedback after reconciliation. Show that auto-run once again toggles the intended movement behavior. Show that the expected shared on-spawn ability behavior comes online again, then show that the expected game-feature ability grant path becomes available and that ability-bound inputs from that path behave correctly. Show that a damaged player can be healed through the gameplay-effect path. Show crouch parity from both sides of a 2-player session.

### Quick Check

Explain which prompts or agents you used to separate the config, runtime, movement, shared-ability startup, ability-grant, ability-input, and GAS threads. Then show that each accepted fix is backed by runtime evidence instead of trusting generated edits.

## Hint Ladder

- Hint 1: split the problem into presentation, combat ownership, movement, shared-ability startup, ability-grant, ability-input, and GAS threads before editing.
- Hint 2: finish one recovery thread fully and prove it, then use the remaining time on the next-highest-value thread.
- Hint 3: use AI for ownership boundaries and call flow, not broad "fix the bug" patches.

## Scoring Notes

- Strong signal: candidate uses targeted prompts and suitable agents to narrow the repo quickly, then restores the highest-value path with proof instead of broad guesswork.
- Partial credit: candidate fully restores either the combat/runtime thread or the movement-plus-GAS thread and clearly narrows the rest.
- Miss: candidate treats AI like a diff oracle, rewrites broad systems without proof, or patches only presentation logic to make the branch appear fixed.
