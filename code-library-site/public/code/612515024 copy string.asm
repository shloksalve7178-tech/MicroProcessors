org 100h
.model small
.stack 100h
.data
str1 DB 50 DUP(?)
str2 DB 50 DUP(?)
len DW ?
.code
MOV AX, @DATA
MOV DS, AX
MOV ES, AX

LEA SI, str1
MOV CX, 0000H
R1:
MOV AH, 01H
INT 21H
CMP AL, 0DH
JE E1
MOV [SI], AL
INC SI
INC CX
JMP R1
E1:
MOV len, CX

LEA SI, str1
LEA DI, str2
MOV CX, len
CLD
REP MOVSB

ret