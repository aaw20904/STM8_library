
	 
  ;Author : Andrii Androsovych
	segment byte at 0000-200 'user_ram'
 
int32Acc   equ $0000
int32Item1 equ $0004  
int32Item2 equ $0008
shortVar1 equ $000c
charCounter equ $0010
shortPtr equ $0011
	segment 'rom'
		;--macro---adding two 32bit numbers
Add32Macro MACRO V1,V2
  LDW X, V1
	LDW Y, V2
	LD A, ($3,X)
	ADD A, ($3,Y)
	LD ($3,X), A ;store b0
	LD A, ($2,X)
	ADC A, ($2,Y)
	LD ($2,X), A ;store b1
	LD A, ($1,X)
	ADC A, ($1,Y)
	LD ($1,X), A ;store b2
	LD A, (X)
	ADC A, (Y)
	LD (X), A ;store b3
	MEND
;--macro---adding 16 to 32bit numbers
Add16To32Macro MACRO V16_1,V32_2
  LDW X, V16_1
	LDW Y, V32_2
	LD A, ($1,X)
	ADD A, ($3,Y)
	LD ($3,Y), A ;;store 0
	LD A, (X)
	ADC A, ($2,Y)
	LD ($2,Y), A;store 1
	LD A, ($1,Y)
	ADC A, #0
	LD ($1,Y), A ;store 2
	LD A, (Y)
	ADC A, #0;
	LD (Y), A ; store 3
	MEND

;in main:
 ;----test code BEGIN
;store to ptr frst address of array
	 LDW Y, #_TBL
   LDW shortPtr, Y

_checkSum	 
	 INC charCounter
   Add32Macro  #int32Acc shortPtr
	 ;add pointer
	 LDW X, shortPtr
	 ADDW X, #4
	 LDW shortPtr, X
   LD A, charCounter
	 SUB A, #$3f
	 JRNE _checkSum
   	 
	 ;test code END

 
;Kiser, K=5
 ;---data area , checksum 1048560 or $000F_FFF0 in hex (4 bit shift)
_TBL DC.L $1, $5, $11, $2b, $59, $a6, $121, $1dd, $2ef, $471, $680,
	 DC.L  $93d, $cc4, $1136, $16af, $1d44, $2504, $2df5, $3809,
   DC.L $432d, $4f42, $5c14, $695a, $76c9, $840e, $90c1, $9c8d,
   DC.L $a714, $aff7, $b6e3, $bba4, $be19, $be19, $bba4, $b6e3,
   DC.L  $aff7, $a714, $9c8d, $90c1, $840e, $76c9, $695a, $5c14,
   DC.L  $4f42, $432d, $3809, $2df5, $2504, $1d44, $16af, $1136,
	 DC.L $cc4, $93d, $680, $471, $2ef, $1dd, $121, $a6, $59, $2b,
	 DC.L  $11, $5, $1

