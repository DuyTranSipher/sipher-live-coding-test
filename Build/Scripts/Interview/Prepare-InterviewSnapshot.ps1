param(
	[string]$Branch,

	[switch]$AllScenarios,
	[switch]$Help,
	[switch]$ListScenarios,
	[switch]$GenerateProjectFiles,

	[string]$OutputRoot = ".\Saved\InterviewSnapshots",
	[string]$SnapshotName,
	[string]$InitialCommitMessage = "Interview start",
	[switch]$NoGitInit,
	[switch]$KeepInterviewDocs,
	[switch]$Force
)

$ErrorActionPreference = "Stop"

function Show-Usage {
	$Lines = @(
		"Usage:",
		"  Prepare-InterviewSnapshot.bat -Branch <branch-name> [options]",
		"  Prepare-InterviewSnapshot.bat -AllScenarios [options]",
		"",
		"Required:",
		"  Choose exactly one of:",
		"    -Branch <branch-name>",
		"    -AllScenarios",
		"",
		"Common options:",
		"  -OutputRoot <path>",
		"  -SnapshotName <name>",
		"  -InitialCommitMessage <message>",
		"  -GenerateProjectFiles",
		"  -NoGitInit",
		"  -KeepInterviewDocs",
		"  -Force",
		"",
		"Examples:",
		"  Prepare-InterviewSnapshot.bat -Branch ""interview/jr-01-weapon-hit-confirmation"" -GenerateProjectFiles -Force",
		"  Prepare-InterviewSnapshot.bat -AllScenarios -OutputRoot "".\\Saved\\InterviewSnapshots"" -Force"
	)

	Write-Host ($Lines -join "`r`n")
}

function Write-Step {
	param([string]$Message)

	Write-Host ""
	Write-Host ("==> {0}" -f $Message) -ForegroundColor Cyan
}

function Write-Detail {
	param([string]$Message)

	Write-Host ("    {0}" -f $Message) -ForegroundColor DarkGray
}

function Get-RepoRoot {
	return (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
}

function Resolve-RepoPath {
	param(
		[string]$Path,
		[string]$RepoRoot
	)

	if ([System.IO.Path]::IsPathRooted($Path)) {
		return $Path
	}

	return (Join-Path $RepoRoot $Path)
}

function Assert-GitRefExists {
	param(
		[string]$RepoRoot,
		[string]$RefName
	)

	$null = & git -C $RepoRoot rev-parse --verify "$RefName^{commit}" 2>$null
	if ($LASTEXITCODE -ne 0) {
		throw "Git ref '$RefName' was not found."
	}
}

function Get-ProjectFilePath {
	param([string]$ProjectRoot)

	$ProjectFiles = Get-ChildItem -Path $ProjectRoot -Filter "*.uproject" -File
	if ($ProjectFiles.Count -eq 0) {
		throw "No .uproject file was found in '$ProjectRoot'."
	}

	if ($ProjectFiles.Count -gt 1) {
		throw "Multiple .uproject files were found in '$ProjectRoot'. Unable to determine which one to generate."
	}

	return $ProjectFiles[0].FullName
}

function Get-LauncherInstallRoot {
	param([string]$EngineAssociation)

	$RegistryPaths = @(
		"HKLM:\SOFTWARE\EpicGames\Unreal Engine\$EngineAssociation",
		"HKLM:\SOFTWARE\WOW6432Node\EpicGames\Unreal Engine\$EngineAssociation"
	)

	foreach ($RegistryPath in $RegistryPaths) {
		if (-not (Test-Path -Path $RegistryPath)) {
			continue
		}

		$InstalledDirectory = (Get-ItemProperty -Path $RegistryPath -ErrorAction SilentlyContinue).InstalledDirectory
		if (-not [string]::IsNullOrWhiteSpace($InstalledDirectory) -and (Test-Path -Path $InstalledDirectory)) {
			return $InstalledDirectory
		}
	}

	return $null
}

function Resolve-EngineRootFromAssociation {
	param([string]$EngineAssociation)

	if ([string]::IsNullOrWhiteSpace($EngineAssociation)) {
		return $null
	}

	if ([System.IO.Path]::IsPathRooted($EngineAssociation) -and (Test-Path -Path $EngineAssociation)) {
		return $EngineAssociation
	}

	$BuildsKey = "HKCU:\Software\Epic Games\Unreal Engine\Builds"
	if (Test-Path -Path $BuildsKey) {
		$BuildValues = (Get-ItemProperty -Path $BuildsKey).PSObject.Properties |
			Where-Object { $_.Name -notmatch '^PS' }
		foreach ($BuildValue in $BuildValues) {
			if ($BuildValue.Name -eq $EngineAssociation -and (Test-Path -Path $BuildValue.Value)) {
				return $BuildValue.Value
			}
		}
	}

	return Get-LauncherInstallRoot -EngineAssociation $EngineAssociation
}

function Get-UnrealVersionSelectorPath {
	$Candidates = @(
		(Join-Path ${env:ProgramFiles(x86)} "Epic Games\Launcher\Engine\Binaries\Win64\UnrealVersionSelector.exe"),
		(Join-Path $env:ProgramFiles "Epic Games\Launcher\Engine\Binaries\Win64\UnrealVersionSelector.exe")
	)

	foreach ($Candidate in $Candidates) {
		if (-not [string]::IsNullOrWhiteSpace($Candidate) -and (Test-Path -Path $Candidate)) {
			return $Candidate
		}
	}

	return $null
}

function Get-GenerateProjectFilesPath {
	param([string]$ResolvedEnginePath)

	if ([string]::IsNullOrWhiteSpace($ResolvedEnginePath)) {
		return $null
	}

	$BasePath = [System.IO.Path]::GetFullPath($ResolvedEnginePath)
	$ParentPath = Split-Path -Path $BasePath -Parent
	$GrandParentPath = if ($ParentPath) { Split-Path -Path $ParentPath -Parent } else { $null }

	$Candidates = @(
		(Join-Path $BasePath "Engine\Build\BatchFiles\GenerateProjectFiles.bat"),
		(Join-Path $BasePath "Build\BatchFiles\GenerateProjectFiles.bat")
	)

	if ($ParentPath) {
		$Candidates += Join-Path $ParentPath "Build\BatchFiles\GenerateProjectFiles.bat"
		$Candidates += Join-Path $ParentPath "Engine\Build\BatchFiles\GenerateProjectFiles.bat"
	}

	if ($GrandParentPath) {
		$Candidates += Join-Path $GrandParentPath "Engine\Build\BatchFiles\GenerateProjectFiles.bat"
	}

	$Candidates = $Candidates | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

	foreach ($Candidate in $Candidates) {
		if (Test-Path -Path $Candidate) {
			return $Candidate
		}
	}

	return $null
}

function Invoke-ProjectFileGeneration {
	param(
		[string]$ProjectRoot,
		[string]$StepLabel
	)

	$ProjectFilePath = Get-ProjectFilePath -ProjectRoot $ProjectRoot
	$ProjectDescriptor = Get-Content -Path $ProjectFilePath -Raw | ConvertFrom-Json
	$EngineAssociation = $ProjectDescriptor.EngineAssociation

	Write-Step ("{0}: Generate Unreal project files" -f $StepLabel)
	Write-Detail ("Project: {0}" -f [System.IO.Path]::GetFileName($ProjectFilePath))
	Write-Detail "This step can take a while. Unreal output will stream below."

	$EngineRoot = Resolve-EngineRootFromAssociation -EngineAssociation $EngineAssociation
	if ($EngineRoot) {
		$GenerateProjectFilesPath = Get-GenerateProjectFilesPath -ResolvedEnginePath $EngineRoot
		if ($GenerateProjectFilesPath) {
			Write-Detail ("Using GenerateProjectFiles.bat: {0}" -f $GenerateProjectFilesPath)
			& $GenerateProjectFilesPath "-project=$ProjectFilePath" -game
			if ($LASTEXITCODE -ne 0) {
				throw "GenerateProjectFiles.bat failed for '$ProjectFilePath'."
			}

			Write-Detail "Unreal project metadata generated successfully"
			return
		}
	}

	$UnrealVersionSelectorPath = Get-UnrealVersionSelectorPath
	if ($UnrealVersionSelectorPath) {
		Write-Detail ("Falling back to UnrealVersionSelector: {0}" -f $UnrealVersionSelectorPath)
		& $UnrealVersionSelectorPath /projectfiles $ProjectFilePath
		if ($LASTEXITCODE -ne 0) {
			throw "UnrealVersionSelector failed for '$ProjectFilePath'."
		}

		Write-Detail "Unreal project metadata generated successfully"
		return
	}

	throw "Could not resolve an Unreal Engine installation for EngineAssociation '$EngineAssociation'."
}

function Get-MarkdownSection {
	param(
		[string]$Content,
		[string]$Heading
	)

	$Pattern = "(?ms)^###\s+$([regex]::Escape($Heading))\s*\r?\n(.*?)(?=^\s*###\s+|^\s*##\s+|\z)"
	$Match = [regex]::Match($Content, $Pattern)
	if (-not $Match.Success) {
		return $null
	}

	return $Match.Groups[1].Value.Trim()
}

function Get-ScenarioMetadataValue {
	param(
		[string]$Content,
		[string]$FieldName
	)

	$Pattern = "(?m)^\|\s*$([regex]::Escape($FieldName))\s*\|\s*(.*?)\s*\|$"
	$Match = [regex]::Match($Content, $Pattern)
	if (-not $Match.Success) {
		return $null
	}

	return $Match.Groups[1].Value.Trim()
}

function Get-MarkdownTitle {
	param([string]$Content)

	$Match = [regex]::Match($Content, '(?m)^#\s+(.*)$')
	if (-not $Match.Success) {
		return $null
	}

	return $Match.Groups[1].Value.Trim()
}

function Normalize-ScenarioValue {
	param([string]$Value)

	if ($null -eq $Value) {
		return $null
	}

	return ($Value.Trim() -replace '^`+|`+$', '')
}

function Convert-MarkdownListToArray {
	param([string]$SectionContent)

	if (-not $SectionContent) {
		return @()
	}

	$Lines = $SectionContent -split "\r?\n"
	$Items = @()
	foreach ($Line in $Lines) {
		$Trimmed = $Line.Trim()
		if ($Trimmed -match '^-+\s+(.*)$') {
			$Items += $Matches[1].Trim()
		}
	}

	if ($Items.Count -gt 0) {
		return $Items
	}

	return @($SectionContent.Trim())
}

function Get-ScenarioList {
	param([string]$RepoRoot)

	$ScenarioDocsPath = Join-Path $RepoRoot "Docs\Interview\Scenarios"
	if (-not (Test-Path -Path $ScenarioDocsPath)) {
		return @()
	}

	$ScenarioDocs = Get-ChildItem -Path $ScenarioDocsPath -Filter "*.md" -File | Sort-Object Name
	$Scenarios = @()
	foreach ($Doc in $ScenarioDocs) {
		$Content = Get-Content -Path $Doc.FullName -Raw
		$Scenarios += [pscustomobject]@{
			Id = Normalize-ScenarioValue -Value (Get-ScenarioMetadataValue -Content $Content -FieldName "ID")
			Branch = Normalize-ScenarioValue -Value (Get-ScenarioMetadataValue -Content $Content -FieldName "Branch")
			Title = Get-MarkdownTitle -Content $Content
			Path = $Doc.FullName
		}
	}

	return $Scenarios
}

function Get-ScenarioDocInfo {
	param(
		[string]$RepoRoot,
		[string]$BranchName
	)

	$ScenarioFiles = Get-ScenarioList -RepoRoot $RepoRoot
	foreach ($File in $ScenarioFiles) {
		$Content = Get-Content -Path $File.Path -Raw
		$BranchValue = Get-ScenarioMetadataValue -Content $Content -FieldName "Branch"
		if ($null -eq $BranchValue) {
			continue
		}

		$NormalizedBranchValue = Normalize-ScenarioValue -Value $BranchValue
		if ($NormalizedBranchValue -eq $BranchName) {
			return [pscustomobject]@{
				Path = $File.FullName
				Content = $Content
				Id = Normalize-ScenarioValue -Value (Get-ScenarioMetadataValue -Content $Content -FieldName "ID")
				Duration = Normalize-ScenarioValue -Value (Get-ScenarioMetadataValue -Content $Content -FieldName "Duration")
				Type = Normalize-ScenarioValue -Value (Get-ScenarioMetadataValue -Content $Content -FieldName "Type")
				Systems = Normalize-ScenarioValue -Value (Get-ScenarioMetadataValue -Content $Content -FieldName "Systems")
				MainProof = Normalize-ScenarioValue -Value (Get-ScenarioMetadataValue -Content $Content -FieldName "Main proof")
				QuickCheck = Normalize-ScenarioValue -Value (Get-ScenarioMetadataValue -Content $Content -FieldName "Quick check")
				Symptom = Get-MarkdownSection -Content $Content -Heading "Symptom"
				Goal = Get-MarkdownSection -Content $Content -Heading "Goal"
				Constraints = Convert-MarkdownListToArray -SectionContent (Get-MarkdownSection -Content $Content -Heading "Constraints")
				ManualProof = Get-MarkdownSection -Content $Content -Heading "Manual Proof"
			}
		}
	}

	throw "No scenario document was found for branch '$BranchName'."
}

function Get-SnapshotFolderName {
	param(
		[string]$BranchName,
		[string]$OverrideName
	)

	if ($OverrideName) {
		return $OverrideName
	}

	return $BranchName.Replace("/", "-")
}

function New-CandidateReadme {
	param(
		[pscustomobject]$Scenario
	)

	$ManualProof = $Scenario.ManualProof
	if (-not $ManualProof) {
		$ManualProof = "Verify the issue in-editor or in the fastest available local workflow."
	}

	$Lines = @(
		"# Interview Task",
		"",
		"This project contains one prepared issue to investigate and fix.",
		"",
		"| Field | Value |",
		"| --- | --- |",
		"| ID | ``$($Scenario.Id)`` |",
		"| Duration | ``$($Scenario.Duration)`` |",
		"| Type | ``$($Scenario.Type)`` |",
		"| Systems | ``$($Scenario.Systems)`` |",
		"",
		"## Problem",
		"",
		$Scenario.Symptom,
		"",
		"## Goal",
		"",
		$Scenario.Goal,
		"",
		"## Constraints",
		""
	)

	foreach ($Constraint in $Scenario.Constraints) {
		$Lines += "- $Constraint"
	}

	$Lines += @(
		"",
		"## Acceptance",
		"",
		"- Main proof: $($Scenario.MainProof)",
		"- Quick check: $($Scenario.QuickCheck)",
		"",
		"## What To Hand Back",
		"",
		"- The code or content change needed to resolve the issue.",
		"- A short summary of the root cause and your fix.",
		"- A brief note on how you verified the result.",
		"",
		"## Suggested Approach",
		"",
		"- Reproduce the problem first.",
		"- Keep the fix as small and safe as possible.",
		"- Prefer proving the root cause before broad edits.",
		"",
		"## Manual Verification Target",
		"",
		$ManualProof
	)

	return ($Lines -join "`r`n") + "`r`n"
}

function Export-BranchSnapshot {
	param(
		[string]$RepoRoot,
		[string]$BranchName,
		[string]$DestinationPath,
		[string]$InitialCommitMessage,
		[bool]$ShouldInitGit,
		[bool]$ShouldKeepInterviewDocs,
		[bool]$ShouldGenerateProjectFiles
	)

	Write-Step ("Preparing snapshot for {0}" -f $BranchName)
	Write-Detail ("Destination: {0}" -f $DestinationPath)

	Assert-GitRefExists -RepoRoot $RepoRoot -RefName $BranchName
	$Scenario = Get-ScenarioDocInfo -RepoRoot $RepoRoot -BranchName $BranchName
	$StepIndex = 0
	$TotalSteps = 5
	if ($ShouldGenerateProjectFiles) {
		$TotalSteps += 1
	}

	if ($ShouldInitGit) {
		$TotalSteps += 1
	}

	if (Test-Path -Path $DestinationPath) {
		if (-not $Force) {
			throw "Destination already exists: $DestinationPath. Use -Force to replace it."
		}

		Write-Detail "Removing existing destination folder"
		Remove-Item -Path $DestinationPath -Recurse -Force
	}

	New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null

	$TempTar = Join-Path ([System.IO.Path]::GetTempPath()) ("interview_snapshot_" + [guid]::NewGuid().ToString("N") + ".tar")
	try {
		$StepIndex += 1
		Write-Step ("Step {0}/{1}: Archive selected branch" -f $StepIndex, $TotalSteps)
		Write-Detail "Archiving selected branch"
		& git -C $RepoRoot archive --format=tar --output=$TempTar $BranchName
		if ($LASTEXITCODE -ne 0) {
			throw "git archive failed for branch '$BranchName'."
		}

		$StepIndex += 1
		Write-Step ("Step {0}/{1}: Extract snapshot contents" -f $StepIndex, $TotalSteps)
		Write-Detail "Extracting snapshot contents"
		& tar -xf $TempTar -C $DestinationPath
		if ($LASTEXITCODE -ne 0) {
			throw "tar extraction failed for branch '$BranchName'."
		}
	}
	finally {
		if (Test-Path -Path $TempTar) {
			Remove-Item -Path $TempTar -Force
		}
	}

	$StepIndex += 1
	if (-not $ShouldKeepInterviewDocs) {
		$InterviewDocsPath = Join-Path $DestinationPath "Docs\Interview"
		Write-Step ("Step {0}/{1}: Remove internal interview docs" -f $StepIndex, $TotalSteps)
		if (Test-Path -Path $InterviewDocsPath) {
			Write-Detail "Removing internal interview authoring docs"
			Remove-Item -Path $InterviewDocsPath -Recurse -Force
		}
		else {
			Write-Detail "Interview docs were already absent"
		}
	}
	else {
		Write-Step ("Step {0}/{1}: Keep internal interview docs" -f $StepIndex, $TotalSteps)
		Write-Detail "Keeping Docs\\Interview in the snapshot by request"
	}

	$CandidateReadme = New-CandidateReadme -Scenario $Scenario
	$ReadmePath = Join-Path $DestinationPath "README.md"
	$StepIndex += 1
	Write-Step ("Step {0}/{1}: Write candidate README" -f $StepIndex, $TotalSteps)
	Write-Detail "Writing candidate README"
	Set-Content -Path $ReadmePath -Value $CandidateReadme -Encoding utf8

	$SnapshotGitPath = Join-Path $DestinationPath ".git"
	if (Test-Path -Path $SnapshotGitPath) {
		Write-Detail "Removing inherited git metadata"
		Remove-Item -Path $SnapshotGitPath -Recurse -Force
	}

	if ($ShouldGenerateProjectFiles) {
		$StepIndex += 1
		Invoke-ProjectFileGeneration -ProjectRoot $DestinationPath -StepLabel ("Step {0}/{1}" -f $StepIndex, $TotalSteps)
	}
	else {
		$StepIndex += 1
		Write-Step ("Step {0}/{1}: Skip Unreal project generation" -f $StepIndex, $TotalSteps)
		Write-Detail "Project-file generation was skipped by request"
	}

	if ($ShouldInitGit) {
		$StepIndex += 1
		Write-Step ("Step {0}/{1}: Create fresh snapshot git repo" -f $StepIndex, $TotalSteps)
		Write-Detail "Creating fresh snapshot git repository"
		& git -C $DestinationPath init -b main | Out-Null
		if ($LASTEXITCODE -ne 0) {
			throw "git init failed in snapshot folder '$DestinationPath'."
		}

		& git -C $DestinationPath add -A
		if ($LASTEXITCODE -ne 0) {
			throw "git add failed in snapshot folder '$DestinationPath'."
		}

		& git -C $DestinationPath commit -m $InitialCommitMessage | Out-Null
		if ($LASTEXITCODE -ne 0) {
			throw "git commit failed in snapshot folder '$DestinationPath'. Ensure git user.name and user.email are configured."
		}
	}
	else {
		$StepIndex += 1
		Write-Step ("Step {0}/{1}: Skip fresh snapshot git repo" -f $StepIndex, $TotalSteps)
		Write-Detail "Fresh git initialization was skipped by request"
	}

	Write-Host ("Prepared snapshot for {0}" -f $BranchName) -ForegroundColor Green
	Write-Host ("Path: {0}" -f $DestinationPath)
	Write-Host ("README: {0}" -f $ReadmePath)
}

$RepoRoot = Get-RepoRoot

if ($Help) {
	Show-Usage
	exit 0
}

if ($ListScenarios) {
	$ScenarioList = Get-ScenarioList -RepoRoot $RepoRoot
	foreach ($Scenario in $ScenarioList) {
		if ([string]::IsNullOrWhiteSpace($Scenario.Branch)) {
			continue
		}

		$ScenarioId = if ([string]::IsNullOrWhiteSpace($Scenario.Id)) { "N/A" } else { $Scenario.Id }
		$ScenarioTitle = if ([string]::IsNullOrWhiteSpace($Scenario.Title)) { $Scenario.Branch } else { $Scenario.Title }
		Write-Output ("{0}|{1}|{2}" -f $ScenarioId, $Scenario.Branch, $ScenarioTitle)
	}

	exit 0
}

$HasBranch = -not [string]::IsNullOrWhiteSpace($Branch)
if ($HasBranch -eq $AllScenarios) {
	Write-Host "You must provide exactly one scenario selector: -Branch <branch-name> or -AllScenarios." -ForegroundColor Yellow
	Write-Host ""
	Show-Usage
	exit 64
}

$ResolvedOutputRoot = Resolve-RepoPath -Path $OutputRoot -RepoRoot $RepoRoot
New-Item -Path $ResolvedOutputRoot -ItemType Directory -Force | Out-Null

if ($AllScenarios) {
	$ScenarioDocs = Get-ChildItem -Path (Join-Path $RepoRoot "Docs\Interview\Scenarios") -Filter "*.md" -File
	$ScenarioBranches = @()
	foreach ($Doc in $ScenarioDocs) {
		$Content = Get-Content -Path $Doc.FullName -Raw
		$BranchValue = (Get-ScenarioMetadataValue -Content $Content -FieldName "Branch")
		if ($BranchValue) {
			$ScenarioBranches += (Normalize-ScenarioValue -Value $BranchValue)
		}
	}

	$ScenarioBranches = $ScenarioBranches | Select-Object -Unique | Sort-Object
	$ScenarioIndex = 0
	foreach ($ScenarioBranch in $ScenarioBranches) {
		$ScenarioIndex += 1
		Write-Step ("Scenario {0}/{1}" -f $ScenarioIndex, $ScenarioBranches.Count)
		$DestinationPath = Join-Path $ResolvedOutputRoot (Get-SnapshotFolderName -BranchName $ScenarioBranch -OverrideName $null)
		Export-BranchSnapshot -RepoRoot $RepoRoot -BranchName $ScenarioBranch -DestinationPath $DestinationPath -InitialCommitMessage $InitialCommitMessage -ShouldInitGit (-not $NoGitInit) -ShouldKeepInterviewDocs $KeepInterviewDocs -ShouldGenerateProjectFiles $GenerateProjectFiles
	}
}
else {
	$DestinationPath = Join-Path $ResolvedOutputRoot (Get-SnapshotFolderName -BranchName $Branch -OverrideName $SnapshotName)
	Export-BranchSnapshot -RepoRoot $RepoRoot -BranchName $Branch -DestinationPath $DestinationPath -InitialCommitMessage $InitialCommitMessage -ShouldInitGit (-not $NoGitInit) -ShouldKeepInterviewDocs $KeepInterviewDocs -ShouldGenerateProjectFiles $GenerateProjectFiles
}
