format PE GUI 4.0
entry inicio

include 'Win32a.inc'

ventana_1              equ 1
salir_btn              equ 1000
ventana_operacion       equ 1001
ventana_resultado       equ 1002
borrar_btn              equ 1003
retroceder_btn          equ 1004
division                equ 1005
modulo                  equ 1006
multiplicacion          equ 1007
nueve                   equ 1008
ocho                    equ 1009
siete                   equ 1010
suma                    equ 1011
tres                    equ 1012
dos                     equ 1013
uno                     equ 1014
resta                   equ 1015
seis                    equ 1016
cinco                   equ 1017
cuatro                  equ 1018
boton_resultado         equ 1020
punto                   equ 1021
cero                    equ 1022

section '.data' data readable writeable

pWnd                    dd 0
acumulador              dd 0
numeroActual            dd 0
operadorPendiente       db 0
operacionValida         db 0
estadoCalculo           db 0
expresion               rb 100
pantalla                rb 150
resultadoTexto          db '0', 0
errorTexto              db 'Error', 0
posicion                dd 0
indiceLectura           dd 0
signoNumero             dd 1
parteDecimal            dd 0
parteIntResultado       dd 0
parteDoubleResul        dd 0
escalaDecimal           dd 100
resultadoTotal          dd 0
resultadoTermino        dd 0
operadorTermino         db '+'
formatoResultado        db '%s%d.%02d', 0
signoPositivo           db '', 0
signoNegativo           db '-', 0

section '.code' code readable executable

inicio:
    invoke GetModuleHandle, 0
    invoke DialogBoxParam, eax, ventana_1, 0, DlgProc, 0
    invoke ExitProcess, 0

proc DlgProc hWnd, uMsg, wParam, lParam
    push ebx

    mov eax, [uMsg]
    cmp eax, WM_INITDIALOG
    je dialogoInicializado

    cmp eax, WM_COMMAND
    je comando

    cmp eax, WM_CLOSE
    je cerrarVentana

    xor eax, eax
    jmp finDlgProc

dialogoInicializado:
    mov eax, [hWnd]
    mov [pWnd], eax
    stdcall BorrarTodo
    mov eax, 1
    jmp finDlgProc

comando:
    mov eax, [wParam]
    and eax, 0FFFFh

    cmp eax, salir_btn
    je cerrarVentana

    cmp eax, cero
    je digito0
    cmp eax, uno
    je digito1
    cmp eax, dos
    je digito2
    cmp eax, tres
    je digito3
    cmp eax, cuatro
    je digito4
    cmp eax, cinco
    je digito5
    cmp eax, seis
    je digito6
    cmp eax, siete
    je digito7
    cmp eax, ocho
    je digito8
    cmp eax, nueve
    je digito9

    cmp eax, suma
    je operadorSuma
    cmp eax, resta
    je operadorResta
    cmp eax, multiplicacion
    je operadorMultiplicacion
    cmp eax, division
    je operadorDivision
    cmp eax, modulo
    je operadorModulo

    cmp eax, punto
    je agregarPunto

    cmp eax, boton_resultado
    je calcularResultado

    cmp eax, borrar_btn
    je borrarTodo

    cmp eax, retroceder_btn
    je retroceder

    xor eax, eax
    jmp finDlgProc

digito0:
    stdcall AgregarDigito, 0
    jmp comandoProcesado
digito1:
    stdcall AgregarDigito, 1
    jmp comandoProcesado
digito2:
    stdcall AgregarDigito, 2
    jmp comandoProcesado
digito3:
    stdcall AgregarDigito, 3
    jmp comandoProcesado
digito4:
    stdcall AgregarDigito, 4
    jmp comandoProcesado
digito5:
    stdcall AgregarDigito, 5
    jmp comandoProcesado
digito6:
    stdcall AgregarDigito, 6
    jmp comandoProcesado
digito7:
    stdcall AgregarDigito, 7
    jmp comandoProcesado
digito8:
    stdcall AgregarDigito, 8
    jmp comandoProcesado
digito9:
    stdcall AgregarDigito, 9
    jmp comandoProcesado

operadorSuma:
    stdcall AgregarOperador, '+'
    jmp comandoProcesado
operadorResta:
    stdcall AgregarOperador, '-'
    jmp comandoProcesado
operadorMultiplicacion:
    stdcall AgregarOperador, 'x'
    jmp comandoProcesado
operadorDivision:
    stdcall AgregarOperador, '/'
    jmp comandoProcesado
operadorModulo:
    stdcall AgregarOperador, '%'
    jmp comandoProcesado

agregarPunto:
    stdcall AgregarPunto
    jmp comandoProcesado

calcularResultado:
    stdcall ProcesarOperacion
    cmp byte [estadoCalculo], 1
    je mostrarResultado

    cmp byte [estadoCalculo], 2
    je mostrarError

    jmp comandoProcesado

mostrarResultado:
    stdcall MostrarResultadoDecimal
    jmp comandoProcesado

mostrarError:
    invoke SetDlgItemText, [pWnd], ventana_resultado, errorTexto
    jmp comandoProcesado

borrarTodo:
    stdcall BorrarTodo
    jmp comandoProcesado

retroceder:
    stdcall Retroceder
    jmp comandoProcesado

comandoProcesado:
    mov eax, 1
    jmp finDlgProc

cerrarVentana:
    invoke EndDialog, [hWnd], 0
    mov eax, 1

finDlgProc:
    pop ebx
    ret
endp

proc AgregarDigito, digito
    mov eax, [digito]
    add eax, '0'
    stdcall AgregarCaracter, eax
    ret
endp

proc AgregarCaracter, caracter
    push eax
    push ecx

    mov eax, [posicion]
    cmp eax, 98
    jge finAgregarCaracter

    mov ecx, [caracter]
    mov [expresion + eax], cl
    inc eax
    mov [posicion], eax
    mov byte [expresion + eax], 0

    stdcall ActualizarPantallas

finAgregarCaracter:
    pop ecx
    pop eax
    ret
endp

proc AgregarOperador, operador
    push eax
    push ecx

    mov eax, [posicion]
    cmp eax, 98
    jge finAgregarOperador

    ; La resta puede representar un numero negativo.
    mov ecx, [operador]
    cmp cl, '-'
    je insertarOperador

    ; Los demas operadores necesitan un numero antes.
    cmp eax, 0
    je finAgregarOperador

    mov cl, [expresion + eax - 1]
    cmp cl, '+'
    je finAgregarOperador
    cmp cl, '-'
    je finAgregarOperador
    cmp cl, 'x'
    je finAgregarOperador
    cmp cl, '/'
    je finAgregarOperador
    cmp cl, '%'
    je finAgregarOperador
    cmp cl, '.'
    je finAgregarOperador

    mov ecx, [operador]

insertarOperador:
    mov [expresion + eax], cl
    inc eax
    mov [posicion], eax
    mov byte [expresion + eax], 0
    stdcall ActualizarPantallas

finAgregarOperador:
    pop ecx
    pop eax
    ret
endp

proc AgregarPunto
    push eax
    push esi

    mov eax, [posicion]
    cmp eax, 0
    je finAgregarPunto

    mov esi, eax
    dec esi

    mov al, [expresion + esi]
    cmp al, '0'
    jl finAgregarPunto
    cmp al, '9'
    jg finAgregarPunto

buscarPuntoAnterior:
    mov al, [expresion + esi]
    cmp al, '.'
    je finAgregarPunto

    cmp al, '+'
    je insertarPunto
    cmp al, '-'
    je insertarPunto
    cmp al, 'x'
    je insertarPunto
    cmp al, '/'
    je insertarPunto
    cmp al, '%'
    je insertarPunto

    cmp esi, 0
    je insertarPunto

    dec esi
    jmp buscarPuntoAnterior

insertarPunto:
    stdcall AgregarCaracter, '.'

finAgregarPunto:
    pop esi
    pop eax
    ret
endp

proc Retroceder
    push eax

    mov eax, [posicion]
    cmp eax, 0
    je finRetroceder

    dec eax
    mov [posicion], eax
    mov byte [expresion + eax], 0
    stdcall ActualizarPantallas

finRetroceder:
    pop eax
    ret
endp

proc BorrarTodo
    mov dword [posicion], 0
    mov byte [expresion], 0
    mov byte [resultadoTexto], '0'
    mov byte [resultadoTexto + 1], 0
    stdcall ActualizarPantallas
    ret
endp

proc ActualizarPantallas
    invoke SetDlgItemText, [pWnd], ventana_operacion, expresion
    invoke SetDlgItemText, [pWnd], ventana_resultado, resultadoTexto
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
    cdq
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

proc ValidarOperacion
    push esi
    push ecx

    mov byte [operacionValida], 0
    xor esi, esi

validarNumero:
    ; Signo negativo opcional.
    mov al, [expresion + esi]
    cmp al, '-'
    jne exigirDigito
    inc esi

exigirDigito:
    ; Debe existir al menos un digito entero.
    mov al, [expresion + esi]
    cmp al, '0'
    jl finValidacion
    cmp al, '9'
    jg finValidacion

recorrerEnteros:
    inc esi
    mov al, [expresion + esi]
    cmp al, '0'
    jl revisarPunto
    cmp al, '9'
    jle recorrerEnteros

revisarPunto:
    cmp al, '.'
    jne revisarOperador

    inc esi
    mov al, [expresion + esi]
    cmp al, '0'
    jl finValidacion
    cmp al, '9'
    jg finValidacion

    ; Primer decimal.
    inc esi
    mov al, [expresion + esi]
    cmp al, '0'
    jl revisarOperador
    cmp al, '9'
    jg revisarOperador

    ; Segundo decimal. Un tercer decimal no est? permitido.
    inc esi
    mov al, [expresion + esi]
    cmp al, '0'
    jl revisarOperador
    cmp al, '9'
    jle finValidacion

revisarOperador:
    mov al, [expresion + esi]
    cmp al, 0
    je expresionCorrecta

    cmp al, '+'
    je avanzarOperador
    cmp al, '-'
    je avanzarOperador
    cmp al, 'x'
    je avanzarOperador
    cmp al, '/'
    je avanzarOperador
    cmp al, '%'
    je avanzarOperador

    jmp finValidacion

avanzarOperador:
    inc esi
    jmp validarNumero

expresionCorrecta:
    mov byte [operacionValida], 1

finValidacion:
    pop ecx
    pop esi
    ret
endp

proc LeerEnteroDesdeIndice
    push esi
    push ebx

    mov dword [numeroActual], 0
    mov dword [parteDecimal], 0
    mov dword [signoNumero], 1

    mov esi, [indiceLectura]

    mov al, [expresion + esi]
    cmp al, '-'
    jne leerParteEntera

    mov dword [signoNumero], -1
    inc esi

leerParteEntera:
    movzx ecx, byte [expresion + esi]
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
    cmp byte [expresion + esi], '.'
    jne finalizarNumero

    inc esi
    movzx ecx, byte [expresion + esi]
    sub cl, '0'
    mov [parteDecimal], ecx

    ; Si solo hay un decimal, se convierte a centesimas.
    inc esi
    mov al, [expresion + esi]
    cmp al, '0'
    jl ajustarDecimal
    cmp al, '9'
    jg ajustarDecimal

    movzx ecx, al
    sub ecx, '0'
    mov eax, [parteDecimal]
    imul eax, 10
    add eax, ecx
    mov [parteDecimal], eax
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

proc ProcesarOperacion
    mov byte [estadoCalculo], 0

    stdcall ValidarOperacion
    cmp byte [operacionValida], 1
    jne finProcesarOperacion

    mov byte [estadoCalculo], 1
    stdcall EvaluarConPrecedencia

finProcesarOperacion:
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

    cinvoke wsprintf, resultadoTexto, formatoResultado, esi, [parteIntResultado], [parteDoubleResul]
    invoke SetDlgItemText, [pWnd], ventana_resultado, resultadoTexto

    pop esi
    pop ebx
    pop eax
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
       SetDlgItemText, 'SetDlgItemTextA', \
       wsprintf,       'wsprintfA'

section '.rsrc' resource from 'calculadora.res' data readable
