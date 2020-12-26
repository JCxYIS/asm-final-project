.386
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc


.Data?

.Data

.Code

WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	.IF uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
	.ELSEIF uMsg==WM_COMMAND
		mov eax,wParam
		.IF lParam==0
			; Process messages, else...
			invoke DestroyWindow,hWnd
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
     xor eax, eax	; return false
     ret
Button_StopClick endp

end
