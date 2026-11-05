format PE GUI 4.0
entry inicio

include 'Win32a.inc'

ventana1 equ 1
salir_btn equ 1000

section '.data' data readable writeable
section '.code' code readable executable
section '.idata' import data readable writeable
section '.rarc' resource  'Ejemplo0.res' data readable

