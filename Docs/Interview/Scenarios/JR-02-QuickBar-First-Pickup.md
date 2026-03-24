# JR-02: Quick Bar First Pickup Does Not Auto-Equip

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-02` |
| Branch | `interview/jr-02-quickbar-first-pickup` |
| Duration | `60 minutes` |
| Type | `bug fix / state-flow repair` |
| Systems | `Equipment`, `Inventory`, `GameplayMessageRuntime`, `HUD state` |
| Main proof | first picked-up weapon becomes truly active and usable without manual slot cycling |
| Quick check | verify the normal active-slot path still drives equip behavior and both quick-bar messages |

## Candidate Brief

### Symptom

When the player picks up their first quick-bar item in a fresh run, the item now looks selected in the quick bar, but the real active/equipped state is still wrong until the player manually cycles slots.

### Goal

Make the first valid quick-bar pickup become the real active slot automatically while keeping later slot behavior unchanged and preserving the intended replication/message path.

### Constraints

- keep the fix narrow to quick-bar state and equipment flow
- do not redesign slot cycling
- be ready to explain any broadcast, equip, or replication side effects

## Interviewer Setup

### Seed

Partially implement first-slot activation in [Source/LyraGame/Equipment/LyraQuickBarComponent.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/Equipment/LyraQuickBarComponent.cpp) by mutating `ActiveSlotIndex` directly when the first item is added, while leaving the normal `SetActiveSlotIndex` path bypassed.

### Expected Fix Shape

- Detect the case where a newly added slot is the first usable item and no active slot is set.
- Route the change through the normal activation path instead of writing active state directly.
- Preserve equip behavior plus `OnRep_Slots` and `OnRep_ActiveSlotIndex` semantics.

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

Verify that the quick-bar still equips the item and emits both slot and active-index change messages when the first item is added.

## Hint Ladder

- Hint 1: inspect what happens when `ActiveSlotIndex` changes during add-item flow
- Hint 2: if state looks half-updated, compare the direct field mutation path against `SetActiveSlotIndex`

## Scoring Notes

- Strong signal: candidate preserves the existing activation path and does not special-case equip work unnecessarily
- Partial credit: item equips but active-index or message behavior is still incomplete
- Miss: candidate hardcodes slot `0`, duplicates equip logic, or leaves the system in a half-selected state
