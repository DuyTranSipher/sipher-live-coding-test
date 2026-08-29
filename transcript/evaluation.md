# Candidate Evaluation — tran-ngoc-anh-dn

## Automated Bug Check: 8 / 10 (effectively 10 / 10)

| # | Bug | Automated Result | Notes |
|---|-----|-----------------|-------|
| 1 | Lobby background asset scan | FIXED | |
| 2 | First-weapon ownership | BROKEN (false negative) | Fix is correct — item assigned before activation. Eval pattern too strict. |
| 3 | Weapon HUD no-weapon transition | BROKEN (false negative) | Fix is correct — OnWeaponChanged notification added. Eval pattern too strict. |
| 4 | Hostile-hit reconciliation | FIXED | |
| 5 | Auto-run state tags | FIXED | |
| 6 | On-spawn ability startup | FIXED | |
| 7 | Game-feature ability grants | FIXED | |
| 8 | Ability input routing | FIXED | |
| 9 | Heal execution | FIXED | |
| 10 | Remote crouch replication | FIXED | |

---

## Full Rubric Scoring

| Category | Score | Notes |
|---|---|---|
| Problem framing | 2 / 4 | Worked through bugs sequentially from the list. No subsystem grouping, no reprioritization, no rejection of wrong leads. |
| AI prompting & delegation | 2 / 4 | Session 1: symptom copy-paste with no constraint-setting or evidence requests. Session 2 shows broader exploration but still no targeted decomposition or output validation. |
| Unreal cross-system judgment | 3 / 4 | Fixes span Config, AbilitySystem, Character, Equipment, GameFeatures, UI/Weapons, Player — correct breadth. Session 2 shows unprompted exploration of asset manager, lobby background pipeline, and respawn architecture. |
| Implementation quality | 3 / 4 | All fixes minimal, correct, and well-scoped. No unnecessary changes. Contracts preserved across related systems. No regressions introduced. |
| Verification & communication | 2 / 4 | Session 1 ends with a structured fix summary. No runtime verification, no regression checks. The weapon HUD fix passes nullptr as the new weapon in OnWeaponChanged — a subtle correctness question that was never surfaced or verified. |
| **Total** | **12 / 20** | |

**Threshold: Borderline (9–12)** — "inspect AI usage quality, narrowing speed, and proof quality carefully."

---

## Prompting Skill — Detailed Assessment

### Strengths
- Prompts are grounded in the symptom language of the system (not generic)
- Explored beyond the task scope in session 2 (architecture, respawn logic)
- No evidence of dangerous or destructive prompting

### Weaknesses
- Session 1 prompts are thin — almost entirely symptom copy-paste with no refinement, no constraint-setting, no evidence requests
- No visible validation prompts ("how do I verify this is correct?", "what else could this affect?")
- Cannot determine if candidate understood or could explain the AI's output — transcript does not capture that
- No targeted tool or agent selection — treated AI as a single oracle

### Automatic Downgrade Flag
- **Triggered:** "uses vague AI prompts that generate broad edits with no evidence request" — already reflected in the 2/4 prompting score.

---

## Hiring Read

The candidate is technically capable — every fix is correct and the architecture exploration in session 2 shows genuine Unreal curiosity. The weakness is in how they used AI: as an oracle rather than a tool they steered. A strong candidate at this level should be directing the AI toward specific subsystems, asking it to justify its output, and providing their own verification. That loop is missing here.

**Verdict: Borderline** — viable if the team values correctness and system breadth over prompting discipline. Recommend a follow-up conversation to probe whether the candidate can explain the fixes independently and demonstrate intentional AI usage.
