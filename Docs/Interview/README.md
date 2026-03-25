# AI-Forward Master Interview Pack

This pack turns the Lyra-based project into a reusable 90-minute interview exercise for mid-level Unreal candidates in an AI-agent-supported environment. The primary exercise is intentionally wider than the earlier small-diff banks: it spans multiple systems, requires several coordinated file changes, and is designed so a candidate should struggle to finish well without disciplined AI usage.

## Contents

- `RUNBOOK.md`: interviewer setup, timing, hint policy, branch/reset workflow, and AI-observation guidance
- `RUBRIC.md`: shared scoring model with explicit AI prompting, agent selection, and verification criteria
- `SCENARIO_TEMPLATE.md`: reusable template for broad cross-system scenarios
- `Scenarios/`: one master scenario plus the earlier narrow scenarios kept for calibration and fallback

## Working Model

- One prepared `interview-master` branch in a real git clone
- One candidate-facing brief that describes the broken experience in product terms, not file terms
- One exercise that crosses at least three subsystems and normally needs four or more meaningful edits for full recovery
- AI is expected, not merely tolerated:
  - candidates should narrow the problem with targeted prompts
  - candidates should choose appropriate agents or tools for search, hypothesis testing, and verification
  - candidates should reject or refine weak AI output instead of applying it blindly
- Default calibration target:
  - a mid-level Unreal engineer using AI well can usually complete the core recovery path and most secondary validation within 90 minutes
  - a candidate using only manual search should have difficulty reaching full completion in the same timebox

## Scenario Index

### Primary Exercise

| ID | Branch | Type | Primary Systems | Primary Proof |
| --- | --- | --- | --- | --- |
| MASTER | `interview-master` | AI-orchestrated cross-system recovery | frontend asset discovery, quick bar and equipment, weapon HUD, combat feedback, character movement, `ULyraGameplayAbility` startup logic, gameplay ability grants, gameplay ability input binding, gameplay ability execution, replication, ShooterTests | core gameplay readiness is restored across frontend, combat onboarding, movement, shared ability startup, feature ability grants, ability input routing, GAS-backed interactions, multiplayer presentation, and strict automation coverage |

### Legacy Calibration Scenarios

| ID | Branch | Type | Primary Systems | Primary Proof |
| --- | --- | --- | --- | --- |
| JR-H01 | `interview/jr-h01-combat-onboarding-state` | state-ownership bug fix | quick bar, equipment, HUD messages, weapon confirmation | first pickup becomes truly active and confirmed hostile hits keep feedback after reconciliation |
| JR-H02 | `interview/jr-h02-frontend-presentation-state` | presentation source-of-truth mismatch | frontend state, asset discovery, weapon UI | lobby background returns from the intended source and weapon HUD clears correctly on no-weapon transitions |
| JR-H03 | `interview/jr-h03-gameplay-presentation-parity` | config-versus-runtime discrimination | weapon data, reticle config, crouch state, ShooterTests | affected weapon regains its full reticle and network crouch parity is restored with proof |
| JR-H04 | `interview/jr-h04-feedback-and-coverage` | contract-and-coverage scenario | quick bar, HUD lifecycle, gameplay messages, ShooterTests | active-slot HUD feedback survives lifecycle transitions and the broken melee test passes without weakening coverage |

## Pack Design Rules

- Favor one integrated exercise over isolated one-file traps.
- Seed defects across interacting systems so grep alone does not isolate the full answer.
- Require at least one runtime proof path and one targeted validation path from tests, config, or replicated state.
- Make AI usage part of the signal:
  - prompt quality should affect how quickly the candidate narrows the problem
  - agent or tool choice should change investigation speed and accuracy
  - verification should separate strong AI use from blind AI acceptance
- Keep the candidate task solvable from the snapshot alone. Do not rely on hidden git history or private authoring notes.
- Preserve prioritization value: a candidate can still score well by restoring the highest-value path and explaining what remains.

## Maintenance Notes

- Treat `interview-master` as the primary interview branch.
- Keep the legacy narrow scenarios for calibration, interviewer onboarding, or fallback shorter sessions.
- Preserve the current snapshot exporter so candidate handoff stays git-history-safe.
- In a real clone, seed the master branch from a clean baseline and verify that the broken experience reproduces quickly before each use.
