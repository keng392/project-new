         title   win

         .586
         .model flat, stdcall
         option casemap:none   ; Case sensitive
	    include xxxx.inc

;===================================================================
; 					  Data section
;===================================================================
.const

.data?

.data

.code
;====================================================================
; 			  Program initialization section
;====================================================================
start:
          INVOKE GetModuleHandle, NULL
          mov hInst, eax
          INVOKE GetCommandLine
          mov CommandLine, eax
          
          call InitCommonControls
          
          INVOKE WinMain, hInst ,NULL, CommandLine, SW_SHOWDEFAULT
          mov MainExit, eax
          INVOKE ExitProcess, MainExit
;====================================================================
;					 WinMain procedure
;====================================================================
WinMain proc  uses ebx  hinst:DWORD, hPrevInst, CmdLine, CmdShow
LOCAL    wc:WNDCLASSEX
LOCAL    msg:MSG
Local    hwnd
          mov wc.cbSize, sizeof WNDCLASSEX
          mov wc.style, CS_HREDRAW or CS_VREDRAW
          mov wc.lpfnWndProc, offset WndProc
          mov wc.cbClsExtra, NULL
          mov wc.cbWndExtra, NULL
          MOVmd wc.hInstance, hInst
          mov wc.hbrBackground, COLOR_BTNFACE+1
          mov wc.lpszMenuName, offset MenuName
          mov wc.lpszClassName, offset ClassName
          INVOKE LoadIcon, NULL, IDI_APPLICATION
          mov wc.hIcon, eax
          mov wc.hIconSm, eax
          INVOKE  LoadCursor, NULL, IDC_ARROW
          mov wc.hCursor, eax
          INVOKE RegisterClassEx, addr wc
;------------------- [Center the window] -------------------------
          INVOKE GetSystemMetrics, SM_CXSCREEN
          sub eax, 350
          shr eax, 1
          push eax
          INVOKE GetSystemMetrics, SM_CYSCREEN
          sub eax, 300
          shr eax, 1
          pop ebx
;------------------- [Create the Main Window] ----------------------
          INVOKE CreateWindowEx, WS_EX_CLIENTEDGE, addr ClassName,\
                 addr AppName, WS_OVERLAPPEDWINDOW,\
                 ebx, eax, 350, 300, NULL, NULL, hInst, NULL
          mov hwnd, eax
          
          INVOKE ShowWindow, hwnd, SW_SHOWNORMAL
          INVOKE UpdateWindow, hwnd
;------------------- [Message loop] ---------------------------------
      .while TRUE
         INVOKE GetMessage, addr msg, NULL, 0, 0
            .break .if (!eax)
            INVOKE TranslateMessage, addr msg
            INVOKE DispatchMessage, addr msg
      .endw
         mov eax, msg.wParam
         ret
WinMain endp
;====================================================================
; 				WinProc procedure
;====================================================================
WndProc proc  uses ebx  hWnd:HWND, uMsg:ULONG, wParam:WPARAM, lParam:LPARAM
      .if uMsg == WM_CREATE
		
      .elseif uMsg == WM_SIZE
		
      .elseif uMsg == WM_NOTIFY
 		   		
      .elseif uMsg == WM_COMMAND
            mov eax, wParam
            cwde                        
		  
      .elseif uMsg == WM_CLOSE
         INVOKE  DestroyWindow, hWnd

      .elseif uMsg == WM_DESTROY
         INVOKE PostQuitMessage, NULL
      .else

DefWin:
         INVOKE DefWindowProc, hWnd, uMsg, wParam, lParam
            ret
      .endif

Ret0:
         xor    eax, eax
         ret
WndProc endp
comment'-------------------------------------------------------------'
comment'				Add New Fuction
comment'============================================================='

end start

