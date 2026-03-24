# JR-03: Lobby Background Asset Miswired

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-03` |
| Branch | `interview/jr-03-lobby-background` |
| Duration | `60 minutes` |
| Type | `editor/data fix` |
| Systems | `UI/Frontend`, `PrimaryDataAsset`, `editor content` |
| Main proof | frontend menu shows its intended background level again |
| Quick check | the active lobby background asset resolves a valid `BackgroundLevel` reference |

## Candidate Brief

### Symptom

The frontend still loads, but the intended lobby backdrop is gone after a content change. The menu is usable, yet the background presentation is broken.

### Goal

Restore the intended lobby background with the smallest safe change. The menu flow itself should remain untouched.

### Constraints

- treat this as a data-wiring problem first
- avoid rewriting frontend flow code unless the data path proves correct
- be ready to show the relevant asset and the working result in-editor

## Interviewer Setup

### Seed

- In the active `ULyraLobbyBackground` data asset instance, clear or replace `BackgroundLevel` with an invalid asset reference.
- Do not modify [Source/LyraGame/UI/Frontend/LyraFrontendStateComponent.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/UI/Frontend/LyraFrontendStateComponent.cpp) in the default version.

### Expected Fix Shape

- Find the content asset derived from [Source/LyraGame/UI/Frontend/LyraLobbyBackground.h](/D:/Projects/sipher_test_project/Source/LyraGame/UI/Frontend/LyraLobbyBackground.h).
- Restore the correct `BackgroundLevel` reference.
- Confirm the frontend flow still reaches the main screen.

### Likely Search Surface

- [Source/LyraGame/UI/Frontend/LyraLobbyBackground.h](/D:/Projects/sipher_test_project/Source/LyraGame/UI/Frontend/LyraLobbyBackground.h)
- [Source/LyraGame/UI/Frontend/LyraFrontendStateComponent.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/UI/Frontend/LyraFrontendStateComponent.cpp)
- active frontend data assets in `Content/`

### Red Herrings To Ignore

- session join flow
- loading screen state text
- performance setting actions

## Verification

### Manual Proof

Open the frontend flow and show that the expected background world is visible again behind the menu.

### Quick Check

Show the corrected asset reference in the editor and confirm it points to a valid world asset.

## Hint Ladder

- Hint 1: search for `LyraLobbyBackground` before stepping through control-flow code
- Hint 2: the C++ type is only a wrapper; the broken value is likely in content

## Scoring Notes

- Strong signal: candidate tests data first and avoids unnecessary C++ edits
- Partial credit: candidate finds the right asset class but does not fully validate the content reference
- Miss: candidate spends most of the session debugging unrelated frontend flow code
