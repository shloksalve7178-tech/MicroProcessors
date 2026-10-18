;Fibonacci series of n terms              

MOV CX,08H       ;CX + 2 TERMS
MOV AX, 0000H
mov DS, AX     
MOV SI,2000H

MOV AX,0000H
MOV BX,0001H

MOV [SI],AX
ADD SI,2

MOV [SI],BX
ADD SI,2

NEXT:
ADD AX,BX
XCHG AX,BX

MOV [SI],BX
ADD SI,2

LOOP NEXT

HLT