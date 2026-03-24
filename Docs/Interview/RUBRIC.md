# Shared Rubric

Score each category from `0` to `4`. Default total is `20`.

| Category | 0 | 1 | 2 | 3 | 4 |
| --- | --- | --- | --- | --- | --- |
| Problem framing | cannot reproduce or reason about the issue | guesses without narrowing | reproduces but root cause search is unfocused | isolates likely cause with a reasonable plan | quickly narrows the problem and updates approach based on evidence |
| AI and tool usage | uses tools blindly or unsafely | over-relies on AI output without checking | uses AI for search or draft help but misses validation | uses AI to accelerate investigation and keeps control of decisions | uses AI strategically, validates outputs, and keeps scope tight |
| Unreal fundamentals | does not navigate the relevant systems | recognizes only surface-level classes/assets | finds the right subsystem with help | understands gameplay/UI/editor flow well enough to implement safely | shows clear command of Lyra and Unreal patterns relevant to the task |
| Implementation quality | no meaningful fix or breaks behavior | partial fix with risky side effects | mostly correct but brittle or oversized | correct, minimal, and aligned with local patterns | correct, minimal, and explains tradeoffs or edge cases clearly |
| Verification and communication | no proof and cannot explain status | weak proof or vague summary | reproduces before/after but misses one gap | shows working proof and summarizes what changed | verifies thoughtfully, calls out risks, and communicates crisp next steps |

## Recommended Thresholds

| Total | Meaning |
| --- | --- |
| 17-20 | strong hire signal for junior band |
| 13-16 | viable junior if communication and coachability are solid |
| 9-12 | borderline; inspect hints used and failure mode carefully |
| 0-8 | not ready for this role setup |

## Automatic Downgrades

Apply at least one category reduction if the candidate:

- removes tests or assertions to make the scenario appear fixed
- rewrites broad areas without need
- ships an unverified change and claims completion
- ignores a clear regression introduced by their own fix

## Partial Credit Guidance

- A candidate can still score well without full completion if they:
  - reproduce the issue cleanly
  - identify the likely fix area
  - make a safe partial change
  - explain what remains and how they would verify it
- A candidate should not score well if they:
  - never establish a reliable repro
  - chase unrelated code paths the entire session
  - depend on AI output they do not understand
