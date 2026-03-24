param(
	[Parameter(ParameterSetName = "single", Mandatory = $true)]
	[string]$Branch,

	[Parameter(ParameterSetName = "all", Mandatory = $true)]
	[switch]$AllScenarios,

	[string]$OutputRoot = ".\Saved\InterviewSnapshots",
	[string]$SnapshotName,
	[string]$InitialCommitMessage = "Interview start",
	[switch]$NoGitInit,
	[switch]$KeepInterviewDocs,
	[switch]$Force
)

$ErrorActionPreference = "Stop"

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

function Get-ScenarioDocInfo {
	param(
		[string]$RepoRoot,
		[string]$BranchName
	)

	$ScenarioFiles = Get-ChildItem -Path (Join-Path $RepoRoot "Docs\Interview\Scenarios") -Filter "*.md" -File
	foreach ($File in $ScenarioFiles) {
		$Content = Get-Content -Path $File.FullName -Raw
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
		[bool]$ShouldKeepInterviewDocs
	)

	Assert-GitRefExists -RepoRoot $RepoRoot -RefName $BranchName
	$Scenario = Get-ScenarioDocInfo -RepoRoot $RepoRoot -BranchName $BranchName

	if (Test-Path -Path $DestinationPath) {
		if (-not $Force) {
			throw "Destination already exists: $DestinationPath. Use -Force to replace it."
		}

		Remove-Item -Path $DestinationPath -Recurse -Force
	}

	New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null

	$TempTar = Join-Path ([System.IO.Path]::GetTempPath()) ("interview_snapshot_" + [guid]::NewGuid().ToString("N") + ".tar")
	try {
		& git -C $RepoRoot archive --format=tar --output=$TempTar $BranchName
		if ($LASTEXITCODE -ne 0) {
			throw "git archive failed for branch '$BranchName'."
		}

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

	if (-not $ShouldKeepInterviewDocs) {
		$InterviewDocsPath = Join-Path $DestinationPath "Docs\Interview"
		if (Test-Path -Path $InterviewDocsPath) {
			Remove-Item -Path $InterviewDocsPath -Recurse -Force
		}
	}

	$CandidateReadme = New-CandidateReadme -Scenario $Scenario
	$ReadmePath = Join-Path $DestinationPath "README.md"
	Set-Content -Path $ReadmePath -Value $CandidateReadme -Encoding utf8

	$SnapshotGitPath = Join-Path $DestinationPath ".git"
	if (Test-Path -Path $SnapshotGitPath) {
		Remove-Item -Path $SnapshotGitPath -Recurse -Force
	}

	if ($ShouldInitGit) {
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

	Write-Host "Prepared snapshot for $BranchName"
	Write-Host "Path: $DestinationPath"
	Write-Host "README: $ReadmePath"
}

$RepoRoot = Get-RepoRoot
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
	foreach ($ScenarioBranch in $ScenarioBranches) {
		$DestinationPath = Join-Path $ResolvedOutputRoot (Get-SnapshotFolderName -BranchName $ScenarioBranch -OverrideName $null)
		Export-BranchSnapshot -RepoRoot $RepoRoot -BranchName $ScenarioBranch -DestinationPath $DestinationPath -InitialCommitMessage $InitialCommitMessage -ShouldInitGit (-not $NoGitInit) -ShouldKeepInterviewDocs $KeepInterviewDocs
	}
}
else {
	$DestinationPath = Join-Path $ResolvedOutputRoot (Get-SnapshotFolderName -BranchName $Branch -OverrideName $SnapshotName)
	Export-BranchSnapshot -RepoRoot $RepoRoot -BranchName $Branch -DestinationPath $DestinationPath -InitialCommitMessage $InitialCommitMessage -ShouldInitGit (-not $NoGitInit) -ShouldKeepInterviewDocs $KeepInterviewDocs
}
