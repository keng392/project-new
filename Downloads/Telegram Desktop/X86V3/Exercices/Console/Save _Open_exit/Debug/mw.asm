.Const
ccode Equ code
.Data?

.Data

hwndToolTips			HWND		NULL


.Code

mwProcedure Proc Private hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
	Local uiID:UINT

	.If uMsg == WM_CREATE
		Invoke GetWindowItem, hWnd, IDC_MW_TOOLBAR1 ;Get ToolBar handle in Eax
		Invoke SendMessage, Eax, TB_GETTOOLTIPS, 0, 0		;Get tool tips handle in Eax
		Mov hwndToolTips, Eax								;Store it in 'hwndToolTips'
		Return TRUE
	.ElseIf uMsg == WM_NOTIFY
		;Process tool tips
		Assume Ebx:Ptr NMHDR
		Mov Ebx, lParam
		.If [Ebx].ccode == TTN_NEEDTEXT
			Mov Eax, [Ebx].hwndFrom				;Check if it's tool tips handle
			.If Eax == hwndToolTips				;from the to ToolBar control
				Assume Esi:Ptr TOOLTIPTEXT
				Mov Esi, lParam
				.If [Esi].hdr.idFrom == 1		;Is it button 1 (A)?
					Mov uiID, IDS_1
				.ElseIf [Esi].hdr.idFrom == 2	;Is it button 2 (B)?
					Mov uiID, IDS_2
				.ElseIf [Esi].hdr.idFrom == 3	;Is it button 2 (B)?
					Mov uiID, IDS_3
				.Else
					Mov uiID, 0
				.EndIf
				Mov Eax, uiID
				Mov [Esi].lpszText, Eax
				Mov Eax, App.Instance
				Mov [Esi].hinst, Eax
				Assume Esi:Nothing
			.EndIf
			Assume Ebx:Nothing
		.EndIf
		.EndIf
	Return FALSE
mwProcedure EndP
