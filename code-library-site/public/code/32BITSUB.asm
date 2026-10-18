DATA SEGMENT
    NUM1_L DW 1234H
    NUM1_H DW 4567H
    
    NUM2_L DW 0ABCDH
    NUM2_H DW 0EF10H
    
    DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
    
    START:
    MOV AX,DATA
    MOV DS,AX
    
    MOV AX,0000H
    MOV BX,0000H
    MOV CX,0000H
    MOV DX,0000H
    
    ; INPUT LOW WORD THEN HIGH WORD OF NUM1, THEN OF NUM2 (DL=0 SO 16 BIT INPUT)
    LEA SI,NUM1_L
    CALL TAKEINPUT
    LEA SI,NUM1_H
    CALL TAKEINPUT
    LEA SI,NUM2_L
    CALL TAKEINPUT
    LEA SI,NUM2_H
    CALL TAKEINPUT
    
    MOV AX,NUM1_L
    MOV BX,NUM1_H
    ADD AX,NUM2_L
    
    SBB BX,NUM2_H
    MOV CX,AX
    
    ;CX HAS LOWER BYTE , BX THE UPPER AND DX THE  CARRY FLAG I.E. 33RD BIT
    
    ADC DX,0000H  ;STORES CARRY FLAG , IF 1 ANSWER IS NEGATIVE ELSE POSITVE
    
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
    
    ; PRINTS THE 32 BIT RESULT (BX:CX) ON ONE LINE, THEN THE CARRY/BORROW (DX)
    DISPLAY PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        
        MOV AX,BX
        CALL PRINTHEX
        MOV AX,CX
        CALL PRINTHEX
        CALL NEWLINE
        
        AND DL,01H
        ADD DL,'0'
        MOV AH,02H
        INT 21H
        
        POP DX
        POP CX
        POP BX
        POP AX
        
        RET
    DISPLAY ENDP
    
    ; PRINTS AX AS 4 HEX DIGITS
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
