;Program display dec,hex,string and binary in debug program

Include	masm32rt.inc
Include	debug.inc
IncludeLib	debug.lib

.Data
FloatNum Real4 100.25
DecNum DD 12345678
HexaNum DD 12345678H ;Store in memory think from right to left
sstr DB "ABCDEFGH", 0 ; Store in memory think from left to right

.Code ; Tell Easy Code where the code starts

; ==========================================================================
start:                          ; The CODE entry point to the program

    call main                   ; branch to the "main" procedure
	getkey
    exit
; ...........................................................................

main proc
	Mov Eax, HexaNum
	PrintHex Eax ; Print the value in eax in hexa
	ASSERT Eax
	PrintDec Eax ; Print the value in eax in decimal
	PrintHex Ax
	PrintHex Al
	PrintHex Ah
	;PrintHex Ecx
	PrintLine
	DbgDump Offset FloatNum, 16
	DbgDump Offset DecNum, 16
	DbgDump Offset HexaNum, 16
	DbgDump Offset sstr, 16
	DumpMem Offset sstr, 16
	getkey
    Ret                         ; return to the next instruction after "call"

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

End start                       ; Tell MASM where the program ends

;Ouput screen
;Eax = 12345678 (Module1.asm, 25)
;Eax = 305419896 (Module1.asm, 26)
;Ax = 5678 (Module1.asm, 27)
;Al = 78 (Module1.asm, 28)
;Ah = 56 (Module1.asm, 29)
;----------------------------------------
;Data In Memory
;00404000:  00 80 C8 42-->FloatNum=42C88000H
;00404000:  4E 61 BC -->DecNum=BC614Eh
;00404004:  78 56 34 12-->HeaxNum:12345678H
;00404008:  41 42 43 44-45 46 47 48
