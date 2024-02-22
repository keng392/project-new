;Title :
org 100h
.data

.code
    mov al, 90h
    mov dx, 0ff26h
    out dx, al
back:
    mov dx, 0ff20h
    in  al, dx
    mov dx, 0ff22h
    out dx, al
    jmp back
ret