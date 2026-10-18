; Division of 16-bit Number by 8-bit Number

MOV AX, 12F1H
MOV BL, 2H

DIV BL     ; AL = QUOTIENT , AH = REMAINDER

HLT    