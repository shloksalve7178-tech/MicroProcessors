DATA SEGMENT 
    NUM1_8 DB ? 
    NUM2_8 DB ? 
    NUM8_RES DW ?
     
    NUM1_16 DW ? 
    NUM2_16 DW ? 
    NUM16_RES DW ? 
    NUM16_CARR DW ? 
DATA ENDS 

CODE SEGMENT 
    ASSUME CS:CODE , DS:DATA 
    
START: 
    MOV AX,DATA 
    MOV DS,AX 
    
    MOV DL,01H 
    LEA SI,NUM1_8 
    CALL TAKEINPUT 
    LEA SI,NUM2_8 
    CALL TAKEINPUT 
    
    MOV DL,00H 
    LEA SI,NUM1_16 
    CALL TAKEINPUT 
    LEA SI,NUM2_16 
    CALL TAKEINPUT 
    
    MOV AX,0000H 
    MOV BX,0000H 
    MOV CX,0000H 
    MOV DX,0000H 
    
    ;8-bit subtraction 
    MOV AL,NUM1_8 
    SUB AL,NUM2_8 
    SBB AH,00H          ; Tracks borrow into AH
    LEA SI,NUM8_RES 
    MOV [SI],AX 
    
    ;16-bit subtraction 
    MOV AX,NUM1_16 
    SUB AX,NUM2_16 
    LEA SI,NUM16_RES 
    MOV [SI],AX 
    PUSHF 
    POP AX 
    LEA SI,NUM16_CARR 
    MOV [SI],AX 
    
    CALL DISPLAY 
    
    MOV AH,4CH 
    INT 21H 

TAKEINPUT PROC 
    PUSH AX 
    PUSH BX 
    PUSH CX 
    
    MOV AX,0000H 
    MOV BX,0000H 
    MOV CX,0000H 
    
    MOV AH,00H 
    INT 16H 
    CMP AL,'A' 
    JGE MAKEINTEGER 
    SUB AL,'0' 
    MOV BL,AL 
    
    MOV AH,00H 
    INT 16H 
    SUB AL,'0' 
    ROL AL,4 
    ADD BL,AL 
    
    CMP DL,01H 
    JZ ENDINPUT 
    
    MOV AH,00H 
    INT 16H 
    SUB AL,'0' 
    ROL AX,8 
    ADD BH,AH 
    
    MOV AH,00H 
    INT 16H 
    SUB AL,'0' 
    ROL AX,12 
    ADD BH,AH 
    
MAKEINTEGER: 
ENDINPUT: 
    MOV [SI],BX 
    POP CX 
    POP BX 
    POP AX 
    RET 
TAKEINPUT ENDP 

DISPLAY PROC 
    PUSH AX 
    PUSH BX 
    PUSH CX 
    PUSH DX 
    
    MOV AX,NUM8_RES 
    CALL PRINTHEX 
    CALL NEWLINE 
    
    MOV AX,NUM16_RES 
    CALL PRINTHEX 
    CALL NEWLINE 
    
    ; Displays 1 if a borrow occurred in the 16-bit subtraction, 0 otherwise
    MOV AX,NUM16_CARR 
    AND AX,0001H 
    MOV DL,AL 
    ADD DL,'0' 
    MOV AH,02H 
    INT 21H 
    
    POP DX 
    POP CX 
    POP BX 
    POP AX 
    RET 
DISPLAY ENDP 

PRINTHEX PROC 
    PUSH BX 
    PUSH CX 
    PUSH DX 
    MOV BX,AX 
    MOV CH,4 
NEXTDIGIT: 
    MOV CL,4 
    ROL BX,CL 
    MOV DL,BL 
    AND DL,0FH 
    CMP DL,9 
    JBE ISDIGIT 
    ADD DL,7 
ISDIGIT: 
    ADD DL,'0' 
    MOV AH,02H 
    INT 21H 
    DEC CH 
    JNZ NEXTDIGIT 
    POP DX 
    POP CX 
    POP BX 
    RET 
PRINTHEX ENDP 

NEWLINE PROC 
    PUSH AX 
    PUSH DX 
    MOV DL,0DH 
    MOV AH,02H 
    INT 21H 
    MOV DL,0AH 
    MOV AH,02H 
    INT 21H 
    POP DX 
    POP AX 
    RET 
NEWLINE ENDP 

CODE ENDS 
END START
