# Repository Guidelines

## Project Structure & Module Organization
This repository is an Unreal Engine 5.7 Lyra project. Put gameplay runtime code in `Source/LyraGame/`, organized by feature area such as `AbilitySystem/`, `UI/`, `Weapons/`, `Inventory/`, and `Teams/`. Keep editor-only code in `Source/LyraEditor/`. Use `Plugins/GameFeatures/` for modular feature packs and plugin-owned tests. Store assets in `Content/` or the owning plugin's `Content/`, and keep engine/project settings in `Config/`. Do not hand-edit generated or cached output in `Binaries/`, `DerivedDataCache/`, or `Intermediate/`.

## Build, Test, and Development Commands
Use Unreal's batch tools against `sipher_test_project.uproject`.

- `Engine\Build\BatchFiles\GenerateProjectFiles.bat -project="D:\Projects\sipher_test_project\sipher_test_project.uproject" -game`
  Regenerates IDE project files.
- `Engine\Build\BatchFiles\Build.bat UnrealEditor Win64 Development -Project="D:\Projects\sipher_test_project\sipher_test_project.uproject"`
  Builds the editor target.
- `Build\BatchFiles\RunLocalTests.bat`
  Runs the repo's UAT BuildGraph test pipeline.
- `Build\BatchFiles\RunLocalPackage.bat`
  Runs a local Win64 packaging flow.

The checked-in batch files still reference `Samples/Games/Lyra` paths, so verify or update those paths before relying on them in this fork.

## Coding Style & Naming Conventions
Match existing Unreal C++ style: tabs for indentation, braces on new lines, PascalCase for types and methods, and Unreal prefixes (`U`, `A`, `F`, `E`, `I`, `T`) for reflected types and templates. Prefix booleans with `b`. Keep files named after the primary class, for example `LyraWeaponInstance.h/.cpp`. No repo-local `.editorconfig` or `.clang-format` was found, so follow neighboring files closely.

## Testing Guidelines
Automation coverage lives in `Source/LyraGame/Tests/` and `Plugins/GameFeatures/ShooterTests/`. Add or update automation tests whenever you change gameplay flow, networking behavior, or editor-integrated systems. Prefer descriptive test names and categories such as `Project.Functional Tests.ShooterTests.*`. No numeric coverage gate was found in this checkout.

## Commit & Pull Request Guidelines
Git history is not available in this workspace snapshot, so no repository-specific commit format could be verified. Use short, imperative commit subjects with a subsystem prefix when helpful, for example `UI: fix lobby background state`. PRs should describe gameplay impact, list test evidence, link the related issue/task, and include screenshots or clips for UI, map, or content changes. Call out any `Config/`, plugin, or asset migration changes explicitly.

## Configuration Tips
Review `Config/*.ini` edits carefully: this project enables multiple online, platform, and game feature plugins, so small config changes can affect packaging and runtime behavior across targets.
