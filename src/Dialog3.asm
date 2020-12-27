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





	
.Data
	; is music playing?
	isPlaying      DWORD 0
	
	; mp3 player var
	mp3PlayerId    DWORD 0
	mp3PlayerType  BYTE  "MPEGVideo",0
	mp3PlayerAlias BYTE  "myMp3Player", 0
	
	; mp3 player cmd
	mp3cmd_info    BYTE  "pause MPEGVideo", 0
	
	; mp3 path
	filePath       BYTE  "F:\Y.mp3", 0   
	
	; tmp
	tmp_str        BYTE  128 DUP(0)
	






.Code

; mp3 player---------------------------------------------

PlayMp3 PROC hWin:DWORD, NameOfFile:DWORD
	LOCAL mciOpenParms:MCI_OPEN_PARMS, mciPlayParms:MCI_PLAY_PARMS

 	; may think `mci` as a mesia player
	; see https://www.itsfun.com.tw/mciSendCommand/wiki-6349974-0497854
	; and https://docs.microsoft.com/zh-tw/windows/win32/multimedia/
	
	mov eax, hWin        
	mov mciPlayParms.dwCallback, eax
	
	; set player device type
	mov eax, OFFSET mp3PlayerType
	mov mciOpenParms.lpstrDeviceType, eax
	
	; set filepath
	mov eax, NameOfFile
	mov mciOpenParms.lpstrElementName, eax

	; set alias	
	mov eax, OFFSET mp3PlayerAlias
	mov mciOpenParms.lpstrAlias, eax
	
	; open that	
 	invoke mciSendCommand, 0, MCI_OPEN,MCI_OPEN_TYPE or MCI_OPEN_ELEMENT, ADDR mciOpenParms	
 	
 	; set mci's device id to our var!
	mov eax, mciOpenParms.wDeviceID
	mov mp3PlayerId, eax
	
	; let's play	
	invoke mciSendCommand, mp3PlayerId, MCI_PLAY, MCI_NOTIFY, ADDR mciPlayParms
	
	ret  
PlayMp3 ENDP

GetMp3PlayerInfo PROC hWin:DWORD
	LOCAL mciStatusParms:MCI_STATUS_PARMS
	
	;mciStatus.dwItem = MCI_STATUS_POSITION; 
    ;mciSendCommand(wDeviceID, MCI_STATUS, MCI_STATUS_ITEM, (DWORD)(LPSTR)&mciStatus); 

GetMp3PlayerInfo ENDP 


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
     .IF mp3PlayerId == 0
	     mov isPlaying, 1
		 invoke PlayMp3, hWnd, ADDR filePath
		 invoke SetWindowText, hWnd, ADDR filePath
		 invoke SendDlgItemMessage, hWnd, 1000, WM_SETTEXT, 0, ADDR filePath
     .ELSE
     	 invoke mciSendCommand, mp3PlayerId, MCI_RESUME, 0, 0
     .ENDIF  
          
     xor eax, eax	; return false
     ret
Button_PlayClick endp

Button_PauseClick proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
     ; Your code here
     invoke mciSendCommand, mp3PlayerId, MCI_PAUSE, 0, 0     
     xor eax, eax	; return false
     mov isPlaying, eax
     
     ret
Button_PauseClick endp

Button_StopClick proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
     ; Your code here
     invoke SendMessage, hWnd, WM_CLOSE, NULL, NULL
     xor eax, eax
     mov isPlaying, eax
     mov mp3PlayerId, eax
     
     ret
Button_StopClick endp


button_testClick proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
     ; Your code here
     ;mov ebx, mp3PlayerId
     ;mov tmp_str, bl
	 ;invoke SetWindowText, hWnd, ADDR tmp_str 
	 ;invoke mciSendCommand, mp3PlayerId, MCI_SET_TIME_FORMAT, 0, 0   
	 invoke GetMp3PlayerInfo, hWnd             	
     
     xor eax, eax	; return false     
     ret
button_testClick endp


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
			
		.ELSEIF wParam == 1006
			invoke button_testClick, hWnd, uMsg, wParam, lParam               
		
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
