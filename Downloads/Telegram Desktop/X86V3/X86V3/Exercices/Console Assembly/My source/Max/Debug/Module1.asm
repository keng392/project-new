;program how to find max
Include	masm32rt.inc
Include	debug.inc
IncludeLib	debug.lib

;---------------------------------------------------
.Data
n DD 0
num DD 0
a DD 0
max DD 0
.Code
;===================================================
start:
	Mov n, sval(input ("Enter n="))
	.While n != 0
		Inc num ;
		print "a["
		print sdd$ (num), "]"
		Mov Eax, sval(input (": "))
		.If max < Eax
			Mov max, Eax ;max=eax
		.EndIf
		Dec n
	.EndW
	loc 35, 15
	print " max:"
	print sdd$ (max)
	getkey
	Ret
End start
