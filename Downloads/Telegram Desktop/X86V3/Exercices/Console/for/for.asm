;EasyCodeName=Module1,1
Include	masm32rt.inc
Include	debug.inc
IncludeLib	debug.lib
.Data

hInst	HINSTANCE	NULL


.Code

start:
	Invoke GetModuleHandle, NULL
	Mov hInst, Eax
	Call Main
	Invoke ExitProcess, 0

Main Proc Private
	Local count
	count = 0
	For item, < args >
		count == count + 1

	Ret
Main EndP

End start
