# sipher_livecoding_test

Unreal Engine 5.7 Lyra-based project used as a live-coding interview exercise. The `main` branch contains 10 seeded gameplay regressions across multiple subsystems. Candidates receive a clean snapshot and have 60 minutes to investigate, fix, and verify as many as they can using AI-assisted tooling.

## Interview Flow

### 1. Prepare a candidate snapshot

```bat
Prepare-InterviewSnapshot.bat
```

Run with no arguments for interactive mode, or pass arguments directly:

```bat
Prepare-InterviewSnapshot.bat -Branch "main" -Force -GenerateProjectFiles
```

This exports a clean copy of the branch without git history. Hand this folder to the candidate.

### 2. Run the interview

Give the candidate the snapshot, Unreal Editor access, and approved AI tools. The snapshot includes a `README.md` with the candidate brief describing the symptoms and expected outcomes.

See `Docs/Interview/RUNBOOK.md` for session timing, hint policy, and scoring guidance.

### 3. Candidate submits their work

When the candidate finishes, they run `Finish-LiveCoding.bat` inside their snapshot folder. It prompts for their name, creates a `candidate/<name>` branch in this repository, copies their changes back, and commits. If anything fails, the script rolls back automatically so they can retry.

### 4. Evaluate the result

```bat
Evaluate-CandidateSnapshot.bat -SnapshotPath "C:\path\to\candidate\snapshot"
```

Reports which of the 10 regressions were fixed, still broken, or changed in an unexpected way. Use alongside the rubric in `Docs/Interview/RUBRIC.md` for final scoring.

## Adding Scenarios

1. Create a new branch from a clean baseline.
2. Write a scenario doc in `Docs/Interview/Scenarios/` following `Docs/Interview/SCENARIO_TEMPLATE.md`.
3. Seed the regressions on the branch.
4. Add evaluation checks to `Build/Scripts/Interview/Evaluate-CandidateSnapshot.ps1`.
5. Test with `Prepare-InterviewSnapshot.bat` and `Evaluate-CandidateSnapshot.bat` before use.

## Prerequisites

- Unreal Engine 5.7
- Git LFS (for `.uasset`, `.umap`, and other large binaries)
- Windows (batch scripts use PowerShell)
