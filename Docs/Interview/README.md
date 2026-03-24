# Junior Unreal Interview Pack

This pack turns the Lyra-based project into a reusable interview bank for fresher and junior Unreal engineers. It is optimized for a 60-minute timebox with AI agents allowed, and it prioritizes problem-solving, Unreal navigation, and minimal safe fixes over broad refactors.

## Contents

- `RUNBOOK.md`: interviewer setup, timing, hint policy, and branch/reset workflow
- `RUBRIC.md`: shared scoring model for all scenarios
- `SCENARIO_TEMPLATE.md`: reusable template for new scenarios
- `Scenarios/`: eight ready-to-seed scenarios grounded in this repo

## Working Model

- One branch per scenario in a real git clone
- Structured candidate brief with visible success criteria
- Manual proof plus a quick reproducible check for every scenario
- Default difficulty target: strong junior reaches 60-80% completion in 1 hour

## Scenario Index

| ID | Branch | Type | Primary Systems | Primary Proof |
| --- | --- | --- | --- | --- |
| JR-01 | `interview/jr-01-weapon-hit-confirmation` | bug fix | weapons, HUD, teams | hit markers only show on valid enemy hits |
| JR-02 | `interview/jr-02-quickbar-first-pickup` | bug fix / small feature | quick bar, inventory, equipment | first pickup auto-equips without manual slot cycling |
| JR-03 | `interview/jr-03-lobby-background` | editor/data fix | frontend, data assets, UI | lobby background world renders again |
| JR-04 | `interview/jr-04-weapon-ui-stale-state` | bug fix | weapon UI, equipment state | weapon HUD clears or rebuilds correctly on unequip |
| JR-05 | `interview/jr-05-reticle-config` | editor/data fix | reticle config, item definitions, HUD | missing reticle reappears for the affected weapon |
| JR-06 | `interview/jr-06-network-crouch` | gameplay bug fix | character, input, replication, ShooterTests | crouch works across 2-player PIE and network test passes |
| JR-07 | `interview/jr-07-active-slot-indicator` | small feature | quick bar, HUD, gameplay messages | HUD shows active slot and updates while cycling |
| JR-08 | `interview/jr-08-melee-test-drift` | test repair | ShooterTests, weapon data, editor validation | shotgun melee test passes again |

## Maintenance Notes

- Treat this folder as the source of truth on the default branch.
- In a real clone, seed each scenario branch from a clean baseline and keep the branch diff limited to one interview task.
- This workspace snapshot does not include `.git`, so branch creation is documented here but not executed in this pack.
