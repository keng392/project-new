         title   xxxx - Normal Window with (.rc)

         .586
         .model flat, stdcall
         option casemap:none   ; Case sensitive

            include  windows.inc
            include  user32.inc
            include  GDI32.inc
            include  kernel32.inc
            include  comdlg32.inc
            include  COMCTL32.inc

		 \X86V2\include\DSPMACRO.asm

         includelib  user32.lib
         includelib  GDI32.lib
         includelib  kernel32.lib
         includelib  comdlg32.lib
         includelib  COMCTL32.lib

WinMain        PROTO  :DWORD, :DWORD, :DWORD, :DWORD
SetColor       PROTO  :DWORD, :DWORD, :DWORD, :DWORD

.const
EditID         equ 1
IDM_EXIT       equ 2
IDM_COLOR      equ 3

.data
ClassName      db  'xxxx',0
AppName        db  'xxxx - Normal Window with (.rc) 02',0
RichEdit       db  'RichEdit20A',0
RichEdDLL      db  'RICHED20.DLL',0
MenuName       db  'MainMenu',0
dlgname        db  'SetColors',0
szText         db  0Dh,0Ah
               db  ' H A V E   A   N I C E   D A Y !',0

szError1       db  'The RICHED20.DLL was not found!',0

.data?
hInst          dd  ?
CommandLine    dd  ?
hREdDll        dd  ?
MainExit       dd  ?
hWnd           dd  ? 
hREdit         dd  ?

.code

;________________________________________________________________________________
start:
      INVOKE     GetModuleHandle, NULL
         mov     hInst, eax
      INVOKE     GetCommandLine
         mov     CommandLine, eax

        call     InitCommonControls          ; Initialize the common ctrl lib
      INVOKE     LoadLibrary, addr RichEdDLL ; Load the Riched20.dll
         mov     hREdDll, eax
      .if !eax
         INVOKE     MessageBox, NULL, addr szError1, addr AppName, MB_OK or MB_ICONERROR
            jmp     NoGo
      .endif

      INVOKE     WinMain, hInst ,NULL, CommandLine, SW_SHOWDEFAULT
         mov     MainExit, eax
      INVOKE     FreeLibrary, hREdDll

NoGo:
      INVOKE     ExitProcess, MainExit

;________________________________________________________________________________
WinMain proc  uses ebx  hinst:DWORD, hPrevInst, CmdLine, CmdShow
LOCAL    wc:WNDCLASSEX
LOCAL    msg:MSG

         mov     wc.cbSize, sizeof WNDCLASSEX
         mov     wc.style, CS_HREDRAW or CS_VREDRAW
         mov     wc.lpfnWndProc, offset WndProc
         mov     wc.cbClsExtra, NULL
         mov     wc.cbWndExtra, NULL
        push     hInst
         pop     wc.hInstance
         mov     wc.hbrBackground, COLOR_WINDOW+1
         mov     wc.lpszMenuName, offset MenuName
         mov     wc.lpszClassName, offset ClassName
      INVOKE     LoadIcon, NULL, IDI_APPLICATION
         mov     wc.hIcon, eax
         mov     wc.hIconSm, eax
      INVOKE     LoadCursor, NULL, IDC_ARROW
         mov     wc.hCursor, eax
      INVOKE     RegisterClassEx, addr wc

;---------- [Center the window] ----------
      INVOKE     GetSystemMetrics, SM_CXSCREEN
         sub     eax, 350
         shr     eax, 1
        push     eax
      INVOKE     GetSystemMetrics, SM_CYSCREEN
         sub     eax, 250
         shr     eax, 1
         pop     ebx

      INVOKE     CreateWindowEx, WS_EX_CLIENTEDGE, addr ClassName,\
                 addr AppName, WS_OVERLAPPEDWINDOW,\
                 ebx, eax, 350, 250, NULL, NULL, hInst, NULL
         mov     hWnd, eax

      INVOKE     ShowWindow, hWnd, SW_SHOWNORMAL
      INVOKE     UpdateWindow, hWnd
      .while TRUE
         INVOKE     GetMessage, addr msg, NULL, 0, 0
            .BREAK .IF (!eax)
            INVOKE     TranslateMessage, addr msg
            INVOKE     DispatchMessage, addr msg
      .endw
         mov     eax, msg.wParam
         ret
WinMain endp

;________________________________________________________________________________
WndProc proc  uses edx  hwnd:DWORD, wMsg, wParam, lParam
      .if wMsg == WM_CREATE
         INVOKE     CreateWindowEx, NULL, addr RichEdit, NULL,\
                    WS_VISIBLE or WS_CHILD or ES_LEFT or ES_MULTILINE or\
                    ES_AUTOHSCROLL or ES_AUTOVSCROLL,\
                    0, 0, 0, 0, hwnd, EditID, hInst, NULL
            mov     hREdit, eax

         INVOKE     SendMessage, hREdit, EM_EXLIMITTEXT, 0, 100000
         INVOKE     SetFocus, hREdit

      .elseif wMsg == WM_SIZE
            mov     eax, lParam
            mov     edx, eax
            shr     edx, 16
            and     eax, 0ffffh
         INVOKE     MoveWindow, hREdit, 0, 0, eax, edx, TRUE

      .elseif wMsg == WM_DESTROY
        INVOKE     PostQuitMessage, NULL

      .elseif wMsg == WM_COMMAND
            mov     eax, wParam
           cwde                         ; Only low word contains command

         .if eax == IDM_COLOR
            INVOKE     DialogBoxParam, hInst, addr dlgname, 0, addr SetColor, 0

         .elseif eax == IDM_EXIT
            INVOKE     DestroyWindow, hwnd
         .endif

      .else

DefWin:
         INVOKE     DefWindowProc, hwnd, wMsg, wParam, lParam
            ret
      .endif

         xor    eax, eax
         ret
WndProc endp

;________________________________________________________________________________
SetColor proc  hdlg:DWORD, wMsg, wParam, lParam
LOCAL    charF:CHARFORMAT2

      .if wMsg == WM_COMMAND
         .if wParam == IDCANCEL
               jmp     GetOut

         .elseif wParam == 401              ; SetColors
            INVOKE     SendMessage, hREdit, EM_SETBKGNDCOLOR, 0, 00000000h ;00GGBBRRh
               mov     charF.cbSize, sizeof charF
               mov     charF.dwEffects, 0
               mov     charF.yHeight, 240
               mov     charF.dwMask, CFM_FACE or CFM_SIZE or CFM_COLOR
               mov     charF.crTextColor, 0000ff00h
               mov     charF.crBackColor, 00000000h
            INVOKE     SendMessage, hREdit, EM_SETCHARFORMAT, SCF_ALL, addr charF
            INVOKE     SendMessage, hREdit, WM_SETTEXT, NULL, addr szText
            INVOKE     SetFocus, hREdit
               jmp     GetOut
         .endif

      .elseif wMsg == WM_CLOSE

GetOut:
         INVOKE     EndDialog, hdlg, wParam ; End the dialog with wparam as return
            mov     eax, TRUE               ; Return
            jmp     SetColorRet             ; with TRUE

      .endif

Ret0:
         xor     eax, eax

SetColorRet:
         ret
SetColor endp

end start
;INVOKE     MessageBox, NULL, addr szText, addr AppName, MB_OK
