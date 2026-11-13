format PE GUI 4.0
entry inicio

include 'Win32a.inc'

ventana_1				equ	1
ventana_operacion   	equ 1001
ventana_resultado		equ 1002
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
operacionValida 	db 0
estadoCalculo 		db 0  
nuevoNumero 		db 1
expresion       	rb 100
pantalla        	rb 150
posicion        	dd 0
indiceLectura 		dd 0
signoNumero 		dd 1
parteDecimal 		dd 0
cantidadDecimales 	dd 0
escalaDecimal 		dd 100
parteIntResultado 	dd 0
parteDoubleResul	dd 0
formatoResultado 	db '%s%d.%02d', 0
signoPositivo 		db '', 0
signoNegativo 		db '-', 0 
resultadoTotal 		dd 0
resultadoTermino 	dd 0
operadorTermino 	db 0
formato_pantalla 	db '%s', 13, 10, 13, 10, 13, 10, 13, 10, '0', 0
pantalla_vacia 		db 13,10,13,10,13,10,13,10,'0',0
formatoPrueba 		db '%s', 0
textoPrueba 		db '7.50', 0
 
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
    cmp eax,suma
    je cmdSuma
    cmp eax,resta
    je cmdResta
    cmp eax,multiplicacion
    je cmdMultiplicacion
    cmp eax,division
    je cmdDivision
    cmp eax,1021
	je cmdPunto
    cmp eax,1020
	je cmdIgual
    cmp eax,borrar_btn 
    je cmdBorrar
    xor eax,eax
    jmp finish

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
    
    cmp eax, porcentaje
    je operador_porcentaje
    
    cmp eax, punto
    je operador_punto
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
    
cmdSuma:    
	stdcall AgregarCaracter, '+'    
	mov eax, 1    
	jmp finish
	
cmdResta:    
	stdcall AgregarCaracter, '-'    
	mov eax, 1    
	jmp finish
	
cmdDivision:    
	stdcall AgregarCaracter, '/'    
	mov eax, 1    
	jmp finish
	
cmdMultiplicacion:    
	stdcall AgregarCaracter, 'x'    
	mov eax, 1    
	jmp finish
	
cmdPunto:
    stdcall AgregarPunto
    mov eax,1
    jmp finish	
    
cmdIgual:
    stdcall ProcesarOperacion
    cmp byte [estadoCalculo], 1
    jne igualTerminado
    stdcall MostrarResultadoDecimal

igualTerminado:
    mov eax, 1
    jmp finish
    
cmdBorrar:
	stdcall BorrarTodo
	mov eax,1
	jmp finish
	
cmdRetroceder:
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

proc AgregarDigito, digito    
	mov eax, [digito]    
	add eax, '0'    
	stdcall AgregarCaracter, eax    
	ret
endp
proc AgregarPunto
    push eax
    push esi

    mov esi, [posicion]
    cmp esi, 0
    je finAgregarPunto

    dec esi

buscarInicioNumero:
    mov al, [expresion + esi]
    cmp al, '.'
    je finAgregarPunto
    cmp al, '+'
    je comprobarInicio
    cmp al, '-'
    je comprobarInicio
    cmp al, 'x'
    je comprobarInicio
    cmp al, '/'
    je comprobarInicio
    cmp al, '%'
    je comprobarInicio

    cmp esi, 0
    je comprobarInicio

    dec esi
    jmp buscarInicioNumero

comprobarInicio:
    mov eax, [posicion]
    cmp esi, eax
    je finAgregarPunto
    stdcall AgregarCaracter, '.'

finAgregarPunto:
    pop esi
    pop eax
    ret
endp
proc AgregarCaracter, caracter
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
    invoke wsprintf, pantalla, formato_pantalla, expresion
    invoke SetDlgItemText, [pWnd], ventana_operacion, pantalla	
finalizarAgregar:
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
proc SumarNumeros
	mov eax, [acumulador]
	add eax, [numeroActual]
	mov [acumulador], eax
	ret
endp
proc RestarNumeros
	mov eax, [acumulador]
	sub eax, [numeroActual]
	mov [acumulador], eax
	ret
endp

proc MultiNumeros
    mov eax, [acumulador]
    imul dword [numeroActual]
    idiv dword [escalaDecimal]
    mov [acumulador], eax
    ret
endp

proc DividirNumeros
    cmp dword [numeroActual], 0
    je errorDivision
    mov eax, [acumulador]
    imul dword [escalaDecimal]
    idiv dword [numeroActual]
    mov [acumulador], eax
    ret
errorDivision:
    mov byte [estadoCalculo], 2
    ret
endp
proc CalcularModulo
    cmp dword [numeroActual], 0
    je errorModulo

    mov eax, [acumulador]
    cmp eax, 80000000h
    jne realizarModulo
    cmp dword [numeroActual], -1
    je errorModulo

realizarModulo:
    mov eax, [acumulador]
    cdq
    idiv dword [numeroActual]
    mov [acumulador], edx
    ret

errorModulo:
    mov byte [estadoCalculo], 2
    ret
endp
proc EvaluarOperacion
    mov al, [operadorPendiente]

    cmp al, '+'
    je evaluarSuma

    cmp al, '-'
    je evaluarResta

    cmp al, 'x'
    je evaluarMultiplicacion

    cmp al, '/'
    je evaluarDivision

    cmp al, '%'
    je evaluarModulo

    ret

evaluarSuma:
    stdcall SumarNumeros
    ret

evaluarResta:
    stdcall RestarNumeros
    ret

evaluarMultiplicacion:
    stdcall MultiNumeros
    ret

evaluarDivision:
    stdcall DividirNumeros
    ret

evaluarModulo:
    stdcall CalcularModulo
    ret
endp
proc IdentificarOperador
    push esi

    mov esi, 0
    mov byte [operadorPendiente], 0

buscarOperadorIdentificacion:
    mov al, [expresion + esi]

    cmp al, 0
    je finIdentificar

    cmp al, '+'
    je guardarOperador

    cmp al, '-'
    je guardarOperador

    cmp al, 'x'
    je guardarOperador

    cmp al, '/'
    je guardarOperador

    cmp al, '%'
    je guardarOperador

    inc esi
    jmp buscarOperadorIdentificacion

guardarOperador:
    mov [operadorPendiente], al

finIdentificar:
    pop esi
    ret
endp
proc CalcularExpresion
    stdcall LeerPrimerEntero
    mov eax, [numeroActual]
    mov [acumulador], eax
    stdcall IdentificarOperador

    cmp byte [operadorPendiente], 0
    je finCalcular

    stdcall LeerSegundoEntero

    stdcall EvaluarOperacion

finCalcular:
    ret
endp
proc ValidarOperacion
    push esi

    mov byte [operacionValida], 0
    mov esi, 0

validarNumero:
    mov al, [expresion + esi]
    cmp al, '-'
    jne comprobarDigito
    inc esi

comprobarDigito:
    mov al, [expresion + esi]
    cmp al, '0'
    jl finValidacion
    cmp al, '9'
    jg finValidacion

recorrerDigitos:
    mov al, [expresion + esi]

    cmp al, '0'
    jl comprobarPunto
    cmp al, '9'
    jg comprobarPunto

    inc esi
    jmp recorrerDigitos

comprobarPunto:
    cmp al, '.'
    jne comprobarOperador

    inc esi
    mov al, [expresion + esi]
    cmp al, '0'
    jl finValidacion
    cmp al, '9'
    jg finValidacion

    inc esi
    mov al, [expresion + esi]

    cmp al, '0'
    jl comprobarOperador
    cmp al, '9'
    jg comprobarOperador

    inc esi
    mov al, [expresion + esi]
    cmp al, '0'
    jl comprobarOperador
    cmp al, '9'
    jle finValidacion

comprobarOperador:
    mov al, [expresion + esi]

    cmp al, 0
    je expresionCorrecta

    cmp al, '+'
    je siguienteNumero

    cmp al, '-'
    je siguienteNumero

    cmp al, 'x'
    je siguienteNumero

    cmp al, '/'
    je siguienteNumero

    cmp al, '%'
    je siguienteNumero

    jmp finValidacion

siguienteNumero:
    inc esi
    jmp validarNumero

expresionCorrecta:
    mov byte [operacionValida], 1

finValidacion:
    pop esi
    ret
endp
proc ProcesarOperacion
    mov byte [estadoCalculo], 0

    stdcall ValidarOperacion

    cmp byte [operacionValida], 1
    jnz finProcesar

    mov byte [estadoCalculo], 1

    stdcall EvaluarConPrecedencia

finProcesar:
    ret
endp
proc LeerPrimerEntero
    push esi
    push ebx

    mov dword [numeroActual], 0
    mov esi, 0

leerDigito:
    mov ecx, 0
    mov cl, [expresion + esi]

    cmp cl, '0'
    jl finLectura
    cmp cl, '9'
    jg finLectura

    sub cl, '0'

    mov eax, [numeroActual]
    mov ebx, 10
    mul ebx
    add eax, ecx

    mov [numeroActual], eax

    inc esi
    jmp leerDigito

finLectura:
    pop ebx
    pop esi
    ret
endp  
proc LeerSegundoEntero
    push esi
    push ebx

    mov dword [numeroActual], 0
    mov esi, 0

buscarOperador:
    mov al, [expresion + esi]

    cmp al, 0
    je finSegundoEntero

    cmp al, '+'
    je operadorEncontrado
    cmp al, '-'
    je operadorEncontrado
    cmp al, 'x'
    je operadorEncontrado
    cmp al, '/'
    je operadorEncontrado
    cmp al, '%'
    je operadorEncontrado

    inc esi
    jmp buscarOperador

operadorEncontrado:
    inc esi

leerSegundoDigito:
    mov ecx, 0
    mov cl, [expresion + esi]

    cmp cl, '0'
    jl finSegundoEntero
    cmp cl, '9'
    jg finSegundoEntero

    sub cl, '0'

    mov eax, [numeroActual]
    imul eax, 10
    add eax, ecx

    mov [numeroActual], eax

    inc esi
    jmp leerSegundoDigito

finSegundoEntero:
    pop ebx
    pop esi
    ret
endp

proc ProbarProcesamiento
    
    mov byte [expresion], '2'
    mov byte [expresion+1], '.'
    mov byte [expresion+2], '5'
    mov byte [expresion+3], 'x'
    mov byte [expresion+4], '3'
    mov byte [expresion+5], 0

    stdcall ProcesarOperacion

    invoke SetDlgItemInt, [pWnd], ventana_operacion, [acumulador], 0

    ret
endp
proc MostrarResultadoDecimal
    push eax
    push ebx
    push esi

    mov eax, [acumulador]
    mov esi, signoPositivo

    cmp eax, 0
    jge separarResultado

    mov esi, signoNegativo
    neg eax

separarResultado:
    xor edx, edx
    mov ebx, 100
    div ebx

    mov [parteIntResultado], eax
    mov [parteDoubleResul], edx

    cinvoke wsprintf, pantalla, formatoResultado, esi, [parteIntResultado], [parteDoubleResul]

    invoke SetDlgItemText, [pWnd], ventana_operacion, pantalla

    pop esi
    pop ebx
    pop eax
    ret
endp
proc ProbarMostrarDecimal
    mov dword [acumulador], 300

    stdcall MostrarResultadoDecimal

    ret
endp

proc LeerEnteroDesdeIndice
    push esi
    push ebx

    mov dword [numeroActual], 0
    mov dword [parteDecimal], 0
    mov dword [cantidadDecimales], 0
    mov dword [signoNumero], 1

    mov esi, [indiceLectura]

    mov al, [expresion + esi]
    cmp al, '-'
    jne leerParteEntera

    mov dword [signoNumero], -1
    inc esi

leerParteEntera:
    mov ecx, 0
    mov cl, [expresion + esi]

    cmp cl, '0'
    jl comprobarPuntoDecimal
    cmp cl, '9'
    jg comprobarPuntoDecimal

    sub cl, '0'

    mov eax, [numeroActual]
    imul eax, 10
    add eax, ecx
    mov [numeroActual], eax

    inc esi
    jmp leerParteEntera

comprobarPuntoDecimal:
    cmp cl, '.'
    jne finalizarNumero

    inc esi

    mov ecx, 0
    mov cl, [expresion + esi]

    cmp cl, '0'
    jl finalizarNumero
    cmp cl, '9'
    jg finalizarNumero

    sub cl, '0'
    mov [parteDecimal], ecx

    mov dword [cantidadDecimales], 1

    inc esi

    mov ecx, 0
    mov cl, [expresion + esi]

    cmp cl, '0'
    jl ajustarDecimal
    cmp cl, '9'
    jg ajustarDecimal

    sub cl, '0'

    mov eax, [parteDecimal]
    imul eax, 10
    add eax, ecx
    mov [parteDecimal], eax

    mov dword [cantidadDecimales], 2

    inc esi
    jmp finalizarNumero

ajustarDecimal:
    mov eax, [parteDecimal]
    imul eax, 10
    mov [parteDecimal], eax

finalizarNumero:
    mov eax, [numeroActual]
    imul eax, 100

    add eax, [parteDecimal]

    cmp dword [signoNumero], -1
    jne guardarNumero

    neg eax

guardarNumero:
    mov [numeroActual], eax
    mov [indiceLectura], esi

    pop ebx
    pop esi
    ret
endp
proc ProbarLecturaDecimal
    
	mov byte [expresion], '-'
	mov byte [expresion+1], '1'
	mov byte [expresion+2], '.'
	mov byte [expresion+3], '2'
	mov byte [expresion+4], '5'
	mov byte [expresion+5], 0

    mov dword [indiceLectura], 0

    stdcall LeerEnteroDesdeIndice
    invoke SetDlgItemInt, [pWnd], ventana_operacion, [numeroActual], 1

    ret
endp
proc ProcesarTermino
	push esi
    stdcall LeerEnteroDesdeIndice

    mov eax, [numeroActual]
    mov [acumulador], eax

siguienteOperadorTermino:
    mov esi, [indiceLectura]
    mov al, [expresion + esi]

    cmp al, 'x'
    je multiplicarTermino

    cmp al, '/'
    je dividirTermino

    cmp al, '%'
    je moduloTermino

    jmp finProcesarTermino

multiplicarTermino:
    mov byte [operadorPendiente], 'x'
    jmp ejecutarTermino

dividirTermino:
    mov byte [operadorPendiente], '/'
    jmp ejecutarTermino

moduloTermino:
    mov byte [operadorPendiente], '%'

ejecutarTermino:
    inc esi
    mov [indiceLectura], esi

    stdcall LeerEnteroDesdeIndice

    stdcall EvaluarOperacion

    cmp byte [estadoCalculo], 2
    je finProcesarTermino

    jmp siguienteOperadorTermino

finProcesarTermino:
    mov eax, [acumulador]
    mov [resultadoTermino], eax

    pop esi
    ret
endp
proc EvaluarConPrecedencia
    push esi

    mov dword [indiceLectura], 0
    mov dword [resultadoTotal], 0
    mov byte [operadorTermino], '+'
    mov byte [estadoCalculo], 1

siguienteTermino:
    stdcall ProcesarTermino

    cmp byte [estadoCalculo], 2
    je finEvaluarPrecedencia

    mov eax, [resultadoTermino]

    cmp byte [operadorTermino], '-'
    je restarTermino

    add [resultadoTotal], eax
    jmp revisarSiguienteOperador

restarTermino:
    sub [resultadoTotal], eax

revisarSiguienteOperador:
    mov esi, [indiceLectura]
    mov al, [expresion + esi]

    cmp al, 0
    je finEvaluarPrecedencia

    cmp al, '+'
    je guardarSignoTermino

    cmp al, '-'
    je guardarSignoTermino

    jmp finEvaluarPrecedencia

guardarSignoTermino:
    mov [operadorTermino], al

    inc esi
    mov [indiceLectura], esi

    jmp siguienteTermino

finEvaluarPrecedencia:
    mov eax, [resultadoTotal]
    mov [acumulador], eax

    pop esi
    ret
endp
proc ProbarPrecedencia
    mov byte [expresion], '7'
    mov byte [expresion+1], '.'
    mov byte [expresion+2], '5'
    mov byte [expresion+3], '/'
    mov byte [expresion+4], '2'
    mov byte [expresion+5], '.'
    mov byte [expresion+6], '5'
    mov byte [expresion+7], 0

    stdcall EvaluarConPrecedencia

    invoke SetDlgItemInt, [pWnd], ventana_operacion, [acumulador], 0

    ret
endp
proc ProbarTermino
    mov byte [expresion], '3'
    mov byte [expresion+1], 'x'
    mov byte [expresion+2], '4'
    mov byte [expresion+3], 0

    mov dword [indiceLectura], 0
    mov byte [estadoCalculo], 1

    stdcall ProcesarTermino

    invoke SetDlgItemInt, [pWnd], ventana_operacion, [resultadoTermino], 1

    ret
endp
proc ProbarLecturaIndice
    mov byte [expresion], '1'
    mov byte [expresion+1], '2'
    mov byte [expresion+2], '+'
    mov byte [expresion+3], '3'
    mov byte [expresion+4], 'x'
    mov byte [expresion+5], '4'
    mov byte [expresion+6], 0

    mov dword [indiceLectura], 3

    stdcall LeerEnteroDesdeIndice

    invoke SetDlgItemInt, [pWnd], ventana_operacion, [numeroActual], 0

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