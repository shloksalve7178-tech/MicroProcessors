DATA SEGMENT
    NUM1 DW 1234H,2345H,3456H ;HERE A SINGLE 3 BYTE NUMBER IS TAKEN AS AN EXAMPLE  SAVED IN LITTLE ENDIAN FORMAT
    NUM2 DW 0ABCDH,0BCDEH,0CDEFH 
    COUNT DW 3 ;LENGTH OF NUMBER IN NUMBER OF BYTES
    RESSUB DW 3 DUP(?)
    BORROW DW ?
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
        
        ; INPUT NUM1 (3 WORDS) THEN NUM2 (3 WORDS), DL=0 SO 16 BIT INPUT
        LEA SI,NUM1
        CALL TAKEINPUT
        ADD SI,2
        CALL TAKEINPUT
        ADD SI,2
        CALL TAKEINPUT
        
        LEA SI,NUM2
        CALL TAKEINPUT
        ADD SI,2
        CALL TAKEINPUT
        ADD SI,2
        CALL TAKEINPUT
        
        LEA SI,NUM1
        LEA DI,NUM2
        CLC ;MAKE SURE BORROW STARTS AT 0
        PUSHF
        MULBYTESUB:
            CMP CX,COUNT
            JE CARRYSUB
            POPF ;TO GET THE STATE OF FLAGS AFTER THE LAST ADDITION
            MOV AX,[SI]
            SBB AX,[DI]
            PUSHF;SAVE THE STATE OF FLAGS AFTER THE ADDITION
            INC CX
            ADD SI,2
            
            
            ADD DI,2
            
            
            PUSH SI
            LEA SI,RESSUB
            DEC CX
            ADD SI,CX
            ADD SI,CX
            INC CX
            MOV [SI],AX
            POP SI   
            
            
            
            JMP MULBYTESUB
          CARRYSUB:
            POPF   ;TO GET THE STATE OF FLAGS AFTER THE LAST ADDITION OPERATION IN LOOP
            ADC DX,0000H
            LEA SI,BORROW
            
            ADD SI,CX
            ADD SI,CX
            
            MOV [SI],DX;SAVE THE BORROW BIT IF ITS 1 , OUR ANSWER IN RESSUB IS NEGATIVE , ELSE POSITIVE 
            
            CALL DISPLAY
            
            
            
         ENDPROG:
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
        
        ; PRINTS THE RESULT WORDS (MOST SIGNIFICANT FIRST), THEN THE BORROW
        DISPLAY PROC
            PUSH AX
            PUSH BX
            PUSH CX
            PUSH DX
            PUSH SI
            
            LEA SI,RESSUB
            MOV CX,COUNT
            ADD SI,CX
            ADD SI,CX
            SHOWWORDS:
            SUB SI,2
            MOV AX,[SI]
            CALL PRINTHEX
            DEC CX
            JNZ SHOWWORDS
            CALL NEWLINE
            
            MOV DX,BORROW
            AND DL,01H
            ADD DL,'0'
            MOV AH,02H
            INT 21H
            
            POP SI
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
