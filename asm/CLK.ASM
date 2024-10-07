;---clock library for STM8
;--Author: Andrii Androsovych
;! IMPORTANT NOTE. 
 ; ____  ___ __  __  
 ;|  _ \|_ _|  \/  | 
 ;| |_) || || |\/| | 
 ;|  _ < | || |  | | 
 ;|_| \_\___|_|  |_| 
 ;  instruction MUST be called when all interrupts has been configured

          ;====P R O C E D U R E===turn on clk bus
	;@peripherial8
	;TIM1-$80,TIM3-$40,TIM2/5-$20,TIM4/6-$10,UART-see datasheet,
	;SPI-$2,I2C-1
	;STACK after return +1
clkBusPeripherial1
	PUSH A
	LD A, ($04,SP)
	LD CLK_PCKENR1, A
	POP A
	RET
	;====P R O C E D U R E===turn on clk bus
	;@peripherial8
	;CAN-$80, ADC-$08, AWU-$04
	;STACK after return +1
clkBusPeripherial2
	PUSH A
	LD A, ($04,SP)
	LD CLK_PCKENR2, A
	POP A
	RET	
	;==P R O C E D U R E=="set HSI divider"
	;--@ char divider
	;STACK after return +1
clkSetHsiDivider
	;--store registers A,X,Y,CC (1+2+2+1=6Bytes)
	PUSH A
	;-read default value 
	LD A, CLK_CKDIVR
	;---clear all the hsi divider bits
	AND A, #$E7
	;--1st paprameter has offset 9 bytes
	; because A,X,Y,CC,SP has ben stored later 
	OR A, ($04,SP)
	;---update CLK_CKDIVR
	LD CLK_CKDIVR, A
	;--restore registers
	POP A
	RET
       ;=====PROCEDURE===clkSwitchToCrystalManually
       ;--IMPORTANT!-when all the interrupts has ben configured,
       ;--you must call the RIM instruction. 
       ;------
       ;--SP +0
clkSwitchToCrystalManually
	 LD A, #$B4        ;1)write HSE as a source
	 LD CLK_SWR, A
_hsi_bsy_01           ;2)wait until OSC will be ready
   BTJF CLK_ICKR, #1,  _hsi_bsy_01
wait_xtal_int
   BTJF CLK_SWCR, #3, wait_xtal_int  ;3)waiting for SWIF flag
	 BRES CLK_SWCR, #3 ;4) clear SWIF flag
	 BSET CLK_SWCR, #1;  5)execute switch ( SWEN bit)
wait_clk_swich
   BTJT CLK_SWCR, #0,wait_clk_swich ;6)waiting until switch be free (SWBSY)
	 NOP 
  RET
	 
 ;===P R O C E D U R E=switch to Crystal in automatic mode
	;--NO PARAMS 
	;STACK after return 0
clkSwitchToCrystalAuto
	PUSH A
	;1)---Enable the switching mechanism
	BSET CLK_SWCR, #1 ;SWEN
	;BSET CLK_SWCR, #2; SWIEN enable interrupt
	;2)---select source clock
	;0xE1: HSI selected as master clock source (reset value)
	;0xD2: LSI selected as master clock source (only if LSI_EN
	;option bit is set)
	;OUR CASE = 0xB4: HSE selected as master clock source
	LD A, #$B4
	LD CLK_SWR, A
	;3)waiting until clock system does 
	; switching process automatically
wait_xtal_rdy1
	BTJF CLK_SWCR, #3, wait_xtal_rdy1 
	;4) clear SWIF flag
	BRES CLK_SWCR, #3 
	POP A
	RET
	
	;==P R O C E D U R E=="set HSI divider"
	;--@ char divider
	;STACK after return +1
clkSetHsiDivider
	;--store registers A,X,Y,CC (1+2+2+1=6Bytes)
	PUSH A
	;-read default value 
	LD A, CLK_CKDIVR
	;---clear all the hsi divider bits
	AND A, #$E7
	;--1st paprameter has offset 9 bytes
	; because A,X,Y,CC,SP has ben stored later 
	OR A, ($04,SP)
	;---update CLK_CKDIVR
	LD CLK_CKDIVR, A
	;--restore registers
	POP A
	RET
	
	;======P R O C e D U R E==="set CPU divider"
	;@ char divider 
	;STACK after return +1
clkSetCpuDivider
		;--store registers A,X,Y,CC (1+2+2+1=6Bytes)
	PUSH A
	;-read default value 
	LD A, CLK_CKDIVR
	;---clear all the hsi divider bits
	AND A, #$f8
	;--1st paprameter has offset 9 bytes
	; because A,X,Y,CC,SP has ben stored later
	OR A, ($04,SP)
	;---update CLK_CKDIVR
	LD CLK_CKDIVR, A
		;--restore registers
	POP A
	RET	
	
