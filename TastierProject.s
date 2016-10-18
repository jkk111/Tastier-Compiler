	AREA	TastierProject, CODE, READONLY

    IMPORT  TastierDiv
	IMPORT	TastierMod
	IMPORT	TastierReadInt
	IMPORT	TastierPrintInt
	IMPORT	TastierPrintIntLf
	IMPORT	TastierPrintTrue
	IMPORT	TastierPrintTrueLf
	IMPORT	TastierPrintFalse
    IMPORT	TastierPrintFalseLf
    IMPORT  TastierPrintString
    
; Entry point called from C runtime __main
	EXPORT	main

; Preserve 8-byte stack alignment for external routines
	PRESERVE8

; Register names
BP  RN 10	; pointer to stack base
TOP RN 11	; pointer to top of stack

main
; Initialization
	LDR		R4, =globals
	LDR 	BP, =stack		; address of stack base
	LDR 	TOP, =stack+16	; address of top of stack frame
	B		mainline
mainConstants
    LDR     R5, =10
    STR     R5, [R4]        ; MYCONST
    B mainConstantsLoaded
mainline
    B mainConstants
mainConstantsLoaded
    ADD     R0, PC, #4      ; string address
    BL      TastierPrintString
    B       L1
    DCB     "The constant value MYCONST is ", 0
    ALIGN
L1
    LDR     R5, [R4]        ; MYCONST
    MOV     R0, R5
    BL      TastierPrintIntLf
    LDR     R5, =5
    STR     R5, [BP,#16]    ; sum
    ADD     R0, PC, #4      ; string address
    BL      TastierPrintString
    B       L2
    DCB     "int sum equals ", 0
    ALIGN
L2
    LDR     R5, [BP,#16]    ; sum
    MOV     R0, R5
    BL      TastierPrintIntLf
    ADD     R0, PC, #4      ; string address
    BL      TastierPrintString
    B       L3
    DCB     "The value of MYCONST + sum is ", 0
    ALIGN
L3
    LDR     R5, [BP,#16]    ; sum
    LDR     R6, [R4]        ; MYCONST
    ADD     R5, R5, R6
    STR     R5, [BP,#16]    ; sum
    LDR     R5, [BP,#16]    ; sum
    MOV     R0, R5
    BL      TastierPrintIntLf
stopTest
    B       stopTest

;;;;;;;;;;;;;;;;;;;;;;;
; Stack Level: 1
;;;;;;;;;;;;;;;;;;;;;;;
; Name: sum, Kind: Variable, Type: int, Address: 0, Scope: Local, Level: 1
; Name: MYCONST, Kind: Constant, Type: int, Address: 0, Scope: Global, Level: 0
; Name: main, Kind: Procedure, Type: undefined, Address: 0, Scope: Global, Level: 0
;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;
; Stack Level: 0
;;;;;;;;;;;;;;;;;;;;;;;
; Name: MYCONST, Kind: Constant, Type: int, Address: 0, Scope: Global, Level: 0
; Name: main, Kind: Procedure, Type: undefined, Address: 0, Scope: Global, Level: 0
;;;;;;;;;;;;;;;;;;;;;;;


; Subroutine enter
; Construct stack frame for procedure
; Input: R0 - lexic level (LL)
;		 R1 - number of local variables
; Output: new stack frame

enter
	STR		R0, [TOP,#4]			; set lexic level
	STR		BP, [TOP,#12]			; and dynamic link
	; if called procedure is at the same lexic level as
	; calling procedure then its static link is a copy of
	; the calling procedure's static link, otherwise called
 	; procedure's static link is a copy of the static link 
	; found LL delta levels down the static link chain
    LDR		R2, [BP,#4]				; check if called LL (R0) and
	SUBS	R0, R2					; calling LL (R2) are the same
	BGT		enter1
	LDR		R0, [BP,#8]				; store calling procedure's static
	STR		R0, [TOP,#8]			; link in called procedure's frame
	B		enter2
enter1
	MOV		R3, BP					; load current base pointer
	SUBS	R0, R0, #1				; and step down static link chain
    BEQ     enter2-4                ; until LL delta has been reduced
	LDR		R3, [R3,#8]				; to zero
	B		enter1+4				;
	STR		R3, [TOP,#8]			; store computed static link
enter2
	MOV		BP, TOP					; reset base and top registers to
	ADD		TOP, TOP, #16			; point to new stack frame adding
	ADD		TOP, TOP, R1, LSL #2	; four bytes per local variable
	BX		LR						; return
	
	AREA	Memory, DATA, READWRITE
globals     SPACE 4096
stack      	SPACE 16384

	END