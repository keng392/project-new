
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

#start=Traffic_Lights.exe#
.data           
                  ;FEDCBA9876543210
    ;situation   dw 030ch
    s1          dw 0000001100001100b 
    s2          dw 0000001010001010b    
    s3          dw 0000100001100001b
    s4          dw 0000010001010001b
    
    
.code
    Mov si, offset s1
    next:
        mov ax,[si]
        out 4,ax
        mov cx,4Ch
        mov dx,4B40h
        mov ah,86h
        int 15h
        add si,2
        cmp si,010AH
        jb next
        mov si, offset s1
        jmp next

ret




