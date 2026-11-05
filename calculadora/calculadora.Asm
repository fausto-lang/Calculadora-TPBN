format PE GUI 4.0
entry inicio

include 'Win32a.inc'

ventana_1				equ	1
ventana_operacion   	equ 1001 
ventana_resultado   	equ 1002
cero 					equ 1022
uno 					equ 1014
dos						equ	1013
tres 					equ	1012
cuatro 					equ	1018
cinco					equ	1017
seis					equ	1016
siete					equ	1010
ocho					equ	1009
nueve					equ	1008
suma					equ	1011
resta					equ	1015
multiplicacion			equ	1007
division				equ	1005
modulo					equ	1006	
punto 					equ 1021
retroceder_btn			equ 1004
borrar_btn   			equ	1003
salir_btn				equ	1000

section '.data' data readable writeable
Ist  				dd 0
pWnd 				dd 0
acumulador 			dd 0    
numeroActual 		dd 0    
operadorPendiente 	db 0    
nuevoNumero 		db 1
 
section '.code' code readable executable

inicio:
	invoke GetModuleHandle,0
	mov [Ist],eax
	invoke DialogBoxParam,eax,ventana_1,0,DlgProc,0 
fin:
	invoke ExitProcess,0

proc DlgProc,hWnd,uMsg,wParam,lParam
	push edi esi ebx
	
	mov eax,[uMsg]
	cmp	eax,WM_COMMAND
	je	jCOMMAND
	cmp	eax,WM_INITDIALOG
	je	jINITDIALOG
	cmp	eax,WM_CLOSE
	je	jCLOSE
	xor eax,eax
	jmp finish

jINITDIALOG:
	mov eax,[hWnd]
	mov [pWnd],eax
	
	mov eax,1
	jmp finish
	
jCOMMAND:
    mov eax,[wParam]
    and eax,0FFFFh
    cmp eax,salir_btn
    je salir
    cmp eax,cero
    je cmdCero
    cmp eax,uno
    je cmdUno
    cmp eax,dos
    je cmdDos
    cmp eax,tres
    je cmdTres
    cmp eax,cuatro
    je cmdCuatro
    cmp eax,cinco
    je cmdCinco
    cmp eax,seis
    je cmdSeis
    cmp eax,siete
    je cmdSiete
    cmp eax,ocho
    je cmdOcho
    cmp eax,nueve
    je cmdNueve
    cmp eax,borrar_btn 
    je cmdBorrar
    xor eax,eax
    jmp finish

cmdCero:
    stdcall  AgregarDigito, 0
    mov eax,1
    jmp finish

cmdUno:
    stdcall AgregarDigito, 1
    mov eax,1
    jmp finish

cmdDos:
    stdcall AgregarDigito, 2
    mov eax,1
    jmp finish

cmdTres:
    stdcall AgregarDigito, 3
    mov eax,1
    jmp finish

cmdCuatro:
    stdcall AgregarDigito, 4
    mov eax,1
    jmp finish

cmdCinco:
    stdcall AgregarDigito, 5
    mov eax,1
    jmp finish

cmdSeis:
    stdcall AgregarDigito, 6
    mov eax,1
    jmp finish

cmdSiete:
    stdcall AgregarDigito, 7
    mov eax,1
    jmp finish

cmdOcho:
    stdcall AgregarDigito, 8
    mov eax,1
    jmp finish

cmdNueve:
    stdcall AgregarDigito, 9
    mov eax,1
    jmp finish
    
cmdBorrar:
	stdcall BorrarTodo
	mov eax,1
	jmp finish
	
salir:
	invoke SendMessage,[hWnd],WM_CLOSE,0,0
	mov eax,1
	jmp finish
	
jCLOSE:	
	invoke EndDialog,[hWnd],0
	mov eax,1
	
finish:
	pop ebx esi edi
	ret
endp

proc AgregarDigito,digito    
	cmp byte [nuevoNumero],1    
	jne agregarContinuar    
	mov dword [numeroActual],0    
	mov byte [nuevoNumero],0
agregarContinuar:    
	mov eax,[numeroActual]    
	imul eax,10    
	add eax,[digito]    
	mov [numeroActual],eax    
	invoke SetDlgItemInt,[pWnd],ventana_operacion,[numeroActual],1    
	ret
endp

proc BorrarTodo    
	mov dword [acumulador], 0    
	mov dword [numeroActual], 0    
	mov byte [operadorPendiente], 0    
	mov byte [nuevoNumero], 1        
	invoke SetDlgItemInt, [pWnd], ventana_operacion, 0, 1    
	invoke SetDlgItemInt, [pWnd], ventana_resultado, 0, 1    
	ret
endp

section '.idata' import data readable writeable
  ;importamos solo los procedimientos basicos para abrir una ventana
  library kernel, 'KERNEL32.DLL',\
	  user,   'USER32.DLL'

  import  kernel,\
	  GetModuleHandle,'GetModuleHandleA',\
	  ExitProcess,	  'ExitProcess'

  import  user,\
	  DialogBoxParam, 'DialogBoxParamA',\
	  EndDialog,	  'EndDialog',\
	  SendMessage,	  'SendMessageA',\
	  SetDlgItemInt, 'SetDlgItemInt'
  ;otra forma para importar los procedimientos importando archivos INC
  ;library kernel32,'KERNEL32.DLL',user32,'USER32.DLL',gdi32,'GDI32.DLL'
  ;include 'api\kernel32.inc'
  ;include 'api\user32.inc'
  ;include 'api\gdi32.inc'

section '.rsrc' resource from 'calculadora.res' data readable
