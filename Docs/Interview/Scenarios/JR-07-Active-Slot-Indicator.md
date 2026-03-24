# JR-07: Add Active Slot Indicator To HUD

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-07` |
| Branch | `interview/jr-07-active-slot-indicator` |
| Duration | `60 minutes` |
| Type | `small feature` |
| Systems | `Equipment`, `HUD`, gameplay messages, widget Blueprint |
| Main proof | HUD shows the active slot and updates while cycling |
| Quick check | indicator responds to `Lyra.QuickBar.Message.ActiveIndexChanged` or an equivalent existing update path |

## Candidate Brief

### Symptom

Players can cycle quick-bar slots, but the HUD does not show which slot is currently active.

### Goal

Add a simple active-slot indicator to the existing HUD. Keep it lightweight and aligned with current quick-bar behavior.

### Constraints

- use existing quick-bar data and message flow if possible
- do not build a brand-new UI framework
- a simple text or badge solution is enough

## Interviewer Setup

### Seed

This is a feature branch rather than a broken branch. Start from a clean baseline with no active-slot indicator present in the assigned HUD widget.

### Expected Fix Shape

- Reuse existing quick-bar state such as `GetActiveSlotIndex()` or the active-index gameplay message.
- Add a small HUD element that updates as the active slot changes.
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

Show the HUD with the new slot indicator and cycle through available slots so the visible active value updates correctly.

### Quick Check

Demonstrate that the indicator is driven by the real quick-bar active-index path, not by hardcoded UI state.

## Hint Ladder

- Hint 1: quick-bar already exposes active-slot information
- Hint 2: prefer existing messages and getters over polling unrelated systems

## Scoring Notes

- Strong signal: candidate adds a small, functional indicator with minimal plumbing
- Partial credit: feature works but is overly coupled or under-verified
- Miss: candidate starts redesigning the whole HUD instead of adding the requested indicator
