# JR-02: Quick Bar First Pickup Does Not Auto-Equip

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-02` |
| Branch | `interview/jr-02-quickbar-first-pickup` |
| Duration | `60 minutes` |
| Type | `bug fix / small feature` |
| Systems | `Equipment`, `Inventory`, `GameplayMessageRuntime` |
| Main proof | first picked-up weapon equips without requiring slot cycling |
| Quick check | verify both slot and active-index messages still fire correctly |

## Candidate Brief

### Symptom

When the player picks up their first quick-bar item in a fresh run, the item appears in the bar but is not immediately usable until the player manually cycles slots.

### Goal

Make the first valid quick-bar pickup become the active slot automatically while keeping later slot behavior unchanged.

### Constraints

- keep the fix narrow to quick-bar state and equipment flow
- do not redesign slot cycling
- be ready to explain any broadcast or replication side effects

## Interviewer Setup

### Seed

Use the current behavior in [Source/LyraGame/Equipment/LyraQuickBarComponent.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/Equipment/LyraQuickBarComponent.cpp) as the scenario, or reinforce it by removing any existing auto-select path in your prepared branch.

### Expected Fix Shape

- Detect the case where a newly added slot is the first usable item and no active slot is set.
- Promote that slot to the active slot through the normal path instead of equipping ad hoc.
- Preserve `OnRep_Slots` and `OnRep_ActiveSlotIndex` behavior.

### Likely Search Surface

- [Source/LyraGame/Equipment/LyraQuickBarComponent.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/Equipment/LyraQuickBarComponent.cpp)
- [Source/LyraGame/Equipment/LyraQuickBarComponent.h](/D:/Projects/sipher_test_project/Source/LyraGame/Equipment/LyraQuickBarComponent.h)

### Red Herrings To Ignore

- inventory replication internals
- weapon instance UI code
- broad input rebinding

## Verification

### Manual Proof

Start from a state with no equipped quick-bar item, pick up the first weapon, and show that it equips and becomes immediately usable without cycling.

### Quick Check

Verify that the quick-bar still emits both slot and active-index change messages when the first item is added.

## Hint Ladder

- Hint 1: inspect what happens when `ActiveSlotIndex` is still `-1`
- Hint 2: use the existing `SetActiveSlotIndex` path instead of duplicating equip logic

## Scoring Notes

- Strong signal: candidate preserves message flow and does not special-case the equip path unnecessarily
- Partial credit: item equips but active-index or message behavior is incomplete
- Miss: candidate hardcodes slot `0` everywhere or bypasses the intended quick-bar path
