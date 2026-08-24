// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;
using System.Collections.Generic;

public class LyraEditorTarget : TargetRules
{
	public LyraEditorTarget(TargetInfo Target) : base(Target)
	{
		// UE 5.8 uses V7 defaults for the editor target. Keeping the project target
		// on V6 changes warning policies relative to UnrealEditor and prevents UBT
		// from using the shared editor build products.
		DefaultBuildSettings = BuildSettingsVersion.V7;

		Type = TargetType.Editor;
		ExtraModuleNames.AddRange(new string[] { "LyraGame", "LyraEditor" });

		if (!bBuildAllModules)
		{
			NativePointerMemberBehaviorOverride = PointerMemberBehavior.Disallow;
		}

		LyraGameTarget.ApplySharedLyraTargetSettings(this);

		// This is used for touch screen development along with the "Unreal Remote 2" app
		EnablePlugins.Add("RemoteSession");
	}
}
