     ================================================================================
     *															    *
     *                      Complete X86 instruction set 					    *
     *						 Book Page: 174  				              *
     --------------------------------------------------------------------------------
     
                              Instruction Name
                              
     1.'Data Transfer	2.Arithmetic and Logic		3.Program Control
     
               MOV,				ADD,						JZ,
               PUSH,			SUB,						JE,
               POP,				MUL,						JB,
               PUSHA,			DIV,						JC,
               POPA,			IDIV,					JNAE,
               PUSHF,		     ,IMUL					JS,
               POPF,			OR,						JO,
               CLD,				AND,						JPE,
               CLC,				NOT,						JP,
               CLI,			     ,XOR						JNZ,
               STI,				ADC,						JNE,
               STC,				SBB,						JNC,
               STD,				IN,						JNB,
               LEA,				OUT,						JAE,
               MOVS,			TEST,					JNS,
               MOVSX,			XLAT,					JNO,
               MOVZX,			XLATB,					JPO,
               PUSHAD,			NEG,						JNP,
               POPAD,			DEC,						JCXZ,
               PUSHFD,			INC,						JG,
               POPFD,			LAHF,					JL,
               XCHG,									JLE,
               ===================Data Transfer=======================				
               LES,				LDS,						MOVSB,
               LSS,				LODSB,					MOVSW,
               LDS,				LODSW,					SCASW,
               SCASB,
               STOSB,			STOSW,
     
    	 4. 'Shift Bit		5.BCD AND ASCII		6.Uncondition
    	 
               SHL,				DAA,					INTO,
               SHR,				DAS,					IRET,
               SAL,				AAA,					RET,
               SAR,				AAS,					JMP,
               ROL,				AAM,					CALL,
              ,ROR				AAD,				
               RCL,									
               RCR,									
     					
    	 7.'Compare and Loop instruction	     									
     	 								     		
               CMC, 		REP,			LOOPNZ,		NOP,			
               CMP, 		REPE,		LOOPZ,		HLT,
               CMPSB, 		LOOP,		REPZ,		
               CMPSW,		LOOPE,		RET,			
               CWD, 		LOOPNE,		RETF,		
     	 									
     ----------------------------------------------------------------------------------------------
REG,
     Operand types:
        1.Register(CPU variables): In Book Page:83-->108
       				
          	REG(32_bit): EAX, EBX, ECX, EDX, ESI, EDI, ESP, EBP
               REG(16_bit): AX, BX, CX, DX,  SI, DI BP, SP
          	REG(8_bit):  AH, AL, BL, BH, CH, CL, DH, DL, DI
          	
          
               SREG: DS, ES, SS, and only as second operand: CS.
     
        2.memory(Ram): [BX], [BX+SI+7], variable, etc...(see Memory Access).
     
        3.immediate: 5, -24, 3Fh, 10001101b, etc...
     
     -----------------------------------------------------------------------------------------------
     
     Notes:
     
     	When two operands are required for an instruction they are separated by comma. For example:
     			
     			          "  dest, src " 
     
     
     When there are two operands, both operands must have the same size (except shift and rotate 
     instructions). For example:

          Mov AL, DL
          Add DX, AX
          m1 DB ?
          Sub AL, m1
          m2 DW ?
          And EAX, m2 
      
     	Some instructions allow several operand combinations. For example:
     
                   ;*************************************
                    		  memory, immediate
                    		  REG, immediate
                    
                                memory, REG
                                REG, SREG 
                    'Note:
                                No perands
                                Only one Operand
         			;************************************* 
     Format Instruction:
     			;=====================================
     			'     Name_Of_Instruction Operands
     			;-------------------------------------     
     
     	Some examples contain macros, so it is advisable to use Shift + F8 hot key to Step Over 
     (to make macro code execute at maximum speed set step delay to zero), otherwise X86 
     will step through each instruction of a macro. Here is an example that uses PrintString macro: 
      
             include 'masm32rt.inc'
             include "debug.inc"
             includelib "debug.lib"
             
             MOV AL, 1
             MOV BL, 2
             PrintText 'Hello World!'   ; macro.
             MOV CL, 3
             PrintText 'Welcome!'       ; macro.
             RET
     
     -------------------------------------------------------------------------------------
     
     These marks are used to show the state of the flags:
     
     1 - instruction sets this flag to 1.
     0 - instruction sets this flag to 0.
     r - flag value depends on result of the instruction.
     ? - flag value is undefined (maybe 1 or 0).
     
     --------------------------------------------------------------------------------------
     
     Some instructions generate exactly the same machine code, so disassembler may have 
     a problem decoding to your original code. This is especially important for Conditional 
     Jump instructions (see "Program Flow Control" in Tutorials for more information). 
     
     --------------------------------------------------------------------------------------
     
     Instructions in alphabetical order: 
     Instruction Operands Description    
     
AAA, :Sytax: AAA No operands 

	Function: ASCII Adjust after Addition.Corrects result in AH and AL after addition when 
	working with BCD values. 
     
     It works according to the following Algorithm: 
     
     	if low nibble of AL > 9 or AF = 1 then:
     
               AL = AL + 6 
               AH = AH + 1 
               AF = 1 
               CF = 1 
          else 
               AF = 0 
               CF = 0 
          in both cases:
          clear the high nibble of AL. 
     
     Example:
          MOV AX, 15   ; AH = 00, AL = 0Fh
          AAA          ; AH = 01, AL = 05
          RET
     C Z S O P A 
     r ? ? ? ? r 
         
AAD, Function: ASCII Adjust before Division.repares two BCD values for division. 

     Syntax :ADD no operands
     Algorithm: 
          
          AL = (AH * 10) + AL 
          AH = 0 
     
     Example:
          MOV AX, 0105h   ; AH = 01, AL = 05
          AAD             ; AH = 00, AL = 0Fh (15)
          RET
     C Z S O P A 
     ? r r ? r ? 
         
AAM, Function: ASCII Adjust after Multiplication.
     Corrects the result of multiplication of two BCD values. 
     
     Syntax:AAM No operands 
     
     Algorithm:
          
          AH = AL / 10 
          AL = remainder 
     
     Example:
          MOV  AL, "9"	; Al = 39h
          AND  AL, 0Fh   ; Al = 09h
          MOV  DL, "7"   ; Dl = 37h
          AND  DL, 0Fh	; Dl = 07h
          MUL  DL	     ; Dl = 3Fh
          AAM			; Al = 03h and Ah = 06h 
		               ; Ax = ?		
          OR AX , 3030H  ; Ax = ?
          
     C Z S O P A 
     ? r r ? r ? 
         
AAS, Function: ASCII Adjust after Subtraction.
     Corrects result in AH and AL after subtraction when working with BCD values. 
     
     Syntax: AAS No operands 
     Algorithm:
     
     if low nibble of AL > 9 or AF = 1 then:
          
          AL = AL - 6 
          AH = AH - 1 
          AF = 1 
          CF = 1 
          else 
          AF = 0 
          CF = 0 
          in both cases:
     clear the high nibble of AL. 
     
     Example:
          MOV AX, 02FFh  ; AH = 02, AL = 0FFh
          AAS            ; AH = 01, AL = 09
          RET
     C Z S O P A 
     r ? ? ? ? 
ADC, Syntax:ADC REG, memory
          memory, REG
          REG, REG
          memory, immediate
          REG, immediate  Add with Carry.
     
     
     Algorithm:
     
     operand1 = operand1 + operand2 + CF 
     
     Example:
          STC        ; set CF = 1
          MOV AL, 5  ; AL = 5
          ADC AL, 1  ; AL = 7
          RET
     C Z S O P A 
     r r r r r r 
         
ADD, Syntax:Add REG, memory       ; Add EAX, x
                memory, REG       ; Add x, Eax
                REG, REG		    ; Add Eax, Edx
                memory, immediate ; Add x, 1234h
                REG, immediate    ; Add Eax, 1234568h
     
     
     Algorithm:
     
     	operand1 = operand1 + operand2 
     
     Example:
     		8_bit									
          MOV AL, 5   ; AL = 5				
          ADD AL, -3  ; AL = 2			
          RET						
			16_bit
     	MOV AX, 3456H ;AX=3456H
     	MOV DX, 67ACH ;DX=67ACH
     	ADD AX, DX    ;AX= AX + DX
     	
     		32_BIT
     	MOV EAX, 12345678H
     	MOV EDX, 9876ABCDH
     	ADD EAX, EDX
     	
     Practice1:
     	title :  Add

          .586
          
          	Include masm32rt.inc
			Include \X86V2\X86.inc
			Includelib \X86V2\X86.lib
          	
          ;=================Input Data===========================================
          .data
               	x       dd	12345678H
               	y       dd	9876ABCDH
               	r	   dd	0
          .code
          
          start:
              	   MOV EAX, x  ;Eax = 
                  MOV EDX, y  ;Eax = Eax + y 
                  ADD EAX, EDX
                  PrintHex Eax
                  MOV r, Eax
                  PrintHex r
          	
          Ret	 
          end start
          ;=================Output===============================================
          ;					
	Practice2:
		title :  Summing an Array

          .586
          
          	Include masm32rt.inc
          	Include \X86V2\X86.inc
          	Includelib debug.lib
          	
          ;=================Input Data=========================================
          ;TITLE                        
          
          .data
          	intarray DWORD 10000h,20000h,30000h,40000h,50000h,60000h
          .code
          start:
          
          	mov  edi,OFFSET intarray			; 1: EDI = address of intarray
          	mov  ecx,LENGTHOF intarray		; 2: initialize loop counter
          	mov  eax,0					; 3: sum = 0
          L1:								; 4: mark beginning of loop
          	add  eax,[edi]					; 5: add an integer
          	add  edi,TYPE intarray   		; 6: point to next element
          	loop L1	
          	PrintHex eax					
          	ret
          ;---------------------------------------------------------------------
          end start

     Flags:
     
     C Z S O P A 
     r r r r r r 
         
AND, Syntax: And REG, memory
          memory, REG
          REG, REG
          memory, immediate
     	REG, immediate  
     	
     Function:Logical AND between all bits of two operands. Result is stored in operand1.
     
     These rules apply:
     
          1 AND 1 = 1
          1 AND 0 = 0
          0 AND 1 = 0
          0 AND 0 = 0
     
     Example:
     
          MOV AL, 'a'        ; AL = 01100001b
          AND AL, 11011111b  ; AL = 01000001b  ('A')
          RET
          
     C Z S O P 
     0 r r 0 r 
         
CAll,
	Syntax:     
		CALL  procedure name
     
      Transfers control to procedure, return address is (IP) is pushed to stack. 4-byte address 
      may be entered in this form: 1234h:5678h, first value is a segment second value is an offset 
      (this is a far call, so CS is also pushed to stack).
     
     Example:
                   
          CALL p1
          
          ADD AX, 1
          
          RET         ; return to OS.
     
     p1 PROC     ; procedure declaration.
         MOV AX, 1234h
         RET     ; return to caller.
     p1 ENDP
     
     C Z S O P A 
     unchanged 
         
CBW, Syntax:CBW No operands 
	Function:Convert byte into word. 
     
     Algorithm: 
     
     if high bit of AL = 1 then: 
     	AH = 255 (0FFh) 
     
     else 
     	AH = 0 
     
     Example:
          MOV AX, 0   ; AH = 0, AL = 0
          MOV AL, -5  ; AX = 000FBh (251)
          CBW         ; AX = 0FFFBh (-5)
          RET
          
     C Z S O P A 
     unchanged 
         
CLC, Syntax:CLC No operands 

	Function: Clear Carry flag. 
     
     Algorithm: 
          
     	CF = 0 
     
     C 
     0 
         
CLD, Syntax: No operands 
	Function: Clear Direction flag. SI and DI will be incremented by chain 
     instructions: CMPSB , CMPSW, LODSB, LODSW, MOVSB, MOVSW, STOSB, STOSW. 
     
     Algorithm: 
     
          DF = 0 
          
          D 
          0 
         
CLI, Sytax: No operands 

	Function:Clear Interrupt enable flag. This disables hardware interrupts. 
     
     Algorithm: 
     
          IF = 0 
          
          I 
          0 
         
CMC, Syntax: CMC No operands 

	Function: Complement Carry flag. Inverts value of CF. 
     
     Algorithm: 
     
          if CF = 1 then CF = 0
          if CF = 0 then CF = 1
    
     C 
     r 
         
CMP,
	Syntax:
          CMP  REG, memory
          	memory, REG
          	REG, REG
          	memory, immediate
          	REG, immediate  Compare. 
     
     Algorithm:
     
     	operand1 - operand2 
     
     	result is not stored anywhere, flags are set (OF, SF, ZF, AF, PF, CF) according to result. 
     
     Example:
          MOV AL, 5
          MOV BL, 5
          CMP AL, BL  ; AL = 5, ZF = 1 (so equal!)
          RET
          
     C Z S O P A 
     r r r r r r 
         
CMPSB, 
	Syntax: No operands
	 
	Function:Compare bytes: ES:[DI] from DS:[SI]. 
     
     Algorithm: 
     
          DS:[SI] - ES:[DI]
          
          set flags according to result:
          OF, SF, ZF, AF, PF, CF
          
          if DF = 0 then 
               SI = SI + 1 
               DI = DI + 1 
          else 
               SI = SI - 1 
          	DI = DI - 1 
     Example:
    
     		title :  Test repe and cmpsb instruction
	
          .586
          
          	Include masm32rt.inc
          	Include \X86V2\X86.inc
          	Includelib debug.lib
          	
          ;=================Input Data===========================================
          .data
               	str1 db 'test string'
          		str2 db 'test string' 
          .code
          start:
          	   cld     
                  lea     esi, str1
                  lea     edi, str2
          
          ; set counter to string length:
                  mov     cx, Lengthof str1
          
          ; compare until equal:
                  repe    cmpsb
                  jnz     not_equal
          
          ; "yes" - equal!
                  PrintText "y"
                  jmp     quit_here
          
          not_equal:
          
          ; "no" - not equal!
                  PrintText "n"
          quit_here:
          
          Ret	 
          end start
          ;=================Output===============================================
          ;	dest and src is the same				

     C Z S O P A 
     r r r r r r 
         
CMPSW,  
	Syntax:CMPSW No operands 
	
	Function:Compare words: ES:[DI] from DS:[SI]. 
     
     Algorithm: 
      
    	 	DS:[SI] - ES:[DI]
     
     set flags according to result:
     OF, SF, ZF, AF, PF, CF
     
          if DF = 0 then 
          SI = SI + 2 
          DI = DI + 2 
          else 
          SI = SI - 2 
          DI = DI - 2 
     example:
     		 See cmpsb
     
     C Z S O P A 
     r r r r r r 
         
CWD, 
	Syntax: CWD No operands 
	Function: Convert Word to Double word. 
     
     Algorithm: 
     
          if high bit of AX = 1 then: 
          DX = 65535 (0FFFFh) 
          
          else 
          DX = 0 
     
     Example:
          MOV DX, 0   ; DX = 0
          MOV AX, 0   ; AX = 0
          MOV AX, -5  ; DX AX = 00000h:0FFFBh
          CWD         ; DX AX = 0FFFFh:0FFFBh
          RET
          
     C Z S O P A 
     unchanged 
         
DAA, Syntax:DAA No operands 
	Function: Decimal adjust After Addition.
     Corrects the result of addition of two packed BCD values. 
     
     Algorithm: 
     	
     	if low nibble of AL > 9 or AF = 1 then:
          
          	AL = AL + 6 
          	AF = 1 
          if AL > 9Fh or CF = 1 then: 
          	AL = AL + 60h 
          	CF = 1 
     
     Example:
     	  MOV AL, 48h  ; AL = 48H      
       	  ADD AL, 39H  ; AL = 81h     
      	  DAA 		; Al = 87h
            RET
          
     C Z S O P A 
     r r r r r r 
         
DAS, 
	Syntax:DAS No operands 
 	Function: Decimal adjust After Subtraction.
     Corrects the result of subtraction of two packed BCD values. 
     
     Algorithm: 
     
          if low nibble of AL > 9 or AF = 1 then:
          
          	AL = AL - 6 
          	AF = 1 
          if AL > 9Fh or CF = 1 then: 
          	AL = AL - 60h 
          	CF = 1 
     
     Example:
          MOV AL, 0FFh  ; AL = 0FFh (-1)
          DAS           ; AL = 99h, CF = 1
          RET
     
     C Z S O P A 
     r r r r r r 
         
DEC, Syntax:DEC REG
     		 memory
     		 
     Function:  Decrement by one. 
     
     Algorithm:
     
     	operand = operand - 1 
         
     Example:
          MOV AL, 255  ; AL = 0FFh (255 or -1)
          DEC AL       ; AL = 0FEh (254 or -2)
          RET
     Z S O P A 
     r r r r r 
     CF - unchanged!     
DIV, Syntax: DIV REG
     		  memory
      		  Unsigned divide. 
     
     Algorithm:
    
          when operand is a byte:
          	AL = AX / operand
          	AH = remainder (modulus) 
          when operand is a word:
          	AX = (DX AX) / operand
     		DX = remainder (modulus)
     	When operand is dword
     		Eax = Eax/ operand
     		Edx = remainder 
     	
     Example:
          MOV AX, 203   ; AX = 00CBh
          MOV BL, 4
          DIV BL        ; AL = 50 (32h), AH = 3
          RET
          
          title :  Division Operand  is dword

          .586
          
          	Include masm32rt.inc
          	Include \X86V2\X86.inc
          	Includelib debug.lib
          	
          ;=================Input Data===========================================
          .data
               	x       dd	1234ABCDH
               	y       dd	00115678H
               	r	   dd	0
          .code
          
          start:
          	  Mov Eax, 0
          	  Mov Edx, 0
              	  MOV Eax, x   ; Eax = 1234ABCDh 
                 MOV Ebx, y
                 DIV Ebx      ; AL = 50 (32h), AH = 3
          	  PrintHex Eax ; Eax =
          	  PrintHex Edx ; Edx =
          	  
          Ret	 
          end start
          ;=================Output===============================================

     C Z S O P A 
     ? ? ? ? ? ? 
         
HLT, Syntax: HLT No operands and Function: Halt the System.
     
     Example:
     	MOV AX, 5
     	HLT
     C Z S O P A 
     unchanged 
         
IDIV Syntax:IDIV  REG
            memory
            Signed divide. 
     
     Algorithm:
     
          when operand is a byte:
               AL = AX / operand
               AH = remainder (modulus) 
          when operand is a word:
               AX = (DX AX) / operand
          	DX = remainder (modulus) 
     	
     Example:
          MOV AX, -203 ; AX = 0FF35h
          MOV BL, 4
          IDIV BL      ; AL = -50 (0CEh), AH = -3 (0FDh)
          RET
     C Z S O P A 
     ? ? ? ? ? ? 
         
,IMUL 
	Syntax:IMUL REG
     		   memory
      	        Signed multiply. 
     
     Algorithm:
      
          when operand is a byte:
          	AX = AL * operand. 
          when operand is a word:
          	(DX AX) = AX * operand. 
     Example:
          MOV AL, -2
          MOV BL, -4
          IMUL BL      ; AX = 8
          RET
     Example2:
		;=========================================================================
          ; Converts a Dec, Hex, Oct or Bin ascii string to a 32 bit num value.    *
          ;=========================================================================
          ;INVOKE     AsciiBase, addr szBuff, addr Num, 10
          AsciiBase PROC Input:DWORD, Output, Base
                    pushad
                    mov esi, Input
                    mov edi, Output 
                    and dword ptr[edi], 0
                    Invoke lstrlen, Input
                    xor ecx, ecx
                    .while (eax)
                         .if byte ptr[esi+ecx] > 60h
                              sub byte ptr[esi+ecx], 57h
                         .elseif byte ptr[esi+ecx] > 40h
                              sub byte ptr[esi+ecx], 37h
                         .else
                              xor byte ptr[esi+ecx], 30h
                         .endif
                         dec eax
                         inc ecx
                    .endw
                    mov ebx, 1
                    mov esi, Input
                    add esi, ecx
                    dec esi
                    xor edx, edx
                    .while (ecx)
                         mov al, byte ptr[esi]      ; Extract byte for conversion
                         and eax, 000000ffh
                         imul eax, ebx
                         add dword ptr[edi], eax    ; Accumulate output
                         imul ebx, Base
                         dec esi
                         dec ecx 
                    .endw
                    popad
                    ret
          AsciiBase ENDP
     
     C Z S O P A 
     r ? ? r ? ? 
     CF=OF=0 when result fits into operand of IMUL.     
IN,  
	Syntax:
     	IN  AL, im.byte
          AL, DX
          AX, im.byte
          AX, DX  Input from port into AL or AX.
          Second operand is a port number. If required to access port number over 255 
          DX register should be used. 
     Example:
          IN AX, 4  ; get status of traffic lights.
          IN AL, 7  ; get status of stepper-motor.
     
     C Z S O P A 
     unchanged 
         
INC,  Syntax:INC  REG
     		   memory
      Function:   Increment. 
     
     Algorithm:
     
     	operand = operand + 1 
     
     Example:
          MOV AL, 4
          INC AL       ; AL = 5
          RET
     Z S O P A 
     r r r r r 
     CF - unchanged!     
INT,
	Syntax:
          INT  immediate byte  
          Interrupt numbered by immediate byte (0..255). 
     
     Algorithm:
     
     
	Push to stack: 
           flags register 
           CS 
           IP 
           IF = 0 
           Transfer control to interrupt procedure 
     
     Example:
          MOV AH, 0Eh  ; teletype.
          MOV AL, 'A'
          INT 10h      ; BIOS interrupt.
          RET
     C Z S O P A I 
     unchanged 0 
         
INTO, 
	Syntax:INTO  No operands 
	uction:Interrupt 4 if Overflow flag is 1. 
     
     Algorithm:
     
     	if OF = 1 then INT 4 
     
     Example:
          ; -5 - 127 = -132 (not in -128..127)
          ; the result of SUB is wrong (124),
          ; so OF = 1 is set:
          MOV AL, -5
          SUB AL, 127   ; AL = 7Ch (124)
          INTO          ; process error.
          RET
              
IRET 
	Syntax:    
	IRET  No operands Interrupt Return. 
     
     Algorithm:
          
          
     	 Pop from stack: 
          IP 
          CS 
     flags register 
     C Z S O P A 
     popped 
         
JA,  Syntax: JA  label   
	Function:Short Jump if first operand is Above second operand (as set by CMP instruction). 
	Unsigned. 
     
     Algorithm:
     
     	if (CF = 0) and (ZF = 0) then jump 
     Example:
       	title :  Test JA instruction
	
          .586
          
          	Include masm32rt.inc
          	Include \X86V2\X86.inc
          	Includelib debug.lib
          	
          ;=================Input Data===========================================
          .data
               	x 	dd 	250
          .code
          start:
          	   MOV Eax, 0
          	   MOV Eax, x
                  CMP Eax, 50
                  JA label1 ; if Al > 5 then jump(go to label1)
                  	PrintText 'Eax is not above 50'
                  JMP quit
          label1:
                  	PrintText 'Eax is above 50'
          quit:	       
          Ret	 
          end start
          ;=================Output===============================================
          ;		
          ;---------------------------------or-----------------------------------
          title :  Test JA instruction
	
          .586
          
          	Include masm32rt.inc
          	Include \X86V2\X86.inc
          	Includelib debug.lib
          	
          ;=================Input Data===========================================
          .data
          ;     	x 	dd 	240 ; 
          		x	dd	40
          .code
          start:
          	   Mov Eax, x
          	   .if Eax > 50
          			PrintText " The value in Eax > 40"
          	   .else
          		     PrintText " The value in Eax < 40"
          	   .endif
                  Ret	 
          end start
		;=================Output===============================================	
				
     C Z S O P A 
     unchanged 
JAE, 
	Syntax:       
     	JAE  label  
     Function:Short Jump if first operand is Above or Equal to second operand (as set by CMP instruction). 
     Unsigned. 
     
     Algorithm:
      
     	if CF = 0 then jump 
     Example:
        include "masm32rt.inc"
    
        MOV AL, 5
        CMP AL, 5
        JAE label1
        	  PrintText 'AL is not above or equal to 5'
        JMP quit
     label1:
        	  PrintText 'AL is above or equal to 5'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JB,
	Syntax:
     	JB  label  
     Function:Short Jump if first operand is Below second operand (as set by CMP instruction). Unsigned. 
     
     Algorithm:
     
     	if CF = 1 then jump 
     Example:
        include "masm32rt.inc"
      
        MOV AL, 1
        CMP AL, 5
        JB  label1
           PrintText 'AL is not below 5'
        JMP quit
     label1:
           PrintText 'AL is below 5'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JBE,
	Syntax:
     	JBE  label  
     Function:Short Jump if first operand is Below or Equal to second operand (as set by CMP instruction). 
     Unsigned. 
     
     Algorithm:
     
     	if CF = 1 or ZF = 1 then jump 
     Example:
        include "masm32rt.inc"
        
        MOV AL, 5
        CMP AL, 5
        JBE  label1
        	   PrintText 'AL is not below or equal to 5'
        JMP quit
     label1:
             PrintText 'AL is below or equal to 5'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JC,
	Syntax:
     	JC  label  
     Function:Short Jump if Carry flag is set to 1. 
     
     Algorithm:
      
     	if CF = 1 then jump 
     Example:
        include "masm32rt.inc"
        
        MOV AL, 255
        ADD AL, 1
        JC  label1
        	  PrintText 'no carry.'
        JMP quit
     label1:
            PrintText 'has carry.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JCXZ,
	Syntax:
     	JCXZ  label  
     Function:Short Jump if CX register is 0. 
     
     Algorithm:
     
     	if CX = 0 then jump 
     Example:
        include "masm32rt.inc"
 
        MOV CX, 0
        JCXZ label1
             PrintText 'CX is not zero.'
        JMP quit
     label1:
             PrintText 'CX is zero.'
     quit:
        RET
        
     C Z S O P A 
     unchanged 
         
JE,
	Syntax:
     	JE  label  
     Function:Short Jump if first operand is Equal to second operand (as set by CMP instruction). 
     Signed/Unsigned. 
     
     Algorithm:
      
     	if ZF = 1 then jump 
     Example:
      
        MOV AL, 5
        CMP AL, 5
        JE  label1
             PrintText 'AL is not equal to 5.'
        JMP quit
     label1:
             PrintText 'AL is equal to 5.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JG,
	Syntax:
     	JG  label  
     Function:Short Jump if first operand is Greater then second operand (as set by CMP instruction). Signed. 
     
     Algorithm:  
     
     	if (ZF = 0) and (SF = OF) then jump 
     Example:
        
        MOV AL, 5
        CMP AL, -5
        JG  label1
             PrintText 'AL is not greater -5.'
        JMP quit
     label1:
             PrintText 'AL is greater -5.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JGE,
	Syntax:
     	JGE  label  
     Function:Short Jump if first operand is Greater or Equal to second operand (as set by CMP instruction). 
     Signed. 
     
     Algorithm:
       
     	if SF = OF then jump 
     Example:
        
        MOV AL, 2
        CMP AL, -5
        JGE  label1
             PrintText 'AL < -5'
        JMP quit
     label1:
             PrintText 'AL >= -5'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JL,
	Syntax:
     	JL  label 
     Function:Short Jump if first operand is Less then second operand (as set by CMP instruction). Signed. 
     
     Algorithm:
     
     	if SF <> OF then jump 
     Example:
        
        MOV AL, -2
        CMP AL, 5
        JL  label1
             PrintText 'AL >= 5.'
        JMP quit
     label1:
             PrintText 'AL < 5.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JLE,
	Syntax:
     	JLE  label  
     Function:Short Jump if first operand is Less or Equal to second operand (as set by CMP instruction).
              Signed. 
     
     Algorithm:
      
     	if SF <> OF or ZF = 1 then jump 
     Example:
        
        MOV AL, -2
        CMP AL, 5
        JLE label1
             PrintText 'AL > 5.'
        JMP quit
     label1:
             PrintText 'AL <= 5.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JMP,
	Syntax:
     	JMP  label
     4-byte address
      Unconditional Jump. Transfers control to another part of the program. 
      4-byte address may be entered in this form: 1234h:5678h, first value is a segment second value is an offset.
     
     Algorithm:
     
     	always jump 
     Example:
       
        MOV AL, 5
        JMP label1    ; jump over 2 lines!
             PrintText 'Not Jumped!'
        MOV AL, 0
     label1:
             PrintText 'Got Here!'
        RET
     C Z S O P A 
     unchanged 
         
JNA,
	Syntax:
     	JNA  label  
     Function:Short Jump if first operand is Not Above second operand (as set by CMP instruction). Unsigned. 
     
     Algorithm:
     
     	if CF = 1 or ZF = 1 then jump 
     Example:

        MOV AL, 2
        CMP AL, 5
        JNA label1
             PrintText 'AL is above 5.'
        JMP quit
     label1:
             PrintText 'AL is not above 5.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JNAE,
	Syntax:
     	JNAE  label  
     Function:Short Jump if first operand is Not Above and Not Equal to second operand 
             (as set by CMP instruction). Unsigned. 
     
     Algorithm:
     
     
     if CF = 1 then jump 
     Example:
     
        MOV AL, 2
        CMP AL, 5
        JNAE label1
             PrintText 'AL >= 5.'
        JMP quit
     label1:
             PrintText 'AL < 5.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JNB,
	Syntax:
     	JNB  label  
     Function:Short Jump if first operand is Not Below second operand (as set by CMP instruction). Unsigned. 
     
     Algorithm:
      
     	if CF = 0 then jump 
     Example:
     
        MOV AL, 7
        CMP AL, 5
        JNB label1
             PrintText 'AL < 5.'
        JMP quit
     label1:
             PrintText 'AL >= 5.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JNBE,
	Syntax:
     	JNBE  label  
     Function:Short Jump if first operand is Not Below and Not Equal to second operand
              (as set by CMP instruction). Unsigned. 
     
     Algorithm:
     
     	if (CF = 0) and (ZF = 0) then jump 
     Example:
        
     
        MOV AL, 7
        CMP AL, 5
        JNBE label1
             PrintText 'AL <= 5.'
        JMP quit
     label1:
             PrintText 'AL > 5.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JNC,
	Syntax:
     	JNC  label 
     Function: Short Jump if Carry flag is set to 0. 
     
     Algorithm:
      
     	if CF = 0 then jump 
     Example:
    
        MOV AL, 2
        ADD AL, 3
        JNC  label1
             PrintText 'has carry.'
        JMP quit
     label1:
             PrintText 'no carry.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JNE,
	Syntax:
     	JNE  label  
     Function:Short Jump if first operand is Not Equal to second operand (as set by CMP instruction). 
     Signed/Unsigned. 
     
     Algorithm:

     
     
     if ZF = 0 then jump 
     Example:
 
     
        MOV AL, 2
        CMP AL, 3
        JNE  label1
             PrintText 'AL = 3.'
        JMP quit
     label1:
             PrintText 'Al <> 3.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JNG,
	Syntax:
       	JNG  label  
     Function:Short Jump if first operand is Not Greater then second operand (as set by CMP instruction). Signed. 
     
     Algorithm:
     
     	if (ZF = 1) and (SF <> OF) then jump 
     Example:
        include "masm32rt.inc"
     
        MOV AL, 2
        CMP AL, 3
        JNG  label1
             PrintText 'AL > 3.'
        JMP quit
     label1:
             PrintText 'Al <= 3.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JNGE,
	Syntax:
	
     	JNGE  label  
     Function: Short Jump if first operand is Not Greater and Not Equal to second operand 
               (as set by CMP instruction). Signed. 
     
     Algorithm:
       
     	if SF <> OF then jump 
     Example:
        include "masm32rt.inc"
     
        MOV AL, 2
        CMP AL, 3
        JNGE  label1
             PrintText 'AL >= 3.'
        JMP quit
     label1:
             PrintText 'Al < 3.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JNL,
	Syntax:
     	JNL  label  
     Function:Short Jump if first operand is Not Less then second operand (as set by CMP instruction). Signed. 
     
     Algorithm:
     
     	if SF = OF then jump 
     Example:
        include "masm32rt.inc"
     
        ORG 404200h
        MOV AL, 2
        CMP AL, -3
        JNL label1
             PrintText 'AL < -3.'
        JMP quit
     label1:
             PrintText 'Al >= -3.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JNLE,
	Syntax:
	
     	JNLE  label  
     Function:Short Jump if first operand is Not Less and Not Equal to second operand (as set by
      CMP instruction). Signed. 
     
     Algorithm:
     
     	if (SF = OF) and (ZF = 0) then jump 
     Example:
        include "masm32rt.inc"
     
        MOV AL, 2
        CMP AL, -3
        JNLE label1
             PrintText 'AL <= -3.'
        JMP quit
     label1:
             PrintText 'Al > -3.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JNO,
	Syntax:
	     JNO  label  
	Function:Short Jump if Not Overflow. 
     
     Algorithm:
      
     	if OF = 0 then jump 
     Example:
     ; -5 - 2 = -7 (inside -128..127)
     ; the result of SUB is correct,
     ; so OF = 0:
     
          include "masm32rt.inc"
          
          ORG 404200h
            MOV AL, -5
            SUB AL, 2   ; AL = 0F9h (-7)
          JNO  label1
              PrintText 'overflow!'
          JMP quit
          label1:
               PrintText 'no overflow.'
          quit:
            RET
     C Z S O P A 
     unchanged 
         
JNP,
	Syntax:
     	JNP  label  
     Function:Short Jump if No Parity (odd). Only 8 low bits of result are checked. Set by CMP , SUB ,
     ADD , TEST , AND , OR , XOR instructions. 
     
     Algorithm: 
     
     	if PF = 0 then jump 
     Example:
        include "masm32rt.inc"
     
        MOV AL, 00000111b   ; AL = 7
        OR  AL, 0           ; just set flags.
        JNP label1
             PrintText 'parity even.'
        JMP quit
     label1:
             PrintText 'parity odd.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JNS,
	Syntax:
     	JNS  label  
     Function:Short Jump if Not Signed (if positive). 
              Set by CMP, SUB , ADD , TEST , AND , OR ,  XOR instructions. 
     
     Algorithm:
     
     	if SF = 0 then jump 
     Example:
        include "masm32rt.inc"
     
        MOV AL, 00000111b   ; AL = 7
        OR  AL, 0           ; just set flags.
        JNS label1
             PrintText 'signed.'
        JMP quit
     label1:
             PrintText 'not signed.'
     quit:
        RET
     C Z S O P A 
     unchanged 

         
JNZ,
	Syntax:
     	JNZ  label  
     Function:Short Jump if Not Zero (not equal). Set by CMP, SUB , ADD , TEST , AND , OR ,  XOR instructions. 
     
     Algorithm:
      
     	if ZF = 0 then jump 
     Example1:
        include "masm32rt.inc"
     
        MOV AL, 00000111b   ; AL = 7
        OR  AL, 0           ; just set flags.
        JNZ label1
             PrintText 'zero.'
        JMP quit
     label1:
             PrintText 'not zero.'
     quit:
        RET
	;__________________________________________________________________
	Example2:
		title :  Adds 5 bytes

          .586
          
          	Include masm32rt.inc
          	Include \X86V2\X86.inc
          	Includelib debug.lib
          	
          ;=================Input Data====================================
          .data
               	szData     db  15h, 12h, 25h, 1Fh, 2Bh
               	szSum	 db  0
               	
          .code
          ;--------------Input Code to CPU Execute------------------------
          start:
              		Mov Ebx, Offset szData ; Ebx = addres of szData	  
          		Mov Ecx, SIZEOF szData ; loop counter
          		Mov AL, 0
          
          back:
          		Add Al, [Ebx]	  ; Al =AL + Value at address in Ebx
          		Inc Ebx		  ; Increment by one 
          		Dec Ecx
          		Jnz back
          		
          		Mov szSum, al	
          		PrintHex szSum	; szsum = 96
          Ret	 
          end start
          ;=================Output=========================================

     C Z S O P A 
     unchanged 
         
JO,
	Syntax:
     	JO  label  
     Function:Short Jump if Overflow. 
     
     Algorithm:
      
     	if OF = 1 then jump 
     Example:
     ; -5 - 127 = -132 (not in -128..127)
     ; the result of SUB is wrong (124),
     ; so OF = 1 is set:
     
     include "masm32rt.inc"
          
            MOV AL, -5
            SUB AL, 127   ; AL = 7Ch (124)
          JO  label1
              PrintText 'no overflow.'
          JMP quit
          label1:
              PrintText 'overflow!'
          quit:
            RET
     C Z S O P A 
     unchanged 
         
JP,
	Syntax:
     	JP  label  
     Function:Short Jump if Parity (even). Only 8 low bits of result are checked. 
     	    Set by CMP, SUB , ADD , TEST , AND , OR ,  XOR instructions. 
     
     Algorithm:
     
     	if PF = 1 then jump 
     Example:
        include "masm32rt.inc"
     
        MOV AL, 00000101b   ; AL = 5
        OR  AL, 0           ; just set flags.
        JP label1
             PrintText 'parity odd.'
        JMP quit
     label1:
             PrintText 'parity even.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JPE,
	Syntax:
     	JPE  label  
     Function:Short Jump if Parity Even. Only 8 low bits of result are checked. 
     	    Set by CMP, SUB , ADD , TEST , AND , OR ,  XOR instructions. 
     
     Algorithm:
       
     	if PF = 1 then jump 
     Example:
        include "masm32rt.inc"
     
        ORG 404200h
        MOV AL, 00000101b   ; AL = 5
        OR  AL, 0           ; just set flags.
        JPE label1
             PrintText 'parity odd.'
        JMP quit
     label1:
             PrintText 'parity even.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JPO,
	Syntax:
     	JPO  label  
     Function;Short Jump if Parity Odd. Only 8 low bits of result are checked. 
     	Set by CMP, SUB , ADD , TEST , AND , OR , XOR instructions. 
     
     Algorithm: 
     
     	if PF = 0 then jump 
     Example:
        include "masm32rt.inc"
     
        MOV AL, 00000111b   ; AL = 7
        OR  AL, 0           ; just set flags.
        JPO label1
             PrintText 'parity even.'
        JMP quit
     label1:
             PrintText 'parity odd.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
JS,
	Syntax:
     	JS  label  
     Fuction:Short Jump if Signed (if negative). Set by CMP, SUB , ADD , TEST , AND , OR , XOR instructions. 
     
     Algorithm:
       
     	if SF = 1 then jump 
     Example1:
             include "masm32rt.inc"
               
   
             MOV AL, 10000000b   ; AL = -128
             OR  AL, 0           ; just set flags.
             JS label1
                  PrintText 'not signed.'
             JMP quit
          label1:
                  PrintText 'signed.'
          quit:
             RET
	
     C Z S O P A 
     unchanged 
         
JZ,
	Syntax:
     	JZ  label  
     Function: Short Jump if Zero (equal). Set by CMP, SUB ,  ADD , TEST , AND , OR , XOR instructions. 
     
     Algorithm:
     
     	if ZF = 1 then jump 
     Example:
        include "masm32rt.inc"
     

        MOV AL, 5
        CMP AL, 5
        JZ  label1
             PrintText 'AL is not equal to 5.'
        JMP quit
     label1:
             PrintText 'AL is equal to 5.'
     quit:
        RET
     C Z S O P A 
     unchanged 
         
LAHF,
	Syntax:
     	LAHF  No operands 
     Function:Load AH from 8 low bits of Flags register. 
     
     Algorithm:
          
          AH = flags register
          
          AH bit:   7    6   5    4   3    2   1    0
             	   [SF] [ZF] [0] [AF] [0] [PF] [1] [CF]
     
     bits 1, 3, 5 are reserved. 
     
     C Z S O P A 
     unchanged 
         
LDS,
	Syntax:
     	LDS  REG, memory  
     Function:Load memory double word into word register and DS. 
     
     Algorithm:
     
          REG = first word 
          DS = second word 
     
     Example: 
        
          ORG 404200h
          
          LDS AX, m
          
          RET
          
          m  DW  1234h
             DW  5678h
          
          END
        
     AX is set to 1234h, DS is set to 5678h. 
     
     C Z S O P A 
     unchanged 
         
LEA,
	Syntax:
     	LEA  REG, memory  
     Function:Load Effective Address. 
     
     Algorithm: 
     
     	REG = address of memory (offset) 
     
     Example: 
     
          MOV BX, 35h
          MOV DI, 12h
     	LEA SI, [BX+DI]    ; SI = 35h + 12h = 47h 
     
     Note: The integrated 8086 assembler automatically replaces LEA with a more efficient MOV where possible. 
     For example: 
     
          ORG 404200h
          LEA AX, m       ; AX = offset of m
          RET
          m  dw  1234h
          END
       
     C Z S O P A 
     unchanged 
         
LES,
	Syntax:
     	LES  REG, memory  
     Function:Load memory double word into word register and ES. 
     
     Algorithm:  
     
          REG = first word 
          ES = second word 
     
     Example: 
     
     
     ORG 404200h
     
          LES AX, m
          
          RET
          
          m  DW  1234h
             DW  5678h
          
          END
     
     AX is set to 1234h, ES is set to 5678h. 
     
     C Z S O P A 
     unchanged 
         
LODSB,
	Syntax:
     	LODSB  No operands 
     Funcion:Load byte at DS:[SI] into AL. Update SI.
     
     Algorithm:      
          AL = DS:[SI]
          
          if DF = 0 then 
          	SI = SI + 1 
          else 
          	SI = SI - 1 
     Example: 
          
          ORG 404200h
          
          LEA SI, a1
          MOV CX, 5
          MOV AH, 0Eh
          
          m: LODSB
          INT 10h
          LOOP m
          
          RET
          
          a1 DB 'H', 'e', 'l', 'l', 'o'
     C Z S O P A 
     unchanged 
         
LODSW,
	Syntax:
     LODSW  No operands 
     Function:Load word at DS:[SI] into AX. Update SI.
     
     Algorithm: 
      
          AX = DS:[SI]
          
          if DF = 0 then 
          	SI = SI + 2 
          else 
          	SI = SI - 2 
     Example: 
     
          ORG 404200h
          
          LEA SI, a1
          MOV CX, 5
          
          REP LODSW   ; finally there will be 555h in AX.
          
          RET
     
     a1 dw 111h, 222h, 333h, 444h, 555h
     C Z S O P A 
     unchanged 
         
LOOP,
	Syntax:
     	LOOP  label  
     Function:Decrease CX, jump to label if CX not zero. 
     
     Algorithm: 
        
          CX = CX - 1
          
          if CX <> 0 then 
          jump 
          else 
     no jump, continue 
     Example1:
        include "masm32rt.inc" 
     
        .code
        start:
                MOV CX, 5
        label1:
                PrintText'loop!'
                LOOP label1
                RET
        end start
               
        ===========Or use while loop ============
        
        include "masm32rt.inc" 
     
        .code
        start:
                MOV CX, 5
                
                .while(CX!=0)
                	PrintText'loop!'
				Dec CX
			 .endw
                RET
        end start
	Example2:

          title :  Copying a String
          ;File name: CpyStr.asm
          
          .586
          
          	Include masm32rt.inc
          	Include \X86V2\X86.inc
          	Includelib debug.lib
          	
          ;=================Input Data====================================
          .data
               	szSource     db  "The is the source string",0
               	szDest       db  Sizeof szSource dup(0)
               	
          .code
          ;--------------Input Code to CPU Execute------------------------
          start:
              		mov  esi,0			; index register
          		mov  ecx,SIZEOF szSource	; loop counter
          L1:
          		mov  al,szSource[esi]	; get a character from source
          		mov  szDest[esi],al		; store it in the target
          		inc  esi				; move to next character
          		loop L1	
          		PrintString szDest	
          Ret	 
          end start
          ;=================Output=========================================
     Example3:
		title :  Copying a String
          ;File name: CpyStr.asm
          
          .586
          
          	Include masm32rt.inc
          	Include \X86V2\X86.inc
          	Includelib debug.lib
          	
          ;=================Input Data====================================
          .data
               	szSource     db  "The is the source string",0
               	szDest       db  Sizeof szSource dup(0)
               	
          .code
          ;--------------Input Code to CPU Execute------------------------
          start:
				;copy string from source to destination
          		Invoke lstrcpy, addr szDest, addr szSource
          		PrintString szDest
          		
              		Ret	 
          end start
          ;=================Output=========================================

	  
     C Z S O P A 
     unchanged 
         
LOOPE,
	Syntax:
     	LOOPE  label  
     Function: Decrease CX, jump to label if CX not zero and Equal (ZF = 1). 
     
     Algorithm: 
       
         	CX = CX - 1
          
          if (CX <> 0) and (ZF = 1) then 
          	jump 
          else 
     no jump, continue 
     Example:
     ; Loop until result fits into AL alone,
     ; or 5 times. The result will be over 255
     ; on third loop (100+100+100),(64h+C8h+12Ch)
     ; ax=012C=> ah=01
     ; so loop will quit.
     
         include "masm32rt.inc"
          .code    
                 start:
          	   MOV AX, 0
                  MOV CX, 5
          label1:
                  PrintText '*'
                  ADD AX, 100
                  CMP AH, 0 ; if AH =0 then go to label1
                            ; if AH !=0 then don't go to label1 
                  LOOPE label1
                  RET
          end start
     C Z S O P A 
     unchanged 
         
LOOPNE,
	LOOPNE  label  Decrease CX, jump to label if CX not zero and Not Equal (ZF = 0). 
     
     Algorithm: 
     
     
     CX = CX - 1
     
     if (CX <> 0) and (ZF = 0) then 
     	jump 
     else 
     no jump, continue 
     Example:
     ; Loop until '7' is found,
     ; or 5 times.
     title :  Test LOOPNE instruction
	
     .586
     
     	Include masm32rt.inc
     	Include \X86V2\X86.inc
     	Includelib debug.lib
     	
     ;=================Input Data===========================================
     .data   	 
     	   v1 db 9, 8, 7, 6, 5
     .code
     start:
             MOV SI, 0
             MOV CX, 5
     label1:
             PrintText '*'
             MOV AL, v1[SI]
             INC SI         ; next byte (SI=SI+1).
             CMP AL, 7	   ; if al=7 don't go to label1
             LOOPNE label1
             RET
            
     end start
	;=================Output===============================================     
	C Z S O P A 
     unchanged 
LOOPNZ,
	Syntax:LOOPNZ label  

	Function: Decrease CX, jump to label if CX not zero and ZF = 0. 
     
     Algorithm: 
     
     
     CX = CX - 1
     
     if (CX != 0) and (ZF = 0) then 
     jump 
     else 
     no jump, continue 
     Example1:
     ; Loop until '7' is found,
     ; or 5 times.
     
        include "masm32rt.inc"
     
        MOV SI, 0
        MOV CX, 5
     label1:
        PrintText '*'
        MOV AL, v1[SI]
        INC SI         ; next byte (SI=SI+1).
        CMP AL, 7
        LOOPNZ label1
        RET
        v1 db 9, 8, 7, 6, 5
	Example2:
	   title : Scanning for a Positive Value
     
     .586
     
     	Include masm32rt.inc
     	Include \X86V2\X86.inc
     	Includelib debug.lib
     	
     ;=================Input Data=========================================
     
     .data
     	array  SWORD  -3,-6,-1,-10,10,30,40,4 ; -3
     	sentinel SWORD  0
     .code
     start:
     
     	mov esi,OFFSET array
     	mov ecx,LENGTHOF array
     
     next:
     
     	test WORD PTR [esi],8000h		; test sign bit
     
     	pushfd						; push flags on stack
     	add  esi,TYPE array
     	popfd						; pop flags from stack
     	dec ecx
     	loopnz next 					; continue loop
     	jnz  quit						; none found
     	sub  esi,TYPE array				; ESI points to value
     
     quit:
     	movsx eax,WORD PTR[esi]			; display the value
     	PrintDec eax
     	
     	ret
     end start


     C Z S O P A 
     unchanged 
         
LOOPZ, 
	Syntax: LOOPZ label  

	Function:Decrease CX, jump to label if CX not zero and ZF = 1. 
     
     Algorithm: 
     
     
     CX = CX - 1
     
     if (CX <> 0) and (ZF = 1) then 
     jump 
     else 
     no jump, continue 
     Example:
     ; Loop until result fits into AL alone,
     ; or 5 times. The result will be over 255
     ; on third loop (100+100+100),
     ; so loop will quit.
     
        	  MOV AX, 0
        	  MOV CX, 5
     label1:
            PrintText '*'
            ADD AX, 100
            CMP AH, 0
            LOOPZ label1
            RET
     C Z S O P A 
     unchanged 
         
MOV, 
	Function: Move(copy) the value from source(src) to dest.

     Syntax:   MOV  REG, memory ; MOV EAX, x
               memory, REG	  ; MOV X, EAX
               REG, REG		  ; MOV EAX, ESI
               memory, immediate; MOV [EBX], 12345678H
               REG, immediate   ; MOV EAX, 98765432H
              ;---------------------------------------- 
               SREG, memory	  ; MOV DS, X
               memory, SREG	  ; MOV y, DS
               REG, SREG		  ; MOV EDX, AX 
               SREG, REG  Copy operand2 to operand1.
               
     
     The MOV instruction cannot: set the value of the CS and IP registers. 
     copy value of one segment register to another segment register (should copy 
     to general register first). 
     copy immediate value to segment register (should copy to general register first). 
     
     Algorithm:
     
     	operand1 = operand2 
     	
     Example1 and Question :
     
          title :  Mov

          .586
          
          	Include masm32rt.inc
          	Include \X86V2\X86.inc
          	Includelib debug.lib
          	
          ;=================Input Data an code==================================
          .data
               	x       dd	0
               	y       dd	0
               	r	   dd	0
          .code
          
          start:
              	   ;Mov Eax, x
          	  	MOV EAX, 12345678h	; set EAX = 12345678h 
          		PrintHex Eax      	; Print the value in Eax to Output screen    
          		PrintHex Ax	   	; Ax=?
          		PrintHex Al
          		PrintHex AH
          		
          		MOV EDX, EAX      	; Edx=   
          	
                    MOV CL, 'A'       	; CL = 41h (ASCII code).
                    MOV CH, 56h 	   	; CL = 56h ; CX= ?
                    MOV EBX, offset x 	; EBX = offset addr of x-->00403000h
                    DbgDump offset x,16 ; See the value at addr "x"
          	     MOV [EBX], CX     	; DS:EBX = CH ;00403000h=  ?
          	     DbgDump offset x,16 ; DS:EBX+1=CL ;00403001h=  ?
          	                       	; Move the value in CX to address  in EBX
              		RET               	; returns to operating system.
          	
          Ret	 
          end start
          ;=================Output===============================================
     Example2:
			title :  Pointers

               .586
               
               	Include masm32rt.inc
               	Include \X86V2\X86.inc
               	Includelib debug.lib
               	
               ;=================Input Data====================================
               ;TITLE                        
               
               .data
               arrayB BYTE  10h,20h,30h
               arrayW WORD  1,2,3
               arrayD DWORD 4,5,6
               
               ; Create some pointer variables.

               ptr1 PBYTE  arrayB
               ptr2 PWORD  arrayW
               ptr3 PDWORD arrayD
               
               .code
               start:
               ; Use the pointers to access data.
               	mov ecx, 3
               	mov esi,ptr1
               	.while ecx!=0
                    	mov al,[esi]		; 10h, 20h, 30h
                    	PrintHex al
                    	inc esi
                    	dec ecx
                    .endw
               	mov esi,ptr2
               	mov ax,[esi]		; 1
               	mov esi,ptr3
               	mov eax,[esi]		; 4
               
               	ret
               end start
	Example3:
		     title :  Scaling an Array Index

               .586
               
               	Include masm32rt.inc
               	Include \X86V2\X86.inc
               	Includelib \X86V2\X86.lib
               	
               ;=================Input Data====================================
               ;TITLE                        
               
               .data
               arrayB BYTE  0,1,2,3,4,5
               arrayW WORD  0,1,2,3,4,5
               arrayD DWORD 0,1,2,3,4,5
               
               .code
               start:
               
               	mov esi, 2
               	mov al,arrayB[esi*TYPE arrayB]	; al = 02
               	mov esi, 4
               	mov bx,arrayW[esi*TYPE arrayW]	; bx = 0004
               	mov esi, 5
               	mov edx,arrayD[esi*TYPE arrayD]	; edx = 00000005
               	PrintHex al
               	PrintHex bx
               	PrintHex edx
               	ret
               end start
		
     Flags:
     
     C Z S O P A 
     unchanged 
         
MOVSB,
     MOVSB  No operands Copy byte at DS:[SI] to ES:[DI]. Update SI and DI.
     
     Algorithm: 
     
     
     	ES:[DI] = DS:[SI]
     
     if DF = 0 then 
          SI = SI + 1 
          DI = DI + 1 
     else 
          SI = SI - 1 
          DI = DI - 1 
     Example:
     .data
     a1 DB 1,2,3,4,5
     a2 DB 5 DUP(0)
	.code
	start:
          CLD
          LEA SI, a1
          LEA DI, a2
          MOV CX, 5
          REP MOVSB
        
          RET
     end start
         C Z S O P A 
     unchanged 
         
MOVSW,
     Syntax: MOVSW  No operands 
	Function:Copy word at DS:[SI] to ES:[DI]. Update SI and DI.
     
     Algorithm: 
     
     
     ES:[DI] = DS:[SI]
     
     if DF = 0 then 
          SI = SI + 2 
          DI = DI + 2 
     else 
          SI = SI - 2 
          DI = DI - 2 
     Example:
     .data
          a1 DW 1,2,3,4,5
          a2 DW 5 DUP(0)
	.code
	start:
          CLD
          LEA SI, a1
          LEA DI, a2
          MOV CX, 5
          REP MOVSW
     
     RET
     end start
     
     C Z S O P A 
     unchanged 
MOVS, - Move String (Byte or Word)

     Usage:  MOVS    dest,src
             MOVSB
             MOVSW
             MOVSD  (386+)
     
     Modifies flags: None
     
     Copies data from addressed by DS:SI (even if operands are given) to
     the location ES:DI destination and updates SI and DI based on the
     size of the operand or instruction used.  SI and DI are incremented
     when the Direction Flag is cleared and decremented when the Direction
     Flag is Set.  Use with REP prefixes.
     
                              Clocks                 Size
     Operands         808x  286   386   486          Bytes
     dest,src          18    5     7     7             1   (W88=26)
     
     A4 MOVS m8, m8 Move byte at address DS:(E)SI to address ES:(E)DI
     A5 MOVS m16, m16 Move word at address DS:(E)SI to address ES:(E)DI
     A5 MOVS m32, m32 Move doubleword at address DS:(E)SI to address ES:(E)DI
     A4 MOVSB Move byte at address DS:(E)SI to address ES:(E)DI
     A5 MOVSW Move word at address DS:(E)SI to address ES:(E)DI
     A5 MOVSD Move doubleword at address DS:(E)SI to address ES:(E)DI
MOVSX, - Move with Sign Extend (386+)


     Usage:  MOVSX   dest,src
     
     Modifies flags: None
     
     Copies the value of the source operand to the destination register
     with the sign extended.
     
                              Clocks                 Size
     Operands         808x  286   386   486          Bytes
     reg,reg           -     -     3     3             3
     reg,mem           -     -     6     3            3-7
     
     0F BE / r MOVSX r16,r/m8 Move byte to word with sign-extension
     0F BE / r MOVSX r32,r/m8 Move byte to doubleword, sign-extension
	0F BF / r MOVSX r32,r/m16 Move word to doubleword, sign-extension  
	 
MOVZX, - Move with Zero Extend (386+)


Usage:  Syntax:MOVZX   dest,src

        Flags:Modifies flags: None
     
          unction:FCopies the value of the source operand to the destination register
          with the zeroes extended.
          
                                   Clocks                 Size
          Operands         808x  286   386   486          Bytes
          reg,reg           -     -     3     3             3
          reg,mem           -     -     6     3            3-7
          
          0F B6 / r MOVZX r16,r/m8 Move byte to word with zero-extension
          0F B6 / r MOVZX r32,r/m8 Move byte to doubleword, zero-extension
          0F B7 / r MOVZX r32,r/m16 Move word to doubleword, zero-extension  

	Example :
          title :  Data Transfer Examples (Movzx.asm in Console  folder)
     ; Demonstration of MOV and
     ; XCHG with direct and direct-offset operands.
     
     .586
          Include masm32rt.inc
          Include \X86V2\X86.inc
          Includelib \X86V2\X86.lib
     ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     .data
          	val1  WORD 1000h
               val2  WORD 2000h
               
               arrayB BYTE  10h,20h,30h,40h,50h
               arrayW WORD  100h,200h,300h
               arrayD DWORD 10000h,20000h
     		n      dd  0
     .code
     ;--------------Input Code to CPU Execute------------
     start:
     ;  MOVZX
     	Mov ebx, 0
     	mov bx,0A69Bh
     	movzx eax,bx		; EAX = 0000A69Bh
     	movzx edx,bl		; EDX = 0000009Bh
     	movzx cx,bl		; CX = 009Bh
     	;PrintRegs
     ; MOVSX
     	mov  bx,0A69Bh
     	movsx eax,bx		; EAX = FFFFA69Bh
     	movsx edx,bl		; EDX = FFFFFF9Bh
     	mov	 bl,7Bh
     	movsx cx,bl		; CX = 007Bh
     
     ; Memory-to-memory exchange:
     	mov ax,val1		; AX = 1000h
     	xchg ax,val2		; AX = 2000h, val2 = 1000h
     	mov val1,ax		; val1 = 2000h
     
     ; Direct-Offset Addressing (byte array):
     	Mov eax, 0
     	mov al,arrayB		; AL = 10h
     	PrintHex al
     	mov al,[arrayB+1]	; AL = 20h
     	PrintHex al
     	mov al,[arrayB+2]	; AL = 30h
     	PrintHex al
     
     ; Direct-Offset Addressing (word array):
     	mov ax,arrayW		; AX = 100h
     	mov ax,[arrayW+2]	; AX = 200h
     
     ; Direct-Offset Addressing (doubleword array):
     	mov eax,arrayD				; EAX = 10000h
     	mov eax,[arrayD+4]			; EAX = 20000h
     	mov eax,[arrayD+TYPE arrayD]	; EAX = 20000h
     
     		
     Ret	 
     end start
     ;=================Output=============================

    
MUL,
	Syntax:
	
     MUL  REG
          memory
          Unsigned multiply. 
     
     Algorithm:
       
          when operand is a byte:
          	AX = AL * operand. 
          when operand is a word:
          	(DX : AX) = AX * operand.
          when operand is a dword:
          	(EDX : Eax)= Eax * operand
           
     Example:
     	Operand is byte 
     	
          MOV AL, 200   ; AL = 0C8h
          MOV BL, 4
          MUL BL        ; AX = 0320h (800)
          RET8
          Operand is word
          
          MOV AX, 1234H ; AX = 1234H
       	MOV BX, 5678H ; BX = 5678H
       	MUL BX        ; DX:AX= 
          		 ; Dx = 0626
          		 ; Ax = 0060
       	PrintHex Dx
       	PrintHex Ax
       	===================Or=================================================
       	title :  Mul

          .586
          
          	Include masm32rt.inc
          	Include \X86V2\X86.inc
          	Includelib debug.lib
          	
        ;=================Input Data===========================================
          .data
                 x       dw	1234H
                 y       dw	5678H
                 r	     dd	0
          .code
          
          start:
              	  MOV AX, x     	   ; AX = 1234H
                 MUL y         	   ; DX:AX= 
                 
                 Mov word ptr r, Ax   ;
                 Mov Word ptr r+2, Dx ;
                 DbgDump offset x, 16 ;
                 PrintHex r    	   ; r = 06260060h
          
          	
          Ret	 
          end start
	   ;=================Output===============================================
        ; 4003000:  34 12 78 56-60 00 26 06-00 00 00 00-00 00 00 00
        ;             x     y         r 
        
        Operand is 32_bit ?
        
     C Z S O P A 
     r ? ? r ? ? 
     CF=OF=0 when high section of the result is zero.     
NEG,
	Syntax:
	
     NEG  REG
          memory
     
     Negate. Makes operand negative (two's complement). 
     
     Algorithm:
     
          Invert all bits of the operand 
          Add 1 to inverted operand 
     Example:
          MOV AL, 5   ; AL = 05h
          NEG AL      ; AL = 0FBh (-5)
          NEG AL      ; AL = 05h (5)
          RET
          
     C Z S O P A 
     r r r r r r 
         
NOP,
	Syntax:
     	NOP No operands.
     
     Algorithm: 
     
     	Do nothing
     
     Example:
          ; do nothing, 3 times:
          NOP
          NOP
          NOP
          RET
     C Z S O P A 
     unchanged 
         
NOT,
	Syntax:
	
     	NOT  REG
     	memory
     	
     Function: Invert each bit of the operand.
     
     Algorithm: 
     
          if bit is 1 turn it to 0.
          
          if bit is 0 turn it to 1.
     
     Example:
     
          MOV AL, 00011011b
          NOT AL   ; AL = 11100100b
          RET
          
     C Z S O P A 
     unchanged 
         
OR, 
	Syntax:
      OR  REG, memory
     	memory, REG
     	REG, REG
     	memory, immediate
          REG, immediate  
          
     Function:Logical OR between all bits of two operands. Result is stored in first operand.
     
     These rules apply:
               
               1 OR 1 = 1
               1 OR 0 = 1
               0 OR 1 = 1
               0 OR 0 = 0 
     
     Example:
     
          MOV AL, 'A'       ; AL = 01000001b
          OR AL, 00100000b  ; AL = 01100001b  ('a')
          RET
          
     C Z S O P A 
     0 r r 0 r ? 
         
OUT,
     Syntax:
     	OUT  im.byte, AL
     	     im.byte, AX
               DX, AL
               DX, AX  Output from AL or AX to port.
               First operand is a port number. If required to access port number over 255 
               DX register should be used. 
     
     Example:
          MOV AX, 0FFFh ; Turn on all
          OUT 4, AX     ; traffic lights.
          
          MOV AL, 100b  ; Turn on the third
          OUT 7, AL     ; magnet of the stepper-motor.
     C Z S O P A 
     unchanged 
         
POP,
     Syntax:
     	POP  REG
     		SREG
     memory  Get 16 bit value from the stack. 
     
     Algorithm:
     
     operand = SS:[SP] (top of the stack) 
     SP = SP + 2 
     
     Example1:
          MOV AX, 1234h
          PUSH AX
          POP  DX     ; DX = 1234h
          RET

	Example2:
		title : Reversing a String 

          .586
          
          	Include masm32rt.inc
          	Include \X86V2\X86.inc
          	Includelib debug.lib
          	
          ;=================Input Data=========================================
          .data
               aName BYTE "Microprocessor",0
               nameSize = ($ - aName) - 1
          
          .code
          start:  
          ; Push the name on the stack.
          	mov	ecx,nameSize
          	mov	esi,0
          
          L1:	movzx eax,aName[esi]	; get character
          	push	eax				; push on stack
          	inc	esi
          	loop L1
          ; Pop the name from the stack, in reverse,
          ; and store in the aName array.
          
          	mov	ecx,nameSize
          	mov	esi,0
          
          L2:	pop eax				; get character
          	mov	aName[esi],al		; store in string
          	inc	esi
          	loop L2
          
          ; Display the name.
          
          	mov  edx,OFFSET aName
          	PrintString aName		
          	ret
          ;---------------------------------------------------------------------
          end start

     C Z S O P A 
     unchanged 
         
POPA,
	Syntax:
          POPA No operands 
          Pop all general purpose registers DI, SI, BP, SP, BX, DX, CX, AX from the stack.
          SP value is ignored, it is Popped but not set to SP register).
     
     Note: this instruction works only on 80186 CPU and later! 
     
     Algorithm:
      
          POP DI 
          POP SI 
          POP BP 
          POP xx (SP value ignored) 
          POP BX 
          POP DX 
          POP CX 
          POP AX 
     C Z S O P A 
     unchanged 
         
POPF,
     POPF  No operands Get flags register from the stack. 
     
     Algorithm:
      
     flags = SS:[SP] (top of the stack) 
     SP = SP + 2 
     C Z S O P A 
     popped 
         
PUSH,
	Syntax:
     	PUSH  REG
     		 SREG
     		 memory
     Function:immediate  Store 16 bit value in the stack.
     
     Note: PUSH immediate works only on 80186 CPU and later! 
     
     Algorithm:
     
     
     SP = SP - 2 
     SS:[SP] (top of the stack) = operand 
     
     Example1:
          MOV AX, 1234h
          PUSH AX
          POP  DX     ; DX = 1234h
          RET
	Example2:
		title :  Reverse string

     .586
          Include masm32rt.inc
          Include \X86V2\X86.inc
          Includelib \X86V2\X86.lib
     ; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     .data
          	aName BYTE "Abraham Lincoln",0
     	     nameSize = ($ - aName) - 1
     .code
     ;--------------Input Code to CPU Execute------------
     start:
         	; Push the name on the stack.
     	DbgDump offset aName, 16
     	PrintString aName
     	mov	ecx,nameSize
     	mov	esi,0
     
     L1:	movzx eax,aName[esi]	; get character
     	push	eax				; push on stack
     	inc	esi
     	loop L1
     
     ; Pop the name from the stack, in reverse,
     ; and store in the aName array.
     
     	mov	ecx,nameSize
     	mov	esi,0
     
     L2:	pop eax				; get character
     	mov	aName[esi],al		; store in string
     	inc	esi
     	loop L2
     
     ; Display the name.
     	mov  edx,OFFSET aName
     	PrintString aName
     			
     Ret	 
     end start
;=================Output=============================

     C Z S O P A 
     unchanged 
PUSHA,         
     Syntax:PUSHA  No operands 
     Function: Push all general purpose registers AX, CX, DX, BX, SP, BP, SI, DI in the stack.
     Original value of SP register (before PUSHA) is used.
     
     Note: this instruction works only on 80186 CPU and later! 
     
     Algorithm:
          
          PUSH AX 
          PUSH CX 
          PUSH DX 
          PUSH BX 
          PUSH SP 
          PUSH BP 
          PUSH SI 
          PUSH DI 
     C Z S O P A 
     unchanged 
PUSHAD, - Push All Registers onto Stack (80188+)


     Usage:  PUSHA
             PUSHAD  (386+)
     
     Modifies flags: None
     
     Pushes all general purpose registers onto the stack in the following
     order: (E)AX, (E)CX, (E)DX, (E)BX, (E)SP, (E)BP, (E)SI, (E)DI.  The
     value of SP is the value before the actual push of SP.
     
                              Clocks                 Size
     Operands         808x  286   386   486          Bytes
     none              -     19    24    11            1
     
     60 PUSHA Push AX, CX, DX, BX, original SP, BP, SI, and DI
	60 PUSHAD Push EAX, ECX, EDX, EBX, original ESP, EBP, ESI, and 

PUSHF,
     Syntax:PUSHF  No operands 
     Function:Store flags register in the stack. 
     
     Algorithm:
     
     
     SP = SP - 2 
     SS:[SP] (top of the stack) = flags 
     C Z S O P A 
     unchanged 
PUSHFD, - Push Flags onto Stack


     Usage:  PUSHF
             PUSHFD  (386+)
     
     Modifies flags: None
     
     Transfers the Flags Register onto the stack.  PUSHF saves a 16 bit
     value while PUSHFD saves a 32 bit value.
     
                              Clocks                 Size
     Operands         808x  286   386   486          Bytes
     none            10/14   3     4     4             1
     none  (PM)        -     -     4     3             1
     
     9C PUSHF Push lower 16 bits of EFLAGS
     9C PUSHFD Push EFLAGS
         
RCL,
	Syntax:
     RCL  memory, immediate
          REG, immediate
          
          memory, CL
     	REG, CL  
     	
     Function: Rotate operand1 left through Carry Flag. The number of rotates is set by operand2. 
     When immediate is greater then 1, assembler generates several RCL xx, 1 instructions because 
     8086 has machine code only for this instruction (the same principle works for all other shift/rotate 
     instructions). 
     
     Algorithm:
     
     
     shift all bits left, the bit that goes off is set to CF and previous value of CF is inserted to the 
     right-most position. 
     
     Example:
     STC               ; set carry (CF=1).
     MOV AL, 1Ch       ; AL = 00011100b
     RCL AL, 1         ; AL = 00111001b,  CF=0.
     RET
     C O 
     r r 
     OF=0 if first operand keeps original sign.     
RCR,
     Syntax:RCR  memory, immediate
    			  REG, immediate
     
                 memory, CL
                  REG, CL  
     Function:Rotate operand1 right through Carry Flag. The number of rotates is set by operand2. 
     
     Algorithm:
     
     
     shift all bits right, the bit that goes off is set to CF and previous value of CF is inserted to the 
     left-most position. 
     
     Example:
          STC               ; set carry (CF=1).
          MOV AL, 1Ch       ; AL = 00011100b
          RCR AL, 1         ; AL = 10001110b,  CF=0.
          RET
     C O 
     r r 
     OF=0 if first operand keeps original sign.     
REP,
    Syntax:REP  chain instruction
    Function:Repeat following MOVSB, MOVSW, LODSB, LODSW, STOSB, STOSW instructions CX times. 
     
     Algorithm:
     
     check_cx:
     
     if CX <> 0 then 
     	do following chain instruction 
     	CX = CX - 1 
     	go back to check_cx 
     else 
     	quit from REP cycle 
     Z 
     r 
REPE,         
     Syntax:REPE  chain instruction
     
     Function: Repeat following CMPSB, CMPSW, SCASB, SCASW instructions while ZF = 1 (result is Equal), 
     maximum CX times. 
     
     Algorithm:
     
     check_cx:
     
     if CX <> 0 then 
     	do following chain instruction 
     	CX = CX - 1 
     if ZF = 1 then: 
     	go back to check_cx 
     else 
     	quit from REPE cycle 
     else 
     	quit from REPE cycle 
     example:
  
    
     Z 
     r 
REPNE,         
     Syntax:REPNE  chain instruction
     Function;Repeat following CMPSB, CMPSW, SCASB, SCASW instructions while ZF = 0 (result is Not Equal), 
     maximum CX times. 
     
     Algorithm:a
     
     check_cx:
     
     if CX <> 0 then 
     	do following chain instruction 
     CX = CX - 1 
     if ZF = 0 then: 
     	go back to check_cx 
     else 
     	quit from REPNE cycle 
     else 
     	quit from REPNE cycle 
     Z 
     r 
         
REPNZ,

     Syntax:REPNZ  chain instruction
     Function:Repeat following CMPSB, CMPSW, SCASB, SCASW instructions while ZF = 0 (result is Not Zero), 
     maximum CX times. 
     
     Algorithm:
     
     check_cx:
     
     if CX <> 0 then 
     	do following chain instruction 
     	CX = CX - 1 
     if ZF = 0 then: 
     	go back to check_cx 
     else 
     	quit from REPNZ cycle 
     else 
     	quit from REPNZ cycle 
     Z 
     r 
         
REPZ,
     Syntax:REPZ  chain instruction
      Repeat following CMPSB, CMPSW, SCASB, SCASW instructions while ZF = 1 (result is Zero), 
      maximum CX times. 
     
     Algorithm:
     
     check_cx:
          
          if CX <> 0 then 
          	do following chain instruction 
          	CX = CX - 1 
          if ZF = 1 then: 
          	go back to check_cx 
          else 
          	quit from REPZ cycle 
          else 
          	quit from REPZ cycle 
     Z 
     r 
         
RET,
     Syntax:RET  No operands
     or even immediate Return from near procedure. 
     
     Algorithm:
     
     
          Pop from stack: 
          IP 
          if immediate operand is present: SP = SP + operand 
     Example:
     
          
          CALL p1
          
          ADD AX, 1
          
          RET         ; return to OS.
          
          p1 PROC     ; procedure declaration.
              MOV AX, 1234h
              RET     ; return to caller.
          p1 ENDP
     C Z S O P A 
     unchanged 
         
RETF,
     Syntax:RETF  No operands
     or even immediate Return from Far procedure. 
     
     Algorithm:
     
     	Pop from stack: 
     	IP 
     	CS 
     	if immediate operand is present: SP = SP + operand 
     C Z S O P A 
     unchanged 
         
ROL,
     Syntax:ROL  memory, immediate
                 REG, immediate
               
                 memory, CL
                 REG, CL  Rotate operand1 left. The number of rotates is set by operand2. 
     
     Algorithm:
          
          shift all bits left, the bit that goes off is set to CF and the same bit is inserted to the right-most position. 
          Example:
          MOV AL, 1Ch       ; AL = 00011100b
          ROL AL, 1         ; AL = 00111000b,  CF=0.
          RET
     C O 
     r r 
     OF=0 if first operand keeps original sign.     
,ROR 
     Syntax:ROR  memory, immediate
                 REG, immediate
               
                 memory, CL
     		  REG, CL  Rotate operand1 right. The number of rotates is set by operand2. 
     
     Algorithm:
     
          shift all bits right, the bit that goes off is set to CF and the same bit is inserted to 
          the left-most position. 
     Example:
          MOV AL, 1Ch       ; AL = 00011100b
          ROR AL, 1         ; AL = 00001110b,  CF=0.
          RET
     C O 
     r r 
     OF=0 if first operand keeps original sign.     
SAHF,
     Syntax:SAHF  No operands 
     Function:Store AH register into low 8 bits of Flags register.
     Algorithm:
        
     flags register = AH
     
     
     AH bit:   7    6   5    4   3    2   1    0
             [SF] [ZF] [0] [AF] [0] [PF] [1] [CF]
     
     bits 1, 3, 5 are reserved. 
     
     C Z S O P A 
     r r r r r r 
         
SAL,
     Syntax:SAL  memory, immediate
     		  REG, immediate
     
                 memory, CL
                 REG, CL  Shift Arithmetic operand1 Left. The number of shifts is set by operand2. 
     
     Algorithm:
     
               Shift all bits left, the bit that goes off is set to CF. 
     		Zero bit is inserted to the right-most position. 
     Example:
          MOV AL, 0E0h      ; AL = 11100000b
          SAL AL, 1         ; AL = 11000000b,  CF=1.
          RET
     C O 
     r r 
     OF=0 if first operand keeps original sign.     
SAR,
     Syntax:SAR  memory, immediate
     		  REG, immediate
     
     memory, CL
     REG, CL  Shift Arithmetic operand1 Right. The number of shifts is set by operand2. 
     
     Algorithm:
      
     Shift all bits right, the bit that goes off is set to CF. 
     The sign bit that is inserted to the left-most position has the same value as before shift. 
     Example:
          MOV AL, 0E0h      ; AL = 11100000b
          SAR AL, 1         ; AL = 11110000b,  CF=0.
          
          MOV BL, 4Ch       ; BL = 01001100b
          SAR BL, 1         ; BL = 00100110b,  CF=0.
          
          RET
     C O 
     r r 
     OF=0 if first operand keeps original sign.     
SBB,     
	Syntax:SBB  REG, memory
                 memory, REG
                 REG, REG
                 memory, immediate
     		  REG, immediate  Subtract with Borrow. 
     
     Algorithm:
     
     	operand1 = operand1 - operand2 - CF 
     
     Example:
STC,     
	Syntax:STC
          MOV AL, 5
          SBB AL, 3    ; AL = 5 - 3 - 1 = 1
          
          RET
     C Z S O P A 
     r r r r r r 
         
SCASB,     
	Syntax:SCASB  No operands 
	Function:Compare bytes: AL from ES:[DI]. 
     
     Algorithm:   
          
          AL - ES:[DI]
          
          set flags according to result:
          OF, SF, ZF, AF, PF, CF
          
          if DF = 0 then 
          	DI = DI + 1 
          else 
          	DI = DI - 1 
     C Z S O P A 
     r r r r r r 
         
SCASW,    
	Syntax: SCASW  No operands 
	Function:Compare words: AX from ES:[DI]. 
     
     Algorithm: 
          
          AX - ES:[DI]
          
          set flags according to result:
          OF, SF, ZF, AF, PF, CF
          
          if DF = 0 then 
          	DI = DI + 2 
          else 
     		DI = DI - 2 
     C Z S O P A 
     r r r r r r 
         
SHL,    
	Syntax: SHL  memory, immediate
     		   REG, immediate
     
                  memory, CL
     		   REG, CL  
     Function:Shift operand1 Left. The number of shifts is set by operand2. 
     
     Algorithm:
     
          Shift all bits left, the bit that goes off is set to CF. 
          Zero bit is inserted to the right-most position. 
     Example:
          MOV AL, 11100000b
          SHL AL, 1         ; AL = 11000000b,  CF=1.
          
          RET
     C O 
     r r 
     OF=0 if first operand keeps original sign.     
SHR,     
	Syntax:SHR  memory, immediate
     	       REG, immediate
     
     		  memory, CL
     		  REG, CL  
     Function: Shift operand1 Right. The number of shifts is set by operand2. 
     
     Algorithm:
            
          Shift all bits right, the bit that goes off is set to CF. 
          Zero bit is inserted to the left-most position. 
     Example:
          MOV AL, 00000111b
          SHR AL, 1         ; AL = 00000011b,  CF=1.
          
          RET
     C O 
     r r 
     OF=0 if first operand keeps original sign.     
STC,     
	Suntax:STC  No operands 
	Function:Set Carry flag. 
     
     Algorithm: 
     
     CF = 1 
     
     C 
     1 
        
STD,   
  
	Syntax:STD  No operands 
	Function:Set Direction flag. SI and DI will be decremented by chain 
	instructions: CMPSB, CMPSW, LODSB, LODSW, MOVSB, MOVSW, STOSB, STOSW. 
     
     Algorithm: 
     
     DF = 1 
     
     D 
     1 
         
STI,  
	Syntax:No operands 
	Function:Set Interrupt enable flag. This enables hardware interrupts. 
     
     Algorithm: 
          
          IF = 1 
          
          I 
          1 
         
STOSB, 
		    
	Syntax:STOSB  No operands 
	Functin:Store byte in AL into ES:[DI]. Update DI.
     
     Algorithm: 
     
     
     ES:[DI] = AL
     
     if DF = 0 then 
     DI = DI + 1 
     else 
     DI = DI - 1 
     Example: 
     
     ORG 404200h
     
     LEA DI, a1
     MOV AL, 12h
     MOV CX, 5
     
     REP STOSB
     
     RET
     
     a1 DB 5 dup(0)
     C Z S O P A 
     unchanged 
         
STOSW,   
	Syntax:  
		STOSW  No operands 
	Function:Store word in AX into ES:[DI]. Update DI.
     
     Algorithm: 
     
          
          ES:[DI] = AX
          
          if DF = 0 then 
          	DI = DI + 2 
          else 
          	DI = DI - 2 
          	
     Example: 
          
          
          LEA DI, a1
          MOV AX, 1234h
          MOV CX, 5
          
          REP STOSW
          
          RET
     
     a1 DW 5 dup(0)
     C Z S O P A 
     unchanged 
         
SUB,     
	Sytax:SUB  REG, memory
                memory, REG
                REG, REG
                memory, immediate
    			 REG, immediate  Subtract. 
     
     Algorithm:
     
     	operand1 = operand1 - operand2 
     
     Example:
     
     	MOV EAX, 0
          MOV Eax, 125
          SUB Eax, 25         ; Eax = 100
          
          RET
          
     C Z S O P A 
     r r r r r r 
         
TEST,     
	Syntax:TEST  REG, memory
                  memory, REG
                  REG, REG
                  memory, immediate
    			   REG, immediate  Logical AND between all bits of two operands for flags only. 
    			   These flags are effected: ZF, SF, PF. Result is not stored anywhere.
     
     These rules apply:
     
          1 AND 1 = 1
          1 AND 0 = 0
          0 AND 1 = 0
          0 AND 0 = 0
     
     
     Example:
          MOV AL, 00000101b
          TEST AL, 1         ; ZF = 0.
          TEST AL, 10b       ; ZF = 1.
          RET
     C Z S O P 
     0 r r 0 r 
         
XCHG,
	Syntax:    
		XCHG  REG, memory
    			 memory, REG
     		 REG, REG  Exchange values of two operands. 
     
     Algorithm:
     
     	operand1 < - > operand2 
     
     Example:
          MOV AL, 5
          MOV AH, 2
          XCHG AL, AH   ; AL = 2, AH = 5
          XCHG AL, AH   ; AL = 5, AH = 2
          RET
     C Z S O P A 
     unchanged 
         
XLATB,
	Syntax:	    
	 	XLATB  No operands 
	Function:Translate byte from table.
     	    Copy value of memory byte at DS:[BX + unsigned AL] to AL register. 
     
     Algorithm:
     
     AL = DS:[BX + unsigned AL] 
     
     Example:
     
          ORG 404200h
          LEA BX, dat
          MOV AL, 2
          XLATB     ; AL = 33h
          
          RET
     
     dat DB 11h, 22h, 33h, 44h, 55h
     C Z S O P A 
     unchanged 
         
,XOR      
	Syntax:XOR REG, memory
     	      memory, REG
                REG, REG
                memory, immediate
                REG, immediate  
     Function:Logical XOR (Exclusive OR) between all bits of two operands. 
     Result is stored in first operand.
     
     These rules apply:
     
          1 XOR 1 = 0
          1 XOR 0 = 1
          0 XOR 1 = 1
          0 XOR 0 = 0
     
     
     Example:
          MOV AL, 00000111b
          XOR AL, 00000010b    ; AL = 00000101b
          RET
     C Z S O P A 
     0 r r 0 r ? 
       
     	--------------------------------------------------------------------------------
    
                  	Please report any Problem to  the following email addresses:
                              
                                      'ouk.polyvann@gmail'
                              
                              		  Thank you
                              
                              	     Ouk Polyvann    
     	=================================================================================

