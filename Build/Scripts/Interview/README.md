# Interview Snapshot Export

Use [Prepare-InterviewSnapshot.ps1](/D:/Projects/sipher_test_project/Build/Scripts/Interview/Prepare-InterviewSnapshot.ps1) to build candidate-safe scenario folders from the private authoring branches.

What it does:
- exports a branch tip without `.git` history
- removes `Docs/Interview` by default so hints and interviewer notes are not exposed
- writes a candidate-facing root `README.md` from the scenario brief
- optionally re-initializes a fresh one-commit git repo

Example:

```powershell
powershell -ExecutionPolicy Bypass -File ".\Build\Scripts\Interview\Prepare-InterviewSnapshot.ps1" `
  -Branch "interview/jr-01-weapon-hit-confirmation" `
  -OutputRoot ".\Saved\InterviewSnapshots" `
  -Force
```

Export every scenario:

```powershell
powershell -ExecutionPolicy Bypass -File ".\Build\Scripts\Interview\Prepare-InterviewSnapshot.ps1" `
  -AllScenarios `
  -OutputRoot ".\Saved\InterviewSnapshots" `
  -Force
```

Useful switches:
- `-NoGitInit`: leaves the snapshot as a plain folder with no git repo
- `-KeepInterviewDocs`: preserves `Docs/Interview` in the snapshot
- `-SnapshotName`: override the single-snapshot folder name
- `-InitialCommitMessage`: change the default `Interview start` initial commit text
