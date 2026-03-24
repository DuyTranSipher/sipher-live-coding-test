# JR-07: Add Active Slot Indicator To HUD

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-07` |
| Branch | `interview/jr-07-active-slot-indicator` |
| Duration | `60 minutes` |
| Type | `small feature` |
| Systems | `Equipment`, `HUD`, gameplay messages, widget Blueprint |
| Main proof | HUD shows the active slot correctly on initial spawn, first pickup, slot cycling, and no-active-slot transitions |
| Quick check | indicator responds to the real quick-bar active-index path and initializes from current state rather than only after a future message |

## Candidate Brief

### Symptom

Players can cycle quick-bar slots, but the HUD does not show which slot is currently active. The missing feature is more than a label: it also needs to initialize correctly when the HUD appears, update on first pickup, and reset when no slot is active.

### Goal

Add an active-slot indicator to the existing HUD that behaves correctly across initialization and runtime state changes. Keep it lightweight and aligned with current quick-bar behavior.

### Constraints

- use existing quick-bar data and message flow if possible
- do not build a brand-new UI framework
- a simple text or badge solution is enough, but it must stay correct through lifecycle edge cases

## Interviewer Setup

### Seed

This is a feature branch rather than a broken branch. Start from a clean baseline with no active-slot indicator present in the assigned HUD widget.

### Expected Fix Shape

- Reuse existing quick-bar state such as `GetActiveSlotIndex()` or the active-index gameplay message.
- Add a small HUD element that can both initialize from current state and update as the active slot changes.
- Keep the implementation intentionally small; do not over-design layout or styling.

### Likely Search Surface

- [Source/LyraGame/Equipment/LyraQuickBarComponent.h](/D:/Projects/sipher_test_project/Source/LyraGame/Equipment/LyraQuickBarComponent.h)
- [Source/LyraGame/Equipment/LyraQuickBarComponent.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/Equipment/LyraQuickBarComponent.cpp)
- existing HUD widget Blueprints or CommonUI widgets in `Content/`

### Red Herrings To Ignore

- inventory replication internals
- weapon hit marker widgets
- frontend menu layers

## Verification

### Manual Proof

Show the HUD with the new slot indicator and prove it stays correct on initial load, after the first pickup, while cycling through slots, and after clearing the active slot.

### Quick Check

Demonstrate that the indicator is driven by the real quick-bar active-index path and can initialize from existing state, not only from future UI messages.

## Hint Ladder

- Hint 1: quick-bar already exposes active-slot information, but UI startup timing matters too
- Hint 2: prefer existing messages plus a current-state read over polling unrelated systems

## Scoring Notes

- Strong signal: candidate adds a small, functional indicator that handles lifecycle edge cases with minimal plumbing
- Partial credit: feature works during cycling but fails on initial state or no-active-slot transitions
- Miss: candidate starts redesigning the whole HUD instead of adding the requested indicator
