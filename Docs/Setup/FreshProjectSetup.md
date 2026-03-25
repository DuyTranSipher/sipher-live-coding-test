# Fresh Project Setup

This guide documents how to bring `sipher_livecoding_test` up on a clean Windows machine and how to reuse the same structure in another fresh Unreal project.

## What this repository contains

- `Source/`
  Runtime and editor C++ modules for the Lyra-based game.
- `Plugins/GameFeatures/`
  Modular game feature plugins such as `ShooterCore`, `ShooterMaps`, `ShooterExplorer`, `ShooterTests`, and `TopDownArena`.
- `Config/`
  Project, platform, and localization settings.
- `Content/`
  Project-owned assets.
- `Build/BatchFiles/`
  Windows entrypoints for setup, testing, packaging, and localization helpers.
- `Docs/Interview/`
  Interview scenario workflow and snapshot export tooling.

Do not copy generated folders into a fresh project:

- `Binaries/`
- `DerivedDataCache/`
- `Intermediate/`
- `Saved/`

## Clean machine prerequisites

Install these before cloning or opening the project:

1. Unreal Engine 5.7
   Use a local engine install and set `UE_ROOT` to that folder, for example `D:\UE_5.7`.
2. Visual Studio 2022 or JetBrains Rider
   Include the C++ desktop/game development workloads required by Unreal.
3. Git and Git LFS
   This repo tracks Unreal assets and common art formats through LFS.

Recommended environment variable:

```bat
setx UE_ROOT "D:\UE_5.7"
```

Open a new terminal after setting it.

## Clone and bootstrap this repository

```bat
git clone <your-remote-url> D:\Projects\sipher_livecoding_test
cd /d D:\Projects\sipher_livecoding_test
Build\BatchFiles\SetupProject.bat
```

What `SetupProject.bat` does:

- validates `UE_ROOT` or the engine path you pass in
- runs `git lfs install`
- runs `git lfs pull`
- regenerates project files for `sipher_livecoding_test.uproject`

Optional editor build:

```bat
Build\BatchFiles\SetupProject.bat -BuildEditor
```

Or call Unreal directly:

```bat
"%UE_ROOT%\Engine\Build\BatchFiles\Build.bat" UnrealEditor Win64 Development -Project="D:\Projects\sipher_livecoding_test\sipher_livecoding_test.uproject"
```

## Create a working branch

This repo currently has `main`, the primary `interview-master` exercise branch, and the legacy `interview/*` branches. For normal feature work, keep the naming simple and explicit:

- `feature/<topic>`
- `fix/<topic>`
- `chore/<topic>`
- `interview/<scenario-name>` for candidate scenario branches

Current interview branches in this repo are:

- `interview-master`
- `interview/jr-h01-combat-onboarding-state`
- `interview/jr-h02-frontend-presentation-state`
- `interview/jr-h03-gameplay-presentation-parity`
- `interview/jr-h04-feedback-and-coverage`

Create a branch from the current `HEAD`:

```bat
Build\BatchFiles\CreateBranch.bat fix/reticle-state
```

Create a branch from `main`:

```bat
Build\BatchFiles\CreateBranch.bat feature/new-onboarding main
```

## First open checklist

After bootstrapping:

1. Open `sipher_livecoding_test.uproject`.
2. Let the editor rebuild modules if prompted.
3. Wait for shaders and asset discovery to settle.
4. Confirm that the expected game feature plugins are enabled:
   - `ShooterCore`
   - `ShooterMaps`
   - `ShooterExplorer`
   - `ShooterTests`
   - `TopDownArena`
5. Verify that LFS-backed assets resolved correctly. Missing meshes, maps, or textures usually mean LFS was not pulled.

## Test scenarios

### Fast setup validation

Use this after a fresh clone to make sure the machine can load the project:

1. Generate project files with `SetupProject.bat`.
2. Open the editor successfully.
3. Load a known project map from the Lyra-derived content set.
4. Confirm plugins mount without missing-content errors.

### Automation tests available in this repo

The main documented automated coverage lives in `Plugins/GameFeatures/ShooterTests/README.md`.

Known CQTest categories:

- `Project.Functional Tests.ShooterTests.Actor.Animation`
- `Project.Functional Tests.ShooterTests.Actor.Replication`
- `Project.Functional Tests.ShooterTests.GameplayAbility`

Known Blueprint functional tests:

- `L_ShooterTest_Autorun`
- `L_ShooterTest_FireWeapon`

Run the default shooter test suite from the command line:

```bat
Build\BatchFiles\RunLocalTests.bat
```

This default wrapper targets the CQTest categories under `Project.Functional Tests.ShooterTests`. The Blueprint functional tests are better run from the editor automation UI.

Run a narrower filter:

```bat
Build\BatchFiles\RunLocalTests.bat -TestFilter "Project.Functional Tests.ShooterTests.GameplayAbility"
```

Run tests from the editor:

1. Open `Window -> Developer Tools -> Session Frontend`.
2. Go to `Automation`.
3. Search for `ShooterTests`.
4. Run the relevant CQTests or Blueprint functional tests.

### Manual smoke scenarios worth keeping

These are the highest-signal checks after setup or when copying the structure into another project:

1. Editor boot
   Project opens without missing modules, missing plugins, or mass asset load failures.
2. Frontend/map load
   A playable map loads and the Lyra experience initializes.
3. Input and weapon flow
   Player can spawn, move, crouch, fire, and switch equipment.
4. Game feature mounting
   `ShooterCore`, `ShooterMaps`, and related plugins activate correctly.
5. Packaging sanity
   `RunLocalPackage.bat` completes a Win64 package.

## Interview scenario workflow

The interview pack in this repo is centered on the broader `interview-master` exercise documented in `Docs/Interview/`, with the older narrow scenarios kept as calibration branches.

Current scenario index:

- `MASTER`: cross-system AI recovery
- `JR-H01`: combat onboarding state
- `JR-H02`: frontend presentation state
- `JR-H03`: gameplay presentation parity
- `JR-H04`: feedback and coverage batch

Use the repo-root wrapper to export a candidate-safe snapshot:

```bat
Prepare-InterviewSnapshot.bat -Branch "interview-master" -OutputRoot ".\Saved\InterviewSnapshots" -Force
```

Useful snapshot options:

- `-AllScenarios`
  export one snapshot folder per hard-mode scenario
- `-GenerateProjectFiles`
  generate Unreal project files inside the exported snapshot so it can open directly in Rider or Visual Studio
- `-NoGitInit`
  leave the snapshot as a plain folder with no fresh git repo
- `-KeepInterviewDocs`
  keep the private `Docs/Interview` authoring material in the export

Snapshot behavior worth knowing:

1. The exporter reads scenario metadata from the Markdown docs in `Docs/Interview/Scenarios`.
2. It writes a candidate-facing root `README.md` from that scenario metadata.
3. It strips `Docs/Interview` by default so internal notes are not exposed.
4. It can handle Windows-authored CRLF Markdown docs correctly when parsing scenario metadata.

## Packaging commands

Package the default Win64 target:

```bat
Build\BatchFiles\RunLocalPackage.bat
```

Package the EOS target:

```bat
Build\BatchFiles\RunLocalPackage_EOS.bat
```

Both scripts accept:

- first argument: Unreal Engine root, if `UE_ROOT` is not already set
- second argument: archive output directory

Example:

```bat
Build\BatchFiles\RunLocalPackage.bat "D:\UE_5.7" "D:\Builds\sipher_livecoding_test\Win64"
```

## Localization helper

`Build\BatchFiles\RunLocalize.bat` is a project-aware wrapper, but it still requires provider credentials to be supplied through environment variables. Use it only after deciding on a provider such as `Crowdin_Sample`, `XLoc_Sample`, or `Smartling_Sample`.

## Reusing this structure in another fresh Unreal project

If you want to copy this repo's setup into a different project, carry over these pieces deliberately:

1. Project layout
   Recreate `Source/`, `Plugins/GameFeatures/`, `Config/`, `Content/`, `Build/`, and `Docs/`.
2. Git baseline
   Copy `.gitignore` and `.gitattributes`, especially the LFS rules for Unreal assets.
3. Batch tooling
   Copy the scripts in `Build/BatchFiles/`, then update:
   - `PROJECT_NAME`
   - `.uproject` filename
   - package targets such as `LyraGame` or `LyraGameEOS`
4. Unreal modules and targets
   Rename target files and module names under `Source/` to match the new project if you want a full rebrand. This repo intentionally keeps `LyraGame` and `LyraEditor`.
5. Plugin references
   Update the `.uproject` plugin list to match the new project's feature set.
6. Config namespaces
   Review `Config/*.ini` for project name, paths, online subsystem, and platform assumptions.
7. BuildGraph and custom automation
   The checked-in C# automation and `Build\LyraTests.xml` still contain inherited Lyra assumptions. Treat them as examples unless you fully rework them for the new project's root path and CI model.
8. Interview snapshot tooling
   If you copy the interview pack to another repo, also copy `Prepare-InterviewSnapshot.bat`, `Build\Scripts\Interview\Prepare-InterviewSnapshot.ps1`, and the scenario docs together. The exporter depends on the scenario Markdown metadata and branch naming staying aligned.

## Known caveats

- The `.uproject` uses engine association `5.7`. On a fresh machine, the batch scripts are safer than relying on local launcher associations alone.
- The local packaging and test wrappers are designed for direct project use, not the old in-engine `Samples/Games/Lyra` layout.
- The batch scripts preserve the current target names `LyraGame`, `LyraGameEOS`, and `LyraEditor` because those are the active build targets in this repo.
