         title   xxxx - Normal Window No (.rc)

         .586
         .model flat, stdcall
         option casemap:none   ; Case sensitive

            include  \Masm32V1\include\windows.inc
            include  \Masm32V1\include\user32.inc
            include  \Masm32V1\include\GDI32.inc
            include  \Masm32V1\include\kernel32.inc
            include  \Masm32V1\include\comdlg32.inc
            include  \Masm32V1\include\COMCTL32.inc

   include  \MASM32V1\include\DSPMACRO.asm

         includelib  \Masm32V1\lib\user32.lib
         includelib  \Masm32V1\lib\GDI32.lib
         includelib  \Masm32V1\lib\kernel32.lib
         includelib  \Masm32V1\lib\comdlg32.lib
         includelib  \Masm32V1\lib\COMCTL32.lib

WinMain        PROTO  :DWORD, :DWORD, :DWORD, :DWORD

.const
;EditID         equ 1

.data
;ClassName      db  'xxxx',0
;AppName        db  'xxxx - Normal Window No (.rc) 01',0
;Edit           db  'Edit',0

.data?
;hInst          dd  ?
;CommandLine    dd  ?
;MainExit       dd  ?
;hWnd           dd  ? 
;hEdit          dd  ?

.code

;________________________________________________________________________________
start:
;      INVOKE     GetModuleHandle, NULL
;         mov     hInst, eax
;      INVOKE     GetCommandLine
;         mov     CommandLine, eax
;
;        call     InitCommonControls          ; Initialize the common ctrl lib
;
;      INVOKE     WinMain, hInst ,NULL, CommandLine, SW_SHOWDEFAULT
;         mov     MainExit, eax
;
;      INVOKE     ExitProcess, MainExit

;________________________________________________________________________________
;WinMain proc  uses ebx  hinst:DWORD, hPrevInst, CmdLine, CmdShow
;LOCAL    wc:WNDCLASSEX
;LOCAL    msg:MSG
;;     
;;              mov     wc.cbSize, sizeof WNDCLASSEX
;;              mov     wc.style, CS_HREDRAW or CS_VREDRAW
;;              mov     wc.lpfnWndProc, offset WndProc
;;              mov     wc.cbClsExtra, NULL
;;              mov     wc.cbWndExtra, NULL
;;             push     hInst
;;              pop     wc.hInstance
;;              mov     wc.hbrBackground, COLOR_WINDOW+1
;;              mov     wc.lpszMenuName, 0 ;offset MenuName
;;              mov     wc.lpszClassName, offset ClassName
;;           INVOKE     LoadIcon, NULL, IDI_APPLICATION
;;              mov     wc.hIcon, eax
;;              mov     wc.hIconSm, eax
;;           INVOKE     LoadCursor, NULL, IDC_ARROW
;;              mov     wc.hCursor, eax
;;           INVOKE     RegisterClassEx, addr wc
;;     
;;     ;---------- [Center the window] ----------
;;           INVOKE     GetSystemMetrics, SM_CXSCREEN
;;              sub     eax, 350
;;              shr     eax, 1
;;             push     eax
;;           INVOKE     GetSystemMetrics, SM_CYSCREEN
;;              sub     eax, 250
;;              shr     eax, 1
;;              pop     ebx
;;     
;;           INVOKE     CreateWindowEx, WS_EX_CLIENTEDGE, addr ClassName,\
;;                      addr AppName, WS_OVERLAPPEDWINDOW,\
;;                      ebx, eax, 350, 250, NULL, NULL, hInst, NULL
;;              mov     hWnd, eax
;;     
;;           INVOKE     ShowWindow, hWnd, SW_SHOWNORMAL
;;           INVOKE     UpdateWindow, hWnd
;;           .while TRUE
;;              INVOKE     GetMessage, addr msg, NULL, 0, 0
;;                 .BREAK .IF (!eax)
;;                 INVOKE     TranslateMessage, addr msg
;;                 INVOKE     DispatchMessage, addr msg
;;           .endw
;;         mov     eax, msg.wParam
;      ret
;WinMain endp
;
;;________________________________________________________________________________
;WndProc proc  uses edx  hwnd:DWORD, wMsg, wParam, lParam
;;      .if wMsg == WM_CREATE
;;         INVOKE     CreateWindowEx, NULL, addr Edit, NULL,\
;;                    WS_VISIBLE or WS_CHILD or ES_LEFT or ES_MULTILINE or\
;;                    ES_AUTOHSCROLL or ES_AUTOVSCROLL,\
;;                    0, 0, 0, 0, hwnd, EditID, hInst, NULL
;;            mov     hEdit, eax
;;         INVOKE     SendMessage, hEdit, EM_EXLIMITTEXT, 0, 100000
;;         INVOKE     SetFocus, hEdit
;;
;;      .elseif wMsg == WM_SIZE
;;            mov     eax, lParam
;;            mov     edx, eax
;;            shr     edx, 16
;;            and     eax, 0ffffh
;;         INVOKE     MoveWindow, hEdit, 0, 0, eax, edx, TRUE
;;
;;      .elseif wMsg == WM_DESTROY
;;        INVOKE     PostQuitMessage, NULL
;;
;;      .elseif wMsg == WM_COMMAND
;;            mov     eax, wParam
;;           cwde                         ; Only low word contains command
;;
;;         .if eax == WM_CLOSE
;;            INVOKE     DestroyWindow, hwnd
;;         .endif
;;
;;      .else
;;
;;DefWin:
;;         INVOKE     DefWindowProc, hwnd, wMsg, wParam, lParam
;;            ret
;;      .endif
;;
;;         xor    eax, eax
;;         ret
;WndProc endp


end start
;INVOKE     MessageBox, NULL, addr szText, addr AppName, MB_OK
