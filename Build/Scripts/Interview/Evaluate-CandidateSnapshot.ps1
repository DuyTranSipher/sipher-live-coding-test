param(
	[string]$SnapshotPath,
	[switch]$Help
)

$ErrorActionPreference = "Stop"

function Show-Usage {
	$Lines = @(
		"Usage: Evaluate-CandidateSnapshot.ps1 -SnapshotPath <path>",
		"",
		"Evaluates a candidate's interview snapshot against the 10 seeded regressions",
		"from the main exercise. Reports which regressions were fixed,",
		"which remain broken, and produces a summary score.",
		"",
		"Parameters:",
		"  -SnapshotPath   Path to the candidate's snapshot folder (the project root)",
		"  -Help           Show this help message",
		"",
		"Examples:",
		"  Evaluate-CandidateSnapshot.bat -SnapshotPath ""C:\Users\Me\Documents\InterviewSnapshots\main""",
		"  Evaluate-CandidateSnapshot.bat -SnapshotPath "".\Saved\InterviewSnapshots\main"""
	)
	$Lines | ForEach-Object { Write-Host $_ }
}

if ($Help) {
	Show-Usage
	exit 0
}

if (-not $SnapshotPath) {
	Write-Host "Error: -SnapshotPath is required." -ForegroundColor Red
	Write-Host ""
	Show-Usage
	exit 1
}

$SnapshotPath = (Resolve-Path -Path $SnapshotPath -ErrorAction Stop).Path

if (-not (Test-Path -Path $SnapshotPath -PathType Container)) {
	Write-Host "Error: Snapshot path does not exist: $SnapshotPath" -ForegroundColor Red
	exit 1
}

function Read-FileContent {
	param([string]$RelativePath)

	$FullPath = Join-Path $SnapshotPath $RelativePath
	if (-not (Test-Path -Path $FullPath)) {
		return $null
	}
	return Get-Content -Path $FullPath -Raw
}

function Test-Regression {
	param(
		[int]$Number,
		[string]$Name,
		[string]$FilePath,
		[string]$BrokenPattern,
		[string]$FixedPattern,
		[switch]$UseRegex
	)

	$Content = Read-FileContent -RelativePath $FilePath

	if ($null -eq $Content) {
		return @{
			Number = $Number
			Name   = $Name
			Status = "MISSING"
			Detail = "File not found: $FilePath"
		}
	}

	$NormalizedContent = $Content -replace '\r\n', "`n" -replace '\t', '    '

	if ($UseRegex) {
		$HasBroken = $NormalizedContent -match $BrokenPattern
		$HasFixed  = if ($FixedPattern) { $NormalizedContent -match $FixedPattern } else { -not $HasBroken }
	}
	else {
		$NormalizedBroken = $BrokenPattern -replace '\r\n', "`n" -replace '\t', '    '
		$HasBroken = $NormalizedContent -match [regex]::Escape($NormalizedBroken)

		if ($FixedPattern) {
			$NormalizedFixed = $FixedPattern -replace '\r\n', "`n" -replace '\t', '    '
			$HasFixed = $NormalizedContent -match [regex]::Escape($NormalizedFixed)
		}
		else {
			$HasFixed = -not $HasBroken
		}
	}

	if ($HasFixed -and -not $HasBroken) {
		return @{
			Number = $Number
			Name   = $Name
			Status = "FIXED"
			Detail = ""
		}
	}
	elseif ($HasBroken) {
		return @{
			Number = $Number
			Name   = $Name
			Status = "BROKEN"
			Detail = "Regression still present"
		}
	}
	else {
		return @{
			Number = $Number
			Name   = $Name
			Status = "CHANGED"
			Detail = "Neither broken nor expected fix pattern found; manual review needed"
		}
	}
}

# --- Define the 10 regression checks ---

$Checks = @(
	@{
		Number        = 1
		Name          = "Lobby background asset scan"
		FilePath      = "Config\DefaultGame.ini"
		BrokenPattern = 'LyraLobbyBackground",AssetBaseClass="/Script/LyraGame.LyraLobbyBackground",bHasBlueprintClasses=False,bIsEditorOnly=False,Directories=,SpecificAssets=("/Game/System/FrontEnd/B_LyraFrontEnd_Experience.B_LyraFrontEnd_Experience")'
		FixedPattern  = 'LyraLobbyBackground",AssetBaseClass="/Script/LyraGame.LyraLobbyBackground",bHasBlueprintClasses=False,bIsEditorOnly=False,Directories=,SpecificAssets=,Rules='
	},
	@{
		Number        = 2
		Name          = "First-weapon ownership"
		FilePath      = "Source\LyraGame\Equipment\LyraQuickBarComponent.cpp"
		BrokenPattern = 'SetActiveSlotIndex(SlotIndex);'
		FixedPattern  = $null
	},
	@{
		Number        = 3
		Name          = "Weapon HUD no-weapon transition"
		FilePath      = "Source\LyraGame\UI\Weapons\LyraWeaponUserInterface.cpp"
		BrokenPattern = 'CurrentInstance = nullptr;'
		FixedPattern  = $null
	},
	@{
		Number        = 4
		Name          = "Hostile-hit reconciliation"
		FilePath      = "Source\LyraGame\Weapons\LyraWeaponStateComponent.cpp"
		BrokenPattern = 'if (Entry.bShowAsSuccess)'
		FixedPattern  = $null
	},
	@{
		Number        = 5
		Name          = "Auto-run state tags"
		FilePath      = "Source\LyraGame\Player\LyraPlayerController.cpp"
		BrokenPattern = 'Status_AutoRunning,\s*0\)[\s\S]*?K2_OnStartAutoRun'
		FixedPattern  = 'Status_AutoRunning,\s*1\)[\s\S]*?K2_OnStartAutoRun'
		UseRegex      = $true
	},
	@{
		Number        = 6
		Name          = "On-spawn ability startup"
		FilePath      = "Source\LyraGame\AbilitySystem\Abilities\LyraGameplayAbility.cpp"
		BrokenPattern = 'if (bClientShouldActivate && bServerShouldActivate)'
		FixedPattern  = 'if (bClientShouldActivate || bServerShouldActivate)'
	},
	@{
		Number        = 7
		Name          = "Game-feature ability grants"
		FilePath      = "Source\LyraGame\GameFeatures\GameFeatureAction_AddAbilities.cpp"
		BrokenPattern = 'else if ((EventName == UGameFrameworkComponentManager::NAME_ExtensionAdded) && (EventName == ALyraPlayerState::NAME_LyraAbilityReady))'
		FixedPattern  = 'else if ((EventName == UGameFrameworkComponentManager::NAME_ExtensionAdded) || (EventName == ALyraPlayerState::NAME_LyraAbilityReady))'
	},
	@{
		Number        = 8
		Name          = "Ability input routing"
		FilePath      = "Source\LyraGame\Character\LyraHeroComponent.cpp"
		BrokenPattern = '&ThisClass::Input_AbilityInputTagReleased, &ThisClass::Input_AbilityInputTagReleased'
		FixedPattern  = '&ThisClass::Input_AbilityInputTagPressed, &ThisClass::Input_AbilityInputTagReleased'
	},
	@{
		Number        = 9
		Name          = "Heal execution"
		FilePath      = "Source\LyraGame\AbilitySystem\Executions\LyraHealExecution.cpp"
		BrokenPattern = 'FMath::Min(0.0f, BaseHeal)'
		FixedPattern  = 'FMath::Max(0.0f, BaseHeal)'
	},
	@{
		Number        = 10
		Name          = "Remote crouch replication"
		FilePath      = "Source\LyraGame\Character\LyraCharacter.cpp"
		BrokenPattern = '!GetCharacterMovement()->bNetworkMovementModeChanged'
		FixedPattern  = $null
	}
)

# --- Run checks ---

$Results = @()
foreach ($Check in $Checks) {
	$Results += Test-Regression @Check
}

# --- Print report ---

$FixedCount = ($Results | Where-Object { $_.Status -eq "FIXED" }).Count
$BrokenCount = ($Results | Where-Object { $_.Status -eq "BROKEN" }).Count
$ChangedCount = ($Results | Where-Object { $_.Status -eq "CHANGED" }).Count
$MissingCount = ($Results | Where-Object { $_.Status -eq "MISSING" }).Count

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Candidate Evaluation Report" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Snapshot: $SnapshotPath"
Write-Host ""

$NameWidth = 36

foreach ($R in $Results) {
	$Num = "{0,2}" -f $R.Number
	$Name = $R.Name.PadRight($NameWidth)

	switch ($R.Status) {
		"FIXED"   { $Color = "Green";  $Symbol = "[FIXED]" }
		"BROKEN"  { $Color = "Red";    $Symbol = "[BROKEN]" }
		"CHANGED" { $Color = "Yellow"; $Symbol = "[CHANGED]" }
		"MISSING" { $Color = "DarkGray"; $Symbol = "[MISSING]" }
	}

	Write-Host "  $Num. $Name " -NoNewline
	Write-Host $Symbol -ForegroundColor $Color

	if ($R.Detail) {
		Write-Host "      $($R.Detail)" -ForegroundColor DarkGray
	}
}

Write-Host ""
Write-Host "--------------------------------------------"
Write-Host "  Fixed: $FixedCount / $($Results.Count)" -ForegroundColor $(if ($FixedCount -eq $Results.Count) { "Green" } else { "White" })

if ($ChangedCount -gt 0) {
	Write-Host "  Changed (needs review): $ChangedCount" -ForegroundColor Yellow
}
if ($MissingCount -gt 0) {
	Write-Host "  Missing files: $MissingCount" -ForegroundColor DarkGray
}

Write-Host "--------------------------------------------"
Write-Host ""

exit 0
