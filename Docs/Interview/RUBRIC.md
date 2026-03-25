# Shared Rubric

Score each category from `0` to `4`. Default total is `20`.

| Category | 0 | 1 | 2 | 3 | 4 |
| --- | --- | --- | --- | --- | --- |
| Problem framing | cannot reproduce or group the issue coherently | chases symptoms without narrowing | reproduces the umbrella issue but does not separate source-of-truth boundaries | isolates the highest-value path and rejects at least one wrong lead with evidence | quickly groups symptoms by subsystem, reprioritizes with evidence, and keeps scope disciplined |
| AI prompting and delegation (scored from prompt history) | uses AI blindly or unsafely | issues vague prompts and cannot explain the results | uses AI for search or draft help but prompts are broad or weakly validated | uses targeted prompts, picks suitable agents or tools, and keeps control of decisions | uses AI strategically to decompose the problem, narrow the search surface fast, and reject weak output with evidence |
| Unreal cross-system judgment | does not navigate the relevant systems | recognizes only surface-level classes or assets | finds one relevant subsystem with help | understands gameplay, UI, gameplay ability grant/input/execution paths, config, replication, and test boundaries well enough to make safe progress | shows clear command of the interacting Lyra and Unreal systems the exercise depends on |
| Implementation quality | no meaningful fix or breaks behavior | partial fix with risky side effects | mostly correct on one path but brittle, oversized, or poorly prioritized | correct and well-scoped on the highest-value path | correct, well-prioritized, and preserves the intended contracts across the related systems |
| Verification and communication | no proof and cannot explain status | weak proof or vague summary | proves only one visible symptom or leaves major assumptions unchecked | shows working proof for the chosen fix path and clearly summarizes what remains | verifies across runtime and test evidence, explains accepted and rejected AI output, and communicates crisp next steps |

## Recommended Thresholds

| Total | Meaning |
| --- | --- |
| 17-20 | strong hire signal for this mid-level, AI-forward setup |
| 13-16 | viable signal if prioritization, prompting, and verification are solid |
| 9-12 | borderline; inspect AI usage quality, narrowing speed, and proof quality carefully |
| 0-8 | not ready for this role setup |

## Automatic Downgrades

Apply at least one category reduction if the candidate:

- removes tests or assertions to make the scenario appear fixed
- rewrites broad areas without proving they are on the critical path
- ships an unverified change and claims completion
- shotgun-edits several plausible files without proving state flow or contract ownership
- uses vague AI prompts that generate broad edits with no evidence request
- accepts AI suggestions that they cannot explain or validate
- ignores a clear regression introduced by their own fix
- does not provide prompt history, making AI usage unverifiable

## Partial Credit Guidance

- A candidate can still score well without full completion if they:
  - reproduce the broken experience cleanly
  - identify the highest-value recovery path and reject at least one plausible wrong path with evidence
  - use AI to narrow the problem intentionally
  - make a safe, meaningful change on the primary path
  - explain what remains and how they would verify it
- A candidate should not score well if they:
  - never establish a reliable repro
  - chase unrelated code paths for most of the session
  - depend on AI output they do not understand
  - confuse a visible symptom with proof of the real root cause
  - cannot explain why they chose a given agent, tool, or prompt
