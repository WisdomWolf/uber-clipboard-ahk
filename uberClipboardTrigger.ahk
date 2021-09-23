#Persistent
#SingleInstance Force
#MaxMem 128
#ClipboardTimeout 5000


DebuggingToggleEnabled := !A_IsCompiled
GlobalHotkeysEnabled := true
FormatTime, TimeString, %A_Now%, M/d/y h:mm:ss tt
APP_NAME := "Uber Clipboard"

;Menu Items
Menu, Tray, NoStandard
Menu, Tray, Add, Activate Uber Clipboard, sendToUberClipboard
Menu, ToggleMenu, Add, Enable Global Hotkeys, GlobalHKFlagToggle
Menu, ToggleMenu, Check, Enable Global Hotkeys
Menu, Tray, Add, Settings, :ToggleMenu
Menu, Tray, Add, Reload Tweaks, Reloader
Menu, Tray, Add
Menu, Tray, Add, Exit, GoExit

if DebuggingToggleEnabled or DebuggingEnabled
{
	Menu, ToggleMenu, Add, Enable Debugging, DebugEnabledToggle
}

if (!A_IsCompiled) {
    try{
		Menu, Tray, Icon, %A_ScriptDir%/icons/emblem_ohno.ico
	} catch e {
		TrayTip, %APP_NAME%, unable to set icon
	}
	Menu, Tray, Tip, % TimeString "`nDebugging Enabled"
} else {
	Menu, Tray, Tip, %TimeString%
}
Return

GlobalHKFlagToggle:
	if (GlobalHotkeysEnabled) {
		GlobalHotkeysEnabled := false
		Menu, ToggleMenu, Uncheck, Enable Global Hotkeys
	} else {
		GlobalHotkeysEnabled := true
		Menu, ToggleMenu, Check, Enable Global Hotkeys
	}
return

DebugEnabledToggle:
	if (DebuggingEnabled) {
		DebuggingEnabled := false
		Menu, ToggleMenu, Uncheck, Enable Debugging
	} else {
		DebuggingEnabled := true
		Menu, ToggleMenu, Check, Enable Debugging
	}
return

Reloader:
	TrayTip, AutoHotkey, Script Reloading, 10, 1
	Sleep 1000 
	Reload
	Sleep 1000 
	;If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
	MsgBox, Reload Failed!
return

;Copy List for rapid paste with uberClipboard
#+c::
uberClipCopy:
	if (GlobalHotkeysEnabled) {
		Keywait, Control
		Keywait, Shift
		oldClip := ClipboardAll
		Clipboard=
		Send ^c
		Clipwait, 2
		sendToUberClipboard()
		Sleep,300 ;necessary to diminish concurrency issues
		if (oldClip) {
			Clipboard=
			Clipboard = %oldClip%
			ClipWait,1
		}
	} else {
        TrayTip, Uber Clipboard Trigger, Global Hot Keys are disabled
    }
return

sendToUberClipboard:
	sendToUberClipboard()
return

:*:#fp#::(>{U+10DA})

sendToUberClipboard()
{
	global DebuggingEnabled
	if (DebuggingEnabled == true)
	{
		; TrayTip, %APP_NAME%, sending to uberClip AHK
		Run, %A_ScriptDir%\uberClipboard.ahk c
	} else {
		; TrayTip, %APP_NAME%, sending to uberClip EXE
		Run, %A_ScriptDir%\uberClipboard.exe c
	}
}

GoExit:
ExitApp