;matrix subtraction

MOV SI,2000H     ;matrix A at 2000H
MOV DI,2100H     ;matrix B at 2100H
MOV BX,2200H     ;result at 2200H

MOV CX,04H

SUBMAT:

MOV AL,[SI]
SUB AL,[DI]

MOV [BX],AL

INC SI
INC DI
INC BX

LOOP SUBMAT

HLT