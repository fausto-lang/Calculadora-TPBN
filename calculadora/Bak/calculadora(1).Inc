format PE GUI 4.0
entry inicio

include 'Win32a.inc'

ventana_1 equ 1
salir_btn equ 1000

section '.data' data readable writeable
	Ist dd 0
	pWnd dd 0
section '.code' code readable executable
	inicio:
		invoke GetModuleHandle, 0
		mov [Ist], eax
		invoke DialogBoxParam,eax,ventana_1,0,DlgProc, 0
	fin:
		invoke ExitProcess,0
section '.idata' import data readable writeable
section '.rsrc' resource from 'Ejemplo0.res' data readable