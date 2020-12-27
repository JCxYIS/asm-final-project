.386
.model flat,stdcall
option casemap:none


include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\winmm.inc
;include \masm32\lib\Irvine\Irvine32.inc
include \masm32\include\gdi32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\winmm.lib 


DPOINT STRUCT
	x DWORD ?
	y DWORD ?
DPOINT ENDS

PLAYER_KEY STRUCT
	up BYTE ?
	down BYTE ?
	left BYTE ?
	right BYTE ?
PLAYER_KEY ENDS

BULLET STRUCT
	pos DPOINT <200, 200>
	speed DWORD 5
BULLET ENDS

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
	


 	; **********************
	; global varibale used in GAME
	; *********************	
	isGameStarted BYTE 0
	PLAYER_SPEED DWORD 20
	testFunPtr DWORD ?
	playerKeys PLAYER_KEY<0, 0, 0, 0>
	currentPos DPOINT<100, 100>
	playerVec DPOINT<0, 0>
	bulletList BULLET 10 DUP(<>)


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


; ***************************************
; ----- Some methods used in the GAME -------------
; ***************************************

; descipt: draw rect
; @param {COLORREF} color ; the value of 'COLORREF' is in a RGB form with hex which is "0x00bbggrr"
; 
DrawRect proc hWnd:DWORD, x1:DWORD, y1:DWORD, rWidth:DWORD, rLength:DWORD, color:DWORD
	LOCAL   x2:DWORD, y2:DWORD,
			hbrush:DWORD, hdc:DWORD, rect:RECT	; some local variable
	mov eax, x1
	add eax, rWidth
	mov x2, eax
	
	mov eax, y1
	add eax, rLength
	mov y2, eax
	
	invoke SetRect, addr rect, x1, y1, x2, y2
	invoke CreateSolidBrush, color
	mov hbrush, eax
	
	invoke GetDC, hWnd
	mov hdc, eax
	
	invoke FillRect, hdc,addr rect, hbrush 
	
	invoke ReleaseDC, hWnd, hdc
	invoke DeleteObject, hbrush
	xor eax, eax
	ret
DrawRect endp 

UpdatePlayer proc hWnd:DWORD
	invoke DrawRect, hWnd, currentPos.x, currentPos.y, 10, 10, 00FFFFFFh
		
	;invoke MessageBeep, 2		
; 		mov eax, playerVec.x
;		add currentPos.x, eax
;		mov eax, playerVec.y
;		add currentPos.y, eax
	mov eax, PLAYER_SPEED
	.IF playerKeys.up == 1
		sub currentPos.y, eax
		mov playerKeys.up, 0
	.ENDIF
	.IF playerKeys.down == 1
		add currentPos.y, eax
		mov playerKeys.down, 0
	.ENDIF
	.IF playerKeys.left == 1
		sub currentPos.x, eax
		mov playerKeys.left, 0
	.ENDIF
	.IF playerKeys.right == 1
		add currentPos.x, eax
		mov playerKeys.right, 0
	.ENDIF
	
	invoke DrawRect, hWnd, currentPos.x, currentPos.y, 10, 10, 00FF0000h
	 
	xor eax, eax
	ret
UpdatePlayer endp


InitBullet proc bulletPtr:PTR BULLET
	push edi
	
	mov edi, bulletPtr
	ASSUME edi: PTR BULLET
	
	; call random
;	mov eax, 300
;	call Random32

	
	mov [edi].pos.x, 500
	mov [edi].pos.y, 200
	mov [edi].speed, 20
	
	pop edi
	xor eax, eax
	ret
InitBullet endp

UpdateBullet proc hWnd:DWORD
	push ecx
	
	mov ecx, LENGTHOF bulletList
	
	ForEachBullet:
		push ecx	; save the counter
		 	
		.IF bulletList[ecx-1].pos.x <= 0
			invoke InitBullet, addr bulletList[ecx-1]
		.ENDIF
		
		; remove the rect at original posision
		;invoke DrawRect, hWnd, bulletList[ecx-1].pos.x, bulletList[ecx-1].pos.y, 10, 10, 00FFFFFFh
		;mov eax, bulletList[ecx-1].speed
		;sub bulletList[ecx-1].pos.x, eax
		
		; draw the bullet
		invoke DrawRect, hWnd, bulletList[ecx-1].pos.x, bulletList[ecx-1].pos.y, 20, 20, 000000FFh
		pop ecx		; relase the counter 
		loop ForEachBullet
	
	pop ecx
	xor eax, eax
	ret
UpdateBullet endp

; -------------------------------
; Game main
; --------------------------------

GameMainProc proc hWnd:DWORD
 	
	invoke UpdatePlayer, hWnd
	;invoke UpdateBullet, hWnd

	
	mov eax, 1	; return 1 for continue the loop
	ret	
GameMainProc endp

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
	.ELSEIF uMsg == WM_KEYDOWN
		; update playerVec when keyDown
		mov eax, lParam
		and eax, 70000000h		; ignore repeating key event
		.IF eax == 0
			.IF wParam == 57h	; 'w'
				mov playerKeys.up, 1
			.ENDIF
			.IF wParam == 53h	; 's'
				mov playerKeys.down, 1
			.ENDIF		
			.IF wParam == 41h	; 'a'
				mov playerKeys.left, 1
			.ENDIF
			.IF wParam == 44h	; 'd'
				mov playerKeys.right, 1
			.ENDIF
		.ENDIF			
	.ELSE
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		ret		
	.ENDIF
	xor	eax,eax
	ret
WndProc endp

            
end
