# Interview Runbook

## Goal

Use `interview-master` to evaluate how a mid-level Unreal candidate investigates, scopes, fixes, verifies, and communicates across a deliberately wide 90-minute exercise while using AI agents. The strongest candidates should combine Unreal judgment with disciplined prompting, appropriate agent selection, and evidence-based validation instead of treating AI as a file-locating shortcut.

## Pre-Interview Setup

1. Prepare a clean project clone with the required Lyra content available and the editor opening successfully.
2. Start from a clean authoring baseline, for example `interview/base`.
3. Create or refresh `interview-master` from that baseline.
4. Seed one integrated exercise that spans at least three subsystems and requires multiple coordinated edits for full recovery.
5. Mix runtime, presentation, and validation surfaces:
   - gameplay or state ownership
   - UI or presentation contracts
   - config, data, replication, or automated coverage
6. Sanity-check that:
   - the umbrella symptom reproduces in under 5 minutes
   - no single-file diff explains the full problem
   - strong AI-assisted investigation materially outperforms blind grep
7. Confirm the branch can be restored quickly between candidates.

## Candidate Snapshot Workflow

Do not hand candidates the private authoring repo with the scenario branch history intact.

Instead, export a snapshot from the prepared branch tip:

```powershell
powershell -ExecutionPolicy Bypass -File ".\Build\Scripts\Interview\Prepare-InterviewSnapshot.ps1" `
  -Branch "interview-master" `
  -OutputRoot ".\Saved\InterviewSnapshots" `
  -Force
```

Default behavior of the exporter:

- exports only the branch tip, not the authoring git history
- removes `Docs/Interview` so hints and interviewer notes are not visible
- writes a candidate-facing root `README.md` describing the issue to solve
- initializes a fresh one-commit git repo unless `-NoGitInit` is used

If you want plain folders without any git history at all, add `-NoGitInit`.

## Candidate Environment

- Give the candidate:
  - the prepared `interview-master` branch or its exported snapshot
  - the structured scenario brief only
  - Unreal Editor access
  - source access
  - approved AI agents and tools
- Tell the candidate:
  - they have 90 minutes
  - they are expected to use AI deliberately, not just optionally
  - they should narrow the problem before broad edits
  - they should use prompts that seek evidence, boundaries, and source of truth
  - they should choose agents or tools intentionally for search, testing, and validation
  - they should verify AI claims before accepting them
  - partial progress still counts if they restore the highest-value path and explain what remains

## Session Flow

| Time | Interviewer action |
| --- | --- |
| 0:00-0:05 | hand over brief, confirm tooling works, answer environment questions only |
| 0:05-0:20 | observe how they reproduce the issue, group symptoms, and choose what to prove first |
| 0:20-0:40 | watch how they prompt AI, select agents or tools, and narrow the search surface |
| 0:40-1:05 | expect implementation progress on the highest-value path, with at least one runtime or test-backed proof step |
| 1:05-1:20 | push for cross-system validation, not just local fixes |
| 1:20-1:30 | ask for working proof, summary of changes, AI usage rationale, rejected hypotheses, and remaining risks |

## Hint Policy

- Default allowance: 3 hints maximum
- Hint 1 at or after minute 20:
  - redirect them toward the right subsystem grouping or source-of-truth boundary
  - example shape: "separate the frontend/config path from the combat/runtime path before changing files"
- Hint 2 at or after minute 45:
  - redirect them toward better AI workflow or missing evidence
  - example shape: "use one agent to narrow the state ownership path and another to inspect the failing test contract"
- Hint 3 at or after minute 65:
  - redirect them toward the highest-value unfinished path
  - example shape: "choose one recovery thread to finish fully and prove it, rather than broad partial fixes"
- Do not provide file names or exact edits unless the scenario explicitly allows it.
- Watch for weak AI usage:
  - repeated wide searches without narrowing
  - vague prompts such as "fix this bug" with no subsystem boundary or evidence request
  - edits in several plausible files before any proof step
  - accepting AI-suggested fixes without checking runtime, tests, or source-of-truth contracts
- Reward candidates who use AI to decompose the problem and then validate the results themselves.
- Record every hint used on the score sheet.

## What To Score

Score against the shared rubric in `RUBRIC.md`, with the default emphasis:

- evidence-based problem framing and prioritization
- prompt quality, agent selection, and verification discipline
- understanding of Unreal gameplay, UI, gameplay ability grant/input/execution paths, config, replication, and test boundaries
- correctness and restraint of the fix
- communication quality, especially around accepted versus rejected AI output

## Branch and Reset Workflow

Use this in a real git clone:

1. Start from `interview/base`.
2. Create or refresh `interview-master`.
3. Apply only the seeded changes for the current master exercise revision.
4. Dry-run the scenario end to end from the prepared branch.
5. Export a clean candidate snapshot.
6. After the interview, discard local candidate edits and reset to the prepared branch snapshot.

Keep the seeded exercise broad but intentional:

- one umbrella broken experience with several correlated symptoms
- multiple subsystem boundaries
- multiple required file changes for full recovery
- at least one runtime proof path plus one targeted validation path
- no dependence on hidden repo history or private authoring notes

## Failure Modes To Avoid

- scenarios solved by one obvious file diff
- scenarios where AI search alone reveals the entire answer without runtime reasoning
- scenarios that depend on cooking or packaging
- scenarios that require hidden project knowledge
- tasks that need long content imports during the interview
- broad breakage with no prioritization path
- scenarios where the candidate can appear done without proving a real state transition, replicated behavior, or shared contract

## Calibration

Before using the master exercise with candidates:

1. Run it internally once with a mid-level Unreal engineer using AI well.
2. Run it internally once with a mid-level Unreal engineer using AI poorly or minimally.
3. Confirm the umbrella symptom reproduces quickly and the subsystem boundaries are discoverable.
4. Confirm strong prompting and agent selection noticeably reduce time-to-narrowing.
5. Confirm a candidate using only manual search is unlikely to finish the full exercise inside 90 minutes.
6. Confirm a strong candidate can still complete the highest-value recovery path and prove it clearly inside 90 minutes.
7. Review the brief, hint ladder, and scoring notes with an interviewer before using the scenario.
