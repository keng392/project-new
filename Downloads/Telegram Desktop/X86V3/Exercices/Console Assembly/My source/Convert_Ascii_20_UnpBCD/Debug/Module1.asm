;Convert Ascii to unpacked BCD
Include	masm32rt.inc
Include	debug.inc
IncludeLib	DEBUG.lib
.Data

ascii DB "3456"
unp_bcd DB 100 Dup(0)
i DD 0
j DD 0
n DD 0
.Code

start:
	
	 ;print Offset ascii

	 Mov n, LengthOf ascii
	 m2m i, n
	 m2m j, n
	 Push n
	 Lea Esi, ascii
     Lea Edi, unp_bcd
	.While n != 0
		Mov Al, [Esi]
		And Al, 0FH
		Mov [Edi + 3], Al
		Inc Esi
		Dec Edi
		Dec n
	.EndW
	;Pop n
	Lea Esi, ascii
	print "Ascii", 09, 09, "Unpacked", 13, 10
	.While i != 0
		Mov Al, [Esi]
		print xdb$ (Al), 09, 09
		Inc Esi
		Dec i
	.EndW
	;PrintDec n
	;Lea Esi, unp_bcd
	;print "Ascii", 09, 09, "Unpacked", 13, 10
	;.While j != 0
	;	Mov Al, [Edi]
	;	print xdb$ (Al)
	;	Inc Edi
	;	Dec j
	;.EndW
	getkey
	Ret
End start
