#Requires AutoHotkey v2.0

; ===================================================================
; Go below "CONFIGURATION" and set the location of your portable OBS
; ==================================================================

;ELEVATE TO ADMINISTRATOR
if not A_IsAdmin {
    try
    {
        Run "*RunAs " . A_ScriptFullPath
    }
    catch {
        MsgBox "Script requires Administrator privileges to move files to Program Files."
        ExitApp
    }
    ExitApp
}

; CONFIGURATION
; ==============================================================================
; Set the filepath to the root folder of your Portable OBS folder.
; Example: "C:\Program Files\obs-studio" with no trailing backslash.
dirToOBSPortableRoot := "C:\Program Files\obs-studio"

; ----- DO NOT MODIFY ANYTHING BELOW THIS LINE -------

; FIX: Changed A_ProgramData (invalid) to A_AppDataCommon (C:\ProgramData)
dirToPluginBase := A_AppDataCommon . "\obs-studio\plugins\StreamDeckPlugin\"
dirToPluginBin := A_AppDataCommon . "\obs-studio\plugins\StreamDeckPlugin\bin\64bit\"
dirToPluginData := A_AppDataCommon . "\obs-studio\plugins\StreamDeckPlugin\data\"

dirToObsBin := dirToOBSPortableRoot . "\obs-plugins\64bit\"
dirToObsData := dirToOBSPortableRoot . "\data\obs-plugins\StreamDeckPlugin\"

sdPluginMainDll := "StreamDeckPlugin.dll"
sdPluginDllQt6Fn := "StreamDeckPluginQt6.dll"

sdPluginQt6Source := dirToPluginData . sdPluginDllQt6Fn
sdPluginMainSource := dirToPluginBin . sdPluginMainDll

sdPluginQt6Dest := dirToObsData . sdPluginDllQt6Fn
sdPluginDest := dirToObsBin . sdPluginMainDll

; Messages
err1 :=
    "You have not specified the location of your Portable OBS installation inside the script.`n`nPlease edit the script file."
err2 := "Unable to locate the source files for the StreamDeck Plugin at`n`n" . dirToPluginBase .
    "`n`nPlease check that you've installed the StreamDeck Application from Elgato's website."
err3 := sdPluginDllQt6Fn .
    " was not moved because the destination file version is already up to date.`n`nClick OK to continue."
err4 := sdPluginMainDll .
    " was not moved because the destination file version is already up to date.`n`nClick OK to exit."

; FUNCTIONS

InitDirCheck() {
    if (dirToOBSPortableRoot == "") {
        MsgBox err1, "OBS Portable Directory Not Set", "Iconi"
        ExitApp
    }
    if !DirExist(dirToOBSPortableRoot) {
        MsgBox err1, "Unable to find OBS Portable Directory", "Iconi"
        ExitApp
    }
}

DestinationCheck() {
    if !DirExist(dirToObsData) {
        try {
            DirCreate dirToObsData
        } catch as e {
            MsgBox "Failed to create Data directory. Access Denied.`n" . e.Message
            ExitApp
        }
    }

    if !DirExist(dirToObsBin) {
        try {
            DirCreate dirToObsBin
        } catch as e {
            MsgBox "Failed to create Bin directory. Access Denied.`n" . e.Message
            ExitApp
        }
    }
}

SourceCheck() {
    if !DirExist(dirToPluginBin) {
        MsgBox err2, "Files Not Found in Source: Bin", "Iconi"
        ExitApp
    }
    if !DirExist(dirToPluginData) {
        MsgBox err2, "Files Not Found in Source: Data", "Iconi"
        ExitApp
    }
}

CompareAndMove() {
    ; PART 1: StreamDeckPluginQt6.dll (Data Folder)
    shouldCopyQt6 := false

    if FileExist(sdPluginQt6Dest) {
        try {
            verSrc := FileGetVersion(sdPluginQt6Source)
            verDest := FileGetVersion(sdPluginQt6Dest)

            ; VerCompare returns >0 if left is greater, 0 if equal, <0 if left is smaller
            if (VerCompare(verDest, verSrc) >= 0) {
                MsgBox err3, sdPluginDllQt6Fn . " Move Not Required", "Iconi"
            } else {
                shouldCopyQt6 := true ; Dest is older than source
            }
        } catch {
            shouldCopyQt6 := true ; Couldn't read version, force copy to be safe
        }
    } else {
        shouldCopyQt6 := true ; File doesn't exist
    }

    if (shouldCopyQt6) {
        try {
            ; DirCopy(Source, Dest, Overwrite?)
            DirCopy dirToPluginData, dirToObsData, 1
            MsgBox sdPluginDllQt6Fn . " files successfully copied to " . dirToObsData, "Qt6 Copied", "Iconi"
        } catch as e {
            MsgBox "Error copying Qt6 Data files: " . e.Message
        }
    }

    ; PART 2: StreamDeckPlugin.dll (Bin Folder)
    shouldCopyMain := false

    if FileExist(sdPluginDest) {
        try {
            verSrcMain := FileGetVersion(sdPluginMainSource)
            verDestMain := FileGetVersion(sdPluginDest)

            if (VerCompare(verDestMain, verSrcMain) >= 0) {
                MsgBox err4, sdPluginMainDll . " Move Not Required", "Iconi"
            } else {
                shouldCopyMain := true
            }
        } catch {
            shouldCopyMain := true
        }
    } else {
        shouldCopyMain := true
    }

    if (shouldCopyMain) {
        try {
            DirCopy dirToPluginBin, dirToObsBin, 1
            MsgBox sdPluginMainDll . " files successfully copied to " . dirToObsBin, "Main Plugin Copied", "Iconi"
        } catch as e {
            MsgBox "Error copying Main Plugin files: " . e.Message
        }
    }
}

; EXECUTION FLOW

InitDirCheck()
DestinationCheck()
SourceCheck()
CompareAndMove()