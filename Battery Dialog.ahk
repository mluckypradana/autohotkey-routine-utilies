; Battery charge notification
;
; When the battery is charged, a notification
; will appear to tell the user to remove the charger
;
; When the battery is below 10%, a notification
; will appear to tell the user to plug in the charger
;
; Improvements 
; - Allow the user to set both boundaries instead of being fixed. 
;   * Read a config file at start up


;SetTitleMatchMode 2
#SingleInstance force
;#NoTrayIcon

I_Icon = Battery.ico
IfExist, %I_Icon%
Menu, Tray, Icon, %I_Icon%
;return


percentage := "%"
sleepTime := 60 * 1000 ; Delay in seconds
Loop{ ;Loop forever

	;Grab the current data.
	;https://docs.microsoft.com/en-us/windows/win32/api/winbase/ns-winbase-system_power_status
	VarSetCapacity(powerstatus, 12) ;1+1+1+1+4+4
	success := DllCall("kernel32.dll\GetSystemPowerStatus", "uint", &powerstatus)

	acLineStatus:=ExtractValue(&powerstatus,0)			; Charger connected
	batteryChargePercent:=ExtractValue(&powerstatus,2)		; Battery charge level

	;Is the battery charged higher than 99%
	if (batteryChargePercent > 95){ ; Yes. 

		if (acLineStatus == 1){ ; Only alert if the power lead is connected
			if (batteryChargePercent != 255){		; and if the battery is not disconnected
			
				output=Consider unplug the charging cable
				notifyUser(output)
			}
		}
	}

	;Is the battery charged less than 10%
	if (batteryChargePercent < 16){ ; Yes

		if (acLineStatus == 0){ ; Only alert if the power lead is not connected
			
			output=Consider plug the charging cable
			;notifyUser(output)
		}
	}


	sleep, sleepTime		
}


; Alert user visually and audibly
notifyUser(message){
	SoundBeep 1000, 250
	Msgbox % message
	tooltip(message)
}


;Format the value from the structure
ExtractValue( p_address, p_offset){
  loop, 1
	value := 0+( *( ( p_address+p_offset )+( a_Index-1 ) ) << ( 8* ( a_Index-1 ) ) )
  return, value
}

tooltip(message){
	ToolTip %message%
	settimer, clearTooltip, -5000
}
clearTooltip:
	Tooltip
Return