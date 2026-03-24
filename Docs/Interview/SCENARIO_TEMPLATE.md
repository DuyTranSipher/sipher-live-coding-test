# Scenario Template

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-XX` |
| Branch | `interview/jr-xx-name` |
| Duration | `60 minutes` |
| Type | `bug fix`, `editor/data fix`, or `small feature` |
| Systems | `subsystem list` |
| Main proof | `manual proof path` |
| Quick check | `fast reproducible or automated check` |

## Candidate Brief

### Symptom

Describe the issue in user-facing language. Do not reveal the root cause.

### Goal

State the expected end behavior clearly and keep scope narrow.

### Constraints

- prefer a minimal safe fix
- use AI/tools if helpful
- do not rewrite unrelated systems
- be ready to show proof at the end

## Interviewer Setup

### Seed

List the exact seeded code or asset change used to create the scenario.

### Expected Fix Shape

List the minimum change you expect a strong junior to make.

### Likely Search Surface

- code files
- asset types
- test files

### Red Herrings To Ignore

- unrelated files
- tempting but unnecessary refactors

## Verification

### Manual Proof

List the fastest visible before/after proof.

### Quick Check

List a deterministic secondary verification path.

## Hint Ladder

- Hint 1:
- Hint 2:

## Scoring Notes

- What matters most in this scenario
- What deserves partial credit
- What should count as a miss
