!include "MUI2.nsh"

; This is where all projects live.  Ensure this is the correct relative path.  
!ifndef PROJECTS
  !define PROJECTS '..\..'
!endif

!ifndef FILES_PATH
 !define FILES_PATH '..\..\output\winamp'
!endif


;------------------------

 SetCompressor /SOLID /FINAL lzma
 SetCompressorDictSize 16
 FileBufSize 64
	
RequestExecutionLevel admin
Name "Winamp Web Development"
OutFile "wa_webdev.exe"

InstallDir $PROGRAMFILES\Winamp
InstProgressFlags smooth
XPStyle on
ShowInstDetails hide
AutoCloseWindow true


LangString IDS_CLOSE_WINAMP ${LANG_ENGLISH} "You must close Winamp before you can continue.$\r$\n - After you have closed Winamp, select Retry.$\r$\n - If you wish to try to install anyway, select Ignore.$\r$\n - If you wish to abort the installation, select Abort."

LangString IDS_USER_ABORT ${LANG_ENGLISH} "User action: Abort Installation"
LangString IDS_USER_IGNORE ${LANG_ENGLISH} "User action: Ignore File"
LangString IDS_PAGE_FINISH_TEXT ${LANG_ENGLISH} "To use the plugin, reopen Winamp and go to the WebDev Platform view in the Media Library."
LangString IDS_PAGE_FINISH_RUN ${LANG_ENGLISH} "Launch Winamp after the installer closes"
LangString IDS_FILE_PROBE ${LANG_ENGLISH} "Probing access: $OUTDIR\$0"



!define MUI_ICON ".\resources\install.ico"
!define MUI_UNICON ".\resources\uninstall.ico"
!define MUI_ABORTWARNING

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP ".\resources\header.bmp"

!define MUI_WELCOMEFINISHPAGE_BITMAP ".\resources\welcome.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP ".\resources\welcome.bmp"

!insertmacro MUI_PAGE_WELCOME
 
; detect Winamp path from uninstall string if available
InstallDirRegKey HKLM \
          "Software\Microsoft\Windows\CurrentVersion\Uninstall\Winamp" \
          "UninstallString"

		  
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_TEXT 			$(IDS_PAGE_FINISH_TEXT)
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT        	$(IDS_PAGE_FINISH_RUN)
!define MUI_FINISHPAGE_RUN_FUNCTION     FinishPage_Run
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "English"


!include "FileFunc.nsh"

!define WriteWinampFile "!insertmacro WriteWinampFile"
 !macro WriteWinampFile filePath
  Push $0
  ${GetFileName} "${filePath}" $0
  DetailPrint $(IDS_FILE_PROBE)
  ${Do}
    ClearErrors
    Delete "$OUTDIR\$0"
    ${If} ${Errors} 
      SetErrors
      IfSilent done_${filePath}
      MessageBox MB_DEFBUTTON2|MB_ABORTRETRYIGNORE|MB_ICONEXCLAMATION  $(IDS_CLOSE_WINAMP) IDABORT done_${filePath} IDRETRY +4
      ClearErrors
	  DetailPrint $(IDS_USER_IGNORE)
	  Goto macroend_${filePath}
    ${EndIf}
  ${LoopWhile} ${Errors}

 done_${filePath}: 
  ${If} ${Errors}
    Abort $(IDS_USER_ABORT)
  ${Else}
    File ${filePath}
  ${EndIf}

macroend_${filePath}:

  Pop $0
!macroend

Function FinishPage_Run
 
  HideWindow
  Exec "$INSTDIR\winamp.exe"
  Sleep 500

FunctionEnd

Section ""

SetOutPath $INSTDIR\Plugins
${WriteWinampFile} "${FILES_PATH}\Plugins\ml_webdev.dll"

SetOutPath $INSTDIR\System
${WriteWinampFile} "${FILES_PATH}\System\omBrowser.w5s"
  
SectionEnd
