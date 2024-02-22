Title :program adds two 32_bit number 
.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive
include Tutorial5.inc
include rsrc.inc

.data
    x   		dd     	0
    y   		dd     	0
    r       	dq     	0
    r1			dq     	0
    r2			dq		0
    final       dd		0
    hRadio1 	dd		0
    hRadio2 	dd		0
.code

start:
	invoke	GetModuleHandle,NULL
	mov	hInstance,eax
	invoke	InitCommonControls
	invoke	DialogBoxParam,hInstance,IDD_MAIN,NULL,addr DlgProc,NULL
	invoke	ExitProcess,0

DlgProc	proc	hDlg:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	mov	eax,uMsg
	.if	eax==WM_INITDIALOG
		;get the handle of radio1 to eax
		invoke GetDlgItem, hDlg, IDC_RBN1
		mov hRadio1, eax
		invoke GetDlgItem, hDlg, IDC_RBN2
		mov hRadio2, eax
		;check radio1
		invoke CheckRadioButton,hDlg, IDC_RBN1, IDC_RBN2, IDC_RBN1 
		
	.elseif	eax==WM_COMMAND
		mov ecx,wParam
		movzx eax, cx
		shr ecx,16
		
		.if ecx==BN_CLICKED
			.if eax==IDC_ADD 
				;get the value is check of radio1 to eax
          		Invoke SendMessage, hRadio1, BM_GETCHECK, 0, 0 
          		;;adds two decimal number
          		.if eax == 1
					invoke GetDlgItemInt, hDlg, IDC_EDT1, 0, 1
					mov x, eax
					
					invoke GetDlgItemInt, hDlg, IDC_EDT2, 0, 1
					mov y, eax
					
					mov eax, x
					add eax, y
					
					invoke dwtoa, eax, addr r
					invoke SetDlgItemText, hDlg, IDC_EDT3, addr r
				.else
					
					invoke GetDlgItemText,hDlg,IDC_EDT1, addr x, 9
					Invoke StrToFloat, Addr x, Addr r
					
					invoke GetDlgItemText,hDlg,IDC_EDT2, addr y, 9
					Invoke StrToFloat, Addr y, Addr r1
					
					Fld r
		    		Fld r1
		    		Fadd St(0), St(1)
		    		Fst r2
		    		
		    		Invoke FloatToStr, r2, Addr final
		    		invoke SetDlgItemText, hDlg, IDC_EDT3, addr final
				
				.endif
			.elseif eax==IDC_ADD 
				
			.elseif eax==IDC_BTN5
				invoke	SendMessage,hDlg,WM_CLOSE,NULL,NULL
				
			.endif
		.endif
	.elseif	eax==WM_CLOSE
		invoke	EndDialog,hDlg, 0
	.else
		mov	eax,FALSE
		ret
	.endif
	mov	eax,TRUE
	ret
DlgProc endp

end start
