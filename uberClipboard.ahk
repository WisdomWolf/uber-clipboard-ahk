;TODO adjust overlay for dynamic handling of 1-5 columns

#InputLevel, 1
EMC_BARCODES_LIST = WindowsForms10.Window.8.app.0.378734a3
EMC_BARCODES_MASTER_EDIT = WindowsForms10.RichEdit20W.app.0.378734a2
EMC_MASTER_EDIT_UNFOCUSED = WindowsForms10.Window.8.app.0.378734a15
APP_NAME := "Uber Clipboard"

Start:
	#NoTrayIcon
	#SingleInstance Force
	SendMode Input  
	SetWorkingDir %A_ScriptDir%  
	;Menu, Tray, Tip, Flickr Field Inserter ; Shows text on mouse hover over icon in System Tray, just whilst file select dialogue box is open.
	;Menu, Tray, Icon, flickr.ico ; My choice of System Tray icon to use. Substitute as appropriate.
	
	;Overlay Setup
	Gui +LastFound +AlwaysOnTop +ToolWindow

	rec := 1
	fieldNum := 1
	fieldOne := Object()
	fieldTwo := Object()
	fieldThree := Object()
	fields := Object()

	xPos := (A_ScreenWidth / 2) - 231
	yPos := 0
	;w: 463	h: 113
	CustomColor = EEAA99
	WinSet, TransColor, %CustomColor% 200

	linecount = 0
	lineArray := Object()
	lineArray.insert("")
	firstRun := True
	
	if 0 < 1
	{
		FileSelectFile, filename, 1,,Please choose a text file to read from;, *.txt
		If ErrorLevel = 1
		{   Msgbox, 5,No file to work with..?, You must choose a file to read!
		   IfMsgBox Retry
				  Goto Start
		   else
				  MsgBox,,Bye!,OK, see you soon!
		   ExitApp
		}
		
		Loop, Read, %filename%
		{
			if (A_LoopReadLine = "")
				continue
			else {
				lineArray.insert(A_LoopReadLine)
				linecount++
			}
		}
	} else {
		contents = %1%
		if (contents = "c") {
			contents := Clipboard
		}
		
		if (RegExMatch(contents, "\r\n\r\n")) {
			InputBox, numCols, Column Count, How many columns of data?,,220,150,,,,,
			contents := RegExReplace(contents, "(?<=\r\n)\r\n", "")
			colCounter = 0
			replacementClipboard := ""
			Loop, Parse, contents,`r, `n
			{
				colCounter++
				if (colCounter < numCols) {
					replacementClipboard := replacementClipboard . A_LoopField . A_Tab
				} else {
					replacementClipboard := replacementClipboard . A_LoopField . "`r`n"
					colCounter = 0
				}
			}
			contents := replacementClipboard
			Sleep, 300
		}
		
		;Uncomment the following line for easy debugging
		; TrayTip, UberClip,% "Uber contents: " . contents
		Loop, Parse, contents,`r, `n
		{
			if (A_LoopField = "") or not RegExMatch(A_LoopField, "\S")
				continue
			else {
				line := StrReplace(A_LoopField, "$","")
				lineArray.insert(line)
				linecount++
			}
		}
	}
	
	;Split lines into fields
	offset := 0
	longestOne := 0
	longestTwo := 0
	longestThree := 0
	For index, line in lineArray
	{
		if (line == "") {
			offset++
			continue
		}
		currentPos := index - offset
		details := StrSplit(line, A_Tab)
		for i, detail in details
		{
			fields[index, i] := detail
		}
		;msgBox % "Line: " line "`nDetails Length: " details.length()
		fieldOne.insert(Format("{:T}", details[1]))
		if (StrLen(details[1]) > StrLen(longestOne)) {
			longestOne := details[1]
		}
		if (details.length() > 1) {
			fieldTwo.insert(Format("{:T}", details[2]))
			if (StrLen(details[2]) > StrLen(longestTwo)) {
				longestTwo := details[2]
			}
			if (details.length() > 2) {
				fieldThree.insert(Format("{:T}", details[3]))
				if (StrLen(details[3]) > StrLen(longestThree)) {
					longestThree := details[3]
				}
			} else {
				fieldThree := False
			}
		} else {
			fieldTwo := False
		}
	}
	
	maxPos := fieldOne.length()
	
	;Gui, UberOverlay:Margin, 0, 0
	gui, +hwndhMYGUI
	gui, add, edit, xm ym ReadOnly vField1, % longestOne
	gui, add, button, xp y+m wp gCopyField, &1
	
	If (longestTwo) {
		gui, add, edit, ym ReadOnly vField2, % longestTwo
		gui, add, button, xp y+m wp gCopyField, &2
	}

	If (longestThree) {
		gui, add, edit, ym ReadOnly vField3, % longestThree
		gui, add, button, xp y+m wp gCopyField, &3
	}
	
	gui, add, updown, xm y+m w100 vtoCenter vRec gChangeRecord Range1-%maxPos% Horz, 1
	Gui, Add, Text, ym vRecordNumber,% "00" rec "/" maxPos
	gui, add, button, xp y+m w60 gLoopDetails, Details
	Gui, Show, X%xPos% Y%yPos% NoActivate, Uber Clipboard
	center(1, "toCenter", "ahk_id" hMYGUI)
	
	Clipboard=
	GoSub,ChangeRecord
return

#IFWinActive

;Paste current entry and advance list
^Insert::
uberPaste:
	;Keywait, Control
	if (firstRun) {
		GoSub, PastePrep
		firstRun := False
	} else {
		Gosub,AdvanceList
	}
	if (rec <= linecount)
	{
		SendLevel 1
		Send ^v
		Sleep 300
	}
return

^+Insert::
	;Keywait, Shift
	Gosub,uberPaste
	if (rec < linecount)
		Send {Enter}
return

^!Insert::
uberClipDump:
	Keywait, Control
	Keywait, Shift
	Clipboard := contents
	Clipwait, 1
	TrayTip, %APP_NAME%, uberClip contents dumped to clipboard
	Send ^v
return

^PgDn::
AdvanceList:
	if (rec < linecount) {
		rec++
		Gosub,ChangeRecord
	} else {
		Gosub,Exiter
	}
return

^PgUp::
RegressList:
	if (rec > 1)
		rec--
	Gosub,ChangeRecord
return

^#Enter::
PastePrep:
	;line := lineArray[rec]
	;nextLine := lineArray[rec + 1]
	;Gosub,ShowToolTip
	; if (rec == 1)
		; Clipboard := nextline
	; else
		; Clipboard := line
	; Clipwait, 1
	CopyField(fieldNum)
return

^1::
^+1::
^2::
^+2::
^3::
^+3::
	fieldNum := SubStr(A_ThisHotkey, 0, 1)
	modType := SubStr(A_ThisHotkey, -1, 1)
	if (CopyField(fieldNum) == True) {
		firstRun := False
		Send ^v
	} else {
		return
	}
	if (modType == "+")
		Send {Enter}
return

^!#p::
	ListHotKeys
return

ShowToolTip:
	line_index := 0
	if (rec <= 1)
		line_index := "-"
	else
		line_index := rec - 1
	if (nextLine != "") {
		ToolTip, Current line: "%line%"`nNext line: "%nextLine%"`n%line_index% of %linecount%
	} else {
		ToolTip, END
	}
	SetTimer, RemoveToolTip, -5000
return

RemoveToolTip:
	ToolTip
return

LoopDetails:
	msgBox, % "Starting Detail Loop `nFields: " fields.length()
	for i, field in fields
	{
		MsgBox, % "Field " i " is " field
		for j, item in field
		{
			MsgBox, % "Array[" j "][" i "] is " item
		}
	}
return

ChangeRecord:
	GuiControl,, Field1,% fieldOne[rec]
	GuiControl,, Field2,% fieldTwo[rec]
	GuiControl,, Field3,% fieldThree[rec]
	GuiControl,, RecordNumber,% rec "/" maxPos
	GoSub, PastePrep
return

CopyField:
	StringRight, eVar, A_GuiControl, 1
	CopyField(eVar)
return

CopyField(fieldNum)
{
	global rec
	global fieldOne
	global fieldTwo
	global fieldThree
	if (fieldNum = 1)
	{
		Clipboard := fieldOne[rec]
		return True
	}
	else if (fieldNum = 2)
	{
		if (fieldTwo != False) {
			Clipboard := fieldTwo[rec]
			return True
		} else {
			MsgBox, Data contains only two columns
			return False
		}
	}
	else if (fieldNum = 3)
	{
		if (fieldThree != False) {
			Clipboard := fieldThree[rec]
			return True
		} else {
			MsgBox, Data contains only two columns
			return False
		}
	}
	Clipwait, 1
}

; -----------------------------------------------
; --------------- CENTER CONTROLS ---------------
; -----------------------------------------------
; THIS IS A "FUNCTION DEFINITION"
; mode 1  = horiz, mode 2 = vertical
; control = the "vControlName" defined in the GUI element.
; win     = the window of the GUI you want to get the size of.   
center(mode, control, win)
{
	; get the width and height of the specified window.
	winGetPos,,,w,h,%win%

	; get the width and height of the specified control.
	GuiControlGet, cont, Pos, %control%

	; get the size of the titlebar area.
	SysGet, titleBar, 4

	; do the logic to see what mode for positioning should be
	; if 1... set the specified control's X position by half the window width, minus half the control width.
	; if mode is 2, do the same but with Y instead of X and HEIGHT instead of WIDTH.
	; example: if the control is 200 px wide and the window is 500 px ...
	; 500/2 = 250
	; 200/2 = 100
	; 250-100=150. 
	; 150 is where the control will start, 350 is where it'll end. 250 is the middle of the control and window.
	if (mode=1)
		guiControl, move, %control%, % "x" (w/2)-(contW/2)
	else if (mode=2)
		guiControl, move, %control%, % "y" (h/2)-(contH/2)-(titleBar/2)
}

Exiter:
	MsgBox, You've reached the end of the list.
return

GuiClose:
ExitApp

; def convert_id_notation(item_id):
	; if 'M' in item_id:
		; split_item_id = item_id.split('M')
		; zero_pad = 9 - (len(split_item_id[0]) + len(split_item_id[1]))
		; return '{0}{1}{2}'.format(split_item_id[0], '0'*zero_pad, split_item_id[1])