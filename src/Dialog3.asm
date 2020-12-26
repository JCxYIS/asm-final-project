.386
.model flat,stdcall
option casemap:none


include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\winmm.inc
;include \masm32\lib\Irvine\Irvine32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\winmm.lib 


.Data?
	icex INITCOMMONCONTROLSEX <> ;structure for Controls
;	hInstance HINSTANCE ? 
;	CommandLine LPSTR ? 
;	buffer db 512 dup(?) 

	
.Data
	; is music playing?
	isPlaying     DWORD 0
	
	;  as
	mp3PlayerId   DWORD 0
	mp3PlayerType BYTE  "MPEGVideo",0
	
	; mp3 path
	filePath      BYTE  "F:\Y.mp3", 0   

.Code

; mp3 player---------------------------------------------

PlayMp3 PROC hWin:DWORD, NameOfFile:DWORD

	LOCAL mciOpenParms:MCI_OPEN_PARMS, mciPlayParms:MCI_PLAY_PARMS

	mov eax, hWin        
	mov mciPlayParms.dwCallback, eax
	mov eax, OFFSET mp3PlayerType
	mov mciOpenParms.lpstrDeviceType,eax
	mov eax, NameOfFile
	mov mciOpenParms.lpstrElementName, eax	
 	invoke mciSendCommand, 0, MCI_OPEN,MCI_OPEN_TYPE or MCI_OPEN_ELEMENT, ADDR mciOpenParms	
	mov eax, mciOpenParms.wDeviceID
	mov mp3PlayerId, eax
	invoke mciSendCommand, mp3PlayerId, MCI_PLAY,MCI_NOTIFY, ADDR mciPlayParms
	
	ret  

PlayMp3 ENDP


; event handler---------------------------------------------------					 

Label_SongNameClick proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
     ; Your code here
     xor eax, eax	; return false
     ret
Label_SongNameClick endp

Label_TimeClick proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
     ; Your code here
     xor eax, eax	; return false
     ret
Label_TimeClick endp



Button_PlayClick proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
     ; Your code here
     mov isPlaying, 1
     invoke PlayMp3, hWnd, ADDR filePath
     invoke SetWindowText, hWnd, ADDR filePath 
          
     xor eax, eax	; return false
     ret
Button_PlayClick endp

Button_PauseClick proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
     ; Your code here
     xor eax, eax	; return false
     ret
Button_PauseClick endp

Button_StopClick proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
     ; Your code here
     invoke SendMessage, hWnd, WM_CLOSE, NULL, NULL
     xor eax, eax	; return false
     ret
Button_StopClick endp


; main------------------------------------------------------------------------- 

WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    
	.IF uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL	
			
	.ELSEIF uMsg==WM_COMMAND
		mov eax,wParam
		.IF lParam==0
			; Process messages, else...
			invoke DestroyWindow,hWnd
			
		.ELSEIF wParam == 1002
			invoke Button_PlayClick, hWnd, uMsg, wParam, lParam 
			
		.ELSEIF wParam == 1004
			invoke Button_PauseClick, hWnd, uMsg, wParam, lParam 
		
		.ELSEIF wParam == 1005
			invoke Button_StopClick, hWnd, uMsg, wParam, lParam 
		
		.ELSE
			mov edx,wParam
			shr edx,16
			; Process messages here
		.ENDIF
				
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret		
	.ENDIF
	xor	eax,eax
	ret
WndProc endp

            
end
