;Division of 32-bit Number by 16-bit Number

MOV DX, 1234H
MOV AX, 5678H   ;NUM = DX:AX

MOV BX, 0025H

DIV BX            ;AX = QUOTIENT , DX = REMAINDER

HLT