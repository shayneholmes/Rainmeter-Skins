;
; Author:         Shayne Holmes
;
; Script Function:
; Listen for updates to the Plover window, then update
; a Rainmeter variable and skin to show correct status

; Configuration section

RainmeterPath := "C:\Program Files\Rainmeter\rainmeter.exe"

; The end! You shouldn't need to update anything below this 

RainmeterExists := FileExist(RainmeterPath)

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetTitleMatchMode 2 ; for #ifwinnotactive calls
DetectHiddenWindows, on

#Persistent
SetBatchLines, 10ms
Process, Priority,, High

; Set up shell hook to listen for window messages
Gui +LastFound
hWnd := WinExist()
DllCall("RegisterShellHookWindow", UInt,hWnd)
MsgNum := DllCall("RegisterWindowMessage", Str,"SHELLHOOK")
OnMessage(MsgNum, "ShellMessage")

ShellMessage(wParam, lParam) {
  ; Execute a command based on wParam and lParam
  If (wParam = 2 OR wParam = 6) { ; HSHELL_WINDOWDESTROYED or HSHELL_REDRAW means a window's been redrawn
    WinGet, currentProcess, ProcessName, ahk_id %lParam%
    If (currentProcess = "plover.exe") {
      UpdatePloverWindowStatus()
    }
  }
}

SendRainmeterCommand(Command) {
  global RainmeterPath, RainmeterExists, out
  if (RainmeterExists) {
    Run, %RainmeterPath% %Command%
  }
}

UpdatePloverWindowStatus() {
  WinGetTitle, PloverTitle, Plover ahk_exe plover.exe
  If ((PloverLastStatus != -1) and InStr(PloverTitle, ": running")) {
    PloverLastStatus := -1
    SendRainmeterCommand("[!SetVariable IndicatorState -1][!Update PloverStatus]")
  }
  Else If ((PloverLastStatus != 1) and InStr(PloverTitle, ": stopped")) {
    PloverLastStatus := 1
    SendRainmeterCommand("[!SetVariable IndicatorState 1][!Update PloverStatus]")
  }
  Else If (PloverTitle = "") {
    PloverLastStatus := 0
    SendRainmeterCommand("[!SetVariable IndicatorState 0][!Update PloverStatus]")
  }
}
