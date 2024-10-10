
	 
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
	 ;load into shotr variable value by index
	 LDW X, shortPtr
	 LDW X, (X) ;X=shortPtr[]
	 LDW Y, #shortVar1
	 LDW (Y), X ;shortVar=shortPtr[]
   Add16To32Macro #shortVar1,  #int32Acc
	 ;add pointer
	 LDW X, shortPtr
	 ADDW X, #2
	 LDW Y, #shortPtr
	 LDW (Y), X ;store updated pointer
	 LDW X, #charCounter
	 LD A, (X)
	 INC A
	 LD (X), A
	 SUB A, #$40
	 JRSLE _checkSum
 ;---data area, Kaiser shape, K=5 , checksum 524278 or $0007 FFF6 in hex
_TBL DC.W $ff6a,$ff3e,$ff1c,$ff0e,$ff1b,$ff4f,$ffb6
  DC.W $005b,$014b,$0291,$0439,$064a,$08cc,$0bc3,$0f31
  DC.W $1311,$175e,$1c14,$2118,$2661,$2bde,$316b
  DC.W $36f7,$3cf5,$4193,$4668, $4ac5, $4e99
  DC.W $51c6,$5436,$55e4,$56bb,$56bb,$55e4
  DC.W $5436,$51c6, $4e99, $4ac5,$4668, $4193
  DC.W $3cf5,$36f7, $316b, $2bde, $2661, $2118
  DC.W $1c14,$175e,$1311,$0f31,$0bc3,$08cc,$064a
  DC.W $0439,$0291,$014b,$005b,$ffb6,$ff4f,$ff1b,$ff0e
  DC.W $ff1c, $ff3e,$ff6a

