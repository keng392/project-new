				
          				      *********************************	
                              *   'Win32 Assembly Tutorials   *
                              *    					  *
                              *********************************
                         

          Tutorial 1: The Basics					Tutorial 19: Tree View Control
          Tutorial 2: MessageBox					Tutorial 20: Window Subclassing
          Tutorial 3: A Simple Window				Tutorial 21: Pipe
          Tutorial 4: Painting with Text			Tutorial 22: Window Superclassing
          Tutorial 5: More about Text				Tutorial 23: Tray Icon
          Tutorial 6: Keyboard Input				Tutorial 24: Windows Hooks
          Tutorial 7: Mouse Input					Tutorial 25: Simple Bitmap	
          Tutorial 8: Menu						    Tutorial 26: Splash Screen
          Tutorial 9: Child Window Controls			Tutorial 27: Tooltip Control
          Tutorial 10: Dialog Box as Main Window		Tutorial 28: Win32 Debug API part 1
          Tutorial 11: More about Dialog Box			Tutorial 29: Win32 Debug API part 2
          Tutorial 12: Memory Management and File I/O	Tutorial 30: Win32 Debug API part 3
          Tutorial 13: Memory Mapped File			Tutorial 31: Listview Control
          Tutorial 14: Process					Tutorial 32: Multiple Document Interface (MDI)
          Tutorial 15: Multithreading Programming		Tutorial 33: RichEdit Control: Basics
          Tutorial 16: Event Object				Tutorial 34: RichEdit Control: More Text Operations
          Tutorial 17: Dynamic Link Libraries		Tutorial 35: RichEdit Control: Syntax Hilighting
          Tutorial 18: Common Controls
          
          
   
                                             Tutorial 1: 'Basics'
  
Theory:

          	Win32 programs run in protected mode which is available since 80286. But 80286 is now history. So we only have 
          to concern ourselves with 80386 and its descendants. Windows runs each Win32 program in separated virtual space.
          That means each Win32 program will have its own 4 GB address space. However, this doesn't mean every win32 
          program has 4GB of physical memory, only that the program can address any address in that range. Windows will
          do anything necessary to make the memory the program references valid. Of course, the program must adhere to 
          the rules set by Windows, else it will cause the dreaded General Protection Fault. Each program is alone in  
          its address space. This is in contrast to the situation in Win16. All Win16 programs can *see* each other.
          Not so under Win32. This feature helps reduce the chance of one program writing over other program's 
          code/data. 
          	Memory model is also drastically different from the old days of the 16-bit world. Under Win32, we need not be 
          concerned with memory model or segments anymore! There's only one memory model: Flat memory model. There's no
          more 64K segments. The memory is a  large continuous space of 4 GB. That also means you don't have to play 
          with segment registers. You can use any segment register to address any point in the memory space. 
          That's a GREAT help to programmers. This is what makes Win32 assembly programming as easy as C.
          	When you program under Win32, you must know some important rules. One such rule is that, Windows uses esi,
          edi, ebp and ebx internally and it doesn't expect the values in those registers to change. So remember 
          this rule first: if you use any of those four registers in your callback function, don't ever forget to 
          restore them before returning control to Windows. A callback function is your own function which is 
          called by Windows. The obvious example is the windows procedure. This doesn't mean that you cannot use 
          those four registers, you can. Just be sure to restore them back before passing control back to Windows.

Content:

     Here's the skeleton program. If you don't understand some of the codes, don't panic. I'll explain each of them 
     later.
                         	===================================
                                   .386 
                                   .MODEL Flat, STDCALL 
                                   .DATA 
                                       <Your initialized data> 
                                       ...... 
                                   .DATA? 
                                      <Your uninitialized data> 
                                      ...... 
                                   .CONST 
                                      <Your constants> 
                                      ...... 
                                   .CODE 
                                      <label> 
                                       <Your code> 
                                      ..... 
                                    end <label> 
                         	___________________________________

	That's all! Let's analyze this skeleton program. 

     .386 
     	This is an assembler directive, telling the assembler to use 80386 instruction set. You can also use .486, 
     .586
     	but the safest bet is to stick to .386. There are actually two nearly identical forms for each CPU model. 
     .386
          /.386p, .486/.486p. Those "p" versions are necessary only when your program uses privileged instructions. 
          Privileged instructions are the instructions reserved by the CPU/operating system when in protected mode. 
          They can only be used by privileged code, such as the virtual device drivers. Most of the time, 
          your program 
          will work in non-privileged mode so it's safe to use non-p versions. 

     .MODEL FLAT, STDCALL 
     .MODEL is an assembler directive that specifies memory model of your program. Under Win32, there's only on model, FLAT model. 
          STDCALL tells MASM about parameter passing convention. Parameter passing convention specifies the order of  parameter passing,
          left-to-right or right-to-left, and also who will balance the stack frame after the function call. 
          Under Win16, there are two types of calling convention, C and PASCAL 
          C calling convention passes parameters from right to left, that is , the rightmost parameter is pushed first. 
          The caller is responsible for balancing the stack frame after the call. For example, in order to call a function named 
          foo(int first_param, int second_param, int third_param) in C calling convention the asm codes will look like this: 
     
     push  [third_param]               ; Push the third parameter 
     push  [second_param]            ; Followed by the second 
     push  [first_param]                ; And the first 
     call    foo 
     add    sp, 12                                ; The caller balances the stack frame
          PASCAL calling convention is the reverse of C calling convention. It passes parameters from left to right and 
          the callee is responsible for the stack balancing after the call. 
          Win16 adopts PASCAL convention because it produces smaller codes. C convention is useful when you don't know 
          how many parameters will be passed to the function as in the case of wsprintf(). In the case of wsprintf(), 
          the function has no way to determine beforehand how many parameters will be pushed on the stack, so it cannot
           do the stack balancing. 
          STDCALL is the hybrid of C and PASCAL convention. It passes parameter from right to left but the callee is 
          responsible for stack balancing after the call.Win32 platform use STDCALL exclusively. Except in one case: 
          wsprintf(). You must use C calling convention with wsprintf(). 
     .DATA 
     .DATA? 
     .CONST 
     .CODE 
     All four directives are what's called section. You don't have segments in Win32, remember? But you can divide 
     your entire address space into logical sections. The start of one section denotes the end of the previous 
     section. There'are two groups of section: data and code. Data sections are divided into 3 categories: 
     
     .DATA    This section contains initialized data of your program. 
     .DATA?  This section contains uninitialized data of your program. Sometimes you just want to preallocate some
      memory but don't want to initialize it. This section is for that purpose. The advantage of uninitialized data 
      is: it doesn't take space in the executable file. For example, if you allocate 10,000 bytes in your .DATA? 
      section, your executable is not bloated up 10,000 bytes. Its size stays much the same. You only tell the 
      assembler how much space you need when the program is loaded into memory, that's all. 
     .CONST  This section contains declaration of constants used by your program. Constants in this section 
     can never be modified in your program. They are just *constant*. 
     You don't have to use all three sections in your program. Declare only the section(s) you want to use.
     
     There's only one section for code: .CODE. This is where your codes reside. 
     <label> 
     end <label> 
where <label> is any arbitrary label is used to specify the extent of your code. Both labels must be identical.  All your codes must reside between <label> and end <label> 

						==============================
                              *   Tutorial 2: 'MessageBox' *
                              ==============================
  
     		In this tutorial, we will create a fully functional Windows program that displays a message box saying 
          "Win32 assembly is great!". 
Theory:
          	Windows prepares a wealth of resources for Windows programs. Central to this is the Windows API 
          (Application Programming Interface). Windows API is a huge collection of very useful functions that 
          reside in Windows itself, ready for use by any Windows programs. These functions are stored in several
          dynamic-linked libraries (DLLs) such as kernel32.dll, user32.dll and gdi32.dll. Kernel32.dll contains 
          API functions that deal with memory and process management. User32.dll controls the user interface 
          aspects of your program. Gdi32.dll is responsible for graphics operations. Other than "the main three",
          there are other DLLs that your program can use, provided you have enough information about the desired 
          API functions. 
          	Windows programs dynamically link to these DLLs, ie. the codes of API functions are not included in 
          the Windows program executable file. In order for your program to know where to find the desired API 
          functions at runtime, you have to embed that information into the executable file. The information 
          is in import libraries. You must link your programs with the correct import libraries or they will 
          not be able to locate API functions. 
          When a Windows program is loaded into memory, Windows reads the information stored in the program. 
          That information includes the names of functions the program uses and the DLLs those functions reside in. 
          When Windows finds such info in the program, it'll load the DLLs and perform function address fixups in 
          the program so the calls will transfer control to the right function. 
          There are two categoriesof API functions: One for ANSI and the other for Unicode. The names of API 
          functions for ANSI are postfixed with "A", eg. MessageBoxA. Those for Unicode are postfixed with "W" 
          (for Wide Char, I think). Windows 95 natively supports ANSI and Windows NT Unicode. 
          	We are usually familiar with ANSI strings, which are arrays of characters terminated by NULL.
          ANSI character is 1 byte in size. While ANSI code is sufficient for European languages, 
          it cannot handle several oriental languages which have several thousands of unique characters. 
          That's why UNICODE comes in. A UNICODE character is 2 bytes in size, making it possible to have
          65536 unique characters in the strings. 
          But most of the time, you will use an include file which can determine and select the appropriate 
          API functions for your platform. Just refer to API function names without the postfix. 
          Example:
				
                              .386
                              .model flat, stdcall 
                              .data 
                              .code 
                              start: 
                              
						end start 

          	The execution starts from the first instruction immediately below the label specified after end directive. 
          In the above skeleton, the execution will start at the first instruction immediately below start label. 
          The execution will proceed instruction by instruction until some flow-control instructions such as jmp, 
          jne, je, ret etc is found. Those instructions redirect the flow of execution to some other instructions.
          When the program needs to exit to Windows, it should call an API function, ExitProcess. 
          
          ExitProcess proto uExitCode:DWORD 
          
          	The above line is called a function prototype. A function prototype defines the attributes of a 
          function to the assembler/linker so it can do type-checking for you. The format of a function 
          prototype is like this: 
          
          FunctionName PROTO [ParameterName]:DataType,[ParameterName]:DataType,... 
          
          In short, the name of the function followed by the keyword PROTO and then by the list of data types 
          of the parameters,separated by commas. In the ExitProcess example above, it defines ExitProcess as a 
          function which takes only one parameter of type DWORD. Functions prototypes are very useful when you use
          the high-level call syntax, invoke. You can think of invoke as a simple call with type-checking.
          For example, if you do: 

          call ExitProcess 
          
          without pushing a dword onto the stack, the assembler/linker will not be able to catch that error for you. 
          You'll notice it later when your program crashes. But if you use: 
          
          invoke ExitProcess 
          
          	The linker will inform you that you forgot to push a dword on the stack thus avoiding error. 
          I recommend you use invoke instead of simple call. The syntax of invoke is as follows: 
          
          					INVOKE  expression [,arguments] 
          
          expression can be the name of a function or it can be a function pointer. 
          The function parameters are separated by commas. 
          
          	Most of function prototypes for API functions are kept in include files. 
          If you use Masm32, they will be in Masm32/include folder. The include files have .
          inc extension and the function prototypes for functions in a DLL is stored in .
          inc file with the same name as the DLL. For example, ExitProcess is exported by kernel32.
          lib so the function prototype for ExitProcess is stored in kernel32.inc. 
          You can also create function prototypes for your own functions. 
          Throughout my examples, I'll use windows.inc which you can download from website. 
          
          Now back to ExitProcess, uExitCode parameter is the value you want the program to return 
          to Windows after the program terminates. You can call ExitProcess like this: 
          
          	invoke ExitProcess, 0 
          
          Put that line immediately below start label, you will get a win32 program which immediately 
          exits to Windows, but it's a valid program nonetheless. 

.386 
.model flat, stdcall 
option casemap:none 
include \masm32\include\windows.inc 
include \masm32\include\kernel32.inc 
includelib \masm32\lib\kernel32.lib 
.data 
.code 
start: 
        invoke ExitProcess,0 
end start 

          	option casemap:none tells MASM to make labels case-sensitive so ExitProcess and exitprocess are different.
          Note a new directive, include. This directive is followed by the name of a file you want to insert at the 
          place the directive is. In the above example, when MASM processes the line include \masm32\include\windows.inc
          , it will open windows.inc which is in \masm32\include folder and process the content of windows.inc 
          as if you paste the content of windows.inc there. windows.inc contains definitions of constants 
          and structures you need in win32 programming. It doesn't contain any function prototype. windows.
          inc is by no means comprehensive. I try to put as many constants and structures into it as possible
          but there are still many left to be included. It'll be constantly updated. 
          From windows.inc, your program got constant and structure definitions. Now for function prototypes, 
          you need to include other include files. They are all stored in \masm32\include folder. 
          
          	In our example above, we call a function exported by kernel32.dll, so we need to include the function 
          prototypes from kernel32.dll. That file is kernel32.inc. If you open it with a text editor, you will see 
          that it's full of function prototypes for kernel32.dll. If you don't include kernel32.inc, you can still 
          call ExitProcess but only with simple call syntax. You won't be able to invoke the function. The point 
          here is that: in order to invoke a function, you have to put its function prototype somewhere in the 
          source code. In the above example, if you don't include kernel32.inc, you can define the function prototype
          for ExitProcess anywhere in the source code above the invoke command and it will work. The include files
          are there to save you the work of typing out the prototypes yourself so use them whenever you can. 
          Now we encounter a new directive, includelib. includelib doesn't work like include. It 's only a way to 
          tell the assembler what import library your program uses. When the assembler sees an includelib directive, 
          it puts a linker command into the object file so that the linker knows what import libraries your program 
          needs to link with. You're not forced to use includelib though. You can specify the names of the import 
          libraries in the command line of the linker but believe me, it's tedious and the command line can hold
          only 128 characters. 
          
          Now save the example under the name msgbox.asm. Assuming that ml.exe is in your path, assemble msgbox.asm
          with: 
          
          ml  /c  /coff  /Cp msgbox.asm 
          /c tells MASM to assemble only. Do not invoke link.exe. Most of the time, you would not want to call link.exe 
          automatically since you may have to perform some other tasks prior to calling link.exe. 
          /coff tells MASM to create .obj file in COFF format. MASM uses a variation of COFF (Common Object File Format)
          which is used under Unix as its own object and executable file format. 
          /Cp tells MASM to preserve case of user identifiers. If you use masm32 package, you may put 
          "option casemap:none" at the head of your source code, just below .model directive to achieve the same effect.
          After you successfully assemble msgbox.asm, you will get msgbox.obj. msgbox.obj is an object file.
          An object file is only one step away from an executable file. It contains the instructions/data 
          in binary form. What is lacking is some fixups of addresses by the linker. 
          Then go on with link: 
          
          link /SUBSYSTEM:WINDOWS  /LIBPATH:c:\masm32\lib  msgbox.obj
          /SUBSYSTEM:WINDOWS  informs Link what sort of executable this program is 
          /LIBPATH:<path to import library> tells Link where the import libraries are. If you use masm32, they will 
          be in masm32\lib folder.
          Link reads in the object file and fixes it with addresses from the import libraries. When the process is 
          finished you get msgbox.exe. 
          Now you get msgbox.exe. Go on, run it. You'll find that it does nothing. Well, we haven't put anything 
          interesting into it yet. But it's a Windows program nonetheless. And look at its size! In my PC, it is 
          1,536 bytes. 
          
          Next we're going to put in a message box. Its function prototype is: 
          
          MessageBox PROTO hwnd:DWORD, lpText:DWORD, lpCaption:DWORD, uType:DWORD 
          
          hwnd is the handle to parent window. You can think of a handle as a number that represents the window 
          you're referrring to. Its value is not important to you. You only remember that it represents the window. 
          When you want to do anything with the window, you must refer to it by its handle. 
          lpText is a pointer to the text you want to display in the client area of the message box. 
          A pointer is really an address of something. A pointer to text string==The address of that string. 
          lpCaption is a pointer to the caption of the message box 
          uType specifies the icon and the number and type of buttons on the message box
          Let's modify msgbox.asm to include the message box. 
  
.386 
.model flat,stdcall 
option casemap:none 
include \masm32\include\windows.inc 
include \masm32\include\kernel32.inc 
includelib \masm32\lib\kernel32.lib 
include \masm32\include\user32.inc 
includelib \masm32\lib\user32.lib 

.data 
MsgBoxCaption  db "Iczelion Tutorial No.2",0 
MsgBoxText       db "Win32 Assembly is Great!",0 

.code 
start: 
invoke MessageBox, NULL, addr MsgBoxText, addr MsgBoxCaption, MB_OK 
invoke ExitProcess, NULL 
end start 

     Assemble and run it. You will see a message box displaying the text "Win32 Assembly is Great!". 
     
     Let's look again at the source code. 
     We define two zero-terminated strings in .data section. Remember that every ANSI string in Windows must be 
     terminated by NULL (0 hexadecimal). 
     We use two constants, NULL and MB_OK. Those constants are documented in windows.inc. So you can refer to them 
     by name instead of the values. This improves readability of your source code. 
     The addr operator is used to pass the address of a label to the function. It's valid only in the context of 
     invoke directive. You can't use it to assign the address of a label to a register/variable, for example. 
     You can use offset instead of addr in the above example. However, there are some differences between the two: 
     
     addr cannot handle forward reference while offset can. For example, if the label is defined somewhere 
     further in the source code than the invoke line, addr will not work. 
     invoke MessageBox,NULL, addr MsgBoxText,addr MsgBoxCaption,MB_OK 
     ...... 
     MsgBoxCaption  db "Iczelion Tutorial No.2",0 
     MsgBoxText       db "Win32 Assembly is Great!",0
     MASM will report error. If you use offset instead of addr in the above code snippet, MASM will assemble 
     it happily. 
     addr can handle local variables while offset cannot. A local variable is only some reserved space 
     in the stack. You will only know its address during runtime. offset is interpreted during assembly 
     time by the assembler. So it's natural that offset won't work for local variables. addr is able to handle local variables because of the fact that the assembler checks first whether the variable referred to by addr is a global or local one. If it's a global variable, it puts the address of that variable into the object file. In this regard, it works like offset. If it's a local variable, it generates an instruction sequence like this before it actually calls the function: 
     lea eax, LocalVar 
     push eax
     
     Since lea can determine the address of a label at runtime, this works fine.
  Unfortunately you can't run Java applets  

							------------------------------
                                   Tutorial 3: 'A Simple Window'
  
		In this tutorial, we will build a Windows program that displays a fully functional window on the desktop. 
Theory:
          	Windows programs rely heavily on API functions for their GUI(menu,file,toolbar,..). 
	     This approach benefits both users and 
          programmers. For users, they don't have to learn how to navigate the GUI of each new programs, 
          the GUI of Windows programs are alike. For programmers, the GUI codes are already there,tested, 
          and ready for use. The downside for programmers is the increased complexity involved. 
          In order to create or manipulate any GUI objects such as windows, menu or icons, 
          programmers must follow a strict recipe. But that can be overcome by modular programming or OOP paradigm. 
          I'll outline the steps required to create a window on the desktop below: 
          Get the instance handle of your program (required) 
          Get the command line (not required unless your program wants to process a command line) 
          Register window class (required ,unless you use predefined window types, eg. MessageBox or a dialog box) 
          Create the window (required) 
          Show the window on the desktop (required unless you don't want to show the window immediately) 
          Refresh the client area of the window 
          Enter an infinite loop, checking for messages from Windows 
          If messages arrive, they are processed by a specialized function that is responsible for the window 
          Quit program if the user closes the window 
          As you can see, the structure of a Windows program is rather complex compared to a DOS program. 
          But the world of Windows is drastically different from the world of DOS. Windows programs must be
          able to coexist peacefully with each other. They must follow stricter rules. You, as a programmer,
          must also be more strict with your programming style and habit. 
          Content:
          Below is the source code of our simple window program. Before jumping into the gory details of 
          Win32 ASM programming, I'll point out some fine points which will ease your programming. 
          You should put all Windows constants, structures and function prototypes in an include file and 
          include it at the beginning of your .asm file. It'll save you a lot of effort and typo. Currently, 
          the most complete include file for MASM is windows.inc which you can download from his page 
          or my page. You can also define your own constants & structure definitions but you should put
          them into a separate include file. 
          Use includelib directive to specify the import library used in your program. For example,
          if your program calls MessageBox, you should put the line: 
          includelib user32.lib
          at the beginning of your .asm file. This directive tells MASM that your program will make 
          uses of functions in that import library. If your program calls functions in more than
          one library, just add an includelib for each library you use. Using IncludeLib directive,
          you don't have to worry about import libraries at link time. You can use /LIBPATH linker 
          switch to tell Link where all the libs are. 
          When declaring API function prototypes, structures, or constants in your include file, 
          try to stick to the original names used in Windows include files, including case. 
          This will save you a lot of headache when looking up some item in Win32 API reference. 
          Use makefile to automate your assembling process. This will save you a lot of typing. 
.386 
.model flat,stdcall 
option casemap:none 
include \masm32\include\windows.inc 
include \masm32\include\user32.inc 
includelib \masm32\lib\user32.lib            ; calls to functions in user32.lib and kernel32.lib 
include \masm32\include\kernel32.inc 
includelib \masm32\lib\kernel32.lib 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 

.DATA                     ; initialized data 
	ClassName db "SimpleWinClass",0        ; the name of our window class 
	AppName db "Our First Window",0        ; the name of our window 

.DATA?                ; Uninitialized data 
	hInstance HINSTANCE ?        ; Instance handle of our program 
	CommandLine LPSTR ? 
.CODE                ; Here begins our code 
start: 
     invoke GetModuleHandle, NULL            ; get the instance handle of our program. 
                                             ; Under Win32, hmodule==hinstance mov hInstance,eax 
     mov hInstance,eax 
     invoke GetCommandLine                        ; get the command line. You don't have to call this function IF 
                                                  ; your program doesn't process the command line. 
     mov CommandLine,eax 
     invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT  ; call the main function 
invoke ExitProcess, eax                           ; quit our program. The exit code is returned in eax from WinMain. 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX      ; create local variables on stack 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 

    mov   wc.cbSize,SIZEOF WNDCLASSEX        ; fill values in members of wc 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInstance 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_WINDOW+1 
    mov   wc.lpszMenuName,NULL 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc ; register our window class 
    invoke CreateWindowEx,NULL,\ 
                ADDR ClassName,\ 
                ADDR AppName,\ 
                WS_OVERLAPPEDWINDOW,\ 
                CW_USEDEFAULT,\ 
                CW_USEDEFAULT,\ 
                CW_USEDEFAULT,\ 
                CW_USEDEFAULT,\ 
                NULL,\ 
                NULL,\ 
                hInst,\ 
                NULL 
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,CmdShow  ; display our window on desktop 
    invoke UpdateWindow, hwnd        ; refresh the client area 

    .WHILE TRUE                                    ; Enter message loop 
           invoke GetMessage, ADDR msg,NULL,0,0 
           .BREAK .IF (!eax) 
           invoke TranslateMessage, ADDR msg 
           invoke DispatchMessage, ADDR msg 
   .ENDW 
    mov     eax,msg.wParam   ; return exit code in eax 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    .IF uMsg==WM_DESTROY               ; if the user closes our window 
        invoke PostQuitMessage,NULL    ; quit our application 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam     ; Default message processing 
        ret 
    .ENDIF 
    xor eax,eax 
    ret 
WndProc endp 

end start 

Analysis:
          	You may be taken aback that a simple Windows program requires so much coding. But most of those 
          codes are just *template* codes that you can copy from one source code file to another.
          Or if you prefer, you could assemble some of these codes into a library to be used as prologue 
          and epilogue codes. You can write only the codes in WinMain function. In fact, this is what 
          C compilers do. They let you write WinMain codes without worrying about other housekeeping chores. 
          The only catch is that you must have a function named WinMain else C compilers will not be able 
          to combine your codes with the prologue and epilogue. You do not have such restriction 
          with assembly language. You can use any function name instead of WinMain or no function at all. 
          Prepare yourself. This's going to be a long, long tutorial. Let's analyze this program to death! 
.386 
.model flat,stdcall 
option casemap:none 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 

include \masm32\include\windows.inc 
include \masm32\include\user32.inc 
include \masm32\include\kernel32.inc 
includelib \masm32\lib\user32.lib 
includelib \masm32\lib\kernel32.lib

          The first three lines are "necessities". .386 tells MASM we intend to use 80386 instruction set 
          in this program. .model flat,stdcall tells MASM that our program uses flat memory addressing model. 
          Also we will use stdcall parameter passing convention as the default one in our program. 
          Next is the function prototype for WinMain. Since we will call WinMain later, we must define 
          its function prototype first so that we will be able to invoke it. 
          We must include windows.inc at the beginning of the source code. 
          It contains important structures and constants that are used by our program. The include file , 
          windows.inc, is just a text file. You can open it with any text editor. Please note that windows.
          inc does not contain all structures, and constants (yet). and I are working on it. You can 
          add in new items if they are not in the file. 
          Our program calls API functions that reside in user32.dll (CreateWindowEx, 
          RegisterWindowClassEx, for example) and kernel32.dll (ExitProcess), so we must 
          link our program to those two import libraries. The next question : how can I 
          know which import library should be linked to my program? The answer: You must know where 
          the API functions called by your program reside. For example, if you call an API function 
          in gdi32.dll, you must link with gdi32.lib. 
          This is the approach of MASM. TASM 's way of import library linking is much more simpler: 
just link to one and only one file: import32.lib. 
.DATA 
    ClassName db "SimpleWinClass",0 
    AppName  db "Our First Window",0 
.DATA? 
     hInstance HINSTANCE ? 
     CommandLine LPSTR ?

          Next are the "DATA" sections. 
          In .DATA, we declare two zero-terminated strings(ASCIIZ strings): ClassName which is the name 
          of our window class and AppName which is the name of our window. Note that the two variables 
          are initialized. 
          In .DATA?, two variables are declared: hInstance (instance handle of our program) and 
          CommandLine (command line of our program). The unfamiliar data types, HINSTANCE and LPSTR,
          are really new names for DWORD. You can look them up in windows.inc. Note that all variables 
          in .DATA? section are not initialized, that is, they don't have to hold any specific value 
          on startup, but we want to reserve the space for future use. 
.CODE 
 start: 
     invoke GetModuleHandle, NULL 
     mov    hInstance,eax 
     invoke GetCommandLine 
     mov    CommandLine,eax 
     invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
     invoke ExitProcess,eax 
     ..... 
end start
          .CODE contains all your instructions. Your codes must reside between <starting label>: and 
          end <starting label>. The name of the label is unimportant. You can name it anything you like 
          so long as it is unique and doesn't violate the naming convention of MASM. 
          Our first instruction is the call to GetModuleHandle to retrieve the instance handle of our program. 
          Under Win32, instance handle and module handle are one and the same. You can think of instance 
          handle as the ID of your program. It is used as parameter to several API functions
          our program must call, so it's generally a good idea to retrieve it at the beginning of our program. 
          Note: Actually under win32, instance handle is the linear address of your program in memory. 
          Upon returning from a Win32 function, the function's return value, if any, can be found in eax.
          All other values are returned through variables passed in the function parameter list you defined
          for the call. 
          A Win32 function that you call will nearly always preserve the segment registers and
          the ebx, edi, esi and ebp registers. Conversely, ecx and edx are considered scratch registers
          and are always undefined upon return from a Win32 function. 
          Note: Don't expect the values of eax, ecx, edx to be preserved across API function calls. 
          The bottom line is that: when calling an API function, expects return value in eax. 
          If any of your function will be called by Windows, you must also play by the rule: preserve 
          and restore the values of the segment registers, ebx, edi, esi and ebp upon function return 
          else your program will crash very shortly, this includes your window procedure and windows 
          callback functions. 
          The GetCommandLine call is unnecessary if your program doesn't process a command line. 
          In this example, I show you how to call it in case you need it in your program. 
          Next is the WinMain call. Here it receives four parameters: the instance handle of our program, 
          the instance handle of the previous instance of our program, the command line and window state 
          at first appearance. Under Win32, there's NO previous instance. Each program is alone in 
          its address space, so the value of hPrevInst is always 0. This is a leftover from the day 
          of Win16 when all instances of a program run in the same address space and an instance wants
          to know if it's the first instance. Under win16, if hPrevInst is NULL, then this instance 
          is the first one. 
          Note: You don't have to declare the function name as WinMain. In fact, you have complete 
          freedom in this regard. You don't have to use any WinMain-equivalent function at all. 
          You can paste the codes inside WinMain function next to GetCommandLine and your program 
          will still be able to function perfectly. 
          Upon returning from WinMain, eax is filled with exit code. We pass that exit code as 
          the parameter to ExitProcess which terminates our application. 
          WinMain proc Inst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
          
          The above line is the function declaration of WinMain. Note the parameter:type 
          pairs that follow PROC directive. They are parameters that WinMain receives from the caller. 
          You can refer to these parameters by name instead of by stack manipulation. 
          In addition, MASM will generate the prologue and epilogue codes for the function. 
          So we don't have to concern ourselves with stack frame on function enter and exit. 

    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 

          LOCAL directive allocates memory from the stack for local variables used in the function. 
          The bunch of LOCAL directives must be immediately below the PROC directive. The LOCAL directive 
          is immediately followed by <the name of local variable>:<variable type>. So LOCAL wc:WNDCLASSEX 
          tells MASM to allocate memory from the stack the size of WNDCLASSEX structure for the variable named wc.
          We can refer to wc in our codes without any difficulty involved in stack manipulation. 
          That's really a godsend, I think. The downside  is that local variables cannot be used outside 
          the function they're created and will be automatically destroyed when the function returns 
          to the caller. Another drawback is that you cannot initialize local variables automatically 
          because they're just stack memory allocated dynamically when the function is entered . 
          You have to manually assign them with desired values after LOCAL directives. 

    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInstance 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_WINDOW+1 
    mov   wc.lpszMenuName,NULL 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
          
          The inimidating lines above are really simple in concept. It just takes several lines of instruction 
          to accomplish. The concept behind all these lines is  window class. A window class is nothing more 
          than a blueprint or specification of a window. It defines several important characteristics of a 
          window such as its icon, its cursor, the function responsible for it, its color etc. You create a 
          window from a window class. This is some sort of object oriented concept. If you want to create 
          more than one window with the same characteristics, it stands to reason to store all these 
          characteristics in only one place and refer to them when needed. This scheme will save lots 
          of memory by avoiding duplication of information. Remember, Windows is designed in the past 
          when memory chips are prohibitive and most computers have 1 MB of memory. Windows must be very 
          efficient in using the scarce memory resource. The point is: if you define your own window, 
          you must fill the desired characteristics of your window in a WNDCLASS or WNDCLASSEX structure
          and call RegisterClass or RegisterClassEx before you're able to create your window. You only 
          have to register the window class once for each window type you want to create a window from. 
          Windows has several predefined Window classes, such as button and edit box. For these windows 
          (or controls), you don't have to register a window class, just call CreateWindowEx with the 
          predefined class name. 
          The single most important member in the WNDCLASSEX is lpfnWndProc. lpfn stands for long pointer 
          to function. Under Win32, there's no "near" or "far" pointer, just pointer because of the 
          new FLAT memory model. But this is again a leftover from the day of Win16. Each window 
          class must be associated with a function called window procedure. The window procedure
          is responsible for message handling of all windows created from the associated window class. 
          Windows will send messages to the window procedure to notify it of important events concerning 
          the windows it 's responsible for,such as user keyboard or mouse input. It's up to the window 
          procedure to respond intelligently to each window message it receives. You will spend most of 
          your time writing event handlers in window procedure. 
          I describe each member of WNDCLASSEX below: 

WNDCLASSEX STRUCT DWORD 
  cbSize            DWORD      ? 
  style             DWORD      ? 
  lpfnWndProc       DWORD      ? 
  cbClsExtra        DWORD      ? 
  cbWndExtra        DWORD      ? 
  hInstance         DWORD      ? 
  hIcon             DWORD      ? 
  hCursor           DWORD      ? 
  hbrBackground     DWORD      ? 
  lpszMenuName      DWORD      ? 
  lpszClassName     DWORD      ? 
  hIconSm           DWORD      ? 
WNDCLASSEX ENDS 

          cbSize: The size of WNDCLASSEX structure in bytes. We can use SIZEOF operator to get the value. 
          style: The style of windows created from this class. You can combine several styles together using
          "or" operator. 
          lpfnWndProc: The address of the window procedure responsible for windows created from this class. 
          cbClsExtra: Specifies the number of extra bytes to allocate following the window-class structure. 
          The operating system initializes the bytes to zero. You can store window class-specific data here. 
          cbWndExtra: Specifies the number of extra bytes to allocate following the window instance. 
          The operating system initializes the bytes to zero. 
          If an application uses the WNDCLASS structure to register a dialog box created by using the 
          CLASS directive in the resource file, it must set this member to DLGWINDOWEXTRA. 
          hInstance: Instance handle of the module. 
          hIcon: Handle to the icon. Get it from LoadIcon call. 
          hCursor: Handle to the cursor. Get it from LoadCursor call. 
          hbrBackground: Background color of windows created from the class. 
          lpszMenuName: Default menu handle for windows created from the class. 
          lpszClassName: The name of this window class. 
          hIconSm: Handle to a small icon that is associated with the window class. 
          If this member is NULL, the system searches the icon resource specified by 
          the hIcon member for an icon of the appropriate size to use as the small icon. 

    invoke CreateWindowEx, NULL,\ 
                                                ADDR ClassName,\ 
                                                ADDR AppName,\ 
                                                WS_OVERLAPPEDWINDOW,\ 
                                                CW_USEDEFAULT,\ 
                                                CW_USEDEFAULT,\ 
                                                CW_USEDEFAULT,\ 
                                                CW_USEDEFAULT,\ 
                                                NULL,\ 
                                                NULL,\ 
                                                hInst,\ 
                                                NULL 

          After registering the window class, we can call CreateWindowEx to create our 
          window based on the submitted window class. Notice that there are 12 parameters to this function. 

CreateWindowExA proto dwExStyle:DWORD,\ 
   lpClassName:DWORD,\ 
   lpWindowName:DWORD,\ 
   dwStyle:DWORD,\ 
   X:DWORD,\ 
   Y:DWORD,\ 
   nWidth:DWORD,\ 
   nHeight:DWORD,\ 
   hWndParent:DWORD ,\ 
   hMenu:DWORD,\ 
   hInstance:DWORD,\ 
   lpParam:DWORD 

               Let's see detailed description of each parameter: 
               dwExStyle: Extra window styles. This is the new parameter that is added to the old CreateWindow. 
               You can put new window styles for Windows 95 & NT here.You can specify your ordinary window style
               in dwStyle but if you want some special styles such as topmost window, you must specify them here.
               You can use NULL if you don't want extra window styles. 
               lpClassName: (Required). Address of the ASCIIZ string containing the name of window class you want 
               to use as template for this window. The Class can be your own registered class or predefined window class. 
               As stated above, every window you created must be based on a window class. 
               lpWindowName: Address of the ASCIIZ string containing the name of the window. 
               It'll be shown on the title bar of the window. If this parameter is NULL, 
               the title bar of the window will be blank. 
               dwStyle:  Styles of the window. You can specify the appearance of the window here. 
               Passing NULL  is ok but the window will have no system menu box, no minimize-maximize buttons, 
               and no close-window button. The window would not be of much use at all. You will need to press Alt+F4 
               to close it. The most common window style is WS_OVERLAPPEDWINDOW. A window style is only a bit flag. 
               Thus you can combine several window styles by "or" operator to achieve the desired appearance of 
               the window. WS_OVERLAPPEDWINDOW style is actually a combination of the most common window styles
               by this method. 
               X,Y: The coordinate of the upper left corner of the window. Normally this values should be CW_USEDEFAULT,
               that is, you want Windows to decide for you where to put the window on the desktop. 
               nWidth, nHeight: The width and height of the window in pixels. You can also use CW_USEDEFAULT 
               to let Windows choose the appropriate width and height for you. 
               hWndParent: A handle to the window's parent window (if exists). This parameter tells Windows 
               whether this window is a child (subordinate) of some other window and, if it is, which window 
               is the parent. Note that this is not the parent-child relationship of multiple document interface
               (MDI). Child windows are not bound to the client area of the parent window. This relationship 
               is specifically for Windows internal use. If the parent window is destroyed, all child windows
               will be destroyed automatically. It's really that simple. Since in our example, there's only 
               one window, we specify this parameter as NULL. 
               hMenu: A handle to the window's menu. NULL if the class menu is to be used. Look back at the a 
               member of WNDCLASSEX structure, lpszMenuName. lpszMenuName specifies *default* menu for the 
               class. Every window created from this window class will have the same menu by default. 
               Unless you specify an *overriding* menu for a specific window via its hMenu parameter. 
               hMenu is actually a dual-purpose parameter. In case the window you want to create is of
               a predefined window type (ie. control), such control cannot own a menu. hMenu is used as 
               that control's ID instead. Windows can decide whether hMenu is really a menu handle or a 
               control ID by looking at lpClassName parameter. If it's the name of a predefined window class, 
               hMenu is a control ID. If it's not, then it's a handle to the window's menu. 
               hInstance: The instance handle for the program module creating the window. 
               lpParam: Optional pointer to a data structure passed to the window. 
               This is used by MDI window to pass the CLIENTCREATESTRUCT data. Normally, 
               this value is set to NULL, meaning that no data is passed via CreateWindow(). 
               The window can retrieve the value of this parameter by the call to GetWindowLong function. 

    mov   hwnd,eax 
    invoke ShowWindow, hwnd,CmdShow 
    invoke UpdateWindow, hwnd 

     On successful return from CreateWindowEx, the window handle is returned in eax. We must keep this 
     value for future use. The window we just created is not automatically displayed. You must call
     ShowWindow with the window handle and the desired *display state* of the window to make it 
     display on the screen. Next you can call UpdateWindow to order your window to repaint 
     its client area. This function is useful when you want to update the content of the client area. 
     You can omit this call though. 
     
   .WHILE TRUE 
                invoke GetMessage, ADDR msg,NULL,0,0 
                .BREAK .IF (!eax) 
                invoke TranslateMessage, ADDR msg 
                invoke DispatchMessage, ADDR msg 
   .ENDW 

          At this time, our window is up on the screen. But it cannot receive input from the world. 
          So we have to *inform* it of relevant events. We accomplish this with a message loop. 
          There's only one message loop for each module. This message loop continually checks 
          for messages from Windows with GetMessage call. GetMessage passes a pointer to a MSG 
          structure to Windows. This MSG structure will be filled with information about the message 
          that Windows want to send to a window in the module. GetMessage function will not 
          return until there's a message for a window in the module. During that time, Windows 
          can give control to other programs. This is what forms the cooperative multitasking 
          scheme of Win16 platform. GetMessage returns FALSE if WM_QUIT message is received which, 
          in the message loop, will terminate the loop and exit the program. 
          TranslateMessage is a utility function that takes raw keyboard input and generates 
          a new message (WM_CHAR) that is placed on the message queue. The message with WM_CHAR contains 
          the ASCII value for the key pressed, which is easier to deal with than the raw keyboard scan codes. 
          You can omit this call if your program doesn't process keystrokes. 
          DispatchMessage sends the message data to the window procedure responsible for the specific window 
          the message is for. 

    mov     eax,msg.wParam 
    ret 
WinMain endp 

          If the message loop terminates, the exit code is stored in wParam member of the MSG structure. 
          You can store this exit code into eax to return it to Windows. At the present time, Windows does
          not make use of the return value, but it's better to be on the safe side and plays by the rule. 
          
          WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
          
          This is our window procedure. You don't have to name it WndProc. The first parameter, hWnd, 
          is the window handle of the window that the message is destined for. uMsg is the message. 
          Note that uMsg is not a MSG structure. It's just a number, really. Windows defines hundreds of messages, m
          ost of which your programs will not be interested in. Windows will send an appropriate message to a window 
          in case something relevant to that window happens. The window procedure receives the message and reacts to 
          it intelligently. wParam and lParam are just extra parameters for use by some messages. Some messages 
          do send accompanying data in addition to the message itself. Those data are passed to the window procedure 
          by means of lParam and wParam. 

    .IF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor eax,eax 
    ret 
WndProc endp 
          
          Here comes the crucial part. This is where most of your program's intelligence resides. 
          The codes that respond to each Windows message are in the window procedure. 
          Your code must check the Windows message to see if it's a message it's interested in. 
          If it is, do anything you want to do in response to that message and then return with zero in eax. 
          If it's not, you MUST call  DefWindowProc, passing all parameters you received to it for 
          default processing.. This DefWindowProc is an API function that processes the messages your 
          program are not interested in. 
          The only message that you MUST respond to is WM_DESTROY. This message is sent to your 
          window procedure whenever your window is closed. By the time your window procedure receives 
          this message, your window is already removed from the screen. This is just a notification that 
          your window was destroyed, you should prepare yourself to return to Windows. In response to this,
          you can perform housekeeping prior to returning to Windows. You have no choice but 
          to quit when it comes to this state. If you want to have a chance to stop the user 
          from closing your window, you should process WM_CLOSE message. Now back to WM_DESTROY, 
          after performing housekeeping chores, you must call PostQuitMessage which will post WM_QUIT
          
          terminates the message loop and quits to Windows. You can send WM_DESTROY message to your 
          own window procedure by calling DestroyWindow function.
          


Tutorial 4: Painting with Text
  
In this tutorial, we will learn how to "paint" text in the client area of a window.
 We'll also learn about device context. 
Theory:
          Text in Windows is a type of GUI object.  Each character is composed of numerous pixels (dots) 
          that are lumped together into a distinct pattern. That's why it's called "painting" instead of 
          "writing". Normally, you paint text in your own client area (actually, you can paint outside 
          client area but that's another story).  Putting text on screen in Windows is drastically different 
          from DOS. In DOS, you can think of the screen in 80x25 dimension. But in Windows, the screen 
          are shared by several programs. Some rules must be enforced to avoid programs writing over e
          ach other's screen. Windows ensures this by limiting painting area of each window to its own 
          client area only. The size of client area of a window is also not constant. The user can change 
          the size anytime. So you must determine the dimensions of your own client area dynamically. 
          Before you can paint something on the client area, you must ask for permission from Windows. 
          That's right, you don't have absolute control of the screen as you were in DOS anymore.  
          ou must ask Windows for permission to paint your own client area. Windows will determine 
          the size of your client area, font, colors and other GDI attributes and sends a handle 
          to device context back to your program. You can then use the device context as a passport
          to painting on your client area. 
          What is a device context? It's just a data structure maintained internally by Windows. 
          A device context is associated with a particular device, such as a printer or video display. 
          For a video display, a device context is usually associated with a particular window on the display. 
          Some of the values in the device context are graphic attributes such as colors, font etc. 
          These are default values which you can change at will. They exist to help reduce the load 
          from having to specify these attributes in every GDI function calls. 
          You can think of a device context as a default environment prepared for you by Windows. 
          You can override some default settings later if you so wish. 
          When a program need to paint, it must obtain a handle to a device context. Normally, 
          there are several ways to accomplish this. 
          call BeginPaint in response to WM_PAINT message. 
          call GetDC in response to other messages. 
          call CreateDC to create your own device context
          One thing you must remember, after you're through with the device context handle, you must release i
          t during the processing of a single message. Don't obtain the handle in response to one message and 
          release it in response to another. 
          Windows posts WM_PAINT messages to a window to notify that it's now time to repaint its client area. 
          Windows does not save the content of client area of a window.  Instead, when a situation occurs 
          that warrants a repaint of client area (such as when a window was covered by another and 
          is just uncovered), Windows puts WM_PAINT message in that window's message queue. 
          It's the responsibility of that window to repaint its own client area. You must gather 
          all information about how to repaint your client area in the WM_PAINT section of your window procedure,
          so the window procudure can repaint the client area when WM_PAINT message arrives. 
          Another concept you must come to terms with is the invalid rectangle. Windows defines 
          an invalid rectangle as the smallest rectangular area in the client area that needs 
          to be repainted. When Windows detects an invalid rectangle in the client area of a window ,
          it posts WM_PAINT message to that window. In response to WM_PAINT message, the window
          can obtain a paintstruct structure which contains, among others, the coordinate of 
          the invalid rectangle. You call BeginPaint in response to WM_PAINT message to validate 
          the invalid rectangle. If you don't process WM_PAINT message, at the very least you 
          must call DefWindowProc or ValidateRect to validate the invalid rectangle else Windows 
          will repeatedly send you WM_PAINT message. 
          Below are the steps you should perform in response to a WM_PAINT message: 
          Get a handle to device context with BeginPaint. 
          Paint the client area. 
          Release the handle to device context with EndPaint
          Note that you don't have to explicitly validate the invalid rectangle. 
          It's automatically done by the BeginPaint call. Between BeginPaint-Endpaint pair, 
          you can call any GDI functions to paint your client area. Nearly all of them require 
          the handle to device context as a parameter. 
          Content:
          We will write a program that displays a text string "Win32 assembly is great and easy!
          " in the center of the client area. 
  
.386 
.model flat,stdcall 
option casemap:none 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 

include \masm32\include\windows.inc 
include \masm32\include\user32.inc 
includelib \masm32\lib\user32.lib 
include \masm32\include\kernel32.inc 
includelib \masm32\lib\kernel32.lib 

.DATA 
ClassName db "SimpleWinClass",0 
AppName  db "Our First Window",0 
OurText  db "Win32 assembly is great and easy!",0 

.DATA? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 

.CODE 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov CommandLine,eax
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_WINDOW+1 
    mov   wc.lpszMenuName,NULL 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\ 
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\ 
           hInst,NULL 
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,SW_SHOWNORMAL 
    invoke UpdateWindow, hwnd 
        .WHILE TRUE 
                invoke GetMessage, ADDR msg,NULL,0,0 
                .BREAK .IF (!eax) 
                invoke TranslateMessage, ADDR msg 
                invoke DispatchMessage, ADDR msg 
        .ENDW 
        mov     eax,msg.wParam 
        ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    LOCAL hdc:HDC 
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT 
    .IF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSEIF uMsg==WM_PAINT 
        invoke BeginPaint,hWnd, ADDR ps 
        mov    hdc,eax 
        invoke GetClientRect,hWnd, ADDR rect 
        invoke DrawText, hdc,ADDR OurText,-1, ADDR rect, \ 
                DT_SINGLELINE or DT_CENTER or DT_VCENTER 
        invoke EndPaint,hWnd, ADDR ps 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor   eax, eax 
    ret 
WndProc endp 
end start

Analysis:
The majority of the code is the same as the example in tutorial 3. I'll explain only the important changes. 
    LOCAL hdc:HDC 
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT 

          These are local variables that are used by GDI functions in our WM_PAINT section. hdc is used to store 
          the handle to device context returned from BeginPaint call. ps is a PAINTSTRUCT structure.
          Normally you don't use the values in ps. It's passed to BeginPaint function and Windows fills 
          it with appropriate values. You then pass ps to EndPaint function when you finish painting the client area. 
          rect is a RECT structure defined as follows: 
  

RECT Struct 
    left           LONG ? 
    top           LONG ? 
    right        LONG ? 
    bottom    LONG ? 
RECT ends
Left and top are the coordinates of the upper left corner of a rectangle Right and bottom are the coordinates 
of the lower right corner. One thing to remember: The origin of the x-y axes is at the upper left corner of 
the client area. So the point y=10 is BELOW the point y=0. 
        invoke BeginPaint,hWnd, ADDR ps 
        mov    hdc,eax 
        invoke GetClientRect,hWnd, ADDR rect 
        invoke DrawText, hdc,ADDR OurText,-1, ADDR rect, \ 
                DT_SINGLELINE or DT_CENTER or DT_VCENTER 
        invoke EndPaint,hWnd, ADDR ps 

          In response to WM_PAINT message, you call BeginPaint with handle to the window you want to paint and an
          uninitialized PAINTSTRUCT structure as parameters. After successful call, eax contains the handle 
          to device context. Next you call GetClientRect to retrieve the dimension of the client area.
          The dimension is returned in rect variable which you pass to DrawText as one of its parameters.
          DrawText's syntax is: 

DrawText proto hdc:HDC, lpString:DWORD, nCount:DWORD, lpRect:DWORD, uFormat:DWORD 

     DrawText is a high-level text output API function. It handles some gory details such as word wrap, 
     centering etc. so you could concentrate on the string you want to paint. Its low-level brother,
     TextOut, will be examined in the next tutorial. DrawText formats a text string to fit within the
     bounds of a rectangle. It uses the currently selected font,color and background (in the device context)
     to draw the text.Lines are wrapped to fit within the bounds of the rectangle. It returns the height 
     of the output text in device units, in our case, pixels. Let's see its parameters: 
     
     hdc  handle to device context 
     lpString  The pointer to the string you want to draw in the rectangle. 
     The string must be null-terminated else you would have to specify its length in the next parameter, nCount. 
     nCount  The number of characters to output. If the string is null-terminated, nCount must be -1. 
     Otherwise nCount must contain the number of characters in the string you want to draw. 
     lpRect  The pointer to the rectangle (a structure of type RECT) you want to draw the 
     string in. Note that this rectangle is also a clipping rectangle, that is, you could not
     draw the string outside this rectangle. 
     uFormat The value that specifies how the string is displayed in the rectangle. 
     We use three values combined by "or" operator: 
     DT_SINGLELINE  specifies a single line of text 
     DT_CENTER  centers the text horizontally. 
     DT_VCENTER centers the text vertically. Must be used with DT_SINGLELINE. 
     After you finish painting the client area, you must call EndPaint function to release the handle
     to device context. 
     That's it. We can summarize the salient points here: 
     You call BeginPaint-EndPaint pair in response to WM_PAINT message. 
     Do anything you like with the client area between the calls to BeginPaint and EndPaint. 
     If you want to repaint your client area in response to other messages, you have two choices: 
     Use GetDC-ReleaseDC pair and do your painting between these calls 
     Call InvalidateRect or UpdateWindow  to invalidate the entire client area, forcing Windows 
     to put WM_PAINT message in the message queue of your window and do your painting in WM_PAINT section 
Unfortunately you can't run Java applets  


Tutorial 5: More about Text
  
	We will experiment more with text attributes, ie. font and color. 
Theory:
          Windows color system is based on RGB values, R=red, G=Green, B=Blue. If you want to specify a color in Windows,
          you must state your desired color in terms of these three major colors. Each color value has a range from 0  
          to 255 (a byte value). For example, if you want pure red color, you should use 255,0,0. Or if you want pure 
          white color, you must use 255,255,255. You can see from the examples that getting the color you need is very
          difficult with this system since you have to have a good grasp of how to mix and match colors. 
          For text color and background, you use SetTextColor and SetBkColor, both of them require a handle 
          to device context and a 32-bit RGB value. The 32-bit RGB value's structure is defined as: 
RGB_value struct 
    unused   db 0 
    blue     db ? 
    green    db ? 
    red      db ? 
RGB_value ends 

          Note that the first byte is not used and should be zero. The order of the remaining three bytes is reversed,ie.
          blue, green, red. However, we will not use this structure since it's cumbersome to initialize and use. We will
          create a macro instead. The macro will receive three parameters: red, green and blue values. 
          It'll produce the desired 32-bit RGB value and store it in eax. The macro is as follows: 

RGB macro red,green,blue 
    xor  eax,eax 
    mov  ah,blue 
    shl  eax,8 
    mov  ah,green 
    mov  al,red 
endm 

          You can put this macro in the include file for future use. 
          You can "create" a font by calling CreateFont or CreateFontIndirect. 
          The difference between the two functions is that CreateFontIndirect receives only one parameter:
          a pointer to a logical font structure, LOGFONT. CreateFontIndirect is the more flexible of the 
          two especially if your programs need to change fonts frequently. However, in our example, 
          we will "create" only one font for demonstration, we can get away with CreateFont. 
          After the call to CreateFont, it will return a handle to a font which you must select 
          into the device context. After that, every text API function will use the font we have selected 
          into the device context. 
  

Content:
.386 
.model flat,stdcall 
option casemap:none 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 

include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\gdi32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
includelib \Masm32\lib\gdi32.lib 

RGB macro red,green,blue 
        xor eax,eax 
        mov ah,blue 
        shl eax,8 
        mov ah,green 
        mov al,red 
endm 

.data 
ClassName db "SimpleWinClass",0 
AppName  db "Our First Window",0 
TestString  db "Win32 assembly is great and easy!",0 
FontName db "script",0 

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 

.code 
 start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov CommandLine,eax
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_WINDOW+1 
    mov   wc.lpszMenuName,NULL 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\ 
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\ 
           hInst,NULL 
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,SW_SHOWNORMAL 
    invoke UpdateWindow, hwnd 
    .WHILE TRUE 
                invoke GetMessage, ADDR msg,NULL,0,0 
                .BREAK .IF (!eax) 
                invoke TranslateMessage, ADDR msg 
                invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov     eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    LOCAL hdc:HDC 
    LOCAL ps:PAINTSTRUCT 
    LOCAL hfont:HFONT 

    .IF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSEIF uMsg==WM_PAINT 
        invoke BeginPaint,hWnd, ADDR ps 
        mov    hdc,eax 
        invoke CreateFont,24,16,0,0,400,0,0,0,OEM_CHARSET,\ 
                                       OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,\ 
                                       DEFAULT_QUALITY,DEFAULT_PITCH or FF_SCRIPT,\ 
                                       ADDR FontName 
        invoke SelectObject, hdc, eax 
        mov    hfont,eax 
        RGB    200,200,50 
        invoke SetTextColor,hdc,eax 
        RGB    0,0,255 
        invoke SetBkColor,hdc,eax 
        invoke TextOut,hdc,0,0,ADDR TestString,SIZEOF TestString 
        invoke SelectObject,hdc, hfont 
        invoke EndPaint,hWnd, ADDR ps 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor    eax,eax 
    ret 
WndProc endp 

end start 
  

Analysis:
        invoke CreateFont,24,16,0,0,400,0,0,0,OEM_CHARSET,\ 
                                       OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,\ 
                                       DEFAULT_QUALITY,DEFAULT_PITCH or FF_SCRIPT,\ 
                                       ADDR FontName 
          CreateFont creates a logical font that is the closest match to the given parameters and  
          the font data available. This function has more parameters than any other function in Windows. 
          It returns a handle to logical font to be used by SelectObject function. 
          We will examine its parameters in detail. 

CreateFont proto  nHeight:DWORD,\ 
                  nWidth:DWORD,\ 
                  nEscapement:DWORD,\ 
                  nOrientation:DWORD,\ 
                  nWeight:DWORD,\ 
                  cItalic:DWORD,\ 
                  cUnderline:DWORD,\ 
                  cStrikeOut:DWORD,\ 
                  cCharSet:DWORD,\ 
                  cOutputPrecision:DWORD,\ 
                  cClipPrecision:DWORD,\ 
                  cQuality:DWORD,\ 
                  cPitchAndFamily:DWORD,\ 
                  lpFacename:DWORD 

               nHeight The desired height of the characters . 0 means use default size. 
               nWidth The desired width of the characters. 
               Normally this value should be 0 which allows Windows to match the width to the height. 
               However, in our example, the default width makes the characters hard to read,
               so I use the width of 16 instead. 
               nEscapement   Specifies the orientation of the next character output relative to the previous one 
               in tenths of a degree. Normally, set to 0. Set to 900 to have all the characters go upward from the 
               first character, 1800 to write backwards, or 2700 to write each character from the top down. 
               nOrientation   Specifies how much the character should be rotated when output in tenths of a degree. 
               Set to 900 to have all the characters lying on their backs, 1800 for upside-down writing, etc. 
               nWeight   Sets the line thickness of each character. Windows defines the following sizes: 

               FW_DONTCARE    equ 0 
               FW_THIN        equ 100 
               FW_EXTRALIGHT  equ 200 
               FW_ULTRALIGHT  equ 200 
               FW_LIGHT       equ 300 
               FW_NORMAL      equ 400 
               FW_REGULAR     equ 400 
               FW_MEDIUM      equ 500 
               FW_SEMIBOLD    equ 600 
               FW_DEMIBOLD    equ 600 
               FW_BOLD        equ 700 
               FW_EXTRABOLD   equ 800 
               FW_ULTRABOLD   equ 800 
               FW_HEAVY       equ 900 
               FW_BLACK       equ 900
          cItalic   0 for normal, any other value for italic characters. 
          cUnderline   0 for normal, any other value for underlined characters. 
          cStrikeOut   0 for normal, any other value for characters with a line through the center. 
          cCharSet  The character set of the font. Normally should be OEM_CHARSET which allows 
          Windows to select font which is operating system-dependent. 
          cOutputPrecision  Specifies how much the selected font must be closely matched to the characteristics we want.
          Normally should be OUT_DEFAULT_PRECIS which defines default font mapping behavior. 
          cClipPrecision  Specifies the clipping precision. The clipping precision defines how to clip characters 
          that are partially outside the clipping region. You should be able to get by with CLIP_DEFAULT_PRECIS 
          which defines the default clipping behavior. 
          cQuality  Specifies the output quality. The output quality defines how carefully GDI must attempt 
          to match the logical-font attributes to those of an actual physical font. There are three 
          choices: DEFAULT_QUALITY, PROOF_QUALITY and  DRAFT_QUALITY. 
          cPitchAndFamily  Specifies pitch and family of the font. You must combine the pitch value and 
          the family value with "or" operator. 
          lpFacename  A pointer to a null-terminated string that specifies the typeface of the font. 
          The description above is by no means comprehensive. You should refer to your Win32 API reference 
          for more details. 

        invoke SelectObject, hdc, eax 
        mov    hfont,eax 

          	After we get the handle to the logical font, we must use it to select the font into the device context 
          by calling SelectObject. SelectObject puts the new GDI objects such as pens, brushs, and fonts into 
          the device context to be used by GDI functions. It returns the handle to the replaced object which 
          we should save for future SelectObject call. After SelectObject call, any text output function will 
          use the font we just selected into the device context. 

        RGB    200,200,50 
        invoke SetTextColor,hdc,eax 
        RGB    0,0,255 
        invoke SetBkColor,hdc,eax 

     Use RGB macro to create a 32-bit RGB value to be used by SetColorText and SetBkColor. 
     
             invoke TextOut,hdc,0,0,ADDR TestString,SIZEOF TestString 
     
     Call TextOut function to draw the text on the client area. The text will be in the font and color 
     we specified previously. 
     
             invoke SelectObject,hdc, hfont 
     
     When we are through with the font, we should restore the old font back into the device context. 
     You should always restore the object that you replaced in the device context.
     
          
                                        Tutorial 6: Keyboard Input
       
     We will learn how a Windows program receives keyboard input. 
Theory:
          Since normally there's only one keyboard in each PC, all running Windows programs must share it between them.
          Windows is responsible for sending the key strokes to the window which has the input focus. 
          Although there may be several windows on the screen, only one of them has the input focus. 
          The window which has input focus is the only one which can receive key strokes. 
          You can differentiate the window which has input focus from other windows by looking at the title bar. 
          The title bar of the window which has input focus is highlighted. 
          Actually, there are two main types of keyboard messages, depending on your view of the keyboard. 
          You can view a keyboard as a collection of keys. In this case, if you press a key, 
          Windows sends a WM_KEYDOWN message to the window which has input focus, notifying that a key is pressed.
          When you release the key, Windows sends a WM_KEYUP message. You treat a key as a button.
          Another way to look at the keyboard is that it's a character input device. When you press 
          "a" key, Windows sends a WM_CHAR message to the window which has input focus, 
          telling it that the user sends "a" character to it. In fact, Windows sends WM_KEYDOWN and WM_KEYUP messages 
          to the window which has input focus and those messages will be translated to WM_CHAR messages 
          by TranslateMessage call. The window procedure may decide to process all three messages 
          or only the messages it's interested in. Most of the time, you can ignore WM_KEYDOWN and WM_KEYUP 
          since TranslateMessage function call in the message loop translate WM_KEYDOWN and WM_KEYUP messages 
  to WM_CHAR messages. We will focus on WM_CHAR in this tutorial. 
  
Example:
.386 
.model flat,stdcall 
option casemap:none 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 

include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\gdi32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
includelib \Masm32\lib\gdi32.lib 

.data 
ClassName db "SimpleWinClass",0 
AppName  db "Our First Window",0 
char WPARAM 20h                         ; the character the program receives from keyboard 

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov CommandLine,eax
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_WINDOW+1 
    mov   wc.lpszMenuName,NULL 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\ 
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\ 
           hInst,NULL 
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,SW_SHOWNORMAL 
    invoke UpdateWindow, hwnd 
    .WHILE TRUE 
                invoke GetMessage, ADDR msg,NULL,0,0 
                .BREAK .IF (!eax) 
                invoke TranslateMessage, ADDR msg 
                invoke DispatchMessage, ADDR msg 
        .ENDW 
    mov     eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    LOCAL hdc:HDC 
    LOCAL ps:PAINTSTRUCT 

    .IF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSEIF uMsg==WM_CHAR 
        push wParam 
        pop  char 
        invoke InvalidateRect, hWnd,NULL,TRUE 
    .ELSEIF uMsg==WM_PAINT 
        invoke BeginPaint,hWnd, ADDR ps 
        mov    hdc,eax 
        invoke TextOut,hdc,0,0,ADDR char,1 
        invoke EndPaint,hWnd, ADDR ps 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor    eax,eax 
    ret 
WndProc endp 
end start 
  

Analysis:

     char WPARAM 20h                         ; the character the program receives from keyboard 
     
     This is the variable that will store the character received from the keyboard. Since the character is sent 
     in WPARAM of the window procedure, we define the variable as type WPARAM for simplicity. The initial value 
     is 20h or the space since when our window refreshes its client area the first time, there is no character
      input. So we want to display space instead. 
     
         .ELSEIF uMsg==WM_CHAR 
             push wParam 
             pop  char 
             invoke InvalidateRect, hWnd,NULL,TRUE 
     
     This is added in the window procedure to handle the WM_CHAR message. It just puts the character into 
     in the client area invalid which forces Windows to send WM_PAINT message to the window procedure. 
     Its syntax is as follows: 
     
     InvalidateRect proto hWnd:HWND,\ 
                                      lpRect:DWORD,\ 
                                      bErase:DWORD 
     
     lpRect is a pointer to the rectagle in the client area that we want to declare invalid. If this parameter 
     is null, the entire client area will be marked as invalid. 
     bErase is a flag telling Windows if it needs to erase the background. If this flag is TRUE, then Windows
      will erase the backgroud of the invalid rectangle when BeginPaint is called. 
     
     So the strategy we used here is that: we store all necessary information relating to painting the client
      area and generate WM_PAINT message to paint the client area. Of course, the codes in WM_PAINT section 
      
      must know beforehand what's expected of them. This seems a roundabout way of doing things but 
      it's the way of Windows. 
     Actually we can paint the client area during processing WM_CHAR message by calling GetDC and ReleaseDC pair. 
     There is no problem there. But the fun begins when our window needs to repaint its client area. 
     Since the codes that paint the character are in WM_CHAR section, the window procedure will not 
     be able to repaint our character in the client area. So the bottom line is: put all necessary data 
     and codes that do painting in WM_PAINT. You can send WM_PAINT message from anywhere in your code 
     anytime you want to repaint the client area. 

        invoke TextOut,hdc,0,0,ADDR char,1 

When InvalidateRect is called, it sends a WM_PAINT message back to the window procedure. 
So the codes in WM_PAINT section is called. It calls BeginPaint as usual to get the handle to 
device context and then call TextOut which draws our character in the client area at x=0, y=0. 
When you run the program and press any key, you will see that character echo in the upper 
left corner of the client window. And when the window is minimized and maximized again, 
the character is still there since all the codes and data essential to repaint are all 
gathered in WM_PAINT section.



Tutorial 7:' Mouse Input '
  
We will learn how to receive and respond to mouse input in our window procedure. 
The example program will wait for left mouse clicks and display a text string at the exact clicked spot 
in the client area. 
Theory:
          As with keyboard input, Windows detects and sends notifications about mouse activities that are relevant 
          to each window. Those activities include left and right clicks, mouse cursor movement over window, double 
          clicks. Unlike keyboard input which is directed to the window that has input focus, mouse messages are sent
          to any window that the mouse cursor is over, active or not. In addition, there are mouse messages about 
          the non-client area too. But most of the time, we can blissfully ignore them. We can focus on those 
          relating to the client area. 
          There are two messages for each mouse button: WM_LBUTTONDOWN,WM_RBUTTONDOWN and WM_LBUTTONUP, WM_RBUTTONUP 
          messages. For a mouse with three buttons, there are also WM_MBUTTONDOWN and WM_MBUTTONUP. When the mouse 
          cursor moves over the client area, Windows sends WM_MOUSEMOVE messages to the window under the cursor. 
          A window can receive double click messages, WM_LBUTTONDBCLK or WM_RBUTTONDBCLK, if and only if its window 
          class has CS_DBLCLKS style flag, else the window will receive only a series of mouse button up and 
          down messages. 
          For all these messages, the value of lParam contains the position of the mouse. The low word is the
          x-coordinate, and the high word is the y-coordinate relative to upper left corner of the client area 
          of the window. wParam indicates the state of the mouse buttons and Shift and Ctrl keys. 
  
Example:
.386 
.model flat,stdcall 
option casemap:none 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 

include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\gdi32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
includelib \Masm32\lib\gdi32.lib 

.data 
ClassName db "SimpleWinClass",0 
AppName  db "Our First Window",0 
MouseClick db 0         ; 0=no click yet 

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
hitpoint POINT <> 

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov CommandLine,eax 
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_WINDOW+1 
    mov   wc.lpszMenuName,NULL 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\ 
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\ 
           hInst,NULL 
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,SW_SHOWNORMAL 
    invoke UpdateWindow, hwnd 
    .WHILE TRUE 
                invoke GetMessage, ADDR msg,NULL,0,0 
                .BREAK .IF (!eax) 
                invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov     eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    LOCAL hdc:HDC 
    LOCAL ps:PAINTSTRUCT 

    .IF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSEIF uMsg==WM_LBUTTONDOWN 
        mov eax,lParam 
        and eax,0FFFFh 
        mov hitpoint.x,eax 
        mov eax,lParam 
        shr eax,16 
        mov hitpoint.y,eax 
        mov MouseClick,TRUE 
        invoke InvalidateRect,hWnd,NULL,TRUE 
    .ELSEIF uMsg==WM_PAINT 
        invoke BeginPaint,hWnd, ADDR ps 
        mov    hdc,eax 
        .IF MouseClick 
            invoke lstrlen,ADDR AppName 
            invoke TextOut,hdc,hitpoint.x,hitpoint.y,ADDR AppName,eax 
        .ENDIF 
        invoke EndPaint,hWnd, ADDR ps 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor    eax,eax 
    ret 
WndProc endp 
end start 
  

Analysis:
    .ELSEIF uMsg==WM_LBUTTONDOWN 
        mov eax,lParam 
        and eax,0FFFFh 
        mov hitpoint.x,eax 
        mov eax,lParam 
        shr eax,16 
        mov hitpoint.y,eax 
        mov MouseClick,TRUE 
        invoke InvalidateRect,hWnd,NULL,TRUE 
The window procedure waits for left mouse button click. When it receives WM_LBUTTONDOWN, 
lParam contains the coordinate of the mouse cursor in the client area. 
It saves the coordinate in a variable of type POINT which is defined as: 

POINT STRUCT 
    x   dd ? 
    y   dd ? 
POINT ENDS 

and sets the flag, MouseClick, to TRUE, meaning that there's at least a left mouse button click
 in the client area. 

        mov eax,lParam 
        and eax,0FFFFh 
        mov hitpoint.x,eax 

Since x-coordinate is the low word of lParam and the members of POINT structure are 32-bit in size,
 we have to zero out the high word of eax prior to storing it in hitpoint.x. 

        shr eax,16 
        mov hitpoint.y,eax 

Because y-coordinate is the high word of lParam, we must put it in the low word of eax prior to storing 
it in hitpoint.y. We do this by shifting eax 16 bits to the right. 
After storing the mouse position, we set the flag, MouseClick, to TRUE in order to let the painting 
code in WM_PAINT section know that there's at least a click in the client area so it can draw the string 
at the mouse position. Next  we call InvalidateRect function to force the window to repaint its entire 
client area. 

        .IF MouseClick 
            invoke lstrlen,ADDR AppName 
            invoke TextOut,hdc,hitpoint.x,hitpoint.y,ADDR AppName,eax 
        .ENDIF 

The painting code in WM_PAINT section must check if MouseClick is true, since when the window was created, 
it received a WM_PAINT message which at that time, no mouse click had occurred so it should not draw the 
string in the client area. We initialize MouseClick to FALSE and change its value to TRUE when an actual 
mouse click occurs. 
If at least one mouse click has occurred, it draws the string in the client area at the mouse position. 
Note that it calls lstrlen to get the length of the string to display and sends the length as the last 
of TextOut function.

Unfortunately you can't run Java applets  


Tutorial 8: Menu
  
In this tutorial, we will learn how to incorporate a menu into our window. 
Theory:
          Menu is one of the most important component in your window. Menu presents a list of services a program 
          offers to the user. The user doesn't have to read the manual included with the program to be able to use it,
          he can peruse the menu to get an overview of the capability of a particular program and start playing with 
          it immediately. Since a menu is a tool to get the user up and running quickly, you should follow the standard. 
          Succintly put, the first two menu items should be File and Edit and the last should be Help. You can insert
          your own menu items between Edit and Help. If a menu item invokes a dialog box, you should append an 
          ellipsis (...) to the menu string. 
          Menu is a kind of resource. There are several kinds of resources such as dialog box, string table, 
          icon, bitmap, menu etc. Resources are described in a separated file called a resource file which normally has .
          rc extension. You then combine the resources with the source code during the link stage. The final product 
          is an executable file which contains both instructions and resources. 
          You can write resource scripts using any text editor. They're composed of phrases which describe the 
          appearances and other attributes of the resources used in a particular program Although you can write 
          resource scripts with a text editor, it's rather cumbersome. 
          A better alternative is to use a resource editor which lets you visually design resources with ease. 
          Resource editors are usually included in compiler packages such as Visual C++, Borland C++, etc. 
          You describe a menu resource like this: 
  
MyMenu  MENU 
{ 
   [menu list here] 
}
          C programmers may recognize that it is similar to declaring a structure. MyMenu being a menu name followed 
          by MENU keyword and menu list within curly brackets. Alternatively, you can use BEGIN and END instead of 
          the curly brackets if you wish. This syntax is more palatable to Pascal programmers. 
          Menu list can be either MENUITEM or POPUP statement. 
          MENUITEM statement defines a menu bar which doesn't invoke a popup menu when selected.The syntax is as 
          follows: 
          MENUITEM "&text", ID [,options]
          It begins by MENUITEM keyword followed by the text you want to use as menu bar string. Note the ampersand. 
          It causes the character that follows it to be underlined. Following the text string is the ID of the menu item. The ID is a number that will be used to identify the menu item in the message sent to the window procedure when the menu item is selected. As such, each menu ID must be unique among themselves. 
          Options are optional. Available options are as follows: 
          GRAYED  The menu item is inactive, and it does not generate a WM_COMMAND message. The text is grayed. 
          INACTIVE The menu item is inactive, and it does not generate a WM_COMMAND message. 
          The text is displayed normally. 
          MENUBREAK  This item and the following items appear on a new line of the menu. 
          HELP  This item and the following items are right-justified. 
          You can use one of the above option or combine them with "or" operator. 
          Beware that INACTIVE and GRAYED cannot be combined together. 
POPUP statement has the following syntax: 
  
POPUP "&text" [,options] 
{ 
  [menu list] 
}
          POPUP statement defines a menu bar that, when selected, drops down a list of menu items in a 
          small popup window. The menu list can be a MENUTIEM or POPUP statement. 
          There's a special kind of MENUITEM statement, MENUITEM SEPARATOR, which will draw a horizontal line 
          in the popup window. 
          The next step after you are finished with the menu resource script is to reference it in your program. 
          You can do this in two different places in your program. 
          In lpszMenuName member of WNDCLASSEX structure. Say, if you have a menu named "FirstMenu", 
          you can assigned the menu to your window like this: 
.DATA 
MenuName  db "FirstMenu",0 
........................... 
........................... 
.CODE 
........................... 
mov   wc.lpszMenuName, OFFSET MenuName 
........................... 
In menu handle parameter of CreateWindowEx like this: 
.DATA 
MenuName  db "FirstMenu",0 
hMenu HMENU ? 
........................... 
........................... 
.CODE 
........................... 
invoke LoadMenu, hInst, OFFSET MenuName 
mov   hMenu, eax 
invoke CreateWindowEx,NULL,OFFSET ClsName,\ 
            OFFSET Caption, WS_OVERLAPPEDWINDOW,\ 
            CW_USEDEFAULT,CW_USEDEFAULT,\ 
            CW_USEDEFAULT,CW_USEDEFAULT,\ 
            NULL,\ 
           hMenu,\ 
            hInst,\ 
            NULL\ 
........................... 
          So you may ask, what's the difference between these two methods? 
          When you reference the menu in the WNDCLASSEX structure, the menu becomes the "default" menu for the
          window class. Every window of that class will have the same menu. 
          If you want each window created from the same class to have different menus, you must choose the 
          second form. In this case, any window that is passed a menu handle in its CreateWindowEx function 
          will have a menu that "overrides" the default menu defined in the WNDCLASSEX structure. 
          Next we will examine how a menu notifies the window procedure when the user selects a menu item. 
          When the user selects a menu item, the window procedure will receive a WM_COMMAND message. 
          The low word of wParam contains the menu ID of the selected menu item. 
          Now we have sufficient information to create and use a menu. Let's do it. 
Example:
The first example shows how to create and use a menu by specifying the menu name in the window class. 
.386 
.model flat,stdcall 
option casemap:none 

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 

include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 

.data 
ClassName db "SimpleWinClass",0 
AppName  db "Our First Window",0 
MenuName db "FirstMenu",0                ; The name of our menu in the resource file. 
Test_string db "You selected Test menu item",0 
Hello_string db "Hello, my friend",0 
Goodbye_string db "See you again, bye",0 

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 

.const 
IDM_TEST equ 1                    ; Menu IDs 
IDM_HELLO equ 2 
IDM_GOODBYE equ 3 
IDM_EXIT equ 4 

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov CommandLine,eax 
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_WINDOW+1 
    mov   wc.lpszMenuName,OFFSET MenuName        ; Put our menu name here 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\ 
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\ 
           hInst,NULL 
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,SW_SHOWNORMAL 
    invoke UpdateWindow, hwnd 
    .WHILE TRUE 
                invoke GetMessage, ADDR msg,NULL,0,0 
                .BREAK .IF (!eax) 
                invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov     eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    .IF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam 
        .IF ax==IDM_TEST 
            invoke MessageBox,NULL,ADDR Test_string,OFFSET AppName,MB_OK 
        .ELSEIF ax==IDM_HELLO 
            invoke MessageBox, NULL,ADDR Hello_string, OFFSET AppName,MB_OK 
        .ELSEIF ax==IDM_GOODBYE 
            invoke MessageBox,NULL,ADDR Goodbye_string, OFFSET AppName, MB_OK 
        .ELSE 
            invoke DestroyWindow,hWnd 
        .ENDIF 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor    eax,eax 
    ret 
WndProc endp 
end start 
***************************************************************************************************
Menu.rc 
*************************************************************************************************** 
#include <resource.h>
#define IDM_TEST 1 
#define IDM_HELLO 2 
#define IDM_GOODBYE 3 
#define IDM_EXIT 4 

FirstMenu MENU 
BEGIN 
 POPUP "&PopUp" 
        GEGIN 
              MENUITEM "&Say Hello",IDM_HELLO 
              MENUITEM "Say &GoodBye", IDM_GOODBYE 
              MENUITEM SEPARATOR 
         		MENUITEM "E&xit",IDM_EXIT 
        END 
 MENUITEM "&Test", IDM_TEST 
END 
  

Analysis:
Let's analyze the resource file first. 
  
#define IDM_TEST    1                /* equal to IDM_TEST equ 1*/ 
#define IDM_HELLO   2 
#define IDM_GOODBYE 3 
#define IDM_EXIT    4 
 
The above lines define the menu IDs used by the menu script. You can assign any value 
to the ID as long as the value is unique in the menu. 
FirstMenu MENU 

Declare your menu with MENU keyword. 

 POPUP "&PopUp" 
        BEGIN 
         MENUITEM "&Say Hello",IDM_HELLO 
         MENUITEM "Say &GoodBye", IDM_GOODBYE 
         MENUITEM SEPARATOR 
         MENUITEM "E&xit",IDM_EXIT 
        END 

Define a popup menu with four menu items, the third one is a menu separator. 

 MENUITEM "&Test", IDM_TEST 

Define a menu bar in the main menu. 
Next we will examine the source code. 
  

          MenuName db "FirstMenu",0                ; The name of our menu in the resource file. 
          Test_string db "You selected Test menu item",0 
          Hello_string db "Hello, my friend",0 
          Goodbye_string db "See you again, bye",0 
           
          MenuName is the name of the menu in the resource file. Note that you can define more than one menu 
          in the resource file so you must specify which menu you want to use. The remaining three lines define 
          the text strings to be displayed in message boxes that are invoked when the appropriate menu item is 
          selected by the user. 
  
IDM_TEST equ    1                    ; Menu IDs 
IDM_HELLO equ   2 
IDM_GOODBYE equ 3 
IDM_EXIT equ    4 
 
Define menu IDs for use in the window procedure. These values MUST be identical to those defined in 
the resource file. 
    .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam 
        .IF ax==IDM_TEST 
            invoke MessageBox,NULL,ADDR Test_string,OFFSET AppName,MB_OK 
        .ELSEIF ax==IDM_HELLO 
            invoke MessageBox, NULL,ADDR Hello_string, OFFSET AppName,MB_OK 
        .ELSEIF ax==IDM_GOODBYE 
            invoke MessageBox,NULL,ADDR Goodbye_string, OFFSET AppName, MB_OK 
        .ELSE 
            invoke DestroyWindow,hWnd 
        .ENDIF 

          In the window procedure, we process WM_COMMAND messages. When the user selects a menu item, the menu ID 
          of that menu item is sended to the window procedure in the low word of wParam along with the WM_COMMAND 
          message. So when we store the value of wParam in eax, we compare the value in ax to the menu IDs we 
          previously and act accordingly. In the first three cases, when the user selects Test, Say Hello, 
          and Say GoodBye menu items, we just display a text string in a message box. 
          If the user selects Exit menu item, we call DestroyWindow with the handle of our window as its parameter 
          which will close our window. 
          As you can see, specifying menu name in a window class is quite easy and straightforward. However 
          you can also use an alternate method to load a menu in your window. I won't show the entire source code here. 
          The resource file is the same in both methods. There are some minor changes in the source file which 
I 'll show below. 
  
.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
hMenu HMENU ?                    ; handle of our menu 
 
Define a variable of type HMENU to store our menu handle. 
        invoke LoadMenu, hInst, OFFSET MenuName 
        mov    hMenu,eax 
        INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\ 
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,hMenu,\ 
           hInst,NULL 

Before calling CreateWindowEx, we call LoadMenu with the instance handle and a pointer to the name of our menu. 
LoadMenu returns the handle of our menu in the resource file which we pass to CreateWindowEx.

Unfortunately you can't run Java applets  


Tutorial 9: Child Window Controls
  
In this tutorial, we will explore child window controls which are very important input and output devices 
of our programs. 
Theory:
          Windows provides several predefined window classes which we can readily use in our own programs. 
          Most of the time we use them as components of a dialog box so they're usually called child window controls. 
          The child window controls process their own mouse and keyboard messages and notify the parent 
          window when their states have changed. They relieve the burden from programmers enormously 
          so you should use them as much as possible. In this tutorial, I put them on a normal window 
          just to demonstrate how you can create and use them but in reality you should put them in a dialog box. 
          Examples of predefined window classes are button, listbox, checkbox, radio button,edit etc. 
          In order to use a child window control, you must create it with CreateWindow or CreateWindowEx. 
          Note that you don't have to register the window class since it's registered for you by Windows. 
          The class name parameter MUST be the predefined class name. Say, if you want to create a button,
           you must specify "button" as the class name in CreateWindowEx. The other parameters you must 
          fill in are the parent window handle and the control ID. The control ID must be unique among 
          the controls. The control ID is the ID of that control. You use it to differentiate between  controls. 
          After the control was created, it will send messages notifying the parent window when its state has changed. 
          Normally, you create the child windows during WM_CREATE message of the parent window. 
          The child window sends WM_COMMAND messages to the parent window with its control ID 
          in the low word of wParam,  the notification code in the high word of wParam, and 
          its window handle in lParam. Each child window control has different notification codes, 
          refer to your Win32 API reference for more information. 
          The parent window can send commands to the child windows too, by calling SendMessage function. 
          SendMessage function sends the specified message with accompanying values in wParam and lParam 
          to the window specified by the window handle. It's an extremely useful function since it 
          can send messages to any window provided you know its window handle. 
          So, after creating the child windows, the parent window must process WM_COMMAND messages to 
          be able to receive notification codes from the child windows. 
          Example:
          We will create a window which contains an edit control and a pushbutton. 
          When you click the button, a message box will appear showing the text you typed in the edit box. 
          There is also a menu with 4 menu items: 
          Say Hello  -- Put a text string into the edit box 
          Clear Edit Box -- Clear the content of the edit box 
          Get Text -- Display a message box with the text in the edit box 
          Exit -- Close the program. 
.386 
.model flat,stdcall 
option casemap:none 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 

include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 

.data 
ClassName db "SimpleWinClass",0 
AppName  db "Our First Window",0 
MenuName db "FirstMenu",0 
ButtonClassName db "button",0 
ButtonText db "My First Button",0 
EditClassName db "edit",0 
TestString db "Wow! I'm in an edit box now",0 

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
hwndButton HWND ? 
hwndEdit HWND ? 
buffer db 512 dup(?)                    ; buffer to store the text retrieved from the edit box 

.const 
ButtonID equ 1                                ; The control ID of the button control 
EditID equ 2                                    ; The control ID of the edit control 
IDM_HELLO equ 1 
IDM_CLEAR equ 2 
IDM_GETTEXT equ 3 
IDM_EXIT equ 4 

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov CommandLine,eax 
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_BTNFACE+1 
    mov   wc.lpszMenuName,OFFSET MenuName 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName, \ 
                        ADDR AppName, WS_OVERLAPPEDWINDOW,\ 
                        CW_USEDEFAULT, CW_USEDEFAULT,\ 
                        300,200,NULL,NULL, hInst,NULL 
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,SW_SHOWNORMAL 
    invoke UpdateWindow, hwnd 
    .WHILE TRUE 
        invoke GetMessage, ADDR msg,NULL,0,0 
        .BREAK .IF (!eax) 
        invoke TranslateMessage, ADDR msg 
        invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov     eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    .IF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSEIF uMsg==WM_CREATE 
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\ 
                        ES_AUTOHSCROLL,\ 
                        50,35,200,25,hWnd,8,hInstance,NULL 
        mov  hwndEdit,eax 
        invoke SetFocus, hwndEdit 
        invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        75,70,140,25,hWnd,ButtonID,hInstance,NULL 
        mov  hwndButton,eax 
    .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam 
        .IF lParam==0 
            .IF ax==IDM_HELLO 
                invoke SetWindowText,hwndEdit,ADDR TestString 
            .ELSEIF ax==IDM_CLEAR 
                invoke SetWindowText,hwndEdit,NULL 
            .ELSEIF  ax==IDM_GETTEXT 
                invoke GetWindowText,hwndEdit,ADDR buffer,512 
                invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK 
            .ELSE 
                invoke DestroyWindow,hWnd 
            .ENDIF 
        .ELSE 
            .IF ax==ButtonID 
                shr eax,16 
                .IF ax==BN_CLICKED 
                    invoke SendMessage,hWnd,WM_COMMAND,IDM_GETTEXT,0 
                .ENDIF 
            .ENDIF 
        .ENDIF 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
     xor    eax,eax 
    ret 
WndProc endp 
end start 

Analysis:
Let's analyze the program. 
    .ELSEIF uMsg==WM_CREATE 
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, \ 
                        ADDR EditClassName,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT\ 
                        or ES_AUTOHSCROLL,\ 
                        50,35,200,25,hWnd,EditID,hInstance,NULL 
        mov  hwndEdit,eax 
        invoke SetFocus, hwndEdit 
        invoke CreateWindowEx,NULL, ADDR ButtonClassName,\ 
                        ADDR ButtonText,\ 
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\ 
                        75,70,140,25,hWnd,ButtonID,hInstance,NULL 
        mov  hwndButton,eax
          We create the controls during processing of WM_CREATE message. We call CreateWindowEx with an extra window style,  
          WS_EX_CLIENTEDGE, which makes the client area look sunken. The name of each control is a predefined one,   
          "edit" for edit control,
          "button" for button control. Next we specify the child window's styles. Each control has extra styles 
          in addition to the normal window styles. For example, the button styles are prefixed with "BS_" for 
          "button style", edit styles are prefixed with "ES_" for "edit style". You have to look these styles up 
          in a Win32 API reference. Note that you put a control ID in place of the menu handle. This doesn't 
          cause any harm since a child window control cannot have a menu. 
          After creating each control, we keep its handle in a variable for future use. 
          SetFocus is called to give input focus to the edit box so the user can type the text into it immediately. 
          Now comes the really exciting part. Every child window control sends notification to its parent window with
WM_COMMAND. 
    .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam 
        .IF lParam==0 

Recall that a menu also sends WM_COMMAND messages to notify the window about its state too. How can 
you differentiate between WM_COMMAND messages originated from a menu or a control? Below is the answer 
  

 Low word of wParam High word of wParam lParam 
Menu Menu ID 0 0 
Control Control ID Notification code Child Window Handle 

You can see that you should check lParam. If it's zero, the current WM_COMMAND message is from a menu. 
You cannot use wParam to differentiate between a menu and a control since the menu ID and control ID 
may be identical and the notification code may be zero. 

            .IF ax==IDM_HELLO 
                invoke SetWindowText,hwndEdit,ADDR TestString 
            .ELSEIF ax==IDM_CLEAR 
                invoke SetWindowText,hwndEdit,NULL 
            .ELSEIF  ax==IDM_GETTEXT 
                invoke GetWindowText,hwndEdit,ADDR buffer,512 
                invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK 

You can put a text string into an edit box by calling SetWindowText. You clear the content of an edit 
box by calling SetWindowText with NULL. SetWindowText is a general purpose API function. You can use 
SetWindowText to change the caption of a window or the text on a button. 
To get the text in an edit box, you use GetWindowText. 

            .IF ax==ButtonID 
                shr eax,16 
                .IF ax==BN_CLICKED 
                    invoke SendMessage,hWnd,WM_COMMAND,IDM_GETTEXT,0 
                .ENDIF 
            .ENDIF 

          The above code snippet deals with the condition when the user presses the button. First, it checks the 
          low word of wParam to see if the control ID matches that of the button. If it is, it checks the high word 
          of wParam to see if it is the notification code BN_CLICKED which is sent when the button is clicked. 
          The interesting part is after it's certain that the notification code is BN_CLICKED. We want to get 
          the text from the edit box and display it in a message box. We can duplicate the code in the IDM_GETTEXT 
          section above but it doesn't make sense. If we can somehow send a WM_COMMAND message with the low word
           of wParam containing the value IDM_GETTEXT to our own window procedure, we can avoid code duplication 
          and simplify our program. SendMessage function is the answer. This function sends any message to any 
          window with any wParam and lParam we want. So instead of duplicating the code, we call SendMessage 
          with the parent window handle, WM_COMMAND, IDM_GETTEXT, and 0. This has identical effect to selecting 
          "Get Text" menu item from the menu. The window procedure doesn't perceive any difference between the two. 
          You should use this technique as much as possible to make your code more organized. 
          Last but not least, do not forget the TranslateMessage function in the message loop. 
          Since you must type in some text into the edit box, your program must translate raw keyboard input 
		into readable text. If you omit this function, you will not be able to type anything into your edit box.

 Unfortunately you can't run Java applets  


Tutorial 10: Dialog Box as Main Window
   
Now comes the really interesting part about GUI, the dialog box. In this tutorial (and the next), we will 
learn how to use a dialog box as our main window. 
Theory:
If you play with the examples in the previous tutorial long enough, you 'll find out that you cannot change 
input focus from one child window control to another with Tab key. The only way you can do that is by clicking 
the control you want it to gain input focus. This situation is rather cumbersome. Another thing you might notice is that I changed the background color of the parent window to gray instead of normal white as in previous examples. This is done so that the color of the child window controls can blend seamlessly with the color of the client area of the parent window. There is a way to get around this problem but it's not easy. You have to subclass all child window controls in your parent window. 
The reason why such inconvenience exists is that child window controls are originally designed to work with 
a dialog box, not a normal window. The default color of child window controls such as a button is gray because
 the client area of a dialog box is normally gray so they blend into each other without any sweat on the 
 programmer's part. 
Before we get deep into the detail, we should know first what a dialog box is. A dialog box is nothing more 
than a normal window which is designed to work with child window controls. Windows also provides internal 
"dialog box manager" which is responsible for most of the keyboard logic such as shifting input focus when 
the user presses Tab, pressing the default pushbutton if Enter key is pressed, etc so programmers can deal
 with higher level tasks. Dialog boxes are primarily used as input/output devices. As such a dialog box can 
 be considered as an input/output "black box" meaning that you don't have to know how a dialog box works 
 internally in order to be able to use it, you only have to know how to interact with it. That's a principle 
 of object oriented programming (OOP) called information hiding. If the black box is *perfectly* designed, 
 the user can make use of it without any knowledge on how it operates. The catch is that the black box must 
 be perfect, that's hard to achieve in the real world. Win32 API is also designed as a black box too. 
Well, it seems we stray from our path. Let's get back to our subject. Dialog boxes are designed to reduce
 workload of a programmer. Normally if you put child window controls on a normal window, you have to subclass them and write keyboard logic yourself. But if you put them on a dialog box, it will handle the logic for you. You only have to know how to get the user input from the dialog box or how to send commands to it. 
A dialog box is defined as a resource much the same way as a menu. You write a dialog box template describing the characteristics of the dialog box and its controls and then compile the resource script with a resource editor. 
Note that all resources are put together in the same resource script file. You can use any text editor to write a dialog box template but I don't recommend it. You should use a resource editor to do the job visually since arranging child window controls on a dialog box is hard to do manually. Several excellent resource editors are available. Most of the major compiler suites include their own resource editors. You can use them to create a resource script for your program and then cut out irrelevant lines such as those related to MFC. 
There are two main types of dialog box: modal and modeless. A modeless dialog box lets you change input focus to other window. The example is the Find dialog of MS Word. There are two subtypes of modal dialog box: application modal and system modal. An application modal dialog box doesn't let you change input focus to other window in the same application but you can change the input focus to the window of OTHER application. A system modal dialog box doesn't allow you to change input focus to any other window until you respond to it first. 
A modeless dialog box is created by calling CreateDialogParam API function. A modal dialog box is created by calling DialogBoxParam. The only distinction between an application modal dialog box and a system modal one is the DS_SYSMODAL style. If you include DS_SYSMODAL style in a dialog box template, that dialog box will be a system modal one. 
You can communicate with any child window control on a dialog box by using SendDlgItemMessage function. Its syntax is like this: 
  
SendDlgItemMessage proto hwndDlg:DWORD,\ 
                                             idControl:DWORD,\ 
                                             uMsg:DWORD,\ 
                                             wParam:DWORD,\ 
                                             lParam:DWORD
This API call is immensely useful for interacting with a child window control. For example, if you want to get the text from an edit control, you can do this: 
call SendDlgItemMessage, hDlg, ID_EDITBOX, WM_GETTEXT, 256, ADDR text_buffer
In order to know which message to send, you should consult your Win32 API reference. 
Windows also provides several control-specific API functions to get and set data quickly, for example, GetDlgItemText, CheckDlgButton etc. These control-specific functions are provided for programmer's convenience so he doesn't have to look up the meanings of wParam and lParam for each message. Normally, you should use control-specific API calls when they're available since they make source code maintenance easier. Resort to SendDlgItemMessage only if no control-specific API calls are available. 
The Windows dialog box manager sends some messages to a specialized callback function called a dialog box procedure which has the following format: 
DlgProc  proto hDlg:DWORD ,\ 
                        iMsg:DWORD ,\ 
                        wParam:DWORD ,\ 
                        lParam:DWORD
The dialog box procedure is very similar to a window procedure except for the type of return value which is TRUE/FALSE instead of LRESULT. The internal dialog box manager inside Windows IS the true window procedure for the dialog box. It calls our dialog box procedure with some messages that it received. So the general rule of thumb is that: if our dialog box procedure processes a message,it MUST return TRUE in eax and if it does not process the message, it must return FALSE in eax. Note that a dialog box procedure doesn't pass the messages it does not process to the DefWindowProc call since it's not a real window procedure. 
There are two distinct uses of a dialog box. You can use it as the main window of your application or use it as an input device. We 'll examine the first approach in this tutorial. 
"Using a dialog box as main window" can be interpreted in two different senses. 
You can use the dialog box template as a class template which you register with RegisterClassEx call. In this case, the dialog box behaves like a "normal" window: it receives messages via a window procedure referred to by lpfnWndProc member of the window class, not via a dialog box procedure. The benefit of this approach is that you don't have to create child window controls yourself, Windows creates them for you when the dialog box is created. Also Windows handles the keyboard logic for you such as Tab order etc. Plus you can specify the cursor and icon of your window in the window class structure. 
Your program just creates the dialog box without creating any parent window. This approach makes a message loop unnecessary since the messages are sent directly to the dialog box procedure. You don't even have to register a window class!
This tutorial is going to be a long one. I'll present the first approach followed by the second. 
Examples:

--------------------------------------------------------------------------------

dialog.asm

--------------------------------------------------------------------------------

.386 
.model flat,stdcall 
option casemap:none 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
.data 
ClassName db "DLGCLASS",0 
MenuName db "MyMenu",0 
DlgName db "MyDialog",0 
AppName db "Our First Dialog Box",0 
TestString db "Wow! I'm in an edit box now",0 

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
buffer db 512 dup(?) 

.const 
IDC_EDIT        equ 3000 
IDC_BUTTON      equ 3001 
IDC_EXIT        equ 3002 
IDM_GETTEXT     equ 32000 
IDM_CLEAR       equ 32001 
IDM_EXIT        equ 32002 

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov CommandLine,eax 
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hDlg:HWND 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,DLGWINDOWEXTRA 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_BTNFACE+1 
    mov   wc.lpszMenuName,OFFSET MenuName 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateDialogParam,hInstance,ADDR DlgName,NULL,NULL,NULL 
    mov   hDlg,eax 
    invoke ShowWindow, hDlg,SW_SHOWNORMAL 
    invoke UpdateWindow, hDlg 
    invoke GetDlgItem,hDlg,IDC_EDIT 
    invoke SetFocus,eax 
    .WHILE TRUE 
        invoke GetMessage, ADDR msg,NULL,0,0 
        .BREAK .IF (!eax) 
       invoke IsDialogMessage, hDlg, ADDR msg 
        .IF eax ==FALSE 
            invoke TranslateMessage, ADDR msg 
            invoke DispatchMessage, ADDR msg 
        .ENDIF 
    .ENDW 
    mov     eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    .IF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam 
        .IF lParam==0 
            .IF ax==IDM_GETTEXT 
                invoke GetDlgItemText,hWnd,IDC_EDIT,ADDR buffer,512 
                invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK 
            .ELSEIF ax==IDM_CLEAR 
                invoke SetDlgItemText,hWnd,IDC_EDIT,NULL 
            .ELSE 
                invoke DestroyWindow,hWnd 
            .ENDIF 
        .ELSE 
            mov edx,wParam 
            shr edx,16 
            .IF dx==BN_CLICKED 
                .IF ax==IDC_BUTTON 
                    invoke SetDlgItemText,hWnd,IDC_EDIT,ADDR TestString 
                .ELSEIF ax==IDC_EXIT 
                    invoke SendMessage,hWnd,WM_COMMAND,IDM_EXIT,0 
                .ENDIF 
            .ENDIF 
        .ENDIF 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor    eax,eax 
    ret 
WndProc endp 
end start 



--------------------------------------------------------------------------------

Dialog.rc

--------------------------------------------------------------------------------

#include "resource.h" 
#define IDC_EDIT                                       3000 
#define IDC_BUTTON                                3001 
#define IDC_EXIT                                       3002 

#define IDM_GETTEXT                             32000 
#define IDM_CLEAR                                  32001 
#define IDM_EXIT                                      32003 
  

MyDialog DIALOG 10, 10, 205, 60 
STYLE 0x0004 | DS_CENTER | WS_CAPTION | WS_MINIMIZEBOX | 
WS_SYSMENU | WS_VISIBLE | WS_OVERLAPPED | DS_MODALFRAME | DS_3DLOOK 
CAPTION "Our First Dialog Box" 
CLASS "DLGCLASS" 
BEGIN 
    EDITTEXT         IDC_EDIT,   15,17,111,13, ES_AUTOHSCROLL | ES_LEFT 
    DEFPUSHBUTTON   "Say Hello", IDC_BUTTON,    141,10,52,13 
    PUSHBUTTON      "E&xit", IDC_EXIT,  141,26,52,13, WS_GROUP 
END 
  

MyMenu  MENU 
BEGIN 
    POPUP "Test Controls" 
    BEGIN 
        MENUITEM "Get Text", IDM_GETTEXT 
        MENUITEM "Clear Text", IDM_CLEAR 
        MENUITEM "", , 0x0800 /*MFT_SEPARATOR*/ 
        MENUITEM "E&xit", IDM_EXIT 
    END 
END 

Analysis:
Let's analyze this first example. 
This example shows how to register a dialog template as a window class and create a "window" from that class. It simplifies your program since you don't have to create the child window controls yourself. 
Let's first analyze the dialog template. 
MyDialog DIALOG 10, 10, 205, 60 

Declare the name of a dialog, in this case, "MyDialog" followed by the keyword "DIALOG". The following four numbers are: x, y , width, and height of the dialog box in dialog box units (not the same as pixels). 

STYLE 0x0004 | DS_CENTER | WS_CAPTION | WS_MINIMIZEBOX | 
WS_SYSMENU | WS_VISIBLE | WS_OVERLAPPED | DS_MODALFRAME | DS_3DLOOK 

Declare the styles of the dialog box. 

CAPTION "Our First Dialog Box" 

This is the text that will appear in the dialog box's title bar. 

CLASS "DLGCLASS" 

This line is crucial. It's this CLASS keyword that allows us to use the dialog box template as a window class. Following the keyword is the name of the "window class" 

BEGIN 
    EDITTEXT         IDC_EDIT,   15,17,111,13, ES_AUTOHSCROLL | ES_LEFT 
    DEFPUSHBUTTON   "Say Hello", IDC_BUTTON,    141,10,52,13 
    PUSHBUTTON      "E&xit", IDC_EXIT,  141,26,52,13 
END 

The above block defines the child window controls in the dialog box. They're defined between BEGIN and END keywords. Generally the syntax is as follows: 

control-type  "text"   ,controlID, x, y, width, height [,styles]
control-types are resource compiler's constants so you have to consult the manual. 
Now we go to the assembly source code. The interesting part is in the window class structure: 
mov   wc.cbWndExtra,DLGWINDOWEXTRA 
mov   wc.lpszClassName,OFFSET ClassName
Normally, this member is left NULL, but if we want to register a dialog box template as a window class, we must set this member to the value DLGWINDOWEXTRA. Note that the name of the class must be identical to the one following the CLASS keyword in the dialog box template. The remaining members are initialized as usual. After you fill the window class structure, register it with RegisterClassEx. Seems familiar? This is the same routine you have to do in order to register a normal window class. 
invoke CreateDialogParam,hInstance,ADDR DlgName,NULL,NULL,NULL
After registering the "window class", we create our dialog box. In this example, I create it as a modeless dialog box with CreateDialogParam function. This function takes 5 parameters but you only have to fill in the first two: the instance handle and the pointer to the name of the dialog box template. Note that the 2nd parameter is not a pointer to the class name. 
At this point, the dialog box and its child window controls are created by Windows. Your window procedure will receive WM_CREATE message as usual. 
invoke GetDlgItem,hDlg,IDC_EDIT 
invoke SetFocus,eax
After the dialog box is created, I want to set the input focus to the edit control. If I put these codes in WM_CREATE section, GetDlgItem call will fail since at that time, the child window controls are not created yet. The only way you can do this is to call it after the dialog box and all its child window controls are created. So I put these two lines after the UpdateWindow call. GetDlgItem function gets the control ID and returns the associated control's window handle. This is how you can get a window handle if you know its control ID. 
       invoke IsDialogMessage, hDlg, ADDR msg 
        .IF eax ==FALSE 
            invoke TranslateMessage, ADDR msg 
            invoke DispatchMessage, ADDR msg 
        .ENDIF 

The program enters the message loop and before we translate and dispatch messages, we call IsDialogMessage 
function to let the dialog box manager handles the keyboard logic of our dialog box for us. If this function
 returns TRUE , it means the message is intended for the dialog box and is processed by the dialog box manager.
  Note another difference from the previous tutorial. When the window procedure wants to get the text from the 
  edit control, it calls GetDlgItemText function instead of GetWindowText. GetDlgItemText accepts a control 
  ID instead of a window handle. That makes the call easier in the case you use a dialog box. 



--------------------------------------------------------------------------------

Now let's go to the second approach to using a dialog box as a main window. In the next example, 
I 'll create an application modal dialog box. You'll not find a message loop or a window procedure because 
they're not necessary! 
--------------------------------------------------------------------------------

dialog.asm (part 2)

--------------------------------------------------------------------------------

.386 
.model flat,stdcall 
option casemap:none 
DlgProc proto :DWORD,:DWORD,:DWORD,:DWORD 

include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 

.data 
DlgName db "MyDialog",0 
AppName db "Our Second Dialog Box",0 
TestString db "Wow! I'm in an edit box now",0 

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
buffer db 512 dup(?) 

.const 
IDC_EDIT            equ 3000 
IDC_BUTTON     equ 3001 
IDC_EXIT            equ 3002 
IDM_GETTEXT  equ 32000 
IDM_CLEAR       equ 32001 
IDM_EXIT           equ 32002 
  

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke DialogBoxParam, hInstance, ADDR DlgName,NULL, addr DlgProc, NULL 
    invoke ExitProcess,eax 

DlgProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    .IF uMsg==WM_INITDIALOG 
        invoke GetDlgItem, hWnd,IDC_EDIT 
        invoke SetFocus,eax 
    .ELSEIF uMsg==WM_CLOSE 
        invoke SendMessage,hWnd,WM_COMMAND,IDM_EXIT,0 
    .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam 
        .IF lParam==0 
            .IF ax==IDM_GETTEXT 
                invoke GetDlgItemText,hWnd,IDC_EDIT,ADDR buffer,512 
                invoke MessageBox,NULL,ADDR buffer,ADDR AppName,MB_OK 
            .ELSEIF ax==IDM_CLEAR 
                invoke SetDlgItemText,hWnd,IDC_EDIT,NULL 
            .ELSEIF ax==IDM_EXIT 
                invoke EndDialog, hWnd,NULL 
            .ENDIF 
        .ELSE 
            mov edx,wParam 
            shr edx,16 
            .if dx==BN_CLICKED 
                .IF ax==IDC_BUTTON 
                    invoke SetDlgItemText,hWnd,IDC_EDIT,ADDR TestString 
                .ELSEIF ax==IDC_EXIT 
                    invoke SendMessage,hWnd,WM_COMMAND,IDM_EXIT,0 
                .ENDIF 
            .ENDIF 
        .ENDIF 
    .ELSE 
        mov eax,FALSE 
        ret 
    .ENDIF 
    mov eax,TRUE 
    ret 
DlgProc endp 
end start 



--------------------------------------------------------------------------------

dialog.rc (part 2)

--------------------------------------------------------------------------------

#include "resource.h" 
#define IDC_EDIT                                       3000 
#define IDC_BUTTON                                3001 
#define IDC_EXIT                                       3002 

#define IDR_MENU1                                  3003 

#define IDM_GETTEXT                              32000 
#define IDM_CLEAR                                   32001 
#define IDM_EXIT                                       32003 
  

MyDialog DIALOG 10, 10, 205, 60 
STYLE 0x0004 | DS_CENTER | WS_CAPTION | WS_MINIMIZEBOX | 
WS_SYSMENU | WS_VISIBLE | WS_OVERLAPPED | DS_MODALFRAME | DS_3DLOOK 
CAPTION "Our Second Dialog Box" 
MENU IDR_MENU1 
BEGIN 
    EDITTEXT         IDC_EDIT,   15,17,111,13, ES_AUTOHSCROLL | ES_LEFT 
    DEFPUSHBUTTON   "Say Hello", IDC_BUTTON,    141,10,52,13 
    PUSHBUTTON      "E&xit", IDC_EXIT,  141,26,52,13 
END 
  

IDR_MENU1  MENU 
BEGIN 
    POPUP "Test Controls" 
    BEGIN 
        MENUITEM "Get Text", IDM_GETTEXT 
        MENUITEM "Clear Text", IDM_CLEAR 
        MENUITEM "", , 0x0800 /*MFT_SEPARATOR*/ 
        MENUITEM "E&xit", IDM_EXIT 
    END 
END 



--------------------------------------------------------------------------------

The analysis follows: 
    DlgProc proto :DWORD,:DWORD,:DWORD,:DWORD 

We declare the function prototype for DlgProc so we can refer to it with addr operator in the line below: 

    invoke DialogBoxParam, hInstance, ADDR DlgName,NULL, addr DlgProc, NULL 

The above line calls DialogBoxParam function which takes 5 parameters: the instance handle, the name of the 
dialog box template, the parent window handle, the address of the dialog box procedure, and the dialog-specific
 data. DialogBoxParam creates a modal dialog box. It will not return until the dialog box is destroyed. 

    .IF uMsg==WM_INITDIALOG 
        invoke GetDlgItem, hWnd,IDC_EDIT 
        invoke SetFocus,eax 
    .ELSEIF uMsg==WM_CLOSE 
        invoke SendMessage,hWnd,WM_COMMAND,IDM_EXIT,0 

The dialog box procedure looks like a window procedure except that it doesn't receive WM_CREATE message. 
The first message it receives is WM_INITDIALOG. Normally you can put the initialization code here. 
Note that you must return the value TRUE in eax if you process the message. 
The internal dialog box manager doesn't send our dialog box procedure the WM_DESTROY message by default 
when WM_CLOSE is sent to our dialog box. So if we want to react when the user presses the close button 
on our dialog box, we must process WM_CLOSE message. In our example, we send WM_COMMAND message with the
 value IDM_EXIT in wParam. This has the same effect as when the user selects Exit menu item. EndDialog 
 is called in response to IDM_EXIT. 
The processing of WM_COMMAND messages remains the same. 
When you want to destroy the dialog box, the only way is to call EndDialog function. Do not try 
DestroyWindow! EndDialog doesn't destroy the dialog box immediately. It only sets a flag for the 
internal dialog box manager and continues to execute the next instructions. 
Now let's examine the resource file. The notable change is that instead of using a text string as 
menu name we use a value, IDR_MENU1. This is necessary if you want to attach a menu to a dialog box 
created with DialogBoxParam. Note that in the dialog box template, you have to add the keyword MENU 
followed by the menu resource ID. 
A difference between the two examples in this tutorial that you can readily observe is the lack of
 an icon in the latter example. However, you can set the icon by sending the message WM_SETICON to the 
 dialog box during WM_INITDIALOG.


Unfortunately you can't run Java applets  


Tutorial 11: More about Dialog Box
  
We will learn more about dialog box in this tutorial. Specifically, we will explore the topic of how to use 
dialog boxs as our input-output devices. If you read the previous tutorial, this one will be a breeze since 
only a minor modification is all that's needed to be able to use dialog boxes as adjuncts to our main window.
 Also in this tutorial, we will learn how to use common dialog boxes. 
Theory:
Very little is to be said about how to use dialog boxes as input-output devices of our program. Your program
 creates the main window as usual and when you want to display the dialog box, just call CreateDialogParam 
 or DialogBoxParam. With DialogBoxParam call, you don't have to do anything more, just process the messages
  in the dialog box procedure. With CreateDialogParam, you must insert IsDialogMessage call in the message 
  loop to let dialog box manager handle the keyboard navigation in your dialog box for you. Since the two 
  cases are trivial, I'll not put the source code here. You can examine the source yourself. 
Let's go on to the common dialog boxes. Windows has prepared predefined dialog boxes for use by your 
applications. These dialog boxes exist to provide standardized user interface. They consist of file, print, 
color, font, and search dialog boxes. You should use them as much as possible. The dialog boxes reside in 
comdlg32.dll. In order to use them, you have to link to comdlg32.lib. You create these dialog boxes by calling
 appropriate functions in the common dialog library. For open file dialog, it is GetOpenFileName, for save as
  dialog it is GetSaveFileName, for print dialog it is PrintDlg and so on. Each one of these functions takes
   a pointer to a structure as its parameter. You should look them up in Win32 API reference. In this tutorial,
    I'll demonstrate how to create and use an open file dialog. 
Below is the function prototype of GetOpenFileName function: 
  
GetOpenFileName proto lpofn:DWORD
You can see that it receives only one parameter, a pointer to an OPENFILENAME structure. The return value TRUE 
means the user selected a file to open, it's FALSE otherwise. We will look at OPENFILENAME structure next. 
  
OPENFILENAME  STRUCT 
 lStructSize DWORD  ? 
 hwndOwner HWND  ? 
 hInstance HINSTANCE ? 
 lpstrFilter LPCSTR  ? 
 lpstrCustomFilter LPSTR  ? 
 nMaxCustFilter DWORD  ? 
 nFilterIndex DWORD  ? 
 lpstrFile LPSTR  ? 
 nMaxFile DWORD  ? 
 lpstrFileTitle LPSTR  ? 
 nMaxFileTitle DWORD  ? 
 lpstrInitialDir LPCSTR  ? 
 lpstrTitle LPCSTR  ? 
 Flags  DWORD  ? 
 nFileOffset WORD  ? 
 nFileExtension WORD  ? 
 lpstrDefExt LPCSTR  ? 
 lCustData LPARAM  ? 
 lpfnHook DWORD  ? 
 lpTemplateName LPCSTR  ?
OPENFILENAME  ENDS
Let's see the meaning of the frequently used members. 
  
lStructSize The size of the OPENFILENAME structure , in bytes 
hwndOwner The window handle of the open file dialog box. 
hInstance Instance handle of the application that creates the open file dialog box 
lpstrFilter The filter strings in the format of  pairs of null terminated strings. The first string in each
 pair is the description. The second string is the filter pattern. for example: 
     FilterString   db "All Files (*.*)",0, "*.*",0 
                            db "Text Files (*.txt)",0,"*.txt",0,0 
Note that only the pattern in the second string in each pair is actually used by Windows to filter out the 
files. Also noted that you have to put an extra 0 at the end of the filter strings to denote the end of it. 
nFilterIndex Specify which pair of the filter strings will be initially used when the open file dialog is 
first displayed. The index is 1-based, that is the first pair is 1, the second pair is 2 and so on. So in 
the above example, if we specify nFilterIndex as 2, the second pattern, "*.txt" will be used. 
lpstrFile Pointer to the buffer that contains the filename used to initialize the filename edit control on 
the dialog box. The buffer should be at least 260 bytes long.  
After the user selects a file to open, the filename with full path is stored in this buffer. You can extract
 the information from it later. 
nMaxFile The size of the lpstrFile buffer. 
lpstrTitle Pointer to the title of the open file dialog box 
Flags Determine the styles and characteristics of the dialog box. 
nFileOffset After the user selects a file to open, this member contains the index to the first character of
 the actual filename. For example, if the full name with path is "c:\windows\system\lz32.dll", the this member
  will contain the value 18. 
nFileExtension After the user selects a file to open, this member contains the index to the first character of 
the file extension 

Example:
The following program displays an open file dialog box when the user selects File-> Open from the menu. 
When the user selects a file in the dialog box, the program displays a message box showing the full name, 
filename,and extension of the selected file. 
.386 
.model flat,stdcall 
option casemap:none 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\comdlg32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
includelib \Masm32\lib\comdlg32.lib 

.const 
IDM_OPEN equ 1 
IDM_EXIT equ 2 
MAXSIZE equ 260 
OUTPUTSIZE equ 512 

.data 
ClassName db "SimpleWinClass",0 
AppName  db "Our Main Window",0 
MenuName db "FirstMenu",0 
ofn   OPENFILENAME <> 
FilterString db "All Files",0,"*.*",0 
             db "Text Files",0,"*.txt",0,0 
buffer db MAXSIZE dup(0) 
OurTitle db "-=Our First Open File Dialog Box=-: Choose the file to open",0 
FullPathName db "The Full Filename with Path is: ",0 
FullName  db "The Filename is: ",0 
ExtensionName db "The Extension is: ",0 
OutputString db OUTPUTSIZE dup(0) 
CrLf db 0Dh,0Ah,0 

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov CommandLine,eax 
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_WINDOW+1 
    mov   wc.lpszMenuName,OFFSET MenuName 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\ 
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,300,200,NULL,NULL,\ 
           hInst,NULL 
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,SW_SHOWNORMAL 
    invoke UpdateWindow, hwnd 
    .WHILE TRUE 
        invoke GetMessage, ADDR msg,NULL,0,0 
        .BREAK .IF (!eax) 
        invoke TranslateMessage, ADDR msg 
        invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov     eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    .IF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam 
        .if ax==IDM_OPEN 
            mov ofn.lStructSize,SIZEOF ofn 
            push hWnd 
            pop  ofn.hwndOwner 
            push hInstance 
            pop  ofn.hInstance 
            mov  ofn.lpstrFilter, OFFSET FilterString 
            mov  ofn.lpstrFile, OFFSET buffer 
            mov  ofn.nMaxFile,MAXSIZE 
            mov  ofn.Flags, OFN_FILEMUSTEXIST or \ 
                OFN_PATHMUSTEXIST or OFN_LONGNAMES or\ 
                OFN_EXPLORER or OFN_HIDEREADONLY 
            mov  ofn.lpstrTitle, OFFSET OurTitle 
            invoke GetOpenFileName, ADDR ofn 
            .if eax==TRUE 
                invoke lstrcat,offset OutputString,OFFSET FullPathName 
                invoke lstrcat,offset OutputString,ofn.lpstrFile 
                invoke lstrcat,offset OutputString,offset CrLf 
                invoke lstrcat,offset OutputString,offset FullName 
                mov  eax,ofn.lpstrFile 
                push ebx 
                xor  ebx,ebx 
                mov  bx,ofn.nFileOffset 
                add  eax,ebx 
                pop  ebx 
                invoke lstrcat,offset OutputString,eax 
                invoke lstrcat,offset OutputString,offset CrLf 
                invoke lstrcat,offset OutputString,offset ExtensionName 
                mov  eax,ofn.lpstrFile 
                push ebx 
                xor ebx,ebx 
                mov  bx,ofn.nFileExtension 
                add eax,ebx 
                pop ebx 
                invoke lstrcat,offset OutputString,eax 
                invoke MessageBox,hWnd,OFFSET OutputString,ADDR AppName,MB_OK 
                invoke RtlZeroMemory,offset OutputString,OUTPUTSIZE 
            .endif 
        .else 
            invoke DestroyWindow, hWnd 
        .endif 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor    eax,eax 
    ret 
WndProc endp 
 end start 



--------------------------------------------------------------------------------

Analysis:
            mov ofn.lStructSize,SIZEOF ofn 
            push hWnd 
            pop  ofn.hwndOwner 
            push hInstance 
            pop  ofn.hInstance 
We fill in the routine members of ofn structures. 

            mov  ofn.lpstrFilter, OFFSET FilterString 

This FilterString is the filename filter that we specify as follows: 

FilterString db "All Files",0,"*.*",0 
             db "Text Files",0,"*.txt",0,0
Note that All four strings are zero terminated. The first string is the description of the following string.
 The actual pattern is the even number string, in this case, "*.*" and "*.txt". Actually we can specify any 
 pattern we want here. We MUST put an extra zero after the last pattern string to denote the end of the filter 
 string. Don't forget this else your dialog box will behave strangely. 
            mov  ofn.lpstrFile, OFFSET buffer 
            mov  ofn.nMaxFile,MAXSIZE 

We specify where the dialog box will put the filename that the user selects. Note that we must specify its 
size in nMaxFile member. We can later extract the filename from this buffer. 

            mov  ofn.Flags, OFN_FILEMUSTEXIST or \ 
                OFN_PATHMUSTEXIST or OFN_LONGNAMES or\ 
                OFN_EXPLORER or OFN_HIDEREADONLY 

Flags specifies the characteristics of the dialog box. 
OFN_FILEMUSTEXIST  and OFN_PATHMUSTEXIST flags demand that the filename and path that the user types in the
 filename edit control MUST exist. 
OFN_LONGNAMES flag tells the dialog box to show long filenames. 
OFN_EXPLORER flag specifies that the appearance of the dialog box must be explorer-like. 
OFN_HIDEREADONLY flag hides the read-only checkbox on the dialog box. 
There are many more flags that you can use. Consult your Win32 API reference. 

            mov  ofn.lpstrTitle, OFFSET OurTitle 

Specify the title of the dialog box. 

            invoke GetOpenFileName, ADDR ofn 

Call the GetOpenFileName function. Passing the pointer to the ofn structure as its parameter. 
At this time, the open file dialog box is displayed on the screen. The function will not return until the 
user selects a file to open or presses the cancel button or closes the dialog box. 
It 'll return the value TRUE in eax if the user selects a file to open. It returns FALSE otherwise. 

            .if eax==TRUE 
                invoke lstrcat,offset OutputString,OFFSET FullPathName 
                invoke lstrcat,offset OutputString,ofn.lpstrFile 
                invoke lstrcat,offset OutputString,offset CrLf 
                invoke lstrcat,offset OutputString,offset FullName 

In case the user selects a file to open, we prepare an output string to be displayed in a message box. 
We allocate a block of memory in OutputString variable and then we use an API function, lstrcat, to concatenate
 the strings together. In order to put the strings into several lines, we must separate each line with a 
 carriage return-line feed pair. 

                mov  eax,ofn.lpstrFile 
                push ebx 
                xor  ebx,ebx 
                mov  bx,ofn.nFileOffset 
                add  eax,ebx 
                pop  ebx 
                invoke lstrcat,offset OutputString,eax 

The above lines require some explanation. nFileOffset contains the index into the ofn.lpstrFile. But you cannot
 add them together directly since nFileOffset is a WORD-sized variable and lpstrFile is a DWORD-sized one. 
 So I have to put the value of nFileOffset into the low word of ebx and add it to the value of lpstrFile. 

                invoke MessageBox,hWnd,OFFSET OutputString,ADDR AppName,MB_OK 

We display the string in a message box. 

                invoke RtlZerolMemory,offset OutputString,OUTPUTSIZE 

We must *clear* the OutputString before we can fill in another string. So we use RtlZeroMemory function to 
do the job.



Unfortunately you can't run Java applets  


Tutorial 12: Memory Management and File I/O
  
We will learn the rudimentary of memory management and file i/o operation in this tutorial. In addition 
we'll use common dialog boxes as input-output devices. 
Theory:
Memory management under Win32 from the application's point of view is quite simple and straightforward. 
Each process owns a 4 GB memory address space. The memory model used is called flat memory model. In this 
model, all segment registers (or selectors) point to the same starting address and the offset is 32-bit so 
an application can access memory at any point in its own address space without the need to change the value
 of selectors. This simplifies memory management a lot. There's no "near" or "far" pointer anymore. 
Under Win16, there are two main categories of memory API functions: Global and Local. Global-type API calls
 deal with memory allocated in other segments thus they're "far" memory functions. Local-type API calls deal 
 with the local heap of the process so they're "near" memory functions. Under Win32, these two types are 
 identical. Whether you call GlobalAlloc or LocalAlloc, you get the same result. 
Steps in allocating and using memory are as follows: 
Allocate a block of memory by calling GlobalAlloc. This function returns a handle to the requested memory 
block. 
"Lock" the memory block by calling GlobalLock. This function accepts a handle to the memory block and returns
 a pointer to the memory block. 
You can use the pointer to read or write memory. 
"Unlock" the memory block by calling GlobalUnlock . This function invalidates the pointer to the memory block.
 
Free the memory block by calling GlobalFree. This function accepts the handle to the memory block. 
You can also substitute "Global" by "Local" such as LocalAlloc, LocalLock,etc. 
The above method can be further simplified by using a flag in GlobalAlloc call, GMEM_FIXED. If you use this 
flag, the return value from Global/LocalAlloc will be the pointer to the allocated memory block, not the 
memory block handle. You don't have to call Global/LocalLock and you can pass the pointer to Global/LocalFree 
without calling Global/LocalUnlock first. But in this tutorial, I'll use the "traditional" approach since you 
may encounter it when reading the source code of other programs. 
File I/O under Win32 bears remarkable semblance to that under DOS. The steps needed are the same. You only 
have to change interrupts to API calls and it's done. The required steps are the followings: 
  

Open or Create the file by calling CreateFile function. This function is very versatile: in addition to files,
 it can open communication ports, pipes, disk drives or console. On success, it returns a handle to file or 
 device. You can then use this handle to perform operations on the file or device. 
Move the file pointer to the desired location by calling SetFilePointer. 
Perform read or write operation by calling ReadFile or WriteFile. These functions transfer data from a block 
of memory to or from the file. So you have to allocate a block of memory large enough to hold the data. 
Close the file by calling CloseHandle. This function accepts the file handle. 
Content:
The program listed below displays an open file dialog box. It lets the user select a text file to open and 
shows the content of that file in an edit control in its client area. The user can modify the text in the 
edit control as he wishes, and can choose to save the content in a file. 
.386 
.model flat,stdcall 
option casemap:none 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\comdlg32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
includelib \Masm32\lib\comdlg32.lib 

.const 
IDM_OPEN equ 1 
IDM_SAVE equ 2 
IDM_EXIT equ 3 
MAXSIZE equ 260 
MEMSIZE equ 65535 

EditID equ 1                            ; ID of the edit control 

.data 
ClassName db "Win32ASMEditClass",0 
AppName  db "Win32 ASM Edit",0 
EditClass db "edit",0 
MenuName db "FirstMenu",0 
ofn   OPENFILENAME <> 
FilterString db "All Files",0,"*.*",0 
             db "Text Files",0,"*.txt",0,0 
buffer db MAXSIZE dup(0) 

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
hwndEdit HWND ?                               ; Handle to the edit control 
hFile HANDLE ?                                   ; File handle 
hMemory HANDLE ?                            ;handle to the allocated memory block 
pMemory DWORD ?                            ;pointer to the allocated memory block 
SizeReadWrite DWORD ?                   ; number of bytes actually read or write 

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine
    mov CommandLine,eax 
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:SDWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_WINDOW+1 
    mov   wc.lpszMenuName,OFFSET MenuName 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\ 
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,300,200,NULL,NULL,\ 
           hInst,NULL 
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,SW_SHOWNORMAL 
    invoke UpdateWindow, hwnd 
    .WHILE TRUE 
        invoke GetMessage, ADDR msg,NULL,0,0 
        .BREAK .IF (!eax) 
        invoke TranslateMessage, ADDR msg 
        invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov     eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc uses ebx hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    .IF uMsg==WM_CREATE 
        invoke CreateWindowEx,NULL,ADDR EditClass,NULL,\ 
                   WS_VISIBLE or WS_CHILD or ES_LEFT or ES_MULTILINE or\ 
                   ES_AUTOHSCROLL or ES_AUTOVSCROLL,0,\ 
                   0,0,0,hWnd,EditID,\ 
                   hInstance,NULL 
        mov hwndEdit,eax 
        invoke SetFocus,hwndEdit 
;============================================== 
;        Initialize the members of OPENFILENAME structure 
;============================================== 
        mov ofn.lStructSize,SIZEOF ofn 
        push hWnd 
        pop  ofn.hWndOwner 
        push hInstance 
        pop  ofn.hInstance 
        mov  ofn.lpstrFilter, OFFSET FilterString 
        mov  ofn.lpstrFile, OFFSET buffer 
        mov  ofn.nMaxFile,MAXSIZE 
    .ELSEIF uMsg==WM_SIZE 
        mov eax,lParam 
        mov edx,eax 
        shr edx,16 
        and eax,0ffffh 
        invoke MoveWindow,hwndEdit,0,0,eax,edx,TRUE 
    .ELSEIF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam 
        .if lParam==0 
            .if ax==IDM_OPEN 
                mov  ofn.Flags, OFN_FILEMUSTEXIST or \ 
                                OFN_PATHMUSTEXIST or OFN_LONGNAMES or\ 
                                OFN_EXPLORER or OFN_HIDEREADONLY 
                invoke GetOpenFileName, ADDR ofn 
                .if eax==TRUE 
                    invoke CreateFile,ADDR buffer,\ 
                                GENERIC_READ or GENERIC_WRITE ,\ 
                                FILE_SHARE_READ or FILE_SHARE_WRITE,\ 
                                NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,\ 
                                NULL 
                    mov hFile,eax 
                    invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,MEMSIZE 
                    mov  hMemory,eax 
                    invoke GlobalLock,hMemory 
                    mov  pMemory,eax 
                    invoke ReadFile,hFile,pMemory,MEMSIZE-1,ADDR SizeReadWrite,NULL 
                    invoke SendMessage,hwndEdit,WM_SETTEXT,NULL,pMemory 
                    invoke CloseHandle,hFile 
                    invoke GlobalUnlock,pMemory 
                    invoke GlobalFree,hMemory 
                .endif 
                invoke SetFocus,hwndEdit 
            .elseif ax==IDM_SAVE 
                mov ofn.Flags,OFN_LONGNAMES or\ 
                                OFN_EXPLORER or OFN_HIDEREADONLY 
                invoke GetSaveFileName, ADDR ofn 
                    .if eax==TRUE 
                        invoke CreateFile,ADDR buffer,\ 
                                                GENERIC_READ or GENERIC_WRITE ,\ 
                                                FILE_SHARE_READ or FILE_SHARE_WRITE,\ 
                                                NULL,CREATE_NEW,FILE_ATTRIBUTE_ARCHIVE,\ 
                                                NULL 
                        mov hFile,eax 
                        invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,MEMSIZE 
                        mov  hMemory,eax 
                        invoke GlobalLock,hMemory 
                        mov  pMemory,eax 
                        invoke SendMessage,hwndEdit,WM_GETTEXT,MEMSIZE-1,pMemory 
                        invoke WriteFile,hFile,pMemory,eax,ADDR SizeReadWrite,NULL 
                        invoke CloseHandle,hFile 
                        invoke GlobalUnlock,pMemory 
                        invoke GlobalFree,hMemory 
                    .endif 
                    invoke SetFocus,hwndEdit 
                .else 
                    invoke DestroyWindow, hWnd 
                .endif 
            .endif 
        .ELSE 
            invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
            ret 
.ENDIF 
xor    eax,eax 
ret 
WndProc endp 
end start 



--------------------------------------------------------------------------------

Analysis:
        invoke CreateWindowEx,NULL,ADDR EditClass,NULL,\ 
                   WS_VISIBLE or WS_CHILD or ES_LEFT or ES_MULTILINE or\ 
                   ES_AUTOHSCROLL or ES_AUTOVSCROLL,0,\ 
                   0,0,0,hWnd,EditID,\ 
                   hInstance,NULL 
        mov hwndEdit,eax 
In WM_CREATE section, we create an edit control. Note that the parameters that specify x, y, width,height of 
the control are all zeroes since we will resize the control later to cover the whole client area of the parent 
window. 
Note that in this case, we don't have to call ShowWindow to make the edit control appear on the screen because 
we include WS_VISIBLE style. You can use this trick in the parent window too. 

;============================================== 
;        Initialize the members of OPENFILENAME structure 
;============================================== 
        mov ofn.lStructSize,SIZEOF ofn 
        push hWnd 
        pop  ofn.hWndOwner 
        push hInstance 
        pop  ofn.hInstance 
        mov  ofn.lpstrFilter, OFFSET FilterString 
        mov  ofn.lpstrFile, OFFSET buffer 
        mov  ofn.nMaxFile,MAXSIZE 

After creating the edit control, we take this time to initialize the members of ofn. Because we want to reuse
 ofn in the save as dialog box too, we fill in only the *common* members that're used by both GetOpenFileName 
 and GetSaveFileName. 
WM_CREATE section is a great place to do once-only initialization. 

    .ELSEIF uMsg==WM_SIZE 
        mov eax,lParam 
        mov edx,eax 
        shr edx,16 
        and eax,0ffffh 
        invoke MoveWindow,hwndEdit,0,0,eax,edx,TRUE 

We receive WM_SIZE messages when the size of the client area of our main window changes. We also receive it 
when the window is first created. In order to be able to receive this message, the window class styles must 
include CS_VREDRAW and CS_HREDRAW styles. We use this opportunity to resize our edit control to the same size 
as the client area of the parent window. First we have to know the current width and height of the client 
area of the parent window. We get this info from lParam. The high word of lParam contains the height and 
the low word of lParam the width of the client area. We then use the information to resize the edit control 
by calling MoveWindow function which, in addition to changing the position of the window, can alter the size
 too. 

            .if ax==IDM_OPEN 
                mov  ofn.Flags, OFN_FILEMUSTEXIST or \ 
                                OFN_PATHMUSTEXIST or OFN_LONGNAMES or\ 
                                OFN_EXPLORER or OFN_HIDEREADONLY 
                invoke GetOpenFileName, ADDR ofn 

When the user selects File/Open menu item, we fill in the Flags member of ofn structure and call 
GetOpenFileName function to display the open file dialog box. 

                .if eax==TRUE 
                    invoke CreateFile,ADDR buffer,\ 
                                GENERIC_READ or GENERIC_WRITE ,\ 
                                FILE_SHARE_READ or FILE_SHARE_WRITE,\ 
                                NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,\ 
                                NULL 
                    mov hFile,eax 

After the user selects a file to open, we call CreateFile to open the file. We specifies that the function 
should try to open the file for read and write. After the file is opened, the function returns the handle to 
the opened file which we store in a global variable for future use. This function has the following syntax: 

CreateFile proto lpFileName:DWORD,\ 
                           dwDesiredAccess:DWORD,\ 
                           dwShareMode:DWORD,\ 
                           lpSecurityAttributes:DWORD,\ 
                           dwCreationDistribution:DWORD\, 
                           dwFlagsAndAttributes:DWORD\, 
                           hTemplateFile:DWORD 

dwDesiredAccess specifies which operation you want to perform on the file. 

0  Open the file to query its attributes. You have to rights to read or write the data. 
GENERIC_READ   Open the file for reading. 
GENERIC_WRITE  Open the file for writing. 
dwShareMode specifies which operation you want to allow other processes to perform on the file that 's being 
opened. 
0  Don't share the file with other processes. 
FILE_SHARE_READ  allow other processes to read the data from the file being opened 
FILE_SHARE_WRITE  allow other processes to write data to the file being opened. 
lpSecurityAttributes has no significance under Windows 95. 
dwCreationDistribution specifies the action CreateFile will perform when the file specified in lpFileName 
exists or when it doesn't exist. 
CREATE_NEW Creates a new file. The function fails if the specified file already exists. 
CREATE_ALWAYS Creates a new file. The function overwrites the file if it exists. 
OPEN_EXISTING Opens the file. The function fails if the file does not exist. 
OPEN_ALWAYS Opens the file, if it exists. If the file does not exist, the function creates the file as if
 dwCreationDistribution were CREATE_NEW. 
TRUNCATE_EXISTING Opens the file. Once opened, the file is truncated so that its size is zero bytes. 
The calling process must open the file with at least GENERIC_WRITE access. The function fails if the file
 does not exist. 
dwFlagsAndAttributes specifies the file attributes 
FILE_ATTRIBUTE_ARCHIVE The file is an archive file. Applications use this attribute to mark files for backup
 or removal. 
FILE_ATTRIBUTE_COMPRESSED The file or directory is compressed. For a file, this means that all of the data 
in the file is compressed. For a directory, this means that compression is the default for newly created files
 and subdirectories. 
FILE_ATTRIBUTE_NORMAL The file has no other attributes set. This attribute is valid only if used alone. 
FILE_ATTRIBUTE_HIDDEN The file is hidden. It is not to be included in an ordinary directory listing. 
FILE_ATTRIBUTE_READONLY The file is read only. Applications can read the file but cannot write to it or 
delete it. 
FILE_ATTRIBUTE_SYSTEM The file is part of or is used exclusively by the operating system. 
                    invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,MEMSIZE 
                    mov  hMemory,eax 
                    invoke GlobalLock,hMemory 
                    mov  pMemory,eax 
When the file is opened, we allocate a block of memory for use by ReadFile and WriteFile functions. 
We specify GMEM_MOVEABLE flag  to let Windows move the memory block around to consolidate memory. 
GMEM_ZEROINIT flag tells GlobalAlloc to fill the newly allocated memory block with zeroes. 
When GlobalAlloc returns successfully, eax contains the handle to the allocated memory block. 
We pass this handle to GlobalLock function which returns a pointer to the memory block. 

                    invoke ReadFile,hFile,pMemory,MEMSIZE-1,ADDR SizeReadWrite,NULL 
                    invoke SendMessage,hwndEdit,WM_SETTEXT,NULL,pMemory 

When the memory block is ready for use, we call ReadFile function to read data from the file. 
When a file is first opened or created, the file pointer is at offset 0. So in this case, 
we start reading from the first byte in the file onwards. The first parameter of ReadFile is the handle of 
the file to read, the second is the pointer to the memory block to hold the data, next is the number of 
bytes to read from the file, the fourth param is the address of the variable of DWORD size that will be 
filled with the number of bytes actually read from the file. 
After we fill the memory block with the data, we put the data into the edit control by sending WM_SETTEXT 
message to the edit control with lParam containing the pointer to the memory block. After this call, 
the edit control shows the data in its client area. 

                    invoke CloseHandle,hFile 
                    invoke GlobalUnlock,pMemory 
                    invoke GlobalFree,hMemory 
                .endif 

At this point, we have no need to keep the file open any longer since our purpose is to write the modified 
data from the edit control to another file, not the original file. So we close the file by calling CloseHandle
 with the file handle as its parameter. Next we unlock the memory block and free it. Actually you don't 
 have to free the memory at this point, you can reuse the memory block during the save operation later. 
 But for demonstration purpose , I choose to free it here. 

                invoke SetFocus,hwndEdit 

When the open file dialog box is displayed on the screen, the input focus shifts to it. So after the open 
file dialog is closed, we must move the input focus back to the edit control. 
This end the read operation on the file. At this point, the user can edit the content of the edit control.
And when he wants to save the data to another file, he must select File/Save as menuitem which displays a 
save as dialog box. The creation of the save as dialog box is not much different from the open file dialog box.
 In fact, they differ in only the name of the functions, GetOpenFileName and GetSaveFileName. You can reuse 
 most members of the ofn structure too except the Flags member. 

                mov ofn.Flags,OFN_LONGNAMES or\ 
                                OFN_EXPLORER or OFN_HIDEREADONLY 

In our case, we want to create a new file, so OFN_FILEMUSTEXIST and OFN_PATHMUSTEXIST must be left out
 else the dialog box will not let us create a file that doesn't already exist. 
The dwCreationDistribution parameter of the CreateFile function must be changed to CREATE_NEW since we 
want to create a new file. 
The remaining code is identical to those in the open file section except the following: 

                        invoke SendMessage,hwndEdit,WM_GETTEXT,MEMSIZE-1,pMemory 
                        invoke WriteFile,hFile,pMemory,eax,ADDR SizeReadWrite,NULL 

We send WM_GETTEXT message to the edit control to copy the data from it to the memory block we provide, 
the return value in eax is the length of the data inside the buffer. After the data is in the memory block,
 we write them to the new file.





Tutorial 13: Memory Mapped Files
  
I'll show you what memory mapped files are and how to use them to your advantages. Using a memory mapped file 
is quite easy as you'll see in this tutorial. 
Theory:
If you examine the example in the previous tutorial closely, you'll find that it has a serious shortcoming: 
what if the file you want to read is larger than the allocated memory block? or what if the string you want 
to search for is cut off in half at the end of the memory block? The traditional answer for the first question 
is that you should repeatedly read in the data from the file until the end of file is encountered. The answer 
to the second question is that you should prepare for the special case at the end of the memory block. 
This is called a boundary value problem. It presents headaches to programmers and causes innumerable bugs. 
It would be nice if we can allocate a very large block of memory, enough to store the whole file but our 
program would be a resource hog. File mapping to the rescue. By using file mapping, you can think of the 
whole file as being already loaded into memory and you can use a memory pointer to read or write data from
 the file. As easy as that. No need to use memory API functions and separate File I/O API functions anymore,
  they are one and the same under file mapping. File mapping is also used as a means to share data between 
  processes. Using file mapping in this way, there's no actual file involved. It's more like a reserved 
  memory block that every process can *see*. But sharing data between processes is a delicate subject, not 
  to be treated lightly. You have to implement process and thread synchronization else your applications will
   crash in very short order. 
We will not touch the subject of file mapping as a means to create a shared memory region in this tutorial. 
We'll concentrate on how to use file mapping as a means to "map" a file into memory. In fact, the PE loader 
uses file mapping to load executable files into memory. It is very convenient since only the necessary 
portions can be selectively read from the file on the disk. Under Win32, you should use file mapping as 
much as possible. 
There are some limitation to file mapping though. Once you create a memory mapped file, its size cannot be
 changed during that session. So file mapping is great for read-only files or file operations that don't 
 affect the file size. That doesn't mean that you cannot use file mapping if you want to increase the file 
 size. You can estimate the new size and create the memory mapped file based on the new size and the file 
 will grow to that size. It's just inconvenient, that's all. 
Enough for the explanation. Let's dive into implementation of file mapping. In order to use file mapping, 
these steps must be performed: 
call CreateFile to open the file you want to map. 
call CreateFileMapping with the file handle returned by CreateFile as one of its parameter. This function 
creates a file mapping object from the file opened by CreateFile. 
call MapViewOfFile to map a selected file region or the whole file to memory. This function returns a pointer
 to the first byte of the mapped file region. 
Use the pointer to read or write the file 
call UnmapViewOfFile to unmap the file. 
call CloseHandle with the handle to the mapped file as the parameter to close the mapped file. 
call CloseHandle again this time with the file handle returned by CreateFile to close the actual file. 
Example:
The program listed below lets you open a file via an open file dialog box. It opens the file using file 
mapping, if it's successful, the window caption is changed to the name of the opened file. You can save the 
file in another name by select File/Save as menuitem. The program will copy the whole content of the opened
 file to the new file. Note that you don't have to call GlobalAlloc to allocate a memory block in this program.
  
.386 
.model flat,stdcall 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\comdlg32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
includelib \Masm32\lib\comdlg32.lib 

.const 
IDM_OPEN equ 1 
IDM_SAVE equ 2 
IDM_EXIT equ 3 
MAXSIZE equ 260 

.data 
ClassName db "Win32ASMFileMappingClass",0 
AppName  db "Win32 ASM File Mapping Example",0 
MenuName db "FirstMenu",0 
ofn   OPENFILENAME <> 
FilterString db "All Files",0,"*.*",0 
             db "Text Files",0,"*.txt",0,0 
buffer db MAXSIZE dup(0) 
hMapFile HANDLE 0                            ; Handle to the memory mapped file, must be 
                                                                    ;initialized with 0 because we also use it as 
                                                                    ;a flag in WM_DESTROY section too 

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
hFileRead HANDLE ?                               ; Handle to the source file 
hFileWrite HANDLE ?                                ; Handle to the output file 
hMenu HANDLE ? 
pMemory DWORD ?                                 ; pointer to the data in the source file 
SizeWritten DWORD ?                               ; number of bytes actually written by WriteFile 

.code 
start: 
        invoke GetModuleHandle, NULL 
        mov    hInstance,eax 
        invoke GetCommandLine 
        mov CommandLine,eax 
        invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
        invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_WINDOW+1 
    mov   wc.lpszMenuName,OFFSET MenuName 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,\ 
                ADDR AppName, WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ 
               CW_USEDEFAULT,300,200,NULL,NULL,\ 
    hInst,NULL 
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,SW_SHOWNORMAL 
    invoke UpdateWindow, hwnd 
    .WHILE TRUE 
        invoke GetMessage, ADDR msg,NULL,0,0 
        .BREAK .IF (!eax) 
        invoke TranslateMessage, ADDR msg 
        invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov     eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    .IF uMsg==WM_CREATE 
        invoke GetMenu,hWnd                       ;Obtain the menu handle 
        mov  hMenu,eax 
        mov ofn.lStructSize,SIZEOF ofn 
        push hWnd 
        pop  ofn.hWndOwner 
        push hInstance 
        pop  ofn.hInstance 
        mov  ofn.lpstrFilter, OFFSET FilterString 
        mov  ofn.lpstrFile, OFFSET buffer 
        mov  ofn.nMaxFile,MAXSIZE 
    .ELSEIF uMsg==WM_DESTROY 
        .if hMapFile!=0 
            call CloseMapFile 
        .endif 
        invoke PostQuitMessage,NULL 
    .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam 
        .if lParam==0 
            .if ax==IDM_OPEN 
                mov  ofn.Flags, OFN_FILEMUSTEXIST or \ 
                                OFN_PATHMUSTEXIST or OFN_LONGNAMES or\ 
                                OFN_EXPLORER or OFN_HIDEREADONLY 
                                invoke GetOpenFileName, ADDR ofn 
                .if eax==TRUE 
                    invoke CreateFile,ADDR buffer,\ 
                                                GENERIC_READ ,\ 
                                                0,\ 
                                                NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,\ 
                                                NULL 
                    mov hFileRead,eax 
                    invoke CreateFileMapping,hFileRead,NULL,PAGE_READONLY,0,0,NULL 
                    mov     hMapFile,eax 
                    mov     eax,OFFSET buffer 
                    movzx  edx,ofn.nFileOffset 
                    add      eax,edx 
                    invoke SetWindowText,hWnd,eax 
                    invoke EnableMenuItem,hMenu,IDM_OPEN,MF_GRAYED 
                    invoke EnableMenuItem,hMenu,IDM_SAVE,MF_ENABLED 
                .endif 
            .elseif ax==IDM_SAVE 
                mov ofn.Flags,OFN_LONGNAMES or\ 
                                OFN_EXPLORER or OFN_HIDEREADONLY 
                invoke GetSaveFileName, ADDR ofn 
                .if eax==TRUE 
                    invoke CreateFile,ADDR buffer,\ 
                                                GENERIC_READ or GENERIC_WRITE ,\ 
                                                FILE_SHARE_READ or FILE_SHARE_WRITE,\ 
                                                NULL,CREATE_NEW,FILE_ATTRIBUTE_ARCHIVE,\ 
                                                NULL 
                    mov hFileWrite,eax 
                    invoke MapViewOfFile,hMapFile,FILE_MAP_READ,0,0,0 
                    mov pMemory,eax 
                    invoke GetFileSize,hFileRead,NULL 
                    invoke WriteFile,hFileWrite,pMemory,eax,ADDR SizeWritten,NULL 
                    invoke UnmapViewOfFile,pMemory 
                    call   CloseMapFile 
                    invoke CloseHandle,hFileWrite 
                    invoke SetWindowText,hWnd,ADDR AppName 
                    invoke EnableMenuItem,hMenu,IDM_OPEN,MF_ENABLED 
                    invoke EnableMenuItem,hMenu,IDM_SAVE,MF_GRAYED 
                .endif 
            .else 
                invoke DestroyWindow, hWnd 
            .endif 
        .endif 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor    eax,eax 
    ret 
WndProc endp 

CloseMapFile PROC 
        invoke CloseHandle,hMapFile 
        mov    hMapFile,0 
        invoke CloseHandle,hFileRead 
        ret 
CloseMapFile endp 

end start 
  

Analysis:
                    invoke CreateFile,ADDR buffer,\ 
                                                GENERIC_READ ,\ 
                                                0,\ 
                                                NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,\ 
                                                NULL 
When the user selects a file in the open file dialog, we call CreateFile to open it. Note that we specify 
GENERIC_READ to open this file for read-only access and dwShareMode is zero because we don't want some other
 process to modify the file during our operation. 

                    invoke CreateFileMapping,hFileRead,NULL,PAGE_READONLY,0,0,NULL 

Then we call CreateFileMapping to create a memory mapped file from the opened file. CreateFileMapping has 
the following syntax: 

CreateFileMapping proto hFile:DWORD,\ 
                                         lpFileMappingAttributes:DWORD,\ 
                                         flProtect:DWORD,\ 
                                         dwMaximumSizeHigh:DWORD,\ 
                                         dwMaximumSizeLow:DWORD,\ 
                                         lpName:DWORD 

You should know first that CreateFileMapping doesn't have to map the whole file to memory. You can use this 
function to map only a part of the actual file to memory. You specify the size of the memory mapped file in
 dwMaximumSizeHigh and dwMaximumSizeLow params. If you specify the size that 's larger than the actual file, 
 the actual file will be expanded to the new size. If you want the memory mapped file to be the same size as 
 the actual file, put zeroes in both params. 
You can use NULL in lpFileMappingAttributes parameter to have Windows creates a memory mapped file with 
default
 security attributes. 
flProtect defines the protection desired for the memory mapped file. In our example, we use PAGE_READONLY to 
allow only read operation on the memory mapped file. Note that this attribute must not contradict the 
attribute used in CreateFile else CreateFileMapping will fail. 
lpName points to the name of the memory mapped file. If you want to share this file with other process, 
you must provide it a name. But in our example, our process is the only one that uses this file so we ignore 
this parameter. 

                    mov     eax,OFFSET buffer 
                    movzx  edx,ofn.nFileOffset 
                    add      eax,edx 
                    invoke SetWindowText,hWnd,eax 

If CreateFileMapping is successful, we change the window caption to the name of the opened file. The filename 
with full path is stored in buffer, we want to display only the filename in the caption so we must add the 
value of nFileOffset member of the OPENFILENAME structure to the address of buffer. 

                    invoke EnableMenuItem,hMenu,IDM_OPEN,MF_GRAYED 
                    invoke EnableMenuItem,hMenu,IDM_SAVE,MF_ENABLED 

As a precaution, we don't want the user to open multiple files at once, so we gray out the Open menu item 
and enable the Save menu item. EnableMenuItem is used to change the attribute of menu item. 
After this, we wait for the user to select File/Save as menu item or close our program. If the user chooses 
to close our program, we must close the memory mapped file and the actual file like the code below: 

    .ELSEIF uMsg==WM_DESTROY 
        .if hMapFile!=0 
            call CloseMapFile 
        .endif 
        invoke PostQuitMessage,NULL 

In the above code snippet, when the window procedure receives the WM_DESTROY message, it checks the value of
 hMapFile first whether it is zero or not. If it's not zero, it calls CloseMapFile function which contains 
 the following code: 

CloseMapFile PROC 
        invoke CloseHandle,hMapFile 
        mov    hMapFile,0 
        invoke CloseHandle,hFileRead 
        ret 
CloseMapFile endp 

CloseMapFile closes the memory mapped file and the actual file so that there 'll be no resource leakage 
when our program exits to Windows. 
If the user chooses to save that data to another file, the program presents him with a save as dialog box. 
After he types in the name of the new file, the file is created by CreateFile function. 

                    invoke MapViewOfFile,hMapFile,FILE_MAP_READ,0,0,0 
                    mov pMemory,eax 

Immediately after the output file is created, we call MapViewOfFile to map the desired portion of the 
memory mapped file into memory. This function has the following syntax: 

MapViewOfFile proto hFileMappingObject:DWORD,\ 
                                   dwDesiredAccess:DWORD,\ 
                                   dwFileOffsetHigh:DWORD,\ 
                                   dwFileOffsetLow:DWORD,\ 
                                   dwNumberOfBytesToMap:DWORD 

dwDesiredAccess specifies what operation we want to do to the file. In our example, we want to read the data 
only so we use FILE_MAP_READ. 
dwFileOffsetHigh and dwFileOffsetLowspecify the starting file offset of the file portion that you want to 
map into memory. In our case, we want to read in the whole file so we start mapping from offset 0 onwards. 
dwNumberOfBytesToMap specifies the number of bytes to map into memory. If you want to map the whole file 
(specified by CreateFileMapping), pass 0 to MapViewOfFile. 
After calling MapViewOfFile, the desired portion is loaded into memory. You'll be given the pointer to the 
memory block that contains the data from the file. 

                    invoke GetFileSize,hFileRead,NULL 

Find out how large the file is. The file size is returned in eax. If the file is larger than 4 GB,  
the high DWORD of the file size is stored in FileSizeHighWord. Since we don't expect to handle such large file,
 we can ignore it. 

                    invoke WriteFile,hFileWrite,pMemory,eax,ADDR SizeWritten,NULL 

Write the data that is mapped into memory into the output file. 

                    invoke UnmapViewOfFile,pMemory 

When we're through with the input file, unmap it from memory. 

                    call   CloseMapFile 
                    invoke CloseHandle,hFileWrite 

And close all the files. 

                    invoke SetWindowText,hWnd,ADDR AppName 

Restore the original caption text. 

                    invoke EnableMenuItem,hMenu,IDM_OPEN,MF_ENABLED 
                    invoke EnableMenuItem,hMenu,IDM_SAVE,MF_GRAYED 

Enable the Open menu item and gray out the Save As menu item.



Unfortunately you can't run Java applets  


Tutorial 14: Process
  
We will learn what a process is and how to create and terminate it. 
Preliminary:
What is a process? I quote this definition from Win32 API reference: 
"A process is an executing application that consists of a private virtual address space, code, data, 
and other operating system resources, such as files, pipes, and synchronization objects that are visible 
to the process."
As you can see from the definition above, a process "owns" several objects: the address space, 
the executing module(s), and anything that the executing modules create or open. At the minimum, 
a process must consist of an executing module, a private address space and a thread. Every process 
must have at least one thread. What's a thread? A thread is actually an execution queue. When Windows
 first creates a process, it creates only one thread per process. This thread usually starts execution 
 from the first instruction in the module. If the process later needs more threads, it can explicitly 
 create them. 
When Windows receives a command to create a process, it creates the private memory address space for 
the process and then it maps the executable file into the space. After that it creates the primary 
thread for the process. 
Under Win32, you can also create processes from your own programs by calling CreateProcess function. 
CreateProcess has the following syntax: 
CreateProcess proto lpApplicationName:DWORD,\ 
                                 lpCommandLine:DWORD,\
                                 lpProcessAttributes:DWORD,\ 
                                 lpThreadAttributes:DWORD,\ 
                                 bInheritHandles:DWORD,\ 
                                 dwCreationFlags:DWORD,\ 
                                 lpEnvironment:DWORD,\ 
                                 lpCurrentDirectory:DWORD,\ 
                                 lpStartupInfo:DWORD,\ 
                                 lpProcessInformation:DWORD 

Don't be alarmed by the number of parameters. We can ignore most of them. 

lpApplicationName --> The name of the executable file with or without pathname that you want to execute. 
If this parameter is null, you must provide the name of the executable file in the lpCommandLine parameter. 
lpCommandLine   --> The command line arguments to the program you want to execute. Note that if the 
lpApplicationName is NULL, this parameter must contain the name of the executable file too. Like this: 
"notepad.exe readme.txt" 
lpProcessAttributes and lpthreadAttributes --> Specify the security attributes for the process and the 
primary thread. If they're NULLs, the default security attributes are used. 
bInheritHandles --> A flag that specify if you want the new process to inherit all opened handles from 
your process. 
dwCreationFlags --> Several flags that determine the behavior of the process you want to created, such as, 
do you want to process to be created but immediately suspended so that you can examine or modify it before 
it runs? You can also specify the priority class of the thread(s) in the new process. This priority class 
is used to determine the scheduling priority of the threads within the process. Normally we use 
NORMAL_PRIORITY_CLASS flag. 
lpEnvironment --> A pointer to the environment block that contains several environment strings for the 
new process. If this parameter is NULL, the new process inherits the environment block from the parent process.
 
lpCurrentDirectory --> A pointer to the string that specifies the current drive and directory for the 
child process. NULL if  you want the child process to inherit from the parent process. 
lpStartupInfo --> Points to a STARTUPINFO structure that specifies how the main window for the new process 
should appear. The STARTUPINFO structure contains many members that specifies the appearance of the main
 window of the child process. If you don't want anything special, you can fill the STARTUPINFO structure
  with the values from the parent process by calling GetStartupInfo function. 
lpProcessInformation --> Points to a PROCESS_INFORMATION structure that receives identification information
 about the new process.  The PROCESS_INFORMATION structure has the following members: 

PROCESS_INFORMATION STRUCT 
    hProcess          HANDLE ?             ; handle to the child process 
    hThread            HANDLE ?             ; handle to the primary thread of the child process 
    dwProcessId     DWORD ?             ; ID of the child process 
    dwThreadId      DWORD ?            ; ID of the primary thread of the child process 
PROCESS_INFORMATION ENDS
Process handle and process ID are two different things. A process ID is a unique identifier for the process 
in the system. A process handle is a value returned by Windows for use with other process-related API functions.
 A process handle cannot be used to identify a process since it's not unique. 
After the CreateProcess call, a new process is created and the CreateProcess call return immediately. 
You can check if the new process is still active by calling GetExitCodeProcess function which has the 
following syntax: 

GetExitCodeProcess proto hProcess:DWORD, lpExitCode:DWORD 

If this call is successful, lpExitCode contains the termination status of the process in question.
 If the value in lpExitCode is equal to STILL_ACTIVE, then that process is still running. 

You can forcibly terminate a process by calling TerminateProcess function. It has the following syntax: 

TerminateProcess proto hProcess:DWORD, uExitCode:DWORD 

You can specify the desired exit code for the process, any value you like. TerminateProcess is not a 
clean way to terminate a process since any dll attached to the process will not be notified that the 
process was terminated. 
  

Example:
The following example will create a new process when the user selects the "create process" menu item.
 It will attempt to execute "msgbox.exe". If the user wants to terminate the new process, he can select 
 the "terminate process" menu item. The program will check first if the new process is already destroyed, 
 if it is not, the program  will call TerminateProcess function to destroy the new process. 
.386 
.model flat,stdcall 
option casemap:none 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 

.const 
IDM_CREATE_PROCESS equ 1 
IDM_TERMINATE equ 2 
IDM_EXIT equ 3 

.data 
ClassName db "Win32ASMProcessClass",0 
AppName  db "Win32 ASM Process Example",0 
MenuName db "FirstMenu",0 
processInfo PROCESS_INFORMATION <> 
programname db "msgbox.exe",0 

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
hMenu HANDLE ? 
ExitCode DWORD ?                    ; contains the process exitcode status from GetExitCodeProcess call. 

.code 
start: 
        invoke GetModuleHandle, NULL 
        mov    hInstance,eax 
        invoke GetCommandLine 
        mov CommandLine,eax 
        invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
        invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_WINDOW+1 
    mov   wc.lpszMenuName,OFFSET MenuName 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\ 
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,300,200,NULL,NULL,\ 
           hInst,NULL 
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,SW_SHOWNORMAL 
    invoke UpdateWindow, hwnd 
    invoke GetMenu,hwnd 
    mov  hMenu,eax 
    .WHILE TRUE 
                invoke GetMessage, ADDR msg,NULL,0,0 
                .BREAK .IF (!eax) 
                invoke TranslateMessage, ADDR msg 
                invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov     eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    LOCAL startInfo:STARTUPINFO 
    .IF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSEIF uMsg==WM_INITMENUPOPUP 
        invoke GetExitCodeProcess,processInfo.hProcess,ADDR ExitCode 
        .if eax==TRUE 
            .if ExitCode==STILL_ACTIVE 
                invoke EnableMenuItem,hMenu,IDM_CREATE_PROCESS,MF_GRAYED 
                invoke EnableMenuItem,hMenu,IDM_TERMINATE,MF_ENABLED 
            .else 
                invoke EnableMenuItem,hMenu,IDM_CREATE_PROCESS,MF_ENABLED 
                invoke EnableMenuItem,hMenu,IDM_TERMINATE,MF_GRAYED 
            .endif 
        .else 
            invoke EnableMenuItem,hMenu,IDM_CREATE_PROCESS,MF_ENABLED 
            invoke EnableMenuItem,hMenu,IDM_TERMINATE,MF_GRAYED 
        .endif 
    .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam 
        .if lParam==0 
            .if ax==IDM_CREATE_PROCESS 
                .if processInfo.hProcess!=0 
                    invoke CloseHandle,processInfo.hProcess 
                    mov processInfo.hProcess,0 
                .endif 
                invoke GetStartupInfo,ADDR startInfo 
                invoke CreateProcess,ADDR programname,NULL,NULL,NULL,FALSE,\ 
                                        NORMAL_PRIORITY_CLASS,\ 
                                        NULL,NULL,ADDR startInfo,ADDR processInfo 
                invoke CloseHandle,processInfo.hThread 
            .elseif ax==IDM_TERMINATE 
                invoke GetExitCodeProcess,processInfo.hProcess,ADDR ExitCode 
                .if ExitCode==STILL_ACTIVE 
                    invoke TerminateProcess,processInfo.hProcess,0 
                .endif 
                invoke CloseHandle,processInfo.hProcess 
                mov processInfo.hProcess,0 
            .else 
                invoke DestroyWindow,hWnd 
            .endif 
        .endif 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor    eax,eax 
    ret 
WndProc endp 
end start 

Analysis:
The program creates the main window and retrieves the menu handle for future use. It then waits for the user to select a command from the menu. When the user selects "Process" menu item in the main menu, we process WM_INITMENUPOPUP message to modify the menu items inside the popup menu before it's displayed. 
    .ELSEIF uMsg==WM_INITMENUPOPUP 
        invoke GetExitCodeProcess,processInfo.hProcess,ADDR ExitCode 
        .if eax==TRUE 
            .if ExitCode==STILL_ACTIVE 
                invoke EnableMenuItem,hMenu,IDM_CREATE_PROCESS,MF_GRAYED 
                invoke EnableMenuItem,hMenu,IDM_TERMINATE,MF_ENABLED 
            .else 
                invoke EnableMenuItem,hMenu,IDM_CREATE_PROCESS,MF_ENABLED 
                invoke EnableMenuItem,hMenu,IDM_TERMINATE,MF_GRAYED 
            .endif 
        .else 
            invoke EnableMenuItem,hMenu,IDM_CREATE_PROCESS,MF_ENABLED 
            invoke EnableMenuItem,hMenu,IDM_TERMINATE,MF_GRAYED 
        .endif 

Why do we want to process this message? Because we want to prepare the menu items in the popup menu before the user can see them. In our example, if the new process is not started yet, we want to enable the "start process" and gray out the "terminate process" menu items. We do the reverse if the new process is already active. 
We first check if the new process is still running by calling GetExitCodeProcess function with the process handle that was filled in by CreateProcess function. If GetExitCodeProcess returns FALSE, it means the process is not started yet so we gray out the "terminate process" menu item. If GetExitCodeProcess returns TRUE, we know that a new process has been started, but we have to check further if it is still running. So we compare the value in ExitCode to the value STILL_ACTIVE, if they're equal, the process is still running: we must gray out the "start process" menu item since we don't want to start several concurrent processes. 

            .if ax==IDM_CREATE_PROCESS 
                .if processInfo.hProcess!=0 
                    invoke CloseHandle,processInfo.hProcess 
                    mov processInfo.hProcess,0 
                .endif 
                invoke GetStartupInfo,ADDR startInfo 
                invoke CreateProcess,ADDR programname,NULL,NULL,NULL,FALSE,\ 
                                        NORMAL_PRIORITY_CLASS,\ 
                                        NULL,NULL,ADDR startInfo,ADDR processInfo 
                invoke CloseHandle,processInfo.hThread 
  
When the user selects "start process" menu item, we first check if hProcess member of PROCESS_INFORMATION 
structure is already closed. If this is the first time, the value of hProcess will always be zero since 
we define PROCESS_INFORMATION structure in .data section. If the value of hProcess member is not 0, 
it means the child process has exited but we haven't closed its process handle yet. So this is the time 
to do it. 
We call GetStartupInfo function to fill in the startupinfo structure that we will pass to CreateProcess 
function. After that we call CreateProcess function to start the new process. Note that I haven't checked
 the return value of CreateProcess because it will make the example more complex. In real life, you should 
 check the return value of CreateProcess. Immediately after CreateProcess, we close the primary thread handle 
 returned in processInfo structure. Closing the handle doesn't mean we terminate the thread, only that we
  don't want to use the handle to refer to the thread from our program. If we don't close it, it will cause 
  a resource leak. 

            .elseif ax==IDM_TERMINATE 
                invoke GetExitCodeProcess,processInfo.hProcess,ADDR ExitCode 
                .if ExitCode==STILL_ACTIVE 
                    invoke TerminateProcess,processInfo.hProcess,0 
                .endif 
                invoke CloseHandle,processInfo.hProcess 
                mov processInfo.hProcess,0 

When the user selects "terminate process" menu item, we check if the new process is still active by calling 
GetExitCodeProcess function. If it's still active, we call TerminateProcess function to kill the process. 
Also we close the child process handle since we have no need for it anymore.



Unfortunately you can't run Java applets  


Tutorial 15: Multithreading Programming
  
We will learn how to create a multithreading program in this tutorial. We also study the communication 
methods between the threads. 
Theory:
In previous tutorial, you learn the a process consists of at least one thread: the primary thread. 
A thread is a chain of execution. You can also create additional threads in your program. 
You can view multithreading as multitasking within one program. In term of implementation, a thread is a 
function that runs concurrently with the main program. You can run several instances of the same function 
or you can run several functions simultaneously depending on your requirement. Multithreading is specific 
to Win32, no Win16 counterpart exists. 
Threads run in the same process so they can access any resources in the process such as global variables,
 handles etc. However, each thread has its own stack so local variables in each thread are private.
  Each thread also owns its private register set so when Windows switches to other threads, the thread 
  can "remember" its last status and can "resume" the task when it gains control again. This is handled 
  internally by Windows. 
We can divide threads into two caterories: 
User interface thread: This type of thread creates its own window so it receives windows messages. 
It can respond to the user via its own window hence the name. This type of thread is subject to Win16 Mutex 
rule which allows only one user interface thread in 16-bit user and gdi kernel. While a user interface 
thread is executing code in 16-bit user and gdi kernel, other UI threads cannot use the service of the 
16-bit user and gdi kernel. Note that this Win16 Mutex is specific to Windows 95 since underneath, 
Windows 95 API functions thunk down to 16-bit code. Windows NT has no Win16 Mutex so the user interface
 threads under NT work more smoothly than under Windows 95. 
Worker thread: This type of thread does not create a window so it cannot receive any windows message. 
It exists primarily to do the assigned job in the background hence the name worker thread. 
I advise the following strategy when using multithreading capability of Win32: Let the primary thread do
 user interface stuff and the other threads do the hard work in the background. In this way, 
 the primary thread is like a Governor, other threads are like the Governor's staff. The Governor delegates 
 jobs to his staff while he maintains contact with the public. The Governor staff obediently performs 
 the work and reports back to the Governor. If the Governor were to perform every task himself, 
 he would not be able to give much attention to the public or the press. That's akin to a window which is 
 busy doing a lengthy job in its primary thread: it doesn't respond to the user until the job is completed.
 Such a program can benefit from creating an additonal thread which is responsible for the lengthy job, 
 allowing the primary thread to respond to the user's commands. 
We can create a thread by calling CreateThread function which has the following syntax: 
CreateThread proto lpThreadAttributes:DWORD,\ 
                                dwStackSize:DWORD,\ 
                                lpStartAddress:DWORD,\ 
                                lpParameter:DWORD,\ 
                                dwCreationFlags:DWORD,\ 
                                lpThreadId:DWORD 

CreateThread function looks a lot like CreateProcess. 
lpThreadAttributes  --> You can use NULL if you want the thread to have default security descriptor. 
dwStackSize --> specify the stack size of the thread. If you want the thread to have the same stack size as 
the primary thread, use NULL as this parameter. 
lpStartAddress--> Address of the thread function.It's the function that will perform the work of the thread.
 This function MUST receive one and only one 32-bit parameter and return a 32-bit value. 
lpParameter  --> The parameter you want to pass to the thread function. 
dwCreationFlags --> 0 means the thread runs immediately after it's created. The opposite is CREATE_SUSPENDED 
flag. 
lpThreadId --> CreateThread function will fill the thread ID of the newly created thread at this address. 

If CreateThread call is sucessful, it returns the handle of the newly created thread. Otherwise, it returns
 NULL. 
The thread function runs as soon as CreateThread call is success ful unless you specify CREATE_SUSPENDED 
flag in dwCreationFlags. In that case, the thread is suspended until ResumeThread function is called. 
When the thread function returns with ret instruction, Windows calls ExitThread function for the thread 
function implicitly. You can call ExitThread function with in your thread function yourself but there' s 
little point in doing so. 
You can retrieve the exit code of a thread by calling GetExitCodeThread function. 
If you want to terminate a thread from other thread, you can call TerminateThread function. But you should 
use this function under extreme circumstance since this function terminates the thread immediately without 
giving the thread any chance to clean up after itself. 

Now let's move to the communication methods between threads. 
There are three of them: 

Using global variables 
Windows messages 
Event 
Threads share the process's resources including global variables so the threads can use global varibles to
 communicate with each other. However this method must be used with care. Thread synchronization must enter
  into consideration. For example, if two threads use the same structure of 10 members , what happens when 
  Windows suddenly yanks the control from one of the thread when it was in the middle of updating the 
  structure? The other thread will be left with an inconsistent data in the structure! Don't make any mistake,
   multithreading programs are harder to debug and maintain. This sort of bug seems to happen at random which 
   is very hard to track down. 
You can also use Windows messages to communicate between threads. If the threads are all user interface ones, 
there's no problem: this method can be used as a two-way communication. All you have to do is defining one or
 more custom windows messages that are meaningful to the threads. You define a custom message by using WM_USER
  message as the base value say , you can define it like this: 
        WM_MYCUSTOMMSG equ WM_USER+100h 

Windows will not use any value from WM_USER upward for its own messages so you can use the value WM_USER and 
above as your own custom message value. 
If one of the thread is a user interface thread and the other is a worker one, you cannot use this method as
 two-way communication since a worker thread doesn't have its own window so it doesn't have a message queue. 
 You can use the following scheme: 

                            User interface Thread ------> global variable(s)----> Worker thread 
                            Worker Thread  ------> custom window message(s) ----> User interface Thread 

In fact, we will use this method in our example. 
The last communication method is an event object. You can view an event object as a kind of flag. 
If the event object is in "unsignalled" state, the thread is dormant or sleeping, in this state,
 the thread doesn't receive CPU time slice. When the event object is in "signalled" state,Windows 
 "wakes up" the thread and it starts performing the assigned task. 

Example:
You should run thread1.exe. Click the "Savage Calculation" menu item. This will instruct the program to
 perform "add eax,eax " for 600,000,000 times. Note that during that time, you cannot do anything with 
 the main window: you cannot move it, you cannot activate its menu, etc. When the calculation is completed, 
 a message box appears. After that the window accepts your command normally. 
To avoid this type of inconveniece to the user, we can move the "calculation" routine into a separate worker
 thread and let the primary thread continue with its user interface task. You can see that even though the 
 main window responds more slowly than usual,  it still responds 
.386 
.model flat,stdcall 
option casemap:none 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 

.const 
IDM_CREATE_THREAD equ 1 
IDM_EXIT equ 2 
WM_FINISH equ WM_USER+100h 

.data 
ClassName db "Win32ASMThreadClass",0 
AppName  db "Win32 ASM MultiThreading Example",0 
MenuName db "FirstMenu",0 
SuccessString db "The calculation is completed!",0 

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
hwnd HANDLE ? 
ThreadID DWORD ? 

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke GetCommandLine 
    mov CommandLine,eax 
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_WINDOW+1 
    mov   wc.lpszMenuName,OFFSET MenuName 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\ 
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,300,200,NULL,NULL,\ 
           hInst,NULL 
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,SW_SHOWNORMAL 
    invoke UpdateWindow, hwnd 
    .WHILE TRUE 
            invoke GetMessage, ADDR msg,NULL,0,0 
            .BREAK .IF (!eax) 
            invoke TranslateMessage, ADDR msg 
            invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov     eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    .IF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam 
        .if lParam==0 
            .if ax==IDM_CREATE_THREAD 
                mov  eax,OFFSET ThreadProc 
                invoke CreateThread,NULL,NULL,eax,\ 
                                        0,\ 
                                        ADDR ThreadID 
                invoke CloseHandle,eax 
            .else 
                invoke DestroyWindow,hWnd 
            .endif 
        .endif 
    .ELSEIF uMsg==WM_FINISH 
        invoke MessageBox,NULL,ADDR SuccessString,ADDR AppName,MB_OK 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .ENDIF 
    xor    eax,eax 
    ret 
WndProc endp 

ThreadProc PROC USES ecx Param:DWORD 
        mov  ecx,600000000 
Loop1: 
        add  eax,eax 
        dec  ecx 
        jz   Get_out 
        jmp  Loop1 
Get_out: 
        invoke PostMessage,hwnd,WM_FINISH,NULL,NULL 
        ret 
ThreadProc ENDP 

end start 
  

Analysis:
The main program presents the user with a normal window with a menu. If the user selects "Create Thread" menu 
item, the program creates a thread as below: 
            .if ax==IDM_CREATE_THREAD 
                mov  eax,OFFSET ThreadProc 
                invoke CreateThread,NULL,NULL,eax,\ 
                                        NULL,0,\ 
                                        ADDR ThreadID 
                invoke CloseHandle,eax 
  
The above function creates a thread that will run a procedure named ThreadProc concurrently with the primary 
thread. After the successful call, CreateThread returns immediately and ThreadProc begins to run. Since we do 
not use thread handle, we should close it else there'll be some leakage of memory. Note that closing the 
thread handle doesn't terminate the thread. Its only effect is that we cannot use the thread handle anymore. 

ThreadProc PROC USES ecx Param:DWORD 
        mov  ecx,600000000 
Loop1: 
        add  eax,eax 
        dec  ecx 
        jz   Get_out 
        jmp  Loop1 
Get_out: 
        invoke PostMessage,hwnd,WM_FINISH,NULL,NULL 
        ret 
ThreadProc ENDP 

As you can see, ThreadProc performs a savage calculation which takes quite a while to finish and when 
it finishs it posts a WM_FINISH message to the main window. WM_FINISH is our custom message defined like 
this: 

WM_FINISH equ WM_USER+100h
You don't have to add WM_USER with 100h but it's safer to do so. 
The WM_FINISH message is meaningful only within our program. When the main window receives the WM_FINISH 
message, it respons by displaying a message box saying that the calculation is completed. 
You can create several threads in succession by selecting "Create Thread" several times. 
In this example, the communication is one-way in that only the thread can notify the main window. 
If you want the main thread to send commands to the worker thread, you can so as follows: 
add a menu item saying something like "Kill Thread" in the menu 
a global variable which is used as a command flag. TRUE=Stop the thread, FALSE=continue the thread 
Modify ThreadProc to check the value of the command flag in the loop. 
When the user selects "Kill Thread" menu item, the main program will set the value TRUE in the command flag.
 When ThreadProc sees that the value of the command flag is TRUE, it exits the loop and returns thus ends 
 the thread.


Unfortunately you can't run Java applets  


Tutorial 16: Event Object
  
We will learn what an event object is and how to use it in a multithreaded program. 
Theory:
From the previous tutorial, I demonstrated how threads communicate with a custom window message. 
I left out two other methods: global variable and event object. We will use both of them in this tutorial. 
An event object is like a switch: it has only two states: on or off. When an event object is turned on, 
it's in the "signalled" state. When it is turned off, it's in the "nonsignalled" state. 
You create an event object and put in a code snippet in the relevant threads to watch for the state of the
 event object. If the event object is in the nonsignalled state, the threads that wait for it will be asleep.
 When the threads are in wait state, they consume little CPU time. 
You create an event object by calling CreateEvent function which has the following syntax: 
CreateEvent proto lpEventAttributes:DWORD,\ 
                              bManualReset:DWORD,\ 
                              bInitialState:DWORD,\ 
                              lpName:DWORD 

lpEventAttribute--> If you specify NULL value, the event object is created with default security descriptor. 
bManualReset--> If you want Windows to automatically reset the event object to nonsignalled state after
 WaitForSingleObject call, you must specify FALSE as this parameter. Else you must manually reset the event 
 object with the call to ResetEvent. 
bInitialState--> If you want the event object to be created in the signalled state, specify TRUE as this 
parameter else the event object will be created in the nonsignalled state. 
lpName --> Pointer to an ASCIIZ string that is the name of the event object. This name is used when you 
want to call OpenEvent. 

If the call is successful, it returns the handle to the newly created event object else it returns NULL. 
You can modify the state of an event object with two API calls: SetEvent and ResetEvent. SetEvent function 
sets the event object into signalled state. ResetEvent does the reverse. 
When the event object is created, you must put the call to WaitForSingleObject in the thread that wants 
to watch for the state of the event object. WaitForSingleObject has the following syntax: 

WaitForSingleObject proto hObject:DWORD, dwTimeout:DWORD 

hObject --> A handle to one of the synchronization object. Event object is a type of synchronization object. 
dwTimeout --> specify the time in milliseconds that this function will wait for the object to be in signalled 
state. If the specified time has passed and the event object is still in nonsignalled state, 
WaitForSingleObject returns the the caller. If you want to wait for the object indefinitely, you must specify 
the value INFINITE as this parameter. 

Example:
The example below displays a window waiting for the user to select a command from the menu. If the user 
selects "run thread", the thread starts the savage calculation. When it's finished, a message box appears 
informing the user that the job is done. During the time that the thread is running, the user can select 
"stop thread" to stop the thread. 
.386 
.model flat,stdcall 
option casemap:none 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 

.const 
IDM_START_THREAD equ 1 
IDM_STOP_THREAD equ 2 
IDM_EXIT equ 3 
WM_FINISH equ WM_USER+100h 

.data 
ClassName db "Win32ASMEventClass",0 
AppName  db "Win32 ASM Event Example",0 
MenuName db "FirstMenu",0 
SuccessString db "The calculation is completed!",0 
StopString db "The thread is stopped",0 
EventStop BOOL FALSE 

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
hwnd HANDLE ? 
hMenu HANDLE ? 
ThreadID DWORD ? 
ExitCode DWORD ? 
hEventStart HANDLE ? 

.code 
start: 
    invoke GetModuleHandle, NULL 


    mov    hInstance,eax 
    invoke GetCommandLine 
    mov CommandLine,eax 
    invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_WINDOW+1 
    mov   wc.lpszMenuName,OFFSET MenuName 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,\ 
            ADDR  AppName,\ 
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,300,200,NULL,NULL,\ 
           hInst,NULL 
    mov   hwnd,eax 
    invoke ShowWindow, hwnd,SW_SHOWNORMAL 
    invoke UpdateWindow, hwnd 
    invoke GetMenu,hwnd 
    mov  hMenu,eax 
    .WHILE TRUE 
            invoke GetMessage, ADDR msg,NULL,0,0 
            .BREAK .IF (!eax) 
            invoke TranslateMessage, ADDR msg 
            invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov     eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    .IF uMsg==WM_CREATE 
        invoke CreateEvent,NULL,FALSE,FALSE,NULL 
        mov  hEventStart,eax 
        mov  eax,OFFSET ThreadProc 
        invoke CreateThread,NULL,NULL,eax,\ 
                             NULL,0,\ 
                             ADDR ThreadID 
        invoke CloseHandle,eax 
    .ELSEIF uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam 
        .if lParam==0 
            .if ax==IDM_START_THREAD 
                invoke SetEvent,hEventStart 
                invoke EnableMenuItem,hMenu,IDM_START_THREAD,MF_GRAYED 
                invoke EnableMenuItem,hMenu,IDM_STOP_THREAD,MF_ENABLED 
            .elseif ax==IDM_STOP_THREAD 
                mov  EventStop,TRUE 
                invoke EnableMenuItem,hMenu,IDM_START_THREAD,MF_ENABLED 
                invoke EnableMenuItem,hMenu,IDM_STOP_THREAD,MF_GRAYED 
            .else 
                invoke DestroyWindow,hWnd 
            .endif 
        .endif 
    .ELSEIF uMsg==WM_FINISH 
        invoke MessageBox,NULL,ADDR SuccessString,ADDR AppName,MB_OK 
    .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
.ENDIF 
    xor    eax,eax 
    ret 
WndProc endp 

ThreadProc PROC USES ecx Param:DWORD 
        invoke WaitForSingleObject,hEventStart,INFINITE 
        mov  ecx,600000000 
        .WHILE ecx!=0 
                .if EventStop!=TRUE 
                        add  eax,eax 
                        dec  ecx 
                .else 
                        invoke MessageBox,hwnd,ADDR StopString,ADDR AppName,MB_OK 
                        mov  EventStop,FALSE 
                        jmp ThreadProc 
                .endif 
        .ENDW 
        invoke PostMessage,hwnd,WM_FINISH,NULL,NULL 
        invoke EnableMenuItem,hMenu,IDM_START_THREAD,MF_ENABLED 
        invoke EnableMenuItem,hMenu,IDM_STOP_THREAD,MF_GRAYED 
        jmp   ThreadProc 
        ret 
ThreadProc ENDP 
end start 

Analysis:
In this example, I demonstrate another thread technique. 
    .IF uMsg==WM_CREATE 
        invoke CreateEvent,NULL,FALSE,FALSE,NULL 
        mov  hEventStart,eax 
        mov  eax,OFFSET ThreadProc 
        invoke CreateThread,NULL,NULL,eax,\ 
                             NULL,0,\ 
                             ADDR ThreadID 
        invoke CloseHandle,eax 

You can see that I create the event object and the thread during the processing of WM_CREATE message. 
I create the event object in the nonsignalled state with automatic reset. After the event object is created,
 I create the thread. However the thread doesn't run immediately because it waits for the event object to be 
 in the signalled state as the code below: 

ThreadProc PROC USES ecx Param:DWORD 
        invoke WaitForSingleObject,hEventStart,INFINITE 
        mov  ecx,600000000 

The first line of the thread procedure is the call to WaitForSingleObject. It waits infinitely for the 
signalled state of the event object before it returns. This means that even when the thread is created, 
we put it into a dormant state. 
When the user selects "run thread" command from the menu, we set the event object into signalled state 
as below: 

            .if ax==IDM_START_THREAD 
                invoke SetEvent,hEventStart 

The call to SetEvent turns the event object into the signalled state which in turn makes the 
WaitForSingleObject call in the thread procedure return and the thread starts running. When the user selects 
"stop thread" command,  we set the value of the global variable "EventStop" to TRUE. 

                .if EventStop==FALSE 
                        add  eax,eax 
                        dec  ecx 
                .else 
                        invoke MessageBox,hwnd,ADDR StopString,ADDR AppName,MB_OK 
                        mov  EventStop,FALSE 
                        jmp ThreadProc 
                .endif 

This stops the thread and jumps to the WaitForSingleObject call again. Note that we don't have to manually 
reset the event object into nonsignalled state because we specify the bManualReset parameter of the 
CreateEvent call as FALSE.

Unfortunately you can't run Java applets  


Tutorial 17: Dynamic Link Libraries
  
In this tutorial, we will learn about DLLs , what are they and how to create them. 
  
Theory:
     If you program long enough, you'll find that the programs you wrote usually have some code routines in 
     common. It's such a waste of time to rewrite them everytime you start coding new programs. Back in the 
     old days of DOS, programmers store those commonly used routines in one or more libraries. When they want
     to use the functions, they just link the library to the object file and the linker extracts the functions
     from the library and inserts them into the final executable file. This process is called static linking.
     C runtime libraries are good examples. The drawback of this method is that you have identical functions 
     in every program that calls them. Your disk space is wasted storing several identical copies of the 
     functions. But for DOS programs, this method is quite acceptable since there is usually only one program 
     that's active in memory. So there is no waste of precious memory. 
     Under Windows, the situation becomes much more critical because you can have several programs running 
     simultaneously. Memory will be eat up quickly if your program is quite large. Windows has a solution for 
     this type of problem: dynamic link libraries. A dynamic link library is a kind of common pool of functions. 
     Windows will not load several copies of a DLL into memory so even if there are many instances of 
     your program running at the same time, there'll be only one copy of the DLL that program uses in memory. 
     And I should clarify this point a bit. In reality, all processes that use the same dll will have their own 
     copies of that dll. It will look like there are many copies of the DLL in memory. But in reality, Windows 
     does it magic with paging and all processes share the same DLL code.So in physical memory, there is only 
     one copy of DLL code. However, each process will have its own unique data section of the DLL. 
     The program links to a DLL at runtime unlike the old static library. That's why it's called dynamic link
     library. You can also unload a DLL at runtime as well when you don't need it. If that program is the only 
     one that uses the DLL, it'll be unloaded from memory immediately. But if the DLL is still used by some 
     other program, the DLL remains in memory until the last program that uses its service unloads it. 
     However, the linker has a more difficult job when it performs address fixups for the final executable file. 
     Since it cannot "extract" the functions and insert them into the final executable file, somehow it must 
     store enough information about the DLL and functions into the final execuable file for it to be able to locate
     and load the correct DLL at runtime. 
     That's where import library comes in. An import library contains the information about the DLL it represents.
     The linker can extract the info it needs from the import libraries and stuff it into the executable file. 
     When Windows loader loads the program into memory, it sees that the program links to a DLL so it searches 
     for that DLL and maps it into the address space of the process as well and performs the address fixups for 
     the calls to the functions in the DLL. 
     You may choose to load the DLL yourself without relying on Windows loader. This method has its pros and cons: 
     
     It doesn't need an import library so you can load and use any DLL even if it comes with no import library. 
     However, you still have to know about the functions inside it, how many parameters they take and the likes. 
     When you let the loader load the DLL for your program, if the loader cannot find the DLL it will report "A 
     required .DLL file, xxxxx.dll is missing" and poof! your program doesn't have a chance to run even if that 
     DLL is not essential to its operation. If you load the DLL yourself, when the DLL cannot be found and it's 
     not essential to the operation, your program can just tell the user about the fact and go on. 
     You can call *undocumented* functions that are not included in the import libraries. Provided that you know 
     enough info about the functions. 
     If you use LoadLibrary, you have to call GetProcAddress for every function that you want to call. 
     GetProcAddress retrieves the entrypoint address of a function in a particular DLL. So your code might be a little bit larger and slower but by not much. 
     Seeing the advantages/disadvantages of LoadLibrary call, we go into detail how to create a DLL now. 
     The following code is the DLL skeleton. 
;-------------------------------------------------------------------------------------- 
;                           DLLSkeleton.asm 
;-------------------------------------------------------------------------------------- 
.386 
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 

.data 
.code 
DllEntry proc hInstDLL:HINSTANCE, reason:DWORD, reserved1:DWORD 
        mov  eax,TRUE 
        ret 
DllEntry Endp 
;--------------------------------------------------------------------------------------------------- 
;                                                This is a dummy function 
; It does nothing. I put it here to show where you can insert  functions into 
; a DLL. 
;---------------------------------------------------------------------------------------------------- 
TestFunction proc 
    ret 
TestFunction endp 

End DllEntry 

;------------------------------------------------------------------------------------- 
;                              DLLSkeleton.def 
;------------------------------------------------------------------------------------- 
LIBRARY   DLLSkeleton 
EXPORTS   TestFunction 
  

The above program is the DLL skeleton. Every DLL must have an entrypoint function. Windows will call the 
entrypoint function everytime that: 

The DLL is first loaded 
The DLL is unloaded 
     A thread is created in the same process 
     A thread is destroyed in the same process 
     DllEntry proc hInstDLL:HINSTANCE, reason:DWORD, reserved1:DWORD 
        mov  eax,TRUE 
        ret 
     DllEntry Endp 
     You can name the entrypoint function anything you wish so long as you have a matching END <Entrypoint function
     name>. This function takes three parameters, only the first two of which are important. 
     hInstDLL is the module handle of the DLL. It's not the same as the instance handle of the process. You should
     keep this value if you need to use it later. You can't obtain it again easily. 
     reason can be one of the four values: 
     
     DLL_PROCESS_ATTACH The DLL receives this value when it is first injected into the process address space. 
     You can use this opportunity to do initialization. 
     DLL_PROCESS_DETACH The DLL receives this value when it is being unloaded from the process address space. 
     You can use this opportunity to do some cleanup such as deallocate memory and so on. 
     DLL_THREAD_ATTACH The DLL receives this value when the process creates a new thread. 
     DLL_THREAD_DETACH The DLL receives this value when a thread in the process is destroyed. 
     You return TRUE in eax if you want the DLL to go on running. If you return FALSE, the DLL will not be loaded. 
     For example, if your initialization code must allocate some memory and it cannot do that successfully, 
     the entrypoint function should return FALSE to indicate that the DLL cannot run. 
     You can put your functions in the DLL following the entrypoint function or before it. But if you want them 
     to be callable from other programs, you must put their names in the export list in the module definition file
     (.def). 
     A DLL needs a module definition file in its developmental stage. We will take a look at it now. 
     LIBRARY   DLLSkeleton 
     EXPORTS   TestFunction 
     
     Normally you must have the first line.The LIBRARY statement defines the internal module name of the DLL. 
     You should match it with the filename of the DLL. 
     The EXPORTS statement tells the linker which functions in the DLL are exported, that is, callable from other
     programs. In the example, we want other modules to be able to call TestFunction, so we put its name in the 
     statement. 
     Another change is in the linker switch. You must put /DLL switch and /DEF:<your def filename> in your linker
     switches like this: 
     
     link /DLL /SUBSYSTEM:WINDOWS /DEF:DLLSkeleton.def /LIBPATH:c:\Masm32\lib DLLSkeleton.obj 
     
     The assembler switches are the same, namely /c /coff /Cp. So after you link the object file, you will get
     .dll and .lib. The .lib is the import library which you can use to link to other programs that use the 
     functions in the DLL. 
     Next I'll show you how to use LoadLibrary to load a DLL. 

;--------------------------------------------------------------------------------------------- 
;                                      UseDLL.asm 
;---------------------------------------------------------------------------------------------- 
.386 
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
includelib \Masm32\lib\kernel32.lib 
includelib \Masm32\lib\user32.lib 

.data 
LibName db "DLLSkeleton.dll",0 
FunctionName db "TestHello",0 
DllNotFound db "Cannot load library",0 
AppName db "Load Library",0 
FunctionNotFound db "TestHello function not found",0 

.data? 
hLib dd ?                                         ; the handle of the library (DLL) 
TestHelloAddr dd ?                        ; the address of the TestHello function 

.code 
start: 
        invoke LoadLibrary,addr LibName 
;--------------------------------------------------------------------------------------------------------- 
; Call LoadLibrary with the name of the desired DLL. If the call is successful 
; it will return the handle to the library (DLL). If not, it will return NULL 
; You can pass the library handle to GetProcAddress or any function that requires 
; a library handle as a parameter. 
;------------------------------------------------------------------------------------------------------------ 
        .if eax==NULL 
                invoke MessageBox,NULL,addr DllNotFound,addr AppName,MB_OK 
        .else 
                mov hLib,eax 
                invoke GetProcAddress,hLib,addr FunctionName 
;------------------------------------------------------------------------------------------------------------- 
; When you get the library handle, you pass it to GetProcAddress with the address 
; of the name of the function in that DLL you want to call. It returns the address 
; of the function if successful. Otherwise, it returns NULL 
; Addresses of functions don't change unless you unload and reload the library. 
; So you can put them in global variables for future use. 
;------------------------------------------------------------------------------------------------------------- 
                .if eax==NULL 
                        invoke MessageBox,NULL,addr FunctionNotFound,addr AppName,MB_OK 
                .else 
                        mov TestHelloAddr,eax 
                        call [TestHelloAddr] 
;------------------------------------------------------------------------------------------------------------- 
; Next, you can call the function with a simple call with the variable containing 
; the address of the function as the operand. 
;------------------------------------------------------------------------------------------------------------- 
                .endif 
                invoke FreeLibrary,hLib 
;------------------------------------------------------------------------------------------------------------- 
; When you don't need the library anymore, unload it with FreeLibrary. 
;------------------------------------------------------------------------------------------------------------- 
        .endif 
        invoke ExitProcess,NULL 
end start 

So you can see that using LoadLibrary is a little more involved but it's also more flexible.


Unfortunately you can't run Java applets  


Tutorial 18: Common Controls
  
We will learn what common controls are and how to use them. This tutorial will be a quick introduction to 
them only. 
Theory:
Windows 95 comes with several user-interface enhancements over Windows 3.1x. They make the GUI richer. 
Several of them are in widely used before Windows 95 hit the shelf, such as status bar, toolbars etc.
 Programmers have to code them themselves. Now Microsoft has included them with Windows 9x and NT. 
 We will learn about them here. 
These are the new controls: 
Toolbar 
Tooltip 
Status bar 
Property sheet 
Property page 
Tree view 
List view 
Animation 
Drag list 
Header 
Hot-key 
Image list 
Progress bar 
Right edit 
Tab 
Trackbar 
Up-down 
     Since there are many of them, loading them all into memory and registering them would be a waste of resource. 
     All of them, with the exception of rich edit control, are stored in comctl32.dll with applications can load
     when they want to use the controls. Rich edit control resides in its own dll, richedXX.dll, because it's
     very complicated and hence larger than its brethren. 
     You can load comctl32.dll by including a call to InitCommonControls in your program. InitCommonControls is a
     function in comctl32.dll, so referring to it anywhere in your code will make PE loader load comctl32.dll
     when your program runs.You don't have to execute it, just include it in your code somewhere. This function 
     does NOTHING! Its only instruction is "ret". Its sole purpose is to include reference to comctl32.dll
     in the import section so that PE loader will load it whenever the program is loaded. The real workhorse
     is the DLL entrypoint function which registers all common control classes when the dll is loaded. 
     Common controls are created based on those classes just like other child window controls such as edit,
     listbox etc. 
     Rich edit is another matter entirely. If you want to use it, you have to call LoadLibrary to load it
     explicitly and call FreeLibrary to unload it. 
     Now we learn how to create them. You can use a resource editor to incorporate them into dialog boxes
     or you can create them yourself. Nearly all common controls are created by calling CreateWindowEx or
     CreateWindow, passing it the name of the control class. Some common controls have specific creation
     functions , however, they are just wrappers around CreateWindowEx to make it easier to create those
    controls. Existing specific creation functions are listed below: 
CreateToolbarEx 
CreateStatusWindow 
CreatePropertySheetPage 
PropertySheet 
ImageList_Create 
In order to create common controls, you have to know their class names. They are listed below: 
  
Class Name Common Control 
ToolbarWindow32 Toolbar 
tooltips_class32 Tooltip 
msctls_statusbar32 Status bar 
SysTreeView32 Tree view 
SysListView32 List view 
SysAnimate32 Animation 
SysHeader32 Header 
msctls_hotkey32 Hot-key 
msctls_progress32 Progress bar 
RICHEDIT Rich edit 
msctls_updown32 Up-down 
SysTabControl32 Tab 

     Property sheets and property pages and image list control have their own specific creation functions. 
     Drag list control are souped-up listbox so it doesn't have its own class. The above class names are 
     verified by checking resource script generated by Visual C++ resource editor. They differ from the class 
     names listed by Borland's win32 api reference and Charles Petzold's Programming Windows 95. The above list
     is the accurate one. 
     Those common controls can use general window styles such as WS_CHILD etc. They also have their own specific 
     styles such as TVS_XXXXX for tree view control, LVS_xxxx for list view control, etc. Win32 api reference is
     your best friend in this regard. 
     Now that we know how to create common controls, we can move on to communication method between common 
     controls and their parent. Unlike child window controls, common controls don't communicate with the parent 
     via WM_COMMAND. Instead they send WM_NOTIFY messages to the parent window when some interesting events occur
     with the common controls. The parent can control the children by sending messages to them. There are also 
     many new messages for those new controls. You should consult your win32 api reference for more detail. 
     Let's examine progress bar and status bar controls in the following example. 
Sample code:
 .386 
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\comctl32.inc 
includelib \Masm32\lib\comctl32.lib 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD 

.const 
IDC_PROGRESS equ 1            ; control IDs 
IDC_STATUS equ 2 
IDC_TIMER  equ 3 

.data 
ClassName  db "CommonControlWinClass",0 
AppName    db "Common Control Demo",0 
ProgressClass  db "msctls_progress32",0       ; the class name of the progress bar 
Message  db "Finished!",0 
TimerID  dd 0 

.data? 
hInstance  HINSTANCE ? 
hwndProgress dd ? 
hwndStatus dd ? 
CurrentStep dd ? 
.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 
    invoke InitCommonControls 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 

    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_APPWORKSPACE 
    mov   wc.lpszMenuName,NULL 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\ 
WS_OVERLAPPED+WS_CAPTION+WS_SYSMENU+WS_MINIMIZEBOX+WS_MAXIMIZEBOX+WS_VISIBLE,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\ 
           hInst,NULL 
    mov   hwnd,eax 
    .while TRUE 
         invoke GetMessage, ADDR msg,NULL,0,0 
        .BREAK .IF (!eax) 
        invoke TranslateMessage, ADDR msg 
        invoke DispatchMessage, ADDR msg 
    .endw 
    mov eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    .if uMsg==WM_CREATE 
         invoke CreateWindowEx,NULL,ADDR ProgressClass,NULL,\ 
            WS_CHILD+WS_VISIBLE,100,\ 
            200,300,20,hWnd,IDC_PROGRESS,\ 
            hInstance,NULL 
        mov hwndProgress,eax 
        mov eax,1000               ; the lParam of PBM_SETRANGE message contains the range 
        mov CurrentStep,eax 
        shl eax,16                   ; the high range is in the high word 
        invoke SendMessage,hwndProgress,PBM_SETRANGE,0,eax 
        invoke SendMessage,hwndProgress,PBM_SETSTEP,10,0 
        invoke CreateStatusWindow,WS_CHILD+WS_VISIBLE,NULL,hWnd,IDC_STATUS 
        mov hwndStatus,eax 
        invoke SetTimer,hWnd,IDC_TIMER,100,NULL        ; create a timer 
        mov TimerID,eax 
    .elseif uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
        .if TimerID!=0 
            invoke KillTimer,hWnd,TimerID 
        .endif 
    .elseif uMsg==WM_TIMER        ; when a timer event occurs 
        invoke SendMessage,hwndProgress,PBM_STEPIT,0,0    ; step up the progress in the progress bar 
        sub CurrentStep,10 
        .if CurrentStep==0 
            invoke KillTimer,hWnd,TimerID 
            mov TimerID,0 
            invoke SendMessage,hwndStatus,SB_SETTEXT,0,addr Message 
            invoke MessageBox,hWnd,addr Message,addr AppName,MB_OK+MB_ICONINFORMATION 
            invoke SendMessage,hwndStatus,SB_SETTEXT,0,0 
            invoke SendMessage,hwndProgress,PBM_SETPOS,0,0 
        .endif 
    .else 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .endif 
    xor eax,eax 
    ret 
WndProc endp 
end start 

Analysis:
    invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 
    invoke InitCommonControls
I deliberately put InitCommonControls after ExitProcess to demonstrate that InitCommonControls is just 
there for putting a reference to comctl32.dll in the import section. As you can see, the common controls 
work even if InitCommonControls doesn't execute. 
    .if uMsg==WM_CREATE 
         invoke CreateWindowEx,NULL,ADDR ProgressClass,NULL,\ 
            WS_CHILD+WS_VISIBLE,100,\ 
            200,300,20,hWnd,IDC_PROGRESS,\ 
            hInstance,NULL 
        mov hwndProgress,eax
     Here is where we create the common control. Note that this CreateWindowEx call contains hWnd as the parent
     window handle. It also specifies a control ID for identifying this control. However, since we have the 
 control's window handle, this ID is not used. All child window controls must have WS_CHILD style. 
        mov eax,1000 
        mov CurrentStep,eax 
        shl eax,16 
        invoke SendMessage,hwndProgress,PBM_SETRANGE,0,eax 
        invoke SendMessage,hwndProgress,PBM_SETSTEP,10,0
     After the progress bar is created, we can set its range. The default range is from 0 to 100. 
     If you are not satisfied with it, you can specify your own range with PBM_SETRANGE message. 
     lParam of this message contains the range, the maximum range is in the high word and the minimum one 
     is in the low word. You can specify how much a step takes by using PBM_SETSTEP message. The example sets 
     it to 10 which means that when you send a PBM_STEPIT message to the progress bar, the progress indicator 
     will rise by 10. You can also set your own indicator level by sending PBM_SETPOS messages. This message 
     gives you tighter control over the progress bar. 
        invoke CreateStatusWindow,WS_CHILD+WS_VISIBLE,NULL,hWnd,IDC_STATUS 
        mov hwndStatus,eax 
        invoke SetTimer,hWnd,IDC_TIMER,100,NULL        ; create a timer 
        mov TimerID,eax
     Next, we create a status bar by calling CreateStatusWindow. This call is easy to understand so 
     I'll not comment on it. After the status window is created, we create a timer. In this example, 
     we will update the progress bar at a regular interval of 100 ms so we must create a timer control.
     Below is the function prototype of SetTimer. 
     SetTimer PROTO hWnd:DWORD, TimerID:DWORD, TimeInterval:DWORD, lpTimerProc:DWORD
     hWnd : Parent window handle 
     TimerID : a nonzero timer identifier. You can create your own identifier. 
     TimerInterval : the timer interval in milliseconds that must pass before the timer calls the timer 
     procedure or sends a WM_TIMER message 
     lpTimerProc : the address of the timer function that will be called when the time interval expires.
     If this parameter is NULL, the timer will send WM_TIMER message to the parent window instead. 
     If this call is successful, it will return the TimerID. If it failed, it returns 0. This is why the
 timer identifer must be a nonzero value. 

    .elseif uMsg==WM_TIMER 
        invoke SendMessage,hwndProgress,PBM_STEPIT,0,0 
        sub CurrentStep,10 
        .if CurrentStep==0 
            invoke KillTimer,hWnd,TimerID 
            mov TimerID,0 
            invoke SendMessage,hwndStatus,SB_SETTEXT,0,addr Message 
            invoke MessageBox,hWnd,addr Message,addr AppName,MB_OK+MB_ICONINFORMATION 
            invoke SendMessage,hwndStatus,SB_SETTEXT,0,0 
            invoke SendMessage,hwndProgress,PBM_SETPOS,0,0 
        .endif
When the specified time interval expires, the timer sends a WM_TIMER message. You will put your code that 
will be executed here. In this example, we update the progress bar and then check if the maximum limit has 
been reached. If it has, we kill the timer and then set the text in the status window with SB_SETTEXT message.
 A message box is displayed and when the user clicks OK, we clear the text in the status bar and the progress 
 bar.


Unfortunately you can't run Java applets  


Tutorial 19: TreeView Control
  
In this tutorial, we will learn how to use tree view control. Moreover, we will also learn how to do drag 
and drop under tree view control and how to use an image list with it. 
Theory:
A tree view control is a special kind of window that represents objects in hierarchical order. An example 
of it is the left pane of Windows Explorer. You can use this control to show relationships between objects. 
You can create a tree view control by calling CreateWindowEx, passing "SysTreeView32" as the class name or 
you can incorporate it into a dialog box. Don't forget to put InitCommonControls call in your code. 
There are several styles specific to the tree view control. These three are the ones mostly used. 
TVS_HASBUTTONS == Displays plus (+) and minus (-) buttons next to parent items. The user clicks the buttons
 to expand or collapse a parent item's list of child items. To include buttons with items at the root of 
 the tree view, TVS_LINESATROOT must also be specified. 
TVS_HASLINES == Uses lines to show the hierarchy of items. 
TVS_LINESATROOT == Uses lines to link items at the root of the tree-view control. This value is ignored 
if TVS_HASLINES is not also specified.
The tree view control, like other common controls, communicates with the parent window via messages. 
The parent window can send various messages to it and the tree view control can send "notification" messages 
to its parent window. In this regard, the tree view control is not different that any window. 
When something interesting occurs to it, it sends a WM_NOTIFY message to the parent window with accompanying 
information. 
WM_NOTIFY 
wParam == Control ID, this value is not guaranteed to be unique so we don't use it. 
                    Instead, we use hwndFrom or IDFrom member of the NMHDR structure 
                    pointed to by lParam 
lParam == Pointer to NMHDR structure. Some controls may pass a pointer to larger 
                   structure but it must have a NMHDR structure as its first member. 
                    That is, when you have lParam, you can be sure that it points to a 
                    NMHDR structure at least.
Next we will examine NMHDR structure. 
NMHDR struct DWORD 
    hwndFrom    DWORD ? 
    idFrom          DWORD ? 
    code              DWORD ? 
NMHDR ends
hwndFrom is the window handle of the control that sends this WM_NOTIFY message. 
idFrom is the control ID of the control that sends this WM_NOTIFY message. 
code is the actual message the control wants to send to the parent window. 
Tree view notifications are those with TVN_ at the beginning of the name. Tree view messages are those 
with TVM_, like TVM_CREATEDRAGIMAGE. The tree view control sends TVN_xxxx in the code member of NMHDR. 
The parent window can send TVM_xxxx to control it. 
Adding items to a tree view control
After you create a tree view control, you can add items to it. You can do this by sending TVM_INSERTITEM to it.
 
TVM_INSERTITEM 
wParam = 0; 
lParam = pointer to a TV_INSERTSTRUCT;
You should know some terminology at this point about the relationship between items in the tree view control.
 
An item can be parent, child, or both at the same time. A parent item is the item that has some other 
subitem(s) associated with it. At the same time, the parent item may be a child of some other item. 
An item without a parent is called a root item. There can be many root items in a tree view control. 
Now we examine TV_INSERTSTRUCT structure 
TV_INSERTSTRUCT STRUCT DWORD 
  hParent       DWORD      ? 
  hInsertAfter  DWORD ? 
                      ITEMTYPE <> 
TV_INSERTSTRUCT ENDS
hParent = Handle to the parent item. If this member is the TVI_ROOT value or NULL, the item is inserted 
at the root of the tree-view control. 
hInsertAfter = Handle to the item after which the new item is to be inserted or one of the following values:
 
TVI_FIRST ==> Inserts the item at the beginning of the list. 
TVI_LAST ==> Inserts the item at the end of the list. 
TVI_SORT ==> Inserts the item into the list in alphabetical order. 
ITEMTYPE UNION 
        itemex TVITEMEX <> 
        item TVITEM <> 
ITEMTYPE ENDS
We will use only TVITEM here. 
TV_ITEM STRUCT DWORD 
  imask             DWORD      ? 
  hItem             DWORD      ? 
  state             DWORD      ? 
  stateMask         DWORD      ? 
  pszText           DWORD      ? 
  cchTextMax        DWORD      ? 
  iImage            DWORD      ? 
  iSelectedImage    DWORD      ? 
  cChildren         DWORD      ? 
  lParam            DWORD      ? 
TV_ITEM ENDS
This structure is used to send and receive info about a tree view item, depending on messages. For example, 
with TVM_INSERTITEM, it is used to specify the attribute of the item to be inserted into the tree view control.
 With TVM_GETITEM, it'll be filled with information about the selected tree view item. 
imask is used to specify which member(s) of the TV_ITEM structure is (are) valid. For example, if the value 
in imask is TVIF_TEXT, it means only the pszText member is valid. You can combine several flags together. 
hItem is the handle to the tree view item. Each item has its own handle, like a window handle. If you want 
to do something with an item, you must select it by its handle. 
pszText is the pointer to a null-terminated string that is the label of the tree view item. 
cchTextMax is used only when you want to retrieve the label of the tree view item. Because you will supply 
the pointer to the buffer in pszText, Windows has to know the size of the provided buffer. You have to give
 the size of the buffer in this member. 
iImage and iSelectedImage refers to the index into an image list that contains the images to be shown when 
the item is not selected and when it's selected. If you recall Windows Explorer left pane, the folder images 
are specified by these two members. 
In order to insert an item into the tree view control, you must at least fill in the hParent, hInsertAfter 
and you should fill imask and pszText members as well. 
Adding images to the tree view control
If you want to put an image to the left of the tree view item's label, you have to create an image list and 
associate it with the tree view control. You can create an image list by calling ImageList_Create. 
ImageList_Create PROTO cx:DWORD, cy:DWORD, flags:DWORD, \ 
                                            cInitial:DWORD,  cGrow:DWORD
     This function returns the handle to an empty image list if successful. 
     cx == width of each image in this image list, in pixels. 
     cy == height of each image in this image list, in pixels. Every image in an image list must be equal to each
     other in size. If you specify a large bitmap, Windows will use cx and cy to *cut* it into several pieces. 
     So you should prepare your own image as a strip of pictures with identical dimensions. 
     flags == specify the type of images in this image list whether they are color or monochrome and their color 
     depth. Consult your win32 api reference for more detail 
     cInitial == The number of images that this image list will initially contain. Windows will use this info to 
     allocate memory for the images. 
     cGrow == Amount of images by which the image list can grow when the system needs to resize the list to make
     room for new images. This parameter represents the number of new images that the resized image list can 
     contain. 
     An image list is not a window! It's only an image deposit for use by other windows. 
     After an image list is created, you can add images to it by calling ImageList_Add 
     ImageList_Add PROTO himl:DWORD, hbmImage:DWORD, hbmMask:DWORD
     This function returns -1 if unsuccessful. 
     himl == the handle of the image list you want to add images to. It is the value returned by a successful 
     call to ImageList_Create 
     hbmImage == the handle to the bitmap to be added to the image list. You usually store the bitmap in the 
     resource and load it with LoadBitmap call. Note that you don't have to specify the number of images contained 
     in this bitmap because this information is inferred from cx and cy parameters passed to ImageList_Create call. 
     hbmMask == Handle to the bitmap that contains the mask. If no mask is used with the image list, this parameter
     is ignored. 
     Normally, we will add only two images to the image list for use with the tree view control: one that is used
     when the tree view item is not selected, and the other when the item is selected. 
     When the image list is ready, you associate it with the tree view control by sending TVM_SETIMAGELIST to the 
     tree view control. 
     TVM_SETIMAGELIST 
     wParam = type of image list to set. There are two choices: 
     TVSIL_NORMAL Set the normal image list, which contains the selected and unselected images for the tree-view 
     item. 
     TVSIL_STATE Set the state image list, which contains the images for tree-view items that are in a user-defined
     state. 
     lParam = Handle to the image list
     Retrieve the info about tree view item
     You can retrieve the information about a tree view item by sending TVM_GETITEM message. 
TVM_GETITEM 
wParam = 0 
lParam = pointer to the TV_ITEM structure to be filled with the information
Before you send this message, you must fill imask member with the flag(s) that specifies which member(s) 
of TV_ITEM you want Windows to fill. And most importantly, you must fill hItem with the handle to the item 
you want to get information from. And this poses a problem: How can you know the handle of the item you want
 to retrieve info from? Will you have to store all tree view handles? 
The answer is quite simple: you don't have to. You can send TVM_GETNEXTITEM message to the tree view control 
to retrieve the handle to the tree view item that has the attribute(s) you specified. For example, you can 
query the handle of the first child item, the root item, the selected item, and so on. 
TVM_GETNEXTITEM 
wParam = flag 
lParam = handle to a tree view item (only necessary for some flag values)
The value in wParam is very important so I present all the flags below: 
TVGN_CARET Retrieves the currently selected item. 
TVGN_CHILD Retrieves the first child item of the item specified by the hitem parameter 
TVGN_DROPHILITE Retrieves the item that is the target of a drag-and-drop operation. 
TVGN_FIRSTVISIBLE Retrieves the first visible item. 
TVGN_NEXT Retrieves the next sibling item. 
TVGN_NEXTVISIBLE Retrieves the next visible item that follows the specified item. The specified item must 
be visible. Use the TVM_GETITEMRECT message to determine whether an item is visible. 
TVGN_PARENT Retrieves the parent of the specified item. 
TVGN_PREVIOUS Retrieves the previous sibling item. 
TVGN_PREVIOUSVISIBLE Retrieves the first visible item that precedes the specified item. The specified item 
must be visible. Use the TVM_GETITEMRECT message to determine whether an item is visible. 
TVGN_ROOT Retrieves the topmost or very first item of the tree-view control. 
You can see that, you can retrieve the handle to the tree view item you are interested in from this message. 
SendMessage returns the handle to the tree view item if successful. You can then fill the returned handle 
into hItem member of TV_ITEM to be used with TVM_GETITEM message. 
Drag and Drop Operation in tree view control
This part is the reason I decided to write this tutorial. When I tried to follow the example in win32 api 
reference (the win32.hlp from InPrise), I was very frustrated because the vital information is lacking. 
From trial and error, I finally figured out how to implement drag & drop in a tree view control and 
I don't want anyone to walk the same path as myself. 
Below is the steps in implementing drag & drop operation in a tree view control. 
When the user tries to drag an item, the tree view control sends TVN_BEGINDRAG notification to the parent 
window. You can use this opportunity to create a drag image which is the image that will be used to represent 
the item while it's being dragged. You can send TVM_CREATEDRAGIMAGE to the tree view control to tell it to 
create a default drag image from the image that is currently used by the item that will be dragged. 
The tree view control will create an image list with just one drag image and return the handle to that image 
list to you. 
After the drag image is created, you specify the hotspot of the drag image by calling ImageList_BeginDrag. 
ImageList_BeginDrag PROTO himlTrack:DWORD,  \ 
                                                    iTrack:DWORD , \ 
                                                    dxHotspot:DWORD, \ 
                                                    dyHotspot:DWORD 
     himlTrack is the handle to the image list that contains the drag image. 
     iTrack is the index into the image list that specifies the drag image 
     dxHotspot specifies the relative distance of the hotspot in horizontal plance in the drag image since this 
     
     image will be used in place of the mouse cursor, so we need to specify which part of the image is the hotspot.
     
     dyHotspot specifies the relative distance of the hotspot in the vertical plane. 
     Normally, iTrack would be 0 if you tell the tree view control to create the drag image for you. and dxHotspot
     and dyHotspot can be 0 if you want the left upper corner of the drag image to be the hotspot.
     When the drag image is ready to be displayed, we call ImageList_DragEnter to display the drag image in the
     window. 
     ImageList_DragEnter PROTO hwndLock:DWORD, x:DWORD, y:DWORD 
     hwndLock is the handle of the window that owns the drag image. The drag image will not be able to move outside 
     that window. 
     x and y are the x-and y-coordinate of the place where the drag image should be initially displayed. Note that 
     these values are relative to the left upper corner of the window, not the client area.
     Now that the drag image is displayed on the window, you will have to support the drag operation in the tree 
     view control. However, there is a little problem here. We have to monitor the drag path with WM_MOUSEMOVE and 
     the drop location with WM_LBUTTONUP messages. However, if the drag image is over some other child windows, 
     the parent window will never receive any mouse message. The solution is to capture the mouse input with 
     SetCapture. Using the call, the mouse messages will be directed to the specified window regardless of where 
     the mouse cursor is. 
     Within WM_MOUSEMOVE handler, you will update the drag path with ImageList_DragMove call. This function moves 
     the image that is being dragged during a drag-and-drop operation. Furthermore, if you so desire, you can hilite
     the item that the drag image is over by sending TVM_HITTEST to check if the drag image is over some item. 
     If it is, you can send TVM_SELECTITEM with TVGN_DROPHILITE flag to hilite that item. Note that before sending 
     TVM_SELECTITEM message, you must hide the drag image first else your drag image will leave ugly traces. 
     You can hide the drag image by calling ImageList_DragShowNolock and, after the hilite operation is finished, 
     call ImageList_DragShowNolock again to show the drag image. 
     When the user releases the left mouse button, you must do several things. If you hilite an item, you must 
     un-hilite it by sending TVM_SELECTITEM with TVGN_DROPHILITE flag again, but this time, lParam MUST be zero.
     If you don't un-hilite the item, you will get a strange effect: when you select some other item, that item 
     will be enclosed by a rectangle but the hilite will still be on the last hilited item. Next, you must call
     ImageList_DragLeave followed by ImageList_EndDrag. You must release the mouse by calling ReleaseCapture. 
     If you create an image list, you must destroy it by calling ImageList_Destroy. After that, you can go on 
     with what your program wants to do when the drag & drop operation is completed. 
Code sample:
.386 
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\comctl32.inc 
include \Masm32\include\gdi32.inc 
includelib \Masm32\lib\gdi32.lib 
includelib \Masm32\lib\comctl32.lib 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD 
.const 
IDB_TREE equ 4006                ; ID of the bitmap resource 
.data 
ClassName  db "TreeViewWinClass",0 
AppName    db "Tree View Demo",0 
TreeViewClass  db "SysTreeView32",0 
Parent  db "Parent Item",0 
Child1  db "child1",0 
Child2  db "child2",0 
DragMode  dd FALSE                ; a flag to determine if we are in drag mode 

.data? 
hInstance  HINSTANCE ? 
hwndTreeView dd ?            ; handle of the tree view control 
hParent  dd ?                        ; handle of the root tree view item 
hImageList dd ?                    ; handle of the image list used in the tree view control 
hDragImageList  dd ?        ; handle of the image list used to store the drag image 

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 
    invoke InitCommonControls 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_APPWORKSPACE 
    mov   wc.lpszMenuName,NULL 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\           WS_OVERLAPPED+WS_CAPTION+WS_SYSMENU+WS_MINIMIZEBOX+WS_MAXIMIZEBOX+WS_VISIBLE,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,200,400,NULL,NULL,\ 
           hInst,NULL 
    mov   hwnd,eax 
    .while TRUE 
        invoke GetMessage, ADDR msg,NULL,0,0 
        .BREAK .IF (!eax) 
        invoke TranslateMessage, ADDR msg 
        invoke DispatchMessage, ADDR msg 
    .endw 
    mov eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc uses edi hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    LOCAL tvinsert:TV_INSERTSTRUCT 
    LOCAL hBitmap:DWORD 
    LOCAL tvhit:TV_HITTESTINFO 
    .if uMsg==WM_CREATE 
        invoke CreateWindowEx,NULL,ADDR TreeViewClass,NULL,\ 
            WS_CHILD+WS_VISIBLE+TVS_HASLINES+TVS_HASBUTTONS+TVS_LINESATROOT,0,\ 
            0,200,400,hWnd,NULL,\ 
            hInstance,NULL            ; Create the tree view control 
        mov hwndTreeView,eax 
        invoke ImageList_Create,16,16,ILC_COLOR16,2,10    ; create the associated image list 
        mov hImageList,eax 
        invoke LoadBitmap,hInstance,IDB_TREE        ; load the bitmap from the resource 
        mov hBitmap,eax 
        invoke ImageList_Add,hImageList,hBitmap,NULL    ; Add the bitmap into the image list 
        invoke DeleteObject,hBitmap    ; always delete the bitmap resource 
        invoke SendMessage,hwndTreeView,TVM_SETIMAGELIST,0,hImageList 
        mov tvinsert.hParent,NULL 
        mov tvinsert.hInsertAfter,TVI_ROOT 
        mov tvinsert.item.imask,TVIF_TEXT+TVIF_IMAGE+TVIF_SELECTEDIMAGE 
        mov tvinsert.item.pszText,offset Parent 
        mov tvinsert.item.iImage,0 
        mov tvinsert.item.iSelectedImage,1 
        invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert 
        mov hParent,eax 
        mov tvinsert.hParent,eax 
        mov tvinsert.hInsertAfter,TVI_LAST 
        mov tvinsert.item.pszText,offset Child1 
        invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert 
        mov tvinsert.item.pszText,offset Child2 
        invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert 
    .elseif uMsg==WM_MOUSEMOVE 
        .if DragMode==TRUE 
            mov eax,lParam 
            and eax,0ffffh 
            mov ecx,lParam 
            shr ecx,16 
            mov tvhit.pt.x,eax 
            mov tvhit.pt.y,ecx 
            invoke ImageList_DragMove,eax,ecx 
            invoke ImageList_DragShowNolock,FALSE 
            invoke SendMessage,hwndTreeView,TVM_HITTEST,NULL,addr tvhit 
            .if eax!=NULL 
                invoke SendMessage,hwndTreeView,TVM_SELECTITEM,TVGN_DROPHILITE,eax 
            .endif 
            invoke ImageList_DragShowNolock,TRUE 
        .endif 
    .elseif uMsg==WM_LBUTTONUP 
        .if DragMode==TRUE 
            invoke ImageList_DragLeave,hwndTreeView 
            invoke ImageList_EndDrag 
            invoke ImageList_Destroy,hDragImageList 
            invoke SendMessage,hwndTreeView,TVM_GETNEXTITEM,TVGN_DROPHILITE,0 
            invoke SendMessage,hwndTreeView,TVM_SELECTITEM,TVGN_CARET,eax 
            invoke SendMessage,hwndTreeView,TVM_SELECTITEM,TVGN_DROPHILITE,0 
            invoke ReleaseCapture 
            mov DragMode,FALSE 
        .endif 
    .elseif uMsg==WM_NOTIFY 
        mov edi,lParam 
        assume edi:ptr NM_TREEVIEW 
        .if [edi].hdr.code==TVN_BEGINDRAG 
            invoke SendMessage,hwndTreeView,TVM_CREATEDRAGIMAGE,0,[edi].itemNew.hItem 
            mov hDragImageList,eax 
            invoke ImageList_BeginDrag,hDragImageList,0,0,0 
            invoke ImageList_DragEnter,hwndTreeView,[edi].ptDrag.x,[edi].ptDrag.y 
            invoke SetCapture,hWnd 
            mov DragMode,TRUE 
        .endif 
        assume edi:nothing 
    .elseif uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .else 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .endif 
    xor eax,eax 
    ret 
WndProc endp 
end start 

Analysis:
Within WM_CREATE handler, you create the tree view control 
        invoke CreateWindowEx,NULL,ADDR TreeViewClass,NULL,\ 
            WS_CHILD+WS_VISIBLE+TVS_HASLINES+TVS_HASBUTTONS+TVS_LINESATROOT,0,\ 
            0,200,400,hWnd,NULL,\ 
            hInstance,NULL
Note the styles. TVS_xxxx are the tree view specific styles. 
        invoke ImageList_Create,16,16,ILC_COLOR16,2,10 
        mov hImageList,eax 
        invoke LoadBitmap,hInstance,IDB_TREE 
        mov hBitmap,eax 
        invoke ImageList_Add,hImageList,hBitmap,NULL 
        invoke DeleteObject,hBitmap 
        invoke SendMessage,hwndTreeView,TVM_SETIMAGELIST,0,hImageList
Next, you create an empty image list with will accept images of 16x16 pixels in size, 16-bit color and 
initially, it will contain 2 images but can be expanded to 10 if need arises. We then load the bitmap 
 the resource and add it to the image list just created. After that, we delete the handle to the bitmap 
 since it will not be used anymore. When the image list is all set, we associate it with the tree view 
 control by sending TVM_SETIMAGELIST to the tree view control. 
        mov tvinsert.hParent,NULL 
        mov tvinsert.hInsertAfter,TVI_ROOT 
        mov tvinsert.u.item.imask,TVIF_TEXT+TVIF_IMAGE+TVIF_SELECTEDIMAGE 
        mov tvinsert.u.item.pszText,offset Parent 
        mov tvinsert.u.item.iImage,0 
        mov tvinsert.u.item.iSelectedImage,1 
        invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
     We insert items into the tree view control, beginning from the root item. Since it will be root item, 
     hParent member is NULL and hInsertAfter is TVI_ROOT. imask member specifies that pszText, iImage and 
     iSelectedImage members of the TV_ITEM structure is valid. We fill those three members with appropriate value. 
     pszText contains the label of the root item, iImage is the index into the image in the image list that will 
     be displayed to the left of the unselected item, and iSelectedImage is the index into the image in the image
     list that will be displayed when the item is selected. When all appropriate members are filled in,
     we send TVM_INSERTITEM message to the tree view control to add the root item to it. 
        mov hParent,eax 
        mov tvinsert.hParent,eax 
        mov tvinsert.hInsertAfter,TVI_LAST 
        mov tvinsert.u.item.pszText,offset Child1 
        invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert 
        mov tvinsert.u.item.pszText,offset Child2 
        invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
After the root item is added, we can attach the child items to it. hParent member is now filled with 
the handle of the parent item. And we will use identical images in the image list so we don't change iImage
 and iSelectedImage member. 
    .elseif uMsg==WM_NOTIFY 
        mov edi,lParam 
        assume edi:ptr NM_TREEVIEW 
        .if [edi].hdr.code==TVN_BEGINDRAG 
            invoke SendMessage,hwndTreeView,TVM_CREATEDRAGIMAGE,0,[edi].itemNew.hItem 
            mov hDragImageList,eax 
            invoke ImageList_BeginDrag,hDragImageList,0,0,0 
            invoke ImageList_DragEnter,hwndTreeView,[edi].ptDrag.x,[edi].ptDrag.y 
            invoke SetCapture,hWnd 
            mov DragMode,TRUE 
        .endif 
        assume edi:nothing
     Now when the user tries to drag an item, the tree view control sends WM_NOTIFY message with TVN_BEGINDRAG as 
     the code. lParam is the pointer to an NM_TREEVIEW structure which contains several pieces of information 
     we need so we put its value into edi and use edi as the pointer to NM_TREEVIEW structure. assume edi:ptr 
     NM_TREEVIEW is a way to tell MASM to treat edi as the pointer to NM_TREEVIEW structure. We then create a drag
     image by sending TVM_CREATEDRAGIMAGE to the tree view control. It returns the handle to the newly created 
     image list with a drag image inside. We call ImageList_BeginDrag to set the hotspot in the drag image. 
     Then we enter the drag operation by calling ImageList_DragEnter. This function displays the drag image at 
     the specified location in the specified window. We use ptDrag structure that is a member of NM_TREEVIEW 
     structure as the point where the drag image should be initially displayed.After that, we capture the mouse 
     input and set the flag to indicate that we now enter drag mode. 
   .elseif uMsg==WM_MOUSEMOVE 
        .if DragMode==TRUE 
            mov eax,lParam 
            and eax,0ffffh 
            mov ecx,lParam 
            shr ecx,16 
            mov tvhit.pt.x,eax 
            mov tvhit.pt.y,ecx 
            invoke ImageList_DragMove,eax,ecx 
            invoke ImageList_DragShowNolock,FALSE 
            invoke SendMessage,hwndTreeView,TVM_HITTEST,NULL,addr tvhit 
            .if eax!=NULL 
                invoke SendMessage,hwndTreeView,TVM_SELECTITEM,TVGN_DROPHILITE,eax 
            .endif 
            invoke ImageList_DragShowNolock,TRUE 
        .endif
     Now we concentrate on WM_MOUSEMOVE. When the user drags the drag image along, our parent window receives 
     WM_MOUSEMOVE messages. In response to these messages, we update the drag image position with ImageList_DragMove.
     After that, we check if the drag image is over some item. We do that by sending TVM_HITTEST message to the 
     tree view control with a point for it to check. If the drag image is over some item, we hilite that item by 
     sending TVM_SELECTITEM message with TVGN_DROPHILITE flag to the tree view control. During the hilite 
     operation, we hide the drag image so that it will not leave unsightly blots on the tree view control. 
    .elseif uMsg==WM_LBUTTONUP 
        .if DragMode==TRUE 
            invoke ImageList_DragLeave,hwndTreeView 
            invoke ImageList_EndDrag 
            invoke ImageList_Destroy,hDragImageList 
            invoke SendMessage,hwndTreeView,TVM_GETNEXTITEM,TVGN_DROPHILITE,0 
            invoke SendMessage,hwndTreeView,TVM_SELECTITEM,TVGN_CARET,eax 
            invoke SendMessage,hwndTreeView,TVM_SELECTITEM,TVGN_DROPHILITE,0 
            invoke ReleaseCapture 
            mov DragMode,FALSE 
        .endif
     When the user releases the left mouse button, the drag operation is at the end. We leave the drag mode by 
     calling ImageList_DragLeave, followed by ImageList_EndDrag and ImageList_Destroy. To make the tree view items 
     look good, we also check the last hilited item, and select it. We must also un-hilite it else the other items 
     will not get hilited when they are selected. And lastly, we release the mouse capture.


Unfortunately you can't run Java applets  


Tutorial 20: Window Subclassing
  
     In this tutorial, we will learn about window subclassing, what it is and how to use it to your advantage. 
     Theory:
     If you program in Windows for some time, you will find some cases where a window has nearly the attributes 
     you need in your program but not quite. Have you encountered a situation where you want some special kind of
     edit control that can filter out some unwanted text? The straightforward thing to do is to code your own 
     window. But it's really hard work and time-consuming. Window subclassing to the rescue. 
     In a nutshell, window subclassing allows you to "take over" the subclassed window. You will have absolute 
     control over it. Let's take an example to make this clearer. Suppose you need a text box that accepts only
     hex numbers. If you use a simple edit control, you have no say whatsoever when your user types something 
     other than hex numbers into your text box, ie. if the user types "zb+q*" into your text box, you can't do 
     anything with it except rejecting the whole text string. This is unprofessional at least. In essence, 
     you need the ability to examine each character the user typed into the text box right at the moment he typed 
     it. 
     We will examine how to do that now. When the user types something into a text box, Windows sends WM_CHAR 
     message to the edit control's window procedure. This window procedure resides inside Windows itself so 
     we can't modify it. But we can redirect the message flow to our own window procedure. So that our window 
     procedure will get first shot at any message Windows sends to the edit control. If our window procedure 
     chooses to act on the message, it can do so. But if it doesn't want to handle the message, it can pass it 
     to the original window procedure. This way, our window procedure inserts itself between Windows and the edit 
control. Look at the flow below: 
Before Subclassing
Windows ==> edit control's window procedure 
After Subclassing
Windows ==> our window procedure -----> edit control's window procedure
Now we put our attention on how to subclass a window. Note that subclassing is not limited to controls, it can 
be used with any window. 
Let's think about how Windows knows where the edit control's window procedure resides. A guess?......
lpfnWndProc member of WNDCLASSEX structure. If we can replace this member with the address of our own window 
procedure, Windows will send messages to our window proc instead. 
We can do that by calling SetWindowLong. 
SetWindowLong PROTO hWnd:DWORD, nIndex:DWORD, dwNewLong:DWORD
hWnd = handle of the window to change the value in the WNDCLASSEX structure 
nIndex == value to change. 
GWL_EXSTYLE Sets a new extended window style. 
GWL_STYLE Sets a new window style. 
GWL_WNDPROC Sets a new address for the window procedure. 
GWL_HINSTANCE Sets a new application instance handle. 
GWL_ID Sets a new identifier of the window. 
GWL_USERDATA Sets the 32-bit value associated with the window. Each window has a corresponding 32-bit value 
intended for use by the application that created the window.
dwNewLong = the replacement value. 
So our job is easy: We code a window proc that will handle the messages for the edit control and then call 
SetWindowLong with GWL_WNDPROC flag, passing along the address of our window proc as the third parameter. 
If the function succeeds, the return value is the previous value of the specified 32-bit integer, in our case, 
the address of the original window procedure. We need to store this value for use within our window procedure. 
Remember that there will be some messages we don't want to handle, we will pass them to the original window 
procedure. We can do that by calling CallWindowProc function. 
CallWindowProc PROTO lpPrevWndFunc:DWORD, \ 
                                            hWnd:DWORD,\ 
                                            Msg:DWORD,\ 
                                            wParam:DWORD,\ 
                                            lParam:DWORD
lpPrevWndFunc = the address of the original window procedure. 
The remaining four parameters are the ones passed to our window procedure. We just pass them along to 
CallWindowProc. 
Code Sample:
.386 
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\comctl32.inc 
includelib \Masm32\lib\comctl32.lib 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD 
EditWndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD 

.data 
ClassName  db "SubclassWinClass",0 
AppName    db "Subclassing Demo",0 
EditClass  db "EDIT",0 
Message  db "You pressed Enter in the text box!",0 

.data? 
hInstance  HINSTANCE ? 
hwndEdit dd ? 
OldWndProc dd ? 

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_APPWORKSPACE 
    mov   wc.lpszMenuName,NULL 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\ 
 WS_OVERLAPPED+WS_CAPTION+WS_SYSMENU+WS_MINIMIZEBOX+WS_MAXIMIZEBOX+WS_VISIBLE,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,350,200,NULL,NULL,\ 
           hInst,NULL 
    mov   hwnd,eax 
    .while TRUE 
        invoke GetMessage, ADDR msg,NULL,0,0 
        .BREAK .IF (!eax) 
        invoke TranslateMessage, ADDR msg 
        invoke DispatchMessage, ADDR msg 
    .endw 
    mov eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    .if uMsg==WM_CREATE 
        invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR EditClass,NULL,\ 
            WS_CHILD+WS_VISIBLE+WS_BORDER,20,\ 
            20,300,25,hWnd,NULL,\ 
            hInstance,NULL 
        mov hwndEdit,eax 
        invoke SetFocus,eax 
        ;----------------------------------------- 
        ; Subclass it! 
        ;----------------------------------------- 
        invoke SetWindowLong,hwndEdit,GWL_WNDPROC,addr EditWndProc 
        mov OldWndProc,eax 
    .elseif uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .else 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .endif 
    xor eax,eax 
    ret 
WndProc endp 

EditWndProc PROC hEdit:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 
    .if uMsg==WM_CHAR 
        mov eax,wParam 
        .if (al>="0" && al<="9") || (al>="A" && al<="F") || (al>="a" && al<="f") || al==VK_BACK 
            .if al>="a" && al<="f" 
                sub al,20h 
            .endif 
            invoke CallWindowProc,OldWndProc,hEdit,uMsg,eax,lParam 
            ret 
        .endif 
    .elseif uMsg==WM_KEYDOWN 
        mov eax,wParam 
        .if al==VK_RETURN 
            invoke MessageBox,hEdit,addr Message,addr AppName,MB_OK+MB_ICONINFORMATION 
            invoke SetFocus,hEdit 
        .else 
            invoke CallWindowProc,OldWndProc,hEdit,uMsg,wParam,lParam 
            ret 
        .endif 
    .else 
        invoke CallWindowProc,OldWndProc,hEdit,uMsg,wParam,lParam 
        ret 
    .endif 
    xor eax,eax 
    ret 
EditWndProc endp 
end start 

Analysis:
        invoke SetWindowLong,hwndEdit,GWL_WNDPROC,addr EditWndProc 
        mov OldWndProc,eax
After the edit control is created, we subclass it by calling SetWindowLong, replacing the address of 
the original window procedure with our own window procedure. Note that we store the address of the original 
window procedure for use with CallWindowProc. Note the EditWndProc is an ordinary window procedure. 
  .if uMsg==WM_CHAR 
        mov eax,wParam 
        .if (al>="0" && al<="9") || (al>="A" && al<="F") || (al>="a" && al<="f") || al==VK_BACK 
            .if al>="a" && al<="f" 
                sub al,20h 
            .endif 
            invoke CallWindowProc,OldWndProc,hEdit,uMsg,eax,lParam 
            ret 
        .endif
Within EditWndProc, we filter WM_CHAR messages. If the character is between 0-9 or a-f, we accept it by 
passing along the message to the original window procedure. If it is a lower case character, we convert it 
to upper case by adding it with 20h. Note that, if the character is not the one we expect, we discard it. 
We don't pass it to the original window proc. So when the user types something other than 0-9 or a-f, the 
character just doesn't appear in the edit control. 
    .elseif uMsg==WM_KEYDOWN 
        mov eax,wParam 
        .if al==VK_RETURN 
            invoke MessageBox,hEdit,addr Message,addr AppName,MB_OK+MB_ICONINFORMATION 
            invoke SetFocus,hEdit 
        .else 
            invoke CallWindowProc,OldWndProc,hEdit,uMsg,wParam,lParam 
            ret 
        .end
I want to demonstrate the power of subclassing further by trapping Enter key. EditWndProc checks WM_KEYDOWN 
message if it's VK_RETURN (the Enter key). If it is, it displays a message box saying "You pressed the Enter 
key in the text box!". If it's not an Enter key, it passes the message to the original window procedure. 
You can use window subclassing to take control over other windows. It's one of the powerful techniques you 
should have in your arsenal.

Unfortunately you can't run Java applets  


Tutorial 21: Pipe
  
     In this tutorial, we will explore pipe, what it is and what we can use it for. To make it more interesting, 
     I throw in the technique on how to change the background and text color of an edit control. 
     Theory:
     Pipe is a communication conduit or pathway with two ends. You can use pipe to exchange the data between two 
     different processes, or within the same process. It's like a walkie-talkie. You give the other party one set 
     and he can use it to communicate with you. 
     There are two types of pipes: anonymous and named pipes. Anonymous pipe is, well, anonymous: that is, you can
     use it without knowing its name. A named pipe is the opposite: you have to know its name before you can use it. 
     You can also categorize pipes according to its property: one-way or two-way. In a one-way pipe, the data can 
     flow only in one direction: from one end to the other. While in a two-way pipe, the data can be exchanged between 
     both ends. 
     An anonymous pipe is always one-way while a named pipe can be one-way or two-way. A named pipe is usually used
     in a network environment where a server can connect to several clients. 
     In this tutorial, we will examine anonymous pipe in some detail. Anonymous pipe's main purpose is to be used 
     as a communcation pathway between a parent and child processes or between child processes. 
     Anonymous pipe is really useful when you deal with a console application. A console application is a kind of 
     win32 program which uses a console for its input & output. A console is like a DOS box. However, a console 
     application is a fully 32-bit program. It can use any GUI function, the same as other GUI programs. It just 
     happens to have a console for its use. 
     A console application has three handles it can use for its input & output. They are called standard handles. 
     There are three of them: standard input, standard output and standard error. Standard input handle is used to
     read/retrieve the information from the console and standard output handle is used to output/print the 
     information to the console. Standard error handle is used to report error condition since its output cannot 
     be redirected. 
     A console application can retrieve those three standard handles by calling GetStdHandle function, specifying 
     the handle it wants to obtain. A GUI application doesn't have a console. If you call GetStdHandle, it will 
     return error. If you really want to use a console, you can call AllocConsole to allocate a new console.
     However, don't forget to call FreeConsole when you're done with the console. 
     Anonymous pipe is most frequently used to redirect input and/or output of a child console application.
     The parent process may be a console or a GUI application but the child must be a console app. for this 
     to work. As you know, a console application uses standard handles for its input and output. If we want 
     to redirect the input and/or output of a console application, we can replace the handle with a handle 
     to one end of a pipe. A console application will not know that it's using a handle to one end of a pipe.
     It'll use it as a standard handle. This is a kind of polymorphism, in OOP jargon. This approach is powerful 
     since we need not modify the child process in anyway. 
     Another thing you should know about a console application is where it gets those standard handles from.
     When a console application is created, the parent process has two choices: it can create a new console 
     for the child or it can let the child inherit its own console. For the second approach to work, the parent
     process must be a console application or if it's a GUI application, it must call AllocConsole first to
     allocate a console. 
Let's begin the work. In order to create an anonymous pipe you need to call CreatePipe. CreatePipe has the 
following prototype: 
CreatePipe proto pReadHandle:DWORD, \ 
       pWriteHandle:DWORD,\ 
       pPipeAttributes:DWORD,\ 
       nBufferSize:DWORD
     pReadHandle is a pointer to a dword variable that will receive the handle to the read end of the pipe 
     pWriteHandle is a pointer to a dword variable that will receive the handle to the write end of the pipe. 
     pPipeAttributes points to a SECURITY_ATTRIBUTES structure that determines whether the returned read & write 
     handles are inheritable by child processes 
     nBufferSize is the suggested size of the buffer the pipe will reserve for use. This is a suggested size only.
     You can use NULL to tell the function to use the default size. 
     If the call is successful, the return value is nonzero. If it failed, the return value is zero. 
     After the call is successful, you will get two handles, one to read end of the pipe and the other to the write
     end. Now I will outline the steps needed for redirecting the standard output of a child console program to 
     your own process.Note that my method differs from the one in Borland's win32 api reference. The method in 
     win32 api reference assumes the parent process is a console application and thus the child can inherit the 
     standard handles from it. But most of the time, we will need to redirect output from a console application 
     to a GUI one. 
     Create an anonymous pipe with CreatePipe. Don't forget to set the bInheritable member of SECURITY_ATTRIBUTES 
     to TRUE so the handles are inheritable. 
     Now we must prepare the parameters we will pass to CreateProcess since we will use it to load the child console
     application. One important structure is the STARTUPINFO structure. This structure determines the appearance of
     the main window of the child process when it first appears. This structure is vital to our purpose. You can 
     hide the main window and pass the pipe handle to the child console process with it. Below is the members you 
     must fill: 
     cb : the size of STARTUPINFO structure 
     dwFlags : the binary bit flags that determine which members of the structure are valid also it governs the 
     show/hide state of the main window. For our purpose, you should use a combination of STARTF_USESHOWWINDOW 
     and STARTF_USESTDHANDLES 
     hStdOutput and hStdError : the handles you want the child process to use as standard output/error handles. 
     For our purpose, we will pass write handle of the pipe as the standard output and error of the child. 
     So when the child outputs something to the standard output/error, it actually passes the info via the pipe 
     to the parent process. 
     wShowWindow governs the show/hide state of the main window. For our purpose, we don't want the console window 
     of the child to show so we put SW_HIDE into this member. 
     Call CreateProcess to load the child application. After CreateProcess is successful, the child is still dormant.
     It is loaded into memory but it doesn't run immediately 
     Close the write pipe handle. This is necessary. Because the parent process has no use for the write pipe handle
     , and the pipe won't work if there are more than one write end, we MUST close it before reading the data from 
     the pipe. However, don't close the write handle before calling CreateProcess, your pipe will be broken. 
     You should close it just after CreateProcess returns and before you read data from the read end of the pipe. 
     Now you can read data from the read end of the pipe with ReadFile. With ReadFile, you kick the child process 
     into running mode. It will start execution and when it writes something to the standard output handle 
     (which is actually the handle to the write end of the pipe), the data are sent through the pipe to the 
     read end. You can think of ReadFile as sucking data from the read end of the pipe. You must call ReadFile 
     repeatedly until it returns 0 which means there are no more data to be read. You can do anything with the 
     data you read from the pipe. In our example, I put them into an edit control. 
Close the read pipe handle. 
Example:
.386 
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\gdi32.inc 
includelib \Masm32\lib\gdi32.lib 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD 

.const 
IDR_MAINMENU equ 101         ; the ID of the main menu 
IDM_ASSEMBLE equ 40001 

.data 
ClassName            db "PipeWinClass",0 
AppName              db "One-way Pipe Example",0 EditClass db "EDIT",0 
CreatePipeError     db "Error during pipe creation",0 
CreateProcessError     db "Error during process creation",0 
CommandLine     db "ml /c /coff /Cp test.asm",0 

.data? 
hInstance HINSTANCE ? 
hwndEdit dd ? 

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov hInstance,eax 
    invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

WinMain proc hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov wc.cbSize,SIZEOF WNDCLASSEX 
    mov wc.style, CS_HREDRAW or CS_VREDRAW mov wc.lpfnWndProc, OFFSET WndProc 
    mov wc.cbClsExtra,NULL 
    mov wc.cbWndExtra,NULL 
    push hInst 
    pop wc.hInstance 
    mov wc.hbrBackground,COLOR_APPWORKSPACE 
    mov wc.lpszMenuName,IDR_MAINMENU 
    mov wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov wc.hIcon,eax 
    mov wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\ WS_OVERLAPPEDWINDOW+WS_VISIBLE,CW_USEDEFAULT,\ CW_USEDEFAULT,400,200,NULL,NULL,\ hInst,NULL 
    mov hwnd,eax 
    .while TRUE 
        invoke GetMessage, ADDR msg,NULL,0,0 
        .BREAK .IF (!eax) 
        invoke TranslateMessage, ADDR msg 
        invoke DispatchMessage, ADDR msg 
    .endw 
    mov eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    LOCAL rect:RECT 
    LOCAL hRead:DWORD 
    LOCAL hWrite:DWORD 
    LOCAL startupinfo:STARTUPINFO 
    LOCAL pinfo:PROCESS_INFORMATION 
    LOCAL buffer[1024]:byte 
    LOCAL bytesRead:DWORD 
    LOCAL hdc:DWORD 
    LOCAL sat:SECURITY_ATTRIBUTES 
    .if uMsg==WM_CREATE 
        invoke CreateWindowEx,NULL,addr EditClass, NULL, WS_CHILD+ WS_VISIBLE+ ES_MULTILINE+ ES_AUTOHSCROLL+ ES_AUTOVSCROLL, 0, 0, 0, 0, hWnd, NULL, hInstance, NULL 
        mov hwndEdit,eax 
    .elseif uMsg==WM_CTLCOLOREDIT 
        invoke SetTextColor,wParam,Yellow 
        invoke SetBkColor,wParam,Black 
       invoke GetStockObject,BLACK_BRUSH 
        ret 
    .elseif uMsg==WM_SIZE 
        mov edx,lParam 
        mov ecx,edx 
        shr ecx,16 
        and edx,0ffffh 
        invoke MoveWindow,hwndEdit,0,0,edx,ecx,TRUE 
    .elseif uMsg==WM_COMMAND 
       .if lParam==0 
            mov eax,wParam 
            .if ax==IDM_ASSEMBLE 
                mov sat.nLength,sizeof SECURITY_ATTRIBUTES 
                mov sat.lpSecurityDescriptor,NULL 
                mov sat.bInheritHandle,TRUE 
                invoke CreatePipe,addr hRead,addr hWrite,addr sat,NULL 
                .if eax==NULL 
                    invoke MessageBox, hWnd, addr CreatePipeError, addr AppName, MB_ICONERROR+ MB_OK 
                .else 
                    mov startupinfo.cb,sizeof STARTUPINFO 
                    invoke GetStartupInfo,addr startupinfo 
                    mov eax, hWrite 
                    mov startupinfo.hStdOutput,eax 
                    mov startupinfo.hStdError,eax 
                    mov startupinfo.dwFlags, STARTF_USESHOWWINDOW+ STARTF_USESTDHANDLES 
                    mov startupinfo.wShowWindow,SW_HIDE 
                    invoke CreateProcess, NULL, addr CommandLine, NULL, NULL, TRUE, NULL, NULL, NULL, addr startupinfo, addr pinfo 
                    .if eax==NULL 
                        invoke MessageBox,hWnd,addr CreateProcessError,addr         AppName,MB_ICONERROR+MB_OK 
                    .else 
                        invoke CloseHandle,hWrite 
                        .while TRUE 
                            invoke RtlZeroMemory,addr buffer,1024 
                            invoke ReadFile,hRead,addr buffer,1023,addr bytesRead,NULL 
                            .if eax==NULL 
                                .break 
                            .endif 
                            invoke SendMessage,hwndEdit,EM_SETSEL,-1,0 
                            invoke SendMessage,hwndEdit,EM_REPLACESEL,FALSE,addr buffer 
                        .endw 
                    .endif 
                    invoke CloseHandle,hRead 
                .endif 
            .endif 
        .endif 
    .elseif uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .else 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam ret 
    .endif 
    xor eax,eax 
    ret 
WndProc endp 
end start

Analysis:
     The example will call ml.exe to assemble a file named test.asm and redirect the output of ml.exe to the edit 
     control in its client area. 
     When the program is loaded, it registers the window class and creates the main window as usual. The first 
     thing it does during main window creation is to create an edit control which will be used to display the 
     output of ml.exe. 
     Now the interesting part, we will change the text and background color of the edit control. When an edit 
     control is going to paint its client area, it sends WM_CTLCOLOREDIT message to its parent. 
     wParam contains the handle to the device context that the edit control will use to write its own client area.
     We can use this opportunity to modify the characteristics of the HDC. 
     .elseif uMsg==WM_CTLCOLOREDIT 
        invoke SetTextColor,wParam,Yellow 
        invoke SetTextColor,wParam,Black 
        invoke GetStockObject,BLACK_BRUSH 
        ret
     SetTextColor changes the text color to yellow. SetTextColor changes the background color of the text to black.
     And lastly, we obtain the handle to the black brush which we return to Windows. With WM_CTLCOLOREDIT message,
     you must return a handle to a brush which Windows will use to paint the background of the edit control. 
     In our example, I want the background to be black so I return the handle to the black brush to Windows. 
     Now when the user selects Assemble menuitem, it creates an anonymous pipe. 
            .if ax==IDM_ASSEMBLE 
                mov sat.nLength,sizeof SECURITY_ATTRIBUTES 
                mov sat.lpSecurityDescriptor,NULL 
                mov sat.bInheritHandle,TRUE 

     Prior to calling CreatePipe, we must fill the SECURITY_ATTRIBUTES structure first. Note that we can use NULL 
     in lpSecurityDescriptor member if we don't care about security. And the bInheritHandle member must be TRUE so
     that the pipe handles are inheritable to the child process. 
     
               invoke CreatePipe,addr hRead,addr hWrite,addr sat,NULL 
     
     After that, we call CreatePipe which, if successful, will fill hRead and hWrite variables with the handles 
     to read and write ends of the pipe respectively. 

                    mov startupinfo.cb,sizeof STARTUPINFO 
                    invoke GetStartupInfo,addr startupinfo 
                    mov eax, hWrite 
                    mov startupinfo.hStdOutput,eax 
                    mov startupinfo.hStdError,eax 
                    mov startupinfo.dwFlags, STARTF_USESHOWWINDOW+ STARTF_USESTDHANDLES 
                    mov startupinfo.wShowWindow,SW_HIDE 

     Next we must fill the STARTUPINFO structure. We call GetStartupInfo to fill the STARTUPINFO structure with 
     default values of the parent process. You MUST fill the STARTUPINFO structure with this call if you intend 
     your code to work under both win9x and NT. After GetStartupInfo call returns, you can modify the members 
     that are important. We copy the handle to the write end of the pipe into hStdOutput and hStdError since we 
     want the child process to use it instead of the default standard output/error handles. We also want to hide 
     the console window of the child process, so we put SW_HIDE value into wShowWidow member. And lastly, we must
     indicate that hStdOutput, hStdError and wShowWindow members are valid and must be used by specifying the 
     flags STARTF_USESHOWWINDOW and STARTF_USESTDHANDLES in dwFlags member. 
     
                   invoke CreateProcess, NULL, addr CommandLine, NULL, NULL, TRUE, NULL, NULL, NULL, addr 
                   startupinfo, addr pinfo 
     
     We now create the child process with CreateProcess call. Note that the bInheritHandles parameter must be 
     set to TRUE for the pipe handle to work. 
     
                       invoke CloseHandle,hWrite 
     
     After we successfully create the child process, we must close the write end of the pipe. Remember that we 
     passed the write handle to the child process via STARTUPINFO structure. If we don't close the write handle
      
     from our end, there will be two write ends. And that the pipe will not work. We must close the write 
     handle
     after CreateProcess but before we read data from the read end of the pipe. 

                        .while TRUE 
                            invoke RtlZeroMemory,addr buffer,1024 
                            invoke ReadFile,hRead,addr buffer,1023,addr bytesRead,NULL 
                            .if eax==NULL 
                                .break 
                            .endif 
                            invoke SendMessage,hwndEdit,EM_SETSEL,-1,0 
                            invoke SendMessage,hwndEdit,EM_REPLACESEL,FALSE,addr buffer 
                        .endw 

     Now we are ready to read the data from the standard output of the child process. We will stay in an infinite 
     loop until there are no more data left to read from the pipe. We call RtlZeroMemory to fill the buffer with 
     zeroes then call ReadFile, passing the read handle of the pipe in place of a file handle. Note that we only
     read a maximum of 1023 bytes since we need the data to be an ASCIIZ string which we can pass on to the edit 
     control. 
     When ReadFile returns with the data in the buffer, we fill the data into the edit control. However, there is 
     a slight problem here. If we use SetWindowText to put the data into the edit control, the new data will 
     overwrite existing data! We want the data to append to the end of the existing data. 
     To achieve that goal, we first move the caret to the end of the text in the edit control by sending EM_SETSEL 
     message with wParam==-1. Next, we append the data at that point with EM_REPLACESEL message. 

                   invoke CloseHandle,hRead 

When ReadFile returns NULL, we break out of the loop and close the read handle.


Unfortunately you can't run Java applets  


Tutorial 22: Superclassing
  
     In this tutorial, we will learn about superclassing, what it is and what it is for. You will also learn how 
     to provide Tab key navigation to the controls in your own window. 
     Theory:
     In your programming career, you will surely encounter a situation where you need several controls with 
     *slightly* different behavior. For example, you may need 10 edit controls which accept only number. 
     There are several ways to achieve that goal: 
     Create your own class and instantiate the controls 
     Create those edit control and then subclass all of them 
     Superclass the edit control 
     The first method is too tedious. You have to implement every functionality of the edit control yourself. 
     Hardly a task to be taken lightly. The second method is better than the first one but still too much work.
     It is ok if you subclass only a few controls but it's going to be a nightmare to subclass a dozen or so 
     controls. Superclassing is the technique you should use for this occasion. 
     Subclassing is the method you use to *take control* of a particular window class. By *taking control*, 
     I mean you can modify the properties of the window class to suit your purpose then then create the bunch 
     of controls. 
     The steps in superclassing is outlined below: 
     call GetClassInfoEx to obtain the information about the window class you want to superclass. GetClassInfoEx 
     requires a pointer to a WNDCLASSEX structure which will be filled with the information if the call returns 
     successfully. 
     Modify the WNDCLASSEX members that you want. However, there are two members which you MUST modify: 
     hInstance  You must put the instance handle of your program into this member. 
     lpszClassName  You must provide it with a pointer to a new class name. 
     You need not modify lpfnWndProc member but most of the time, you need to do it. Just remember to save the 
     original lpfnWndProc member if you want to call it with CallWindowProc.
     Register the modifed WNDCLASSEX structure. You'll have a new window class which has several characteristics 
     of the old window class. 
     Create windows from the new class 
     Superclassing is better than subclassing if you want to create many controls with the same characteristics. 
Example:
.386 
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
WM_SUPERCLASS equ WM_USER+5 
WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD 
EditWndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD 

.data 
ClassName  db "SuperclassWinClass",0 
AppName    db "Superclassing Demo",0 
EditClass  db "EDIT",0 
OurClass db "SUPEREDITCLASS",0 
Message  db "You pressed the Enter key in the text box!",0 

.data? 
hInstance dd ? 
hwndEdit dd 6 dup(?) 
OldWndProc dd ? 

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 

    mov wc.cbSize,SIZEOF WNDCLASSEX 
    mov wc.style, CS_HREDRAW or CS_VREDRAW 
    mov wc.lpfnWndProc, OFFSET WndProc 
    mov wc.cbClsExtra,NULL 
    mov wc.cbWndExtra,NULL 
    push hInst 
    pop wc.hInstance 
    mov wc.hbrBackground,COLOR_APPWORKSPACE 
    mov wc.lpszMenuName,NULL 
    mov wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov wc.hIcon,eax 
    mov wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,WS_EX_CLIENTEDGE+WS_EX_CONTROLPARENT,ADDR ClassName,ADDR AppName,\ 
        WS_OVERLAPPED+WS_CAPTION+WS_SYSMENU+WS_MINIMIZEBOX+WS_MAXIMIZEBOX+WS_VISIBLE,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,350,220,NULL,NULL,\ 
           hInst,NULL 
    mov hwnd,eax 

    .while TRUE 
        invoke GetMessage, ADDR msg,NULL,0,0 
        .BREAK .IF (!eax) 
        invoke TranslateMessage, ADDR msg 
        invoke DispatchMessage, ADDR msg 
    .endw 
     mov eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc uses ebx edi hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    LOCAL wc:WNDCLASSEX 
    .if uMsg==WM_CREATE 
        mov wc.cbSize,sizeof WNDCLASSEX 
        invoke GetClassInfoEx,NULL,addr EditClass,addr wc 
        push wc.lpfnWndProc 
        pop OldWndProc 
        mov wc.lpfnWndProc, OFFSET EditWndProc 
        push hInstance 
        pop wc.hInstance 
        mov wc.lpszClassName,OFFSET OurClass 
        invoke RegisterClassEx, addr wc 
        xor ebx,ebx 
        mov edi,20 
        .while ebx<6 
            invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR OurClass,NULL,\ 
                 WS_CHILD+WS_VISIBLE+WS_BORDER,20,\ 
                 edi,300,25,hWnd,ebx,\ 
                 hInstance,NULL 
            mov dword ptr [hwndEdit+4*ebx],eax 
            add edi,25 
            inc ebx 
        .endw 
        invoke SetFocus,hwndEdit 
    .elseif uMsg==WM_DESTROY 
        invoke PostQuitMessage,NULL 
    .else 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .endif 
    xor eax,eax 
    ret 
WndProc endp 

EditWndProc PROC hEdit:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 
    .if uMsg==WM_CHAR 
        mov eax,wParam 
        .if (al>="0" && al<="9") || (al>="A" && al<="F") || (al>="a" && al<="f") || al==VK_BACK 
            .if al>="a" && al<="f" 
               sub al,20h 
            .endif 
            invoke CallWindowProc,OldWndProc,hEdit,uMsg,eax,lParam 
            ret 
        .endif 
    .elseif uMsg==WM_KEYDOWN 
        mov eax,wParam 
        .if al==VK_RETURN 
            invoke MessageBox,hEdit,addr Message,addr AppName,MB_OK+MB_ICONINFORMATION 
            invoke SetFocus,hEdit 
        .elseif al==VK_TAB 
            invoke GetKeyState,VK_SHIFT 
            test eax,80000000 
            .if ZERO? 
                invoke GetWindow,hEdit,GW_HWNDNEXT 
                .if eax==NULL 
                    invoke GetWindow,hEdit,GW_HWNDFIRST 
                .endif 
            .else 
                invoke GetWindow,hEdit,GW_HWNDPREV 
                .if eax==NULL 
                    invoke GetWindow,hEdit,GW_HWNDLAST 
                .endif 
            .endif 
            invoke SetFocus,eax 
            xor eax,eax 
            ret 
        .else 
            invoke CallWindowProc,OldWndProc,hEdit,uMsg,wParam,lParam 
            ret 
        .endif 
    .else 
        invoke CallWindowProc,OldWndProc,hEdit,uMsg,wParam,lParam 
        ret 
    .endif 
    xor eax,eax 
    ret 
EditWndProc endp 
end start 
  

Analysis:
     The program will create a simple window with 6 "modified" edit controls in its client area. The edit controls 
     will accept only hex digits. Actually, I modified the subclassing example to do superclassing. The program 
     starts normally and the interesting part is when the main window is created: 
     .if uMsg==WM_CREATE 
         mov wc.cbSize,sizeof WNDCLASSEX 
        invoke GetClassInfoEx,NULL,addr EditClass,addr wc 
     
     We must first fill the WNDCLASSEX structure with the data from the class which we want to superclass, 
     in this case, it's EDIT class. Remember that you must set the cbSize member of the WNDCLASSEX structure 
     before you call GetClassInfoEx else the WNDCLASSEX structure will not be filled properly. 
     After GetClassInfoEx returns, wc is filled with all information we need to create a new window class. 
     
        push wc.lpfnWndProc 
        pop OldWndProc 
        mov wc.lpfnWndProc, OFFSET EditWndProc 
        push hInstance 
        pop wc.hInstance 
        mov wc.lpszClassName,OFFSET OurClass 
     
     Now we must modify some members of wc. The first one is the pointer to the window procedure. 
     Since we need to chain our own window procedure with the original one, we have to save it into a variable so
     we can call it with CallWindowProc. This technique is identical to subclassing except that you modify the 
     WNDCLASSEX structure directly without having to call SetWindowLong. The next two members must be changed 
     else you will not be able to register your new window class, hInstance and lpsClassName. You must replace 
     original hInstance value with hInstance of your own program. And you must choose a new name for the new class. 


        invoke RegisterClassEx, addr wc 

	When all is ready, register the new class. You will get a new class with some characteristics of the old 
	class. 

        xor ebx,ebx 
        mov edi,20 
        .while ebx<6 
            invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR OurClass,NULL,\ 
                 WS_CHILD+WS_VISIBLE+WS_BORDER,20,\ 
                 edi,300,25,hWnd,ebx,\ 
                 hInstance,NULL 
            mov dword ptr [hwndEdit+4*ebx],eax 
            add edi,25 
            inc ebx 
        .endw 
        invoke SetFocus,hwndEdit 

     Now that we registered the class, we can create windows based on it. In the above snippet, I use ebx as the
     counter of the number of windows created. edi is used as the y coordinate of the left upper corner of the 
     window. When a window is created, its handle is stored in the array of dwords. When all windows are created, 
     set input focus to the first window. 
     At this point, you got 6 edit controls which accept only hex digits. The substituted window proc handles the 
     filter. Actually, it's identical to the window proc in subclassing example. As you can see, you don't have to 
     do extra work of subclassing them. 
     
     I throw in a code snippet to handle control navigation with tabs to make this example more juicy. Normally, 
     if you put controls on a dialog box, the dialog box manager handles the navigation keys for you so you can tab 
     to go to the next control or shift-tab to go back to the previous control. Alas, such feature is not available 
     if you put your controls on a simple window. You have to subclass them so you can handle the Tab keys yourself.
     In our example, we need not subclass the controls one by one because we already superclassed them, so we can
     provide a "central control navigation manager" for them. 
  

        .elseif al==VK_TAB 
            invoke GetKeyState,VK_SHIFT 
            test eax,80000000 
            .if ZERO? 
                invoke GetWindow,hEdit,GW_HWNDNEXT 
                .if eax==NULL 
                    invoke GetWindow,hEdit,GW_HWNDFIRST 
                .endif 
            .else 
                invoke GetWindow,hEdit,GW_HWNDPREV 
                .if eax==NULL 
                    invoke GetWindow,hEdit,GW_HWNDLAST 
                .endif 
            .endif 
            invoke SetFocus,eax 
            xor eax,eax 
            ret 

     The above code snippet is from EditWndClass procedure. It checks if the user press Tab key, if so, it call
     GetKeyState to check if  the SHIFT key is also pressed. GetKeyState returns a value in eax that determines 
     whether the specified key is pressed or not. If the key is pressed, the high bit of eax is set. If not, 
     the high bit is clear. So we test the return value against 80000000h. If the high bit is set, it means 
     the user pressed shift+tab which we must handle separately. 
     If the user press Tab key alone, we call GetWindow to retrieve the handle of the next control. We use 
     GW_HWNDNEXT flag to tell GetWindow to obtain the handle to the window that is next in line to the current
     hEdit. If this function returns NULL, we interpret it as no more handle to obtain so the current hEdit is 
     the last control in the line. We will "wrap around" to the first control by calling GetWindow with GW_HWNDFIRST
     flag. Similar to the Tab case, shift-tab just works in reverse.




Tutorial 23: Tray Icon
  
     In this tutorial, we will learn how to put icons into system tray and how to create/use a popup menu. 
     Theory:
     System tray is the rectangular region in the taskbar where several icons reside. Normally, you'll see at le
     cbSize   The size of this structure. 
     hwnd  Handle of the window that will receive notification when a mouse event occurs over the tray icon. 
     uID A constant that is used as the icon's identifier. You are the one who decides on this value.
      In case you have more than one tray icons, you will be able to check from what tray icon the mouse
       notification is from. 
     uFlags    Specify which members of this structure are valid 
     NIF_ICON The hIcon member is valid. 
     NIF_MESSAGE The uCallbackMessage member is valid. 
     NIF_TIP The szTip member is valid. 
     uCallbackMessage  The custom message that Windows will send to the window specified by the hwnd member
      when mouse events occur over the tray icon. You create this message yourself. 
     hIcon      The handle of the icon you want to put into the system tray 
     szTip       A 64-byte array that contains the string that will be used as the tooltip text when the mouse
      hovers over the tray icon. 
     Call Shell_NotifyIcon which is defined in shell32.inc. This function has the following prototype: 

            Shell_NotifyIcon PROTO dwMessage:DWORD ,pnid:DWORD 

    dwMessage  is the type of message to send to the shell. 
           NIM_ADD Adds an icon to the status area. 
          NIM_DELETE Deletes an icon from the status area. 
          NIM_MODIFY Modifies an icon in the status area. 
    pnid  is the pointer to a NOTIFYICONDATA structure filled with proper values 
If you want to add an icon to the tray, use NIM_ADD message, if you want to remove the icon, use NIM_DELETE.

     That's all there is to it. But most of the time, you're not content in just putting an icon there. You need 
     to be able to respond to the mouse events over the tray icon. You can do this by processing the message you 
     specified in uCallbackMessage member of NOTIFYICONDATA structure. This message has the following values 
     in wParam and lParam (special thanks to s__d for the info): 
     wParam contains the ID of the icon. This is the same value you put into uID member of NOTIFYICONDATA structure.
     
     lParam  The low word contains the mouse message. For example, if the user right-clicked at the icon, 
     lParam will contain WM_RBUTTONDOWN. 
     Most tray icon, however, displays a popup menu when the user right-click on it. We can implement this feature 
     by creating a popup menu and then call TrackPopupMenu to display it. The steps are described below: 
     Create a popup menu by calling CreatePopupMenu. This function creates an empty menu. It returns the menu
     handle in eax if successful. 
     Add menu items to it with AppendMenu, InsertMenu or InsertMenuItem. 
     When you want to display the popup menu where the mouse cursor is, call GetCursorPos to obtain the screen 
     coordinate of the cursor and then call TrackPopupMenu to display the menu. When the user selects a menu item 
     from the popup menu, Windows sends WM_COMMAND message to your window procedure just like normal menu selection.
     
     Note: Beware of two annoying behaviors when you use a popup menu with a tray icon: 
     When the popup menu is displayed, if you click anywhere outside the menu, the popup menu will not disappear 
     immediately as it should be. This behavior occurs because the window that will receive the notifications from 
     the popup menu MUST be the foreground window. Just call SetForegroundWindow will correct it. 
     After calling SetForegroundWindow, you will find that the first time the popup menu is displayed, it works ok 
     but on the subsequent times, the popup menu will show up and close immediately. This behavior is 
     "intentional", to quote from MSDN. The task switch to the program that is the owner of the tray icon in the near future is necessary. You can force this task switch by posting any message to the window of the program. Just use PostMessage, not SendMessage! 
     Example:
.386 
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\shell32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
includelib \Masm32\lib\shell32.lib 
WM_SHELLNOTIFY equ WM_USER+5 
IDI_TRAY equ 0 
IDM_RESTORE equ 1000 
IDM_EXIT equ 1010 
WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD 

.data 
ClassName  db "TrayIconWinClass",0 
AppName    db "TrayIcon Demo",0 
RestoreString db "&Restore",0 
ExitString   db "E&xit Program",0 

.data? 
hInstance dd ? 
note NOTIFYICONDATA <> 
hPopupMenu dd ? 

.code 
start: 
    invoke GetModuleHandle, NULL 
    mov    hInstance,eax 
    invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT 
    invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX 
    LOCAL msg:MSG 
    LOCAL hwnd:HWND 
    mov   wc.cbSize,SIZEOF WNDCLASSEX 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInst 
    pop   wc.hInstance 
    mov   wc.hbrBackground,COLOR_APPWORKSPACE 
    mov   wc.lpszMenuName,NULL 
    mov   wc.lpszClassName,OFFSET ClassName 
    invoke LoadIcon,NULL,IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor,NULL,IDC_ARROW 
    mov   wc.hCursor,eax 
    invoke RegisterClassEx, addr wc 
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR ClassName,ADDR AppName,\ 
WS_OVERLAPPED+WS_CAPTION+WS_SYSMENU+WS_MINIMIZEBOX+WS_MAXIMIZEBOX+WS_VISIBLE,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,350,200,NULL,NULL,\ 
           hInst,NULL 
    mov   hwnd,eax 
    .while TRUE 
        invoke GetMessage, ADDR msg,NULL,0,0 
        .BREAK .IF (!eax) 
        invoke TranslateMessage, ADDR msg 
        invoke DispatchMessage, ADDR msg 
    .endw 
    mov eax,msg.wParam 
    ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    LOCAL pt:POINT 
    .if uMsg==WM_CREATE 
        invoke CreatePopupMenu 
        mov hPopupMenu,eax 
        invoke AppendMenu,hPopupMenu,MF_STRING,IDM_RESTORE,addr RestoreString 
        invoke AppendMenu,hPopupMenu,MF_STRING,IDM_EXIT,addr ExitString 
    .elseif uMsg==WM_DESTROY 
        invoke DestroyMenu,hPopupMenu 
        invoke PostQuitMessage,NULL 
    .elseif uMsg==WM_SIZE 
        .if wParam==SIZE_MINIMIZED 
            mov note.cbSize,sizeof NOTIFYICONDATA 
            push hWnd 
            pop note.hwnd 
            mov note.uID,IDI_TRAY 
            mov note.uFlags,NIF_ICON+NIF_MESSAGE+NIF_TIP 
            mov note.uCallbackMessage,WM_SHELLNOTIFY 
            invoke LoadIcon,NULL,IDI_WINLOGO 
            mov note.hIcon,eax 
            invoke lstrcpy,addr note.szTip,addr AppName 
            invoke ShowWindow,hWnd,SW_HIDE 
            invoke Shell_NotifyIcon,NIM_ADD,addr note 
        .endif 
    .elseif uMsg==WM_COMMAND 
        .if lParam==0 
            invoke Shell_NotifyIcon,NIM_DELETE,addr note 
            mov eax,wParam 
            .if ax==IDM_RESTORE 
                invoke ShowWindow,hWnd,SW_RESTORE 
            .else 
                invoke DestroyWindow,hWnd 
            .endif 
        .endif 
    .elseif uMsg==WM_SHELLNOTIFY 
        .if wParam==IDI_TRAY 
            .if lParam==WM_RBUTTONDOWN 
                invoke GetCursorPos,addr pt 
                invoke SetForegroundWindow,hWnd 
                invoke TrackPopupMenu,hPopupMenu,TPM_RIGHTALIGN,pt.x,pt.y,NULL,hWnd,NULL 
                invoke PostMessage,hWnd,WM_NULL,0,0 
            .elseif lParam==WM_LBUTTONDBLCLK 
                invoke SendMessage,hWnd,WM_COMMAND,IDM_RESTORE,0 
            .endif 
        .endif 
    .else 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
        ret 
    .endif 
    xor eax,eax 
    ret 
WndProc endp 

end start 
  

Analysis:
     The program will display a simple window. When you press the minimize button, it will hide itself and put an 
     icon into the system tray. When you double-click on the icon, the program will restore itself and remove the 
     icon from the system tray. When you right-click on it, a popup menu is displayed. You can choose to restore 
     the program or exit it. 
     .if uMsg==WM_CREATE 
        invoke CreatePopupMenu 
        mov hPopupMenu,eax 
        invoke AppendMenu,hPopupMenu,MF_STRING,IDM_RESTORE,addr RestoreString 
        invoke AppendMenu,hPopupMenu,MF_STRING,IDM_EXIT,addr ExitString 
     
     When the main window is created, it creates a popup menu and append two menu items. AppendMenu has the 
     following syntax: 
     
     
     AppendMenu PROTO hMenu:DWORD, uFlags:DWORD, uIDNewItem:DWORD, lpNewItem:DWORD 
     
     hMenu is the handle of the menu you want to append the item to 
     uFlags tells Windows about the menu item to be appended to the menu whether it is a bitmap or a string or an 
     owner-draw item, enabled, grayed or disable etc. You can get the complete list from win32 api reference.
     In our example, we use MF_STRING which means the menu item is a string. 
     uIDNewItem is the ID of the menu item. This is a user-defined value that is used to represent the menu item. 
     lpNewItem specifies the content of the menu item, depending on what you specify in uFlags member. Since we 
     specify MF_STRING in uFlags member, lpNewItem must contain the pointer to the string to be displayed in the
     popup menu. 
     After the popup menu is created, the main window waits patiently for the user to press minimize button. 
     When a window is minimized, it receives WM_SIZE message with SIZE_MINIMIZED value in wParam. 
     .elseif uMsg==WM_SIZE 
        .if wParam==SIZE_MINIMIZED 
            mov note.cbSize,sizeof NOTIFYICONDATA 
            push hWnd 
            pop note.hwnd 
            mov note.uID,IDI_TRAY 
            mov note.uFlags,NIF_ICON+NIF_MESSAGE+NIF_TIP 
            mov note.uCallbackMessage,WM_SHELLNOTIFY 
            invoke LoadIcon,NULL,IDI_WINLOGO 
            mov note.hIcon,eax 
            invoke lstrcpy,addr note.szTip,addr AppName 
            invoke ShowWindow,hWnd,SW_HIDE 
            invoke Shell_NotifyIcon,NIM_ADD,addr note 
        .endif 

     We use this opportunity to fill NOTIFYICONDATA structure. IDI_TRAY is just a constant defined at the beginning 
     of the source code. You can set it to any value you like. It's not important because you have only one tray 
     icon. But if you will put several icons into the system tray, you need unique IDs for each tray icon. 
     We specify all flags in uFlags member because we specify an icon (NIF_ICON), we specify a custom message 
     (NIF_MESSAGE) and we specify the tooltip text (NIF_TIP). WM_SHELLNOTIFY is just a custom message defined as 
     WM_USER+5. The actual value is not important so long as it's unique. I use the winlogo icon as the tray icon
     here but you can use any icon in your program. Just load it from the resource with LoadIcon and put the 
     returned handle in hIcon member. Lastly, we fill the szTip with the text we want the shell to display when 
     the mouse is over the icon. 
     We hide the main window to give the illusion of "minimizing-to-tray-icon" appearance. 
     Next we call Shell_NotifyIcon  with NIM_ADD message to add the icon to the system tray. 
     
     Now our main window is hidden and the icon is in the system tray. If you move the mouse over it, you will see 
     a tooltip that displays the text we put into szTip member. Next, if you double-click at the icon, the main
     window will reappear and the tray icon is gone. 

    .elseif uMsg==WM_SHELLNOTIFY 
        .if wParam==IDI_TRAY 
            .if lParam==WM_RBUTTONDOWN 
                invoke GetCursorPos,addr pt 
                invoke SetForegroundWindow,hWnd 
                invoke TrackPopupMenu,hPopupMenu,TPM_RIGHTALIGN,pt.x,pt.y,NULL,hWnd,NULL 
                invoke PostMessage,hWnd,WM_NULL,0,0 
            .elseif lParam==WM_LBUTTONDBLCLK 
                invoke SendMessage,hWnd,WM_COMMAND,IDM_RESTORE,0 
            .endif 
        .endif 

     When a mouse event occurs over the tray icon, your window receives WM_SHELLNOTIFY message which is the custom 
     message you specified in uCallbackMessage member. Recall that on receiving this message, wParam contains the 
     tray icon's ID and lParam contains the actual mouse message. In the code above, we check first if this message
     comes from the tray icon we are interested in. If it does, we check the actual mouse message. Since we are
     only interested in right mouse click and double-left-click, we process only WM_RBUTTONDOWN and 
     WM_LBUTTONDBLCLK messages. 
     If the mouse message is WM_RBUTTONDOWN, we call GetCursorPos to obtain the current screen coordinate of 
     the mouse cursor. When the function returns, the POINT structure is filled with the screen coordinate of
     the mouse cursor. By screen coordinate, I mean the coordinate of the entire screen without regarding to 
     any window boundary. For example, if the screen resolution is 640*480, the right-lower corner of the screen
     is x==639 and y==479. If you want to convert the screen coordinate to window coordinate, use ScreenToClient 
     function. 
     However, for our purpose, we want to display the popup menu at the current mouse cursor position with 
     TrackPopupMenu call and it requires screen coordinates, we can use the coordinates filled by GetCursorPos 
     directly. 
     TrackPopupMenu has the following syntax: 
  

TrackPopupMenu PROTO hMenu:DWORD, uFlags:DWORD,  x:DWORD,  y:DWORD, nReserved:DWORD, hWnd:DWORD, prcRect:DWORD 
     
     hMenu is the handle of the popup menu to be displayed 
     uFlags specifies the options of the function. Like where to position the menu relative to the coordinates 
     specified later and which mouse button will be used to track the menu. In our example, we use TPM_RIGHTALIGN 
     to position the popup menu to the left of the coordinates. 
     x and y specify the location of the menu in screen coordinates. 
     nReserved must be NULL 
     hWnd is the handle of the window that will receive the messages from the menu. 
     prcRect is the rectangle in the screen where it is possible to click without dismissing the menu. Normally 
     we put NULL here so when the user clicks anywhere outside the popup menu, the menu is dismissed. 
     When the user double-clicks at the tray icon, we send WM_COMMAND message to our own window specifying 
     IDM_RESTORE to emulate the user selects Restore menu item in the popup menu thereby restoring the main window 
     and removing the icon from the system tray. In order to be able to receive double click message, the main 
     window must have CS_DBLCLKS style. 
            invoke Shell_NotifyIcon,NIM_DELETE,addr note 
            mov eax,wParam 
            .if ax==IDM_RESTORE 
                invoke ShowWindow,hWnd,SW_RESTORE 
            .else 
                invoke DestroyWindow,hWnd 
            .endif 

When the user selects Restore menu item, we remove the tray icon by calling Shell_NotifyIcon again, this time 
we specify NIM_DELETE as the message. Next, we restore the main window to its original state. If the user 
selects Exit menu item, we also remove the icon from the tray and destroy the main window by calling 
DestroyWindow.

Unfortunately you can't run Java applets  


Tutorial 24: Windows Hooks
  
We will learn about Windows hooks in this tutorial. Windows hooks are very powerful. With them, you can poke 
inside other processes and sometimes alter their behaviors. 
Theory:
     Windows hooks can be considered one of the most powerful features of Windows. With them, you can trap events 
     that will occur, either in your own process or in other processes. By "hooking", you tell Windows about a 
     function, filter function also called hook procedure, that will be called everytime an event you're interested
     in occurs. There are two types of them: local and remote hooks. 
     Local hooks trap events that will occur in your own process. 
     Remote hooks trap events that will occur in other process(es). There are two types of remote hooks 
     thread-specific  traps events that will occur in a specific thread in other process. In short, you want to
     observe events in a specific thread in a specific process. 
     system-wide  traps all events destined for all threads in all processes in the system. 
     When you install hooks, remember that they affect system performance. System-wide hooks are the most notorious.
     Since ALL related events will be routed through your filter function, your system may slow down noticeably. 
     So if you use a system-wide hook, you should use it judiciously and unhook it as soon as you don't need it. 
     Also, you have a higher chance of crashing the other processes since you can meddle with other processes and 
     if something is wrong in your filter function, it can pull the other processes down to oblivion with it. 
     Remember: Power comes with responsibility. 
     You have to understand how a hook works before you can use it efficiently. When you create a hook, Windows 
     creates a data structure in memory, containing information about the hook, and adds it to a linked list of 
     existing hooks. New hook is added in front of old hooks. When an event occurs, if you install a local hook, 
     the filter function in your process is called so it's rather straightforward. But if it's a remote hook, the 
     system must inject the code for the hook procedure into the address space(s) of the other process(es).
     And the system can do that only if the function resides in a DLL. Thus , if you want to use a remote hook, 
     your hook procedure must reside in a DLL. There is two exceptions to this rule: journal record and journal 
     playback hooks. The hook procedures for those two hooks must reside in the thread that installs the hooks.
     The reason why it must be so is that: both hooks deal with the low-level interception of hardware input 
     events. The input events must be recorded/playbacked in the order they appeared. If the code of those two
     hooks is in a DLL, the input events may scatter among several threads and it is impossible to know the 
     order of them. So the solution: the hook procedure of those two hooks must be in a single thread only i.e.
     the thread that installs the hooks. 
There are 14 types of hooks: 
WH_CALLWNDPROC  called when SendMessage is called 
WH_CALLWNDPROCRET  called when SendMessage returns 
WH_GETMESSAGE   called when GetMessage or PeekMessage is called 
WH_KEYBOARD  called when GetMessage or PeekMessage retrieves WM_KEYUP or WM_KEYDOWN from the message queue 
WH_MOUSE  called when GetMessage or PeekMessage retrieves a mouse message from the message queue 
WH_HARDWARE called when GetMessage or PeekMessage retrieves some hardware message that is not related to 
keyboard or mouse. 
WH_MSGFILTER  called when a dialog box, menu or scrollbar is about to process a message. This hook is local.
 It's specifically for those objects which have their own internal message loops. 
WH_SYSMSGFILTER  same as WH_MSGFILTER but system-wide 
WH_JOURNALRECORD  called when Windows retrieves message from the hardware input queue 
WH_JOURNALPLAYBACK  called when an event is requested from the system's hardware input queue. 
WH_SHELL  called when something interesting about the shell occurs such as when the task bar needs to redraw
 its button. 
WH_CBT  used specifically for computer-based training (CBT). 
WH_FOREGROUNDIDLE used internally by Windows. Little use for general applications 
WH_DEBUG  used to debug the hooking procedure 
Now that we know some theory, we can move on to how to install/uninstall the hooks. 
          To install a hook, you call SetWindowsHookEx which has the following syntax: 
          SetWindowsHookEx proto HookType:DWORD, pHookProc:DWORD, hInstance:DWORD, ThreadID:DWORD 
          HookType is one of the values listed above, e.g., WH_MOUSE, WH_KEYBOARD 
          pHookProc is the address of the hook procedure that will be called to process the messages for the specified
          hook. If the hook is a remote one, it must reside in a DLL. If not, it must be in your process. 
          hInstance is the instance handle of the DLL in which the hook procedure resides. If the hook is a local one, 
          this value must be NULL 
          ThreadID  is the ID of the thread you want to install the hook to spy on. This parameter is the one that 
          determines whether a hook is local or remote. If this parameter is NULL, Windows will interpret the hook as a 
          system-wide remote hook that affects all threads in the system. If you specify the thread ID of a thread in 
          your own process, this hook is a local one. If you specify the thread ID from other process, the hook is a 
          thread-specific remote one. There are two exceptions to this rule: WH_JOURNALRECORD and WH_JOURNALPLAYBACK are
          always local system-wide hooks that are not required to be in a DLL. And WH_SYSMSGFILTER is always a system
          -wide remote hook. Actually it is identical to WH_MSGFILTER hook with ThreadID==0. 
          If the call is successful, it returns the hook handle in eax. If not, NULL is returned. You must save the hook
          handle for unhooking later.
          You can uninstall a hook by calling UnhookWindowsHookEx which accepts only one parameter, the handle of the 
          hook you want to uninstall. If the call succeeds, it returns a non-zero value in eax. Otherwise, it returns 
          NULL. 
          Now that you know how to install/uninstall hooks, we can examine the hook procedure. 
          The hook procedure will be called whenever an event that is associated with the type of hook you have 
          installed occurs. For example, if you install WH_MOUSE hook, when a mouse event occurs, your hook procedure 
          will be called. Regardless of the type of hook you installed, the hook procedure always has the following 
          prototype: 
          HookProc proto nCode:DWORD, wParam:DWORD, lParam:DWORD 
          
          nCode specifies the hook code. 
          wParam and lParam contain additional information about the event 
          HookProc is actually a placeholder for the function name. You can name it anything you like so long as 
          it has the above prototype. The interpretation of nCode, wParam and lParam is dependent on the type of hook 
          you install. So as the return value from the hook procedure. For example: 
          WH_CALLWNDPROC 
          nCode can be only HC_ACTION which means there is a message sent to a window 
          wParam contains the message being sent, if it's not zero 
          lParam points to a CWPSTRUCT structure 
          return value: not used, return zero 
          WH_MOUSE 
          nCode can be HC_ACTION or HC_NOREMOVE 
          wParam contains the mouse message 
          lParam points to a MOUSEHOOKSTRUCT structure 
          return value: zero if the message should be processed. 1 if the message should be discarded. 
          The bottom line is: you must consult your win32 api reference for details about the meanings of the parameters and return value of the hook you want to install. 
          Now there is a little catch about the hook procedure. Remember that the hooks are chained in a linked list with the most recently installed hook at the head of the list. When an event occurs, Windows will call only the first hook in the chain. It's your hook procedure's responsibility to call the next hook in the chain. You can choose not to call the next hook but you'd better know what you're doing. Most of the time, it's a good practice to call the next procedure so other hooks can have a shot at the event. You can call the next hook by calling CallNextHookEx which has the following prototype: 
          CallNextHookEx proto hHook:DWORD, nCode:DWORD, wParam:DWORD, lParam:DWORD 
          hHook is your own hook handle. The function uses this handle to traverse the linked list and search for the hook procedure it should call next. 
          nCode, wParam and lParam  you can just pass those three values you receive from Windows to CallNextHookEx. 
An important note about remote hooks: the hook procedure must reside in a DLL which will be mapped into other processes. When Windows maps the DLL into other processes, it will not map the data section(s) into the other processes. In short, all processes share a single copy of code but they will have their own private copy of the DLL's data section! This can be a big surprise to the unwary. You may think that when you store a value into a variable in the data section of a DLL, that value will be shared among all processes that load the DLL into their process address space. It's simply not true. In normal situation, this behavior is desirable since it provides the illusion that each process has its own copy of the DLL. But not when Windows hook is concerned. We want the DLL to be identical in all processes, including the data. The solution: you must mark the data section as shared. You can do this by specifying the section(s) attribute in the linker switch. For MASM, you need to use this switch: 
/SECTION:<section name>, S
The name of the initialized data section is .data and the uninitialized data is .bss. For example if you want to assemble a DLL which contains a hook procedure and you want the uninitialized data section to be shared amoung processes, you must use the following line: 
link /section:.bss,S  /DLL  /SUBSYSTEM:WINDOWS ..........
S attribute marks the section as shared. 
Example:
There are two modules: one is the main program which will do the GUI part and the other is the DLL that will install/uninstall the hook. 
;--------------------------------------------- This is the source code of the main program -------------------------------------- 
.386 
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
include mousehook.inc 
includelib mousehook.lib 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 

wsprintfA proto C :DWORD,:DWORD,:VARARG 
wsprintf TEXTEQU <wsprintfA> 

.const 
IDD_MAINDLG                   equ 101 
IDC_CLASSNAME              equ 1000 
IDC_HANDLE                     equ 1001 
IDC_WNDPROC                 equ 1002 
IDC_HOOK                         equ 1004 
IDC_EXIT                           equ 1005 
WM_MOUSEHOOK             equ WM_USER+6 

DlgFunc PROTO :DWORD,:DWORD,:DWORD,:DWORD 

.data 
HookFlag dd FALSE 
HookText db "&Hook",0 
UnhookText db "&Unhook",0 
template db "%lx",0 

.data? 
hInstance dd ? 
hHook dd ? 
.code 
start: 
    invoke GetModuleHandle,NULL 
    mov hInstance,eax 
    invoke DialogBoxParam,hInstance,IDD_MAINDLG,NULL,addr DlgFunc,NULL 
    invoke ExitProcess,NULL 


DlgFunc proc hDlg:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 
    LOCAL hLib:DWORD 
    LOCAL buffer[128]:byte 
    LOCAL buffer1[128]:byte 
    LOCAL rect:RECT 
    .if uMsg==WM_CLOSE 
        .if HookFlag==TRUE 
            invoke UninstallHook 
        .endif 
        invoke EndDialog,hDlg,NULL 
    .elseif uMsg==WM_INITDIALOG 
        invoke GetWindowRect,hDlg,addr rect 
        invoke SetWindowPos, hDlg, HWND_TOPMOST, rect.left, rect.top, rect.right, rect.bottom, SWP_SHOWWINDOW 
    .elseif uMsg==WM_MOUSEHOOK 
        invoke GetDlgItemText,hDlg,IDC_HANDLE,addr buffer1,128 
        invoke wsprintf,addr buffer,addr template,wParam 
        invoke lstrcmpi,addr buffer,addr buffer1 
        .if eax!=0 
            invoke SetDlgItemText,hDlg,IDC_HANDLE,addr buffer 
        .endif 
        invoke GetDlgItemText,hDlg,IDC_CLASSNAME,addr buffer1,128 
        invoke GetClassName,wParam,addr buffer,128 
        invoke lstrcmpi,addr buffer,addr buffer1 
        .if eax!=0 
            invoke SetDlgItemText,hDlg,IDC_CLASSNAME,addr buffer 
        .endif 
        invoke GetDlgItemText,hDlg,IDC_WNDPROC,addr buffer1,128 
        invoke GetClassLong,wParam,GCL_WNDPROC 
        invoke wsprintf,addr buffer,addr template,eax 
        invoke lstrcmpi,addr buffer,addr buffer1 
        .if eax!=0 
            invoke SetDlgItemText,hDlg,IDC_WNDPROC,addr buffer 
        .endif 
    .elseif uMsg==WM_COMMAND 
        .if lParam!=0 
            mov eax,wParam 
            mov edx,eax 
            shr edx,16 
            .if dx==BN_CLICKED 
                .if ax==IDC_EXIT 
                    invoke SendMessage,hDlg,WM_CLOSE,0,0 
                .else 
                    .if HookFlag==FALSE 
                        invoke InstallHook,hDlg 
                        .if eax!=NULL 
                            mov HookFlag,TRUE 
                            invoke SetDlgItemText,hDlg,IDC_HOOK,addr UnhookText 
                        .endif 
                    .else 
                        invoke UninstallHook 
                        invoke SetDlgItemText,hDlg,IDC_HOOK,addr HookText 
                        mov HookFlag,FALSE 
                        invoke SetDlgItemText,hDlg,IDC_CLASSNAME,NULL 
                        invoke SetDlgItemText,hDlg,IDC_HANDLE,NULL 
                        invoke SetDlgItemText,hDlg,IDC_WNDPROC,NULL 
                    .endif 
                .endif 
            .endif 
        .endif 
    .else 
        mov eax,FALSE 
        ret 
    .endif 
    mov eax,TRUE 
    ret 
DlgFunc endp 

end start 

;----------------------------------------------------- This is the source code of the DLL -------------------------------------- 
.386 
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\kernel32.inc 
includelib \Masm32\lib\kernel32.lib 
include \Masm32\include\user32.inc 
includelib \Masm32\lib\user32.lib 

.const 
WM_MOUSEHOOK equ WM_USER+6 

.data 
hInstance dd 0 

.data? 
hHook dd ? 
hWnd dd ? 

.code 
DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD 
    .if reason==DLL_PROCESS_ATTACH 
        push hInst 
        pop hInstance 
    .endif 
    mov  eax,TRUE 
    ret 
DllEntry Endp 

MouseProc proc nCode:DWORD,wParam:DWORD,lParam:DWORD 
    invoke CallNextHookEx,hHook,nCode,wParam,lParam 
    mov edx,lParam 
    assume edx:PTR MOUSEHOOKSTRUCT 
    invoke WindowFromPoint,[edx].pt.x,[edx].pt.y 
    invoke PostMessage,hWnd,WM_MOUSEHOOK,eax,0 
    assume edx:nothing 
    xor eax,eax 
    ret 
MouseProc endp 

InstallHook proc hwnd:DWORD 
    push hwnd 
    pop hWnd 
    invoke SetWindowsHookEx,WH_MOUSE,addr MouseProc,hInstance,NULL 
    mov hHook,eax 
    ret 
InstallHook endp 

UninstallHook proc 
    invoke UnhookWindowsHookEx,hHook 
    ret 
UninstallHook endp 

End DllEntry 

;---------------------------------------------- This is the makefile of the DLL ---------------------------------------------- 

NAME=mousehook 
$(NAME).dll: $(NAME).obj 
        Link /SECTION:.bss,S  /DLL /DEF:$(NAME).def /SUBSYSTEM:WINDOWS /LIBPATH:c:\masm\lib $(NAME).obj 
$(NAME).obj: $(NAME).asm 
        ml /c /coff /Cp $(NAME).asm 
  

Analysis:
     The example will display a dialog box with three edit controls that will be filled with the class name, window
     handle and the address of the window procedure associated with the window under the mouse cursor. There are
     two buttons, Hook and Exit. When you press the Hook button, the program hooks the mouse input and the text
     on the button changes to Unhook. When you move the mouse cursor over a window, the info about that window
     will be displayed in the main window of the example. When you press Unhook button, the program removes
     the mouse hook. 
     The main program uses a dialog box as its main window. It defines a custom message, WM_MOUSEHOOK which will
     be used between the main program and the hook DLL. When the main program receives this message, wParam
     contains the handle of the window that the mouse cursor is on. Of course, this is an arbitrary arrangement.
     I decide to send the handle in wParam for the sake of simplicity. You can choose your own method of
     communication between the main program and the hook DLL. 
                    .if HookFlag==FALSE 
                        invoke InstallHook,hDlg 
                        .if eax!=NULL 
                            mov HookFlag,TRUE 
                            invoke SetDlgItemText,hDlg,IDC_HOOK,addr UnhookText 

                        .endif 

     The program maintains a flag, HookFlag, to monitor the state of the hook. It's FALSE if the hook is not 
     installed and TRUE if the hook is installed. 
     When the user presses Hook button, the program checks if the hook is already installed. If it is not, it 
     call InstallHook function in the hook DLL to install it. Note that we pass the handle of the main dialog
     i.e. our own. 
     When the program is loaded, the hook DLL is loaded too. Actually, DLLs are loaded immediately after the 
     program is in memory. The DLL entrypoint function is called before the first instruction in the main program 
     is execute even. So when the main program executes the DLL(s) is/are initialized. We put the following code 
	in the DLL entrypoint function of the hook DLL: 

    .if reason==DLL_PROCESS_ATTACH 
        push hInst 
        pop hInstance 
    .endif 

     The code just saves the instance handle of the hook DLL itself to a global variable named hInstance for 
     use within the InstallHook function. Since the DLL entrypoint function is called before other functions 
     in the DLL are called , hInstance is always valid. We put hInstance in .data section so that this value 
     is kept on per-process basis. Since when the mouse cursor hovers over a window, the hook DLL is mapped into 
     the process. Imagine that there is already a DLL that occupies the intended load address of the hook DLL, 
     the hook DLL would be remapped to another address. The value of hInstance will be updated to those of the 
     new load address. When the user presses Unhook button and then Hook button, SetWindowsHookEx will be called 
     again. However, this time, it will use the new load address as the instance handle which will be wrong because
     in the example process, the hook DLL's load address hasn't been changed. The hook will be a local one
     where you can hook only the mouse events that occur in your own window. Hardly desirable. 

InstallHook proc hwnd:DWORD 
    push hwnd 
    pop hWnd 
    invoke SetWindowsHookEx,WH_MOUSE,addr MouseProc,hInstance,NULL 
    mov hHook,eax 
    ret 
InstallHook endp 

The InstallHook function itself is very simple. It saves the window handle passed as its parameter to a global
 variable named hWnd for future use. It then calls SetWindowsHookEx to install a mouse hook. The return value 
 of SetWindowsHookEx is stored in a global variable named hHook for use with UnhookWindowsHookEx. 
After SetWindowsHookEx is called, the mouse hook is functional. Whenever a mouse event occurs in the system, 
MouseProc ( your hook procedure) is called. 

MouseProc proc nCode:DWORD,wParam:DWORD,lParam:DWORD 
    invoke CallNextHookEx,hHook,nCode,wParam,lParam 
    mov edx,lParam 
    assume edx:PTR MOUSEHOOKSTRUCT 
    invoke WindowFromPoint,[edx].pt.x,[edx].pt.y 
    invoke PostMessage,hWnd,WM_MOUSEHOOK,eax,0 
    assume edx:nothing 
    xor eax,eax 
    ret 
MouseProc endp 

     The first thing it does is to call CallNextHookEx to give the other hooks the chance to process the mouse event.
     After that, it calls WindowFromPoint function to retrieve the handle of the window at the specified screen 
     coordinate. Note that we use the POINT structure in the MOUSEHOOKSTRUCT structure pointed to by lParam as 
     the current mouse coordinate. After that we send the window handle to the main program via PostMessage with 
     WM_MOUSEHOOK message. One thing you should remember is that: you should not use SendMessage inside the hook 
     procedure, it can cause message deadlock. PostMessage is recommended. The MOUSEHOOKSTRUCT structure is defined
  below: 

MOUSEHOOKSTRUCT STRUCT DWORD 
  pt            POINT <> 
  hwnd          DWORD      ? 
  wHitTestCode  DWORD      ? 
  dwExtraInfo   DWORD      ? 
MOUSEHOOKSTRUCT ENDS 
  

     pt is the current screen coordinate of the mouse cursor 
     hwnd is the handle of the window that will receive the mouse message. It's usually the window under the mouse 
     cursor but not always. If a window calls SetCapture, the mouse input will be redirected to that window instead.
     Because of this reason, I don't use the hwnd member of this structure but choose to call WindowFromPoint 
     instead. 
     wHitTestCode specifies the hit-test value. The hit-test value gives more information about the current mouse 
     cursor position. It specifies on what part of window the mouse cursor is. For complete list, check your win32 
     api reference under WM_NCHITTEST message. 
     dwExtraInfo contains the extra information associated with the message. Normally this value is set by calling 
     mouse_event and retrieved by calling GetMessageExtraInfo. 
     When the main window receives WM_MOUSEHOOK message, it uses the window handle in wParam to retrieve the 
information about the window. 
    .elseif uMsg==WM_MOUSEHOOK 
        invoke GetDlgItemText,hDlg,IDC_HANDLE,addr buffer1,128 
        invoke wsprintf,addr buffer,addr template,wParam 
        invoke lstrcmpi,addr buffer,addr buffer1 
        .if eax!=0 
            invoke SetDlgItemText,hDlg,IDC_HANDLE,addr buffer 
        .endif 
        invoke GetDlgItemText,hDlg,IDC_CLASSNAME,addr buffer1,128 
        invoke GetClassName,wParam,addr buffer,128 
        invoke lstrcmpi,addr buffer,addr buffer1 
        .if eax!=0 
            invoke SetDlgItemText,hDlg,IDC_CLASSNAME,addr buffer 
        .endif 
        invoke GetDlgItemText,hDlg,IDC_WNDPROC,addr buffer1,128 
        invoke GetClassLong,wParam,GCL_WNDPROC 
        invoke wsprintf,addr buffer,addr template,eax 
        invoke lstrcmpi,addr buffer,addr buffer1 
        .if eax!=0 
            invoke SetDlgItemText,hDlg,IDC_WNDPROC,addr buffer 
        .endif 

     To avoid flickers, we check the text already in the edit controls and the text we will put into them if they
     are identical. If they are, we skip them. 
     We retrieve the class name by calling GetClassName, the address of the window procedure by calling 
     GetClassLong with GCL_WNDPROC and then format them into strings and put them into the appropriate edit 
     controls. 

                        invoke UninstallHook 
                        invoke SetDlgItemText,hDlg,IDC_HOOK,addr HookText 
                        mov HookFlag,FALSE 
                        invoke SetDlgItemText,hDlg,IDC_CLASSNAME,NULL 
                        invoke SetDlgItemText,hDlg,IDC_HANDLE,NULL 
                        invoke SetDlgItemText,hDlg,IDC_WNDPROC,NULL 

     When the user presses Unhook button, the program calls UninstallHook function in the hook DLL. UninstallHook 
     just calls UnhookWindowsHookEx. After that, it changes the text of the button back to "Hook", HookFlag to
     FALSE and clears the content of the edit controls. 
     Note the linker switch in the makefile. 
     
        Link /SECTION:.bss,S  /DLL /DEF:$(NAME).def /SUBSYSTEM:WINDOWS 
     
     It specifies .bss section as a shared section to make all processes share the same uninitialized data 
    section
     of the hook DLL. Without this switch, your hook DLL will not function correctly.


Unfortunately you can't run Java applets  


Tutorial 25: Simple Bitmap
  
     In this tutorial, we will learn how to use bitmap in our program. To be exact, we will learn how to display 
     a bitmap in the client area of our window. 
     Theory
     Bitmaps can be thought of as pictures stored in computer. There are many picture formats used with computers
     but Windows only natively supports Windows Bitmap Graphics files (.bmp). The bitmaps I'll refer to in this 
     tutorial are Windows bitmap graphics files. The easiest way to use a bitmap is to use it as a resource. 
     There are two ways to do that. You can include the bitmap in the resource definition file (.rc) as follows: 
     
     #define IDB_MYBITMAP   100 
     IDB_MYBITMAP  BITMAP  "c:\project\example.bmp"
     This method uses a constant to represent the bitmap. The first line just creates a constant named IDB_MYBITMAP
     which has the value of 100. We will use this label to refer to the bitmap in the program. The next line 
     declares a bitmap resource. It tells the resource compiler where to find the actual bmp file. 
     The other method uses a name to represent the bitmap as follows: 
     MyBitMap  BITMAP "c:\project\example.bmp"
     This method requires that you refer to the bitmap in your program by the string "MyBitMap" instead of a value.
     
     Either method works fine as long as you know which method you're using. 
     Now that we put the bitmap in the resource file, we can go on with the steps in displaying it in the client 
     area of our window. 
     call LoadBitmap to get the bitmap handle. LoadBitmap has the following definition: 
     LoadBitmap proto hInstance:HINSTANCE, lpBitmapName:LPSTR
     
     This function returns a bitmap handle. hInstance is the instance handle of our program. lpBitmapName is a 
     pointer to the string that is the name of the bitmap (incase you use the second method to refer to the bitmap).
     If you use a constant to refer to the bitmap (like IDB_MYBITMAP), you can put its value here. (In the example
     above it would be 100). A short example is in order: 

  
First Method: 
.386 
.model flat, stdcall 
................ 
.const 
IDB_MYBITMAP    equ 100 
............... 
.data? 
hInstance  dd ? 
.............. 
.code 
............. 
    invoke GetModuleHandle,NULL 
    mov hInstance,eax 
............ 
    invoke LoadBitmap,hInstance,IDB_MYBITMAP 
........... 

Second Method: 

.386 
.model flat, stdcall 
................ 
.data 
BitmapName  db "MyBitMap",0 
............... 
.data? 
hInstance  dd ? 
.............. 
.code 
............. 
    invoke GetModuleHandle,NULL 
    mov hInstance,eax 
............ 
    invoke LoadBitmap,hInstance,addr BitmapName 
...........

     Obtain a handle to device context (DC). You can obtain this handle by calling BeginPaint in response to 
     WM_PAINT message or by calling GetDC anywhere. 
     Create a memory device context which has the same attribute as the device context we just obtained. 
     The idea here is to create a kind of "hidden" drawing surface which we can draw the bitmap on. When we 
     are finished with the operation, we just copy the content of the hidden drawing surface to the actual 
     device context in one function call. It's an example of double-buffer technique used for fast display of 
     pictures on the screen. You can create this "hidden" drawing surface by calling CreateCompatibleDC. 
     CreateCompatibleDC  proto  hdc:HDC
     
     If this function succeeds, it returns the handle of the memory device context in eax. hdc is the handle to 
     the device context that you want the memory DC to be compatible with. 

     Now that you got a hidden drawing surface, you can draw on it by selecting the bitmap into it. This is done
     by calling SelectObject with the handle to the memory DC as the first parameter and the bitmap handle as
     the second parameter. SelectObject has the following definition: 
     SelectObject   proto  hdc:HDC, hGdiObject:DWORD
     The bitmap is drawn on the memory device context now. All we need to do here is to copy it to the actual 
     display device, namely the true device context. There are several functions that can perform this operation 
     such as BitBlt and StretchBlt. BitBlt just copies the content of one DC to another so it's fast while
     StretchBlt can stretch or compress the bitmap to fit the output area. We will use BitBlt here for 
     simplicity. BitBlt has the following definition: 
     BitBlt  proto  hdcDest:DWORD, nxDest:DWORD, nyDest:DWORD, nWidth:DWORD, nHeight:DWORD, hdcSrc:DWORD, 
     nxSrc:DWORD, nySrc:DWORD, dwROP:DWORD 
     
     hdcDest is the handle of the device context that serves as the destination of bitmap transfer operation 
     nxDest, nyDest are the coordinate of the upper left corner of the output area 
     nWidth, nHeight are the width and height of the output area 
     hdcSrc is the handle of the device context that serves as the source of bitmap transfer operation 
     nxSrc, nySrc are the coordinate of the upper left corner of the source rectangle. 
     dwROP is the raster-operation code (hence the acronym ROP) that governs how to combine the color data of
     the bitmap to the existing color data on the output area to achieve the final result. Most of the time, 
     you only want to overwrite the existing color data with the new one. 
     When you're done with the bitmap, delete it with DeleteObject API call. 
     That's it! To recapitulate, you need to put the bitmap into the resource scipt. Then load it from the
     resource with LoadBitmap. You'll get the bitmap handle. Next you obtain the handle to the device context 
     f the area you want to paint the bitmap on. Then you create a memory device context that is compatible with 
     the device context you just obtained. Select the bitmap into the memory DC then copy the content of the 
 memory DC to the real DC. 
Example Code:
.386 
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\gdi32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
includelib \Masm32\lib\gdi32.lib 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 
IDB_MAIN   equ 1 

.data 
ClassName db "SimpleWin32ASMBitmapClass",0 
AppName  db "Win32ASM Simple Bitmap Example",0 

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
hBitmap dd ? 

.code 
start: 
 invoke GetModuleHandle, NULL 
 mov    hInstance,eax 
 invoke GetCommandLine 
 mov    CommandLine,eax 
 invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
 invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
 LOCAL wc:WNDCLASSEX 
 LOCAL msg:MSG 
 LOCAL hwnd:HWND 
 mov   wc.cbSize,SIZEOF WNDCLASSEX 
 mov   wc.style, CS_HREDRAW or CS_VREDRAW 
 mov   wc.lpfnWndProc, OFFSET WndProc 
 mov   wc.cbClsExtra,NULL 
 mov   wc.cbWndExtra,NULL 
 push  hInstance 
 pop   wc.hInstance 
 mov   wc.hbrBackground,COLOR_WINDOW+1 
 mov   wc.lpszMenuName,NULL 
 mov   wc.lpszClassName,OFFSET ClassName 
 invoke LoadIcon,NULL,IDI_APPLICATION 
 mov   wc.hIcon,eax 
 mov   wc.hIconSm,eax 
 invoke LoadCursor,NULL,IDC_ARROW 
 mov   wc.hCursor,eax 
 invoke RegisterClassEx, addr wc 
 INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\ 
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\ 
           hInst,NULL 
 mov   hwnd,eax 
 invoke ShowWindow, hwnd,SW_SHOWNORMAL 
 invoke UpdateWindow, hwnd 
 .while TRUE 
  invoke GetMessage, ADDR msg,NULL,0,0 
  .break .if (!eax) 
  invoke TranslateMessage, ADDR msg 
  invoke DispatchMessage, ADDR msg 
 .endw 
 mov     eax,msg.wParam 
 ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
   LOCAL ps:PAINTSTRUCT 
   LOCAL hdc:HDC 
   LOCAL hMemDC:HDC 
   LOCAL rect:RECT 
   .if uMsg==WM_CREATE 
      invoke LoadBitmap,hInstance,IDB_MAIN 
      mov hBitmap,eax 
   .elseif uMsg==WM_PAINT 
      invoke BeginPaint,hWnd,addr ps 
      mov    hdc,eax 
      invoke CreateCompatibleDC,hdc 
      mov    hMemDC,eax 
      invoke SelectObject,hMemDC,hBitmap 
      invoke GetClientRect,hWnd,addr rect 
      invoke BitBlt,hdc,0,0,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY 
      invoke DeleteDC,hMemDC 
      invoke EndPaint,hWnd,addr ps 
 .elseif uMsg==WM_DESTROY 
  invoke DeleteObject,hBitmap 
  invoke PostQuitMessage,NULL 
 .ELSE 
  invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
  ret 
 .ENDIF 
 xor eax,eax 
 ret 
WndProc endp 
end start 

;--------------------------------------------------------------------- 
;                            The resource script 
;--------------------------------------------------------------------- 
#define IDB_MAIN 1 
IDB_MAIN BITMAP "tweety78.bmp" 

Analysis:
There is not much to analyze in this tutorial ;) 
  
#define IDB_MAIN 1 
IDB_MAIN BITMAP "tweety78.bmp"
Define a constant named IDB_MAIN, assign 1 as its value. And then use that constant as the bitmap resource identifier. The bitmap file to be included in the resource is "tweety78.bmp" which resides in the same folder as the resource script. 
   .if uMsg==WM_CREATE 
      invoke LoadBitmap,hInstance,IDB_MAIN 
      mov hBitmap,eax 

In response to WM_CREATE, we call LoadBitmap to load the bitmap from the resource, passing the bitmap's resource identifier as the second parameter to the API. We get the handle to the bitmap when the function returns. 
Now that the bitmap is loaded, we can paint it in the client area of our main window. 

   .elseif uMsg==WM_PAINT 
      invoke BeginPaint,hWnd,addr ps 
      mov    hdc,eax 
      invoke CreateCompatibleDC,hdc 
      mov    hMemDC,eax 
      invoke SelectObject,hMemDC,hBitmap 
      invoke GetClientRect,hWnd,addr rect 
      invoke BitBlt,hdc,0,0,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY 
      invoke DeleteDC,hMemDC 
      invoke EndPaint,hWnd,addr ps 

We choose to paint the bitmap in response to WM_PAINT message. We first call BeginPaint to obtain the handle to the device context. Then we create a compatible memory DC with CreateCompatibleDC. Next select the bitmap into the memory DC with SelectObject. Determine the dimension of the client area with GetClientRect. Now we can display the bitmap in the client area by calling BitBlt which copies the bitmap from the memory DC to the real DC. When the painting is done, we have no further need for the memory DC so we delete it with DeleteDC. End painting session with EndPaint. 

 .elseif uMsg==WM_DESTROY 
  invoke DeleteObject,hBitmap 
  invoke PostQuitMessage,NULL
When we don't need the bitmap anymore, we delete it with DeleteObject



Tutorial 26: Splash Screen
  
     Now that we know how to use a bitmap, we can progress to a more creative use of it. Splash screen. 
     Theory
     A splash screen is a window that has no title bar, no system menu box, no border that displays a bitmap for 
     a while and then disappears automatically. It's usually used during program startup, to display the program's
     logo or to distract the user's attention while the program does some lengthy initialization. We will implement a splash screen in this tutorial. 
     The first step is to include the bitmap in the resource file. However, if you think of it,  it's a waste of 
     precious memory to load a bitmap that will be used only once and keep it in memory till the program is closed.
     A better solution is to create a *resource* DLL which contains the bitmap and has the sole purpose of 
     displaying the splash screen. This way, you can load the DLL when you want to display the splash screen 
     and unload it when it's not necessary anymore. So we will have two modules: the main program and the splash
     DLL. We will put the bitmap into the DLL's resource. 
     The general scheme is as follows: 
     Put the bitmap into the DLL as a bitmap resource 
     The main program calls LoadLibrary to load the dll into memory 
     The DLL entrypoint function of the DLL is called. It will create a timer and set the length of time that the
     splash screen will be displayed. Next it  will register and create a window without caption and border and 
     display the bitmap in the client area. 
     When the specified length of time elapsed, the splash screen is removed from the screen and the control is 
     returned to the main program 
     The main program calls FreeLibrary to unload the DLL from memory and then goes on with whatever task it is 
     supposed to do. 
     We will examine the mechanisms in detail. 
     Load/Unload DLL
     You can dynamically load a DLL with LoadLibrary function which has the following syntax: 
     LoadLibrary  proto lpDLLName:DWORD
     It takes only one parameter: the address of the name of the DLL you want to load into memory. If the call 
     is successful, it returns the module handle of the DLL else it returns NULL. 
     To unload a DLL, call FreeLibrary: 
     FreeLibrary  proto  hLib:DWORD
     It takes one parameter: the module handle of the DLL you want to unload. Normally, you got that handle from 
     LoadLibrary 
     How to use a timer
     First, you must create a timer first with SetTimer: 
     SetTimer  proto  hWnd:DWORD, TimerID:DWORD, uElapse:DWORD, lpTimerFunc:DWORD 
     hWnd is the handle of a window that will receive the timer notification message. This parameter can be NULL
     to specify that there is no window that's associated with the timer. 
     TimerID is a user-defined value that is used as the ID of the timer. 
     uElapse is the time-out value in milliseconds. 
     lpTimerFunc is the address of a function that will process the timer notification messages. If you pass NULL, 
     the timer messages will be sent to the window specified by hWnd parameter. 
     
     SetTimer returns the ID of the timer if successful. Otherwise it returns NULL. So it's best not to use the
     timer ID of 0.
     
     You can create a timer in two ways: 
     If you have a window and you want the timer notification messages to go to that window, you must pass all
     four parameters to SetTimer (the lpTimerFunc must be NULL) 
     If you don't have a window or you don't want to process the timer messages in the window procedure, you 
     must pass NULL to the function in place of a window handle. You must also specify the address of the timer 
     function that will process the timer messages. 
     We will use the first approach in this example. 
     When the time-out period elapses, WM_TIMER message is sent to the window that is associated with the timer.
     For example, if you specify uElapse of 1000, your window will receive WM_TIMER every second. 
     When you don't need the timer anymore, destroy it with KillTimer: 
KillTimer  proto  hWnd:DWORD, TimerID:DWORD
Example:
;----------------------------------------------------------------------- 
;                         The main program 
;----------------------------------------------------------------------- 
.386 
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 

.data 
ClassName db "SplashDemoWinClass",0 
AppName  db "Splash Screen Example",0 
Libname db "splash.dll",0 

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
.code 
start: 
 invoke LoadLibrary,addr Libname 
 .if eax!=NULL 
    invoke FreeLibrary,eax 
 .endif 
 invoke GetModuleHandle, NULL 
 mov    hInstance,eax 
 invoke GetCommandLine 
 mov    CommandLine,eax 
 invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
 invoke ExitProcess,eax 

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
 LOCAL wc:WNDCLASSEX 
 LOCAL msg:MSG 
 LOCAL hwnd:HWND 
 mov   wc.cbSize,SIZEOF WNDCLASSEX 
 mov   wc.style, CS_HREDRAW or CS_VREDRAW 
 mov   wc.lpfnWndProc, OFFSET WndProc 
 mov   wc.cbClsExtra,NULL 
 mov   wc.cbWndExtra,NULL 
 push  hInstance 
 pop   wc.hInstance 
 mov   wc.hbrBackground,COLOR_WINDOW+1 
 mov   wc.lpszMenuName,NULL 
 mov   wc.lpszClassName,OFFSET ClassName 
 invoke LoadIcon,NULL,IDI_APPLICATION 
 mov   wc.hIcon,eax 
 mov   wc.hIconSm,eax 
 invoke LoadCursor,NULL,IDC_ARROW 
 mov   wc.hCursor,eax 
 invoke RegisterClassEx, addr wc 
 INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\ 
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\ 
           hInst,NULL 
 mov   hwnd,eax 
 invoke ShowWindow, hwnd,SW_SHOWNORMAL 
 invoke UpdateWindow, hwnd 
 .while TRUE 
  invoke GetMessage, ADDR msg,NULL,0,0 
  .break .if (!eax) 
  invoke TranslateMessage, ADDR msg 
  invoke DispatchMessage, ADDR msg 
 .endw 
 mov     eax,msg.wParam 
 ret 
WinMain endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
 .IF uMsg==WM_DESTROY 
  invoke PostQuitMessage,NULL 
 .ELSE 
  invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
  ret 
 .ENDIF 
 xor eax,eax 
 ret 
WndProc endp 
end start 

;-------------------------------------------------------------------- 
;                         The Bitmap DLL 
;-------------------------------------------------------------------- 
.386 
.model flat, stdcall 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\gdi32.inc 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
includelib \Masm32\lib\gdi32.lib 
.data 
BitmapName db "MySplashBMP",0 
ClassName db "SplashWndClass",0 
hBitMap dd 0 
TimerID dd 0 

.data 
hInstance dd ? 

.code 

DllEntry proc hInst:DWORD, reason:DWORD, reserved1:DWORD 
   .if reason==DLL_PROCESS_ATTACH  ; When the dll is loaded 
      push hInst 
      pop hInstance 
      call ShowBitMap 
   .endif
   mov eax,TRUE
   ret 
DllEntry Endp 
ShowBitMap proc 
        LOCAL wc:WNDCLASSEX 
        LOCAL msg:MSG 
        LOCAL hwnd:HWND 
        mov   wc.cbSize,SIZEOF WNDCLASSEX 
        mov   wc.style, CS_HREDRAW or CS_VREDRAW 
        mov   wc.lpfnWndProc, OFFSET WndProc 
        mov   wc.cbClsExtra,NULL 
        mov   wc.cbWndExtra,NULL 
        push  hInstance 
        pop   wc.hInstance 
        mov   wc.hbrBackground,COLOR_WINDOW+1 
        mov   wc.lpszMenuName,NULL 
        mov   wc.lpszClassName,OFFSET ClassName 
        invoke LoadIcon,NULL,IDI_APPLICATION 
        mov   wc.hIcon,eax 
        mov   wc.hIconSm,0 
        invoke LoadCursor,NULL,IDC_ARROW 
        mov   wc.hCursor,eax 
        invoke RegisterClassEx, addr wc 
        INVOKE CreateWindowEx,NULL,ADDR ClassName,NULL,\ 
           WS_POPUP,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,250,250,NULL,NULL,\ 
           hInstance,NULL 
        mov   hwnd,eax 
        INVOKE ShowWindow, hwnd,SW_SHOWNORMAL 
        .WHILE TRUE 
                INVOKE GetMessage, ADDR msg,NULL,0,0 
                .BREAK .IF (!eax) 
                INVOKE TranslateMessage, ADDR msg 
                INVOKE DispatchMessage, ADDR msg 
        .ENDW 
        mov     eax,msg.wParam 
        ret 
ShowBitMap endp 
WndProc proc hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 
        LOCAL ps:PAINTSTRUCT 
        LOCAL hdc:HDC 
        LOCAL hMemoryDC:HDC 
        LOCAL hOldBmp:DWORD 
        LOCAL bitmap:BITMAP 
        LOCAL DlgHeight:DWORD 
        LOCAL DlgWidth:DWORD 
        LOCAL DlgRect:RECT 
        LOCAL DesktopRect:RECT 

        .if uMsg==WM_DESTROY 
                .if hBitMap!=0 
                        invoke DeleteObject,hBitMap 
                .endif 
                invoke PostQuitMessage,NULL 
        .elseif uMsg==WM_CREATE 
                invoke GetWindowRect,hWnd,addr DlgRect 
                invoke GetDesktopWindow 
                mov ecx,eax 
                invoke GetWindowRect,ecx,addr DesktopRect 
                push  0 
                mov  eax,DlgRect.bottom 
                sub  eax,DlgRect.top 
                mov  DlgHeight,eax 
                push eax 
                mov  eax,DlgRect.right 
                sub  eax,DlgRect.left 
                mov  DlgWidth,eax 
                push eax 
                mov  eax,DesktopRect.bottom 
                sub  eax,DlgHeight 
                shr  eax,1 
                push eax 
                mov  eax,DesktopRect.right 
                sub  eax,DlgWidth 
                shr  eax,1 
                push eax 
                push hWnd 
                call MoveWindow 
                invoke LoadBitmap,hInstance,addr BitmapName 
                mov hBitMap,eax 
                invoke SetTimer,hWnd,1,2000,NULL 
                mov TimerID,eax 
        .elseif uMsg==WM_TIMER 
                invoke SendMessage,hWnd,WM_LBUTTONDOWN,NULL,NULL 
                invoke KillTimer,hWnd,TimerID 
        .elseif uMsg==WM_PAINT 
                invoke BeginPaint,hWnd,addr ps 
                mov hdc,eax 
                invoke CreateCompatibleDC,hdc 
                mov hMemoryDC,eax 
                invoke SelectObject,eax,hBitMap 
                mov hOldBmp,eax 
                invoke GetObject,hBitMap,sizeof BITMAP,addr bitmap 
                invoke StretchBlt,hdc,0,0,250,250,\ 
                       hMemoryDC,0,0,bitmap.bmWidth,bitmap.bmHeight,SRCCOPY 
                invoke SelectObject,hMemoryDC,hOldBmp 
                invoke DeleteDC,hMemoryDC 
                invoke EndPaint,hWnd,addr ps 
        .elseif uMsg==WM_LBUTTONDOWN 
                invoke DestroyWindow,hWnd 
        .else 
                invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
                ret 
        .endif 
        xor eax,eax 
        ret 
WndProc endp 

End DllEntry 

Analysis:
We will examine the code in the main program first. 
 invoke LoadLibrary,addr Libname 
 .if eax!=NULL 
    invoke FreeLibrary,eax 
 .endif
We call LoadLibrary to load the DLL named "splash.dll". And after that, unload it from memory with FreeLibrary.
 LoadLibrary will not return until the DLL is finished with its initialization. 
That's all the main program does. The interesting part is in the DLL. 
   .if reason==DLL_PROCESS_ATTACH  ; When the dll is loaded 
      push hInst 
      pop hInstance 
      call ShowBitMap 

When the DLL is loaded, Windows calls its entrypoint function with DLL_PROCESS_ATTACH flag. We take this 
opportunity to display the splash screen. First we store the instance handle of the DLL for future use. 
Then call a function named ShowBitMap to do the real job. ShowBitMap registers a window class, creates a
 window and enters the message loop as usual. The interesting part is in the CreateWindowEx call: 

        INVOKE CreateWindowEx,NULL,ADDR ClassName,NULL,\ 
           WS_POPUP,CW_USEDEFAULT,\ 
           CW_USEDEFAULT,250,250,NULL,NULL,\ 
           hInstance,NULL 

Note that the window style is only WS_POPUP which will make the window borderless and without caption. 
We also limit the width and height of the window to 250x250 pixels. 
Now when the window is created, in WM_CREATE message handler we move the window to the center of the screen 
with the following code. 

                invoke GetWindowRect,hWnd,addr DlgRect 
                invoke GetDesktopWindow 
                mov ecx,eax 
                invoke GetWindowRect,ecx,addr DesktopRect 
                push  0 
                mov  eax,DlgRect.bottom 
                sub  eax,DlgRect.top 
                mov  DlgHeight,eax 
                push eax 
                mov  eax,DlgRect.right 
                sub  eax,DlgRect.left 
                mov  DlgWidth,eax 
                push eax 
                mov  eax,DesktopRect.bottom 
                sub  eax,DlgHeight 
                shr  eax,1 
                push eax 
                mov  eax,DesktopRect.right 
                sub  eax,DlgWidth 
                shr  eax,1 
                push eax 
                push hWnd 
                call MoveWindow 

     It retrieves the dimensions of the desktop and the window then calculates the appropriate coordinate of the 
     left upper corner of the window to make it center. 
     
                     invoke LoadBitmap,hInstance,addr BitmapName 
                     mov hBitMap,eax 
                     invoke SetTimer,hWnd,1,2000,NULL 
                     mov TimerID,eax 
     
     Next it loads the bitmap from the resource with LoadBitmap and creates a timer with the timer ID of 1 and 
     the time interval 2 seconds. The timer will send WM_TIMER messages to the window every 2 seconds. 

        .elseif uMsg==WM_PAINT 
                invoke BeginPaint,hWnd,addr ps 
                mov hdc,eax 
                invoke CreateCompatibleDC,hdc 
                mov hMemoryDC,eax 
                invoke SelectObject,eax,hBitMap 
                mov hOldBmp,eax 
                invoke GetObject,hBitMap,sizeof BITMAP,addr bitmap 
                invoke StretchBlt,hdc,0,0,250,250,\ 
                       hMemoryDC,0,0,bitmap.bmWidth,bitmap.bmHeight,SRCCOPY 
                invoke SelectObject,hMemoryDC,hOldBmp 
                invoke DeleteDC,hMemoryDC 
                invoke EndPaint,hWnd,addr ps 

     When the window receives WM_PAINT message, it creates a memory DC, select the bitmap into the memory DC, 
     obtain the size of the bitmap with GetObject and then put the bitmap on the window by calling StretchBlt
     which performs like BitBlt but it can stretch or compress the bitmap to the desired dimension. In this case,
     we want the bitmap to fit into the window so we use StretchBlt instead of BitBlt. We delete the memory DC
     after that. 
     
        .elseif uMsg==WM_LBUTTONDOWN 
                invoke DestroyWindow,hWnd 
     
     It would be frustrating to the user if he has to wait until the splash screen to disappear. We can provide
     the user with a choice. When he clicks on the splash screen, it will disappear. That's why we need to proces
     s WM_LBUTTONDOWN message in the DLL. Upon receiving this message, the window is destroyed by DestroyWindow call. 

        .elseif uMsg==WM_TIMER 
                invoke SendMessage,hWnd,WM_LBUTTONDOWN,NULL,NULL 
                invoke KillTimer,hWnd,TimerID 

     If the user chooses to wait, the splash screen will disappear when the specified time has elapsed 
     (in our example, it's 2 seconds). We can do this by processing WM_TIMER message. Upon receiving this
     message, we closes the window by sending WM_LBUTTONDOWN message to the window. This is to avoid code 
     duplication. We don't have further use for the timer so we destroy it with KillTimer. 
     When the window is closed, the DLL will return control to the main program.
     


Tutorial 27: Tooltip Control
  
We will learn about the tooltip control: What it is and how to create and use it. 
Theory:
     A tooltip is a small rectangular window that is displayed when the mouse pointer hovers over some specific area.
     A tooltip window contains some text that the programmer wants to be displayed. In this regard, a tooltip
     servers the same role as the status window but it disappears when the user clicks or moves the mouse 
     pointer away from the designated area. You'll probably be familiar with the tooltips that are associated 
     with toolbar buttons. Those "tooltips" are conveniencies provided by the toolbar control. If you want 
     tooltips for other windows/controls, you need to create your own tooltip control. 
     Now that you know what a tooltip is, let's go on to how we can create and use it. The steps are outlined 
     below: 
     Create a tooltip control with CreateWindowEx 
     Define a region that the tooltip control will monitor for mouse pointer movement. 
     Submit the region to the tooltip control 
     Relay mouse messages of the submitted region to the tooltip control (this step may occur earlier, depending 
     on the method used to relay the messages) 
     We wll next examine each step in detail. 
     Tooltip Creation
     A tooltip control is a common control. As such, you need to call InitCommonControls somewhere in your source 
     code so that MASM implicitly links your program to comctl32.dll. You create a tooltip control with 
     CreateWindowEx. The typical scenario would be like this: 
     .data 
     TooltipClassName db "Tooltips_class32",0 
.code 
..... 
invoke InitCommonControls 
invoke CreateWindowEx, NULL, addr TooltipClassName, NULL, TIS_ALWAYSTIP, CW_USEDEFAULT, CW_USEDEFAULT, 
     CW_USEDEFAULT, CW_USEDEFAULT, NULL, NULL, hInstance, NULL
     Note the window style: TIS_ALWAYSTIP. This style specifies that the tooltip will be shown when the mouse 
     pointer is over the designated area regardless of the status of the window that contains the area. Put simply,
     if you use this flag, when the mouse pointer hovers over the area you register to the tooltip control, 
     the tooltip window will appear even if the window under the mouse pointer is inactive. 
     You don't have to include WS_POPUP and WS_EX_TOOLWINDOW styles in CreateWindowEx because the tooltip control's
     window procedure adds them automatically. You also don't need to specify the coordinate, the height and width 
     of the tooltip window: the tooltip control will adjust them automatically to fit the tooltip text that will 
     be displayed, thus we supply CW_USEDEFAULT in all four parameters. The remaining parameters are not remarkable. 
     Specifying the tool
     The tooltip control is created but it's not shown immediately. We want the tooltip window to show up when 
     the mouse pointer hovers over some area. Now is the time to specify that area. We call such area "tool". 
A tool is a rectangular area on the client area of a window which the tooltip control will monitor for mouse pointer. If the mouse pointer hovers over the tool, the tooltip window will appear. The rectangular area can cover the whole client area or only a part of it. So we can divided tool into two types: one that is implemented as a window and another that is implemented as a rectangular area in the client area of some window. Both has their uses. The tool that covers the whole client area of a window is most frequently used with controls such as buttons, edit controls and so on. You don't need to specify the coordinate and the dimensions of the tool: it's assumed to be the whole client area of the window. The tool that is implemented as a rectangular area on the client area is useful when you want to divide the client area of a window into several regions without using child windows. With this type of tool, you need to specify the coordinate of the upper left corner and the width and height of the tool. 
You specify the tool with the TOOLINFO structure which has the following definition: 
TOOLINFO STRUCT 
  cbSize             DWORD      ? 
  uFlags             DWORD      ? 
  hWnd               DWORD      ? 
  uId                DWORD      ? 
  rect               RECT      <> 
  hInst              DWORD      ? 
  lpszText           DWORD      ? 
  lParam             LPARAM     ? 
TOOLINFO ENDS
Field Name Explanation 
     cbSize The size of the TOOLINFO structure. You MUST fill this member. Windows will not flag error if this 
     field is not filled properly but you will receive strange, unpredictable results. 
     uFlags The bit flags that specifies the characteristics of the tool. This value can be a combination of the 
     following flags: 
     TTF_IDISHWND  "ID is hWnd". If you specify this flag, it means you want to use a tool that covers the whole 
     client area of a window (the first type of tool above). If you use this flag, you must fill the uId member 
     of this structure with the handle of the window you want to use. If you don't specify this flag, it means you
      want to use the second type of tool, the one that is implemented as the rectangular area on the client window.
       In that case, you need to fill the rect member with the dimension of the rectangle. 
     TTF_CENTERTIP  Normally the tooltip window will appear to the right and below the mouse pointer. 
     If you specify this flag, the tooltip window will always appear directly below the tool and is centered 
     regardless of the position of the mouse pointer. 
     TTF_RTLREADING  You can forget about this flag if your program is not designed specifically for Arabic or 
     Hebrew systems. This flag displays the tooltip text with right-to-left reading order. Doesn't work under 
     other systems. 
     TTF_SUBCLASS  If you use this flag, it means you tell the tooltip control to subclass the window that the 
     tool is on so that the tooltip control can intercept mouse messages that are sent to the window. This flag is
      very handy. If you don't use this flag, you have to do more work to relay the mouse messages to the tooltip 
      control. 
      
     hWnd Handle to the window that contains the tool. If you specify TTF_IDISHWND flag, this field is ignored
      since Windows will use the value in uId member as the window handle. You need to fill this field if: 
     You don't use TTF_IDISHWND flag (in other words, you use a rectangular tool) 
     You specify the value LPSTR_TEXTCALLBACK in lpszText member. This value tells the tooltip control that, 
     when it needs to display the tooltip window, it must ask the window that contains the tool for the text to 
     be displayed. This is a kind of dynamic realtime tooltip text update. If you want to change your tooltip text 
dynamically, you should specify LPSTR_TEXTCALLBACK value in lpszText member. The tooltip control will send 
TTN_NEEDTEXT notification message to the window identified by the handle in hWnd field. 
 
uId The value in this field can have two meanings, depending on whether the uFlags member contains the flag
 TTF_IDISHWND. 
     Application-defined tool ID if the TTF_IDISHWND flag is not specified. Since this means you use a tool which
     covers only a part of the client area, it's logical that you can have many such tools on the same client 
     area (without overlap). The tooltip control needs a way to differentiate between them. In this case, the 
     window handle in hWnd member is not enough since all tools are on the same window. The application-defined
     IDs are thus necessary. The IDs can be any value so long as they are unique among themselves. 
     The handle to the window whose whole client area is used as the tool if the TTF_IDISHWND flag is specified. 
     You may wonder why this field is used to store the window handle instead of the hWnd field above. The answer 
     is: the hWnd member may already be filled if the value LPSTR_TEXTCALLBACK is specified in the lpszText member
     and the window that is responsible for supplying the tooltip text and the window that contains the tool may
     NOT be the same ( You can design your program so that a single window can serve both roles but this is too 
     restrictive. In this case, Microsoft gives you more freedom. Cheers.) 
     
     rect A RECT structure that specifies the dimension of the tool. This structure defines a rectangle relative 
     to the upper left corner of the client area of the window specified by the hWnd member. In short, you must 
     fill this structure if you want to specify a tool that covers only a part of the client area. The tooltip 
     control will ignore this field if you specify TTF_IDISHWND flag (you choose to use a tool that covers the 
     whole client area) 
     hInst The handle of the instance that contains the string resource that will be used as the tooltip text if 
     the value in the lpszText member specifies the string resource identifier. This may sound confusing. Read 
     the explanation of the lpszText member first and you will understand what this field is used for. The tooltip 
     control ignores this field if the lpszText field doesn't contain a string resource identifier. 
     lpszText This field can have several values: 
     If you specify the value LPSTR_TEXTCALLBACK in this field, the tooltip control will send TTN_NEEDTEXT 
     notification message to the window identified by the handle in hWnd field for the text string to be 
     displayed in the tooltip window. This is the most dynamic method of tooltip text update: you can change 
     the tooltip text each time the tooltip window is displayed. 
     If you specify a string resource identifier in this field, when the tooltip control needs to display the
     tooltip text in the tooltip window, it searches for the string in the string table of the instance 
     specified by hInst member. The tooltip control identifies a string resource identifier by checking the
     high word of this field. Since a string resource identifier is a 16-bit value, the high word of this 
     field will always be zero. This method is useful if you plan to port your program to other languages. 
     Since the string resource is defined in a resource script, you don't need to modify the source code.
     You only have to modify the string table and the tooltip texts will change without the risk of introducing 
     bugs into your program. 
     If the value in this field is not LPSTR_TEXTCALLBACK and the high word is not zero, the tooltip control 
     interprets the value as the pointer to a text string that will be used as the tooltip text. This method is 
the easiest to use but the least flexible. 
 

     To recapitulate, you need to fill the TOOLINFO structure prior to submitting it to the tooltip control.
     This structure describes the characteristics of the tool you desire. 
     
     Register the tool with the tooltip control
     After you fill the TOOLINFO structure, you must submit it to tooltip control. A tooltip control c
     an service many tools so it is usually unnecessary to create more than one tooltip control for a window.
     To register a tool with a tooltip control, you send the TTM_ADDTOOL message to the tooltip control. 
     The wParam is not used and the lParam must contain the address of the TOOLINFO structure you want to register.
  
.data? 
ti TOOLINFO <> 
....... 
.code 
....... 
<fill the TOOLINFO structure> 
....... 
     invoke SendMessage, hwndTooltip, TTM_ADDTOOL, NULL, addr ti
     SendMessage for this message will return TRUE if the tool is successfully registered with the tooltip control,
     FALSE otherwise. 
     You can unregister the tool by sending TTM_DELTOOL message to the tooltip control. 
     Relaying Mouse Messages to the Tooltip Control
     When the above step is completed, the tooltip control knows which area it should monitor for mouse messages 
     and what text it should display in the tooltip window. The only thing it lacks is the *trigger* for that 
     action. Think about it: the area specified by the tool is on the client area of the other window. How can 
     the tooltip control intercept the mouse messages destined for that window? It needs to do so in order that 
     it can measure the amount of time the mouse pointer hovers over a point in the tool so that when the specified
     amount of time elapses, the tooltip control shows the tooltip window. There are two methods of accomplishing 
     this goal, one that requires the cooperation of the window that contains the tool and the other without the 
     cooperation on the part of the window. 
     The window that contains the tool must relay the mouse messages to the tooltip control by sending 
     TTM_RELAYEVENT messages to the control. The lParam of this message must contain the address of a MSG structure
     that specifies the message to be relayed to the tooltip control. A tooltip control processes only the 
 following mouse messages: 
WM_LBUTTONDOWN 
WM_MOUSEMOVE 
WM_LBUTTONUP 
WM_RBUTTONDOWN 
WM_MBUTTONDOWN 
WM_RBUTTONUP 
WM_MBUTTONUP 
All other messages are ignored. Thus in the window procedure of the window that contains the tool, there must 
 a switch that does something like this: 
WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD 
....... 
    if uMsg==WM_CREATE 
        ............. 
    elseif uMsg==WM_LBUTTONDOWN || uMsg==WM_MOUSEMOVE || uMsg==WM_LBUTTONUP || uMsg==WM_RBUTTONDOWN || 
    uMsg==WM_MBUTTONDOWN || uMsg==WM_RBUTTONUP || uMsg==WM_MBUTTONUP 
        invoke SendMessage, hwndTooltip, TTM_RELAYEVENT, NULL, addr msg 
        .......... 

     You can specify TTF_SUBCLASS flag in the uFlags member of the TOOLINFO structure. This flag tells the tooltip
     control to subclass the window that contains the tool so it can intercept the mouse messages without the 
     cooperation of the window. This method is easier to use since it doesn't require more coding than specifying
     TTF_SUBCLASS flag and the tooltip control handles all the message interception itself. 
     That's it. At this step, your tooltip control is fully functional. There are several useful tooltip-related 
     messages you should know about. 
     TTM_ACTIVATE.  If you want to disable/enable the tooltip control dynamically, this message is for you. 
     If the wParam value is TRUE, the tooltip control is enabled. If the wParam value is FALSE, the tooltip 
     control is disabled. A tooltip control is enabled when it first created so you don't need to send this message
     to activate it. 
     TTM_GETTOOLINFO and TTM_SETTOOLINFO. If you want to obtain/change the values in the TOOLINFO structure after 
     it was submitted to the tooltip control, use these messages. You need to specify the tool you need to change 
     with the correct uId and hWnd values. If you only want to change the rect member, use TTM_NEWTOOLRECT message.
     If you only want to change the tooltip text, use TTM_UPDATETIPTEXT. 
     TTM_SETDELAYTIME. With this message, you can specify the time delay the tooltip control uses when it's d
     isplaying the tooltip text and much more. 
     Example:
     The following example is a simple dialog box with two buttons. The client area of the dialog box is divided 
     into 4 areas: upper left, upper right, lower left and lower right. Each area is specified as a tool with its 
     own tooltip text. The two buttons also has their own tooltip texts. 
.386 
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\comctl32.inc 
includelib \Masm32\lib\comctl32.lib 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 
DlgProc proto :DWORD,:DWORD,:DWORD,:DWORD 
EnumChild proto :DWORD,:DWORD 
SetDlgToolArea proto :DWORD,:DWORD,:DWORD,:DWORD,:DWORD 
.const 
IDD_MAINDIALOG equ 101 
.data 
ToolTipsClassName db "Tooltips_class32",0 
MainDialogText1 db "This is the upper left area of the dialog",0 
MainDialogText2 db "This is the upper right area of the dialog",0 
MainDialogText3 db "This is the lower left area of the dialog",0 
MainDialogText4 db "This is the lower right area of the dialog",0 
.data? 
hwndTool dd ? 
hInstance dd ? 
.code 
start: 
    invoke GetModuleHandle,NULL 
    mov hInstance,eax 
    invoke DialogBoxParam,hInstance,IDD_MAINDIALOG,NULL,addr DlgProc,NULL 
    invoke ExitProcess,eax 
DlgProc proc hDlg:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 
    LOCAL ti:TOOLINFO 
    LOCAL id:DWORD 
    LOCAL rect:RECT 
    .if uMsg==WM_INITDIALOG 
        invoke InitCommonControls 
        invoke CreateWindowEx,NULL,ADDR ToolTipsClassName,NULL,\ 
            TTS_ALWAYSTIP,CW_USEDEFAULT,\ 
            CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\ 
            hInstance,NULL 
        mov hwndTool,eax 
        mov id,0 
        mov ti.cbSize,sizeof TOOLINFO 
        mov ti.uFlags,TTF_SUBCLASS 
        push hDlg 
        pop ti.hWnd 
        invoke GetWindowRect,hDlg,addr rect 
        invoke SetDlgToolArea,hDlg,addr ti,addr MainDialogText1,id,addr rect 
        inc id 
        invoke SetDlgToolArea,hDlg,addr ti,addr MainDialogText2,id,addr rect 
        inc id 
        invoke SetDlgToolArea,hDlg,addr ti,addr MainDialogText3,id,addr rect 
        inc id 
        invoke SetDlgToolArea,hDlg,addr ti,addr MainDialogText4,id,addr rect 
        invoke EnumChildWindows,hDlg,addr EnumChild,addr ti 
    .elseif uMsg==WM_CLOSE 
        invoke EndDialog,hDlg,NULL 
    .else 
        mov eax,FALSE 
        ret 
    .endif 
    mov eax,TRUE 
    ret 
DlgProc endp 

EnumChild proc uses edi hwndChild:DWORD,lParam:DWORD 
    LOCAL buffer[256]:BYTE 
    mov edi,lParam 
    assume edi:ptr TOOLINFO 
    push hwndChild 
    pop [edi].uId 
    or [edi].uFlags,TTF_IDISHWND 
    invoke GetWindowText,hwndChild,addr buffer,255 
    lea eax,buffer 
    mov [edi].lpszText,eax 
    invoke SendMessage,hwndTool,TTM_ADDTOOL,NULL,edi 
    assume edi:nothing 
    ret 
EnumChild endp 

SetDlgToolArea proc uses edi esi hDlg:DWORD,lpti:DWORD,lpText:DWORD,id:DWORD,lprect:DWORD 
    mov edi,lpti 
    mov esi,lprect 
    assume esi:ptr RECT 
    assume edi:ptr TOOLINFO 
    .if id==0 
        mov [edi].rect.left,0 
        mov [edi].rect.top,0 
        mov eax,[esi].right 
        sub eax,[esi].left 
        shr eax,1 
        mov [edi].rect.right,eax 
        mov eax,[esi].bottom 
        sub eax,[esi].top 
        shr eax,1 
        mov [edi].rect.bottom,eax 
    .elseif id==1 
        mov eax,[esi].right 
        sub eax,[esi].left 
        shr eax,1 
        inc eax 
        mov [edi].rect.left,eax 
        mov [edi].rect.top,0 
        mov eax,[esi].right 
        sub eax,[esi].left 
        mov [edi].rect.right,eax 
        mov eax,[esi].bottom 
        sub eax,[esi].top 
        mov [edi].rect.bottom,eax 
    .elseif id==2 
        mov [edi].rect.left,0 
        mov eax,[esi].bottom 
        sub eax,[esi].top 
        shr eax,1 
        inc eax 
        mov [edi].rect.top,eax 
        mov eax,[esi].right 
        sub eax,[esi].left 
        shr eax,1 
        mov [edi].rect.right,eax 
        mov eax,[esi].bottom 
        sub eax,[esi].top 
        mov [edi].rect.bottom,eax 
    .else 
        mov eax,[esi].right 
        sub eax,[esi].left 
        shr eax,1 
        inc eax 
        mov [edi].rect.left,eax 
        mov eax,[esi].bottom 
        sub eax,[esi].top 
        shr eax,1 
        inc eax 
        mov [edi].rect.top,eax 
        mov eax,[esi].right 
        sub eax,[esi].left 
        mov [edi].rect.right,eax 
        mov eax,[esi].bottom 
        sub eax,[esi].top 
        mov [edi].rect.bottom,eax 
    .endif 
    push lpText 
    pop [edi].lpszText 
    invoke SendMessage,hwndTool,TTM_ADDTOOL,NULL,lpti 
    assume edi:nothing 
    assume esi:nothing 
    ret 
SetDlgToolArea endp 
end start

Analysis:
After the main dialog window is created, we create the tooltip control with CreateWindowEx. 
invoke InitCommonControls 
invoke CreateWindowEx,NULL,ADDR ToolTipsClassName,NULL,\ 
       TTS_ALWAYSTIP,CW_USEDEFAULT,\ 
       CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\ 
       hInstance,NULL 
mov hwndTool,eax
After that, we proceed to define four tools for each corner of the dialog box. 
    mov id,0        ; used as the tool ID 
    mov ti.cbSize,sizeof TOOLINFO 
    mov ti.uFlags,TTF_SUBCLASS    ; tell the tooltip control to subclass the dialog window. 
    push hDlg 
    pop ti.hWnd    ; handle to the window that contains the tool 
    invoke GetWindowRect,hDlg,addr rect    ; obtain the dimension of the client area 
    invoke SetDlgToolArea,hDlg,addr ti,addr MainDialogText1,id,addr rect 
     
     We initialize the members of TOOLINFO structure. Note that we want to divide the client area into 4 tools 
     so we need to know the dimension of the client area. That's why we call GetWindowRect. We don't want to relay 
     
     mouse messages to the tooltip control ourselves so we specify TIF_SUBCLASS flag. 
     SetDlgToolArea is a function that calculates the bounding rectangle of each tool and registers the tool to the
     tooltip control. I won't go into gory detail on the calculation, suffice to say that it divides the client 
     area into 4 areas with the same sizes. Then it sends TTM_ADDTOOL message to the tooltip control, passing the
     address of the TOOLINFO structure in the lParam parameter. 
     
     invoke SendMessage,hwndTool,TTM_ADDTOOL,NULL,lpti 
     
     After all 4 tools are registered, we can go on to the buttons on the dialog box. We can handle each button by
     its ID but this is tedious. Instead, we will use EnumChildWindows API call to enumerate all controls on the 
     dialog box and then registers them to the tooltip control. EnumChildWindows has the following syntax: 
     
     EnumChildWindows proto hWnd:DWORD, lpEnumFunc:DWORD, lParam:DWORD
     hWnd is the handle to the parent window. lpEnumFunc is the address of the EnumChildProc function that will be
     called for each control enumerated. lParam is the application-defined value that will be passed to the 
     EnumChildProc function. The EnumChildProc function has the following definition: 
     EnumChildProc proto hwndChild:DWORD, lParam:DWORD
     hwndChild is the handle to a control enumerated by EnumChildWindows. lParam is the same lParam value you pass 
     to EnumChildWindows. 
     In our example, we call EnumChildWindows like this: 
     invoke EnumChildWindows,hDlg,addr EnumChild,addr ti
     We pass the address of the TOOLINFO structure in the lParam parameter because we will register each child 
     control to the tooltip control in the EnumChild function. If we don't use this method, we need to declare ti 
     as a global variable which can introduce bugs. 
     When we call EnumChildWindows, Windows will enumerate the child controls on our dialog box and call the 
     EnumChild function once for each control enumerated. Thus if our dialog box has two controls, EnumChild 
     will be called twice. 
     The EnumChild function fills the relevant members of the TOOLINFO structure and then registers the tool 
     with the tooltip control. 
EnumChild proc uses edi hwndChild:DWORD,lParam:DWORD 
    LOCAL buffer[256]:BYTE 
    mov edi,lParam 
    assume edi:ptr TOOLINFO 
    push hwndChild 
    pop [edi].uId    ; we use the whole client area of the control as the tool 
    or [edi].uFlags,TTF_IDISHWND 
    invoke GetWindowText,hwndChild,addr buffer,255 
    lea eax,buffer    ; use the window text as the tooltip text 
    mov [edi].lpszText,eax 
    invoke SendMessage,hwndTool,TTM_ADDTOOL,NULL,edi 
    assume edi:nothing 
    ret 
     EnumChild endp
     Note that in this case, we use a different type of tool: one that covers the whole client area of the window. 
     We thus need to fill the uID field with the handle to the window that contains the tool. Also we must specify
     TTF_IDISHWND flag in the uFlags member.
     
     
     Unfortunately you can't run Java applets  
     
     
     Tutorial 28: Win32 Debug API Part 1
     
     In this tutorial, you'll learn what Win32 offers to developers regarding debugging primitives. You'll know how 
     to debug a process when you're finished with this tutorial.
     
     Theory:
     Win32 has several APIs that allow programmers to use some of the powers of a debugger. They are called Win32 
     Debug APIs or primitives. With them, you can:
     
     Load a program or attach to a running program for debugging 
     Obtain low-level information about the program you're debugging, such as process ID, address of entrypoint, 
     image base and so on. 
     Be notified of debugging-related events such as when a process/thread starts/exits, DLLs are loaded/unloaded
     etc. 
     Modify the process/thread being debugged 
     In short, you can code a simple debugger with those APIs. Since this subject is vast, I divide it into several
     managable parts: this tutorial being the first part. I'll explain the basic concepts and general framework 
     for using Win32 Debug APIs in this tutorial.
     The steps in using Win32 Debug APIs are:
     
     Create a process or attach your program to a running process. This is the first step in using Win32 Debug APIs.
     Since your program will act as a debugger, you need a program to debug. The program being debugged is called 
     a debuggee. You can acquire a debuggee in two ways: 
     You can create the debuggee process yourself with CreateProcess. In order to create a process for debugging, 
     you must specify the DEBUG_PROCESS flag. This flag tells Windows that we want to debug the process. Windows 
     will send notifications of important debugging-related events (debug events) that occur in the debuggee to 
     your program. The debuggee process will be immediately suspended until your program is ready. If the debuggee 
     also creates child processes, Windows will also send debug events that occur in all those child processes to
     your program as well. This behavior is usually undesirable. You can disable this behavior by specifying 
     DEBUG_ONLY_THIS_PROCESS flag in combination of DEBUG_PROCESS flag. 
     You can attach your program to a running process with DebugActiveProcess. 
     Wait for debugging events. After your program acquired a debuggee, the debuggee's primary thread is suspended 
     and will continue to be suspended until your program calls WaitForDebugEvent. This function works like other 
     WaitForXXX functions, ie. it blocks the calling thread until the waited-for event occurs. In this case, 
     it waits for debug events to be sent by Windows. Let's see its definition: 
     WaitForDebugEvent proto lpDebugEvent:DWORD, dwMilliseconds:DWORD
     
     lpDebugEvent is the address of a DEBUG_EVENT structure that will be filled with information about the debug 
     event that occurs within the debuggee.
     
     dwMilliseconds is the length of time in milliseconds this function will wait for the debug event to occur. 
     If this period elapses and no debug event occurs, WaitForDebugEvent returns to the caller. On the other hand,
     if you specify INFINITE constant in this argument, the function will not return until a debug event occurs.
     
     Now let's examine the DEBUG_EVENT structure in more detail.

DEBUG_EVENT STRUCT 
   dwDebugEventCode dd ? 
   dwProcessId dd ? 
   dwThreadId dd ? 
   u DEBUGSTRUCT <> 
DEBUG_EVENT ENDS 

dwDebugEventCode contains the value that specifies what type of debug event occurs. In short, there can be 
many types of events, your program needs to check the value in this field so it knows what type of event 
occurs and responds appropriately. The possible values are:

Value Meanings 
CREATE_PROCESS_DEBUG_EVENT A process is created. This event will be sent when the debuggee process is just 
created (and not yet running) or when your program just attaches itself to a running process with 
DebugActiveProcess. This is the first event your program will receive. 
EXIT_PROCESS_DEBUG_EVENT A process exits. 
CREATE_THEAD_DEBUG_EVENT A new thread is created in the debuggee process or when your program first attaches 
itself to a running process. Note that you'll not receive this notification when the primary thread of the 
debuggee is created.  
EXIT_THREAD_DEBUG_EVENT A thread in the debuggee process exits. Your program will not receive this event for 
the primary thread. In short, you can think of the primary thread of the debuggee as the equivalent of the 
debuggee process itself. Thus, when your program sees CREATE_PROCESS_DEBUG_EVENT, it's actually 
the CREATE_THREAD_DEBUG_EVENT for the primary thread. 
LOAD_DLL_DEBUG_EVENT The debuggee loads a DLL. You'll receive this event when the PE loader first resolves 
the links to DLLs (you call CreateProcess to load the debuggee) and when the debuggee calls LoadLibrary. 
UNLOAD_DLL_DEBUG_EVENT A DLL is unloaded from the debuggee process.  
EXCEPTION_DEBUG_EVENT An exception occurs in the debuggee process. Important: This event will occur once 
just before the debuggee starts executing its first instruction. The exception is actually a debug break 
(int 3h). When you want to resume the debuggee, call ContinueDebugEvent with DBG_CONTINUE flag. Don't 
use DBG_EXCEPTION_NOT_HANDLED flag else the debuggee will refuse to run under NT (on Win98, it works fine). 
OUTPUT_DEBUG_STRING_EVENT This event is generated when the debuggee calls DebugOutputString function to 
send a message string to your program.  
RIP_EVENT System debugging error occurs 

dwProcessId and dwThreadId are the process and thread Ids of the process that the debug event occurs. 
You can use these values as identifiers of the process/thread you're interested in. Remember that if 
you use CreateProcess to load the debuggee, you also get the process and thread IDs of the debuggee in 
the PROCESS_INFO structure. You can use these values to differentiate between the debug events occurring 
in the debuggee and its child processes (in case you didn't specify DEBUG_ONLY_THIS_PROCESS flag).

u is a union that contains more information about the debug event. It can be one of the following 
structures depending on the value of dwDebugEventCode above. 

value in dwDebugEventCode Interpretation of u 
CREATE_PROCESS_DEBUG_EVENT A CREATE_PROCESS_DEBUG_INFO structure named CreateProcessInfo 
EXIT_PROCESS_DEBUG_EVENT An EXIT_PROCESS_DEBUG_INFO structure named ExitProcess 
CREATE_THREAD_DEBUG_EVENT A CREATE_THREAD_DEBUG_INFO structure named CreateThread 
EXIT_THREAD_DEBUG_EVENT An EXIT_THREAD_DEBUG_EVENT structure named ExitThread 
LOAD_DLL_DEBUG_EVENT A LOAD_DLL_DEBUG_INFO structure named LoadDll 
UNLOAD_DLL_DEBUG_EVENT An UNLOAD_DLL_DEBUG_INFO structure named UnloadDll 
EXCEPTION_DEBUG_EVENT An EXCEPTION_DEBUG_INFO structure named Exception 
OUTPUT_DEBUG_STRING_EVENT An OUTPUT_DEBUG_STRING_INFO structure named DebugString 
RIP_EVENT A RIP_INFO structure named RipInfo 

I won't go into detail about all those structures in this tutorial, only the CREATE_PROCESS_DEBUG_INFO struc
ture will be covered here. 
Assuming that our program calls WaitForDebugEvent and it returns. The first thing we should do is to examine 
the value in dwDebugEventCode to see which type of debug event occured in the debuggee process. For example, 
if the value in dwDebugEventCode is CREATE_PROCESS_DEBUG_EVENT, you can interpret the member in u as 
CreateProcessInfo and access it with u.CreateProcessInfo. 

Do whatever your program want to do in response to the debug event. When WaitForDebugEvent returns, it means 
a debug event just occurred in the debuggee process or a timeout occurs. Your program needs to examine the 
value in dwDebugEventCode in order to react to the event appropriately. In this regard, it's like processing
 Windows messages: you choose to handle some and ignore some. 
Let the debuggee continues execution. When a debug event occurs, Windows suspends the debuggee. When 
you're finished with the event handling, you need to kick the debuggee into moving again. You do this 
by calling ContinueDebugEvent function. 
ContinueDebugEvent proto dwProcessId:DWORD, dwThreadId:DWORD, dwContinueStatus:DWORD

This function resumes the thread that was previously suspended because a debug event occurred.
dwProcessId and dwThreadId are the process and thread IDs of the thread that will be resumed. You usually 
take these two values from the dwProcessId and dwThreadId members of the DEBUG_EVENT structure.
dwContinueStatus specifies how to continue the thread that reported the debug event. There are two possible
 values: DBG_CONTINUE and DBG_EXCEPTION_NOT_HANDLED. For all other debug events, those two values do 
 the same thing: resume the thread. The exception is the EXCEPTION_DEBUG_EVENT. If the thread reports 
 an exception debug event, it means an exception occurred in the debuggee thread. If you specify DBG_CONTINUE,
  the thread will ignore its own exception handling and continue with the execution. In this scenario, your 
  program must examine and resolve the exception itself before resuming the thread with DBG_CONTINUE 
  else the exception will occur again and again and again.... If you specify DBG_EXCEPTION_NOT_HANDLED, 
  your program is telling Windows that it didn't handle the exception: Windows should use the default 
  exception handler of the debuggee to handle the exception. 
In conclusion, if the debug event refers to an exception in the debuggee process, you should call 
ContinueDebugEvent with DBG_CONTINUE flag if your program already removed the cause of exception. Otherwise,
 your program must call ContinueDebugEvent with DBG_EXCEPTION_NOT_HANDLED flag. Except in one case which you
  must always use DBG_CONTINUE flag: the first EXCEPTION_DEBUG_EVENT which has the value EXCEPTION_BREAKPOINT
   in the ExceptionCode member. When the debuggee is going to execute its very first instruction, 
   your program will receive the exception debug event. It's actually a debug break (int 3h). If you 
   respond by calling ContinueDebugEvent with DBG_EXCEPTION_NOT_HANDLED flag, Windows NT will refuse to 
   run the debuggee (because no one cares for it). You must always use DBG_CONTINUE flag in this case to 
   tell Windows that you want the thread to go on.

Continue this cycle in an infinite loop until the debuggee process exits. Your program must be in an i
nfinite loop much like a message loop until the debuggee exits. The loop looks like this: 
.while TRUE
    invoke WaitForDebugEvent, addr DebugEvent, INFINITE
   .break .if DebugEvent.dwDebugEventCode==EXIT_PROCESS_DEBUG_EVENT
   <Handle the debug events>
   invoke ContinueDebugEvent, DebugEvent.dwProcessId, DebugEvent.dwThreadId, DBG_EXCEPTION_NOT_HANDLED 
.endw 


Here's the catch: Once you start debugging a program, you just can't detach from the debuggee until it exits.

Let's summarize the steps again:

Create a process or attach your program to a running process. 
Wait for debugging events 
Do whatever your program want to do in response to the debug event. 
Let the debuggee continues execution. 
Continue this cycle in an infinite loop until the debuggee process exits 
Example:
This example debugs a win32 program and shows important information such as the process handle, process Id, 
image base and so on.

.386 
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\comdlg32.inc 
include \Masm32\include\user32.inc 
includelib \Masm32\lib\kernel32.lib 
includelib \Masm32\lib\comdlg32.lib 
includelib \Masm32\lib\user32.lib 
.data 
AppName db "Win32 Debug Example no.1",0 
ofn OPENFILENAME <> 
FilterString db "Executable Files",0,"*.exe",0 
             db "All Files",0,"*.*",0,0 
ExitProc db "The debuggee exits",0 
NewThread db "A new thread is created",0 
EndThread db "A thread is destroyed",0 
ProcessInfo db "File Handle: %lx ",0dh,0Ah 
            db "Process Handle: %lx",0Dh,0Ah 
            db "Thread Handle: %lx",0Dh,0Ah 
            db "Image Base: %lx",0Dh,0Ah 
            db "Start Address: %lx",0 
.data? 
buffer db 512 dup(?) 
startinfo STARTUPINFO <> 
pi PROCESS_INFORMATION <> 
DBEvent DEBUG_EVENT <> 
.code 
start: 
mov ofn.lStructSize,sizeof ofn 
mov ofn.lpstrFilter, offset FilterString 
mov ofn.lpstrFile, offset buffer 
mov ofn.nMaxFile,512 
mov ofn.Flags, OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY 
invoke GetOpenFileName, ADDR ofn 
.if eax==TRUE 
invoke GetStartupInfo,addr startinfo 
invoke CreateProcess, addr buffer, NULL, NULL, NULL, FALSE, DEBUG_PROCESS+ DEBUG_ONLY_THIS_PROCESS, NULL, NULL, addr startinfo, addr pi 
.while TRUE 
   invoke WaitForDebugEvent, addr DBEvent, INFINITE 
   .if DBEvent.dwDebugEventCode==EXIT_PROCESS_DEBUG_EVENT 
       invoke MessageBox, 0, addr ExitProc, addr AppName, MB_OK+MB_ICONINFORMATION 
       .break 
   .elseif DBEvent.dwDebugEventCode==CREATE_PROCESS_DEBUG_EVENT 
       invoke wsprintf, addr buffer, addr ProcessInfo, DBEvent.u.CreateProcessInfo.hFile, DBEvent.u.CreateProcessInfo.hProcess, DBEvent.u.CreateProcessInfo.hThread, DBEvent.u.CreateProcessInfo.lpBaseOfImage, DBEvent.u.CreateProcessInfo.lpStartAddress 
       invoke MessageBox,0, addr buffer, addr AppName, MB_OK+MB_ICONINFORMATION    
   .elseif DBEvent.dwDebugEventCode==EXCEPTION_DEBUG_EVENT 
       .if DBEvent.u.Exception.pExceptionRecord.ExceptionCode==EXCEPTION_BREAKPOINT 
          invoke ContinueDebugEvent, DBEvent.dwProcessId, DBEvent.dwThreadId, DBG_CONTINUE 
         .continue 
       .endif 
   .elseif DBEvent.dwDebugEventCode==CREATE_THREAD_DEBUG_EVENT 
       invoke MessageBox,0, addr NewThread, addr AppName, MB_OK+MB_ICONINFORMATION 
   .elseif DBEvent.dwDebugEventCode==EXIT_THREAD_DEBUG_EVENT 
       invoke MessageBox,0, addr EndThread, addr AppName, MB_OK+MB_ICONINFORMATION 
   .endif 
   invoke ContinueDebugEvent, DBEvent.dwProcessId, DBEvent.dwThreadId, DBG_EXCEPTION_NOT_HANDLED 
.endw 
invoke CloseHandle,pi.hProcess 
invoke CloseHandle,pi.hThread 
.endif 
invoke ExitProcess, 0 
end start 

Analysis:
The program fills the OPENFILENAME structure and then calls GetOpenFileName to let the user choose a program 
to be debugged.

invoke GetStartupInfo,addr startinfo 
invoke CreateProcess, addr buffer, NULL, NULL, NULL, FALSE, DEBUG_PROCESS+ DEBUG_ONLY_THIS_PROCESS, NULL, 
NULL, addr startinfo, addr pi 

When the user chose one, it calls CreateProcess to load the program. It calls GetStartupInfo to fill the 
STARTUPINFO structure with its default values. Note that we use DEBUG_PROCESS combined with 
DEBUG_ONLY_THIS_PROCESS flags in order to debug only this program, not including its child processes.

.while TRUE 
   invoke WaitForDebugEvent, addr DBEvent, INFINITE 


When the debuggee is loaded, we enter the infinite debug loop, calling WaitForDebugEvent. WaitForDebugEvent 
will not return until a debug event occurs in the debuggee because we specify INFINITE as its second parameter.
 When a debug event occurred, WaitForDebugEvent returns and DBEvent is filled with information about the debug
  event.

   .if DBEvent.dwDebugEventCode==EXIT_PROCESS_DEBUG_EVENT 
       invoke MessageBox, 0, addr ExitProc, addr AppName, MB_OK+MB_ICONINFORMATION 
       .break 

We first check the value in dwDebugEventCode. If it's EXIT_PROCESS_DEBUG_EVENT, we display a message box 
saying "The debuggee exits" and then get out of the debug loop.

   .elseif DBEvent.dwDebugEventCode==CREATE_PROCESS_DEBUG_EVENT 
       invoke wsprintf, addr buffer, addr ProcessInfo, DBEvent.u.CreateProcessInfo.hFile, DBEvent.u.
       CreateProcessInfo.hProcess, DBEvent.u.CreateProcessInfo.hThread, DBEvent.u.CreateProcessInfo.
       lpBaseOfImage, DBEvent.u.CreateProcessInfo.lpStartAddress 
       invoke MessageBox,0, addr buffer, addr AppName, MB_OK+MB_ICONINFORMATION    

If the value in dwDebugEventCode is CREATE_PROCESS_DEBUG_EVENT, then we display several interesting 
information about the debuggee in a message box. We obtain those information from u.CreateProcessInfo. 
CreateProcessInfo is a structure of type CREATE_PROCESS_DEBUG_INFO. You can get more info about this 
structure from Win32 API reference. 

   .elseif DBEvent.dwDebugEventCode==EXCEPTION_DEBUG_EVENT 
       .if DBEvent.u.Exception.pExceptionRecord.ExceptionCode==EXCEPTION_BREAKPOINT 
          invoke ContinueDebugEvent, DBEvent.dwProcessId, DBEvent.dwThreadId, DBG_CONTINUE 
         .continue 
       .endif 

If the value in dwDebugEventCode is EXCEPTION_DEBUG_EVENT, we must check further for the exact type of 
exception. It's a long line of nested structure reference but you can obtain the kind of exception from 
ExceptionCode member. If the value in ExceptionCode is EXCEPTION_BREAKPOINT and it occurs for the first 
time (or if we are sure that the debuggee has no embedded int 3h), we can safely assume that this exception 
occured when the debuggee was going to execute its very first instruction. When we are done with the 
processing, we must call ContinueDebugEvent with DBG_CONTINUE flag to let the debuggee run. Then we go
 back to wait for the next debug event.

   .elseif DBEvent.dwDebugEventCode==CREATE_THREAD_DEBUG_EVENT 
       invoke MessageBox,0, addr NewThread, addr AppName, MB_OK+MB_ICONINFORMATION 
   .elseif DBEvent.dwDebugEventCode==EXIT_THREAD_DEBUG_EVENT 
       invoke MessageBox,0, addr EndThread, addr AppName, MB_OK+MB_ICONINFORMATION 
   .endif 

If the value in dwDebugEventCode is CREATE_THREAD_DEBUG_EVENT or EXIT_THREAD_DEBUG_EVENT, we display a message 
box saying so.

   invoke ContinueDebugEvent, DBEvent.dwProcessId, DBEvent.dwThreadId, DBG_EXCEPTION_NOT_HANDLED 
.endw 

Except for the EXCEPTION_DEBUG_EVENT case above, we call ContinueDebugEvent with DBG_EXCEPTION_NOT_HANDLED 
flag to resume the debuggee.

invoke CloseHandle,pi.hProcess 
invoke CloseHandle,pi.hThread 

When the debuggee exits, we are out of the debug loop and must close both process and thread handles of the 
debuggee. Closing the handles doesn't mean we are killing the process/thread. It just means we don't want to 
use those handles to refer to the process/thread anymore. 

Unfortunately you can't run Java applets  


Tutorial 29: Win32 Debug API Part 2
  
We continue with the subject of win32 debug API. In this tutorial, we will learn how to modify the debuggee 
process.

Theory:
In the previous tutorial, we know how to load the debuggee and handle debug events that occur in its process. 
In order to be useful, our program must be able to modify the debuggee process. There are several APIs just 
for this purpose.

ReadProcessMemory This function allows you to read memory in the specified process. The function prototype 
is as follows: 
ReadProcessMemory proto hProcess:DWORD, lpBaseAddress:DWORD, lpBuffer:DWORD, nSize:DWORD, lpNumberOfBytesRead:
DWORD

hProcess is the handle to the process you want to read.
lpBaseAddress is the address in the target process you want to start reading. For example, if you want to 
read 4 bytes from the debuggee process starting at 401000h, the value in this parameter must be 401000h.
lpBuffer is the address of the buffer to receive the bytes read from the process. 
nSize is the number of bytes you want to read
lpNumberOfBytesRead is the address of the variable of dword size that receives the number of bytes actually
 read. If you don't care about it, you can use NULL.

WriteProcessMemory is the counterpart of ReadProcessMemory. It enables you to write memory of the target 
process. Its parameters are exactly the same as those of ReadProcessMemory 
The next two API functions need a little background on context. Under a multitasking OS like Windows, 
there can be several programs running at the same time. Windows gives each thread a timeslice. When that 
timeslice expires, Windows freezes the present thread and switches to the next thread that has the highest
 priority. Just before switching to the other thread, Windows saves values in registers of the present 
 thread so that when the time comes to resume the thread, Windows can restore the last *environment* of 
 that thread. The saved values of the registers are collectively called a context. 
Back to our subject. When a debug event occurs, Windows suspends the debuggee. The debuggee's context
is saved. Since the debuggee is suspended, we can be sure that the values in the context will remain 
unchanged . We can get the values in the context with GetThreadContext and we can change them with 
SetThreadContext.
These two APIs are very powerful. With them, you have at your fingertips the VxD-like power over the 
debuggee: you can alter the saved register values and just before the debuggee resumes execution, 
the values in the context will be written back into the registers. Any change you made to the context 
is reflected back to the debuggee. Think about it: you can even alter the value of the eip register 
and divert the flow of execution to anywhere you like! You won't be able to do that under normal circumstance.


GetThreadContext proto hThread:DWORD, lpContext:DWORD 

hThread is the handle to the thread that you want to obtain the context from
lpContext is the address of the CONTEXT structure that will be filled when the function returns successfully.

SetThreadContext has exactly the same parameters. Let's see what a CONTEXT structure looks like:

CONTEXT STRUCT 

ContextFlags dd ? 
;----------------------------------------------------------------------------------------------------------
; This section is returned if ContextFlags contains the value CONTEXT_DEBUG_REGISTERS 
;-----------------------------------------------------------------------------------------------------------
iDr0 dd ? 
iDr1 dd ? 
iDr2 dd ? 
iDr3 dd ? 
iDr6 dd ? 
iDr7 dd ? 

;----------------------------------------------------------------------------------------------------------
; This section is returned if ContextFlags contains the value CONTEXT_FLOATING_POINT 
;-----------------------------------------------------------------------------------------------------------

FloatSave FLOATING_SAVE_AREA <> 

;----------------------------------------------------------------------------------------------------------
; This section is returned if ContextFlags contains the value CONTEXT_SEGMENTS 
;----------------------------------------------------------------------------------------------------------- 
regGs dd ? 
regFs dd ? 
regEs dd ? 
regDs dd ? 

;----------------------------------------------------------------------------------------------------------
; This section is returned if ContextFlags contains the value CONTEXT_INTEGER 
;----------------------------------------------------------------------------------------------------------- 
regEdi dd ? 
regEsi dd ? 
regEbx dd ? 
regEdx dd ? 
regEcx dd ? 
regEax dd ? 

;----------------------------------------------------------------------------------------------------------
; This section is returned if ContextFlags contains the value CONTEXT_CONTROL 
;----------------------------------------------------------------------------------------------------------- 
regEbp dd ? 
regEip dd ? 
regCs dd ? 
regFlag dd ? 
regEsp dd ? 
regSs dd ? 

;----------------------------------------------------------------------------------------------------------
; This section is returned if ContextFlags contains the value CONTEXT_EXTENDED_REGISTERS 
;----------------------------------------------------------------------------------------------------------- 
ExtendedRegisters db MAXIMUM_SUPPORTED_EXTENSION dup(?) CONTEXT ENDS 
As you can observe, the members of this structures are mimics of the real processor's registers. Before you 
can use this structure, you need to specify which groups of registers you want to read/write in ContextFlags 
member. For example, if you want to read/write all registers, you must specify CONTEXT_FULL in ContextFlags. 
If you want only to read/write regEbp, regEip, regCs, regFlag, regEsp or regSs, you must specify 
CONTEXT_CONTROL in ContextFlags.

One thing you must remember when using the CONTEXT structure: it must be aligned on dword boundary 
else you'd get strange results under NT. You must put "align dword" just above the line that declares it,
 like this: 

align dword
MyContext CONTEXT <>

Example:
The first example demonstrates the use of DebugActiveProcess. First, you need to run a target named win.exe
 which goes in an infinite loop just before the window is shown on the screen. Then you run the example, 
 it will attach itself to win.exe and modify the code of win.exe such that win.exe exits the infinite 
 loop and shows its own window.

.386 
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\comdlg32.inc 
include \Masm32\include\user32.inc 
includelib \Masm32\lib\kernel32.lib 
includelib \Masm32\lib\comdlg32.lib 
includelib \Masm32\lib\user32.lib 

.data 
AppName db "Win32 Debug Example no.2",0 
ClassName db "SimpleWinClass",0 
SearchFail db "Cannot find the target process",0 
TargetPatched db "Target patched!",0 
buffer dw 9090h

.data? 
DBEvent DEBUG_EVENT <> 
ProcessId dd ? 
ThreadId dd ? 
align dword 
context CONTEXT <> 

.code 
start: 
invoke FindWindow, addr ClassName, NULL 
.if eax!=NULL 
    invoke GetWindowThreadProcessId, eax, addr ProcessId 
    mov ThreadId, eax 
    invoke DebugActiveProcess, ProcessId 
    .while TRUE 
       invoke WaitForDebugEvent, addr DBEvent, INFINITE 
       .break .if DBEvent.dwDebugEventCode==EXIT_PROCESS_DEBUG_EVENT 
       .if DBEvent.dwDebugEventCode==CREATE_PROCESS_DEBUG_EVENT 
          mov context.ContextFlags, CONTEXT_CONTROL 
          invoke GetThreadContext,DBEvent.u.CreateProcessInfo.hThread, addr context           
          invoke WriteProcessMemory, DBEvent.u.CreateProcessInfo.hProcess, context.regEip ,addr buffer, 2, NULL
          invoke MessageBox, 0, addr TargetPatched, addr AppName, MB_OK+MB_ICONINFORMATION 
       .elseif DBEvent.dwDebugEventCode==EXCEPTION_DEBUG_EVENT 
          .if DBEvent.u.Exception.pExceptionRecord.ExceptionCode==EXCEPTION_BREAKPOINT 
             invoke ContinueDebugEvent, DBEvent.dwProcessId,DBEvent.dwThreadId, DBG_CONTINUE 
             .continue 
          .endif 
       .endif 
       invoke ContinueDebugEvent, DBEvent.dwProcessId, DBEvent.dwThreadId, DBG_EXCEPTION_NOT_HANDLED 
   .endw 
.else 
    invoke MessageBox, 0, addr SearchFail, addr AppName,MB_OK+MB_ICONERROR .endif 
invoke ExitProcess, 0 
end start 

;--------------------------------------------------------------------
; The partial source code of win.asm, our debuggee. It's actually
; the simple window example in tutorial 2 with an infinite loop inserted
; just before it enters the message loop.
;----------------------------------------------------------------------

......
mov wc.hIconSm,eax 
invoke LoadCursor,NULL,IDC_ARROW 
mov wc.hCursor,eax 
invoke RegisterClassEx, addr wc 
INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\ WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\ hInst,NULL 
mov hwnd,eax 
jmp $ <---- Here's our infinite loop. It assembles to EB FE
invoke ShowWindow, hwnd,SW_SHOWNORMAL 
invoke UpdateWindow, hwnd 
.while TRUE 
   invoke GetMessage, ADDR msg,NULL,0,0 
   .break .if (!eax) 
   invoke TranslateMessage, ADDR msg 
   invoke DispatchMessage, ADDR msg 
.endw 
mov eax,msg.wParam 
ret 
WinMain endp 

Analysis:
invoke FindWindow, addr ClassName, NULL 

Our program needs to attach itself to the debuggee with DebugActiveProcess which requires the process Id of 
the debuggee. We can obtain the process Id by calling GetWindowThreadProcessId which in turn needs the window
 handle as its parameter. So we need to obtain the window handle first. 
With FindWindow, we can specify the name of the window class we need. It returns the handle to the window 
created by that window class. If it returns NULL, no window of that class is present.

.if eax!=NULL 
    invoke GetWindowThreadProcessId, eax, addr ProcessId 
    mov ThreadId, eax 
    invoke DebugActiveProcess, ProcessId 

After we obtain the process Id, we can call DebugActiveProcess. Then we enter the debug loop waiting for the 
debug events.

       .if DBEvent.dwDebugEventCode==CREATE_PROCESS_DEBUG_EVENT 
          mov context.ContextFlags, CONTEXT_CONTROL 
          invoke GetThreadContext,DBEvent.u.CreateProcessInfo.hThread, addr context           

When we get CREATE_PROCESS_DEBUG_INFO, it means the debuggee is suspended, ready for us to do surgery upon 
its process. In this example, we will overwrite the infinite loop instruction in the debuggee (0EBh 0FEh) 
with NOPs ( 90h 90h). 
First, we need to obtain the address of the instruction. Since the debuggee is already in the loop by the 
time our program attached to it, eip will always point to the instruction. All we need to do is obtain the 
value of eip. We use GetThreadContext to achieve that goal. We set the ContextFlags member to CONTEXT_CONTROL
 so as to tell GetThreadContext that we want it to fill the "control" register members of the CONTEXT 
 structure.

          invoke WriteProcessMemory, DBEvent.u.CreateProcessInfo.hProcess, context.regEip ,addr buffer, 2,
           NULL

Now that we get the value of eip, we can call WriteProcessMemory to overwrite the "jmp $" instruction with
 NOPs, thus effectively help the debuggee exit the infinite loop. After that we display the message to the 
 user and then call ContinueDebugEvent to resume the debuggee. Since the "jmp $" instruction is overwritten
  by NOPs, the debuggee will be able to continue with showing its window and enter the message loop. 
  The evidence is we will see its window on screen.

The other example uses a slightly different approach to break the debuggee out of the infinite loop.

.......
.......
.if DBEvent.dwDebugEventCode==CREATE_PROCESS_DEBUG_EVENT 
   mov context.ContextFlags, CONTEXT_CONTROL 
   invoke GetThreadContext,DBEvent.u.CreateProcessInfo.hThread, addr context 
   add context.regEip,2 
   invoke SetThreadContext,DBEvent.u.CreateProcessInfo.hThread, addr context 
   invoke MessageBox, 0, addr LoopSkipped, addr AppName, MB_OK+MB_ICONINFORMATION 
.......
....... 

It still calls GetThreadContext to obtain the current value of eip but instead of overwriting the "jmp $" 
instruction, it increments the value of regEip by 2 to "skip over" the instruction. The result is that when 
the debuggee regains control , it resumes execution at the next instruction after "jmp $". 

Now you can see the power of Get/SetThreadContext. You can also modify the other register images as well 
and their values will be reflected back to the debuggee. You can even insert int 3h instruction to put
 breakpoints in the debuggee process.

Unfortunately you can't run Java applets  


Tutorial 30: Win32 Debug API part 3
  
In this tutorial, we continue the exploration of win32 debug api. Specifically, we will learn how to trace 
the debuggee.

Theory:
If you have used a debugger before, you would be familiar with tracing. When you "trace" a program, 
the program stops after executing each instruction, giving you the chance to examine the values of registers
/memory. Single-stepping is the official name of tracing.
The single-step feature is provided by the CPU itself. The 8th bit of the flag register is called trap flag. 
If this flag(bit) is set, the CPU executes in single-step mode. The CPU will generate a debug exception after 
each instruction. After the debug exception is generated, the trap flag is cleared automatically.
We can also single-step the debuggee, using win32 debug api. The steps are as follows:

Call GetThreadContext, specifying CONTEXT_CONTROL in ContextFlags, to obtain the value of the flag register. 
Set the trap bit in regFlag member of the CONTEXT structure 
call SetThreadContext 
Wait for the debug events as usual. The debuggee will execute in single-step mode. After it executes each 
instruction, we will get EXCEPTION_DEBUG_EVENT with EXCEPTION_SINGLE_STEP value in u.Exception.
pExceptionRecord.ExceptionCode 
If you need to trace the next instruction, you need to set the trap bit again. 
Example:
.386
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\comdlg32.inc 
include \Masm32\include\user32.inc 
includelib \Masm32\lib\kernel32.lib 
includelib \Masm32\lib\comdlg32.lib 
includelib \Masm32\lib\user32.lib 

.data 
AppName db "Win32 Debug Example no.4",0 
ofn OPENFILENAME <> 
FilterString db "Executable Files",0,"*.exe",0 
             db "All Files",0,"*.*",0,0 
ExitProc db "The debuggee exits",0Dh,0Ah 
         db "Total Instructions executed : %lu",0 
TotalInstruction dd 0

.data? 
buffer db 512 dup(?) 
startinfo STARTUPINFO <> 
pi PROCESS_INFORMATION <> 
DBEvent DEBUG_EVENT <> 
context CONTEXT <> 

.code 
start: 
mov ofn.lStructSize,SIZEOF ofn 
mov ofn.lpstrFilter, OFFSET FilterString 
mov ofn.lpstrFile, OFFSET buffer 
mov ofn.nMaxFile,512 
mov ofn.Flags, OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY 
invoke GetOpenFileName, ADDR ofn 
.if eax==TRUE 
    invoke GetStartupInfo,addr startinfo 
    invoke CreateProcess, addr buffer, NULL, NULL, NULL, FALSE, DEBUG_PROCESS+ DEBUG_ONLY_THIS_PROCESS, NULL, NULL, addr startinfo, addr pi 
    .while TRUE 
       invoke WaitForDebugEvent, addr DBEvent, INFINITE 
       .if DBEvent.dwDebugEventCode==EXIT_PROCESS_DEBUG_EVENT 
          invoke wsprintf, addr buffer, addr ExitProc, TotalInstruction 
          invoke MessageBox, 0, addr buffer, addr AppName, MB_OK+MB_ICONINFORMATION 
          .break 
       .elseif DBEvent.dwDebugEventCode==EXCEPTION_DEBUG_EVENT           .if DBEvent.u.Exception.pExceptionRecord.ExceptionCode==EXCEPTION_BREAKPOINT 
             mov context.ContextFlags, CONTEXT_CONTROL 
             invoke GetThreadContext, pi.hThread, addr context 
             or context.regFlag,100h 
             invoke SetThreadContext,pi.hThread, addr context 
             invoke ContinueDebugEvent, DBEvent.dwProcessId, DBEvent.dwThreadId, DBG_CONTINUE 
             .continue 
          .elseif DBEvent.u.Exception.pExceptionRecord.ExceptionCode==EXCEPTION_SINGLE_STEP 
             inc TotalInstruction 
             invoke GetThreadContext,pi.hThread,addr context or context.regFlag,100h 
             invoke SetThreadContext,pi.hThread, addr context 
             invoke ContinueDebugEvent, DBEvent.dwProcessId, DBEvent.dwThreadId,DBG_CONTINUE 
             .continue 
          .endif 
       .endif 
       invoke ContinueDebugEvent, DBEvent.dwProcessId, DBEvent.dwThreadId, DBG_EXCEPTION_NOT_HANDLED 
    .endw 
.endif 
invoke CloseHandle,pi.hProcess 
invoke CloseHandle,pi.hThread 
invoke ExitProcess, 0 
end start 

Analysis:
The program shows the openfile dialog box. When the user chooses an executable file, it executes the program 
in single-step mode, couting the number of instructions executed until the debuggee exits. 

       .elseif DBEvent.dwDebugEventCode==EXCEPTION_DEBUG_EVENT           .if DBEvent.u.Exception.
       pExceptionRecord.ExceptionCode==EXCEPTION_BREAKPOINT 

We take this opportunity to set the debuggee into single-step mode. Remember that Windows sends 
an EXCEPTION_BREAKPOINT just before it executes the first instruction of the debuggee.

             mov context.ContextFlags, CONTEXT_CONTROL 
             invoke GetThreadContext, pi.hThread, addr context 

We call GetThreadContext to fill the CONTEXT structure with the current values in the registers of 
the debuggee. More specifically, we need the current value of the flag register.

             or context.regFlag,100h 

We set the trap bit (8th bit) in the flag register image.

             invoke SetThreadContext,pi.hThread, addr context 
             invoke ContinueDebugEvent, DBEvent.dwProcessId, DBEvent.dwThreadId, DBG_CONTINUE 
             .continue 

Then we call SetThreadContext to overwrite the values in the CONTEXT structure with the new one(s) 
and call ContinueDebugEvent with DBG_CONTINUE flag to resume the debuggee.

          .elseif DBEvent.u.Exception.pExceptionRecord.ExceptionCode==EXCEPTION_SINGLE_STEP 
             inc TotalInstruction 

When an instruction is executed in the debuggee, we receive an EXCEPTION_DEBUG_EVENT. We must examine the 
value of u.Exception.pExceptionRecord.ExceptionCode. If the value is EXCEPTION_SINGLE_STEP, then this debug 
event is generated because of the single-step mode. In this case, we can increment the variable 
TotalInstruction by one because we know that exactly one instruction was executed in the debuggee.

             invoke GetThreadContext,pi.hThread,addr context or context.regFlag,100h 
             invoke SetThreadContext,pi.hThread, addr context 
             invoke ContinueDebugEvent, DBEvent.dwProcessId, DBEvent.dwThreadId,DBG_CONTINUE 
             .continue 


Since the trap flag is cleared after the debug exception is generated, we must set the trap flag again 
if we want to continue in single-step mode.
Warning: Don't use the example in this tutorial with a large program: tracing is SLOW. You may have to wait
 for ten minutes before you can close the debuggee.
Unfortunately you can't run Java applets  


Tutorial 31: Listview Control
  
We will learn how to create and use the listview control in this tutorial.

Theory:
A listview control is one of the common controls like treeview, richedit etc. You are familiar with it even  
if
 you may not know it by its name. For example, the right pane of Windows Explorer is a listview control.
  A listview control is good for displaying items. In this regard, it's like a listbox but with enhanced 
  capabilities.
You can create a listview control in two ways. The first method is also the easiest one: create it with a 
resource editor. Just don't forget to call InitCommonControls within your asm source code. The other method 
is to call CreateWindowEx in your source code. You must specify the correct window class name for the control,
 ie. SysListView32. The window class "WC_LISTVIEW" is incorrect. 
There are four methods of viewing data in a listview control: icon, small icon, list and report views. 
You can see examples of these views by selecting View->Large Icons (icon view), Small Icons (small icon view),
 List (list view) and Details (report view). Views are just data representation methods:they only affect the 
 appearances of data. For example, you can have a lot of data in the listview control, but if you want,
  you can view only some of them. Report view is the most informative one while the remaining views give l
  ess info. You can specify the view you want when you create a listview control. You can later change the 
  view by calling SetWindowLong, specifying GWL_STYLE flag.

Now that we know how to create a listview control, we will continue on how to use it. I'll focus on report 
view which can demonstrate many features of listview control. The steps in using a listview control are as 
follows:

Create a listview control with CreateWindowEx, specifying SysListView32 as the class name. You can specify 
the initial view at this time. 
(if exists) Create and initialize image lists to be used with the listview items. 
Insert column(s) into the listview control. This step is necessary if the listview control will use report 
view. 
Insert items and subitems into the listview control. 
Columns
In report view, there are one or more columns. You can think of the arrangement of data in the report view 
as a table: the data are arranged in rows and columns. You must have at least one column in your listview 
control (only in report view). In views other than report, you need not insert a column because there can 
be one and only one column in those views.
You can insert a column by sending LVM_INSERTCOLUMN to the listview control.

LVM_INSERTCOLUMN
wParam = iCol
lParam = pointer to a LV_COLUMN structure

iCol is the column number, starting from 0.
LV_COLUMN contains information about the column to be inserted. It has the following definition:

LV_COLUMN STRUCT 
  imask dd ? 
  fmt dd ? 
  lx dd ? 
  pszText dd ? 
  cchTextMax dd ? 
  iSubItem dd ? 
  iImage dd ? 
  iOrder dd ? 
LV_COLUMN ENDS 

Field name Meanings 
imask A collection of flags that governs which members in this structure are valid. The reason behind this
 member is that not all members in this structure are used at the same time. Some members are used in some 
 situations. And this structure is used both for input and output. Thus it's important that you *mark* the 
 members that are used in this call to Windows so Windows knows which members are valid. The available flags 
 are:

LVCF_FMT = The fmt member is valid. 
LVCF_SUBITEM = The iSubItem member is valid. 
LVCF_TEXT = The pszText member is valid. 
LVCF_WIDTH = The lx member is valid.

You can combine the above flags. For example, if you want to specify the text label of the column, you must 
supply the pointer to the string in pszText member. And you must tell Windows that pszText member contains 
data by specifying LVCF_TEXT flag in this field else Windows will ignore the value in pszText.
 
fmt Specify the alignment of items/subitems in the column. The available values are:

LVCFMT_CENTER = Text is centered. 
LVCFMT_LEFT = Text is left-aligned. 
LVCFMT_RIGHT = Text is right-aligned.
 
lx The width of the column, in pixels. You can later change the width of the column with LVM_SETCOLUMNWIDTH. 
pszText Contains a pointer to the name of the column if this structure is used to set the column's properties.
 If this structure is used to receive the properties of a column, this field contains a pointer to a buffer 
 large enough to receive the name of the column that will be returned. In that case, you must give the size of
  the buffer in cchTextMax below. You can ignore cchTextMax if you want to set the name of the column because 
  the name must be an ASCIIZ string which Windows can determine the length. 
cchTextMax The size, in bytes, of the buffer specified in pszText above. This member is used only when you use 
this structure to receive info about a column. If you use this structure to set the properties of a column, 
this field is ignored. 
iSubItem Specify the index of subitem associated with this column. This value is used as a marker which 
subitem this column is associated with. If you want, you can specify an absurd number in this field and your 
listview control will still run like a breeze. The use of this field is best demonstrated when you have the 
column number and need to know with which subitem this column is associated. You can query the listview 
control by sending LVM_GETCOLUMN message to it, specifying LVCF_SUBITEM in the imask member. The listview 
control will fill the iSubItem member with whatever value you specify in this field when the column is 
inserted. In order for this method to work, you need to input the correct subitem index into this field.  
iImage and iOrder Used with Internet Explorer 3.0 upwards. I don't have info about them. 

So after the listview control is created, you should insert one or more columns into it. Columns are not 
necessary if you don't plan to switch the listview control into report view. In order to insert a column, 
you need to create a LV_COLUMN structure, fill it with necessary information, specify the column number and 
then send the structure to the listview control with LVM_INSERTCOLUMN message.

   LOCAL lvc:LV_COLUMN
   mov lvc.imask,LVCF_TEXT+LVCF_WIDTH 
   mov lvc.pszText,offset Heading1 
   mov lvc.lx,150 
   invoke SendMessage,hList, LVM_INSERTCOLUMN,0,addr lvc 

The above code snippet demonstrates the process. It specifies the column header text and its width then send LVM_INSERTCOLUMN message to the listview control. It's that simple.

Items and subitems
Items are the main entries in the listview control. In views other than report view, you will only see items in the listview control. Subitems are details of the items. An item may have one or more associated subitems. For example, if the item is the name of a file, then you can have the file attributes, its size, the date of file creation as subitems. In report view, the leftmost column contains items and the remaining columns contain subitems. You can think of an item and its subitems as a database record. The item is the primary key of the record and the subitems are fields in the record. 
At the bare minimum, you need some items in your listview control: subitems are not necessary. However, if you want to give the user more information about the items, you can associate items with subitems so the user can see the details in the report view.
You insert an item into a listview control by sending LVM_INSERTITEM message to it. You also need to pass the address of an LV_ITEM structure to it in lParam. LV_ITEM has the following definition:

LV_ITEM STRUCT 
  imask dd ? 
  iItem dd ? 
  iSubItem dd ? 
  state dd ? 
  stateMask dd ? 
  pszText dd ? 
  cchTextMax dd ? 
  iImage dd ? 
  lParam dd ? 
  iIndent dd ? 
LV_ITEM ENDS 

Field name Meanings 
imask A collection of flags indicating which members in this structure are valid for this call. In general, 
this field is similar to imask member of LV_COLUMN above. Check your win32 api reference for more detail on 
the available flags. 
iItem The index of the item this structure refers to. The index is zero-based. You can think of this field 
as containing the "row" number of a table. 
iSubItem The index of the subitem associated with the item specified by iItem above. You can think of this 
field as containing the "column" of a table. For example, if you want to insert an item into a newly created 
listview control, the value in iItem would be 0 (because this item is the first one), and the value in 
iSubItem would also be 0 (we want to insert the item into the first column). If you want to specify a 
subitem associated with this item, the iItem would be the index of the item you want to associate with 
(in the above example, it's 0), the iSubItem would be 1 or greater, depending on which column you want to 
insert the subitem into. For example, if your listview control has 4 columns, the first column will contain 
the items. The remaining 3 columns are for subitems. If you want to insert a subitem into the 4th column, 
you need to specify the value 3 in iSubItem.  
state This member contains flags that reflect the status of the item. The state of an item can change because
 of the user's actions or it can be modified by our program. The state includes whether the item has the 
 focus/is hilited/is selected for cut operation/is selected. In addition to the state flags, It can also 
 contains one-based index into the overlay image/state image for use by the item. 
 
stateMask Since the state member above can contain the state flags, overlay image index , and state image 
index, we need to tell Windows which value we want to set or retrieve. The value in this field is for such 
use. 
pszText The address of an ASCIIZ string that will be used as the label of the item in the case we want 
to set/insert the item. In the case that we use this structure to retrieve the item's property, this 
member must contain the address of a buffer that will be filled with the label of the item. 
cchTextMax This field is used only when you use this structure to receive info about an item. In this case,
 this field contains the size in bytes of the buffer specified in pszText above. 
iImage The index into the imagelist containing the icons for the listview control. This index points to the
 icon to be used with this item. 
lParam A user-defined value that will be used when you sort items in the listview control. In short, 
when you tell the listview control to sort the items, the listview control will compare the items in pairs. 
It will send the lParam values of both items to you so you can decide which of the two should be listed first.
 If you're still hazy about this, don't worry. You'll learn more about sorting later. 

Let's summarize the steps in inserting an item/subitem into a listview control.

Create a variable of type LV_ITEM structure 
Fill it with necessary information 
Send LVM_INSERTITEM message to the listview control if you want to insert an item. Or if you want to *insert* a subitem, send LVM_SETITEM instead. This is rather confusing if you don't understand the relationship between an item and its subitems. Subitems are considered as properties of an item. Thus you can insert items but not subitems and you can't have a subitem without an associated item. That's why you need to send LVM_SETITEM message to add a subitem instead of LVM_INSERTITEM. 
ListView Messages/Notifications
Now that you know how to create and populate a listview control, the next step is to communicate with it. A listview control communicates with the parent window via messages and notifications. The parent window can control the listview control by sending messages to it. The listview control notifies the parent of important/interesting events via WM_NOTIFY message, just like other common controls.

Sorting items/subitems
You can specify the default sorting order of a listview control by specifying LVS_SORTASCENDING or LVS_SORTDESCENDING styles in CreateWindowEx. These two styles order the items using their labels only. If you want to sort the items in other ways, you need to send LVM_SORTITEMS message to the listview control.

LVM_SORTITEMS
wParam = lParamSort
lParam = pCompareFunction

lParamSort is a user-defined value that will be passed to the compare function. You can use this value in any 
way you want.
pCompareFunction is the address of the user-defined function that will decide the outcome of the comparison of
 items in the listview control. The function has the following prototype:

CompareFunc proto lParam1:DWORD, lParam2:DWORD, lParamSort:DWORD

lParam1 and lParam2 are the values in lParam member of LV_ITEM that you specify when you insert the items 
into the listview control.
lParamSort is the value in wParam you sent with LVM_SORTITEMS

When the listview control receives LVM_SORTITEMS message, it calls the compare function specified in lParam 
of the message when it needs to ask us for the result of comparison between two items. In short, the comparison
 function will decide which of the two items sent to it will precede the other. The rule is simple: 
 if the function returns a negative value, the first item (represented by lParam1) should precede the other. 
 If the function returns a positive value, the second item (represented by lParam2) should precede the first
  one. If both items are equal, it must return zero. 

What makes this method work is the value in lParam of LV_ITEM structure. If you need to sort the items 
(such as when the user clicks on a column header), you need to think of a sorting scheme that makes use of 
the values in lParam member. In the example, I put the index of the item in this field so I can obtain other 
information about the item by sending LVM_GETITEM message. Note that when the items are rearranged, 
their indexes also change. So when the sorting is done in my example, I need to update the values in 
lParam to reflect the new indexes. If you want to sort the items when the user clicks on a column header, 
you need to process LVN_COLUMNCLICK notification message in your window procedure. LVN_COLUMNCLICK is passed 
to your window proc via WM_NOTIFY message.

Example:
This example creates a listview control and fills it with the names and sizes of the files in the current 
folder. The default view is the report one. In the report view, you can click on the column heads and the 
items will be sorted in ascending/descending order. You can select the view you want via the menu. 
When you double-click on an item, a message box showing the label of the item is displayed.

.386 
.model flat,stdcall 
option casemap:none 
include \Masm32\include\windows.inc 
include \Masm32\include\user32.inc 
include \Masm32\include\kernel32.inc 
include \Masm32\include\comctl32.inc 
includelib \Masm32\lib\comctl32.lib 
includelib \Masm32\lib\user32.lib 
includelib \Masm32\lib\kernel32.lib 

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 

IDM_MAINMENU equ 10000 
IDM_ICON equ LVS_ICON 
IDM_SMALLICON equ LVS_SMALLICON 
IDM_LIST equ LVS_LIST 
IDM_REPORT equ LVS_REPORT 

RGB macro red,green,blue 
  xor eax,eax 
  mov ah,blue 
  shl eax,8 
  mov ah,green 
  mov al,red 
endm 

.data 
ClassName db "ListViewWinClass",0 
AppName db "Testing a ListView Control",0 
ListViewClassName db "SysListView32",0 
Heading1 db "Filename",0 
Heading2 db "Size",0 
FileNamePattern db "*.*",0 
FileNameSortOrder dd 0 
SizeSortOrder dd 0 
template db "%lu",0

.data? 
hInstance HINSTANCE ? 
hList dd ? 
hMenu dd ? 

.code 
start: 
  invoke GetModuleHandle, NULL 
  mov hInstance,eax 
  invoke WinMain, hInstance,NULL, NULL, SW_SHOWDEFAULT 
  invoke ExitProcess,eax 
  invoke InitCommonControls 
WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
  LOCAL wc:WNDCLASSEX 
  LOCAL msg:MSG 
  LOCAL hwnd:HWND

  mov wc.cbSize,SIZEOF WNDCLASSEX 
  mov wc.style, NULL 
  mov wc.lpfnWndProc, OFFSET WndProc 
  mov wc.cbClsExtra,NULL 
  mov wc.cbWndExtra,NULL 
  push hInstance 
  pop wc.hInstance 
  mov wc.hbrBackground,COLOR_WINDOW+1 
  mov wc.lpszMenuName,IDM_MAINMENU 
  mov wc.lpszClassName,OFFSET ClassName 
  invoke LoadIcon,NULL,IDI_APPLICATION 
  mov wc.hIcon,eax 
  mov wc.hIconSm,eax 
  invoke LoadCursor,NULL,IDC_ARROW 
  mov wc.hCursor,eax 
  invoke RegisterClassEx, addr wc 
  invoke CreateWindowEx,NULL,ADDR ClassName,ADDR AppName, WS_OVERLAPPEDWINDOW,CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, NULL, NULL, hInst,NULL 
  mov hwnd,eax 
  invoke ShowWindow, hwnd,SW_SHOWNORMAL 
  invoke UpdateWindow, hwnd 
  .while TRUE 
    invoke GetMessage, ADDR msg,NULL,0,0 
    .break .if (!eax) 
      invoke TranslateMessage, ADDR msg 
      invoke DispatchMessage, ADDR msg 
  .endw 
  mov eax,msg.wParam 
  ret 
WinMain endp 

InsertColumn proc 
  LOCAL lvc:LV_COLUMN 

  mov lvc.imask,LVCF_TEXT+LVCF_WIDTH 
  mov lvc.pszText,offset Heading1 
  mov lvc.lx,150 
  invoke SendMessage,hList, LVM_INSERTCOLUMN, 0, addr lvc
  or lvc.imask,LVCF_FMT
  mov lvc.fmt,LVCFMT_RIGHT 
  mov lvc.pszText,offset Heading2 
  mov lvc.lx,100
  invoke SendMessage,hList, LVM_INSERTCOLUMN, 1 ,addr lvc 
  ret 
InsertColumn endp 

ShowFileInfo proc uses edi row:DWORD, lpFind:DWORD 
  LOCAL lvi:LV_ITEM 
  LOCAL buffer[20]:BYTE 
  mov edi,lpFind 
  assume edi:ptr WIN32_FIND_DATA 
  mov lvi.imask,LVIF_TEXT+LVIF_PARAM 
  push row 
  pop lvi.iItem 
  mov lvi.iSubItem,0 
  lea eax,[edi].cFileName 
  mov lvi.pszText,eax 
  push row 
  pop lvi.lParam 
  invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvi 
  mov lvi.imask,LVIF_TEXT 
  inc lvi.iSubItem 
  invoke wsprintf,addr buffer, addr template,[edi].nFileSizeLow 
  lea eax,buffer 
  mov lvi.pszText,eax 
  invoke SendMessage,hList,LVM_SETITEM, 0,addr lvi 
  assume edi:nothing 
  ret 
ShowFileInfo endp 

FillFileInfo proc uses edi 
  LOCAL finddata:WIN32_FIND_DATA 
  LOCAL FHandle:DWORD 

  invoke FindFirstFile,addr FileNamePattern,addr finddata 
  .if eax!=INVALID_HANDLE_VALUE 
    mov FHandle,eax 
    xor edi,edi 
    .while eax!=0 
      test finddata.dwFileAttributes,FILE_ATTRIBUTE_DIRECTORY 
      .if ZERO?
         invoke ShowFileInfo,edi, addr finddata 
         inc edi 
      .endif 
      invoke FindNextFile,FHandle,addr finddata 
    .endw 
    invoke FindClose,FHandle 
  .endif 
  ret 
FillFileInfo endp 

String2Dword proc uses ecx edi edx esi String:DWORD 
  LOCAL Result:DWORD 

  mov Result,0 
  mov edi,String 
  invoke lstrlen,String 
  .while eax!=0 
    xor edx,edx 
    mov dl,byte ptr [edi] 
    sub dl,"0" 
    mov esi,eax 
    dec esi 
    push eax 
    mov eax,edx 
    push ebx 
    mov ebx,10 
    .while esi > 0 
      mul ebx 
      dec esi 
    .endw 
    pop ebx 
    add Result,eax 
    pop eax 
    inc edi 
    dec eax 
  .endw 
  mov eax,Result 
  ret 
String2Dword endp 

CompareFunc proc uses edi lParam1:DWORD, lParam2:DWORD, SortType:DWORD 
  LOCAL buffer[256]:BYTE 
  LOCAL buffer1[256]:BYTE 
  LOCAL lvi:LV_ITEM 

  mov lvi.imask,LVIF_TEXT 
  lea eax,buffer 
  mov lvi.pszText,eax 
  mov lvi.cchTextMax,256 
  .if SortType==1 
    mov lvi.iSubItem,1 
    invoke SendMessage,hList,LVM_GETITEMTEXT,lParam1,addr lvi 
    invoke String2Dword,addr buffer 
    mov edi,eax 
    invoke SendMessage,hList,LVM_GETITEMTEXT,lParam2,addr lvi 
    invoke String2Dword,addr buffer 
    sub edi,eax 
    mov eax,edi 
  .elseif SortType==2 
    mov lvi.iSubItem,1 
    invoke SendMessage,hList,LVM_GETITEMTEXT,lParam1,addr lvi 
    invoke String2Dword,addr buffer 
    mov edi,eax 
    invoke SendMessage,hList,LVM_GETITEMTEXT,lParam2,addr lvi 
    invoke String2Dword,addr buffer 
    sub eax,edi 
  .elseif SortType==3 
    mov lvi.iSubItem,0 
    invoke SendMessage,hList,LVM_GETITEMTEXT,lParam1,addr lvi 
    invoke lstrcpy,addr buffer1,addr buffer 
    invoke SendMessage,hList,LVM_GETITEMTEXT,lParam2,addr lvi 
    invoke lstrcmpi,addr buffer1,addr buffer 
  .else 
    mov lvi.iSubItem,0 
    invoke SendMessage,hList,LVM_GETITEMTEXT,lParam1,addr lvi 
    invoke lstrcpy,addr buffer1,addr buffer 
    invoke SendMessage,hList,LVM_GETITEMTEXT,lParam2,addr lvi 
    invoke lstrcmpi,addr buffer,addr buffer1 
  .endif 
  ret 
CompareFunc endp 

UpdatelParam proc uses edi 
   LOCAL lvi:LV_ITEM 

   invoke SendMessage,hList, LVM_GETITEMCOUNT,0,0 
   mov edi,eax 
   mov lvi.imask,LVIF_PARAM 
   mov lvi.iSubItem,0 
   mov lvi.iItem,0 
   .while edi>0 
     push lvi.iItem 
     pop lvi.lParam 
     invoke SendMessage,hList, LVM_SETITEM,0,addr lvi 
     inc lvi.iItem 
     dec edi 
   .endw 
   ret 
UpdatelParam endp 

ShowCurrentFocus proc 
   LOCAL lvi:LV_ITEM 
   LOCAL buffer[256]:BYTE 

   invoke SendMessage,hList,LVM_GETNEXTITEM,-1, LVNI_FOCUSED
   mov lvi.iItem,eax 
   mov lvi.iSubItem,0 
   mov lvi.imask,LVIF_TEXT 
   lea eax,buffer 
   mov lvi.pszText,eax 
   mov lvi.cchTextMax,256 
   invoke SendMessage,hList,LVM_GETITEM,0,addr lvi 
   invoke MessageBox,0, addr buffer,addr AppName,MB_OK 
   ret 
ShowCurrentFocus endp 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
  .if uMsg==WM_CREATE 
    invoke CreateWindowEx, NULL, addr ListViewClassName, NULL, LVS_REPORT+WS_CHILD+WS_VISIBLE, 0,0,0,0,hWnd, NULL, hInstance, NULL 
    mov hList, eax 
    invoke InsertColumn 
    invoke FillFileInfo 
    RGB 255,255,255 
    invoke SendMessage,hList,LVM_SETTEXTCOLOR,0,eax 
    RGB 0,0,0 
    invoke SendMessage,hList,LVM_SETBKCOLOR,0,eax 
    RGB 0,0,0 
    invoke SendMessage,hList,LVM_SETTEXTBKCOLOR,0,eax 
    invoke GetMenu,hWnd 
    mov hMenu,eax 
    invoke CheckMenuRadioItem,hMenu,IDM_ICON,IDM_LIST, IDM_REPORT,MF_CHECKED 
  .elseif uMsg==WM_COMMAND 
    .if lParam==0 
      invoke GetWindowLong,hList,GWL_STYLE 
      and eax,not LVS_TYPEMASK 
      mov edx,wParam 
      and edx,0FFFFh 
      push edx 
      or eax,edx 
      invoke SetWindowLong,hList,GWL_STYLE,eax 
      pop edx 
      invoke CheckMenuRadioItem,hMenu,IDM_ICON,IDM_LIST, edx,MF_CHECKED 
    .endif 
  .elseif uMsg==WM_NOTIFY 
    push edi 
    mov edi,lParam 
    assume edi:ptr NMHDR 
    mov eax,[edi].hwndFrom 
    .if eax==hList 
      .if [edi].code==LVN_COLUMNCLICK 
        assume edi:ptr NM_LISTVIEW 
        .if [edi].iSubItem==1 
          .if SizeSortOrder==0 || SizeSortOrder==2 
            invoke SendMessage,hList,LVM_SORTITEMS,1,addr CompareFunc 
            invoke UpdatelParam 
            mov SizeSortOrder,1 
          .else 
            invoke SendMessage,hList,LVM_SORTITEMS,2,addr CompareFunc 
            invoke UpdatelParam 
            mov SizeSortOrder,2 
          .endif 
        .else 
          .if FileNameSortOrder==0 || FileNameSortOrder==4 
            invoke SendMessage,hList,LVM_SORTITEMS,3,addr CompareFunc 
            invoke UpdatelParam 
            mov FileNameSortOrder,3 
          .else 
            invoke SendMessage,hList,LVM_SORTITEMS,4,addr CompareFunc 
            invoke UpdatelParam 
            mov FileNameSortOrder,4 
          .endif 
        .endif 
        assume edi:ptr NMHDR 
      .elseif [edi].code==NM_DBLCLK 
        invoke ShowCurrentFocus 
      .endif 
    .endif 
    pop edi 
  .elseif uMsg==WM_SIZE
    mov eax,lParam 
    mov edx,eax 
    and eax,0ffffh 
    shr edx,16 
    invoke MoveWindow,hList, 0, 0, eax,edx,TRUE 
  .elseif uMsg==WM_DESTROY 
    invoke PostQuitMessage,NULL 
  .else 
    invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
    ret 
  .endif 
  xor eax,eax 
  ret 
WndProc endp 
end start 

Analysis:
The first thing the program does when the main window is created is to create a listview control.

  .if uMsg==WM_CREATE 
    invoke CreateWindowEx, NULL, addr ListViewClassName, NULL, LVS_REPORT+WS_CHILD+WS_VISIBLE, 0,0,0,0,hWnd, NULL, hInstance, NULL 
    mov hList, eax 

We call CreateWindowEx, passing itthe name of the window class "SysListView32". The default view is the report view as specified by LVS_REPORT style.

    invoke InsertColumn 

After the listview control is created, we insert columns into it. 

  LOCAL lvc:LV_COLUMN 

  mov lvc.imask,LVCF_TEXT+LVCF_WIDTH 
  mov lvc.pszText,offset Heading1 
  mov lvc.lx,150 
  invoke SendMessage,hList, LVM_INSERTCOLUMN, 0, addr lvc

We specify the label and the width of the first column, for storing the names of the files, in LV_COLUMN 
structure thus we need to set imask with LVCF_TEXT and LVCF_WIDTH flags. We fill pszText with the address
 of the label and lx with the width of the column, in pixels. When all is done, we send LVM_INSERTCOLUMN 
 message to the listview control, passing the structure to it.

  or lvc.imask,LVCF_FMT
  mov lvc.fmt,LVCFMT_RIGHT 

When we are done with the insertion of the first column, we insert another column for storing the sizes 
of the files. Since we need the sizes to right-align in the column, we need to specify a flag in fmt member,
 LVCFMT_RIGHT. We must also specify LVCF_FMT flag in imask, in addition to LVCF_TEXT and LVCF_WIDTH.

  mov lvc.pszText,offset Heading2 
  mov lvc.lx,100
  invoke SendMessage,hList, LVM_INSERTCOLUMN, 1 ,addr lvc 

The remaining code is simple. Put the address of the label in pszText and the width in lx. 
Then send LVM_INSERTCOLUMN message to the listview control, specifying the column number and the address 
of the structure.

When the columns are inserted, we can fill items in the listview control.

    invoke FillFileInfo 

FillFileInfo has the following code.

FillFileInfo proc uses edi 
  LOCAL finddata:WIN32_FIND_DATA 
  LOCAL FHandle:DWORD 

  invoke FindFirstFile,addr FileNamePattern,addr finddata 

We call FindFirstFile to obtain the information of the first file that matches the search criteria.
 FindFirstFile has the following prototype:

FindFirstFile proto pFileName:DWORD, pWin32_Find_Data:DWORD

pFileName is the address of the filename to search for. This string can contain wildcards. In our example, 
we use *.*, which amounts to search for all the files in the current folder.
pWin32_Find_Data is the address of the WIN32_FIND_DATA structure that will be filled with information about
 the file (if found). 

This function returns INVALID_HANDLE_VALUE in eax if no matching file is found. Otherwise it returns
 a search handle that will be used in subsequent FindNextFile calls.

  .if eax!=INVALID_HANDLE_VALUE 
    mov FHandle,eax 
    xor edi,edi 

If a file is found, we store the search handle in a variable and then zero out edi which will be used 
as the index into the items (row number).

    .while eax!=0
      test finddata.dwFileAttributes,FILE_ATTRIBUTE_DIRECTORY 
      .if ZERO?

In this tutorial, I don't want to deal with the folders yet so I filter them out by checking dwFileAttributes 
for files which have FILE_ATTRIBUTE_DIRECTORY flag set. If they are found, I skip to call FindNextFile.

          invoke ShowFileInfo,edi, addr finddata 
          inc edi 
      .endif
      invoke FindNextFile,FHandle,addr finddata     
    .endw 


We insert the name and size of the file into the listview control by calling ShowFileInfo function. 
Then we increase the current row number in edi. Lastly we proceed to call FindNextFile to search for 
the next file in the current folder until FindNextFile returns 0 (meaning no more file is found).

    invoke FindClose,FHandle 
  .endif 
  ret 
FillFileInfo endp 

When all files in the current folder are enumerated, we must close the search handle.

Now let's look at the ShowFileInfo function. This function accepts two parameters, the index of the item 
(row number) and the address of WIN32_FIND_DATA structure.

ShowFileInfo proc uses edi row:DWORD, lpFind:DWORD 
  LOCAL lvi:LV_ITEM 
  LOCAL buffer[20]:BYTE 
  mov edi,lpFind 
  assume edi:ptr WIN32_FIND_DATA 

Store the address of WIN32_FIND_DATA structure in edi.

  mov lvi.imask,LVIF_TEXT+LVIF_PARAM 
  push row 
  pop lvi.iItem 
  mov lvi.iSubItem,0 

We will supply the label of the item and the value in lParam so we put LVIF_TEXT and LVIF_PARAM flags 
into imask. Next we set the iItem to the row number passed to the function and since this is the main item, 
we must filliSubItem with 0 (column 0).

  lea eax,[edi].cFileName 
  mov lvi.pszText,eax 
  push row 
  pop lvi.lParam 

Next we put the address of the label, in this case, the name of the file in WIN32_FIND_DATA structure, 
into pszText. Because we will implement sorting in the listview control, we must fill lParam with a value. 
I choose to put the row number into this member so I can retrieve the item info by its index.

  invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvi 

When all necessary fields in LV_ITEM are filled, we send LVM_INSERTITEM message to the listview control 
to insert the item into it. 

  mov lvi.imask,LVIF_TEXT 
  inc lvi.iSubItem 
  invoke wsprintf,addr buffer, addr template,[edi].nFileSizeLow 
  lea eax,buffer 
  mov lvi.pszText,eax 

We will set the subitem associated with the item just inserted into the second column. A subitem can only 
have a label. Thus we specify LVIF_TEXT in imask. Then we specify the column that the subitem should reside 
in iSubItem. In this case, we set it to 1 by incrementing iSubItem. The label we will use is the size of 
the file. However, we must convert it to a string first by calling wsprintf. Then we put the address of 
the string into pszText. 

  invoke SendMessage,hList,LVM_SETITEM, 0,addr lvi 
  assume edi:nothing 
  ret 
ShowFileInfo endp 


When all necessary fields in LV_ITEM are filled, we send LVM_SETITEM message to the listview control, passing 
to it the address of the LV_ITEM structure. Note that we use LVM_SETITEM, not LVM_INSERTITEM because a subitem 
is considered as a property of an item. Thus we *set* the property of the item, not inserting a new item.

When all items are inserted into the listview control, we set the text and background colors of the listview 
control.

    RGB 255,255,255 
    invoke SendMessage,hList,LVM_SETTEXTCOLOR,0,eax 
    RGB 0,0,0 
    invoke SendMessage,hList,LVM_SETBKCOLOR,0,eax 
    RGB 0,0,0 
    invoke SendMessage,hList,LVM_SETTEXTBKCOLOR,0,eax 

I use RGB macro to convert the red, green,blue values into eax and use it to specify the color we need. 
We set the foreground and background colors of the text with LVM_SETTEXTCOLOR and LVM_SETTEXTBKCOLOR messages.
 We set the background color of the listview control by sending LVM_SETBKCOLOR message to the listview control.
 

    invoke GetMenu,hWnd 
    mov hMenu,eax 
    invoke CheckMenuRadioItem,hMenu,IDM_ICON,IDM_LIST, IDM_REPORT,MF_CHECKED 

We will let the user chooses the views he wants via the menu. Thus we must obtain the menu handle first. 
To help the user track the current view, we put a radio button system in our menu. The menu item that 
reflects the current view will be preceded by a radio button. That's why we call CheckMenuRadioItem. 
This function will put a radio button before a menu item.

Note that we create the listview control with width and height equal to 0. It will be resized later whenever 
the parent window is resized. This way, we can ensure that the size of the listview control will always 
match that of the parent window. In our example, we want the listview control to fill the whole client area 
of the parent window.

  .elseif uMsg==WM_SIZE
    mov eax,lParam 
    mov edx,eax 
    and eax,0ffffh 
    shr edx,16 
    invoke MoveWindow,hList, 0, 0, eax,edx,TRUE 

When the parent window receives WM_SIZE message, the low word of lParam contains the new width of the 
client area and the high word the new height. Then we call MoveWindow to resize the listview control to 
cover the whole client area of the parent window.

When the user selects a view in the menu. We must change the view in the listview control accordingly. 
We accomplish this by setting a new style in the listview control with SetWindowLong.

  .elseif uMsg==WM_COMMAND 
    .if lParam==0 
      invoke GetWindowLong,hList,GWL_STYLE 
      and eax,not LVS_TYPEMASK 

The first thing we do is to obtain the current styles of the listview control. Then we clear the old 
view style from the returned style flags. LVS_TYPEMASK is a constant that is the combined value of all 
4 view style constants (LVS_ICON+LVS_SMALLICON+LVS_LIST+LVS_REPORT). Thus when we perform and operation 
on the current style flags with the value "not LVS_TYPEMASK", it amounts to clearing away the current 
view style.

In designing the menu, I cheat a little. I use the view style constants as the menu IDs.

IDM_ICON equ LVS_ICON 
IDM_SMALLICON equ LVS_SMALLICON 
IDM_LIST equ LVS_LIST 
IDM_REPORT equ LVS_REPORT 

Thus when the parent window receives WM_COMMAND message, the desired view style is in the low word of 
wParam as the menu ID.

      mov edx,wParam 
      and edx,0FFFFh 

We have the desired view style in the low word of wParam. All we have to do is to zero out the high word.

      push edx 
      or eax,edx 

And add the desired view style to the existing styles (minus the current view style) of the listview control.

      invoke SetWindowLong,hList,GWL_STYLE,eax 

And set the new styles with SetWindowLong.

      pop edx 
      invoke CheckMenuRadioItem,hMenu,IDM_ICON,IDM_LIST, edx,MF_CHECKED     
   .endif 

We also need to put the radio button in front of the selected view menu item. Thus we call CheckMenuRadioItem,
 passing the current view style (double as menu ID) to it.

When the user clicks on the column headers in the report view, we want to sort the items in the listview 
control. We must respond to WM_NOTIFY message.

  .elseif uMsg==WM_NOTIFY 
    push edi 
    mov edi,lParam 
    assume edi:ptr NMHDR 
    mov eax,[edi].hwndFrom 
    .if eax==hList 

When we receive WM_NOTIFY message, lParam contains the pointer to an NMHDR structure. We can check if this 
message is from the listview control by comparing the hwndFrom member of NMHDR to the handle to the listview 
control. If they match, we can assume that the notification came from the listview control.

      .if [edi].code==LVN_COLUMNCLICK 
        assume edi:ptr NM_LISTVIEW 

If the notification is from the listview control, we check if the code is LVN_COLUMNCLICK. If it is, it means 
the user clicks on a column header. In the case that the code is LVN_COLUMNCLICK, we can assume that lParam 
contains the pointer to an NM_LISTVIEW structure which is a superset of the NMHDR structure. We then need 
to know on which column header the user clicks. Examination of iSubItem member reveals this info. The value 
in iSubItem can be treated as the column number, starting from 0.

        .if [edi].iSubItem==1 
          .if SizeSortOrder==0 || SizeSortOrder==2 

In the case iSubItem is 1, it means the user clicks on the second column, size. We use state variables to keep
 the current status of the sorting order. 0 means "no sorting yet", 1 means "sort ascending", 2 means 
 "sort descending". If the items/subitems in the column are not sorted before, or sorted descending, 
 we set the sorting order to ascending.

            invoke SendMessage,hList,LVM_SORTITEMS,1,addr CompareFunc 

We send LVM_SORTITEMS message to the listview control, passing 1 in wParam and the address of our comparison 
function in lParam. Note that the value in wParam is user-defined, you can use it in any way you like. 
I use it as the sorting method in this example. We will take a look at the comparison function first.

CompareFunc proc uses edi lParam1:DWORD, lParam2:DWORD, SortType:DWORD 
  LOCAL buffer[256]:BYTE 
  LOCAL buffer1[256]:BYTE 
  LOCAL lvi:LV_ITEM 

  mov lvi.imask,LVIF_TEXT 
  lea eax,buffer 
  mov lvi.pszText,eax 
  mov lvi.cchTextMax,256 

In the comparison function, the listview control will pass lParams (in LV_ITEM) of the two items it needs to
 compare to us in lParam1 and lParam2. You'll recall that we put the index of the item in lParam. Thus we 
 can obtain information about the items by querying the listview control using the indexes. The info we need 
 is the labels of the items/subitems being sorted. Thus we prepare an LV_ITEM structure for such purpose, 
 specifying LVIF_TEXT in imask and the address of the buffer in pszText and the size of the buffer in 
 cchTextMax.

  .if SortType==1 
    mov lvi.iSubItem,1 
    invoke SendMessage,hList,LVM_GETITEMTEXT,lParam1,addr lvi 

If the value in SortType is 1 or 2, we know that the size column is clicked. 1 means sort the items according
 to their sizes in ascending order. 2 means the reverse. Thus we specify iSubItem as 1 ( to specify the size 
 column) and send LVM_GETITEMTEXT message to the listview control to obtain the label (size string) of the 
 subitem.

    invoke String2Dword,addr buffer 
    mov edi,eax 

Covert the size string into a dword value with String2Dword which is the function I wrote. It returns the
 dword value in eax. We store it in edi for comparison later.

    invoke SendMessage,hList,LVM_GETITEMTEXT,lParam2,addr lvi 
    invoke String2Dword,addr buffer 
    sub edi,eax 
    mov eax,edi 

Do likewise with the value in lParam2. When we have the sizes of the two files, we can then compare them.
The rule of the comparison function is as follows:

If the first item should precede the other, you must return a negative value in eax 
If the second item should precede the first one, you must return a positive value in eax 
If both items are equal, you must return zero in eax. 
In this case, we want to sort the items according to their sizes in ascending order. Thus we can simply 
subtract the size of the first item with that of the second one and return the result in eax.

  .elseif SortType==3 
    mov lvi.iSubItem,0 
    invoke SendMessage,hList,LVM_GETITEMTEXT,lParam1,addr lvi 
    invoke lstrcpy,addr buffer1,addr buffer 
    invoke SendMessage,hList,LVM_GETITEMTEXT,lParam2,addr lvi 
    invoke lstrcmpi,addr buffer1,addr buffer 


In case the user clicks the filename column, we must compare the names of the files. We first obtain the 
filenames and then compare them with lstrcmpi function. We can return the return value of lstrcmpi without 
any modification since it also uses the same rule of comparison, eg. negative value in eax if the first string 
is less than the second string.

When the items were sorted, we need to update the lParam values of all items to reflect the new indexes by 
calling UpdatelParam function.

            invoke UpdatelParam 
            mov SizeSortOrder,1 

This function simply enumerates all items in the listview control and updates the values in lParam with the 
new indexes. We need to do this else the next sort will not work as expected because our assumption is that
 the value in lParam is the index of the item.

      .elseif [edi].code==NM_DBLCLK 
        invoke ShowCurrentFocus 
      .endif 

When the user double-clicks at an item, we want to display a message box with the label of the item on it.
 We must check if the code in NMHDR is NM_DBLCLK. If it is, we can proceed to obtain the label and display 
it in a message box.

ShowCurrentFocus proc 
   LOCAL lvi:LV_ITEM 
   LOCAL buffer[256]:BYTE 

   invoke SendMessage,hList,LVM_GETNEXTITEM,-1, LVNI_FOCUSED

How do we know which item is double-clicked? When an item is clicked or double-clicked, its state is set 
to "focused". Even if many items are hilited (selected), only one of them has got the focus. Our job than i
s to find the item that has the focus. We do this by sending LVM_GETNEXTITEM message to the listview control, 
specifying the desired state in lParam. -1 in wParam means search all items. The index of the item is returned 
in eax.

   mov lvi.iItem,eax 
   mov lvi.iSubItem,0 
   mov lvi.imask,LVIF_TEXT 
   lea eax,buffer 
   mov lvi.pszText,eax 
   mov lvi.cchTextMax,256 
   invoke SendMessage,hList,LVM_GETITEM,0,addr lvi 

We then proceed to obtain the label by sending LVM_GETITEM message to the listview control.

   invoke MessageBox,0, addr buffer,addr AppName,MB_OK 

Lastly, we display the label in a message box.

If you want to know how to use icons in the listview control, you can read about it in my treeview tutorial. 
The steps are just about the same.

 Unfortunately you can't run Java applets  


Tutorial 32: Multiple Document Interface (MDI)
  
This tutorial shows you how to create MDI application. It's actually not too difficult to do.

Theory:
Multiple Document Interface (MDI) is a specification for applications that handle multple documents at the 
same time. You are familiar with Notepad: It's an example of Single Document Interface (SDI). Notepad can 
handle only one document at a time. If you want to open another document, you have to close the previous one
 first. As you can imagine, it's rather cumbersome. Contrast it with Microsoft Word: Word can open arbitrary 
 documents at the same time and let the user choose which document to use. Microsoft Word is an example of 
 Multiple Document Interface (MDI).

MDI application has several characteristics that are distinctive. I'll list some of them:

Within the main window, there can be multiple child windows in the client area. All child windows are clipped
to the client area. 
When you minimize a child window, it minimizes to the lower left corner of the client area of the main window. 
When you maximize achild window, its title merges with that of the main window. 
You can close a child window by pressing Ctrl+F4 and switch the focus between the child windows by pressing 
Ctrl+Tab 
The main window that contains the child windows is called a frame window. Its client area is where the child 
windows live, hence the name "frame". Its job is a little more elaborate than a usual window because it needs 
to handle some coordination for MDI.

To control an arbitrary number of child windows in your client area, you need a special window called client
window. You can think of this client window as a transparent window that covers the whole client area of the 
frame window. It's this client window that is the actual parent of those MDI child windows. The client window 
is the real supervisor of the MDI child windows.

    Frame Window 
     
    |      
    Client Window 
     
    |     

--------------------------------------------------------------------------------
 
| | | | | 
MDI Child 1  
 MDI Child 2  
 MDI Child 3  
 MDI Child 4  
 MDI Child n  
 

Figure 1. The hierachy of an MDI application

Creating the Frame Window
Now we can turn our attention to the detail. First of all you need to create a frame window. It's created the 
same way as the normal window: by calling CreateWindowEx. There are two major differences from a normal window.

The first difference is that you MUST call DefFrameProc instead of DefWindowProc to process the Windows 
messages your window don't want to handle. This is one way to let Windows do the dirty job of maintaining MDI 
application for you. If you forget to use DefFrameProc, your application won't get the MDI feature. Period. 
DefFrameProc has the following syntax:

DefFrameProc proc hwndFrame:DWORD,
                                   hwndClient:DWORD,
                                   uMsg:DWORD,
                                   wParam:DWORD,
                                   lParam:DWORD
If you compare DefFrameProc with DefWindowProc, you'll notice that the only difference between them is that
 DefFrameProc has 5 parameters while DefWindowProc has only 4. The extra parameter is the handle to the 
 client window. This handle is necessary so Windows can send MDI-related messages to the client window.

The second difference is that, you must call TranslateMDISysAccel in the message loop of your frame window. 
This is necessary if you want Windows to handle MDI-related accelerator key strokes such as Ctrl+F4, Ctrl+Tab 
for you. It has the following syntax: 

TranslateMDISysAccel proc hwndClient:DWORD,
                                                 lpMsg:DWORD 
The first parameter is the handle to the client window. This should not come as a surprise to you because 
it's the client window that is the parent of all MDI child windows. The second parameter is the address of 
the MSG structure you filled by calling GetMessage. The idea is to pass the MSG structure to the client 
window so it could examine if the MSG structure contains the MDI-related keypresses. If so, it processes 
the message itself and returns a non-zero value, otherwise it returns FALSE.

The steps in creating the frame window can be summarized as follows:

Fill in the WNDCLASSEX structure as usual 
Register the frame window class by calling RegisterClassEx 
Create the frame window by calling CreateWindowEx 
Within the message loop, call TranslateMDISysAccel. 
Within the window procedure, pass the unprocessed messages to DefFrameProc instead of DefWindowProc. 
Creating the Client Window
Now that we have the frame window, we can create the client window. The client window class is 
pre-registered by Windows. The class name is "MDICLIENT". You also need to pass the address of a 
CLIENTCREATESTRUCT structure to CreateWindowEx. This structure has the following definition:

CLIENTCREATESTRUCT struct
        hWindowMenu    dd ?
        idFirstChild    dd ?
CLIENTCREATESTRUCT ends
hWindowMenu is the handle to the submenu that Windows will append the list of MDI child window names. 
This feature requires a little explanation. If you ever use an MDI application like Microsoft Word before,
 you'll notice that there is a submenu named "window" which, on activation, displays various menuitems 
 related to window management and at the bottom, the list of the MDI child window currently opened. 
 That list is internally maintained by Windows itself: you don't have to do anything special for it. 
 Just pass the handle of the submenu you want the list to appear in hWindowMenu and Windows will handle 
 the rest. Note that the submenu can be ANY submenu:it doesn't have to be the one that is named "window". 
 The bottom line is that, you should pass the handle to the submenu you want the window list to appear. 
 If you don't want the list, just put NULL in hWindowMenu. You get the handle to the submenu by calling 
 GetSubMenu.

idFirstChild is the ID of the first MDI child window. Windows increments the ID for each new MDI child window
 the application created. For example, if you pass 100 to this field, the first MDI child window will have the
  ID of 100, the second one will have the ID of 101 and so on. This ID is sent to the frame window via
   WM_COMMAND when the MDI child window is selected from the window list. Normally you'll pass this 
   "unhandled" WM_COMMAND messages to DefFrameProc. I use the word "unhandled" because the menuitems in 
   the window list are not created by your application thus your application doesn't know their IDs and 
   doesn't have the handler for them. This is another special case for the MDI frame window: 
   if you have the window list, you must modify your WM_COMMAND handler a bit like this:

.elseif uMsg==WM_COMMAND      .if lParam==0          ; this message is generated from a menu
          mov eax,wParam          .if ax==IDM_CASCADE                 .....          .elseif ax==IDM_TILEVERT                .....
          .else                invoke DefFrameProc, hwndFrame, hwndClient, uMsg,wParam, lParam              
            ret          .endif
Normally, you would just ignore the messages from unhandled cases. But In the MDI case, if you ignore them,
 when the user clicks on the name of an MDI child window in the window list, that window won't become active.
  You need to pass them to DefFrameProc so they can be handled properly.

A caution on the value of idFirstChild: you should not use 0. Your window list will not behave properly,
 ie. the check mark will not appear in front of the name of the first MDI child even though it's active.
  Choose a safe value such as 100 or above.

Having filled in the CLIENTCREATESTRUCT structure, you can create the client window by calling 
CreateWindowEx with the predefined class name,"MDICLIENT", and passing the address of the CLIENTCREATESTRUCT
 structure in lParam. You must also specify the handle to the frame window in the hWndParent parameter so 
 Windows knows the parent-child relationship between the frame window and the client window. The window styles 
 you should use are: WS_CHILD ,WS_VISIBLE and WS_CLIPCHILDREN. If you forget WS_VISIBLE, you won't see the MDI child windows even if they were created successfully.

The steps in creating the client window are as follows:

Obtain the handle to the submenu that you want to append the window list to. 
Put the value of the menu handle along with the value you want to use as the ID of the first MDI child window 
in a CLIENTCREATESTRUCT structure 
call CreateWindowEx with the class name "MDICLIENT", passing the address of the CLIENTCREATESTRUCT structure 
you just filled in in lParam. 
Creating the MDI Child Window
Now you have both the frame window and the client window. The stage is now ready for the creation of the MDI
 child window. There are two ways to do that.

You can send WM_MDICREATE message to the client window, passing the address of a structure of type 
MDICREATESTRUCT in wParam. This is the easiest and the usual method of MDI child window creation. 
.data?    mdicreate MDICREATESTRUCT <>    .....code    .....    [fill the members of mdicreate]    ......

    invoke SendMessage, hwndClient, WM_MDICREATE,addr mdicreate,0
SendMessage will return the handle of the newly created MDI child window if successful. 
You don't need to save the handle though. You can obtain it by other means if you want to. MDICREATESTRUCT has the following definition.

MDICREATESTRUCT STRUCT
szClass   DWORD ?
szTitle     DWORD ?
hOwner    DWORD ?
x               DWORD ?
y               DWORD ?
lx              DWORD ?
ly              DWORD ?
style         DWORD ?
lParam     DWORD ?
MDICREATESTRUCT ENDS
szClass the address of the window class you want to use as the template for the MDI child window. 
szTitle the address of the text you want to appear in the title bar of the child window 
hOwner the instance handle of the application 
x,y,lx,ly the upper left coordinate and the width and height of the child window 
style child window style. If you create the client window with MDIS_ALLCHILDSTYLES, you can use any window 
style.  
lParam an application-defined 32-bit value. This is a way of sharing values among MDI windows. 
If you don't need to use it, set it to NULL 

You can call CreateMDIWindow. This function has the following syntax: 
CreateMDIWindow proto lpClassName:DWORD                                           lpWindowName:DWORD                                           dwStyle:DWORD
                                           x:DWORD                                           y:DWORD                                           nWidth:DWORD                                           nHeight:DWORD                                           hWndParent:DWORD                                           hInstance:DWORD                                           lParam:DWORD
If you look closely at the parameters, you'll find that they are identical to the members of MDICREATESTRUCT 
structure, except for the hWndParent. Essentially it's the same number of parameters you pass with WM_MDICREATE.
 MDICREATESTRUCT doesn't have the hWndParent field because you must pass the whole structure to the correct client window with SendMessage anyway.

At this point, you may have some questions: which method should I use? What is the difference between the two? 
Here is the answer: 

The WM_MDICREATE method can only create the MDI child window in the same thread as the calling code.
 For example, if your application has 2 threads, and the first thread creates the MDI frame window, 
 if the second thread wants to create an MDI child, it must do so with CreateMDIChild: sending WM_MDICREATE
  message to the first thread won't work. If your application is single-threaded, you can use either method. 
  (Thanks yap for the correction - 04/24/2002)

A little more detail needs to be covered about the window procedure of the MDI child. As with the frame 
window case, you must not call DefWindowProc to handle the unprocessed messages. Instead, you must use 
DefMDIChildProc. This function has exactly the same parameters as DefWindowProc.

In addition to WM_MDICREATE, there are other MDI-related window messages. I'll list them below:

WM_MDIACTIVATE This message can be sent by the application to the client window to instruct the client 
window to activate the selected MDI child. When the client window receives the message, it activates the 
selected MDI child window and sends WM_MDIACTIVATE to the child being deactivated and activated. The use 
of this message is two-fold: it can be used by the application to activate the desired child window. 
And it can be used by the MDI child window itself as the indicator that it's being activated/deactivated. 
For example, if each MDI child window has different menu, it can use this opportunity to change the menu 
of the frame window when it's activated/deactivated. 
WM_MDICASCADE
WM_MDITILE
WM_MDIICONARRANGE  These messages handle the arrangement of the MDI child windows. For example, if you want 
the MDI child windows to arrange themselves in cascading style, send WM_MDICASCADE to the client window.  
WM_MDIDESTROY Send this message to the client window to destroy an MDI child window. You should use this 
message instead of calling DestroyWindow because if the MDI child window is maxmized, this message will 
restore the tile of the frame window. If you use DestroyWindow, the title of the frame window will not be 
restored. 
WM_MDIGETACTIVE Send this message to retrieve the handle of the currently active MDI child window. 
WM_MDIMAXIMIZE
WM_MDIRESTORE  Send WM_MDIMAXIMIZE to maximize the MDI child window and WM_MDIRESTORE to restore it to 
previous state. Always use these messages for the operations. If you use ShowWindow with SW_MAXIMIZE, 
the MDI child window will maximize fine but it will have the problem when you try to restore it to previous 
size. You can minimize the MDI child window with ShowWindow without problem, however. 
WM_MDINEXT Send this message to the client window to activate the next or the previous MDI child window 
according to the values in wParam and lParam. 
WM_MDIREFRESHMENU Send this message to the client window to refresh the menu of the frame window. Note 
that you must call DrawMenuBar to update the menu bar after sending this message. 
WM_MDISETMENU Send this message to the client window to replace the whole menu of the frame window or 
just the window submenu. You must use this message instead of SetMenu. After sending this message,
 you must call DrawMenuBar to update the menu bar. Normally you will use this message when the active 
 MDI child window has its own menu and you want it to replace the menu of the frame window while the
  MDI child window is active. 

I'll review the steps in creating an MDI application for you again below.

Register the window classes, both the frame window class and the MDI child window class 
Create the frame window with CreateWindowEx. 
Within the message loop, call TranslateMDISysAccel to process the MDI-related accelerator keys 
Within the window procedure of the frame window, call DefFrameProc to handle ALL messages unhandled by 
your code. 
Create the client window by calling CreateWindowEx using the name of the predefined window class, 
"MDICLIENT", passing the address of a CLIENTCREATESTRUCT structure in lParam. Normally, you would create 
the client window within the WM_CREATE handler of the frame window proc 
You can create an MDI child window by sending WM_MDICREATE to the client window or, alternatively, 
by calling CreateMDIWindow. 
Within the window proc of the MDI child window, pass all unhandled messages to DefMDIChildProc. 
Use MDI version of the messages if it exists. For example, use WM_MDIDESTROY instead of calling D
estroyWindow 
Example:
.386 .model flat,stdcall option casemap:none include \Masm32\include\windows.inc    
include \Masm32\include\user32.inc
include \Masm32\include\kernel32.inc
includelib \Masm32\lib\user32.lib
includelib \Masm32\lib\kernel32.lib
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.const
IDR_MAINMENU    equ 101
IDR_CHILDMENU   equ 102
IDM_EXIT        equ 40001
IDM_TILEHORZ    equ 40002
IDM_TILEVERT    equ 40003
IDM_CASCADE equ 40004
IDM_NEW         equ 40005
IDM_CLOSE   equ 40006

.data
ClassName   db "MDIASMClass",0
MDIClientName   db "MDICLIENT",0
MDIChildClassName   db "Win32asmMDIChild",0
MDIChildTitle   db "MDI Child",0
AppName     db "Win32asm MDI Demo",0
ClosePromptMessage  db "Are you sure you want to close this window?",0

.data?
hInstance   dd ?
hMainMenu   dd ?
hwndClient  dd ?
hChildMenu  dd ?
mdicreate       MDICREATESTRUCT <>
hwndFrame   dd ?

.code
start:
    invoke GetModuleHandle, NULL
    mov hInstance,eax
    invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT
    invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    ;=============================================
    ; Register the frame window class
    ;=============================================
    mov wc.cbSize,SIZEOF WNDCLASSEX
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc,OFFSET WndProc
    mov wc.cbClsExtra,NULL
    mov wc.cbWndExtra,NULL
    push hInstance
    pop wc.hInstance
    mov wc.hbrBackground,COLOR_APPWORKSPACE
    mov wc.lpszMenuName,IDR_MAINMENU
    mov wc.lpszClassName,OFFSET ClassName
    invoke LoadIcon,NULL,IDI_APPLICATION
    mov wc.hIcon,eax
    mov wc.hIconSm,eax
    invoke LoadCursor,NULL,IDC_ARROW
    mov wc.hCursor,eax
    invoke RegisterClassEx, addr wc
    ;================================================
    ; Register the MDI child window class
    ;================================================
    mov wc.lpfnWndProc,offset ChildProc
    mov wc.hbrBackground,COLOR_WINDOW+1
    mov wc.lpszClassName,offset MDIChildClassName
    invoke RegisterClassEx,addr wc
    invoke CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
            WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN,CW_USEDEFAULT,\
            CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,0,\
            hInst,NULL
    mov hwndFrame,eax
  invoke LoadMenu,hInstance, IDR_CHILDMENU
    mov hChildMenu,eax 
    invoke ShowWindow,hwndFrame,SW_SHOWNORMAL
    invoke UpdateWindow, hwndFrame
    .while TRUE
        invoke GetMessage,ADDR msg,NULL,0,0
        .break .if (!eax)
        invoke TranslateMDISysAccel,hwndClient,addr msg
        .if !eax
            invoke TranslateMessage, ADDR msg
            invoke DispatchMessage, ADDR msg
        .endif
    .endw
    invoke DestroyMenu, hChildMenu
    mov eax,msg.wParam
    ret
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL ClientStruct:CLIENTCREATESTRUCT
    .if uMsg==WM_CREATE
        invoke GetMenu,hWnd
        mov hMainMenu,eax
        invoke GetSubMenu,hMainMenu,1
        mov ClientStruct.hWindowMenu,eax
        mov ClientStruct.idFirstChild,100
        INVOKE CreateWindowEx,NULL,ADDR MDIClientName,NULL,\
                WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN,CW_USEDEFAULT,\
                CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,hWnd,NULL,\
                hInstance,addr ClientStruct
        mov hwndClient,eax
        ;=======================================
        ; Initialize the MDICREATESTRUCT
        ;=======================================
        mov mdicreate.szClass,offset MDIChildClassName
        mov mdicreate.szTitle,offset MDIChildTitle
        push hInstance
        pop mdicreate.hOwner
        mov mdicreate.x,CW_USEDEFAULT
        mov mdicreate.y,CW_USEDEFAULT
        mov mdicreate.lx,CW_USEDEFAULT
        mov mdicreate.ly,CW_USEDEFAULT
    .elseif uMsg==WM_COMMAND
        .if lParam==0
            mov eax,wParam
            .if ax==IDM_EXIT
                invoke SendMessage,hWnd,WM_CLOSE,0,0
            .elseif ax==IDM_TILEHORZ
                invoke SendMessage,hwndClient,WM_MDITILE,MDITILE_HORIZONTAL,0
            .elseif ax==IDM_TILEVERT
                invoke SendMessage,hwndClient,WM_MDITILE,MDITILE_VERTICAL,0
            .elseif ax==IDM_CASCADE
                invoke SendMessage,hwndClient,WM_MDICASCADE,MDITILE_SKIPDISABLED,0
            .elseif ax==IDM_NEW
                invoke SendMessage,hwndClient,WM_MDICREATE,0,addr mdicreate
            .elseif ax==IDM_CLOSE
                invoke SendMessage,hwndClient,WM_MDIGETACTIVE,0,0
                invoke SendMessage,eax,WM_CLOSE,0,0
            .else
                invoke DefFrameProc,hWnd,hwndClient,uMsg,wParam,lParam
                ret
            .endif
        .endif
    .elseif uMsg==WM_DESTROY
        invoke PostQuitMessage,NULL
    .else
        invoke DefFrameProc,hWnd,hwndClient,uMsg,wParam,lParam
        ret
    .endif
    xor eax,eax
    ret
WndProc endp

ChildProc proc hChild:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
    .if uMsg==WM_MDIACTIVATE
        mov eax,lParam
        .if eax==hChild
            invoke GetSubMenu,hChildMenu,1
            mov edx,eax
            invoke SendMessage,hwndClient,WM_MDISETMENU,hChildMenu,edx
        .else
            invoke GetSubMenu,hMainMenu,1
            mov edx,eax
            invoke SendMessage,hwndClient,WM_MDISETMENU,hMainMenu,edx
        .endif
        invoke DrawMenuBar,hwndFrame
    .elseif uMsg==WM_CLOSE
        invoke MessageBox,hChild,addr ClosePromptMessage,addr AppName,MB_YESNO
        .if eax==IDYES
            invoke SendMessage,hwndClient,WM_MDIDESTROY,hChild,0
        .endif
    .else
        invoke DefMDIChildProc,hChild,uMsg,wParam,lParam
        ret
    .endif
    xor eax,eax
    ret
ChildProc endp
end start

Analysis:
The first thing the program does is to register the window classes of the frame window and the MDI child
window. After that, it calls CreateWindowEx to create the frame window. Within the WM_CREATE handler of 
the frame window, we create the client window: 


    LOCAL ClientStruct:CLIENTCREATESTRUCT
    .if uMsg==WM_CREATE
        invoke GetMenu,hWnd
        mov hMainMenu,eax
        invoke GetSubMenu,hMainMenu,1
       mov ClientStruct.hWindowMenu,eax
        mov ClientStruct.idFirstChild,100 
        invoke CreateWindowEx,NULL,ADDR MDIClientName,NULL,\
            WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN,CW_USEDEFAULT,\
            CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,hWnd,NULL,\
            hInstance,addr ClientStruct
        mov hwndClient,eax

It calls GetMenu to obtain the handle to the menu of the frame window, to be used in the GetSubMenu call. 
Note that we pass the value 1 to GetSubMenu because the submenu we want the window list to appear is the 
second submenu. Then we fill the members of the CLIENTCREATESTRUCT structure.
Next, we initialize the MDICLIENTSTRUCT structure. Note that we don't need to do it here. It's only convenient 
to do it in WM_CREATE.

   mov mdicreate.szClass,offset MDIChildClassName
    mov mdicreate.szTitle,offset MDIChildTitle
    push hInstance
    pop mdicreate.hOwner
    mov mdicreate.x,CW_USEDEFAULT
    mov mdicreate.y,CW_USEDEFAULT
    mov mdicreate.lx,CW_USEDEFAULT
    mov mdicreate.ly,CW_USEDEFAULT

After the frame window is created (and also the client window), we call LoadMenu to load the 
child window menu from the resource. We need to get this menu handle so we can replace the menu of the
 frame window with it when an MDI child window is present. Don't forget to call DestroyMenu on the handle 
 before the application exits to Windows. Normally Windows will free the menu associated with a window 
 automatically when the application exits but in this case, the child window menu is not associated with 
 any window thus it will still occupy valuable memory even after the application exits.


   invoke LoadMenu,hInstance, IDR_CHILDMENU
    mov hChildMenu,eax
    ........
    invoke DestroyMenu, hChildMenu

Within the message loop, we call TranslateMDISysAccel.

   .while TRUE
        invoke GetMessage,ADDR msg,NULL,0,0
        .break .if (!eax)
        invoke TranslateMDISysAccel,hwndClient,addr msg
        .if !eax
            invoke TranslateMessage, ADDR msg
            invoke DispatchMessage, ADDR msg
        .endif
    .endw 
If TranslateMDISysAccel returns a non-zero value, it means the message was already handled by Windows 
itself so you don't need to do anything to the message. If it returns 0, the message is not MDI-related 
and thus should be handled as usual.


WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    .....
    .else
       invoke DefFrameProc,hWnd,hwndClient,uMsg,wParam,lParam
        ret 
    .endif
    xor eax,eax
    ret
WndProc endp
Note that within the window procedure of the frame window, we call DefFrameProc to handle the messages we 
are not interested in.

The bulk of the window procedure is the WM_COMMAND handler. When the user selects "New" from the File menu, 
we create a new MDI child window.

   .elseif ax==IDM_NEW
        invoke SendMessage,hwndClient,WM_MDICREATE,0,addr mdicreate

In our example, we create the MDI child window by sending WM_MDICREATE to the client window, passing the a
ddress of the MDICREATESTRUCT structure in lParam.

ChildProc proc hChild:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
    .if uMsg==WM_MDIACTIVATE
        mov eax,lParam
        .if eax==hChild
            invoke GetSubMenu,hChildMenu,1
            mov edx,eax
            invoke SendMessage,hwndClient,WM_MDISETMENU,hChildMenu,edx
        .else
            invoke GetSubMenu,hMainMenu,1
            mov edx,eax
            invoke SendMessage,hwndClient,WM_MDISETMENU,hMainMenu,edx
        .endif
        invoke DrawMenuBar,hwndFrame 
When the MDI child window is created, it monitors WM_MDIACTIVATE to see if it's the active window. 
It does this by comparing the value of the lParam which contains the handle of the active child window 
with its own handle. If they match, it's the active window and the next step is to replace the menu of 
the frame window to its own. Since the original menu will be replaced, you have to tell Windows again 
in which submenu the window list should appear. That's why we must call GetSubMenu again to retrieve 
the handle to the submenu. We send WM_MDISETMENU message to the client window to achieve the desired result.
 wParam of WM_MDISETMENU contains the handle of the menu you would like to replace the original menu. 
 lParam contains the handle of the submenu you want the window list to appear. Right after sending 
 WM_MDISETMENU, we call DrawMenuBar to refresh the menu else your menu will be a mess.

   .else
        invoke DefMDIChildProc,hChild,uMsg,wParam,lParam
        ret
    .endif 
Within the window procedure of the MDI    child window, you must pass all unhandled messages to 
DefMDIChildProc    instead of DefWindowProc.
   .elseif ax==IDM_TILEHORZ
        invoke SendMessage,hwndClient,WM_MDITILE,MDITILE_HORIZONTAL,0
    .elseif ax==IDM_TILEVERT
        invoke SendMessage,hwndClient,WM_MDITILE,MDITILE_VERTICAL,0
    .elseif ax==IDM_CASCADE
        invoke SendMessage,hwndClient,WM_MDICASCADE,MDITILE_SKIPDISABLED,0   
When the user selects one of the menuitems in the window submenu, we send the corresponding message to the 
client window. If the user chooses to tile the windows, we send WM_MDITILE to the client window, specifying 
in wParam what kind of tiling we want. WM_CASCADE is similar.

   .elseif ax==IDM_CLOSE
        invoke SendMessage,hwndClient,WM_MDIGETACTIVE,0,0
        invoke SendMessage,eax,WM_CLOSE,0,0 
If the user chooses "Close"    menuitem, we must obtain the handle of the currently active MDI child window   
 first by sending WM_MDIGETACTIVE to the client window. The return value in eax    is the handle of the 
 currently active MDI child window. After that, we send    WM_CLOSE to that window.
   .elseif uMsg==WM_CLOSE
        invoke MessageBox,hChild,addr ClosePromptMessage,addr AppName,MB_YESNO
        .if eax==IDYES
            invoke SendMessage,hwndClient,WM_MDIDESTROY,hChild,0
        .endif 
Within the window procedure of the MDI child, when WM_CLOSE is received, it displays a message box asking 
the user if he really wants to close the window. If the answer is yes, we send WM_MDIDESTROY to the client 
window. WM_MDIDESTROY closes the MDI child window and restores the title of the frame window.

Unfortunately you can't run Java applets  


Tutorial 33: RichEdit Control: Basics
  
There are lots of request on tutorials about RichEdit controls. Finally I have played with it enough to think
 I can write tutorials about it. So here it is: the first RichEdit tutorial. The tutorials will describe 
 nearly everything there is to know about RichEdit control or at least as much as I know it. The amount of 
 information is rather large so I divide it into several parts, this tutorial being the first part. In this 
 tutorial, you'll learn what a RichEdit control is, how to create it and how to load/save data to/from it.

Theory
A richedit control can be thought of as a souped-up edit control. It provides many desirable features that are 
lacking from the plain simple edit control, for example, the ability to use multiple font face/size, multiple-
level undo/redo, search-for-text operation, OLE-embedded objects, drag-and-drop editing support, etc. Since 
the richedit control has so many features, it's stored in a separate DLL. This also means that, to use it, 
you can't just call InitCommonControls like other common controls. You have to call LoadLibrary to load the 
richedit DLL.

The problem is that there are three versions of richedit control up till now. Version 1,2, and 3. The table 
below shows you the name of the DLL for each version.

DLL Name RichEdit version Richedit Class Name 
Riched32.dll 1.0 RICHEDIT 
RichEd20.dll 2.0 RICHEDIT20A 
RichEd20.dll 3.0 RICHEDIT20A 

You can notice that richedit version 2 and 3 use the same DLL name. They also use the same class name! This 
can pose a problem if you want to use specific features of richedit 3.0. Up to now, I haven't found an 
official method of differentiating between version 2.0 and 3.0. However, there is a workaround which works ok,
 I'll show you later.

.data
   RichEditDLL db "RichEd20.dll",0   ......data? hRichEditDLL dd ?.code  invoke LoadLibrary,addr RichEditDLL  
    mov hRichEditDLL,eax ......  invoke FreeLibrary,hRichEditDLL
When the richedit dll is loaded, it registers the RichEdit window class. Thus it's imperative that you load 
the DLL before you create the control. The names of the richedit control classes are also different. Now you 
may have a question: how do I know which version of richedit control should I use? Using the latest version is 
not always appropriate if you don't require the extra features. So below is the table that shows the features
 provided by each version of richedit control.

Feature Version 1.0 Version 2.0 Version 3.0 
selection bar x x x 
unicode editing   x x 
character/paragraph formatting x x x 
search for text forward forward/backward forward/backward 
OLE embedding x x x 
Drag and drop editing x x x 
Undo/Redo single-level multi-level multi-level 
automatic URL recognition   x x 
Accelerator key support   x x 
Windowless operation   x x 
Line break CRLF CR only CR only (can emulate version 1.0) 
Zoom     x 
Paragraph numbering     x 
simple table     x 
normal and heading styles     x 
underline coloring     x 
hidden text     x 
font binding     x 

The above table is by no means comprehensive: I only list the important features.

Creating the richedit control 
After loading the richedit dll, you can call CreateWindowEx to create the control. You can use edit control 
styles and common window styles in CreateWindowEx except ES_LOWERCASE, ES_UPPERCASE and ES_OEMCONVERT.

.const
    RichEditID equ 300
.data
    RichEditDLL db "RichEd20.dll",0    RichEditClass db "RichEdit20A",0
    ...
.data?  hRichEditDLL dd ?
    hwndRichEdit dd ?
.code
    .....
    invoke LoadLibrary,addr RichEditDLL
    mov hRichEditDLL,eax    invoke CreateWindowEx,0,addr RichEditClass,WS_VISIBLE or ES_MULTILINE or WS_CHILD or WS_VSCROLL or WS_HSCROLL, \
                                        CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,hWnd,RichEditID,hInstance,0
    mov hwndRichEdit,eax
Setting default text and background color
You may have the problem with setting text color and the background color of the edit control. But this
 problem has been remedy in richedit control. To set the background color of the richedit control, you 
 send EM_SETBKGNDCOLOR to the richedit control. This message has the following syntax.

wParam == color option. The value of 0 in this parameter specifies that Windows uses the color value in 
lParam as the background color. If this value is nonzero, Windows uses the Windows system background color. 
Since we send this message to change the background color, we must pass 0 in wParam.
lParam == specifies the COLORREF structure of the color you want to set if wParam is 0.

For example, if I want to set the background color to pure blue, I would issue this following line:

      invoke SendMessage,hwndRichEdit,EM_SETBKGNDCOLOR,0,0FF0000h
      
To set the text color, richedit control provides another new message, EM_SETCHARFORMAT, for the job. 
This message has the following syntax:

wParam == formatting options: 

SCF_ALL The operation affects all text in the control. 
SCF_SELECTION The operation affects only the text in selection 
SCF_WORD or SCF_SELECTION Affects the word in selection. If the selection is empy, ie, only the caret is in 
the word, the operation affects that word. SCF_WORD flag must be used with SCF_SELECTION. 

lParam == pointer to a CHARFORMAT or CHARFORMAT2 structure that specifies the text formatting to be applied. 
CHARFORMAT2 is available for richedit 2.0 and above only. This doesn't mean that you must use CHARFORMAT2 
with RichEdit 2.0 or above. You can still use CHARFORMAT if the added features in CHARFORMAT2 are not 
necessary for your need.

CHARFORMATA STRUCT
    cbSize DWORD ?
    dwMask DWORD ?
    dwEffects DWORD    ?
    yHeight DWORD ?
    yOffset DWORD ?
    crTextColor COLORREF ?
    bCharSet BYTE ?
    bPitchAndFamily    BYTE ?
    szFaceName BYTE LF_FACESIZE dup(?)
    _wPad2 WORD ?
CHARFORMATA ENDS 
Field Name Description 
cbSize The size of the structure. RichEdit control uses this field to determine the version of the structure 
whether it is CHARFORMAT or CHARFORMAT2 
dwMask Bit flags that determine which of the following members are valid.

CFM_BOLD The CFE_BOLD value of the dwEffects member is valid 
CFM_CHARSET The bCharSet member is valid. 
CFM_COLOR The crTextColor member and the CFE_AUTOCOLOR value of the dwEffects member are valid 
CFM_FACE The szFaceName member is valid. 
CFM_ITALIC The CFE_ITALIC value of the dwEffects member is valid 
CFM_OFFSET The yOffset member is valid 
CFM_PROTECTED The CFE_PROTECTED value of the dwEffects member is valid 
CFM_SIZE The yHeight member is valid 
CFM_STRIKEOUT The CFE_STRIKEOUT value of the dwEffects member is valid. 
CFM_UNDERLINE The CFE_UNDERLINE value of the dwEffects member is valid 
 
dwEffects The character effects. Can be the combination of the following values

CFE_AUTOCOLOR Use the system text color 
CFE_BOLD Characters are bold 
CFE_ITALIC Characters are italic 
CFE_STRIKEOUT Characters are struck. 
CFE_UNDERLINE Characters are underlined 
CFE_PROTECTED Characters are protected; an attempt to modify them will cause an EN_PROTECTED notification 
message.  
 
yHeight Character height, in twips (1/1440 of an inch or 1/20 of a printer's point).  
yOffset Character offset, in twips, from the baseline. If the value of this member is positive, the character
 is a superscript; if it is negative, the character is a subscript.  
crTextColor  Text color. This member is ignored if the CFE_AUTOCOLOR character effect is specified.  
bCharSet Character set value 
bPitchAndFamily Font family and pitch.  
szFaceName  Null-terminated character array specifying the font name 
_wPad2 Padding 

From examination of the structure, you'll see that we can change the text effects (bold,italic, strikeout,
underline), text color (crTextColor) and font face/size/character set. A notable flag is CFE_RPOTECTED. 
The text with this flag is marked as protected which means that when the user tries to modify it, 
EN_PROTECTED notification message will be sent to the parent window. And you can allow the change to 
appen or not.

CHARFORMAT2 adds more text styles such as font weight, spacing,text background color, kerning, etc. 
If you don't need these extra features, simply use CHARFORMAT. 

To set text formatting, you have to think about the range of text you want to apply to. Richedit control 
introduces the notion of character text range. Richedit control gives each character a number starting 
from 0: the first characterin the control has Id of 0, the second character 1 and so on. To specify a text 
range, you must give the richedit control two numbers: the IDs of the first and the last character of the 
range. To apply the text formatting with EM_SETCHARFORMAT, you have at most three choices: 

Apply to all text in the control (SCF_ALL) 
Apply to the text currently in selection (SCF_SELECTION) 
Apply to the whole word currently in selection (SCF_WORD or SCF_SELECTION) 
The first and the second choices are straightforward. The last choice requires a little explanation. 
If the current selection only covers one or more of the characters in the word but not the whole word, 
specifying the flag SCF_WORD+SCF_SELECTION applies the text formatting to the whole word. Even if there 
is no current selection, ie, only the caret is positioned in the word, the third choice also applies 
the text formatting to the whole word.

To use EM_SETCHARFORMAT, you need to fill several members of CHARFORMAT (or CHARFORMAT2) structure. 
For example, if we want to set the text color, we will fill the CHARFORMAT structure as follows:

.data?
    cf CHARFORMAT <>
....
.code
    mov cf.cbSize,sizeof cf
    mov cf.dwMask,CFM_COLOR
    mov cf.crTextColor,0FF0000h
    invoke SendMessage,hwndRichEdit,EM_SETCHARFORMAT,SCF_ALL,addr cf
The above code snippet sets the text color of the richedit control to pure blue. Note that if there is no text 
in the richedit control when EM_SETCHARFORMAT is issued, the text entered into the richedit control following 
the message will use the text formatting specified by the EM_SETCHARFORMAT message.


Setting the text/saving the text
For those of you who are used to edit control, you'll surely be familiar with WM_GETTEXT/WM_SETTEXT as the
 means to set the text/get the text to/from the control. This method still works with richedit control but 
 may not be efficient if the file is large. Edit control limits the text that can be entered into it to 64K 
 but richedit control can accept text much larger than that. It would be very cumbersome to allocate a very 
 large block of memory (such as 10 MB or so) to receive the text from WM_GETTEXT. Richedit control offers a 
 new approach to this method, ie. text streaming.

To put it simply, you provide the address of a callback function to the richedit control. And richedit control 
will call that callback, passing the address of the buffer to it, when it's ready. The callback will fill the
 buffer with the data it wants to send to the control or read the data from the buffer and then waits for the 
 next call until the operation is finished. This paradigm is used for both streaming in (setting the text) 
 and streaming out (getting the text out of the control). You'll see that this method is more efficient: 
 the buffer is provided by the richedit control itself so the data are divided into chunks. The operations 
 involve two messages: EM_STREAMIN and EM_STREAMOUT

Both EM_STREAMIN and EM_STREAMOUT use the same syntax:

wParam == formatting options.

SF_RTF The data is in the rich-text format (RTF)  
SF_TEXT The data is in the plain text format 
SFF_PLAINRTF Only the keywords common to all languages are streamed in. 
SFF_SELECTION If specified, the target of the operation is the text currently in selection. If you stream 
the text in, the text replaces the current selection. If you stream the text out, only the text currently 
in selection is streamed out. If this flag is not specified, the operation affects the whole text in the 
control. 
SF_UNICODE (Available on RichEdit 2.0 or later) Specify the unicode text. 

lParam == point to an EDITSTREAM structure which has the following definition:

 EDITSTREAM STRUCT
    dwCookie DWORD    ?
    dwError DWORD ?
    pfnCallback DWORD ?
EDITSTREAM ENDS
dwCookie application-defined value that will be passed to the callback function speficied in pfnCallback 
member below. We normally pass some important value to the callback function such as the file handle to use 
in the stream-in/out procedure. 
dwError Indicates the results of the stream-in (read) or stream-out (write) operation. A value of zero 
indicates no error. A nonzero value can be the return value of the EditStreamCallback function or a code 
indicating that the control encountered an error.  
pfnCallback Pointer to an EditStreamCallback function, which is an application-defined function that the 
control calls to transfer data. The control calls the callback function repeatedly, transferring a portion 
of the data with each call 

The editstream callback function has the following definition:

   EditStreamCallback proto dwCookie:DWORD,                pBuffer:DWORD,
                 NumBytes:DWORD,
                 pBytesTransferred:DWORD
You have to create a function with the above prototype in your program. And then pass its address to 
EM_STREAMIN or EM_STREAMOUT via EDITSTREAM structure.

For stream-in operation (settting the text in the richedit control):

   dwCookie: the application-defined value you pass to EM_STREAMIN via EDITSTREAM structure. We almost always
        pass the file handle of the file we want to set its content to the control here.
    pBuffer: points to the buffer provided by the richedit control that will receive the text from your 
    callback function.
    NumBytes: the maximum number of bytes you can write the the buffer (pBuffer) in this call. You MUST 
    always obey this limit, ie, you can send
        less data than the value in NumBytes but must not send more data than this value. You can think of 
        this value as the size
        of the buffer in pBuffer.
   pBytesTransferred: points to a dword that you must set the value indicating the number of bytes you 
   actually transferred to the buffer.
        This value is usually identical to the value in NumBytes. The exception is when the data is to send 
        is less than
        the size of the buffer provided such as when the end of file is reached.
For stream-out operation (getting the text out of the richedit control):

   dwCookie: Same as the stream-in operation. We usually pass the file handle we want to write the data to 
   in this parameter.
    pBuffer: points to the buffer provided by the richedit control that is filled with the data from the 
    richedit control.
        To obtain its size, you must examine the value of NumBytes. 
    NumBytes: the size of the data in the buffer pointed to by pBuffer.
    pBytesTransferred: points to a dword that you must set the value indicating the number of bytes 
    you actually read from the buffer.
The callback function returns 0 to indicate success and richedit control will continue calling the callback 
function if there is still data left to read/write. If some error occurs during the process and you want 
to stop the operation, returns a non-zero value and the richedit control will discard the data pointed to 
by pBuffer. The error/success value will be filled in the dwError field of EDITSTREAM so you can examine 
the error/success status of the stream operation after SendMessage returns. 

Example:
The example below is a simple editor which you can open an asm source code file, edit and save it. 
It uses RichEdit control version 2.0 or above.

.386
.model flat,stdcall
option casemap:none
include \Masm32\include\windows.inc
include \Masm32\include\user32.inc
include \Masm32\include\comdlg32.inc
include \Masm32\include\gdi32.inc
include \Masm32\include\kernel32.inc
includelib \Masm32\lib\gdi32.lib
includelib \Masm32\lib\comdlg32.lib
includelib \Masm32\lib\user32.lib
includelib \Masm32\lib\kernel32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.const
IDR_MAINMENU                   equ 101
IDM_OPEN                      equ  40001
IDM_SAVE                       equ 40002
IDM_CLOSE                      equ 40003
IDM_SAVEAS                     equ 40004
IDM_EXIT                       equ 40005
IDM_COPY                      equ  40006
IDM_CUT                       equ  40007
IDM_PASTE                      equ 40008
IDM_DELETE                     equ 40009
IDM_SELECTALL                  equ 40010
IDM_OPTION          equ 40011
IDM_UNDO            equ 40012
IDM_REDO            equ 40013
IDD_OPTIONDLG                  equ 101
IDC_BACKCOLORBOX               equ 1000
IDC_TEXTCOLORBOX               equ 1001

RichEditID          equ 300

.data
ClassName db "IczEditClass",0
AppName  db "IczEdit version 1.0",0
RichEditDLL db "riched20.dll",0
RichEditClass db "RichEdit20A",0
NoRichEdit db "Cannot find riched20.dll",0
ASMFilterString         db "ASM Source code (*.asm)",0,"*.asm",0
                db "All Files (*.*)",0,"*.*",0,0
OpenFileFail db "Cannot open the file",0
WannaSave db "The data in the control is modified. Want to save it?",0
FileOpened dd FALSE
BackgroundColor dd 0FFFFFFh     ; default to white
TextColor dd 0      ; default to black

.data?
hInstance dd ?
hRichEdit dd ?
hwndRichEdit dd ?
FileName db 256 dup(?)
AlternateFileName db 256 dup(?)
CustomColors dd 16 dup(?)

.code
start:
    invoke GetModuleHandle, NULL
    mov    hInstance,eax
  invoke LoadLibrary,addr RichEditDLL
    .if eax!=0
        mov hRichEdit,eax
        invoke WinMain, hInstance,0,0, SW_SHOWDEFAULT
        invoke FreeLibrary,hRichEdit
    .else
        invoke MessageBox,0,addr NoRichEdit,addr AppName,MB_OK or MB_ICONERROR
    .endif
    invoke ExitProcess,eax

WinMain proc hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hwnd:DWORD
    mov   wc.cbSize,SIZEOF WNDCLASSEX
    mov   wc.style, CS_HREDRAW or CS_VREDRAW
    mov   wc.lpfnWndProc, OFFSET WndProc
    mov   wc.cbClsExtra,NULL
    mov   wc.cbWndExtra,NULL
    push  hInst
    pop   wc.hInstance
    mov   wc.hbrBackground,COLOR_WINDOW+1
    mov   wc.lpszMenuName,IDR_MAINMENU
    mov   wc.lpszClassName,OFFSET ClassName
    invoke LoadIcon,NULL,IDI_APPLICATION
    mov   wc.hIcon,eax
    mov   wc.hIconSm,eax
    invoke LoadCursor,NULL,IDC_ARROW
    mov   wc.hCursor,eax
    invoke RegisterClassEx, addr wc
    INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
           hInst,NULL
    mov   hwnd,eax
    invoke ShowWindow, hwnd,SW_SHOWNORMAL
    invoke UpdateWindow, hwnd
    .while TRUE
        invoke GetMessage, ADDR msg,0,0,0
        .break .if (!eax)
        invoke TranslateMessage, ADDR msg
        invoke DispatchMessage, ADDR msg
    .endw
    mov   eax,msg.wParam
    ret
WinMain endp

StreamInProc proc hFile:DWORD,pBuffer:DWORD, NumBytes:DWORD, pBytesRead:DWORD
    invoke ReadFile,hFile,pBuffer,NumBytes,pBytesRead,0
    xor eax,1
    ret
StreamInProc endp

StreamOutProc proc hFile:DWORD,pBuffer:DWORD, NumBytes:DWORD, pBytesWritten:DWORD
    invoke WriteFile,hFile,pBuffer,NumBytes,pBytesWritten,0
    xor eax,1
    ret
StreamOutProc endp

CheckModifyState proc hWnd:DWORD
    invoke SendMessage,hwndRichEdit,EM_GETMODIFY,0,0
    .if eax!=0
        invoke MessageBox,hWnd,addr WannaSave,addr AppName,MB_YESNOCANCEL
        .if eax==IDYES
            invoke SendMessage,hWnd,WM_COMMAND,IDM_SAVE,0
        .elseif eax==IDCANCEL
            mov eax,FALSE
            ret
        .endif
    .endif
    mov eax,TRUE
    ret
CheckModifyState endp

SetColor proc
    LOCAL cfm:CHARFORMAT
    invoke SendMessage,hwndRichEdit,EM_SETBKGNDCOLOR,0,BackgroundColor
    invoke RtlZeroMemory,addr cfm,sizeof cfm
    mov cfm.cbSize,sizeof cfm
    mov cfm.dwMask,CFM_COLOR
    push TextColor
    pop cfm.crTextColor
    invoke SendMessage,hwndRichEdit,EM_SETCHARFORMAT,SCF_ALL,addr cfm
    ret
SetColor endp

OptionProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    LOCAL clr:CHOOSECOLOR
    .if uMsg==WM_INITDIALOG
    .elseif uMsg==WM_COMMAND
        mov eax,wParam
        shr eax,16
        .if ax==BN_CLICKED
            mov eax,wParam
            .if ax==IDCANCEL
                invoke SendMessage,hWnd,WM_CLOSE,0,0
            .elseif ax==IDC_BACKCOLORBOX
                invoke RtlZeroMemory,addr clr,sizeof clr
                mov clr.lStructSize,sizeof clr
                push hWnd
                pop clr.hwndOwner
                push hInstance
                pop clr.hInstance
                push BackgroundColor
                pop clr.rgbResult
                mov clr.lpCustColors,offset CustomColors
                mov clr.Flags,CC_ANYCOLOR or CC_RGBINIT
                invoke ChooseColor,addr clr
                .if eax!=0
                    push clr.rgbResult
                    pop BackgroundColor
                    invoke GetDlgItem,hWnd,IDC_BACKCOLORBOX
                    invoke InvalidateRect,eax,0,TRUE
                .endif
            .elseif ax==IDC_TEXTCOLORBOX
                invoke RtlZeroMemory,addr clr,sizeof clr
                mov clr.lStructSize,sizeof clr
                push hWnd
                pop clr.hwndOwner
                push hInstance
                pop clr.hInstance
                push TextColor
                pop clr.rgbResult
                mov clr.lpCustColors,offset CustomColors
                mov clr.Flags,CC_ANYCOLOR or CC_RGBINIT
                invoke ChooseColor,addr clr
                .if eax!=0
                    push clr.rgbResult
                    pop TextColor
                    invoke GetDlgItem,hWnd,IDC_TEXTCOLORBOX
                    invoke InvalidateRect,eax,0,TRUE
                .endif
            .elseif ax==IDOK
                ;==================================================================================
                ; Save the modify state of the richedit control because changing the text color changes the
                ; modify state of the richedit control.
                ;==================================================================================
                invoke SendMessage,hwndRichEdit,EM_GETMODIFY,0,0
                push eax
                invoke SetColor
                pop eax
                invoke SendMessage,hwndRichEdit,EM_SETMODIFY,eax,0
                invoke EndDialog,hWnd,0
            .endif
        .endif
    .elseif uMsg==WM_CTLCOLORSTATIC
        invoke GetDlgItem,hWnd,IDC_BACKCOLORBOX
        .if eax==lParam
            invoke CreateSolidBrush,BackgroundColor
            ret
        .else
            invoke GetDlgItem,hWnd,IDC_TEXTCOLORBOX
            .if eax==lParam
                invoke CreateSolidBrush,TextColor
                ret
            .endif
        .endif
        mov eax,FALSE
        ret
    .elseif uMsg==WM_CLOSE
        invoke EndDialog,hWnd,0
    .else
        mov eax,FALSE
        ret
    .endif
    mov eax,TRUE
    ret
OptionProc endp

WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    LOCAL chrg:CHARRANGE
    LOCAL ofn:OPENFILENAME
    LOCAL buffer[256]:BYTE
    LOCAL editstream:EDITSTREAM
    LOCAL hFile:DWORD
    .if uMsg==WM_CREATE
        invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr RichEditClass,0,WS_CHILD or WS_VISIBLE or ES_MULTILINE or WS_VSCROLL or WS_HSCROLL or ES_NOHIDESEL,\
                CW_USEDEFAULT,CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,hWnd,RichEditID,hInstance,0
        mov hwndRichEdit,eax
        ;=============================================================
        ; Set the text limit. The default is 64K
        ;=============================================================
        invoke SendMessage,hwndRichEdit,EM_LIMITTEXT,-1,0
        ;=============================================================
        ; Set the default text/background color
        ;=============================================================
        invoke SetColor
        invoke SendMessage,hwndRichEdit,EM_SETMODIFY,FALSE,0
        invoke SendMessage,hwndRichEdit,EM_EMPTYUNDOBUFFER,0,0
    .elseif uMsg==WM_INITMENUPOPUP
        mov eax,lParam
        .if ax==0       ; file menu
            .if FileOpened==TRUE    ; a file is already opened
                invoke EnableMenuItem,wParam,IDM_OPEN,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_CLOSE,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_SAVE,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_SAVEAS,MF_ENABLED
            .else
                invoke EnableMenuItem,wParam,IDM_OPEN,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_CLOSE,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_SAVE,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_SAVEAS,MF_GRAYED
            .endif
        .elseif ax==1   ; edit menu
            ;=============================================================================
            ; Check whether there is some text in the clipboard. If so, we enable the paste menuitem
            ;=============================================================================
            invoke SendMessage,hwndRichEdit,EM_CANPASTE,CF_TEXT,0
            .if eax==0      ; no text in the clipboard
                invoke EnableMenuItem,wParam,IDM_PASTE,MF_GRAYED
            .else
                invoke EnableMenuItem,wParam,IDM_PASTE,MF_ENABLED
            .endif
            ;==========================================================
            ; check whether the undo queue is empty
            ;==========================================================
            invoke SendMessage,hwndRichEdit,EM_CANUNDO,0,0
            .if eax==0
                invoke EnableMenuItem,wParam,IDM_UNDO,MF_GRAYED
            .else
                invoke EnableMenuItem,wParam,IDM_UNDO,MF_ENABLED
            .endif
            ;=========================================================
            ; check whether the redo queue is empty
            ;=========================================================
            invoke SendMessage,hwndRichEdit,EM_CANREDO,0,0
            .if eax==0
                invoke EnableMenuItem,wParam,IDM_REDO,MF_GRAYED
            .else
                invoke EnableMenuItem,wParam,IDM_REDO,MF_ENABLED
            .endif
            ;=========================================================
            ; check whether there is a current selection in the richedit control.
            ; If there is, we enable the cut/copy/delete menuitem
            ;=========================================================
            invoke SendMessage,hwndRichEdit,EM_EXGETSEL,0,addr chrg
            mov eax,chrg.cpMin
            .if eax==chrg.cpMax     ; no current selection
                invoke EnableMenuItem,wParam,IDM_COPY,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_CUT,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_DELETE,MF_GRAYED
            .else
                invoke EnableMenuItem,wParam,IDM_COPY,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_CUT,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_DELETE,MF_ENABLED
            .endif
        .endif
    .elseif uMsg==WM_COMMAND
        .if lParam==0       ; menu commands
            mov eax,wParam
            .if ax==IDM_OPEN
                invoke RtlZeroMemory,addr ofn,sizeof ofn
                mov ofn.lStructSize,sizeof ofn
                push hWnd
                pop ofn.hwndOwner
                push hInstance
                pop ofn.hInstance
                mov ofn.lpstrFilter,offset ASMFilterString
                mov ofn.lpstrFile,offset FileName
                mov byte ptr [FileName],0
                mov ofn.nMaxFile,sizeof FileName
                mov ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
                invoke GetOpenFileName,addr ofn
                .if eax!=0
                    invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
                    .if eax!=INVALID_HANDLE_VALUE
                        mov hFile,eax
                        ;================================================================
                        ; stream the text into the richedit control
                        ;================================================================
                        mov editstream.dwCookie,eax
                        mov editstream.pfnCallback,offset StreamInProc
                        invoke SendMessage,hwndRichEdit,EM_STREAMIN,SF_TEXT,addr editstream
                        ;==========================================================
                        ; Initialize the modify state to false
                        ;==========================================================
                        invoke SendMessage,hwndRichEdit,EM_SETMODIFY,FALSE,0
                        invoke CloseHandle,hFile
                        mov FileOpened,TRUE
                    .else
                        invoke MessageBox,hWnd,addr OpenFileFail,addr AppName,MB_OK or MB_ICONERROR
                    .endif
                .endif
            .elseif ax==IDM_CLOSE
                invoke CheckModifyState,hWnd
                .if eax==TRUE
                    invoke SetWindowText,hwndRichEdit,0
                    mov FileOpened,FALSE
                .endif
            .elseif ax==IDM_SAVE
                invoke CreateFile,addr FileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
                .if eax!=INVALID_HANDLE_VALUE
@@:
                    mov hFile,eax
                    ;================================================================
                    ; stream the text to the file
                    ;================================================================
                    mov editstream.dwCookie,eax
                    mov editstream.pfnCallback,offset StreamOutProc
                    invoke SendMessage,hwndRichEdit,EM_STREAMOUT,SF_TEXT,addr editstream
                    ;==========================================================
                    ; Initialize the modify state to false
                    ;==========================================================
                    invoke SendMessage,hwndRichEdit,EM_SETMODIFY,FALSE,0
                    invoke CloseHandle,hFile
                .else
                    invoke MessageBox,hWnd,addr OpenFileFail,addr AppName,MB_OK or MB_ICONERROR
                .endif
            .elseif ax==IDM_COPY
                invoke SendMessage,hwndRichEdit,WM_COPY,0,0
            .elseif ax==IDM_CUT
                invoke SendMessage,hwndRichEdit,WM_CUT,0,0
            .elseif ax==IDM_PASTE
                invoke SendMessage,hwndRichEdit,WM_PASTE,0,0
            .elseif ax==IDM_DELETE
                invoke SendMessage,hwndRichEdit,EM_REPLACESEL,TRUE,0
            .elseif ax==IDM_SELECTALL
                mov chrg.cpMin,0
                mov chrg.cpMax,-1
                invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr chrg
            .elseif ax==IDM_UNDO
                invoke SendMessage,hwndRichEdit,EM_UNDO,0,0
            .elseif ax==IDM_REDO
                invoke SendMessage,hwndRichEdit,EM_REDO,0,0
            .elseif ax==IDM_OPTION
                invoke DialogBoxParam,hInstance,IDD_OPTIONDLG,hWnd,addr OptionProc,0
            .elseif ax==IDM_SAVEAS
                invoke RtlZeroMemory,addr ofn,sizeof ofn
                mov ofn.lStructSize,sizeof ofn
                push hWnd
                pop ofn.hwndOwner
                push hInstance
                pop ofn.hInstance
                mov ofn.lpstrFilter,offset ASMFilterString
                mov ofn.lpstrFile,offset AlternateFileName
                mov byte ptr [AlternateFileName],0
                mov ofn.nMaxFile,sizeof AlternateFileName
                mov ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
                invoke GetSaveFileName,addr ofn
                .if eax!=0
                    invoke CreateFile,addr AlternateFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
                    .if eax!=INVALID_HANDLE_VALUE
                        jmp @B
                    .endif
                .endif
            .elseif ax==IDM_EXIT
                invoke SendMessage,hWnd,WM_CLOSE,0,0
            .endif
        .endif
    .elseif uMsg==WM_CLOSE
        invoke CheckModifyState,hWnd
        .if eax==TRUE
            invoke DestroyWindow,hWnd
        .endif
    .elseif uMsg==WM_SIZE
        mov eax,lParam
        mov edx,eax
        and eax,0FFFFh
        shr edx,16
        invoke MoveWindow,hwndRichEdit,0,0,eax,edx,TRUE
    .elseif uMsg==WM_DESTROY
        invoke PostQuitMessage,NULL
    .else
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
    .endif
    xor eax,eax
    ret
WndProc endp
end start

;===================================================================
; The resource file
;===================================================================
#include "resource.h"
#define IDR_MAINMENU                    101
#define IDD_OPTIONDLG                   101
#define IDC_BACKCOLORBOX                1000
#define IDC_TEXTCOLORBOX                1001
#define IDM_OPEN                        40001
#define IDM_SAVE                        40002
#define IDM_CLOSE                       40003
#define IDM_SAVEAS                      40004
#define IDM_EXIT                        40005
#define IDM_COPY                        40006
#define IDM_CUT                         40007
#define IDM_PASTE                       40008
#define IDM_DELETE                      40009
#define IDM_SELECTALL                   40010
#define IDM_OPTION                      40011
#define IDM_UNDO                        40012
#define IDM_REDO                        40013

IDR_MAINMENU MENU DISCARDABLE
BEGIN
    POPUP "&File"
    BEGIN
        MENUITEM "&Open",                       IDM_OPEN
        MENUITEM "&Close",                      IDM_CLOSE
        MENUITEM "&Save",                       IDM_SAVE
        MENUITEM "Save &As",                    IDM_SAVEAS
        MENUITEM SEPARATOR
        MENUITEM "E&xit",                       IDM_EXIT
    END
    POPUP "&Edit"
    BEGIN
        MENUITEM "&Undo",                       IDM_UNDO
        MENUITEM "&Redo",                       IDM_REDO
        MENUITEM "&Copy",                       IDM_COPY
        MENUITEM "C&ut",                        IDM_CUT
        MENUITEM "&Paste",                      IDM_PASTE
        MENUITEM SEPARATOR
        MENUITEM "&Delete",                     IDM_DELETE
        MENUITEM SEPARATOR
        MENUITEM "Select &All",                 IDM_SELECTALL
    END
    MENUITEM "Options",                     IDM_OPTION
END


IDD_OPTIONDLG DIALOG DISCARDABLE  0, 0, 183, 54
STYLE DS_MODALFRAME | WS_POPUP | WS_VISIBLE | WS_CAPTION | WS_SYSMENU | DS_CENTER
CAPTION "Options"
FONT 8, "MS Sans Serif"
BEGIN
    DEFPUSHBUTTON   "OK",IDOK,137,7,39,14
    PUSHBUTTON      "Cancel",IDCANCEL,137,25,39,14
    GROUPBOX        "",IDC_STATIC,5,0,124,49
    LTEXT           "Background Color:",IDC_STATIC,20,14,60,8
    LTEXT           "",IDC_BACKCOLORBOX,85,11,28,14,SS_NOTIFY | WS_BORDER
    LTEXT           "Text Color:",IDC_STATIC,20,33,35,8
    LTEXT           "",IDC_TEXTCOLORBOX,85,29,28,14,SS_NOTIFY | WS_BORDER
END

--------------------------------------------------------------------------------

Analysis:
The program first loads the richedit dll, which in this case is riched20.dll. If the dll cannot be loaded, 
it exits to Windows.


invoke LoadLibrary,addr RichEditDLL
.if eax!=0
    mov hRichEdit,eax
    invoke WinMain,hInstance,0,0, SW_SHOWDEFAULT
    invoke FreeLibrary,hRichEdit
.else
    invoke MessageBox,0,addr NoRichEdit,addr AppName,MB_OK or MB_ICONERROR
.endif
invoke ExitProcess,eax
After the dll is loaded successfully, we proceed to create a normal window which will be the parent of 
the richedit control. Within the WM_CREATE handler, we create the richedit control:

       invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr RichEditClass,0,WS_CHILD or WS_VISIBLE or ES_MULTILINE 
       or WS_VSCROLL or WS_HSCROLL or ES_NOHIDESEL,\
                CW_USEDEFAULT,CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,hWnd,RichEditID,hInstance,0
        mov hwndRichEdit,eax
Note that we specify ES_MULTILINE style else the control will be a single-lined one. 


       invoke SendMessage,hwndRichEdit,EM_LIMITTEXT,-1,0
After the richedit control is created, we must set the new text limit on it. By default, the richedit 
control has 64K text limit, the same as a simple multi-line edit control. We must extend this limit to
 allow it to operate with larger files. In the above line, I specify -1 which amounts to 0FFFFFFFFh, 
 a very large value.

       invoke SetColor

Next, we set the text/background color. Since this operation can be performed in other part of the program, 
I put the code in a function named SetColor. 


SetColor proc
    LOCAL cfm:CHARFORMAT
    invoke SendMessage,hwndRichEdit,EM_SETBKGNDCOLOR,0,BackgroundColor
Setting the background color of the richedit control is a straightforward operation: j
ust send EM_SETBKGNDCOLOR message to the richedit control. (If you use a multi-line edit control,
 you have to process WM_CTLCOLOREDIT). The default background color is white. 


   invoke RtlZeroMemory,addr cfm,sizeof cfm
    mov cfm.cbSize,sizeof cfm
    mov cfm.dwMask,CFM_COLOR
    push TextColor
    pop cfm.crTextColor
After the background color is set, we fill in the members of CHARFORMAT in order to set the text color. 
Note that we fill cbSize with the size of the structure so the richedit control knows we are sending 
it CHARFORMAT, not CHARFORMAT2. dwMask has only one flag, CFM_COLOR, because we only want to set the 
text color and crTextColor is filled with the value of the desired text color. 

   invoke SendMessage,hwndRichEdit,EM_SETCHARFORMAT,SCF_ALL,addr cfm
    ret
SetColor endp
After settting the color, you have to empty undo buffer simply because the act of changing text/background 
color is undo-able. We send EM_EMPTYUNDOBUFFER message to achieve this.

 invoke SendMessage,hwndRichEdit,EM_EMPTYUNDOBUFFER,0,0 
After filling the CHARFORMAT structure, we send EM_SETCHARFORMAT to the richedit control, specifying SCF_ALL 
flag in wParam to indicate that we want the text formatting to be applied to all text in the control. 

Note that when we first created the richedit control, we didn't specify its size/position at that time. 
That's because we want it to cover the whole client area of the parent window. We resize it whenever 
the size of the parent window changes.

    .elseif uMsg==WM_SIZE
        mov eax,lParam
        mov edx,eax
        and eax,0FFFFh
        shr edx,16
        invoke MoveWindow,hwndRichEdit,0,0,eax,edx,TRUE
In the above code snippet, we use the new dimension of the client area passed in lParam to resize the richedit
 control with MoveWindow.

When the user clicks on the File/Edit menu bar, we process WM_INITPOPUPMENU so that we can prepare the states 
of the menuitems in the submenu before displaying it to the user. For example, if a file is already opened in 
the richedit control, we want to disable the open menuitem and enable all the remaining menuitems.

In the case of the File menu bar, we use the variable FileOpened as the flag to determine whether a file is 
already opened. If the value in this variable is TRUE, we know that a file is already opened.

    .elseif uMsg==WM_INITMENUPOPUP
        mov eax,lParam
        .if ax==0       ; file menu
            .if FileOpened==TRUE    ; a file is already opened
                invoke EnableMenuItem,wParam,IDM_OPEN,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_CLOSE,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_SAVE,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_SAVEAS,MF_ENABLED
            .else
                invoke EnableMenuItem,wParam,IDM_OPEN,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_CLOSE,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_SAVE,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_SAVEAS,MF_GRAYED
            .endif
As you can see, if a file is already opened, we gray out the open menuitem and enable the remaining menuitems.
 The reverse is true of FileOpened is false.

In the case of the edit menu bar, we need to check the state of the richedit control/clipboard first.

            invoke SendMessage,hwndRichEdit,EM_CANPASTE,CF_TEXT,0
            .if eax==0      ; no text in the clipboard
                invoke EnableMenuItem,wParam,IDM_PASTE,MF_GRAYED
            .else
                invoke EnableMenuItem,wParam,IDM_PASTE,MF_ENABLED
            .endif
We first check whether some text is available in the clipboard by sending EM_CANPASTE message. If some text 
is available, SendMessage returns TRUE and we enable the paste menuitem. If not, we gray out the menuitem. 

            invoke SendMessage,hwndRichEdit,EM_CANUNDO,0,0
            .if eax==0
                invoke EnableMenuItem,wParam,IDM_UNDO,MF_GRAYED
            .else
                invoke EnableMenuItem,wParam,IDM_UNDO,MF_ENABLED
            .endif
Next, we check whether the undo buffer is empty by sending EM_CANUNDO message. If it's not empty, SendMessage
 returns TRUE and we enable the undo menuitem. 

            invoke SendMessage,hwndRichEdit,EM_CANREDO,0,0
            .if eax==0
                invoke EnableMenuItem,wParam,IDM_REDO,MF_GRAYED
            .else
                invoke EnableMenuItem,wParam,IDM_REDO,MF_ENABLED
            .endif
We check the redo buffer by sending EM_CANREDO message to the richedit control. If it's not empty, SendMessage 
returns TRUE and we enable the redo menuitem. 

            invoke SendMessage,hwndRichEdit,EM_EXGETSEL,0,addr chrg
            mov eax,chrg.cpMin
            .if eax==chrg.cpMax     ; no current selection
                invoke EnableMenuItem,wParam,IDM_COPY,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_CUT,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_DELETE,MF_GRAYED
            .else
                invoke EnableMenuItem,wParam,IDM_COPY,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_CUT,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_DELETE,MF_ENABLED
            .endif
Lastly, we check whether a current selection exists by sending EM_EXGETSEL message. This message uses 
a CHARRANGE structure which is defined as follows:

CHARRANGE STRUCT
  cpMin  DWORD      ?
  cpMax  DWORD      ?
CHARRANGE ENDS
cpMin contains the character position index immediately preceding the first character in the range.
cpMax contains the character position immediately following the last character in the range.

After EM_EXGETSEL returns, the CHARRANGE structure is filled with the starting-ending character position 
indices of the selection range. If there is no current selection, cpMin and cpMax are identical and we gray 
out the cut/copy/delete menuitems.

When the user clicks the Open menuitem, we display an open file dialog box and if the user selects a file, 
we open the file and stream its content to the richedit control.

                    invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
                    .if eax!=INVALID_HANDLE_VALUE
                        mov hFile,eax

                        mov editstream.dwCookie,eax
                        mov editstream.pfnCallback,offset StreamInProc
                        invoke SendMessage,hwndRichEdit,EM_STREAMIN,SF_TEXT,addr editstream
After the file is successfully opened with CreateFile, we fill the EDITSTREAM structure in preparation for EM_STREAMIN message. We choose to send the handle to the opened file via dwCookie member and pass the address of the stream callback function in pfnCallback.

The stream callback procedure itself is the essence of simplicity.

StreamInProc proc hFile:DWORD,pBuffer:DWORD, NumBytes:DWORD, pBytesRead:DWORD
    invoke ReadFile,hFile,pBuffer,NumBytes,pBytesRead,0
    xor eax,1
    ret
StreamInProc endp
You can see that all parameters of the stream callback procedure fit perfectly with ReadFile. And the 
return value of ReadFile is xor-ed with 1 so that if it returns 1 (success), the actual value returned 
in eax is 0 and vice versa.

   invoke SendMessage,hwndRichEdit,EM_SETMODIFY,FALSE,0
    invoke CloseHandle,hFile
    mov FileOpened,TRUE
After EM_STREAMIN returns, it means the stream operation is completed. In reality, we must check the value 
of dwError member of the EDITSTREAM structure.

Richedit (and edit) control supports a flag to indicate whether its content is modified. We can obtain the 
value of this flag by sending EM_GETMODIFY message to the control. SendMessage returns TRUE if the content 
of the control was modified. Since we stream the text into the control, it's a kind of a modification. 
We must set the modify flag to FALSE by sending EM_SETMODIFY with wParam==FALSE to the control to start
 anew after the stream-in opertion is finished. We immediately close the file and set FileOpened to TRUE 
 to indicate that a file was opened.

When the user clicks on save/saveas menuitem, we use EM_STREAMOUT message to output the content of the 
richedit control to a file. As with the streamin callback function, the stream-out callback function is 
simplicity in itself. It fits perfectly with WriteFile.

The text operations such as cut/copy/paste/redo/undo are easily implemented by sending single message to 
the richedit control, WM_CUT/WM_COPY/WM_PASTE/WM_REDO/WM_UNDO respectively. 

The delete/select all operations are done as follows:

            .elseif ax==IDM_DELETE
                invoke SendMessage,hwndRichEdit,EM_REPLACESEL,TRUE,0
            .elseif ax==IDM_SELECTALL
                mov chrg.cpMin,0
                mov chrg.cpMax,-1
                invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr chrg
The delete operation affects the currently selection. I send EM_REPLACESEL message with NULL string so the 
richedit control will replace the currently selected text with the null string.

The select-all operation is done by sending EM_EXSETSEL message, specifying cpMin==0 and cpMax==-1 which 
amounts to selecting all the text. 

When the user selects Option menu bar, we display a dialog box presenting the current background/text colors.



When the user clicks on one of the color boxes, it displays the choose-color dialog box. The "color box" is 
in fact a static control with SS_NOTIFY and WS_BORDER flag. A static control with SS_NOTIFY flag will notify 
its parent window with mouse actions on it, such as BN_CLICKED (STN_CLICKED). That's the trick. 


            .elseif ax==IDC_BACKCOLORBOX
                invoke RtlZeroMemory,addr clr,sizeof clr
                mov clr.lStructSize,sizeof clr
                push hWnd
                pop clr.hwndOwner
                push hInstance
                pop clr.hInstance
                push BackgroundColor
                pop clr.rgbResult
                mov clr.lpCustColors,offset CustomColors
                mov clr.Flags,CC_ANYCOLOR or CC_RGBINIT
                invoke ChooseColor,addr clr
                .if eax!=0
                    push clr.rgbResult
                    pop BackgroundColor
                    invoke GetDlgItem,hWnd,IDC_BACKCOLORBOX
                    invoke InvalidateRect,eax,0,TRUE
                .endif
When the user clicks on one of the color box, we fill the members of the CHOOSECOLOR structure and call 
ChooseColor to display the choose-color dialog box. If the user selects a color, the colorref value is 
returned in rgbResult member and we store that value in BackgroundColor variable. After that, we force a 
repaint on the color box by calling InvalidateRect on the handle to the color box. The color box sends
 WM_CTLCOLORSTATIC message to its parent window.

        invoke GetDlgItem,hWnd,IDC_BACKCOLORBOX
        .if eax==lParam
            invoke CreateSolidBrush,BackgroundColor
            ret
Within the WM_CTLCOLORSTATIC handler, we compare the handle of the static control passed in lParam to that
 of both the color boxes. If the values match, we create a new brush using the color in the variable and 
 immediately return. The static control will use the newly created brush to paint its background.

Unfortunately you can't run Java applets  


Tutorial 34: RichEdit Control: More Text Operations
  
You'll learn more about text operations under RichEdit control. Specifically, you'll know how to search 
for/replace text, jumping to specific line number.

Theory
Searching for Text
There are several text operations under RichEdit control. Searching for text is one such operation. Searching
 for text is done by sending EM_FINDTEXT or EM_FINDTEXTEX. These messages has a small difference.

EM_FINDTEXT
wParam == Search options. Can be any combination of the values in the table below.These options are identical 
for both
            EM_FINDTEXT and EM_FINDTEXTEX
FR_DOWN If this flag is specified, the search starts from the end of the current selection to the end of t
he text in the control (downward). This flag has effect only for RichEdit 2.0 or later: This behavior is 
the default for RichEdit 1.0. The default behavior of RichEdit 2.0 or later is to search from the end of 
the current selection to the beginning of the text (upward).
In summary, if you use RichEdit 1.0, you can't do anything about the search direction: it always searches 
downward. If you use RichEdit 2.0 and you want to search downward, you must specify this flag else the search 
would be upward. 
FR_MATCHCASE If this flag is specified, the search is case-sensitive. 
FR_WHOLEWORD If this flag is set, the search finds the whole word that matches the specified search string. 

Actually, there are a few more flags but they are relevant to non-English languages.
lParam == pointer to the FINDTEXT structure.

           FINDTEXT STRUCT
              chrg          CHARRANGE  <>
              lpstrText     DWORD      ?
            FINDTEXT ENDS

chrg is a CHARRANGE structure which is defined as follows:

           CHARRANGE STRUCT
              cpMin  DWORD      ?
              cpMax  DWORD      ?
            CHARRANGE ENDS

cpMin contains the character index of the first character in the character array (range).
cpMax contains the character index of the character immediately following the last character in the character 
array.

In essence, to search for a text string, you have to specify the character range in which to search. 
The meaning of cpMin
and cpMax differ according to whether the search is downward or upward. If the search is downward, cpMin
specifies the starting character index to search in and cpMax the ending character index. If the search is 
upward, the
reverse is true, ie. cpMin contains the ending character index while cpMax the starting character index.

lpstrText is the pointer to the text string to search for.

EM_FINDTEXT returns the character index of the first character in the matching text string in the richedit 
control. It returns -1 if
no match is found.

EM_FINDTEXTEX
wParam == the search options. Same as those of EM_FINDTEXT.
lParam == pointer to the FINDTEXTEX structure.

           FINDTEXTEX STRUCT
              chrg          CHARRANGE  <>
              lpstrText     DWORD      ?
              chrgText  CHARRANGE <>
            FINDTEXTEX ENDS

The first two members of FINDTEXTEX are identical to those of FINDTEXT structure. chrgText is a CHARRANGE 
structure that will
be filled with the starting/ending characterindices if a match is found.

The return value of EM_FINDTEXTEX is the same as that of EM_FINDTEXT.

The difference between EM_FINDTEXT and EM_FINDTEXTEX is that the FINDTEXTEX structure has an additional member,
chrgText, which will be filled with the starting/ending character indices if a match is found. This is 
convenient if we want to do
more text operations on the string.
Replace/Insert Text 
RichEdit control provides EM_SETTEXTEX for replacing/inserting text. This message combines the functionality 
of WM_SETTEXT and EM_REPLACESEL. It has the following syntax:

   EM_SETTEXTEX
    wParam == pointer to SETTEXTEX structure.

           SETTEXTEX STRUCT
              flags          DWORD      ?
              codepage       DWORD      ?
            SETTEXTEX ENDS

    flags can be the combination of the following values:
ST_DEFAULT Deletes the undo stack, discards rich-text formatting, replaces all text. 
ST_KEEPUNDO Keeps the undo stack 
ST_SELECTION Replaces selection and keeps rich-text formatting 

   codepage is the constant that specifies the code page you want to text to be. Usually, we simply use CP_ACP.
   
Text Selection
We can select the text programmatically with EM_SETSEL or EM_EXSETSEL. Either one works fine. Choosing which 
message to use depends on the available format of the character indices. If they are already stored in a 
CHARRANGE structure, it's easier to use EM_EXSETSEL.


   EM_EXSETSEL
    wParam == not used. Must be 0
    lParam == pointer to a CHARRANGE structure that contains the character range to be selected.
Event Notification
In the case of a multiline edit control, you have to subclass it in order to obtain the input messages such 
as mouse/keyboard events. RichEdit control provides a better scheme that will notify the parent window of 
such events. In order to register for notifications, the parent window sends EM_SETEVENTMASK message to the 
RichEdit control, specifying which events it's interested in. EM_SETEVENTMASK has the following syntax:

   EM_SETEVENTMASK
    wParam == not used. Must be 0
    lParam == event mask value. It can be the combination of the flags in the table below.
ENM_CHANGE Sends EN_CHANGE notifications 
ENM_CORRECTTEXT Sends EN_CORRECTTEXT notifications 
ENM_DRAGDROPDONE Sends EN_DRAGDROPDONE notifications 
ENM_DROPFILES Sends EN_DROPFILES notifications. 
ENM_KEYEVENTS Sends EN_MSGFILTER notifications for keyboard events 
ENM_LINK Rich Edit 2.0 and later: Sends EN_LINK notifications when the mouse pointer is over text that has 
the CFE_LINK and one of several mouse actions is performed. 
ENM_MOUSEEVENTS Sends EN_MSGFILTER notifications for mouse events 
ENM_OBJECTPOSITIONS Sends EN_OBJECTPOSITIONS notifications 
ENM_PROTECTED Sends EN_PROTECTED notifications 
ENM_REQUESTRESIZE Sends EN_REQUESTRESIZE notifications 
ENM_SCROLL Sends EN_HSCROLL and EN_VSCROLL notifications 
ENM_SCROLLEVENTS Sends EN_MSGFILTER notifications for mouse wheel events 
ENM_SELCHANGE Sends EN_SELCHANGE notifications 
ENM_UPDATE Sends EN_UPDATE notifications.
Rich Edit 2.0 and later: this flag is ignored and the EN_UPDATE notifications are always sent. However, 
if Rich Edit 3.0 emulates Rich Edit 1.0, you must use this flag to send EN_UPDATE notifications 
 

All the above notifications will be sent as WM_NOTIFY message: you have to check the code member of NMHDR
 structure for the notification message. For example, if you want to register for mouse events 
 (eg. you want to provide a context sensitive popup menu), you must do something like this:

    invoke SendMessage,hwndRichEdit,EM_SETEVENTMASK,0,ENM_MOUSEEVENTS
    .....
    .....
    WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    .....
    ....
        .elseif uMsg==WM_NOTIFY
            push esi
            mov esi,lParam
            assume esi:ptr NMHDR
            .if [esi].code==EN_MSGFILTER
                ....
                [ do something here]
                ....
            .endif
            pop esi
Example:
The following example is the update of IczEdit in tutorial no. 33. It adds search/replace functionality  
and accelerator keys to the program. It also processes the mouse events and provides a popup menu on right
 mouse click.

.386
.model flat,stdcall
option casemap:none
include \Masm32\include\windows.inc
include \Masm32\include\user32.inc
include \Masm32\include\comdlg32.inc
include \Masm32\include\gdi32.inc
include \Masm32\include\kernel32.inc
includelib \Masm32\lib\gdi32.lib
includelib \Masm32\lib\comdlg32.lib
includelib \Masm32\lib\user32.lib
includelib \Masm32\lib\kernel32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.const
IDR_MAINMENU                   equ 101
IDM_OPEN                      equ  40001
IDM_SAVE                       equ 40002
IDM_CLOSE                      equ 40003
IDM_SAVEAS                     equ 40004
IDM_EXIT                       equ 40005
IDM_COPY                      equ  40006
IDM_CUT                       equ  40007
IDM_PASTE                      equ 40008
IDM_DELETE                     equ 40009
IDM_SELECTALL                  equ 40010
IDM_OPTION          equ 40011
IDM_UNDO            equ 40012
IDM_REDO            equ 40013
IDD_OPTIONDLG                  equ 101
IDC_BACKCOLORBOX               equ 1000
IDC_TEXTCOLORBOX               equ 1001
IDR_MAINACCEL                 equ  105
IDD_FINDDLG                    equ 102
IDD_GOTODLG                    equ 103
IDD_REPLACEDLG                 equ 104
IDC_FINDEDIT                  equ  1000
IDC_MATCHCASE                  equ 1001
IDC_REPLACEEDIT                 equ 1001
IDC_WHOLEWORD                  equ 1002
IDC_DOWN                       equ 1003
IDC_UP                       equ   1004
IDC_LINENO                   equ   1005
IDM_FIND                       equ 40014
IDM_FINDNEXT                  equ  40015
IDM_REPLACE                     equ 40016
IDM_GOTOLINE                   equ 40017
IDM_FINDPREV                  equ  40018
RichEditID          equ 300

.data
ClassName db "IczEditClass",0
AppName  db "IczEdit version 2.0",0
RichEditDLL db "riched20.dll",0
RichEditClass db "RichEdit20A",0
NoRichEdit db "Cannot find riched20.dll",0
ASMFilterString         db "ASM Source code (*.asm)",0,"*.asm",0
                db "All Files (*.*)",0,"*.*",0,0
OpenFileFail db "Cannot open the file",0
WannaSave db "The data in the control is modified. Want to save it?",0
FileOpened dd FALSE
BackgroundColor dd 0FFFFFFh     ; default to white
TextColor dd 0    ; default to black
hSearch dd ?      ; handle to the search/replace dialog box
hAccel dd ?

.data?
hInstance dd ?
hRichEdit dd ?
hwndRichEdit dd ?
FileName db 256 dup(?)
AlternateFileName db 256 dup(?)
CustomColors dd 16 dup(?)
FindBuffer db 256 dup(?)
ReplaceBuffer db 256 dup(?)
uFlags dd ?
findtext FINDTEXTEX <>

.code
start:
    mov byte ptr [FindBuffer],0
    mov byte ptr [ReplaceBuffer],0
    invoke GetModuleHandle, NULL
    mov    hInstance,eax
    invoke LoadLibrary,addr RichEditDLL
    .if eax!=0
        mov hRichEdit,eax
        invoke WinMain, hInstance,0,0, SW_SHOWDEFAULT
        invoke FreeLibrary,hRichEdit
    .else
        invoke MessageBox,0,addr NoRichEdit,addr AppName,MB_OK or MB_ICONERROR
    .endif
    invoke ExitProcess,eax

WinMain proc hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hwnd:DWORD
    mov   wc.cbSize,SIZEOF WNDCLASSEX
    mov   wc.style, CS_HREDRAW or CS_VREDRAW
    mov   wc.lpfnWndProc, OFFSET WndProc
    mov   wc.cbClsExtra,NULL
    mov   wc.cbWndExtra,NULL
    push  hInst
    pop   wc.hInstance
    mov   wc.hbrBackground,COLOR_WINDOW+1
    mov   wc.lpszMenuName,IDR_MAINMENU
    mov   wc.lpszClassName,OFFSET ClassName
    invoke LoadIcon,NULL,IDI_APPLICATION
    mov   wc.hIcon,eax
    mov   wc.hIconSm,eax
    invoke LoadCursor,NULL,IDC_ARROW
    mov   wc.hCursor,eax
    invoke RegisterClassEx, addr wc
    INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
           hInst,NULL
    mov   hwnd,eax
    invoke ShowWindow, hwnd,SW_SHOWNORMAL
    invoke UpdateWindow, hwnd
    invoke LoadAccelerators,hInstance,IDR_MAINACCEL
    mov hAccel,eax
    .while TRUE
        invoke GetMessage, ADDR msg,0,0,0
        .break .if (!eax)
        invoke IsDialogMessage,hSearch,addr msg
        .if eax==FALSE
            invoke TranslateAccelerator,hwnd,hAccel,addr msg
            .if eax==0
                invoke TranslateMessage, ADDR msg
                invoke DispatchMessage, ADDR msg
            .endif
        .endif
    .endw
    mov   eax,msg.wParam
    ret
WinMain endp

StreamInProc proc hFile:DWORD,pBuffer:DWORD, NumBytes:DWORD, pBytesRead:DWORD
    invoke ReadFile,hFile,pBuffer,NumBytes,pBytesRead,0
    xor eax,1
    ret
StreamInProc endp

StreamOutProc proc hFile:DWORD,pBuffer:DWORD, NumBytes:DWORD, pBytesWritten:DWORD
    invoke WriteFile,hFile,pBuffer,NumBytes,pBytesWritten,0
    xor eax,1
    ret
StreamOutProc endp

CheckModifyState proc hWnd:DWORD
    invoke SendMessage,hwndRichEdit,EM_GETMODIFY,0,0
    .if eax!=0
        invoke MessageBox,hWnd,addr WannaSave,addr AppName,MB_YESNOCANCEL
        .if eax==IDYES
            invoke SendMessage,hWnd,WM_COMMAND,IDM_SAVE,0
        .elseif eax==IDCANCEL
            mov eax,FALSE
            ret
        .endif
    .endif
    mov eax,TRUE
    ret
CheckModifyState endp

SetColor proc
    LOCAL cfm:CHARFORMAT
    invoke SendMessage,hwndRichEdit,EM_SETBKGNDCOLOR,0,BackgroundColor
    invoke RtlZeroMemory,addr cfm,sizeof cfm
    mov cfm.cbSize,sizeof cfm
    mov cfm.dwMask,CFM_COLOR
    push TextColor
    pop cfm.crTextColor
    invoke SendMessage,hwndRichEdit,EM_SETCHARFORMAT,SCF_ALL,addr cfm
    ret
SetColor endp

OptionProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    LOCAL clr:CHOOSECOLOR
    .if uMsg==WM_INITDIALOG
    .elseif uMsg==WM_COMMAND
        mov eax,wParam
        shr eax,16
        .if ax==BN_CLICKED
            mov eax,wParam
            .if ax==IDCANCEL
                invoke SendMessage,hWnd,WM_CLOSE,0,0
            .elseif ax==IDC_BACKCOLORBOX
                invoke RtlZeroMemory,addr clr,sizeof clr
                mov clr.lStructSize,sizeof clr
                push hWnd
                pop clr.hwndOwner
                push hInstance
                pop clr.hInstance
                push BackgroundColor
                pop clr.rgbResult
                mov clr.lpCustColors,offset CustomColors
                mov clr.Flags,CC_ANYCOLOR or CC_RGBINIT
                invoke ChooseColor,addr clr
                .if eax!=0
                    push clr.rgbResult
                    pop BackgroundColor
                    invoke GetDlgItem,hWnd,IDC_BACKCOLORBOX
                    invoke InvalidateRect,eax,0,TRUE
                .endif
            .elseif ax==IDC_TEXTCOLORBOX
                invoke RtlZeroMemory,addr clr,sizeof clr
                mov clr.lStructSize,sizeof clr
                push hWnd
                pop clr.hwndOwner
                push hInstance
                pop clr.hInstance
                push TextColor
                pop clr.rgbResult
                mov clr.lpCustColors,offset CustomColors
                mov clr.Flags,CC_ANYCOLOR or CC_RGBINIT
                invoke ChooseColor,addr clr
                .if eax!=0
                    push clr.rgbResult
                    pop TextColor
                    invoke GetDlgItem,hWnd,IDC_TEXTCOLORBOX
                    invoke InvalidateRect,eax,0,TRUE
                .endif
            .elseif ax==IDOK
                invoke SendMessage,hwndRichEdit,EM_GETMODIFY,0,0
                push eax
                invoke SetColor
                pop eax
                invoke SendMessage,hwndRichEdit,EM_SETMODIFY,eax,0
                invoke EndDialog,hWnd,0
            .endif
        .endif
    .elseif uMsg==WM_CTLCOLORSTATIC
        invoke GetDlgItem,hWnd,IDC_BACKCOLORBOX
        .if eax==lParam
            invoke CreateSolidBrush,BackgroundColor
            ret
        .else
            invoke GetDlgItem,hWnd,IDC_TEXTCOLORBOX
            .if eax==lParam
                invoke CreateSolidBrush,TextColor
                ret
            .endif
        .endif
        mov eax,FALSE
        ret
    .elseif uMsg==WM_CLOSE
        invoke EndDialog,hWnd,0
    .else
        mov eax,FALSE
        ret
    .endif
    mov eax,TRUE
    ret
OptionProc endp

SearchProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    .if uMsg==WM_INITDIALOG
        push hWnd
        pop hSearch
        invoke CheckRadioButton,hWnd,IDC_DOWN,IDC_UP,IDC_DOWN
        invoke SendDlgItemMessage,hWnd,IDC_FINDEDIT,WM_SETTEXT,0,addr FindBuffer
    .elseif uMsg==WM_COMMAND
        mov eax,wParam
        shr eax,16
        .if ax==BN_CLICKED
            mov eax,wParam
            .if ax==IDOK
                mov uFlags,0
                invoke SendMessage,hwndRichEdit,EM_EXGETSEL,0,addr findtext.chrg
                invoke GetDlgItemText,hWnd,IDC_FINDEDIT,addr FindBuffer,sizeof FindBuffer
                .if eax!=0
                    invoke IsDlgButtonChecked,hWnd,IDC_DOWN
                    .if eax==BST_CHECKED
                        or uFlags,FR_DOWN
                        mov eax,findtext.chrg.cpMin
                        .if eax!=findtext.chrg.cpMax
                            push findtext.chrg.cpMax
                            pop findtext.chrg.cpMin
                        .endif
                        mov findtext.chrg.cpMax,-1
                    .else
                        mov findtext.chrg.cpMax,0
                    .endif
                    invoke IsDlgButtonChecked,hWnd,IDC_MATCHCASE
                    .if eax==BST_CHECKED
                        or uFlags,FR_MATCHCASE
                    .endif
                    invoke IsDlgButtonChecked,hWnd,IDC_WHOLEWORD
                    .if eax==BST_CHECKED
                        or uFlags,FR_WHOLEWORD
                    .endif
                    mov findtext.lpstrText,offset FindBuffer
                    invoke SendMessage,hwndRichEdit,EM_FINDTEXTEX,uFlags,addr findtext
                    .if eax!=-1
                        invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr findtext.chrgText
                    .endif
                .endif
            .elseif ax==IDCANCEL
                invoke SendMessage,hWnd,WM_CLOSE,0,0
            .else
                mov eax,FALSE
                ret
            .endif
        .endif
    .elseif uMsg==WM_CLOSE
        mov hSearch,0
        invoke EndDialog,hWnd,0
    .else
        mov eax,FALSE
        ret
    .endif
    mov eax,TRUE
    ret
SearchProc endp

ReplaceProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    LOCAL settext:SETTEXTEX
    .if uMsg==WM_INITDIALOG
        push hWnd
        pop hSearch
        invoke SetDlgItemText,hWnd,IDC_FINDEDIT,addr FindBuffer
        invoke SetDlgItemText,hWnd,IDC_REPLACEEDIT,addr ReplaceBuffer
    .elseif uMsg==WM_COMMAND
        mov eax,wParam
        shr eax,16
        .if ax==BN_CLICKED
            mov eax,wParam
            .if ax==IDCANCEL
                invoke SendMessage,hWnd,WM_CLOSE,0,0
            .elseif ax==IDOK
                invoke GetDlgItemText,hWnd,IDC_FINDEDIT,addr FindBuffer,sizeof FindBuffer
                invoke GetDlgItemText,hWnd,IDC_REPLACEEDIT,addr ReplaceBuffer,sizeof ReplaceBuffer
                mov findtext.chrg.cpMin,0
                mov findtext.chrg.cpMax,-1
                mov findtext.lpstrText,offset FindBuffer
                mov settext.flags,ST_SELECTION
                mov settext.codepage,CP_ACP
                .while TRUE
                    invoke SendMessage,hwndRichEdit,EM_FINDTEXTEX,FR_DOWN,addr findtext
                    .if eax==-1
                        .break
                    .else
                        invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr findtext.chrgText
                        invoke SendMessage,hwndRichEdit,EM_SETTEXTEX,addr settext,addr ReplaceBuffer
                    .endif
                .endw
            .endif
        .endif
    .elseif uMsg==WM_CLOSE
        mov hSearch,0
        invoke EndDialog,hWnd,0
    .else
        mov eax,FALSE
        ret
    .endif
    mov eax,TRUE
    ret
ReplaceProc endp

GoToProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    LOCAL LineNo:DWORD
    LOCAL chrg:CHARRANGE
    .if uMsg==WM_INITDIALOG
        push hWnd
        pop hSearch
    .elseif uMsg==WM_COMMAND
        mov eax,wParam
        shr eax,16
        .if ax==BN_CLICKED
            mov eax,wParam
            .if ax==IDCANCEL
                invoke SendMessage,hWnd,WM_CLOSE,0,0
            .elseif ax==IDOK
                invoke GetDlgItemInt,hWnd,IDC_LINENO,NULL,FALSE
                mov LineNo,eax
                invoke SendMessage,hwndRichEdit,EM_GETLINECOUNT,0,0
                .if eax>LineNo
                    invoke SendMessage,hwndRichEdit,EM_LINEINDEX,LineNo,0
                    mov chrg.cpMin,eax
                    mov chrg.cpMax,eax
                    invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr chrg
                    invoke SetFocus,hwndRichEdit
                .endif
            .endif
        .endif
    .elseif uMsg==WM_CLOSE
        mov hSearch,0
        invoke EndDialog,hWnd,0
    .else
        mov eax,FALSE
        ret
    .endif
    mov eax,TRUE
    ret
GoToProc endp

PrepareEditMenu proc hSubMenu:DWORD
    LOCAL chrg:CHARRANGE
    invoke SendMessage,hwndRichEdit,EM_CANPASTE,CF_TEXT,0
    .if eax==0      ; no text in the clipboard
        invoke EnableMenuItem,hSubMenu,IDM_PASTE,MF_GRAYED
    .else
        invoke EnableMenuItem,hSubMenu,IDM_PASTE,MF_ENABLED
    .endif
    invoke SendMessage,hwndRichEdit,EM_CANUNDO,0,0
    .if eax==0
        invoke EnableMenuItem,hSubMenu,IDM_UNDO,MF_GRAYED
    .else
        invoke EnableMenuItem,hSubMenu,IDM_UNDO,MF_ENABLED
    .endif
    invoke SendMessage,hwndRichEdit,EM_CANREDO,0,0
    .if eax==0
        invoke EnableMenuItem,hSubMenu,IDM_REDO,MF_GRAYED
    .else
        invoke EnableMenuItem,hSubMenu,IDM_REDO,MF_ENABLED
    .endif
    invoke SendMessage,hwndRichEdit,EM_EXGETSEL,0,addr chrg
    mov eax,chrg.cpMin
    .if eax==chrg.cpMax     ; no current selection
        invoke EnableMenuItem,hSubMenu,IDM_COPY,MF_GRAYED
        invoke EnableMenuItem,hSubMenu,IDM_CUT,MF_GRAYED
        invoke EnableMenuItem,hSubMenu,IDM_DELETE,MF_GRAYED
    .else
        invoke EnableMenuItem,hSubMenu,IDM_COPY,MF_ENABLED
        invoke EnableMenuItem,hSubMenu,IDM_CUT,MF_ENABLED
        invoke EnableMenuItem,hSubMenu,IDM_DELETE,MF_ENABLED
    .endif
    ret
PrepareEditMenu endp

WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    LOCAL ofn:OPENFILENAME
    LOCAL buffer[256]:BYTE
    LOCAL editstream:EDITSTREAM
    LOCAL hFile:DWORD
    LOCAL hPopup:DWORD
    LOCAL pt:POINT
    LOCAL chrg:CHARRANGE
    .if uMsg==WM_CREATE
        invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr RichEditClass,0,WS_CHILD or WS_VISIBLE or ES_MULTILINE or WS_VSCROLL or WS_HSCROLL or ES_NOHIDESEL,\
                CW_USEDEFAULT,CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,hWnd,RichEditID,hInstance,0
        mov hwndRichEdit,eax
        invoke SendMessage,hwndRichEdit,EM_LIMITTEXT,-1,0
        invoke SetColor
        invoke SendMessage,hwndRichEdit,EM_SETMODIFY,FALSE,0
        invoke SendMessage,hwndRichEdit,EM_SETEVENTMASK,0,ENM_MOUSEEVENTS
        invoke SendMessage,hwndRichEdit,EM_EMPTYUNDOBUFFER,0,0
    .elseif uMsg==WM_NOTIFY
        push esi
        mov esi,lParam
        assume esi:ptr NMHDR
        .if [esi].code==EN_MSGFILTER
            assume esi:ptr MSGFILTER
            .if [esi].msg==WM_RBUTTONDOWN
                invoke GetMenu,hWnd
                invoke GetSubMenu,eax,1
                mov hPopup,eax
                invoke PrepareEditMenu,hPopup
                mov edx,[esi].lParam
                mov ecx,edx
                and edx,0FFFFh
                shr ecx,16
                mov pt.x,edx
                mov pt.y,ecx
                invoke ClientToScreen,hWnd,addr pt
                invoke TrackPopupMenu,hPopup,TPM_LEFTALIGN or TPM_BOTTOMALIGN,pt.x,pt.y,NULL,hWnd,NULL
            .endif
        .endif
        pop esi
    .elseif uMsg==WM_INITMENUPOPUP
        mov eax,lParam
        .if ax==0       ; file menu
            .if FileOpened==TRUE    ; a file is already opened
                invoke EnableMenuItem,wParam,IDM_OPEN,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_CLOSE,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_SAVE,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_SAVEAS,MF_ENABLED
            .else
                invoke EnableMenuItem,wParam,IDM_OPEN,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_CLOSE,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_SAVE,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_SAVEAS,MF_GRAYED
            .endif
        .elseif ax==1   ; edit menu
            invoke PrepareEditMenu,wParam
        .elseif ax==2       ; search menu bar
            .if FileOpened==TRUE
                invoke EnableMenuItem,wParam,IDM_FIND,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_FINDNEXT,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_FINDPREV,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_REPLACE,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_GOTOLINE,MF_ENABLED
            .else
                invoke EnableMenuItem,wParam,IDM_FIND,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_FINDNEXT,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_FINDPREV,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_REPLACE,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_GOTOLINE,MF_GRAYED
            .endif
        .endif
    .elseif uMsg==WM_COMMAND
        .if lParam==0       ; menu commands
            mov eax,wParam
            .if ax==IDM_OPEN
                invoke RtlZeroMemory,addr ofn,sizeof ofn
                mov ofn.lStructSize,sizeof ofn
                push hWnd
                pop ofn.hwndOwner
                push hInstance
                pop ofn.hInstance
                mov ofn.lpstrFilter,offset ASMFilterString
                mov ofn.lpstrFile,offset FileName
                mov byte ptr [FileName],0
                mov ofn.nMaxFile,sizeof FileName
                mov ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
                invoke GetOpenFileName,addr ofn
                .if eax!=0
                    invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
                    .if eax!=INVALID_HANDLE_VALUE
                        mov hFile,eax
                        ;================================================================
                        ; stream the text into the richedit control
                        ;================================================================
                        mov editstream.dwCookie,eax
                        mov editstream.pfnCallback,offset StreamInProc
                        invoke SendMessage,hwndRichEdit,EM_STREAMIN,SF_TEXT,addr editstream
                        ;==========================================================
                        ; Initialize the modify state to false
                        ;==========================================================
                        invoke SendMessage,hwndRichEdit,EM_SETMODIFY,FALSE,0
                        invoke CloseHandle,hFile
                        mov FileOpened,TRUE
                    .else
                        invoke MessageBox,hWnd,addr OpenFileFail,addr AppName,MB_OK or MB_ICONERROR
                    .endif
                .endif
            .elseif ax==IDM_CLOSE
                invoke CheckModifyState,hWnd
                .if eax==TRUE
                    invoke SetWindowText,hwndRichEdit,0
                    mov FileOpened,FALSE
                .endif
            .elseif ax==IDM_SAVE
                invoke CreateFile,addr FileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
                .if eax!=INVALID_HANDLE_VALUE
@@:
                    mov hFile,eax
                    ;================================================================
                    ; stream the text to the file
                    ;================================================================
                    mov editstream.dwCookie,eax
                    mov editstream.pfnCallback,offset StreamOutProc
                    invoke SendMessage,hwndRichEdit,EM_STREAMOUT,SF_TEXT,addr editstream
                    ;==========================================================
                    ; Initialize the modify state to false
                    ;==========================================================
                    invoke SendMessage,hwndRichEdit,EM_SETMODIFY,FALSE,0
                    invoke CloseHandle,hFile
                .else
                    invoke MessageBox,hWnd,addr OpenFileFail,addr AppName,MB_OK or MB_ICONERROR
                .endif
            .elseif ax==IDM_COPY
                invoke SendMessage,hwndRichEdit,WM_COPY,0,0
            .elseif ax==IDM_CUT
                invoke SendMessage,hwndRichEdit,WM_CUT,0,0
            .elseif ax==IDM_PASTE
                invoke SendMessage,hwndRichEdit,WM_PASTE,0,0
            .elseif ax==IDM_DELETE
                invoke SendMessage,hwndRichEdit,EM_REPLACESEL,TRUE,0
            .elseif ax==IDM_SELECTALL
                mov chrg.cpMin,0
                mov chrg.cpMax,-1
                invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr chrg
            .elseif ax==IDM_UNDO
                invoke SendMessage,hwndRichEdit,EM_UNDO,0,0
            .elseif ax==IDM_REDO
                invoke SendMessage,hwndRichEdit,EM_REDO,0,0
            .elseif ax==IDM_OPTION
                invoke DialogBoxParam,hInstance,IDD_OPTIONDLG,hWnd,addr OptionProc,0
            .elseif ax==IDM_SAVEAS
                invoke RtlZeroMemory,addr ofn,sizeof ofn
                mov ofn.lStructSize,sizeof ofn
                push hWnd
                pop ofn.hwndOwner
                push hInstance
                pop ofn.hInstance
                mov ofn.lpstrFilter,offset ASMFilterString
                mov ofn.lpstrFile,offset AlternateFileName
                mov byte ptr [AlternateFileName],0
                mov ofn.nMaxFile,sizeof AlternateFileName
                mov ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
                invoke GetSaveFileName,addr ofn
                .if eax!=0
                    invoke CreateFile,addr AlternateFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
                    .if eax!=INVALID_HANDLE_VALUE
                        jmp @B
                    .endif
                .endif
            .elseif ax==IDM_FIND
                .if hSearch==0
                    invoke CreateDialogParam,hInstance,IDD_FINDDLG,hWnd,addr SearchProc,0
                .endif
            .elseif ax==IDM_REPLACE
                .if hSearch==0
                    invoke CreateDialogParam,hInstance,IDD_REPLACEDLG,hWnd,addr ReplaceProc,0
                .endif
            .elseif ax==IDM_GOTOLINE
                .if hSearch==0
                    invoke CreateDialogParam,hInstance,IDD_GOTODLG,hWnd,addr GoToProc,0
                .endif
            .elseif ax==IDM_FINDNEXT
                invoke lstrlen,addr FindBuffer
                .if eax!=0
                    invoke SendMessage,hwndRichEdit,EM_EXGETSEL,0,addr findtext.chrg
                    mov eax,findtext.chrg.cpMin
                    .if eax!=findtext.chrg.cpMax
                        push findtext.chrg.cpMax
                        pop findtext.chrg.cpMin
                    .endif
                    mov findtext.chrg.cpMax,-1
                    mov findtext.lpstrText,offset FindBuffer
                    invoke SendMessage,hwndRichEdit,EM_FINDTEXTEX,FR_DOWN,addr findtext
                    .if eax!=-1
                        invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr findtext.chrgText
                    .endif
                .endif
            .elseif ax==IDM_FINDPREV
                invoke lstrlen,addr FindBuffer
                .if eax!=0
                    invoke SendMessage,hwndRichEdit,EM_EXGETSEL,0,addr findtext.chrg
                    mov findtext.chrg.cpMax,0
                    mov findtext.lpstrText,offset FindBuffer
                    invoke SendMessage,hwndRichEdit,EM_FINDTEXTEX,0,addr findtext
                    .if eax!=-1
                        invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr findtext.chrgText
                    .endif
                .endif
            .elseif ax==IDM_EXIT
                invoke SendMessage,hWnd,WM_CLOSE,0,0
            .endif
        .endif
    .elseif uMsg==WM_CLOSE
        invoke CheckModifyState,hWnd
        .if eax==TRUE
            invoke DestroyWindow,hWnd
        .endif
    .elseif uMsg==WM_SIZE
        mov eax,lParam
        mov edx,eax
        and eax,0FFFFh
        shr edx,16
        invoke MoveWindow,hwndRichEdit,0,0,eax,edx,TRUE
    .elseif uMsg==WM_DESTROY
        invoke PostQuitMessage,NULL
    .else
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
    .endif
    xor eax,eax
    ret
WndProc endp
end start
Analysis
The search-for-text capability is implemented with EM_FINDTEXTEX. When the user clicks on Find menuitem, 
IDM_FIND message is sent and the Find dialog box is displayed.




  invoke GetDlgItemText,hWnd,IDC_FINDEDIT,addr FindBuffer,sizeof FindBuffer
    .if eax!=0
When the user types the text to search for and then press OK button, we get the text to be searched for into
 FindBuffer. 

        mov uFlags,0
        invoke SendMessage,hwndRichEdit,EM_EXGETSEL,0,addr findtext.chrg
If the text string is not null, we continue to initialize uFlags variable to 0.This variable is used to 
store the search flags used with EM_FINDTEXTEX. After that, we obtain the current selection with EM_EXGETSEL
 because we need to know the starting point of the search operation.


   invoke IsDlgButtonChecked,hWnd,IDC_DOWN
        .if eax==BST_CHECKED
            or uFlags,FR_DOWN
            mov eax,findtext.chrg.cpMin
            .if eax!=findtext.chrg.cpMax
                push findtext.chrg.cpMax
                pop findtext.chrg.cpMin
            .endif
            mov findtext.chrg.cpMax,-1
        .else
            mov findtext.chrg.cpMax,0
        .endif
The next part is a little tricky. We check the direction radio button to ascertain which direction the 
search should go. If the downward search is indicated, we set FR_DOWN flag to uFlags. After that, we check 
whether a selection is currently in effect by comparing the values of cpMin and cpMax. If both values are 
not equal, it means there is a current selection and we must continue the search from the end of that 
selection to the end of text in the control. Thus we need to replace the value of cpMax with that of cpMin 
and change the value of cpMax to -1 (0FFFFFFFFh). If there is no current selection, the range to search is
 from the current caret position to the end of text.

If the user chooses to search upward, we use the range from the start of the selection to the beginning of 
the text in the control. That's why we only modify the value of cpMax to 0. In the case of upward search, 
cpMin contains the character index of the last character in the search range and cpMax the character index
 of the first char in the search range. It's the inverse of the downward search.


        invoke IsDlgButtonChecked,hWnd,IDC_MATCHCASE
        .if eax==BST_CHECKED
            or uFlags,FR_MATCHCASE
        .endif
        invoke IsDlgButtonChecked,hWnd,IDC_WHOLEWORD
        .if eax==BST_CHECKED
            or uFlags,FR_WHOLEWORD
        .endif
        mov findtext.lpstrText,offset FindBuffer
We continue to check the checkboxes for the search flags, ie, FR_MATCHCASE and FR_WHOLEWORD. Lastly, 
we put the offset of the text to search for in lpstrText member.


        invoke SendMessage,hwndRichEdit,EM_FINDTEXTEX,uFlags,addr findtext
        .if eax!=-1
            invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr findtext.chrgText
        .endif
    .endif
We are now ready to issue EM_FINDTEXTEX. After that, we examine the search result returned by SendMessage. 
If the return value is -1, no match is found in the search range. Otherwise, chrgText member of FINDTEXTEX 
structure is filled with the character indices of the matching text. We thus proceed to select it with 
EM_EXSETSEL.

The replace operation is done in much the same manner.

    invoke GetDlgItemText,hWnd,IDC_FINDEDIT,addr FindBuffer,sizeof FindBuffer
    invoke GetDlgItemText,hWnd,IDC_REPLACEEDIT,addr ReplaceBuffer,sizeof ReplaceBuffer
We retrieve the text to search for and the text used to replace.


    mov findtext.chrg.cpMin,0
    mov findtext.chrg.cpMax,-1
    mov findtext.lpstrText,offset FindBuffer
To make it easy, the replace operation affects all the text in the control. Thus the starting index is 0 
and the ending index is -1.


    mov settext.flags,ST_SELECTION
    mov settext.codepage,CP_ACP
We initialize SETTEXTEX structure to indicate that we want to replace the current selection and use the
 default system code page.


    .while TRUE
        invoke SendMessage,hwndRichEdit,EM_FINDTEXTEX,FR_DOWN,addr findtext
        .if eax==-1
            .break
        .else
            invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr findtext.chrgText
            invoke SendMessage,hwndRichEdit,EM_SETTEXTEX,addr settext,addr ReplaceBuffer
        .endif
    .endw
We enter an infinite loop, searching for the matching text. If one is found, we select it with EM_EXSETSEL 
and replace it with EM_SETTEXTEX. When no more match is found, we exit the loop.

Find Next and Find Prev. features use EM_FINDTEXTEX message in the similar manner to the find operation.

We will examine the Go to Line feature next. When the user clicks Go To Line menuitem, we display a dialog
 box below:



When the user types a line number and presses Ok button, we begin the operation.

   invoke GetDlgItemInt,hWnd,IDC_LINENO,NULL,FALSE
    mov LineNo,eax
Obtain the line number from the edit control


   invoke SendMessage,hwndRichEdit,EM_GETLINECOUNT,0,0
    .if eax>LineNo
Obtain the number of lines in the control. Check whether the user specifies the line number that is out of 
the range.


       invoke SendMessage,hwndRichEdit,EM_LINEINDEX,LineNo,0
If the line number is valid, we want to move the caret to the first character of that line. So we send 
EM_LINEINDEX message to the richedit control. This message returns the character index of the first character 
in the specified line. We send the line number in wParam and in return, we has the character index.


       invoke SendMessage,hwndRichEdit,EM_SETSEL,eax,eax
To set the current selection, this time we use EM_SETSEL because the character indices are not already in 
a CHARRANGE structure thus it saves us two instructions (to put those indices into a CHARRANGE structure). 

       invoke SetFocus,hwndRichEdit
    .endif
The caret will not be displayed unless the richedit control has the focus. So we call SetFocus on it. 
Unfortunately you can't run Java applets  


                         Tutorial 35: RichEdit Control: Syntax Hilighting
  
  
Before reading this tutorial, let me warn you that it's a complicated subject: not suited for a beginner. 
This is the last in the richedit control tutorials.

Theory
Syntax hilighting is a subject of hot debate for those writing text editors. The best method (in my opinion)
 is to code a custom edit control and this is the approach taken by lots of commercial softwares. However,
  for those of us who don't have time for coding such control, the next best thing is to adapt the existing 
  control to make it suit our need.

Let us take a look at what RichEdit control provides to help us in implementing syntax hilighting. 
I should state at this moment that the following method is not the "correct" path: I just want to show you 
the pitfall that many fall for. RichEdit control provides EM_SETCHARFORMAT message that you can use to change
 the color of the text. At first glance, this message seems to be the perfect solution (I know because I was 
 one of the victim). However, a closer examination will show you several things that are undesirable:

EM_SETCHARFORMAT only works for a text currently in selection or all text in the control. If you want 
to change the text color (hilight) a certain word, you must first select it. 
EM_SETCHARFORMAT is very slow 
It has a problem with the caret position in the richedit control 
With the above discussion, you can see that using EM_SETCHARFORMAT is a wrong choice. I'll show you the 
"relatively correct" choice.

The method I currently use is "syntax hilighting just-in-time". I'll hilight only the visible portion of 
text. Thus the speed of the hilighting will not be related to the size of the file at all. No matter how 
large the file, only a small portion of it is visible at one time.

How to do that? The answer is simple: 

subclass the richedit control and handle WM_PAINT message within your own window procedure 
When it receives WM_PAINT message, it calls the original window procedure of the richedit control to let it 
update the screen as usual. 
After that, we overwrite the words to be hilighted with different color 
Of course, the road is not that easy: there are still a couple of minor things to fix but the above method
 works quite nicely. The display speed is very satisfactory.

Now let's concentrate on the detail. The subclassing process is simple and doesn't require much attention. 
The really complicated part is when we have to find a fast way of searching for the words to be hilighted. 
This is further complicated by the need not to hilight any word within a comment block. 

The method I use may not be the best but it works ok. I'm sure you can find a faster way. Anyway, here it is:

I create a 256 dword array, initialized to 0. Each dword corresponds to a possible ASCII character,named 
ASMSyntaxArray. For example, the 21th dword represents the ascii 20h (space). I use them as a fast lookup 
table: For example, if I have the word "include", I'll extract the first character (i) from the word and 
look up the dword at the corresponding index. If that dword is 0, I know immediately that there is no words 
to be hilighted starting with "i". If the dword is non-zero, it contains the pointer to the linked list of 
the WORDINFO structure which contains the information about the word to be hilighted. 
I read the words to be hilighted and create a WORDINFO structure for each of them. 
            WORDINFO struct

                WordLen dd ?        ; the length of the word: used as a quick comparison
                pszWord dd ?    ; pointer to the word
                pColor dd ?         ; point to the dword that contains the color used to hilite the word
                NextLink dd ?       ; point to the next WORDINFO structure
            WORDINFO ends 

As you can see, I use the length of the word as the second quick comparison. If the first character of the 
word matches, we next compare its length to the available words. Each dword in ASMSyntaxArray contains a 
pointer to the head of the associated WORDINFO array. For example, the dword that represents the character 
"i" will contain the pointer to the linked list of the words that begin with "i". pColor member points to 
the dword that contains the color value used to hilight the word. pszWord points to the word to be hilighted,
 in lowercase.

The memory for the linked list is allocated from the default heap so it's fast and easy to clean up, ie, no 
cleaning up required at all. 
The word list is stored in a file named "wordfile.txt" and I access it with GetPrivateProfileString APIs. 
I provide as many as 10 different syntax coloring, starting from C1 to C10. The color array is named 
ASMColorArray. pColor member of each WORDINFO structure points to one of the dwords in ASMColorArray. 
Thus it is easy to change the syntax coloring on the fly: you just change the dword in ASMColorArray and 
all words using that color will use the new color immediately. 

Example
.386
.model flat,stdcall
option casemap:none
include \Masm32\include\windows.inc
include \Masm32\include\user32.inc
include \Masm32\include\comdlg32.inc
include \Masm32\include\gdi32.inc
include \Masm32\include\kernel32.inc
includelib \Masm32\lib\gdi32.lib
includelib \Masm32\lib\comdlg32.lib
includelib \Masm32\lib\user32.lib
includelib \Masm32\lib\kernel32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

WORDINFO struct
    WordLen dd ?        ; the length of the word: used as a quick comparison
    pszWord dd ?        ; pointer to the word
    pColor dd ?     ; point to the dword that contains the color used to hilite the word
    NextLink dd ?       ; point to the next WORDINFO structure
WORDINFO ends

.const
IDR_MAINMENU                   equ 101
IDM_OPEN                      equ  40001
IDM_SAVE                       equ 40002
IDM_CLOSE                      equ 40003
IDM_SAVEAS                     equ 40004
IDM_EXIT                       equ 40005
IDM_COPY                      equ  40006
IDM_CUT                       equ  40007
IDM_PASTE                      equ 40008
IDM_DELETE                     equ 40009
IDM_SELECTALL                  equ 40010
IDM_OPTION          equ 40011
IDM_UNDO            equ 40012
IDM_REDO            equ 40013
IDD_OPTIONDLG                  equ 101
IDC_BACKCOLORBOX               equ 1000
IDC_TEXTCOLORBOX               equ 1001
IDR_MAINACCEL                 equ  105
IDD_FINDDLG                    equ 102
IDD_GOTODLG                    equ 103
IDD_REPLACEDLG                 equ 104
IDC_FINDEDIT                  equ  1000
IDC_MATCHCASE                  equ 1001
IDC_REPLACEEDIT                 equ 1001
IDC_WHOLEWORD                  equ 1002
IDC_DOWN                       equ 1003
IDC_UP                       equ   1004
IDC_LINENO                   equ   1005
IDM_FIND                       equ 40014
IDM_FINDNEXT                  equ  40015
IDM_REPLACE                     equ 40016
IDM_GOTOLINE                   equ 40017
IDM_FINDPREV                  equ  40018
RichEditID          equ 300

.data

ClassName db "IczEditClass",0
AppName  db "IczEdit version 3.0",0
RichEditDLL db "riched20.dll",0
RichEditClass db "RichEdit20A",0
NoRichEdit db "Cannot find riched20.dll",0
ASMFilterString         db "ASM Source code (*.asm)",0,"*.asm",0
                db "All Files (*.*)",0,"*.*",0,0
OpenFileFail db "Cannot open the file",0
WannaSave db "The data in the control is modified. Want to save it?",0
FileOpened dd FALSE
BackgroundColor dd 0FFFFFFh     ; default to white
TextColor dd 0      ; default to black
WordFileName db "\wordfile.txt",0
ASMSection db "ASSEMBLY",0
C1Key db "C1",0
C2Key db "C2",0
C3Key db "C3",0
C4Key db "C4",0
C5Key db "C5",0
C6Key db "C6",0
C7Key db "C7",0
C8Key db "C8",0
C9Key db "C9",0
C10Key db "C10",0
ZeroString db 0
ASMColorArray dd 0FF0000h,0805F50h,0FFh,666F00h,44F0h,5F8754h,4 dup(0FF0000h)
CommentColor dd 808000h

.data?
hInstance dd ?
hRichEdit dd ?
hwndRichEdit dd ?
FileName db 256 dup(?)
AlternateFileName db 256 dup(?)
CustomColors dd 16 dup(?)
FindBuffer db 256 dup(?)
ReplaceBuffer db 256 dup(?)
uFlags dd ?
findtext FINDTEXTEX <>
ASMSyntaxArray dd 256 dup(?)
hSearch dd ?        ; handle to the search/replace dialog box
hAccel dd ?
hMainHeap dd ?      ; heap handle
OldWndProc dd ?
RichEditVersion dd ?

.code
start:
    mov byte ptr [FindBuffer],0
    mov byte ptr [ReplaceBuffer],0
    invoke GetModuleHandle, NULL
    mov    hInstance,eax
    invoke LoadLibrary,addr RichEditDLL
    .if eax!=0
        mov hRichEdit,eax
        invoke GetProcessHeap
        mov hMainHeap,eax
        call FillHiliteInfo
        invoke WinMain, hInstance,0,0, SW_SHOWDEFAULT
        invoke FreeLibrary,hRichEdit
    .else
        invoke MessageBox,0,addr NoRichEdit,addr AppName,MB_OK or MB_ICONERROR
    .endif
    invoke ExitProcess,eax

WinMain proc hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hwnd:DWORD
    mov   wc.cbSize,SIZEOF WNDCLASSEX
    mov   wc.style, CS_HREDRAW or CS_VREDRAW
    mov   wc.lpfnWndProc, OFFSET WndProc
    mov   wc.cbClsExtra,NULL
    mov   wc.cbWndExtra,NULL
    push  hInst
    pop   wc.hInstance
    mov   wc.hbrBackground,COLOR_WINDOW+1
    mov   wc.lpszMenuName,IDR_MAINMENU
    mov   wc.lpszClassName,OFFSET ClassName
    invoke LoadIcon,NULL,IDI_APPLICATION
    mov   wc.hIcon,eax
    mov   wc.hIconSm,eax
    invoke LoadCursor,NULL,IDC_ARROW
    mov   wc.hCursor,eax
    invoke RegisterClassEx, addr wc
    INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
           hInst,NULL
    mov   hwnd,eax
    invoke ShowWindow, hwnd,SW_SHOWNORMAL
    invoke UpdateWindow, hwnd
    invoke LoadAccelerators,hInstance,IDR_MAINACCEL
    mov hAccel,eax
    .while TRUE
        invoke GetMessage, ADDR msg,0,0,0
        .break .if (!eax)
        invoke IsDialogMessage,hSearch,addr msg
        .if eax==FALSE
            invoke TranslateAccelerator,hwnd,hAccel,addr msg
            .if eax==0
                invoke TranslateMessage, ADDR msg
                invoke DispatchMessage, ADDR msg
            .endif
        .endif
    .endw
    mov   eax,msg.wParam
    ret
WinMain endp

StreamInProc proc hFile:DWORD,pBuffer:DWORD, NumBytes:DWORD, pBytesRead:DWORD
    invoke ReadFile,hFile,pBuffer,NumBytes,pBytesRead,0
    xor eax,1
    ret
StreamInProc endp

StreamOutProc proc hFile:DWORD,pBuffer:DWORD, NumBytes:DWORD, pBytesWritten:DWORD
    invoke WriteFile,hFile,pBuffer,NumBytes,pBytesWritten,0
    xor eax,1
    ret
StreamOutProc endp

CheckModifyState proc hWnd:DWORD
    invoke SendMessage,hwndRichEdit,EM_GETMODIFY,0,0
    .if eax!=0
        invoke MessageBox,hWnd,addr WannaSave,addr AppName,MB_YESNOCANCEL
        .if eax==IDYES
            invoke SendMessage,hWnd,WM_COMMAND,IDM_SAVE,0
        .elseif eax==IDCANCEL
            mov eax,FALSE
            ret
        .endif
    .endif
    mov eax,TRUE
    ret
CheckModifyState endp

SetColor proc
    LOCAL cfm:CHARFORMAT
    invoke SendMessage,hwndRichEdit,EM_SETBKGNDCOLOR,0,BackgroundColor
    invoke RtlZeroMemory,addr cfm,sizeof cfm
    mov cfm.cbSize,sizeof cfm
    mov cfm.dwMask,CFM_COLOR
    push TextColor
    pop cfm.crTextColor
    invoke SendMessage,hwndRichEdit,EM_SETCHARFORMAT,SCF_ALL,addr cfm
    ret
SetColor endp

OptionProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    LOCAL clr:CHOOSECOLOR
    .if uMsg==WM_INITDIALOG
    .elseif uMsg==WM_COMMAND
        mov eax,wParam
        shr eax,16
        .if ax==BN_CLICKED
            mov eax,wParam
            .if ax==IDCANCEL
                invoke SendMessage,hWnd,WM_CLOSE,0,0
            .elseif ax==IDC_BACKCOLORBOX
                invoke RtlZeroMemory,addr clr,sizeof clr
                mov clr.lStructSize,sizeof clr
                push hWnd
                pop clr.hwndOwner
                push hInstance
                pop clr.hInstance
                push BackgroundColor
                pop clr.rgbResult
                mov clr.lpCustColors,offset CustomColors
                mov clr.Flags,CC_ANYCOLOR or CC_RGBINIT
                invoke ChooseColor,addr clr
                .if eax!=0
                    push clr.rgbResult
                    pop BackgroundColor
                    invoke GetDlgItem,hWnd,IDC_BACKCOLORBOX
                    invoke InvalidateRect,eax,0,TRUE
                .endif
            .elseif ax==IDC_TEXTCOLORBOX
                invoke RtlZeroMemory,addr clr,sizeof clr
                mov clr.lStructSize,sizeof clr
                push hWnd
                pop clr.hwndOwner
                push hInstance
                pop clr.hInstance
                push TextColor
                pop clr.rgbResult
                mov clr.lpCustColors,offset CustomColors
                mov clr.Flags,CC_ANYCOLOR or CC_RGBINIT
                invoke ChooseColor,addr clr
                .if eax!=0
                    push clr.rgbResult
                    pop TextColor
                    invoke GetDlgItem,hWnd,IDC_TEXTCOLORBOX
                    invoke InvalidateRect,eax,0,TRUE
                .endif
            .elseif ax==IDOK
                invoke SendMessage,hwndRichEdit,EM_GETMODIFY,0,0
                push eax
                invoke SetColor
                pop eax
                invoke SendMessage,hwndRichEdit,EM_SETMODIFY,eax,0
                invoke EndDialog,hWnd,0
            .endif
        .endif
    .elseif uMsg==WM_CTLCOLORSTATIC
        invoke GetDlgItem,hWnd,IDC_BACKCOLORBOX
        .if eax==lParam
            invoke CreateSolidBrush,BackgroundColor
            ret
        .else
            invoke GetDlgItem,hWnd,IDC_TEXTCOLORBOX
            .if eax==lParam
                invoke CreateSolidBrush,TextColor
                ret
            .endif
        .endif
        mov eax,FALSE
        ret
    .elseif uMsg==WM_CLOSE
        invoke EndDialog,hWnd,0
    .else
        mov eax,FALSE
        ret
    .endif
    mov eax,TRUE
    ret
OptionProc endp

SearchProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    .if uMsg==WM_INITDIALOG
        push hWnd
        pop hSearch
        invoke CheckRadioButton,hWnd,IDC_DOWN,IDC_UP,IDC_DOWN
        invoke SendDlgItemMessage,hWnd,IDC_FINDEDIT,WM_SETTEXT,0,addr FindBuffer
    .elseif uMsg==WM_COMMAND
        mov eax,wParam
        shr eax,16
        .if ax==BN_CLICKED
            mov eax,wParam
            .if ax==IDOK
                mov uFlags,0
                invoke SendMessage,hwndRichEdit,EM_EXGETSEL,0,addr findtext.chrg
                invoke GetDlgItemText,hWnd,IDC_FINDEDIT,addr FindBuffer,sizeof FindBuffer
                .if eax!=0
                    invoke IsDlgButtonChecked,hWnd,IDC_DOWN
                    .if eax==BST_CHECKED
                        or uFlags,FR_DOWN
                        mov eax,findtext.chrg.cpMin
                        .if eax!=findtext.chrg.cpMax
                            push findtext.chrg.cpMax
                            pop findtext.chrg.cpMin
                        .endif
                        mov findtext.chrg.cpMax,-1
                    .else
                        mov findtext.chrg.cpMax,0
                    .endif
                    invoke IsDlgButtonChecked,hWnd,IDC_MATCHCASE
                    .if eax==BST_CHECKED
                        or uFlags,FR_MATCHCASE
                    .endif
                    invoke IsDlgButtonChecked,hWnd,IDC_WHOLEWORD
                    .if eax==BST_CHECKED
                        or uFlags,FR_WHOLEWORD
                    .endif
                    mov findtext.lpstrText,offset FindBuffer
                    invoke SendMessage,hwndRichEdit,EM_FINDTEXTEX,uFlags,addr findtext
                    .if eax!=-1
                        invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr findtext.chrgText
                    .endif
                .endif
            .elseif ax==IDCANCEL
                invoke SendMessage,hWnd,WM_CLOSE,0,0
            .else
                mov eax,FALSE
                ret
            .endif
        .endif
    .elseif uMsg==WM_CLOSE
        mov hSearch,0
        invoke EndDialog,hWnd,0
    .else
        mov eax,FALSE
        ret
    .endif
    mov eax,TRUE
    ret
SearchProc endp

ReplaceProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    LOCAL settext:SETTEXTEX
    .if uMsg==WM_INITDIALOG
        push hWnd
        pop hSearch
        invoke SetDlgItemText,hWnd,IDC_FINDEDIT,addr FindBuffer
        invoke SetDlgItemText,hWnd,IDC_REPLACEEDIT,addr ReplaceBuffer
    .elseif uMsg==WM_COMMAND
        mov eax,wParam
        shr eax,16
        .if ax==BN_CLICKED
            mov eax,wParam
            .if ax==IDCANCEL
                invoke SendMessage,hWnd,WM_CLOSE,0,0
            .elseif ax==IDOK
                invoke GetDlgItemText,hWnd,IDC_FINDEDIT,addr FindBuffer,sizeof FindBuffer
                invoke GetDlgItemText,hWnd,IDC_REPLACEEDIT,addr ReplaceBuffer,sizeof ReplaceBuffer
                mov findtext.chrg.cpMin,0
                mov findtext.chrg.cpMax,-1
                mov findtext.lpstrText,offset FindBuffer
                mov settext.flags,ST_SELECTION
                mov settext.codepage,CP_ACP
                .while TRUE
                    invoke SendMessage,hwndRichEdit,EM_FINDTEXTEX,FR_DOWN,addr findtext
                    .if eax==-1
                        .break
                    .else
                        invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr findtext.chrgText
                        invoke SendMessage,hwndRichEdit,EM_SETTEXTEX,addr settext,addr ReplaceBuffer
                    .endif
                .endw
            .endif
        .endif
    .elseif uMsg==WM_CLOSE
        mov hSearch,0
        invoke EndDialog,hWnd,0
    .else
        mov eax,FALSE
        ret
    .endif
    mov eax,TRUE
    ret
ReplaceProc endp

GoToProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    LOCAL LineNo:DWORD
    LOCAL chrg:CHARRANGE
    .if uMsg==WM_INITDIALOG
        push hWnd
        pop hSearch
    .elseif uMsg==WM_COMMAND
        mov eax,wParam
        shr eax,16
        .if ax==BN_CLICKED
            mov eax,wParam
            .if ax==IDCANCEL
                invoke SendMessage,hWnd,WM_CLOSE,0,0
            .elseif ax==IDOK
                invoke GetDlgItemInt,hWnd,IDC_LINENO,NULL,FALSE
                mov LineNo,eax
                invoke SendMessage,hwndRichEdit,EM_GETLINECOUNT,0,0
                .if eax>LineNo
                    invoke SendMessage,hwndRichEdit,EM_LINEINDEX,LineNo,0
                    invoke SendMessage,hwndRichEdit,EM_SETSEL,eax,eax
                    invoke SetFocus,hwndRichEdit
                .endif
            .endif
        .endif
    .elseif uMsg==WM_CLOSE
        mov hSearch,0
        invoke EndDialog,hWnd,0
    .else
        mov eax,FALSE
        ret
    .endif
    mov eax,TRUE
    ret
GoToProc endp

PrepareEditMenu proc hSubMenu:DWORD
    LOCAL chrg:CHARRANGE
    invoke SendMessage,hwndRichEdit,EM_CANPASTE,CF_TEXT,0
    .if eax==0      ; no text in the clipboard
        invoke EnableMenuItem,hSubMenu,IDM_PASTE,MF_GRAYED
    .else
        invoke EnableMenuItem,hSubMenu,IDM_PASTE,MF_ENABLED
    .endif
    invoke SendMessage,hwndRichEdit,EM_CANUNDO,0,0
    .if eax==0
        invoke EnableMenuItem,hSubMenu,IDM_UNDO,MF_GRAYED
    .else
        invoke EnableMenuItem,hSubMenu,IDM_UNDO,MF_ENABLED
    .endif
    invoke SendMessage,hwndRichEdit,EM_CANREDO,0,0
    .if eax==0
        invoke EnableMenuItem,hSubMenu,IDM_REDO,MF_GRAYED
    .else
        invoke EnableMenuItem,hSubMenu,IDM_REDO,MF_ENABLED
    .endif
    invoke SendMessage,hwndRichEdit,EM_EXGETSEL,0,addr chrg
    mov eax,chrg.cpMin
    .if eax==chrg.cpMax     ; no current selection
        invoke EnableMenuItem,hSubMenu,IDM_COPY,MF_GRAYED
        invoke EnableMenuItem,hSubMenu,IDM_CUT,MF_GRAYED
        invoke EnableMenuItem,hSubMenu,IDM_DELETE,MF_GRAYED
    .else
        invoke EnableMenuItem,hSubMenu,IDM_COPY,MF_ENABLED
        invoke EnableMenuItem,hSubMenu,IDM_CUT,MF_ENABLED
        invoke EnableMenuItem,hSubMenu,IDM_DELETE,MF_ENABLED
    .endif
    ret
PrepareEditMenu endp

ParseBuffer proc uses edi esi hHeap:DWORD,pBuffer:DWORD, nSize:DWORD, ArrayOffset:DWORD,pArray:DWORD
    LOCAL buffer[128]:BYTE
    LOCAL InProgress:DWORD
    mov InProgress,FALSE
    lea esi,buffer
    mov edi,pBuffer
    invoke CharLower,edi
    mov ecx,nSize
SearchLoop:
    or ecx,ecx
    jz Finished
    cmp byte ptr [edi]," "
    je EndOfWord
    cmp byte ptr [edi],9    ; tab
    je EndOfWord
    mov InProgress,TRUE
    mov al,byte ptr [edi]
    mov byte ptr [esi],al
    inc esi
SkipIt:
    inc edi
    dec ecx
    jmp SearchLoop
EndOfWord:
    cmp InProgress,TRUE
    je WordFound
    jmp SkipIt
WordFound:
    mov byte ptr [esi],0
    push ecx
    invoke HeapAlloc,hHeap,HEAP_ZERO_MEMORY,sizeof WORDINFO
    push esi
    mov esi,eax
    assume esi:ptr WORDINFO
    invoke lstrlen,addr buffer
    mov [esi].WordLen,eax
    push ArrayOffset
    pop [esi].pColor
    inc eax
    invoke HeapAlloc,hHeap,HEAP_ZERO_MEMORY,eax
    mov [esi].pszWord,eax
    mov edx,eax
    invoke lstrcpy,edx,addr buffer
    mov eax,pArray
    movzx edx,byte ptr [buffer]
    shl edx,2       ; multiply by 4
    add eax,edx
    .if dword ptr [eax]==0
        mov dword ptr [eax],esi
    .else
        push dword ptr [eax]
        pop [esi].NextLink
        mov dword ptr [eax],esi
    .endif
    pop esi
    pop ecx
    lea esi,buffer
    mov InProgress,FALSE
    jmp SkipIt
Finished:
    .if InProgress==TRUE
        invoke HeapAlloc,hHeap,HEAP_ZERO_MEMORY,sizeof WORDINFO
        push esi
        mov esi,eax
        assume esi:ptr WORDINFO
        invoke lstrlen,addr buffer
        mov [esi].WordLen,eax
        push ArrayOffset
        pop [esi].pColor
        inc eax
        invoke HeapAlloc,hHeap,HEAP_ZERO_MEMORY,eax
        mov [esi].pszWord,eax
        mov edx,eax
        invoke lstrcpy,edx,addr buffer
        mov eax,pArray
        movzx edx,byte ptr [buffer]
        shl edx,2       ; multiply by 4
        add eax,edx
        .if dword ptr [eax]==0
            mov dword ptr [eax],esi
        .else
            push dword ptr [eax]
            pop [esi].NextLink
            mov dword ptr [eax],esi
        .endif
        pop esi
    .endif
    ret
ParseBuffer endp

FillHiliteInfo proc uses edi
    LOCAL buffer[1024]:BYTE
    LOCAL pTemp:DWORD
    LOCAL BlockSize:DWORD
    invoke RtlZeroMemory,addr ASMSyntaxArray,sizeof ASMSyntaxArray
    invoke GetModuleFileName,hInstance,addr buffer,sizeof buffer
    invoke lstrlen,addr buffer
    mov ecx,eax
    dec ecx
    lea edi,buffer
    add edi,ecx
    std
    mov al,"\"
    repne scasb
    cld
    inc edi
    mov byte ptr [edi],0
    invoke lstrcat,addr buffer,addr WordFileName
    invoke GetFileAttributes,addr buffer
    .if eax!=-1
        mov BlockSize,1024*10
        invoke HeapAlloc,hMainHeap,0,BlockSize
        mov pTemp,eax
@@:
        invoke GetPrivateProfileString,addr ASMSection,addr C1Key,addr ZeroString,pTemp,BlockSize,addr buffer
        .if eax!=0
            inc eax
            .if eax==BlockSize  ; the buffer is too small
                add BlockSize,1024*10
                invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
                mov pTemp,eax
                jmp @B
            .endif
            mov edx,offset ASMColorArray
            invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
        .endif
@@:
        invoke GetPrivateProfileString,addr ASMSection,addr C2Key,addr ZeroString,pTemp,BlockSize,addr buffer
        .if eax!=0
            inc eax
            .if eax==BlockSize  ; the buffer is too small
                add BlockSize,1024*10
                invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
                mov pTemp,eax
                jmp @B
            .endif
            mov edx,offset ASMColorArray
            add edx,4
            invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
        .endif
@@:
        invoke GetPrivateProfileString,addr ASMSection,addr C3Key,addr ZeroString,pTemp,BlockSize,addr buffer
        .if eax!=0
            inc eax
            .if eax==BlockSize  ; the buffer is too small
                add BlockSize,1024*10
                invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
                mov pTemp,eax
                jmp @B
            .endif
            mov edx,offset ASMColorArray
            add edx,8
            invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
        .endif
@@:
        invoke GetPrivateProfileString,addr ASMSection,addr C4Key,addr ZeroString,pTemp,BlockSize,addr buffer
        .if eax!=0
            inc eax
            .if eax==BlockSize  ; the buffer is too small
                add BlockSize,1024*10
                invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
                mov pTemp,eax
                jmp @B
            .endif
            mov edx,offset ASMColorArray
            add edx,12
            invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
        .endif
@@:
        invoke GetPrivateProfileString,addr ASMSection,addr C5Key,addr ZeroString,pTemp,BlockSize,addr buffer
        .if eax!=0
            inc eax
            .if eax==BlockSize  ; the buffer is too small
                add BlockSize,1024*10
                invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
                mov pTemp,eax
                jmp @B
            .endif
            mov edx,offset ASMColorArray
            add edx,16
            invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
        .endif
@@:
        invoke GetPrivateProfileString,addr ASMSection,addr C6Key,addr ZeroString,pTemp,BlockSize,addr buffer
        .if eax!=0
            inc eax
            .if eax==BlockSize  ; the buffer is too small
                add BlockSize,1024*10
                invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
                mov pTemp,eax
                jmp @B
            .endif
            mov edx,offset ASMColorArray
            add edx,20
            invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
        .endif
@@:
        invoke GetPrivateProfileString,addr ASMSection,addr C7Key,addr ZeroString,pTemp,BlockSize,addr buffer
        .if eax!=0
            inc eax
            .if eax==BlockSize  ; the buffer is too small
                add BlockSize,1024*10
                invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
                mov pTemp,eax
                jmp @B
            .endif
            mov edx,offset ASMColorArray
            add edx,24
            invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
        .endif
@@:
        invoke GetPrivateProfileString,addr ASMSection,addr C8Key,addr ZeroString,pTemp,BlockSize,addr buffer
        .if eax!=0
            inc eax
            .if eax==BlockSize  ; the buffer is too small
                add BlockSize,1024*10
                invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
                mov pTemp,eax
                jmp @B
            .endif
            mov edx,offset ASMColorArray
            add edx,28
            invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
        .endif
@@:
        invoke GetPrivateProfileString,addr ASMSection,addr C9Key,addr ZeroString,pTemp,BlockSize,addr buffer
        .if eax!=0
            inc eax
            .if eax==BlockSize  ; the buffer is too small
                add BlockSize,1024*10
                invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
                mov pTemp,eax
                jmp @B
            .endif
            mov edx,offset ASMColorArray
            add edx,32
            invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
        .endif
@@:
        invoke GetPrivateProfileString,addr ASMSection,addr C10Key,addr ZeroString,pTemp,BlockSize,addr buffer
        .if eax!=0
            inc eax
            .if eax==BlockSize  ; the buffer is too small
                add BlockSize,1024*10
                invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
                mov pTemp,eax
                jmp @B
            .endif
            mov edx,offset ASMColorArray
            add edx,36
            invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
        .endif
        invoke HeapFree,hMainHeap,0,pTemp
    .endif
    ret
FillHiliteInfo endp

NewRichEditProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    LOCAL hdc:DWORD
    LOCAL hOldFont:DWORD
    LOCAL FirstChar:DWORD
    LOCAL rect:RECT
    LOCAL txtrange:TEXTRANGE
    LOCAL buffer[1024*10]:BYTE
    LOCAL hRgn:DWORD
    LOCAL hOldRgn:DWORD
    LOCAL RealRect:RECT
    LOCAL pString:DWORD
    LOCAL BufferSize:DWORD
    LOCAL pt:POINT
    .if uMsg==WM_PAINT
        push edi
        push esi
        invoke HideCaret,hWnd
        invoke CallWindowProc,OldWndProc,hWnd,uMsg,wParam,lParam
        push eax
        mov edi,offset ASMSyntaxArray
        invoke GetDC,hWnd
        mov hdc,eax
        invoke SetBkMode,hdc,TRANSPARENT
        invoke SendMessage,hWnd,EM_GETRECT,0,addr rect
        invoke SendMessage,hWnd,EM_CHARFROMPOS,0,addr rect
        invoke SendMessage,hWnd,EM_LINEFROMCHAR,eax,0
        invoke SendMessage,hWnd,EM_LINEINDEX,eax,0
        mov txtrange.chrg.cpMin,eax
        mov FirstChar,eax
        invoke SendMessage,hWnd,EM_CHARFROMPOS,0,addr rect.right
        mov txtrange.chrg.cpMax,eax
        push rect.left
        pop RealRect.left
        push rect.top
        pop RealRect.top
        push rect.right
        pop RealRect.right
        push rect.bottom
        pop RealRect.bottom
        invoke CreateRectRgn,RealRect.left,RealRect.top,RealRect.right,RealRect.bottom
        mov hRgn,eax
        invoke SelectObject,hdc,hRgn
        mov hOldRgn,eax
        invoke SetTextColor,hdc,CommentColor
        lea eax,buffer
        mov txtrange.lpstrText,eax
        invoke SendMessage,hWnd,EM_GETTEXTRANGE,0,addr txtrange
        .if eax>0
            mov esi,eax     ; esi == size of the text
            mov BufferSize,eax
            push edi
            push ebx
            lea edi,buffer
            mov edx,edi     ; used as the reference point
            mov ecx,esi
            mov al,";"
ScanMore:
            repne scasb
            je NextSkip
            jmp NoMoreHit
NextSkip:
            dec edi
            inc ecx
            mov pString,edi
            mov ebx,edi
            sub ebx,edx
            add ebx,FirstChar
            mov txtrange.chrg.cpMin,ebx
            push eax
            mov al,0Dh
            repne scasb
            pop eax
HiliteTheComment:
            .if ecx>0
                mov byte ptr [edi-1],0
            .endif
            mov ebx,edi
            sub ebx,edx
            add ebx,FirstChar
            mov txtrange.chrg.cpMax,ebx
            pushad
            mov edi,pString

            mov esi,txtrange.chrg.cpMax
            sub esi,txtrange.chrg.cpMin     ; esi contains the length of the buffer
            mov eax,esi
            push edi
            .while eax>0
                .if byte ptr [edi]==9
                    mov byte ptr [edi],0
                .endif
                inc edi
                dec eax
            .endw
            pop edi
            .while esi>0
                .if byte ptr [edi]!=0
                    invoke lstrlen,edi
                    push eax
                    mov ecx,edi
                    lea edx,buffer
                    sub ecx,edx
                    add ecx,FirstChar
                    .if RichEditVersion==3
                        invoke SendMessage,hWnd,EM_POSFROMCHAR,addr rect,ecx
                    .else
                        invoke SendMessage,hWnd,EM_POSFROMCHAR,ecx,0
                        mov ecx,eax
                        and ecx,0FFFFh
                        mov rect.left,ecx
                        shr eax,16
                        mov rect.top,eax
                    .endif
                    invoke DrawText,hdc,edi,-1,addr rect,0
                    pop eax
                    add edi,eax
                    sub esi,eax
                .else
                    inc edi
                    dec esi
                .endif
            .endw
            mov ecx,txtrange.chrg.cpMax
            sub ecx,txtrange.chrg.cpMin
            invoke RtlZeroMemory,pString,ecx
            popad
            .if ecx>0
                jmp ScanMore
            .endif
NoMoreHit:
            pop ebx
            pop edi
            mov ecx,BufferSize
            lea esi,buffer
            .while ecx>0
                mov al,byte ptr [esi]
                .if al==" " || al==0Dh || al=="/" || al=="," || al=="|" || al=="+" || al=="-" || al=="*" 
                || al=="&" || al=="<" || al==">" || al=="=" || al=="(" || al==")" || al=="{" || al=="}" 
                || al=="[" || al=="]" || al=="^" || al==":" || al==9
                    mov byte ptr [esi],0
                .endif
                dec ecx
                inc esi
            .endw
            lea esi,buffer
            mov ecx,BufferSize
            .while ecx>0
                mov al,byte ptr [esi]
                .if al!=0
                    push ecx
                    invoke lstrlen,esi
                    push eax
                    mov edx,eax     ; edx contains the length of the string
                    movzx eax,byte ptr [esi]
                    .if al>="A" && al<="Z"
                        sub al,"A"
                        add al,"a"
                    .endif
                    shl eax,2
                    add eax,edi     ; edi contains the pointer to the WORDINFO pointer array
                    .if dword ptr [eax]!=0
                        mov eax,dword ptr [eax]
                        assume eax:ptr WORDINFO
                        .while eax!=0
                            .if edx==[eax].WordLen
                                pushad
                                invoke lstrcmpi,[eax].pszWord,esi
                                .if eax==0
                                    popad
                                    mov ecx,esi
                                    lea edx,buffer
                                    sub ecx,edx
                                    add ecx,FirstChar
                                    pushad
                                    .if RichEditVersion==3
                                        invoke SendMessage,hWnd,EM_POSFROMCHAR,addr rect,ecx
                                    .else
                                        invoke SendMessage,hWnd,EM_POSFROMCHAR,ecx,0
                                        mov ecx,eax
                                        and ecx,0FFFFh
                                        mov rect.left,ecx
                                        shr eax,16
                                        mov rect.top,eax
                                    .endif
                                    popad
                                    mov edx,[eax].pColor
                                    invoke SetTextColor,hdc,dword ptr [edx]
                                    invoke DrawText,hdc,esi,-1,addr rect,0
                                    .break
                                .endif
                                popad
                            .endif
                            push [eax].NextLink
                            pop eax
                        .endw
                    .endif
                    pop eax
                    pop ecx
                    add esi,eax
                    sub ecx,eax
                .else
                    inc esi
                    dec ecx
                .endif
            .endw
        .endif
        invoke SelectObject,hdc,hOldRgn
        invoke DeleteObject,hRgn
        invoke SelectObject,hdc,hOldFont
        invoke ReleaseDC,hWnd,hdc
        invoke ShowCaret,hWnd
        pop eax
        pop esi
        pop edi
        ret
    .elseif uMsg==WM_CLOSE
        invoke SetWindowLong,hWnd,GWL_WNDPROC,OldWndProc
    .else
        invoke CallWindowProc,OldWndProc,hWnd,uMsg,wParam,lParam
        ret
    .endif
NewRichEditProc endp

WndProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
    LOCAL ofn:OPENFILENAME
    LOCAL buffer[256]:BYTE
    LOCAL editstream:EDITSTREAM
    LOCAL hFile:DWORD
    LOCAL hPopup:DWORD
    LOCAL pt:POINT
    LOCAL chrg:CHARRANGE
    .if uMsg==WM_CREATE
        invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr RichEditClass,0,WS_CHILD or WS_VISIBLE or ES_MULTILINE or WS_VSCROLL or WS_HSCROLL or ES_NOHIDESEL,\
                CW_USEDEFAULT,CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,hWnd,RichEditID,hInstance,0
        mov hwndRichEdit,eax
        invoke SendMessage,hwndRichEdit,EM_SETTYPOGRAPHYOPTIONS,TO_SIMPLELINEBREAK,TO_SIMPLELINEBREAK
        invoke SendMessage,hwndRichEdit,EM_GETTYPOGRAPHYOPTIONS,1,1
        .if eax==0      ; means this message is not processed
            mov RichEditVersion,2
        .else
            mov RichEditVersion,3
            invoke SendMessage,hwndRichEdit,EM_SETEDITSTYLE,SES_EMULATESYSEDIT,SES_EMULATESYSEDIT
        .endif
        invoke SetWindowLong,hwndRichEdit,GWL_WNDPROC, addr NewRichEditProc
        mov OldWndProc,eax
        invoke SendMessage,hwndRichEdit,EM_LIMITTEXT,-1,0
        invoke SetColor
        invoke SendMessage,hwndRichEdit,EM_SETMODIFY,FALSE,0
        invoke SendMessage,hwndRichEdit,EM_SETEVENTMASK,0,ENM_MOUSEEVENTS
        invoke SendMessage,hwndRichEdit,EM_EMPTYUNDOBUFFER,0,0
    .elseif uMsg==WM_NOTIFY
        push esi
        mov esi,lParam
        assume esi:ptr NMHDR
        .if [esi].code==EN_MSGFILTER
            assume esi:ptr MSGFILTER
            .if [esi].msg==WM_RBUTTONDOWN
                invoke GetMenu,hWnd
                invoke GetSubMenu,eax,1
                mov hPopup,eax
                invoke PrepareEditMenu,hPopup
                mov edx,[esi].lParam
                mov ecx,edx
                and edx,0FFFFh
                shr ecx,16
                mov pt.x,edx
                mov pt.y,ecx
                invoke ClientToScreen,hWnd,addr pt
                invoke TrackPopupMenu,hPopup,TPM_LEFTALIGN or TPM_BOTTOMALIGN,pt.x,pt.y,NULL,hWnd,NULL
            .endif
        .endif
        pop esi
    .elseif uMsg==WM_INITMENUPOPUP
        mov eax,lParam
        .if ax==0       ; file menu
            .if FileOpened==TRUE    ; a file is already opened
                invoke EnableMenuItem,wParam,IDM_OPEN,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_CLOSE,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_SAVE,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_SAVEAS,MF_ENABLED
            .else
                invoke EnableMenuItem,wParam,IDM_OPEN,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_CLOSE,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_SAVE,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_SAVEAS,MF_GRAYED
            .endif
        .elseif ax==1   ; edit menu
            invoke PrepareEditMenu,wParam
        .elseif ax==2       ; search menu bar
            .if FileOpened==TRUE
                invoke EnableMenuItem,wParam,IDM_FIND,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_FINDNEXT,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_FINDPREV,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_REPLACE,MF_ENABLED
                invoke EnableMenuItem,wParam,IDM_GOTOLINE,MF_ENABLED
            .else
                invoke EnableMenuItem,wParam,IDM_FIND,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_FINDNEXT,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_FINDPREV,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_REPLACE,MF_GRAYED
                invoke EnableMenuItem,wParam,IDM_GOTOLINE,MF_GRAYED
            .endif
        .endif
    .elseif uMsg==WM_COMMAND
        .if lParam==0       ; menu commands
            mov eax,wParam
            .if ax==IDM_OPEN
                invoke RtlZeroMemory,addr ofn,sizeof ofn
                mov ofn.lStructSize,sizeof ofn
                push hWnd
                pop ofn.hwndOwner
                push hInstance
                pop ofn.hInstance
                mov ofn.lpstrFilter,offset ASMFilterString
                mov ofn.lpstrFile,offset FileName
                mov byte ptr [FileName],0
                mov ofn.nMaxFile,sizeof FileName
                mov ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
                invoke GetOpenFileName,addr ofn
                .if eax!=0
                    invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
                    .if eax!=INVALID_HANDLE_VALUE
                        mov hFile,eax
                        mov editstream.dwCookie,eax
                        mov editstream.pfnCallback,offset StreamInProc
                        invoke SendMessage,hwndRichEdit,EM_STREAMIN,SF_TEXT,addr editstream
                        invoke SendMessage,hwndRichEdit,EM_SETMODIFY,FALSE,0
                        invoke CloseHandle,hFile
                        mov FileOpened,TRUE
                    .else
                        invoke MessageBox,hWnd,addr OpenFileFail,addr AppName,MB_OK or MB_ICONERROR
                    .endif
                .endif
            .elseif ax==IDM_CLOSE
                invoke CheckModifyState,hWnd
                .if eax==TRUE
                    invoke SetWindowText,hwndRichEdit,0
                    mov FileOpened,FALSE
                .endif
            .elseif ax==IDM_SAVE
                invoke CreateFile,addr FileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
                .if eax!=INVALID_HANDLE_VALUE
@@:
                    mov hFile,eax
                    mov editstream.dwCookie,eax
                    mov editstream.pfnCallback,offset StreamOutProc
                    invoke SendMessage,hwndRichEdit,EM_STREAMOUT,SF_TEXT,addr editstream
                    invoke SendMessage,hwndRichEdit,EM_SETMODIFY,FALSE,0
                    invoke CloseHandle,hFile
                .else
                    invoke MessageBox,hWnd,addr OpenFileFail,addr AppName,MB_OK or MB_ICONERROR
                .endif
            .elseif ax==IDM_COPY
                invoke SendMessage,hwndRichEdit,WM_COPY,0,0
            .elseif ax==IDM_CUT
                invoke SendMessage,hwndRichEdit,WM_CUT,0,0
            .elseif ax==IDM_PASTE
                invoke SendMessage,hwndRichEdit,WM_PASTE,0,0
            .elseif ax==IDM_DELETE
                invoke SendMessage,hwndRichEdit,EM_REPLACESEL,TRUE,0
            .elseif ax==IDM_SELECTALL
                mov chrg.cpMin,0
                mov chrg.cpMax,-1
                invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr chrg
            .elseif ax==IDM_UNDO
                invoke SendMessage,hwndRichEdit,EM_UNDO,0,0
            .elseif ax==IDM_REDO
                invoke SendMessage,hwndRichEdit,EM_REDO,0,0
            .elseif ax==IDM_OPTION
                invoke DialogBoxParam,hInstance,IDD_OPTIONDLG,hWnd,addr OptionProc,0
            .elseif ax==IDM_SAVEAS
                invoke RtlZeroMemory,addr ofn,sizeof ofn
                mov ofn.lStructSize,sizeof ofn
                push hWnd
                pop ofn.hwndOwner
                push hInstance
                pop ofn.hInstance
                mov ofn.lpstrFilter,offset ASMFilterString
                mov ofn.lpstrFile,offset AlternateFileName
                mov byte ptr [AlternateFileName],0
                mov ofn.nMaxFile,sizeof AlternateFileName
                mov ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
                invoke GetSaveFileName,addr ofn
                .if eax!=0
                    invoke CreateFile,addr AlternateFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
                    .if eax!=INVALID_HANDLE_VALUE
                        jmp @B
                    .endif
                .endif
            .elseif ax==IDM_FIND
                .if hSearch==0
                    invoke CreateDialogParam,hInstance,IDD_FINDDLG,hWnd,addr SearchProc,0
                .endif
            .elseif ax==IDM_REPLACE
                .if hSearch==0
                    invoke CreateDialogParam,hInstance,IDD_REPLACEDLG,hWnd,addr ReplaceProc,0
                .endif
            .elseif ax==IDM_GOTOLINE
                .if hSearch==0
                    invoke CreateDialogParam,hInstance,IDD_GOTODLG,hWnd,addr GoToProc,0
                .endif
            .elseif ax==IDM_FINDNEXT
                invoke lstrlen,addr FindBuffer
                .if eax!=0
                    invoke SendMessage,hwndRichEdit,EM_EXGETSEL,0,addr findtext.chrg
                    mov eax,findtext.chrg.cpMin
                    .if eax!=findtext.chrg.cpMax
                        push findtext.chrg.cpMax
                        pop findtext.chrg.cpMin
                    .endif
                    mov findtext.chrg.cpMax,-1
                    mov findtext.lpstrText,offset FindBuffer
                    invoke SendMessage,hwndRichEdit,EM_FINDTEXTEX,FR_DOWN,addr findtext
                    .if eax!=-1
                        invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr findtext.chrgText
                    .endif
                .endif
            .elseif ax==IDM_FINDPREV
                invoke lstrlen,addr FindBuffer
                .if eax!=0
                    invoke SendMessage,hwndRichEdit,EM_EXGETSEL,0,addr findtext.chrg
                    mov findtext.chrg.cpMax,0
                    mov findtext.lpstrText,offset FindBuffer
                    invoke SendMessage,hwndRichEdit,EM_FINDTEXTEX,0,addr findtext
                    .if eax!=-1
                        invoke SendMessage,hwndRichEdit,EM_EXSETSEL,0,addr findtext.chrgText
                    .endif
                .endif
            .elseif ax==IDM_EXIT
                invoke SendMessage,hWnd,WM_CLOSE,0,0
            .endif
        .endif
    .elseif uMsg==WM_CLOSE
        invoke CheckModifyState,hWnd
        .if eax==TRUE
            invoke DestroyWindow,hWnd
        .endif
    .elseif uMsg==WM_SIZE
        mov eax,lParam
        mov edx,eax
        and eax,0FFFFh
        shr edx,16
        invoke MoveWindow,hwndRichEdit,0,0,eax,edx,TRUE
    .elseif uMsg==WM_DESTROY
        invoke PostQuitMessage,NULL
    .else
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
    .endif
    xor eax,eax
    ret
WndProc endp
end start
Analysis:
     The first action before calling WinMain to to call FillHiliteInfo. This function reads the content of 
     wordfile.txt and parses the content.
     
     FillHiliteInfo proc uses edi
         LOCAL buffer[1024]:BYTE
         LOCAL pTemp:DWORD
         LOCAL BlockSize:DWORD
         invoke RtlZeroMemory,addr ASMSyntaxArray,sizeof ASMSyntaxArray
     Initialize ASMSyntaxArray to zero.
     
     
         invoke GetModuleFileName,hInstance,addr buffer,sizeof buffer
         invoke lstrlen,addr buffer
         mov ecx,eax
         dec ecx
         lea edi,buffer
         add edi,ecx
         std
         mov al,"\"
         repne scasb
         cld
         inc edi
         mov byte ptr [edi],0
         invoke lstrcat,addr buffer,addr WordFileName
     Construct the full path name of wordfile.txt: I assume that it's always in the same folder as the program.
     
     
         invoke GetFileAttributes,addr buffer
         .if eax!=-1
     I use this method as a quick way of checking whether a file exists.
     
     
             mov BlockSize,1024*10
             invoke HeapAlloc,hMainHeap,0,BlockSize
             mov pTemp,eax
     Allocate the memory block to store the words. Default to 10K. The memory is allocated from the default heap.
     
     
     @@:
             invoke GetPrivateProfileString,addr ASMSection,addr C1Key,addr ZeroString,pTemp,BlockSize,addr buffer
             .if eax!=0
     I use GetPrivateProfileString to retrieve the content of each key in wordfile.txt. The key starts from 
     C1 to C10.
     
     
                 inc eax
                 .if eax==BlockSize  ; the buffer is too small
                     add BlockSize,1024*10
                     invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
                     mov pTemp,eax
                     jmp @B
                 .endif
     Checking whether the memory block is large enough. If it is not, we increment the size by 10K until the 
     block is large enough. 
     
     
                 mov edx,offset ASMColorArray
                 invoke ParseBuffer,hMainHeap,pTemp,eax,edx,addr ASMSyntaxArray
     Pass the words, the memory block handle, the size of the data read from wordfile.txt, the address of the 
     color dword that will be used to hilight the words and the address of ASMSyntaxArray.
     
     Now, let's examine what ParseBuffer does. In essence, this function accepts the buffer containing the 
     words to be hilighted ,parses them to individual words and stores each of them in a WORDINFO structure 
     array that can be accessed quickly from ASMSyntaxArray. 
     
     
     ParseBuffer proc uses edi esi hHeap:DWORD,pBuffer:DWORD, nSize:DWORD, ArrayOffset:DWORD,pArray:DWORD
         LOCAL buffer[128]:BYTE
         LOCAL InProgress:DWORD
         mov InProgress,FALSE
     InProgress is the flag I use to indicate whether the scanning process has begun. If the value is FALSE, 
     we haven't encountered a non-white space character yet.
     
     
         lea esi,buffer
         mov edi,pBuffer
         invoke CharLower,edi
     esi points to our local buffer that will contain the word we have parsed from the word list. edi points to 
     the word list string. To simplify the search later, we convert all characters to lowercase.
     
     
         mov ecx,nSize
     SearchLoop:
         or ecx,ecx
         jz Finished
         cmp byte ptr [edi]," "
         je EndOfWord
         cmp byte ptr [edi],9    ; tab
         je EndOfWord
     Scan the whole word list in the buffer, looking for the white spaces. If a white space is found, we have 
     to determine whether it marks the end or the beginning of a word. 
     
         mov InProgress,TRUE
         mov al,byte ptr [edi]
         mov byte ptr [esi],al
         inc esi
     SkipIt:
         inc edi
         dec ecx
         jmp SearchLoop
     If the byte under scrutiny is not a white space, we copy it to the buffer to construct a word and then 
     continue the scan. 
     
     EndOfWord:
         cmp InProgress,TRUE
         je WordFound
         jmp SkipIt
     If a white space is found, we check the value in InProgress. If the value is TRUE, we can assume 
     that the white space marks the end of a word and we may proceed to put the word currently in the local buffer
      (pointed to by esi) into a WORDINFO structure. If the value is FALSE, we continue the scan until a non-white 
      space character is found. 
     
     WordFound:
         mov byte ptr [esi],0
         push ecx
         invoke HeapAlloc,hHeap,HEAP_ZERO_MEMORY,sizeof WORDINFO
     When the end of a word is found, we append 0 to the buffer to make the word an ASCIIZ string. 
     We then allocate a block of memory from the heap the size of WORDINFO for this word. 
     
         push esi
         mov esi,eax
         assume esi:ptr WORDINFO
         invoke lstrlen,addr buffer
         mov [esi].WordLen,eax
     We obtain the length of the word in the local buffer and store it in the WordLen member of the WORDINFO 
     structure, to be used as a quick comparison. 

    push ArrayOffset
    pop [esi].pColor
     Store the address of the dword that contains the color to be used to hilight the word in pColor member. 
     
         inc eax
         invoke HeapAlloc,hHeap,HEAP_ZERO_MEMORY,eax
         mov [esi].pszWord,eax
         mov edx,eax
         invoke lstrcpy,edx,addr buffer
     Allocate memory from the heap to store the word itself. Right now, the WORDINFO structure is ready to be 
     inserted into the appropriate linked list. 
     
         mov eax,pArray
         movzx edx,byte ptr [buffer]
         shl edx,2       ; multiply by 4
         add eax,edx
     pArray contains the address of ASMSyntaxArray. We want to move to the dword that has the same index as the 
     value of the first character of the word. So we put the first character of the word in edx then multiply 
     edx by 4 (because each element in ASMSyntaxArray is 4 bytes in size) and then add the offset to the address 
     of ASMSyntaxArray. We have the address of the corresponding dword in eax. 
     
         .if dword ptr [eax]==0
             mov dword ptr [eax],esi
         .else
             push dword ptr [eax]
             pop [esi].NextLink
             mov dword ptr [eax],esi
         .endif
     Check the value of the dword. If it's 0, it means there is currently no word that begins with this character in 
     the list. We thus put the address of the current WORDINFO structure in that dword.
     
     If the value in the dword is not 0, it means there is at least one word that begins with this charac
     ter in the array. We thus insert this WORDINFO structure to the head of the linked list and update 
     its NextLink member to point to the next WORDINFO structure.
     
         pop esi
         pop ecx
         lea esi,buffer
         mov InProgress,FALSE
         jmp SkipIt
	After the operation is complete, we begin the next scan cycle until the end of buffer is reached. 

        invoke SendMessage,hwndRichEdit,EM_SETTYPOGRAPHYOPTIONS,TO_SIMPLELINEBREAK,TO_SIMPLELINEBREAK
        invoke SendMessage,hwndRichEdit,EM_GETTYPOGRAPHYOPTIONS,1,1
        .if eax==0      ; means this message is not processed
            mov RichEditVersion,2
        .else
            mov RichEditVersion,3
            invoke SendMessage,hwndRichEdit,EM_SETEDITSTYLE,SES_EMULATESYSEDIT,SES_EMULATESYSEDIT
        .endif
     After the richedit control is created, we need to determine the its version. This step is necessary since 
     EM_POSFROMCHAR behaves differently for RichEdit 2.0 and 3.0 and EM_POSFROMCHAR is crucial to our syntax 
     hilighting routine. I have never seen a documented way of checking the version of richedit control thus 
     I have to use a workaround. In this case, I set an option that is specific to version 3.0 and immediately 
     retrieve its value. If I can retrieve the value, I assume that the control version is 3.0.
     
     If you use RichEdit control version 3.0, you will notice that updating the font color for a large file takes
      quite a long time. This problem seems to be specific to version 3.0. I found a workaround: making the control
      emulate the behavior of the system edit control by sending EM_SETEDITSTYLE message.
     
     After we can obtain the version information, we proceed to subclass the richedit control. We will now examine 
     the new window procedure for the richedit control.
     
     NewRichEditProc proc hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
         ........
         .......
         .if uMsg==WM_PAINT
             push edi
             push esi
             invoke HideCaret,hWnd
             invoke CallWindowProc,OldWndProc,hWnd,uMsg,wParam,lParam
             push eax
     We handle WM_PAINT message. First, we hide the caret so as to avoid some ugly gfx after the hilighting. 
     After that we pass the message to the original richedit procedure to let it update the window. 
     When CallWindowProc returns, the text is updated with its usual color/background. Now is our opportunity 
     to do syntax hilighting. 
     
             mov edi,offset ASMSyntaxArray
             invoke GetDC,hWnd
             mov hdc,eax
             invoke SetBkMode,hdc,TRANSPARENT
     Store the address of ASMSyntaxArray in edi. Then we obtain the handle to the device context and set the 
     text background mode to transparent so the text that we will write will use the default background color. 


        invoke SendMessage,hWnd,EM_GETRECT,0,addr rect
        invoke SendMessage,hWnd,EM_CHARFROMPOS,0,addr rect
        invoke SendMessage,hWnd,EM_LINEFROMCHAR,eax,0
        invoke SendMessage,hWnd,EM_LINEINDEX,eax,0
     We want to obtain the visible text so we first have to obtain the formatting rectangle by sending EM_GETRECT 
     message to the richedit control. Now that we have the bounding rectangle, we obtain the nearest character 
     index to the upper left corner of the rectangle with EM_CHARFROMPOS. Once we have the character index 
     (the first visible character in the control), we can start to do syntax hilighting starting from that position.
      But the effect might not be as good as when we start from the first character of the line that the character 
     is in. That's why I need to obtain the line number of that the first visible character is in by sending 
     EM_LINEFROMCHAR message. To obtain the first character of that line, I send EM_LINEINDEX message. 
     
             mov txtrange.chrg.cpMin,eax
             mov FirstChar,eax
             invoke SendMessage,hWnd,EM_CHARFROMPOS,0,addr rect.right
             mov txtrange.chrg.cpMax,eax
     Once we have the first character index, store it for future reference in FirstChar variable. Next we obtain
      the last visible character index by sending EM_CHARFROMPOS, passing the lower-right corner of the formatting 
     rectangle in lParam. 
     
             push rect.left
             pop RealRect.left
             push rect.top
             pop RealRect.top
             push rect.right
             pop RealRect.right
             push rect.bottom
             pop RealRect.bottom
             invoke CreateRectRgn,RealRect.left,RealRect.top,RealRect.right,RealRect.bottom
             mov hRgn,eax
             invoke SelectObject,hdc,hRgn
             mov hOldRgn,eax
     While doing syntax hilighting, I noticed an unsightly side-effect of this method: if the richedit control 
     has a margin (you can specify margin by sending EM_SETMARGINS message to the richedit control), DrawText 
     writes over the margin. Thus I need to create a clipping region, the size of the formatting rectangle, 
     by calling CreateRectRgn. The output of GDI functions will be clipped to the "writable" area.
     
     Next, we need to hilight the comments first and get them out of our way. My method is to search for ";" 
     and hilight the text with the comment color until the carriage return is found. I will not analyze the routine
      here: it's fairly long and complicated. Suffice here to say that, when all the comments are hilighted, 
     we replace them with 0s in the buffer so that the words in the comments will not be processed/hilighted later.

        mov ecx,BufferSize
        lea esi,buffer
        .while ecx>0
            mov al,byte ptr [esi]
            .if al==" " || al==0Dh || al=="/" || al=="," || al=="|" || al=="+" || al=="-" || al=="*" ||  
            al=="&" || al=="<" || al==">" || al=="=" || al=="(" || al==")" || al=="{" || al=="}" || al=="[" || 
            al=="]" || al=="^" || al==":" || al==9
                mov byte ptr [esi],0
            .endif
            dec ecx
            inc esi
        .endw
     Once the comments are out of our way, we separate the words in the buffer by replacing the "separator
     " characters with 0s. With this method, we need not concern about the separator characters while
     processing the words in the buffer anymore: there is only one separator character, NULL. 
     
             lea esi,buffer
             mov ecx,BufferSize
             .while ecx>0
                 mov al,byte ptr [esi]
                 .if al!=0
     Search the buffer for the first character that is not null,ie, the first character of a word. 
     
                     push ecx
                     invoke lstrlen,esi
                     push eax
                     mov edx,eax
     Obtain the length of the word and put it in edx 

                movzx eax,byte ptr [esi]
                .if al>="A" && al<="Z"
                    sub al,"A"
                    add al,"a"
                .endif
     Convert the character to lowercase (if it's an uppercase character) 
     
                     shl eax,2
                     add eax,edi     ; edi contains the pointer to the WORDINFO pointer array
                     .if dword ptr [eax]!=0
     After that, we skip to the corresponding dword in ASMSyntaxArray and check whether the value in that dword 
     is 0. If it is, we can skip to the next word. 
     
                         mov eax,dword ptr [eax]
                         assume eax:ptr WORDINFO
                         .while eax!=0
                             .if edx==[eax].WordLen
     If the value in the dword is non-zero, it points to the linked list of WORDINFO structures. We process to 
     walk the linked list, comparing the length of the word in our local buffer with the length of the word in 
     the WORDINFO structure. This is a quick test before we compare the words. Should save some clock cycles. 
     
                                 pushad
                                 invoke lstrcmpi,[eax].pszWord,esi
                                 .if eax==0
     If the lengths of both words are equal, we proceed to compare them with lstrcmpi. 
     
                                     popad
                                     mov ecx,esi
                                     lea edx,buffer
                                     sub ecx,edx
                                     add ecx,FirstChar
     We construct the character index from the address of the first character of the matching word in the buffer. 
     We first obtain its relative offset from the starting address of the buffer then add the character index of 
     the first visible character to it. 

                                pushad
                                .if RichEditVersion==3
                                    invoke SendMessage,hWnd,EM_POSFROMCHAR,addr rect,ecx
                                .else
                                    invoke SendMessage,hWnd,EM_POSFROMCHAR,ecx,0
                                    mov ecx,eax
                                    and ecx,0FFFFh
                                    mov rect.left,ecx
                                    shr eax,16
                                    mov rect.top,eax
                                .endif
                                popad
     Once we know the character index of the first character of the word to be hilighted, we proceed to obtain the 
     coordinate of it by sending EM_POSFROMCHAR message. However, this message is interpreted differently by 
     richedit 2.0 and 3.0. For richedit 2.0, wParam contains the character index and lParam is not used. It returns 
     the coordinate in eax. For richedit 3.0, wParam is the pointer to a POINT structure that will be filled with 
     the coordinate and lParam contains the character index. 
     
     As you can see, passing the wrong arguments to EM_POSFROMCHAR can wreak havoc to your system. That's why 
     I have to differentiate between RichEdit control versions. 
     
                                     mov edx,[eax].pColor
                                     invoke SetTextColor,hdc,dword ptr [edx]
                                     invoke DrawText,hdc,esi,-1,addr rect,0
     Once we got the coordinate to start, we set the text color with the one specified in the WORDINFO structure. 
     And then proceed to overwrite the word with the new color.
     
     As the final words, this method can be improved in several ways. For example, I obtain all the text starting 
     from the first to the last visible line. If the lines are very long, the performance may hurt by processing 
     the words that are not visible. You can optimize this by obtaining the really visible text line by line. 
     Also the searching algorithm can be improved by using a more efficient method. Don't take me wrong: 
     the syntax hilighting method used in this example is FAST but it can be FASTER. :)
     
 		--------------------------------------------------------------------------------
    
                  Please report any Problem to  the following email addresses:
                              
                                    'ouk.polyvann@gmail'
                              
                              		  Thank you
                              
                              	      Ouk Polyvann    
     	=================================================================================




