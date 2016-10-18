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

