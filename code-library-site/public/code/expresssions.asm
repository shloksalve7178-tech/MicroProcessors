  
; a = 12, b = 8, c = 7, d = 5

;(a+b)*(c+d) 

MOV AL,0CH
ADD AL,08H

MOV BL,07H
ADD BL,05H

MUL BL

MOV DX,AX 
    

; (a*b)+(c*d)

MOV AL,0CH
MOV BL,08H

MUL BL

MOV CX,AX

MOV AL,07H
MOV BL,05H

MUL BL

ADD AX,CX 
     
HLT