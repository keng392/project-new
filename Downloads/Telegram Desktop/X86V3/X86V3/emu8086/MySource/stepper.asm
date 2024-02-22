;STEPPER.ASM (SOURCE: Emu8086 Help option)
#start=stepper_motor.exe#
#make_bin#
#CS = 500#
#IP = 0#

; This is a sample of OUT instruction.
; It writes values to virtual I/O port
; that controls the stepper-motor.

; Try using datCCW, datCW_FS or datCCW_FS
; instead of datCW to get different
; behavior of the motor.

; set Data Segment to code:
MOV AX, CS
MOV DS, AX

MOV SI, 0
next_situation:

MOV AL, datCW[SI]
OUT 7, AL

INC SI

CMP SI, 4
JB next_situation
MOV SI, 0

JMP next_situation

; bin data for clock-wise
; half-step rotation:
datCW db 110b
      db 100b    
      db 011b
      db 010b

; bin data for counter-clock-wise
; half-step rotation:
datCCW db 011b
       db 001b    
       db 110b
       db 010b


; bin data for clock-wise
; full-step rotation:
datCW_FS db 001b
         db 011b    
         db 110b
         db 000b

; bin data for counter-clock-wise
; full-step rotation:
datCCW_FS db 100b
          db 110b    
          db 011b
          db 000b
