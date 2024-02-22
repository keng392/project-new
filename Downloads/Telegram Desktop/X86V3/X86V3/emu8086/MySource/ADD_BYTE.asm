
; Program add byte
org 100h

.data
    data1 db 50h;data1=50h
    data2 db 60h
    sum   db 00h
.code 
    MOV AL,data1 ;AL=50H
    MOV BL,data2 ;BL=60h
    ADD AL,BL ;   AL=AL+BL
    MOV sum,AL; 
     
ret