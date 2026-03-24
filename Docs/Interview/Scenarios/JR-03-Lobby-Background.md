# JR-03: Lobby Background Asset Miswired

## Metadata

| Field | Value |
| --- | --- |
| ID | `JR-03` |
| Branch | `interview/jr-03-lobby-background` |
| Duration | `60 minutes` |
| Type | `editor/data fix` |
| Systems | `UI/Frontend`, `AssetManager`, `PrimaryDataAsset`, `editor content` |
| Main proof | frontend menu shows its intended background level again |
| Quick check | the project once again discovers `LyraLobbyBackground` assets and resolves a valid `BackgroundLevel` reference |

## Candidate Brief

### Symptom

The frontend still loads, but the intended lobby backdrop is gone after an asset-management change. The menu is usable, yet the background presentation is broken because the frontend no longer discovers the expected background assets.

### Goal

Restore the intended lobby background with the smallest safe change. The menu flow itself should remain untouched, and the fix should restore the intended asset discovery path rather than masking the symptom locally.

### Constraints

- treat this as an asset-discovery or data-wiring problem first
- avoid rewriting frontend flow code unless the data path proves correct
- be ready to show the relevant asset and the working result in-editor

## Interviewer Setup

### Seed

- Misconfigure the `LyraLobbyBackground` asset-manager scan in [Config/DefaultGame.ini](/D:/Projects/sipher_test_project/Config/DefaultGame.ini) so the frontend background loader finds no valid lobby background assets.
- Do not modify [Source/LyraGame/UI/Frontend/LyraFrontendStateComponent.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/UI/Frontend/LyraFrontendStateComponent.cpp) in the prepared branch.

### Expected Fix Shape

- Trace how the frontend discovers and loads `ULyraLobbyBackground` assets.
- Restore the correct asset-manager discovery configuration.
- Confirm the loader again resolves a valid background asset and the frontend still reaches the main screen.

### Likely Search Surface

- [Config/DefaultGame.ini](/D:/Projects/sipher_test_project/Config/DefaultGame.ini)
- [Source/LyraGame/UI/Frontend/LyraLobbyBackground.h](/D:/Projects/sipher_test_project/Source/LyraGame/UI/Frontend/LyraLobbyBackground.h)
- [Source/LyraGame/UI/Frontend/LyraFrontendStateComponent.cpp](/D:/Projects/sipher_test_project/Source/LyraGame/UI/Frontend/LyraFrontendStateComponent.cpp)
- [B_LoadRandomLobbyBackground.uasset](/D:/Projects/sipher_test_project/Content/Environments/B_LoadRandomLobbyBackground.uasset)

### Red Herrings To Ignore

- session join flow
- loading screen state text
- performance setting actions

## Verification

### Manual Proof

Open the frontend flow and show that the expected background world is visible again behind the menu.

### Quick Check

Show that `LyraLobbyBackground` assets are discovered again and confirm the active background asset points to a valid world asset.

## Hint Ladder

- Hint 1: search for `LyraLobbyBackground` before stepping through control-flow code
- Hint 2: check how the asset type is registered and discovered before editing the frontend Blueprint

## Scoring Notes

- Strong signal: candidate inspects AssetManager or data discovery first and avoids unnecessary C++ edits
- Partial credit: candidate finds the right asset class but does not fully validate why discovery broke
- Miss: candidate spends most of the session debugging unrelated frontend flow code
