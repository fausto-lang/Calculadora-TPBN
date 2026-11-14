format PE GUI 4.0
entry inicio

include 'C:\Pack RadASM\fasm\INCLUDE\WIN32A.INC'

ventana_1           equ 1
ventana_operacion   equ 1001
ventana_resultado   equ 1002

cero                equ 1022
uno                 equ 1014
dos                 equ 1013
tres                equ 1012
cuatro              equ 1018
cinco               equ 1017
seis                equ 1016
siete               equ 1010
ocho                equ 1009
nueve               equ 1008

suma                equ 1011
resta               equ 1015
multiplicacion      equ 1007
division            equ 1005

borrar_btn          equ 1003
retroceder_btn      equ 1004
salir_btn           equ 1000


section '.data' data readable writeable
pWnd                dd 0
posicion            dd 0
expresion           rb 100
resultado_texto     db '0', 0


section '.code' code readable executable

inicio:
    invoke GetModuleHandle, 0
    invoke DialogBoxParam, eax, ventana_1, 0, DlgProc, 0
    invoke ExitProcess, 0

proc DlgProc hWnd, uMsg, wParam, lParam
    push ebx
    mov eax, [uMsg]
    cmp eax, WM_INITDIALOG
    je inicializar
    cmp eax, WM_COMMAND
    je comando
    cmp eax, WM_CLOSE
    je cerrar
    xor eax, eax
    jmp finalizar

inicializar:
    mov eax, [hWnd]
    mov [pWnd], eax
    mov byte [expresion], 0
    stdcall ActualizarPantallas
    mov eax, 1
    jmp finalizar

comando:
    mov eax, [wParam]
    and eax, 0FFFFh
    cmp eax, salir_btn
    je cerrar

    cmp eax, cero
    je digito_0

    cmp eax, uno
    je digito_1

    cmp eax, dos
    je digito_2

    cmp eax, tres
    je digito_3

    cmp eax, cuatro
    je digito_4

    cmp eax, cinco
    je digito_5

    cmp eax, seis
    je digito_6

    cmp eax, siete
    je digito_7

    cmp eax, ocho
    je digito_8

    cmp eax, nueve
    je digito_9

    cmp eax, suma
    je operador_suma

    cmp eax, resta
    je operador_resta

    cmp eax, multiplicacion
    je operador_multiplicacion

    cmp eax, division
    je operador_division

    cmp eax, borrar_btn
    je borrar

    cmp eax, retroceder_btn
    je retroceder

    xor eax, eax
    jmp finalizar

digito_0:
    stdcall AgregarDigito, 0
    jmp comando_procesado

digito_1:
    stdcall AgregarDigito, 1
    jmp comando_procesado

digito_2:
    stdcall AgregarDigito, 2
    jmp comando_procesado

digito_3:
    stdcall AgregarDigito, 3
    jmp comando_procesado

digito_4:
    stdcall AgregarDigito, 4
    jmp comando_procesado

digito_5:
    stdcall AgregarDigito, 5
    jmp comando_procesado

digito_6:
    stdcall AgregarDigito, 6
    jmp comando_procesado

digito_7:
    stdcall AgregarDigito, 7
    jmp comando_procesado

digito_8:
    stdcall AgregarDigito, 8
    jmp comando_procesado

digito_9:
    stdcall AgregarDigito, 9
    jmp comando_procesado

operador_suma:
    stdcall AgregarOperador, '+'
    jmp comando_procesado

operador_resta:
    stdcall AgregarOperador, '-'
    jmp comando_procesado

operador_multiplicacion:
    stdcall AgregarOperador, 'x'
    jmp comando_procesado

operador_division:
    stdcall AgregarOperador, '/'
    jmp comando_procesado

borrar:
    stdcall BorrarTodo
    jmp comando_procesado

retroceder:
    stdcall Retroceder
    jmp comando_procesado

comando_procesado:
    mov eax, 1
    jmp finalizar

cerrar:
    invoke EndDialog, [hWnd], 0
    mov eax, 1

finalizar:
    pop ebx
    ret

endp

proc AgregarDigito digito
    mov eax, [posicion]
    cmp eax, 98
    jge terminar_digito
    mov ecx, [digito]
    add ecx, '0'
    mov [expresion + eax], cl
    inc eax
    mov [posicion], eax
    mov byte [expresion + eax], 0
    stdcall ActualizarPantallas

terminar_digito:
    ret
endp

proc AgregarOperador operador    
	mov eax, [posicion]    
	cmp eax, 0    
	je terminar_operador    
	mov cl, [expresion + eax - 1]    
	cmp cl, '+'    
	je terminar_operador    
	cmp cl, '-'    
	je terminar_operador    
	cmp cl, 'x'    
	je terminar_operador    
	cmp cl, '/'    
	je terminar_operador    
	cmp eax, 98    
	jge terminar_operador    
	mov ecx, [operador]    
	mov [expresion + eax], cl    
	inc eax    
	mov [posicion], eax    
	mov byte [expresion + eax], 0    
	stdcall ActualizarPantallas
	terminar_operador:    
	ret    
	
endp

proc BorrarTodo
    mov dword [posicion], 0
    mov byte [expresion], 0
    stdcall ActualizarPantallas
    ret
endp

proc Retroceder
    mov eax, [posicion]
    cmp eax, 0
    je terminar_retroceder
    dec eax
    mov [posicion], eax
    mov byte [expresion + eax], 0
    stdcall ActualizarPantallas

terminar_retroceder:
    ret
endp

proc ActualizarPantallas
    invoke SetDlgItemText, [pWnd], ventana_operacion, expresion
    invoke SetDlgItemText, [pWnd], ventana_resultado, resultado_texto
    ret
endp

section '.idata' import data readable writeable

library kernel, 'KERNEL32.DLL', \
        user,   'USER32.DLL'

import kernel, \
       GetModuleHandle, 'GetModuleHandleA', \
       ExitProcess,     'ExitProcess'

import user, \
       DialogBoxParam, 'DialogBoxParamA', \
       EndDialog,      'EndDialog', \
       SetDlgItemText, 'SetDlgItemTextA'

section '.rsrc' resource from 'calculadora.res' data readable
