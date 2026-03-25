# Scenario Template

Use this template for AI-forward V3 scenarios that present one believable broken product state across several interacting systems. The candidate brief should describe the broken experience in user-facing language, force prioritization, and reward candidates who use AI agents well enough to narrow the search surface and verify the resulting fixes.

## Metadata

| Field | Value |
| --- | --- |
| ID | `MASTER` or `XX-H0X` |
| Branch | `interview-master` or `interview/<name>` |
| Duration | `90 minutes` |
| Type | `cross-system recovery`, `AI-orchestrated debugging`, or similar |
| Systems | `at least three interacting subsystems` |
| Main proof | `primary end-to-end proof for the scenario` |
| Quick check | `targeted validation proving the chosen fix path is real` |

## Candidate Brief

### Symptom

Describe one umbrella broken experience in user-facing language. Mention the visible consequences, but do not reveal hidden file names or the intended fix order.

### Goal

State the expected end behavior clearly. Full completion should require several coordinated fixes, but the highest-value path should still be recognizable and scoreable if time runs out.

### Constraints

- use AI agents or tools deliberately
- prefer prompts that ask for boundaries, source of truth, and evidence
- validate AI output before broad edits
- avoid rewriting unrelated systems
- be ready to show proof at the end
- be ready to explain what remains if one thread is unfinished

## Interviewer Setup

### Seed

List the exact seeded code, config, or asset changes used to create the scenario.

### Expected Fix Shape

List the minimum change you expect on the highest-value path, plus what a full completion would also cover.

### Expected AI Workflow

- where targeted prompting should help
- which searches or agents should narrow the problem fastest
- what evidence a strong candidate should request before editing

### Likely Search Surface

- subsystem boundaries
- state transitions
- config or data contracts
- test or replication evidence surfaces

### Red Herrings To Ignore

- cosmetic fixes that hide the issue
- broad rewrites that do not explain the state break
- single-file patches that do not restore the shared contract

## Verification

### Manual Proof

List the fastest visible proof for the primary recovery path.

### Quick Check

List a deterministic secondary validation path that proves the chosen fix path is real and not just cosmetic.

## Hint Ladder

- Hint 1: subsystem grouping or ownership boundary
- Hint 2: AI workflow or evidence redirection
- Hint 3: prioritization toward the highest-value unfinished path

## Scoring Notes

- What matters most in this scenario
- What deserves partial credit when only the primary path is completed
- What should count as a miss
