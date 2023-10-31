#InstallKeybdHook
#InstallMouseHook
SendMode Input
SetCapsLockState, Off
global incrementList := 84
global copiedList := []
global charLength := 5
SetKeyDelay -1
SetMouseDelay -1

untapButtons()

#Include %A_ScriptDir%\_Credentials.ahk

!+^Esc::ExitApp
!Esc::
	file:=A_ScriptDir . "\" . A_ScriptName
	tooltip(A_ScriptName . " restarted")
	Run % file, , , processId
Return

;Development
+^!z::
	CoordMode, Mouse, Screen
	CoordMode, Tooltip, Screen
	CoordMode, Pixel, Screen
	MouseGetPos x, y
	PixelGetColor, color, x, y, RGB
 	clipboard := % x . ", " . y . ", " . color
 	tooltip(clipboard)
return
+^!x::
	CoordMode, Mouse, Screen
	CoordMode, Tooltip, Screen
	CoordMode, Pixel, Screen

	copyCoordinate()
Return
+^!c::
	CoordMode, Mouse, Screen
	CoordMode, Tooltip, Screen
	CoordMode, Pixel, Screen

	MouseGetPos x, y
	PixelGetColor, color, x, y, RGB
 	clipboard := % color
 	splitRgbColor(color, red, green, blue)
 	code:=blackGrayWhite(red, green, blue)
 	tooltip(clipboard . ", " . red . " " . green . " " . blue . ", " . code)
return

cleanClipboard(text){
	untapButtons()
	StringReplace, text, text, -, , All
	StringReplace, text, text, '–', , All
	StringReplace, text, text, %A_Space%, , All
	StringReplace, text, text, (, , All
	StringReplace, text, text, ), , All
	return text
}
closeTab(){
	Send ^w
	Sleep 100
}
openTab(text){
	Send ^t
	pixelWait(1334, 61, 0x202124)
	Sleep 200
	Send, %text%
	Send {Enter}
}
searchBox(query){
	Send % query
	Send {Tab}
	Send {Enter}
}
revealUserInfo(){
	click(526, 333) ;Phone number 
	click(824, 338) ;Email
	click(481, 535) ;Corporate order
	click(526, 333) ;Phone number 
	click(824, 338) ;Email
	click(481, 535) ;Corporate order
}
searchCompanyAccount(){
	copyText()
	openTab(urlEnterpriseSearch)
	pixelWait(527, 121, 0xF16622)
	pixelWait(378, 244, 0xF1F1F1)
	;click(454, 183) ;Radio button
	click(582, 183) ;Textview
	query := RTrim(Clipboard, " ")
	searchBox(query)
	Sleep 100
	click(796, 193) ;Search / Confirm
	pixelWait(1708, 188, 0x3280FC)
	pixelWait(1708, 188, 0x3280FC)
	if c(1708, 188, 0x3280FC) {	;If has company account
		drag(378, 283, 229, 278)
		tempClipboard := query
		copyText()
		viewUserByCorpId(Clipboard)
		;click(259, 277) ;Corporate id
		pixelWait(520, 111, 0xF16622)
		pixelWait(400, 418, 0xF1F1F1)
		Clipboard := tempClipboard
	}
}
viewUserByCorpId(corpId){
	openTab(urlEnterpriseDetailWithId . corpId)
	pixelWait(355, 411, 0xF1F1F1)
	pixelWait(587, 99, 0xF16622)
	Sleep 500
	click(358, 324)	;Staff
	pixelWait(1079, 464, 0x38B03F)
	click(255, 457) ;User id
	pixelWait(320, 188, 0x38B03F)	
	if !c(320, 188, 0x38B03F){
		beep()
		return
	}	
	Sleep 100
	revealUserInfo()
}
getCopiedListOrClipboard(){
	global copiedList 
	text := Clipboard
	if(copiedList.Length() > 0){
		text := copiedList[1]
		copiedList.RemoveAt(1)
	}
	return text
}

;Paste without - and space char
+^f::
	Send ^f
	Sleep 500
	pasteText(Clipboard, cleanClipboard(getCopiedListOrClipboard()))
Return
+^c::
	;copyText()
	;untapButtons()
	Clipboard:=""
	send ^c
	ClipWait 10, 10
	;copyArray()
	copiedList.Push(Clipboard)
	tooltip("Clipboards[" . copiedList.Length() . "] " . copiedList[copiedList.Length()])
Return
+^v::
	;pasteArray()
	;untapButtons()
	Clipboard := % copiedList[1]
	ClipWait 10, 10
	SendInput ^v
	pasteWait()
	ClipWait 10, 10
	tooltip("Clipboards[" . (copiedList.Length()-1) . "] " . copiedList[1])
	copiedList.RemoveAt(1)
Return

;Paste array without extra chars
+^x::
	Clipboard := cleanClipboard(copiedList[1])
	Send ^v
	copiedList.RemoveAt(1)
Return

;Reset array
+^r::
	copiedList:=[]
	tooltip("Clipboards[" . copiedList.Length() . "]")
Return
;Open whatsapp based on phone number
^+w::openTab(urlWhatsappWithPhone . Clipboard)

;Check account from corp id, view order
^+d::
	viewUserByCorpId(getCopiedListOrClipboard())
Return

;Add call log, from list
^+1::
	MouseGetPos x, y
	untapButtons()
	Loop {
		click(x, y) ;Click ham menu
		Sleep 200
		callLogX := x - 84
		callLogY := y + 42
		click(callLogX, callLogY) ;Click call log
		pixelWait(866, 114, 0xFDFDFD)
		pixelWait(852, 115, 0x808080) ;Wait dialog
		
		if !c(852, 115, 0x808080){ ;If dialog doesn't show
			msgbox failed
			break
		}
		MouseMove 1744, 254
		Sleep 150
		MouseMove 1644, 254
		Sleep 150
		click(1744, 254) ;Dropdown
		pixelWait(1628, 316, 0xEBEFF3)
		pixelWait(1628, 316, 0xEBEFF3)
		pixelWait(1628, 316, 0xEBEFF3)
		click(1577, 317) ;Contacted
		pixelWait(1576, 308, 0xFFFFFF)
		click(1846, 999) ;Save
		pixelWait(533, 118, 0xFFFFFF)
		pixelWait(533, 118, 0xFFFFFF)
		pixelWait(533, 118, 0xFFFFFF)
		pixelWait(533, 118, 0xFFFFFF)

		y := y + incrementList
		if Not (y<1018) 
			break
	}
Return
#q::
	click(1744, 254)
Return
;Add call log, view order
^+q::
	untapButtons()
	click(1700, 174)
	pixelWait(1697, 196, 0xFFFFFF)
	if !c(1697, 196, 0xFFFFFF){
		beep()
		return
	}
	click(1700, 221)
	pixelWait(879, 216, 0xFFFFFF)
	click(1630, 259) ;Choose dropdown
	pixelWait(1550, 315, 0xEBEFF3)
	click(1520, 316) ;Choose contacted
	pixelWaitNot(1550, 315, 0xEBEFF3)
	untapButtons()
	click(1844, 1002) ;Save
	pixelWait(958, 158, 0x2C5CC5) ;Wait for refresh button
	pixelWait(948, 156, 0x2C5CC5)
	move(588, 377)
	Click, 2
	Return
	;TODO Fix this
	if !c(958, 158, 0x2C5CC5) {
		beep()
		tooltip("Stopped")
		Return
	}
	MouseMove 945, 378
	pixelWait(941, 352, 0xEEEFF5) ;Wait for edit show up
	Send, {Click}
	pixelWait(868, 363, 0xFFFFFF) ;Wait for edit
	if !c(868, 363, 0xFFFFFF) {
		beep()
		Return
	}
	Send ^a
	copyText()
	viewUserByCorpId(Clipboard)
Return

;Check whether phone number exists in the system
^+e::
	untapButtons()
	copyText()
	openTab(urlSearchUser)
	pixelWait(162, 353, 0x3280FC)
	pixelWait(387, 220, 0xF1F1F1)
	if !c(387, 220, 0xF1F1F1)
		return
	click(590, 170) ;Edittext
	searchBox(Clipboard)
	Sleep 100
	click(736, 165) ;Search
	pixelWait(1895, 219, 0x2C2C2C)
	click(252, 255) ;Click user id
	pixelWait(253, 559, 0xF1F1F1)
	pixelWait(253, 559, 0xF1F1F1)
	if c(347, 175, 0x38B03F) {	;If has user
		revealUserInfo()
		Return
	}
	untapButtons()
Return

^+n::
	searchCompanyAccount()
Return

;Copy user detail information
^+s::
	untapButtons()
	revealUserInfo()
	copiedList := []
	;Corporate id
	move(1131, 468)
	Send, {Click 2}
	Sleep 200
	MouseMove 213, 444
	Click Down
	MouseMove 214, 485
	Sleep 100
	Click up
	copyText()
	StringReplace,Clipboard,Clipboard,`n,,A
	StringReplace,Clipboard,Clipboard,`r,,A
	copiedList.Push(cleanClipboard(Clipboard))

	;User id
	drag(210, 254, 333, 254)
	copyText()
	copiedList.Push(Clipboard)

	;Corp name
	drag(223, 416, 210, 446)
	copyText()
	addressArray := StrSplit(Clipboard, "(", ".") ; Omits periods.
	copiedList.Push(RTrim(addressArray[1], " "))

	;Email
	drag(810, 338, 990, 335)
	copyText()
	copiedList.Push(Clipboard)

	;Phone number
	drag(543, 338, 691, 336)
	copyText()
	copiedList.Push(Clipboard)

	SetMouseDelay -1
	untapButtons()
Return
^+b::
	untapButtons()

	Send % copiedList[1]
	copiedList.RemoveAt(1)

	Send {Right}

	Send % copiedList[1]
	copiedList.RemoveAt(1)

	Send {Right}
	Sleep 50
	Send {Right}
	Sleep 50

	Send % copiedList[1]
	copiedList.RemoveAt(1)

	Loop, 9{
		Send {Right}
		Sleep 50			
	}

	Send % copiedList[1]
	copiedList.RemoveAt(1)

	Loop, 3{
		Send {Left}
		Sleep 100
	}

	Send % copiedList[1]
	copiedList.RemoveAt(1)

	Loop, 19 {
		Send {Left}
		Sleep 50
	}
	untapButtons()
Return
!^+h::
	KeyHistory
Return

#Persistent

SetKeyDelay, 0


:*?:[p::
    RandomizeWord(charLength)
return

RandomizeWord(length) {
    word := ""
    Random, startWithVowel, 0, 1

    if (startWithVowel)
        word := RandomVowel()
    else
        word := RandomConsonant()
	loopTotal:=length-1
	Loop, %loopTotal%
	{
        if (Mod(A_Index,2) == startWithVowel)
            word .= RandomConsonant()
        else
            word .= RandomVowel()
    }
    Send, %word%
}

RandomConsonant() {
    consonants := "bcdfghjklmnpqrstvwxyz"
	Random, charIndex , 1, StrLen(consonants)
    return SubStr(consonants,charIndex, 1)
}

RandomVowel() {
    vowels := "aeiou"
	Random, charIndex , 1, StrLen(vowels)
    return SubStr(vowels, charIndex, 1)
}


#Include  %A_ScriptDir%\_Functions.ahk