;factorial using recursion  

MOV AX,06H      ;6!

CALL FACT

HLT

FACT:
CMP AX,01H
JE DONE

PUSH AX
DEC AX

CALL FACT

POP BX
MUL BX

DONE:
RET