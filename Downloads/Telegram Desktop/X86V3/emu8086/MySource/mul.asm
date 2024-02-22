
; Program multiple two byte
org 100h ;set address to PC register

.data
   data1 db 34h
   data2 db 57h
   result dw 0000h 
.code 
   MOV AL,data1
   MOV BL,data2
   MUL BL ;AX=AL*BL
   MOV result,ax
     
ret ;return to os