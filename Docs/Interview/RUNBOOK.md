# Interview Runbook

## Goal

Use one seeded scenario branch to evaluate how a junior Unreal engineer investigates, scopes, fixes, verifies, and communicates within a 60-minute session while using AI agents.

## Pre-Interview Setup

1. Prepare a clean project clone with the required Lyra content available and the editor opening successfully.
2. Create a clean baseline branch, for example `interview/base`.
3. Create one child branch per scenario using the naming in [`README.md`](./README.md).
4. Seed exactly one intentional defect or feature request per branch.
5. Sanity-check that the branch reproduces the issue in under 3 minutes.
6. Confirm the branch can be restored quickly between candidates.

## Candidate Environment

- Give the candidate:
  - one scenario branch
  - the structured scenario brief only
  - Unreal Editor access
  - source access
  - approved AI agents/tools
- Tell the candidate:
  - they have 60 minutes
  - they should prefer a minimal safe fix
  - they should verify the result before time ends
  - partial progress is still valuable if they can explain the blocker clearly

## Session Flow

| Time | Interviewer action |
| --- | --- |
| 0:00-0:05 | hand over brief, confirm tooling works, answer environment questions only |
| 0:05-0:20 | observe how they reproduce and narrow the issue |
| 0:20-0:35 | allow one planned hint if they are stalled |
| 0:35-0:50 | push for verification and scope control |
| 0:50-1:00 | ask for proof, summary of changes, and remaining risks |

## Hint Policy

- Default allowance: 2 hints maximum
- Hint 1 at or after minute 15:
  - redirect them to the right subsystem or file family
- Hint 2 at or after minute 30:
  - narrow to the likely root cause or asset category
- Do not provide implementation details unless the scenario explicitly allows it.
- Record every hint used on the score sheet.

## What To Score

Score against the shared rubric in [`RUBRIC.md`](./RUBRIC.md), with the default emphasis:

- problem framing and debugging approach
- safe use of AI tools
- understanding of Unreal gameplay/UI patterns
- correctness and restraint of the fix
- verification and communication

## Branch and Reset Workflow

Use this in a real git clone:

1. Start from `interview/base`.
2. Create `interview/jr-xx-*` branch.
3. Apply the seeded change for that scenario only.
4. Dry-run the scenario end to end.
5. After the interview, discard local candidate edits and reset to the prepared branch snapshot.

Keep seed diffs small:

- one root cause
- one visible symptom
- one expected proof path
- optional secondary file or asset only when it helps realism

## Failure Modes To Avoid

- scenarios that depend on cooking or packaging
- scenarios that require hidden project knowledge
- tasks that need long content imports during the interview
- bugs with multiple equally valid root causes
- scenarios where the fastest path is random trial and error instead of reasoning

## Calibration

Before using a scenario with candidates:

1. Run it internally with a junior-to-mid engineer and a 60-minute timer.
2. Confirm they can reproduce the problem quickly.
3. Confirm the expected fix stays within 1-3 files or one asset plus one code path.
4. Confirm the proof path is visible and fast.
5. Adjust scope if most of the hour is spent on editor startup, build wait time, or content hunting.
