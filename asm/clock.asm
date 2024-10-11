
	 
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
 ;store to ptr frst address of array
	 LDW Y, #_TBL
   LDW X, #shortPtr
	 LDW (X),Y
_checkSum	 
	 ;load into long variable value by index
	 ;LDW X, shortPtr
	 ;LDW X, ($2,X) ;LOW 16bits from table
	 ;LDW Y, #int32Item1
	 ;LDW ($2,Y),X ;store low 16bits to int32Item1
	 ;LDW X, shortPtr
	 ;LDW X, (X) ;HIGH 16bits from table
	 ;LDW (Y),X ;store high 16 bits to int32Item1
   Add32Macro  #int32Acc shortPtr
	 ;add pointer
	 LDW X, shortPtr
	 ADDW X, #4
	 LDW shortPtr, X
	 ;LDW Y, #shortPtr
	 ;LDW (Y), X ;store updated pointer
	 ;LDW X, #charCounter
	 ;LD A, (X)
	 LD A, charCounter
	 INC A
	 LD charCounter,A
	 ;LD (X), A
	 SUB A, #$40
	 JRSLE _checkSum

 
 ;Kiser, K=5
 ;---data area , checksum 1048560 or $000F_FFF0 in hex (4 bit shift)
_TBL DC.L $51, $B8, $157, $23D, $376, $510, $718, $99A, $CA2, $1036,
	 DC.L $145F, $191E, $1E73, $244C, $2A91, $31A4, $3938, $4117, $490C, $50FE,
   DC.L $58FC, $5FCA, $6916, $6A9F, $77B3, $7F03, $83B0, $8920, $8E47, $920B,
   DC.L $9425, $94E5, $94E5, $920B, $8E47, $8920, $83B0, $7F03, $77B3, $6A9F,
   DC.L $6916, $5FCA, $58FC, $50FE, $490C, $4117, $3938, $31A4, $2A91, $244C,
   DC.L $1E73, $191E, $145F, $1036, $CA2, $99A, $718, $510, $376, $23D,
	 DC.L $157, $B8, $51

