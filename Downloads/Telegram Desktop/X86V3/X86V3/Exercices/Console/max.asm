;EasyCodeName=Module1,1

;Program Find max n number
Include	masm32rt.inc
Include	debug.inc
IncludeLib	debug.lib
.Data

n DD 0
max DD 0
num DB 1
.Code
start:
	;scan data from keyboar to a variable
	Mov n, sval(input ("Enter n: "))

	.While n != 0
		print "a["
		print sdb$ (num), "]:"
		Mov Eax, sval(input (" "))
		.If max < Eax
			Mov max, Eax	;max=eax=12
		.EndIf
		Inc num
		Dec n
	.EndW
	print "max:"
	print sdd$ (max)
	getkey
	Ret
End start
