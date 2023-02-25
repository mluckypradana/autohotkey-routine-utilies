#NoEnv
#SingleInstance force
CoordMode, Mouse, Screen
CoordMode, Tooltip, Screen
CoordMode, Pixel, Screen
SetCapsLockState, AlwaysOff
SetNumLockState, AlwaysOn
setmousedelay -1
setkeydelay -1
global lastX:=0
global lastY:=0
global lastWindowId:=0
global copiedList := []

equal( c1, c2 ) { ; function by [VxE], return value range = [0, 441.67295593006372]
	; that just means that any two colors will have a distance less than 442
	r1 := c1 >> 16
	g1 := c1 >> 8 & 255
	b1 := c1 & 255
	r2 := c2 >> 16
	g2 := c2 >> 8 & 255
	b2 := c2 & 255
	return Sqrt( (r1-r2)**2 + (g1-g2)**2 + (b1-b2)**2 )
}
clickL(cx, cy){
	Click %cx%, %cy%
}

focusLastWindow(){
	if(lastWindowId!=0){
		WinGet, PID, PID, A
		if(PID!=lastWindowId)
			WinActivate, ahk_pid %lastWindowId%
	}
}
saveLastWindow(){
	WinGet, PID, PID, A
	lastWindowId := PID
}
saveLastCursor(){
	MouseGetPos x, y
	lastX := x
	lastY := y
}
loadLastCursor(){
	;MouseMove lastX, lastY
	DllCall("SetCursorPos", "int", lastX, "int", lastY)
}
;Click with mouse
click(cx, cy){
	CoordMode, Mouse, Screen
	CoordMode, Tooltip, Screen
	CoordMode, Pixel, Screen
	SetCapsLockState, AlwaysOff
	setmousedelay -1
	setkeydelay -1

	;untapMouse()
	saveLastCursor()
	saveLastWindow()
	;MouseMove %cx%, %cy%
	Click %cx%, %cy%
	;tooltip(cx . ", " . cy)
	focusLastWindow()
	loadLastCursor()
}
move(x, y){
	;saveLastCursor()
	MouseMove x, y
	;loadLastCursor()
}
beep(){
	SoundBeep 200, 30
}
;300 note, 150 time
ping(){
	SoundBeep 350, 200
}
clickWhen(px, py, pcolor, cx, cy){
	PixelGetColor, color, coorX(px), coorY(py), RGB
	If (equal(color, pcolor)<4){
		if(cx==0)
			click(px, py)
		if(cx>0)
			click(cx, cy)

		return true
	}
	return false
}

coorX(x){
	return x ; A_ScreenWidth  * x / actualScreenX
}

coorY(y){
	return y ; A_ScreenHeight  * y / actualScreenY
}

takeScreenshot(){
	Send #{PrintScreen}
	beep()
}
getColor(px, py) {
	PixelGetColor, color, %px%, %py%, RGB
	return color
}
isColor(px, py, pcolor) {
	PixelGetColor, color, %px%, %py%, RGB
	return equal(color, pcolor)<4
}
c(px, py, pcolor){
	return isColor(px, py, pcolor)
}
isColorS(px, py, pcolor, sensitivity) {
	PixelGetColor, color, %px%, %py%, RGB
	return equal(color, pcolor)<sensitivity
}

moveMouse(dx, dy){
	MouseGetPos x, y
	x:=x+dx
	y:=y+dy
	MouseMove x, y
}
getCurrentDate(){
	FormatTime, currentDate,, dd/MM/yyyy
	return currentDate
}
getDayOfWeek(){
	currentDate := getCurrentDate()
	StringSplit, currentDate, datestring, /
	date := d3 d1 d2
	FormatTime, dayWeek, %date%, dddd
	if(dayWeek=="Monday")
		day:=1
	else if(dayWeek=="Tuesday")
		day:=2
	else if(dayWeek=="Wednesday")
		day:=3
	else if(dayWeek=="Thursday")
		day:=4
	else if(dayWeek=="Friday")
		day:=5
	else if(dayWeek=="Saturday")
		day:=6
	else if(dayWeek=="Sunday")
		day:=7
	return day
}

rand(v1, v2){
	Random, value, v1, v2
	return value
}
drag(sx, sy, dx, dy, delay:=24){
	saveLastCursor()
	MouseMove sx, sy
	SetMouseDelay %delay%
	MouseClickDrag, Left, sx, sy, dx, dy
	SetMouseDelay -1
	loadLastCursor()
}
untapButtons(){
	if GetKeyState("Alt"){
		Send {Alt up}
		Send {LAlt up}
		Send {RAlt up}
	}
	if GetKeyState("Win"){
		Send {Win up}
		Send {LWin up}
		Send {RWin up}
	}
	if GetKeyState("Ctrl"){
		Send {Ctrl up}
		Send {LCtrl up}
		Send {RCtrl up}
	}
	if GetKeyState("Shift"){
		Send {Shift up}
		Send {LShift up}
		Send {RShift up}
	}

	untapMouse()
}
untapMouse(){
	If GetKeyState("LButton", "P") {
		Click, Up, Left
	}
	If GetKeyState("RButton", "P") {
		Click, Up, Right
	}
}

;Wait for pixel to match exact color
pixelWait(x, y, color){
	pixelWaitTime(x, y, color, 1000)
}
pixelWaitTime(x, y, color, wait){
	pixelWait:=0
	wait:=wait/30
	Loop {
		if(c(x, y, color))
			break
		pixelWait++
		if(pixelWait>=wait){
			break
		}
	}
}
pixelWaitNot(x, y, color, time=1000){
	pixelWaitNotTime(x, y, color, time)
}
pixelWaitNotTime(x, y, color, wait){
	pixelWait:=0
	wait:=wait/30
	Loop {
		if(!c(x, y, color))
			break
		pixelWait++
		if(pixelWait>=wait){
			break
		}
	}
}
waitClick(x, y, color){
	pixelWait(x, y, color)
	clickWhen(x, y, color, 0, 0)
}
clickWait(x, y, color){
	click(x, y)
	pixelWait(x, y, color)
}
tooltip(message, ms=1000){
	ToolTip %message%
	hideMs := ms * -1
	settimer, clearTooltip, %hideMs%
}
clearTooltip:
	Tooltip
Return
closeThreads(threadTotal, prefix){
	DetectHiddenWindows, On
	try {
		total := threadTotal+0
		Loop %total% {
			file:=a_scriptdir . "\" . prefix . A_Index . ".ahk"
			tooltip(file)
			WinClose, %file% ahk_class AutoHotkey
		}
	} catch e {
	}
}
closeThread(fileName){
	DetectHiddenWindows, On
	file:=a_scriptdir . "\" . fileName . ".ahk"
	tooltip(file)
	WinClose, %file% ahk_class AutoHotkey
}
runThread(fileName){
	file:=fileName . ".ahk"
	tooltip(file)
	Run % file, , , processId
}
runThreads(threadTotal, prefix){
	DetectHiddenWindows, On
	total := threadTotal+0
	Loop %total% {
		try {
			file:=prefix . A_Index . ".ahk"
			tooltip(file)
			Run % file, , , processId
		} catch e {
		}
	}
}
searchClick(x, y, x2, y2, color){
	PixelSearch, Px, Py, %x%, %y%, %x2%, %y2%, %color%, 4, RGB Fast
	If !ErrorLevel{
		click(Px, Py)
	}
}
searchColor(cx, cy, x2, y2, color, sensitivity=4){
	PixelSearch, Px, Py, %cx%, %cy%, %x2%, %y2%, %color%, 0, RGB Fast
	If !ErrorLevel{
		return {x: Px, y: Py}
	} else {
		return null
	}
}
getCurrentHour(){
	FormatTime, vDate,, h m tt ;e.g. 1 1 PM
	vHour := StrSplit(vDate, " ")[1]
	return vHour
}
runCommand(command, timeout:=100){
	commandOpened:=false
	saveLastWindow()
	if WinExist("ahk_exe cmd.exe"){
		WinActivate
		commandOpened:=true
	}
	cmdId:=0
	if(!commandOpened){
		Run cmd.exe, , , processId
		cmdId:=processId
		WinWait, ahk_pid %processId%
	}
	Send %command%{enter}
	Sleep %timeout%
	Process, Close, %cmdId%
	focusLastWindow()
}
copyCoordinate(){
	MouseGetPos x, y
	clipboard := % x . ", " . y
	tooltip(clipboard)
}

copyText(){
	send ^c
	ClipWait, 10
}
blackGrayWhite(red, green, blue){
	totalColor := red + green + blue
	color := 0
	if(red>175 && green>175 && blue>175)
		color := 9
	else if(red>175 && red>green && red> blue)
		color :=3
	else if(green>175 && green>red && green> blue)
		color :=4
	else if(blue>175 && blue>red && blue> green)
		color :=5
	else if (totalColor >255)
		color := 1
	return color
}
splitRgbColor(RGBColor, ByRef Red, ByRef Green, ByRef Blue){
	Red := RGBColor >> 16 & 0xFF
	Green := RGBColor >> 8 & 0xFF
	Blue := RGBColor & 0xFF
}
pasteText(Byref board, text){
	tempClip := Clipboard
	Clipboard := text
	ClipWait, 10
	Send ^v
	pasteWait()
	;SendInput % Clipboard
	Clipboard := tempClip
	ClipWait, 10
}
pasteWait(){
	; https://www.autohotkey.com/boards/viewtopic.php?f=5&t=37209&p=171360#p271287
	while DllCall("user32\GetOpenClipboardWindow", "Ptr")
		Sleep, 50
}

openWeb(url, newTab:=false){
	option := " --new-window"
	if newTab
		option := " --new-tab"
	Run, msedge.exe %url% %option%
}
pasteFile(path){
	tempClip := Clipboard
	FileRead, Clipboard, %path%
	ClipWait, 10
	Send, ^v
	Clipboard:=tempClip
	ClipWait, 10
}
;Reset array
resetArray(){
	copiedList := []
	tooltip("Clipboards[" . copiedList.Length() . "]")
}
;Copy array
copyArray(){
	untapButtons()
	copyText()
	copiedList.Push(Clipboard)
	tooltip("Clipboards[" . copiedList.Length() . "]")
	untapButtons()
}
;Paste array
pasteArray(){
	Clipboard := % copiedList[1]
	ClipWait, 10
	;tooltip(copiedList[1])
	Send ^v
	ClipWait, 10
	untapButtons()
	copiedList.RemoveAt(1)
	tooltip("Clipboards[" . copiedList.Length() . "]")
}