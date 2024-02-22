;EasyCodeName=Module1,1

;Program calculate money to confide the bike

Include	masm32rt.inc
Include	debug.inc
IncludeLib	debug.lib

.Data
stime DD 0
etime DD 0
hundred DD 100
two_hundred DD 200
amount DQ 0
amount1 DQ 0
.Code
start:
	Mov stime, sval(input ("Enter start time:"))
	Mov etime, sval(input ("Enter start time:"))

	Mov Ebx, stime
	Mov Eax, etime

	.If Ebx < 16 ;ebx is start time
		.If Eax < 16 ;eax is end time
			Sub Eax, Ebx
			Mul DWord Ptr hundred ; direct am(mul mem)
			Mov DWord Ptr amount, Eax
			Mov DWord Ptr amount + 4, Edx
		.Else
			Mov Esi, 16
			Sub Esi, Ebx ;time=16-stimem
			Mov Eax, Esi
			Mul DWord Ptr hundred ; direct am(mul mem)
			Mov DWord Ptr amount, Eax
			Mov DWord Ptr amount + 4, Edx
			Mov Eax, etime
			Sub Eax, 16 ;time=16-stime
			Mul DWord Ptr two_hundred ; direct am(mul mem)
			Mov DWord Ptr amount1, Eax
			Mov DWord Ptr amount1 + 4, Edx
			Mov Eax, DWord Ptr amount
			Add Eax, DWord Ptr amount1
			Mov Ecx, DWord Ptr amount + 2
			Adc Ecx, DWord Ptr amount1 + 2
			Mov DWord Ptr amount, Eax
			Mov DWord Ptr amount + 2, Ecx
			.EndIf

	.Else
		Sub Eax, Ebx
		Mul DWord Ptr two_hundred ; direct am(mul mem)
		Mov DWord Ptr amount, Eax
		Mov DWord Ptr amount + 4, Edx
	.EndIf
	print "amount="
	print sqword$ (amount), 13, 10
	getkey
	Ret
End start
