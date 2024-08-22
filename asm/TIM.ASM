;STM8 assembler TIM1, TIM2 library
;Author: Andrii Androsowych

;  _____ ___ __  __ _ 
; |_   _|_ _|  \/  / |
;   | |  | || |\/| | |
;   | |  | || |  | | |
;   |_| |___|_|  |_|_|
;                     
;=====P R O C E D U R E=='tim1BaseModeSetup'=
;===initializing TIM1 in base mode
; @prescaler16, @base16, @mode8
; After return: SP-5
;-modes can (TIM1_CR1) be ;
;-TIM_EDGE_ALIGNED ($00)
;- TIM_CENTER_ALINGN_1 ($20),
;- TIM_CENTER_ALINGN_2 ($40),
;- TIM_CENTER_ALINGN_3 ($60),
;count mode can be:
;- TIM_COUNTS_UP ($00)
;- TIM_COUNTS_DOWN ($10)
;--stack frame:
;   0   1  2 3  4    5  6  7  8 
 ;[| A |  RET |mode| base | presc| 

tim1BaseModeSetup
	;--store registers
	PUSH A
	#define _000_presH $07 ;prescaler
	#define _000_presL $08
	#define _000_baseH $05 ;base ,counter
	#define _000_baseL $06
	#define _000_mode $04  ; parameters
	;load prescaler HI firstly:
	LD A,(_000_presH,SP)
	LD TIM1_PSCRH, A
	LD A,(_000_presL,SP)
	LD TIM1_PSCRL, A
	;load base, HI first:
	LD A, (_000_baseH,SP)
	LD TIM1_ARRH, A
	LD A, (_000_baseL,SP)
	LD TIM1_ARRL, A
  ;load mod in TIM1_CR1 (p.188 ref manual)
  LD A, (_000_mode,SP)
  LD TIM1_CR1, A
	;--start timer and GO! 
	LD A, TIM1_CR1
	OR A, #$01
	LD TIM1_CR1, A
	;--restore registers
	POP A
	RET
	
;=====P R O C E D U R E=='tim1BaseModeSetupIT'=
;===initializing TIM1 in base mode with interrupts
; @prescaler16, @base16, @mode8
; After return: SP-5
;-modes can (TIM1_CR1) be ;
;-TIM_CR1_EDGE_ALIGNED ($00)
;- TIM_CR1_CENTER_ALINGN_1 ($20),
;- TIM_CR1_CENTER_ALINGN_2 ($40),
;- TIM_CR1_CENTER_ALINGN_3 ($60),
;count mode can be:
;- TIM_CR1_COUNTS_UP ($00)
;- TIM_CR1_COUNTS_DOWN ($10)
;   0   1  2 3  4    5  6  7  8 
 ;[| A |  RET |mode| base | presc| 

tim1BaseModeSetupIT
	;--store registers
	PUSH A
	#define _001_presH $07;prescaler
	#define _001_presL $08
	#define _001_baseH $05 ;base ,counter
	#define _001_baseL $06
	#define _001_mode $04  ; parameters
	;load prescaler HI firstly:
	LD A,(_001_presH,SP)
	LD TIM1_PSCRH, A
	LD A,(_001_presL,SP)
	LD TIM1_PSCRL, A
	;load base, HI first:
	LD A, (_001_baseH,SP)
	LD TIM1_ARRH, A
	LD A, (_001_baseL,SP)
	LD TIM1_ARRL, A
	;--write interrupts (p.194):
	LD A, #$01
	LD TIM1_IER, A
	;--start timer and GO! 
	LD A, TIM1_CR1
	OR A, #$01
	LD TIM1_CR1, A
	;--restore registers
	POP A
	RET

  ;--TEST PASSED!
		;===PROCEDURE 'tim1OutputCompareCh1Setup'
  ;@presc16,  
	;@base16, -> base of counter, ARRL
	;@comp16, -> capture compare CCR1 content
	;@mode8,  -> (CCMR)PIN  beheviavour: $10 active on match
							;$20 inactive on muatch $30 toggle pin
							;$40 force inactive Level $50 force active level
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
	; SP after RETURN +9
	;stack frame:
	;  0  1  2 3   4   5    6  7 8  9 A  A C
	;[v8a|A|return|prel|pol|mode|comp|base|presc]
tim1OutputCompareCh1Setup
		PUSH A
	;allocate memory
  SUBW SP, #$01	
	;-variables
	#define _002_v8a  $00 
	#define _002_prel $05
	#define _002_pol $06
	#define _002_mode $07
	#define _002_compH $08
	#define _002_compL $09
	#define _002_baseH $0A
	#define _002_baseL $0B
	#define _002_prescH $0C
	#define _002_prescL $0D
	;--disable timer
	LD A, TIM1_CR1
	AND A, #$FE;
	LD TIM1_CR1,A
	;--load comparand, Hi firstly
	LD A, (_002_compH,SP)
	LD TIM1_CCR1H, A
	LD A, (_002_compL,SP)
	LD TIM1_CCR1L, A
		;--prescaler high byte firstly
	LD A, (_002_prescH,SP)
	LD TIM1_PSCRH, A	
	LD A, (_002_prescL,SP)
	LD TIM1_PSCRL, A
	;--load base, high byte first
	LD A, (_002_baseH,SP)
	LD TIM1_ARRH, A
	LD A, (_002_baseL,SP)
	LD TIM1_ARRL, A
	;--load CCMR1
	LD A, (_002_mode,SP)
	LD TIM1_CCMR1, A
	;--polarity
	;--1) read and store 
	; content of another channels
	LD A, TIM1_CCER1
	AND A, #$F0
	LD (_002_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_002_pol,SP)
	OR A, #$01; turn on channel 1
	;--3)apply others regs
	OR A, (_002_v8a,SP)
	LD TIM1_CCER1, A
	;--turn on main channels
	LD A, #$80; MOE bit
	LD TIM1_BKR, A
	;--CR1
	LD A, (_002_prel,SP)
	LD TIM1_CR1, A
	OR A, #$01;
	LD TIM1_CR1, A
	;free memory
	ADDW SP, #$01
	POP A
	RET 
	;--TEST PASSED!
		;===PROCEDURE 'tim1OutputCompareCh2Setup'
  ;@presc16,  
	;@base16, -> base of counter, ARRL
	;@comp16, -> capture compare CCR1 content
	;@mode8,  -> (CCMR)PIN  beheviavour: $10 active on match
							;$20 inactive on muatch $30 toggle pin
							;$30 force inactive Level $50 force active level
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
	; SP after RETURN +9
	;stack frame:
	;[v8a|A|return|prel|pol|mode|comp|base|presc]
tim1OutputCompareCh2Setup
		PUSH A
		;--allocate memory
		SUBW SP , #$01
	;-variables
	#define _003_v8a $00
	#define _003_prel $05
	#define _003_pol $06
	#define _003_mode $07
	#define _003_compH $08
	#define _003_compL $09
	#define _003_baseH $0A
	#define _003_baseL $0B
	#define _003_prescH $0C
	#define _003_prescL $0D
		;--disable timer
	LD A, TIM1_CR1
	AND A, #$FE;
	LD TIM1_CR1,A
	;--load comparand, Hi firstly
	LD A, (_003_compH,SP)
	LD TIM1_CCR2H, A
	LD A, (_003_compL,SP)
	LD TIM1_CCR2L, A
		;--prescaler high byte firstly
	LD A, (_003_prescH,SP)
	LD TIM1_PSCRH, A	
	LD A, (_003_prescL,SP)
	LD TIM1_PSCRL, A
	;--load base, high byte first
	LD A, (_003_baseH,SP)
	LD TIM1_ARRH, A
	LD A, (_003_baseL,SP)
	LD TIM1_ARRL, A
	;--load CCMR2
	LD A, (_003_mode,SP)
	LD TIM1_CCMR2, A
	;--polarity
	; 1)store content of another channels
	LD A, TIM1_CCER1
	AND A, #$0F
	LD (_003_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_003_pol,SP)
	OR A, #$01; turn on channel 
	SWAP A;  A << 4
	;--3) apply another regs
	OR A, (_003_v8a,SP)
	LD TIM1_CCER1, A
	;--turn on main channels
	LD A, #$80; MOE bit
	LD TIM1_BKR, A
	;--CR1
	LD A, (_003_prel,SP)
	LD TIM1_CR1, A
	OR A, #$01;
	LD TIM1_CR1, A
	;--fre memory
	ADDW SP, #$01
	POP A
	RET
	;--TEST PASSED!
			;===PROCEDURE 'tim1OutputCompareCh3Setup'
	;@presc16,  
	;@base16, -> base of counter, ARRL
	;@comp16, -> capture compare CCR1 content
	;@mode8,  -> (CCMR)PIN  beheviavour: $10 active on match
							;$20 inactive on muatch $30 toggle pin
							;$30 force inactive Level $50 force active level
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
	; SP after RETURN +9
	;stack frame:
	;[v8a|A|return|prel|pol|mode|comp|base|presc]
tim1OutputCompareCh3Setup
		PUSH A
		;--allocate memory
		SUBW SP , #$01
	;-variables
	#define _004_v8a $00
	#define _004_prel $05
	#define _004_pol $06
	#define _004_mode $07
	#define _004_compH $08
	#define _004_compL $09
	#define _004_baseH $0A
	#define _004_baseL $0B
	#define _004_prescH $0C
	#define _004_prescL $0D
		;--disable timer
	LD A, TIM1_CR1
	AND A, #$FE;
	LD TIM1_CR1,A
	;--load comparand, Hi firstly
	LD A, (_004_compH,SP)
	LD TIM1_CCR3H, A
	LD A, (_004_compL,SP)
	LD TIM1_CCR3L, A
		;--prescaler high byte firstly
	LD A, (_004_prescH,SP)
	LD TIM1_PSCRH, A	
	LD A, (_004_prescL,SP)
	LD TIM1_PSCRL, A
	;--load base, high byte first
	LD A, (_004_baseH,SP)
	LD TIM1_ARRH, A
	LD A, (_004_baseL,SP)
	LD TIM1_ARRL, A
	;--load CCMR1
	LD A, (_004_mode,SP)
	LD TIM1_CCMR3, A
	;--polarity
	; 1)store content of another channels
	LD A, TIM1_CCER2
	AND A, #$F0
	LD (_004_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_004_pol,SP)
	OR A, #$01; turn on channel 
	;--3)apply another regs
	OR A, (_004_v8a,SP)
	LD TIM1_CCER2, A
	;--turn on main channels
	LD A, #$80; MOE bit
	LD TIM1_BKR, A
	;--CR1
	LD A, (_004_prel,SP)
	LD TIM1_CR1, A
	OR A, #$01;
	LD TIM1_CR1, A
	;--free memory
	ADDW SP, #$01
	POP A
	RET
	;--TEST PASSED!
		;===PROCEDURE 'tim1OutputCompareCh4Setup'
	;@presc16,  
	;@base16, -> base of counter, ARRL
	;@comp16, -> capture compare CCR1 content
	;@mode8,  -> (CCMR)PIN  beheviavour: $10 active on match
							;$20 inactive on muatch $30 toggle pin
							;$30 force inactive Level $50 force active level
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
	; SP after RETURN +9
	;stack frame:
	;[v16a|A|return|prel|pol|mode|comp|base|presc]
tim1OutputCompareCh4Setup
		PUSH A
		;--allocate memory
		SUBW SP , #$01
	;-variables
	#define _005_v8a $00
	#define _005_prel $05
	#define _005_pol $06
	#define _005_mode $07
	#define _005_compH $08
	#define _005_compL $09
	#define _005_baseH $0A
	#define _005_baseL $0B
	#define _005_prescH $0C
	#define _005_prescL $0D
		;--disable timer
	LD A, TIM1_CR1
	AND A, #$FE;
	LD TIM1_CR1,A
	;--load comparand, Hi firstly
	LD A, (_005_compH,SP)
	LD TIM1_CCR4H, A
	LD A, (_005_compL,SP)
	LD TIM1_CCR4L, A
		;--prescaler high byte firstly
	LD A, (_005_prescH,SP)
	LD TIM1_PSCRH, A	
	LD A, (_005_prescL,SP)
	LD TIM1_PSCRL, A
	;--load base, high byte first
	LD A, (_005_baseH,SP)
	LD TIM1_ARRH, A
	LD A, (_005_baseL,SP)
	LD TIM1_ARRL, A
	;--load CCMR
	LD A, (_005_mode,SP)
	LD TIM1_CCMR4, A
	;--polarity
; 1)store content of another channels
	LD A, TIM1_CCER2
	AND A, #$0F
	LD (_005_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_005_pol,SP)
	OR A, #$01; turn on channel 
	SWAP A;  A << 4
	;--3) apply another regs
	OR A,  (_005_v8a,SP)
	LD TIM1_CCER2, A
	;--turn on main channels
	LD A, #$80; MOE bit
	LD TIM1_BKR, A
	;--CR1
	LD A, (_005_prel,SP)
	LD TIM1_CR1, A
	OR A, #$01;
	LD TIM1_CR1, A
	;--free mem
	ADDW SP, #$01
	POP A
	RET
	;--TEST PASSED!
		;===PROCEDURE 'tim1PwmCh1Setup'
  ;@presc16,  
	;@base16, -> base of counter, ARRL
	;@comp16, -> pulse width, CCR1 content
	;@mode8,  -> (CCMR) : $60 PWM_MODE1
							       ;$70 iPWM_MODE2
						;additional:  $04 fast, $08 preload en.
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
	; SP after RETURN +9
	;stack frame:
	;[v16a|return|prel|pol|mode|comp|base|presc]
tim1PwmCh1Setup
		PUSH A
	;allocate memory
  SUBW SP, #$01	
	;-variables
	#define _002_v8a  $00 
	#define _002_prel $05
	#define _002_pol $06
	#define _002_mode $07
	#define _002_compH $08
	#define _002_compL $09
	#define _002_baseH $0A
	#define _002_baseL $0B
	#define _002_prescH $0C
	#define _002_prescL $0D
	;--disable timer
	LD A, TIM1_CR1
	AND A, #$FE;
	LD TIM1_CR1,A
	;--load comparand, Hi firstly
	LD A, (_002_compH,SP)
	LD TIM1_CCR1H, A
	LD A, (_002_compL,SP)
	LD TIM1_CCR1L, A
		;--prescaler high byte firstly
	LD A, (_002_prescH,SP)
	LD TIM1_PSCRH, A	
	LD A, (_002_prescL,SP)
	LD TIM1_PSCRL, A
	;--load base, high byte first
	LD A, (_002_baseH,SP)
	LD TIM1_ARRH, A
	LD A, (_002_baseL,SP)
	LD TIM1_ARRL, A
	;--load CCMR1
	LD A, (_002_mode,SP)
	LD TIM1_CCMR1, A
	;--polarity
	;--1) read and store 
	; content of another channels
	LD A, TIM1_CCER1
	AND A, #$F0
	LD (_002_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_002_pol,SP)
	OR A, #$01; turn on channel 1
	;--3)apply others regs
	OR A, (_002_v8a,SP)
	LD TIM1_CCER1, A
	;--turn on main channels
	LD A, #$80; MOE bit
	LD TIM1_BKR, A
	;--CR1
	LD A, (_002_prel,SP)
	LD TIM1_CR1, A
	OR A, #$01;
	LD TIM1_CR1, A
	;free memory
	ADDW SP, #$01
	POP A
	RET 
	
	
	;--TEST PASSED!
  ;===PROCEDURE 'tim1PwmCh2Setup'
  ;@presc16,  
	;@base16, -> base of counter, ARRL
	;@comp16, ->  pulse width, CCR1 content
	;@mode8,  -> (CCMR) : $60 PWM_MODE1
							       ;$70 iPWM_MODE2
						;additional:  $04 fast, $08 preload en.
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
	;SP after RETURN +9
	;stack frame:
	;[v16a|return|prel|pol|mode|comp|base|presc]
tim1PwmCh2Setup
		PUSH A
		;--allocate memory
		SUBW SP , #$01
	;-variables
	#define _003_v8a $00
	#define _003_prel $05
	#define _003_pol $06
	#define _003_mode $07
	#define _003_compH $08
	#define _003_compL $09
	#define _003_baseH $0A
	#define _003_baseL $0B
	#define _003_prescH $0C
	#define _003_prescL $0D
		;--disable timer
	LD A, TIM1_CR1
	AND A, #$FE;
	LD TIM1_CR1,A
	;--load comparand, Hi firstly
	LD A, (_003_compH,SP)
	LD TIM1_CCR2H, A
	LD A, (_003_compL,SP)
	LD TIM1_CCR2L, A
		;--prescaler high byte firstly
	LD A, (_003_prescH,SP)
	LD TIM1_PSCRH, A	
	LD A, (_003_prescL,SP)
	LD TIM1_PSCRL, A
	;--load base, high byte first
	LD A, (_003_baseH,SP)
	LD TIM1_ARRH, A
	LD A, (_003_baseL,SP)
	LD TIM1_ARRL, A
	;--load CCMR2
	LD A, (_003_mode,SP)
	LD TIM1_CCMR2, A
	;--polarity
	; 1)store content of another channels
	LD A, TIM1_CCER1
	AND A, #$0F
	LD (_003_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_003_pol,SP)
	OR A, #$01; turn on channel 
	SWAP A;  A << 4
	;--3) apply another regs
	OR A, (_003_v8a,SP)
	LD TIM1_CCER1, A
	;--turn on main channels
	LD A, #$80; MOE bit
	LD TIM1_BKR, A
	;--CR1
	LD A, (_003_prel,SP)
	LD TIM1_CR1, A
	OR A, #$01;
	LD TIM1_CR1, A
	;--fre memory
	ADDW SP, #$01
	POP A
	RET
	
	;--TEST PASSED!	 
	;===PROCEDURE 'tim1PwmCh3Setup'
  ;@presc16,  
	;@base16, -> base of counter, ARRL
	;@comp16, ->  pulse width, CCR1 content
	;@mode8,  -> (CCMR) : $60 PWM_MODE1
							       ;$70 iPWM_MODE2
						;additional:  $04 fast, $08 preload en.
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
	
	;stack frame:
	;[v16a|return|prel|pol|mode|comp|base|presc]
tim1PwmCh3Setup
		PUSH A
		;--allocate memory
		SUBW SP , #$01
	;-variables
	#define _004_v8a $00
	#define _004_prel $05
	#define _004_pol $06
	#define _004_mode $07
	#define _004_compH $08
	#define _004_compL $09
	#define _004_baseH $0A
	#define _004_baseL $0B
	#define _004_prescH $0C
	#define _004_prescL $0D
		;--disable timer
	LD A, TIM1_CR1
	AND A, #$FE;
	LD TIM1_CR1,A
	;--load comparand, Hi firstly
	LD A, (_004_compH,SP)
	LD TIM1_CCR3H, A
	LD A, (_004_compL,SP)
	LD TIM1_CCR3L, A
		;--prescaler high byte firstly
	LD A, (_004_prescH,SP)
	LD TIM1_PSCRH, A	
	LD A, (_004_prescL,SP)
	LD TIM1_PSCRL, A
	;--load base, high byte first
	LD A, (_004_baseH,SP)
	LD TIM1_ARRH, A
	LD A, (_004_baseL,SP)
	LD TIM1_ARRL, A
	;--load CCMR1
	LD A, (_004_mode,SP)
	LD TIM1_CCMR3, A
	;--polarity
	; 1)store content of another channels
	LD A, TIM1_CCER2
	AND A, #$F0
	LD (_004_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_004_pol,SP)
	OR A, #$01; turn on channel 
	;--3)apply another regs
	OR A, (_004_v8a,SP)
	LD TIM1_CCER2, A
	;--turn on main channels
	LD A, #$80; MOE bit
	LD TIM1_BKR, A
	;--CR1
	LD A, (_004_prel,SP)
	LD TIM1_CR1, A
	OR A, #$01;
	LD TIM1_CR1, A
	;--free memory
	ADDW SP, #$01
	POP A
	RET

	
	
	;--TEST PASSED!	
		;===PROCEDURE 'tim1PwmCh4Setup'
  ;@presc16,  
	;@base16, -> base of counter, ARRL
	;@comp16, ->  pulse width, CCR1 content
	;@mode8,  -> (CCMR) : $60 PWM_MODE1
							       ;$70 iPWM_MODE2
						;additional:  $04 fast, $08 preload en.
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
	
	;stack frame:
	;[v16a|return|prel|pol|mode|comp|base|presc]
tim1PwmCh4Setup
		PUSH A
		;--allocate memory
		SUBW SP , #$01
	;-variables
	#define _005_v8a $00
	#define _005_prel $05
	#define _005_pol $06
	#define _005_mode $07
	#define _005_compH $08
	#define _005_compL $09
	#define _005_baseH $0A
	#define _005_baseL $0B
	#define _005_prescH $0C
	#define _005_prescL $0D
		;--disable timer
	LD A, TIM1_CR1
	AND A, #$FE;
	LD TIM1_CR1,A
	;--load comparand, Hi firstly
	LD A, (_005_compH,SP)
	LD TIM1_CCR4H, A
	LD A, (_005_compL,SP)
	LD TIM1_CCR4L, A
		;--prescaler high byte firstly
	LD A, (_005_prescH,SP)
	LD TIM1_PSCRH, A	
	LD A, (_005_prescL,SP)
	LD TIM1_PSCRL, A
	;--load base, high byte first
	LD A, (_005_baseH,SP)
	LD TIM1_ARRH, A
	LD A, (_005_baseL,SP)
	LD TIM1_ARRL, A
	;--load CCMR
	LD A, (_005_mode,SP)
	LD TIM1_CCMR4, A
	;--polarity
; 1)store content of another channels
	LD A, TIM1_CCER2
	AND A, #$0F
	LD (_005_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_005_pol,SP)
	OR A, #$01; turn on channel 
	SWAP A;  A << 4
	;--3) apply another regs
	OR A,  (_005_v8a,SP)
	LD TIM1_CCER2, A
	;--turn on main channels
	LD A, #$80; MOE bit
	LD TIM1_BKR, A
	;--CR1
	LD A, (_005_prel,SP)
	LD TIM1_CR1, A
	OR A, #$01;
	LD TIM1_CR1, A
	;--free mem
	ADDW SP, #$01
	POP A
	RET
	
	;--TEST PASSED!
	;=P R O C E D UR E======tim1OnePulseModeStart=======
	;start one pulse mode
	;SP afer RETURN nas not been changed 
tim1OnePulseModeStart
	LD TIM1_CR1, A
	OR A, #$09; ///ONE PULSE MODE + Go
	LD TIM1_CR1, A
	RET
		;--TEST PASSED!
			;===PROCEDURE 'tim1OnePulsePwmCh1Setup'
	;timer is stopped!To start, call - 'tim1OnePulseModeStart'
  ;@presc16,  
	;@base16, -> base of counter, ARRL
	;@comp16, -> pulse width, CCR1 content
	;@mode8,  -> (CCMR) : $60 PWM_MODE1
							       ;$70 iPWM_MODE2
						;additional:  $04 fast, $08 preload en.
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
	;after return: SP+9
	;stack frame:
	;[v8a|A|return|prel|pol|mode|comp|base|presc]
tim1OnePulsePwmCh1Setup
	PUSH A
	;allocate memory
  SUBW SP, #$01	
	;-variables
	#define _002_v8a  $00 
	#define _002_prel $05
	#define _002_pol $06
	#define _002_mode $07
	#define _002_compH $08
	#define _002_compL $09
	#define _002_baseH $0A
	#define _002_baseL $0B
	#define _002_prescH $0C
	#define _002_prescL $0D
	;--disable timer
	LD A, TIM1_CR1
	AND A, #$FE;
	LD TIM1_CR1,A
	;--load comparand, Hi firstly
	LD A, (_002_compH,SP)
	LD TIM1_CCR1H, A
	LD A, (_002_compL,SP)
	LD TIM1_CCR1L, A
		;--prescaler high byte firstly
	LD A, (_002_prescH,SP)
	LD TIM1_PSCRH, A	
	LD A, (_002_prescL,SP)
	LD TIM1_PSCRL, A
	;--load base, high byte first
	LD A, (_002_baseH,SP)
	LD TIM1_ARRH, A
	LD A, (_002_baseL,SP)
	LD TIM1_ARRL, A
	;--load CCMR1
	LD A, (_002_mode,SP)
	LD TIM1_CCMR1, A
	;--polarity
	;--1) read and store 
	; content of another channels
	LD A, TIM1_CCER1
	AND A, #$F0
	LD (_002_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_002_pol,SP)
	OR A, #$01; turn on channel 1
	;--3)apply others regs
	OR A, (_002_v8a,SP)
	LD TIM1_CCER1, A
	;--turn on main channels
	LD A, #$80; MOE bit
	LD TIM1_BKR, A
	;--CR1
	LD A, (_002_prel,SP)
	LD TIM1_CR1, A
	OR A, #$08  ;//one pulse mode ,stopped
	LD TIM1_CR1, A
	;free memory
	ADDW SP, #$01
	POP A
	RET 
	
	;--TEST PASSED!
		;===PROCEDURE 'tim1OnePulsePwmCh2Setup'
		;timer is stopped!To start, call - 'tim1OnePulseModeStart'
  ;@presc16,  
	;@base16, -> base of counter, ARRL
	;@comp16, ->  pulse width, CCR1 content
	;@mode8,  -> (CCMR) : $60 PWM_MODE1
							       ;$70 iPWM_MODE2
						;additional:  $04 fast, $08 preload en.
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
		;after return: SP+9
	;stack frame:
	;[v8a|A|return|prel|pol|mode|comp|base|presc]
tim1OnePulsePwmCh2Setup
		PUSH A
		;--allocate memory
		SUBW SP , #$01
	;-variables
	#define _003_v8a $00
	#define _003_prel $05
	#define _003_pol $06
	#define _003_mode $07
	#define _003_compH $08
	#define _003_compL $09
	#define _003_baseH $0A
	#define _003_baseL $0B
	#define _003_prescH $0C
	#define _003_prescL $0D
		;--disable timer
	LD A, TIM1_CR1
	AND A, #$FE;
	LD TIM1_CR1,A
	;--load comparand, Hi firstly
	LD A, (_003_compH,SP)
	LD TIM1_CCR2H, A
	LD A, (_003_compL,SP)
	LD TIM1_CCR2L, A
		;--prescaler high byte firstly
	LD A, (_003_prescH,SP)
	LD TIM1_PSCRH, A	
	LD A, (_003_prescL,SP)
	LD TIM1_PSCRL, A
	;--load base, high byte first
	LD A, (_003_baseH,SP)
	LD TIM1_ARRH, A
	LD A, (_003_baseL,SP)
	LD TIM1_ARRL, A
	;--load CCMR2
	LD A, (_003_mode,SP)
	LD TIM1_CCMR2, A
	;--polarity
	; 1)store content of another channels
	LD A, TIM1_CCER1
	AND A, #$0F
	LD (_003_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_003_pol,SP)
	OR A, #$01; turn on channel 
	SWAP A;  A << 4
	;--3) apply another regs
	OR A, (_003_v8a,SP)
	LD TIM1_CCER1, A
	;--turn on main channels
	LD A, #$80; MOE bit
	LD TIM1_BKR, A
	;--CR1
	LD A, (_003_prel,SP)
	LD TIM1_CR1, A
	OR A, #$08  ;//one pulse mode ,stopped
	LD TIM1_CR1, A
	;--fre memory
	ADDW SP, #$01
	POP A
	RET
	
	;--TEST PASSED!
	;===PROCEDURE 'tim1OnePulsePwmCh3Setup'
	;timer is stopped!To start, call - 'tim1OnePulseModeStart'
  ;@presc16,  
	;@base16, -> base of counter, ARRL
	;@comp16, ->  pulse width, CCR1 content
	;@mode8,  -> (CCMR) : $60 PWM_MODE1
							       ;$70 iPWM_MODE2
						;additional:  $04 fast, $08 preload en.
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
		;after return: SP+9
	;stack frame:
	;[v8a|A|return|prel|pol|mode|comp|base|presc]
tim1OnePulsePwmCh3Setup
			PUSH A
		;--allocate memory
		SUBW SP , #$01
	;-variables
	#define _004_v8a $00
	#define _004_prel $05
	#define _004_pol $06
	#define _004_mode $07
	#define _004_compH $08
	#define _004_compL $09
	#define _004_baseH $0A
	#define _004_baseL $0B
	#define _004_prescH $0C
	#define _004_prescL $0D
		;--disable timer
	LD A, TIM1_CR1
	AND A, #$FE;
	LD TIM1_CR1,A
	;--load comparand, Hi firstly
	LD A, (_004_compH,SP)
	LD TIM1_CCR3H, A
	LD A, (_004_compL,SP)
	LD TIM1_CCR3L, A
		;--prescaler high byte firstly
	LD A, (_004_prescH,SP)
	LD TIM1_PSCRH, A	
	LD A, (_004_prescL,SP)
	LD TIM1_PSCRL, A
	;--load base, high byte first
	LD A, (_004_baseH,SP)
	LD TIM1_ARRH, A
	LD A, (_004_baseL,SP)
	LD TIM1_ARRL, A
	;--load CCMR1
	LD A, (_004_mode,SP)
	LD TIM1_CCMR3, A
	;--polarity
	; 1)store content of another channels
	LD A, TIM1_CCER2
	AND A, #$F0
	LD (_004_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_004_pol,SP)
	OR A, #$01; turn on channel 
	;--3)apply another regs
	OR A, (_004_v8a,SP)
	LD TIM1_CCER2, A
	;--turn on main channels
	LD A, #$80; MOE bit
	LD TIM1_BKR, A
	;--CR1
	LD A, (_004_prel,SP)
	LD TIM1_CR1, A
	OR A, #$08  ;//one pulse mode ,stopped
	LD TIM1_CR1, A
	;--free memory
	ADDW SP, #$01
	POP A
	RET
	
	;--TEST PASSED!
	;===PROCEDURE 'tim1OnePulsePwmCh4Setup'
	;timer is stopped!To start, call - 'tim1OnePulseModeStart'
  ;@presc16,  
	;@base16, -> base of counter, ARRL
	;@comp16, ->  pulse width, CCR1 content
	;@mode8,  -> (CCMR) : $60 PWM_MODE1
							       ;$70 iPWM_MODE2
						;additional:  $04 fast, $08 preload en.
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
		;after return: SP+9
	;stack frame:
	;[v8a|A|return|prel|pol|mode|comp|base|presc]
tim1OnePulsePwmCh4Setup
		PUSH A
		;--allocate memory
		SUBW SP , #$01
	;-variables
	#define _005_v8a $00
	#define _005_prel $05
	#define _005_pol $06
	#define _005_mode $07
	#define _005_compH $08
	#define _005_compL $09
	#define _005_baseH $0A
	#define _005_baseL $0B
	#define _005_prescH $0C
	#define _005_prescL $0D
		;--disable timer
	LD A, TIM1_CR1
	AND A, #$FE;
	LD TIM1_CR1,A
	;--load comparand, Hi firstly
	LD A, (_005_compH,SP)
	LD TIM1_CCR4H, A
	LD A, (_005_compL,SP)
	LD TIM1_CCR4L, A
		;--prescaler high byte firstly
	LD A, (_005_prescH,SP)
	LD TIM1_PSCRH, A	
	LD A, (_005_prescL,SP)
	LD TIM1_PSCRL, A
	;--load base, high byte first
	LD A, (_005_baseH,SP)
	LD TIM1_ARRH, A
	LD A, (_005_baseL,SP)
	LD TIM1_ARRL, A
	;--load CCMR
	LD A, (_005_mode,SP)
	LD TIM1_CCMR4, A
	;--polarity
; 1)store content of another channels
	LD A, TIM1_CCER2
	AND A, #$0F
	LD (_005_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_005_pol,SP)
	OR A, #$01; turn on channel 
	SWAP A;  A << 4
	;--3) apply another regs
	OR A,  (_005_v8a,SP)
	LD TIM1_CCER2, A
	;--turn on main channels
	LD A, #$80; MOE bit
	LD TIM1_BKR, A
	;--CR1
	LD A, (_005_prel,SP)
	LD TIM1_CR1, A
	OR A, #$08  ;//one pulse mode ,stopped
	LD TIM1_CR1, A
	;--free mem
	ADDW SP, #$01
	POP A
	RET
	
	
  ;---TEST PASSED!
			;===PROCEDURE 'tim1ComplementaryPwmCh1Setup'
  ;@presc16,  
	;@base16, -> base of counter, ARRL
	;@comp16, -> pulse width, CCR1 content
	;@mode8,  -> (CCMR) : $60 PWM_MODE1
							       ;$70 iPWM_MODE2
						;additional:  $04 fast, $08 preload en.
	;@polarity8 -> (CCER)  PosCh:$02 active LOW,
                       ;	NegCh: $08 active LOW
	;@preload8  -> (CR1) $80 preload , $20-center align.mode 1
	;@deadtime8 -> TIM1_DTR content
	; SP +10 after ret
	;stack frame:
	;[v8a|A|return|deadtime|prel|pol|mode|comp|base|presc]
tim1ComplementaryPwmCh1Setup
		PUSH A
	;-variables
	#define _002_v8a $00
	#define _002_deadtime $05
	#define _002_prel $06
	#define _002_pol $07
	#define _002_mode $08
	#define _002_compH $09
	#define _002_compL $0a
	#define _002_baseH $0b
	#define _002_baseL $0c
	#define _002_prescH $0d
	#define _002_prescL $0e
	;;allocate memory
	SUBW SP, #$01
	;--load comparand, Hi firstly
	LD A, (_002_compH,SP)
	LD TIM1_CCR1H, A
	LD A, (_002_compL,SP)
	LD TIM1_CCR1L, A
		;--prescaler high byte firstly
	LD A, (_002_prescH,SP)
	LD TIM1_PSCRH, A	
	LD A, (_002_prescL,SP)
	LD TIM1_PSCRL, A
	;--load base, high byte first
	LD A, (_002_baseH,SP)
	LD TIM1_ARRH, A
	LD A, (_002_baseL,SP)
	LD TIM1_ARRL, A
	;--load CCMR1
	LD A, (_002_mode,SP)
	LD TIM1_CCMR1, A
	;--polarity
	;1)store an another channel CCER1
	LD A, TIM1_CCER1
	AND A, #$F0
	LD (_002_v8a,SP), A
	;--2)apply saved another channel
	LD A, (_002_pol,SP)
	OR A, #$05; Pos and Neg channels ON
	OR A, (_002_v8a,SP)
	LD TIM1_CCER1, A
	;--deadtime
	LD A, (_002_deadtime,SP)
	LD TIM1_DTR, A
	;--turn on channels
	LD A, #$80
	LD TIM1_BKR, A
	;--CR1
	LD A, (_002_prel,SP)
	LD TIM1_CR1, A
	OR A, #$01;
	LD TIM1_CR1, A
	;--free memory
	ADDW SP, #$01
	POP A
	RET 

	;---TEST PASSED!
	  ;===PROCEDURE 'tim1ComplementaryPwmCh2Setup'
  ;@presc16,  
	;@base16, -> base of counter, ARRL
	;@comp16, ->  pulse width, CCR1 content
	;@mode8,  -> (CCMR) : $60 PWM_MODE1
							       ;$70 iPWM_MODE2
						;additional:  $04 fast, $08 preload en.
	;@polarity8 -> (CCER)  PosCh:$02 active LOW,
                  ;	NegCh: $08 active LOW
	;@preload8  -> (CR1) $80 preload , $20-center align.mode 1
	;@deadtime8 -> TIM1_DTR content
	; SP +10 after ret
	;stack frame:
	;[v8a|A|return|prel|pol|mode|comp|base|presc]
tim1ComplementaryPwmCh2Setup
		PUSH A
	;-variables
	#define _003_v8a $00
	#define _003_deadtime $05
	#define _003_prel $06
	#define _003_pol $07
	#define _003_mode $08
	#define _003_compH $09
	#define _003_compL $0a
	#define _003_baseH $0b
	#define _003_baseL $0c
	#define _003_prescH $0d
	#define _003_prescL $0e
	;;allocate memory
	SUBW SP, #$01
	;--load comparand, Hi firstly
	LD A, (_003_compH,SP)
	LD TIM1_CCR2H, A
	LD A, (_003_compL,SP)
	LD TIM1_CCR2L, A
		;--prescaler high byte firstly
	LD A, (_003_prescH,SP)
	LD TIM1_PSCRH, A	
	LD A, (_003_prescL,SP)
	LD TIM1_PSCRL, A
	;--load base, high byte first
	LD A, (_003_baseH,SP)
	LD TIM1_ARRH, A
	LD A, (_003_baseL,SP)
	LD TIM1_ARRL, A
	;--load CCMR1
	LD A, (_003_mode,SP)
	LD TIM1_CCMR2, A
	;--polarity
	;1)store an another channel CCER1
	LD A, TIM1_CCER1
	AND A, #$0F
	LD (_003_v8a,SP), A
	;--2)apply saved another channel
	LD A, (_003_pol,SP)
	OR A, #$05; Ch and ChN are turns ON
	SWAP A; A << 4 , because channel 2
	OR A, (_003_v8a,SP)
	LD TIM1_CCER1, A
	;--deadtime
	LD A, (_003_deadtime,SP)
	LD TIM1_DTR, A
	;--turn on channels
	LD A, #$80
	LD TIM1_BKR, A
	;--CR1
	LD A, (_003_prel,SP)
	LD TIM1_CR1, A
	OR A, #$01;
	LD TIM1_CR1, A
	;--free memory
	ADDW SP, #$01
	POP A
	RET
	 
 ;--TEST PASSED!
	;-=====PROCEDURE===tim1InputCaptureCh1Setup
	;@prescaler8, $04->/2, $08->/4, ;
						;$0C->8,$0-NONE
	;@filter8, see ref.manual
	;@evt_condition8, $00-RISE,HIGH, $02-FALL,LOW
  ;------------
	;SP +5
	;stack frame:
 ;[v8a|A|RET|evt_condition|filter|prescaler|period]
tim1InputCaptureCh1Setup
  #define _007_v1a $00
	#define _007_evt_condition $05
	#define _007_filter $06
	#define _007_prescaler $07
	#define _007_periodH $08
	#define _007_periodL $09
  PUSH A;
	SUBW SP, #$01
		;--turn off timer
	LD A, TIM1_CR1
	AND A, #$FE
	LD TIM1_CR1, A
	;--CCMR1-
	LD A, (_007_filter,SP)
	OR A, (_007_prescaler,SP)
	OR A, #$01
	LD TIM1_CCMR1, A
	;---CCER1--
	;--1)save other channel state
	LD A, TIM1_CCER1
  AND A, #$F0 
	LD (_007_v1a,SP), A
	;--2)load value for tthis channel
	LD A, (_007_evt_condition,SP)
	;--3)aplly other channel to current 
	OR A, (_007_v1a,SP)
	LD TIM1_CCER1, A
	;--turn on CH1
	LD A, TIM1_CCER1
	OR A, #$01
	LD TIM1_CCER1, A
	;---period
	LD A, (_007_periodH,SP)
	LD TIM1_ARRH, A
	LD A, (_007_periodL,SP)
	LD TIM1_ARRL, A
	;--turn on timer
	LD A, TIM1_CR1
	OR A, #$01
	LD TIM1_CR1, A
	;--free mem
	ADDW SP, #$01
	POP A
	RET
	;--TEST PASSED!
	;-=====PROCEDURE===tim1InputCaptureCh2Setup
	;@period16
	;@prescaler8, $04->/2, $08->/4, ;
						;$0C->8,$0-NONE
	;@filter8, see ref.manual
	;@evt_condition8, $00-RISE,HIGH, $02-FALL,LOW
  ;------------
	;SP +5
	;stack frame:
 ;[v8a|A|RET|evt_condition|filter|prescaler|period]
tim1InputCaptureCh2Setup
  #define _007_v1a $00
	#define _007_evt_condition $05
	#define _007_filter $06
	#define _007_prescaler $07
	#define _007_periodH $08
	#define _007_periodL $09
	
  PUSH A;
	SUBW SP, #$01
		;--turn off timer
	LD A, TIM1_CR1
	AND A, #$FE
	LD TIM1_CR1, A
	;--CCMR1-
	LD A, (_007_filter,SP)
	OR A, (_007_prescaler,SP)
	OR A, #$01
	LD TIM1_CCMR2, A
	;---CCER1--
	;--1)save other channel state
	LD A, TIM1_CCER1
  AND A, #$0F 
	LD (_007_v1a,SP), A
	;--2)load value for tthis channel
	LD A, (_007_evt_condition,SP)
	SWAP A ;<<4 because CH2
	;--3)aplly other channel to current 
	OR A, (_007_v1a,SP)
	LD TIM1_CCER1, A
	;--turn on CH2
	LD A, TIM1_CCER1
	OR A, #$10
	LD TIM1_CCER1, A
	;---period
	LD A, (_007_periodH,SP)
	LD TIM1_ARRH, A
	LD A, (_007_periodL,SP)
	LD TIM1_ARRL, A
	;--turn on timer
	LD A, TIM1_CR1
	OR A, #$01
	LD TIM1_CR1, A
	;--free mem
	ADDW SP, #$01
	POP A
	RET
	;***34*****
	
	 ;--TEST PASSED!
	;-=====PROCEDURE===tim1InputCaptureCh3Setup
	;@prescaler8, $04->/2, $08->/4, ;
						;$0C->8,$0-NONE
	;@filter8, see ref.manual
	;@evt_condition8, $00-RISE,HIGH, $02-FALL,LOW
  ;------------
	;SP +5
	;stack frame:
 ;[v8a|A|RET|evt_condition|filter|prescaler|period]
tim1InputCaptureCh3Setup
  #define _007_v1a $00
	#define _007_evt_condition $05
	#define _007_filter $06
	#define _007_prescaler $07
	#define _007_periodH $08
	#define _007_periodL $09
  PUSH A;
	SUBW SP, #$01
		;--turn off timer
	LD A, TIM1_CR1
	AND A, #$FE
	LD TIM1_CR1, A
	;--CCMR3-
	LD A, (_007_filter,SP)
	OR A, (_007_prescaler,SP)
	OR A, #$01
	LD TIM1_CCMR3, A
	;---CCER1--
	;--1)save other channel state
	LD A, TIM1_CCER2
  AND A, #$F0 
	LD (_007_v1a,SP), A
	;--2)load value for tthis channel
	LD A, (_007_evt_condition,SP)
	;--3)aplly other channel to current 
	OR A, (_007_v1a,SP)
	LD TIM1_CCER2, A
	;--turn on CH1
	LD A, TIM1_CCER2
	OR A, #$01
	LD TIM1_CCER2, A
	;---period
	LD A, (_007_periodH,SP)
	LD TIM1_ARRH, A
	LD A, (_007_periodL,SP)
	LD TIM1_ARRL, A
	;--turn on timer
	LD A, TIM1_CR1
	OR A, #$01
	LD TIM1_CR1, A
	;--free mem
	ADDW SP, #$01
	POP A
	RET
	;--TEST PASSED!
	;-=====PROCEDURE===tim1InputCaptureCh4Setup
	;@period16
	;@prescaler8, $04->/2, $08->/4, ;
						;$0C->8,$0-NONE
	;@filter8, see ref.manual
	;@evt_condition8, $00-RISE,HIGH, $02-FALL,LOW
  ;------------
	;SP +5
	;stack frame:
 ;[v8a|A|RET|evt_condition|filter|prescaler|period]
tim1InputCaptureCh4Setup
  #define _007_v1a $00
	#define _007_evt_condition $05
	#define _007_filter $06
	#define _007_prescaler $07
	#define _007_periodH $08
	#define _007_periodL $09
	
  PUSH A;
	SUBW SP, #$01
		;--turn off timer
	LD A, TIM1_CR1
	AND A, #$FE
	LD TIM1_CR1, A
	;--CCMR1-
	LD A, (_007_filter,SP)
	OR A, (_007_prescaler,SP)
	OR A, #$01
	LD TIM1_CCMR4, A
	;---CCER1--
	;--1)save other channel state
	LD A, TIM1_CCER2
  AND A, #$0F 
	LD (_007_v1a,SP), A
	;--2)load value for tthis channel
	LD A, (_007_evt_condition,SP)
	SWAP A ;<<4 because CH2
	;--3)aplly other channel to current 
	OR A, (_007_v1a,SP)
	LD TIM1_CCER2, A
	;--turn on CH2
	LD A, TIM1_CCER2
	OR A, #$10
	LD TIM1_CCER2, A
	;---period
	LD A, (_007_periodH,SP)
	LD TIM1_ARRH, A
	LD A, (_007_periodL,SP)
	LD TIM1_ARRL, A
	;--turn on timer
	LD A, TIM1_CR1
	OR A, #$01
	LD TIM1_CR1, A
	;--free mem
	ADDW SP, #$01
	POP A
	RET
	
	;---TEST PASSED!
	;==========P R O C E D U R E===="tim1EncoderSetup"
  ;@band16,
	;@mode8, must be: $01 ->mod1, $02->mod2, $03->mod3	
	;@filter8, $00->filter_off, 
	             ;please see ref.manual TIM1_CCMR1, 2
  ;@polarity8,$00-Ch1 and Ch2-rise-edge-pos,
						  ;$02->fall-edge-neg-CH1 $20->fall-edge-neg-CH2
	;-------------------
	;after retutrn SP + 5
	;Stack frame;
	;[v8a | A | RET  | polarity |filter  |mode | band]
tim1EncoderSetup
	#define _005_v8a $00
	#define _005_mode $07
	#define _005_filter $06
	#define _005_polarity $05
	#define _005_bandH $08
	#define _005_bandL $09
	;save A
	PUSH A
	;allocate memory
	SUBW SP, #$01
	;--SMCR
	LD A, (_005_mode,SP)
	LD TIM1_SMCR, A
	;--TIM1_CCMR1
	LD A,(_005_filter,SP)
	OR A, #$01; 
	LD TIM1_CCMR1, A
	;--TIM1_CCMR2
	LD A,(_005_filter,SP)
	OR A, #$01; 
	LD TIM1_CCMR2, A
	;--TIM_CCER1
	LD A, (_005_polarity,SP)
	OR A, #$11; 
  LD TIM1_CCER1, A
  ;--load band 
  LD A, (_005_bandH,SP)
  LD TIM1_ARRH, A
  LD A, (_005_bandL,SP)
  LD TIM1_ARRL, A	
	;--turn on 
	LD A, #$01
	LD TIM1_CR1, A
	;--free mem
	ADDW SP, #$01
	;--restore A
	POP A;
	RET
	
	;------C A P T U R E   C O M P A R E    I N T E R R U P T S 
	;====PROCDEDURE 'tim1CaptureCompareSetupInterrupts
	;turn on capture/compare interrupt enable for given channel
	;@channel8
	; must be $02->CH1, $04->CH2, $08->CH3, $1->CH4
	; to enable UPDATE interrupt - OR $01 
  ;after RETURN: SP +1
	;stack frame
	; 0  1 2 3      4
  ;[A |RETURN| channel]
tim1CaptureCompareSetupInterrupts
	PUSH A
	LD A , ($04,SP)
	LD TIM1_IER, A
	POP A
	RET

;  _____ ___ __  __ ____  
; |_   _|_ _|  \/  |___ \ 
;   | |  | || |\/| | __) |
;   | |  | || |  | |/ __/ 
;   |_| |___|_|  |_|_____|


;---T E S T   P A S S E D!
;=====P R O C E D U R E=='tim2BaseModeSetup'=
;===initializing TIM1 in base mode
; @prescaler16 (!ONLY LOW byte), @base16, @mode8
; After return: SP-5
;-modes can (TIM1_CR1) be ;
;-TIM_EDGE_ALIGNED ($00)
;- TIM_CENTER_ALINGN_1 ($20),
;- TIM_CENTER_ALINGN_2 ($40),
;- TIM_CENTER_ALINGN_3 ($60),
;count mode can be:
;- TIM_COUNTS_UP ($00)
;- TIM_COUNTS_DOWN ($10)
;--stack frame:
;   0   1  2 3  4    5  6  7  8 
 ;[| A |  RET |mode| base | presc| 

tim2BaseModeSetup
	;--store registers
	PUSH A
	#define _000_presH $07 ;prescaler
	#define _000_presL $08
	#define _000_baseH $05 ;base ,counter
	#define _000_baseL $06
	#define _000_mode $04  ; parameters
	;load prescaler:
	LD A,(_000_presL,SP)
	LD TIM2_PSCR, A
	;load base, HI first:
	LD A, (_000_baseH,SP)
	LD TIM2_ARRH, A
	LD A, (_000_baseL,SP)
	LD TIM2_ARRL, A
  ;load mod in TIM1_CR1 (p.188 ref manual)
  LD A, (_000_mode,SP)
  LD TIM2_CR1, A
	;--start timer and GO! 
	LD A, TIM2_CR1
	OR A, #$01
	LD TIM2_CR1, A
	;--restore registers
	POP A
	RET
	
;--note! insert WFI inside main loop to allow interrups


;---T E S T   P A S S E D!
;=====P R O C E D U R E=='tim2BaseModeSetupIT'=
;===initializing TIM1 in base mode with interrupts
; @prescaler16 (!ONLY LOW byte), @base16, @mode8
; After return: SP-5
;-modes can (TIM1_CR1) be ;
;-TIM_EDGE_ALIGNED ($00)
;- TIM_CENTER_ALINGN_1 ($20),
;- TIM_CENTER_ALINGN_2 ($40),
;- TIM_CENTER_ALINGN_3 ($60),
;count mode can be:
;- TIM_COUNTS_UP ($00)
;- TIM_COUNTS_DOWN ($10)
;--stack frame:
;   0   1  2 3  4    5  6  7  8 
 ;[| A |  RET |mode| base | presc| 

tim2BaseModeSetupIT
	;--store registers
	PUSH A
	#define _000_presH $07 ;prescaler
	#define _000_presL $08
	#define _000_baseH $05 ;base ,counter
	#define _000_baseL $06
	#define _000_mode $04  ; parameters
	;set interrupt update event enable
	LD A, #$01
	LD TIM2_IER, A
	;load prescaler:
	LD A,(_000_presL,SP)
	LD TIM2_PSCR, A
	;load base, HI first:
	LD A, (_000_baseH,SP)
	LD TIM2_ARRH, A
	LD A, (_000_baseL,SP)
	LD TIM2_ARRL, A
  ;load mod in TIM1_CR1 (p.188 ref manual)
  LD A, (_000_mode,SP)
  LD TIM2_CR1, A
	;--start timer and GO! 
	LD A, TIM2_CR1
	OR A, #$01
	LD TIM2_CR1, A
	;--restore registers
	POP A
	RET

	;====PROCDEDURE 'tim2CaptureCompareSetupInterrupts
	;turn on capture/compare interrupt enable for given channel
	;@channel8
	; must be $02->CH1, $04->CH2, $08->CH3, 
	; to enable UPDATE interrupt - OR $01
  ;after  RETURN: SP +1
	;stack frame
	; 0  1 2 3      4
  ;[A |RETURN| channel]
tim2CaptureCompareSetupInterrupts
	PUSH A
	LD A , ($04,SP)
	LD TIM2_IER, A
	POP A
	RET

;----T E S T   P A S S E D!
	;=====P R O C E D U R E==='tim2OutputCompareCh1Setup'
	;@presc16, !!! must be in TIM2 from list  (only LOW byte):
				  ;$01->/2, $02->/4, $03->/8 $04->/16 
					;$05->/32, $06->/64, $07->/128, $08->/256
					;$09->/512 $0A->/1024, $0B->/2048, $0C->/4096
					;$0D->/8192, $0E->/16384, $0F->/32768 
	;@base16, -> base of counter, ARRL
	;@comp16, -> capture compare CCR1 content
	;@mode8,  -> (CCMR)PIN  beheviavour: $10 active on match
							;$20 inactive on muatch $30 toggle pin
							;$30 force inactive Level $50 force active level
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
	;after ret SP +9
	;stack frame:
	;[v8a|A|return|prel|pol|mode|comp|base|presc]
tim2OutputCompareCh1Setup
		PUSH A
	;allocate memory
  SUBW SP, #$01	
	;-variables
	#define _002_v8a  $00 
	#define _002_prel $05
	#define _002_pol $06
	#define _002_mode $07
	#define _002_compH $08
	#define _002_compL $09
	#define _002_baseH $0A
	#define _002_baseL $0B
	#define _002_prescH $0C
	#define _002_prescL $0D
	;--disable timer
	LD A, TIM2_CR1
	AND A, #$FE;
	LD TIM2_CR1,A
	;--prescaler only low	
	LD A, (_002_prescL,SP)
	LD TIM2_PSCR, A
	LD A, TIM2_PSCR
	;--load comparand, Hi firstly
	LD A, (_002_compH,SP)
	LD TIM2_CCR1H, A
	LD A, (_002_compL,SP)
	LD TIM2_CCR1L, A
	;--load base, high byte first
	LD A, (_002_baseH,SP)
	LD TIM2_ARRH, A
	LD A, (_002_baseL,SP)
	LD TIM2_ARRL, A
	;--load CCMR1
	LD A, (_002_mode,SP)
	LD TIM2_CCMR1, A
	;--polarity
	;--1) read and store 
	; content of another channels
	LD A, TIM2_CCER1
	AND A, #$F0
	LD (_002_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_002_pol,SP)
	OR A, #$01; turn on channel 1
	;--3)apply others regs
	OR A, (_002_v8a,SP)
	LD TIM2_CCER1, A
	;--CR1
	LD A, (_002_prel,SP)
	LD TIM2_CR1, A
	OR A, #$01;
	LD TIM2_CR1, A
	;free memory
	ADDW SP, #$01
	POP A
	RET 
	
  ;---T E S T   P A S S E D!
	;=====P R O C E D U R E==='tim2OutputCompareCh2Setup'
	;@presc16, !!! must be in TIM2 from list  (only LOW byte):
				  ;$01->/2, $02->/4, $03->/8 $04->/16 
					;$05->/32, $06->/64, $07->/128, $08->/256
					;$09->/512 $0A->/1024, $0B->/2048, $0C->/4096
					;$0D->/8192, $0E->/16384, $0F->/32768 
	;@base16, -> base of counter, ARRL
	;@comp16, -> capture compare CCR1 content
	;@mode8,  -> (CCMR)PIN  beheviavour: $10 active on match
							;$20 inactive on muatch $30 toggle pin
							;$30 force inactive Level $50 force active level
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
	;SP +9
	;stack frame:
	;[v16a|return|prel|pol|mode|comp|base|presc]
tim2OutputCompareCh2Setup
		PUSH A
		;--allocate memory
		SUBW SP , #$01
	;-variables
	#define _003_v8a $00
	#define _003_prel $05
	#define _003_pol $06
	#define _003_mode $07
	#define _003_compH $08
	#define _003_compL $09
	#define _003_baseH $0A
	#define _003_baseL $0B
	#define _003_prescH $0C
	#define _003_prescL $0D
		;--disable timer
	LD A, TIM2_CR1
	AND A, #$FE;
	LD TIM2_CR1,A
	;--prescaler only low	
	LD A, (_002_prescL,SP)
	LD TIM2_PSCR, A
	LD A, TIM2_PSCR
	;--load comparand, Hi firstly
	LD A, (_003_compH,SP)
	LD TIM2_CCR2H, A
	LD A, (_003_compL,SP)
	LD TIM2_CCR2L, A
	;--load base, high byte first
	LD A, (_003_baseH,SP)
	LD TIM2_ARRH, A
	LD A, (_003_baseL,SP)
	LD TIM2_ARRL, A
	;--load CCMR2
	LD A, (_003_mode,SP)
	LD TIM2_CCMR2, A
	;--polarity
	; 1)store content of another channels
	LD A, TIM2_CCER1
	AND A, #$0F
	LD (_003_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_003_pol,SP)
	OR A, #$01; turn on channel 
	SWAP A;  A << 4
	;--3) apply another regs
	OR A, (_003_v8a,SP)
	LD TIM2_CCER1, A
	;--CR1
	LD A, (_003_prel,SP)
	LD TIM2_CR1, A
	OR A, #$01;
	LD TIM2_CR1, A
	;--fre memory
	ADDW SP, #$01
	POP A
	RET
	
	;--T E S T   P A S S E D!
	;=====P R O C E D U R E==='tim2OutputCompareCh3Setup'
	;@presc16, !!! must be in TIM2 from list  (only LOW byte):
				  ;$01->/2, $02->/4, $03->/8 $04->/16 
					;$05->/32, $06->/64, $07->/128, $08->/256
					;$09->/512 $0A->/1024, $0B->/2048, $0C->/4096
					;$0D->/8192, $0E->/16384, $0F->/32768 
	;@base16, -> base of counter, ARRL
	;@comp16, -> capture compare CCR1 content
	;@mode8,  -> (CCMR)PIN  beheviavour: $10 active on match
							;$20 inactive on muatch $30 toggle pin
							;$30 force inactive Level $50 force active level
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
	;SP +9
	;stack frame:
	;[v16a|return|prel|pol|mode|comp|base|presc]
tim2OutputCompareCh3Setup
		PUSH A
		;--allocate memory
		SUBW SP , #$01
	;-variables
	#define _004_v8a $00
	#define _004_prel $05
	#define _004_pol $06
	#define _004_mode $07
	#define _004_compH $08
	#define _004_compL $09
	#define _004_baseH $0A
	#define _004_baseL $0B
	#define _004_prescH $0C
	#define _004_prescL $0D
		;--disable timer
	LD A, TIM2_CR1
	AND A, #$FE;
	LD TIM2_CR1,A
	;--prescaler only low	
	LD A, (_002_prescL,SP)
	LD TIM2_PSCR, A
	LD A, TIM2_PSCR
	;--load comparand, Hi firstly
	LD A, (_004_compH,SP)
	LD TIM2_CCR3H, A
	LD A, (_004_compL,SP)
	LD TIM2_CCR3L, A
 
	;--load base, high byte first
	LD A, (_004_baseH,SP)
	LD TIM2_ARRH, A
	LD A, (_004_baseL,SP)
	LD TIM2_ARRL, A
	;--load CCMR1
	LD A, (_004_mode,SP)
	LD TIM2_CCMR3, A
	;--polarity
	; 1)store content of another channels
	LD A, TIM2_CCER2
	AND A, #$F0
	LD (_004_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_004_pol,SP)
	OR A, #$01; turn on channel 
	;--3)apply another regs
	OR A, (_004_v8a,SP)
	LD TIM2_CCER2, A
	;--CR1
	LD A, (_004_prel,SP)
	LD TIM2_CR1, A
	OR A, #$01;
	LD TIM2_CR1, A
	;--free memory
	ADDW SP, #$01
	POP A
	RET
	
	;----T E S T   P A S S E D!
	;=====P R O C E D U R E==='tim2PwmCh1Setup'
	;@presc16, !!! must be in TIM2 from list  (only LOW byte):
				  ;$01->/2, $02->/4, $03->/8 $04->/16 
					;$05->/32, $06->/64, $07->/128, $08->/256
					;$09->/512 $0A->/1024, $0B->/2048, $0C->/4096
					;$0D->/8192, $0E->/16384, $0F->/32768 
	;@base16, -> base of counter, ARRL
	;@comp16, ->  pulse width, CCR1 content
	;@mode8,  -> (CCMR)PWM mode: $60 pwm_mode_1, $70 pwm_mode_2
							;additional parameters (use OR) $04 -fast_mode
							; $80 - prelopad enable
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
	;SP +9
	;stack frame:
	;[v16a|return|prel|pol|mode|comp|base|presc]
tim2PwmCh1Setup
		PUSH A
	;allocate memory
  SUBW SP, #$01	
	;-variables
	#define _002_v8a  $00 
	#define _002_prel $05
	#define _002_pol $06
	#define _002_mode $07
	#define _002_compH $08
	#define _002_compL $09
	#define _002_baseH $0A
	#define _002_baseL $0B
	#define _002_prescH $0C
	#define _002_prescL $0D
	;--disable timer
	LD A, TIM2_CR1
	AND A, #$FE;
	LD TIM2_CR1,A
	;--prescaler only low	
	LD A, (_002_prescL,SP)
	LD TIM2_PSCR, A
	LD A, TIM2_PSCR
	;--load comparand, Hi firstly
	LD A, (_002_compH,SP)
	LD TIM2_CCR1H, A
	LD A, (_002_compL,SP)
	LD TIM2_CCR1L, A
	;--load base, high byte first
	LD A, (_002_baseH,SP)
	LD TIM2_ARRH, A
	LD A, (_002_baseL,SP)
	LD TIM2_ARRL, A
	;--load CCMR1
	LD A, (_002_mode,SP)
	LD TIM2_CCMR1, A
	;--polarity
	;--1) read and store 
	; content of another channels
	LD A, TIM2_CCER1
	AND A, #$F0
	LD (_002_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_002_pol,SP)
	OR A, #$01; turn on channel 1
	;--3)apply others regs
	OR A, (_002_v8a,SP)
	LD TIM2_CCER1, A
	;--CR1
	LD A, (_002_prel,SP)
	LD TIM2_CR1, A
	OR A, #$01;
	LD TIM2_CR1, A
	;free memory
	ADDW SP, #$01
	POP A
	RET 
	;---T E S T   P A S S E D!
			;=====P R O C E D U R E==='tim2PwmCh2Setup'
	;@presc16, !!! must be in TIM2 from list  (only LOW byte):
				  ;$01->/2, $02->/4, $03->/8 $04->/16 
					;$05->/32, $06->/64, $07->/128, $08->/256
					;$09->/512 $0A->/1024, $0B->/2048, $0C->/4096
					;$0D->/8192, $0E->/16384, $0F->/32768 
	;@base16, -> base of counter, ARRL
	;@comp16, -> c pulse width, CCR1 content
	;@mode8,  -> (CCMR)PWM mode: $60 pwm_mode_1, $70 pwm_mode_2
							;additional parameters (use OR) $04 -fast_mode
							; $80 - prelopad enable
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
	;SP +9
	;stack frame:
	;[v16a|return|prel|pol|mode|comp|base|presc]
tim2PwmCh2Setup
		PUSH A
		;--allocate memory
		SUBW SP , #$01
	;-variables
	#define _003_v8a $00
	#define _003_prel $05
	#define _003_pol $06
	#define _003_mode $07
	#define _003_compH $08
	#define _003_compL $09
	#define _003_baseH $0A
	#define _003_baseL $0B
	#define _003_prescH $0C
	#define _003_prescL $0D
		;--disable timer
	LD A, TIM2_CR1
	AND A, #$FE;
	LD TIM2_CR1,A
	;--prescaler only low	
	LD A, (_002_prescL,SP)
	LD TIM2_PSCR, A
	LD A, TIM2_PSCR
	;--load comparand, Hi firstly
	LD A, (_003_compH,SP)
	LD TIM2_CCR2H, A
	LD A, (_003_compL,SP)
	LD TIM2_CCR2L, A
	;--load base, high byte first
	LD A, (_003_baseH,SP)
	LD TIM2_ARRH, A
	LD A, (_003_baseL,SP)
	LD TIM2_ARRL, A
	;--load CCMR2
	LD A, (_003_mode,SP)
	LD TIM2_CCMR2, A
	;--polarity
	; 1)store content of another channels
	LD A, TIM2_CCER1
	AND A, #$0F
	LD (_003_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_003_pol,SP)
	OR A, #$01; turn on channel 
	SWAP A;  A << 4
	;--3) apply another regs
	OR A, (_003_v8a,SP)
	LD TIM2_CCER1, A
	;--CR1
	LD A, (_003_prel,SP)
	LD TIM2_CR1, A
	OR A, #$01;
	LD TIM2_CR1, A
	;--fre memory
	ADDW SP, #$01
	POP A
	RET
	
	;--T E S T   P A S S E D!
	;=====P R O C E D U R E==='tim2PwmCh3Setup'
	;@presc16, !!! must be in TIM2 from list  (only LOW byte):
				  ;$01->/2, $02->/4, $03->/8 $04->/16 
					;$05->/32, $06->/64, $07->/128, $08->/256
					;$09->/512 $0A->/1024, $0B->/2048, $0C->/4096
					;$0D->/8192, $0E->/16384, $0F->/32768 
	;@base16, -> base of counter, ARRL
	;@comp16, ->  pulse width, CCR1 content
	;@mode8,  -> (CCMR)PWM mode: $60 pwm_mode_1, $70 pwm_mode_2
							;additional parameters (use OR) $04 -fast_mode
							; $80 - prelopad enable
	;@polarity8 -> (CCER)  $00 active HI,$02 active low
	;@preload8  ->  $80 preload enable, CR1 content
	;SP +9
	;stack frame:
	;[v16a|return|prel|pol|mode|comp|base|presc]
tim2PwmCh3Setup
			PUSH A
		;--allocate memory
		SUBW SP , #$01
	;-variables
	#define _004_v8a $00
	#define _004_prel $05
	#define _004_pol $06
	#define _004_mode $07
	#define _004_compH $08
	#define _004_compL $09
	#define _004_baseH $0A
	#define _004_baseL $0B
	#define _004_prescH $0C
	#define _004_prescL $0D
		;--disable timer
	LD A, TIM2_CR1
	AND A, #$FE;
	LD TIM2_CR1,A
	;--prescaler only low	
	LD A, (_002_prescL,SP)
	LD TIM2_PSCR, A
	LD A, TIM2_PSCR
	;--load comparand, Hi firstly
	LD A, (_004_compH,SP)
	LD TIM2_CCR3H, A
	LD A, (_004_compL,SP)
	LD TIM2_CCR3L, A
 
	;--load base, high byte first
	LD A, (_004_baseH,SP)
	LD TIM2_ARRH, A
	LD A, (_004_baseL,SP)
	LD TIM2_ARRL, A
	;--load CCMR1
	LD A, (_004_mode,SP)
	LD TIM2_CCMR3, A
	;--polarity
	; 1)store content of another channels
	LD A, TIM2_CCER2
	AND A, #$F0
	LD (_004_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_004_pol,SP)
	OR A, #$01; turn on channel 
	;--3)apply another regs
	OR A, (_004_v8a,SP)
	LD TIM2_CCER2, A
	;--CR1
	LD A, (_004_prel,SP)
	LD TIM2_CR1, A
	OR A, #$01;
	LD TIM2_CR1, A
	;--free memory
	ADDW SP, #$01
	POP A
	RET
	
	;--T E S T   P A S S E D!
		;=====P R O C E D U R E==='tim2OnePulsePwmCh1Setup'
		;@presc16, !!! must be in TIM2 from list  (only LOW byte):
				  ;$01->/2, $02->/4, $03->/8 $04->/16 
					;$05->/32, $06->/64, $07->/128, $08->/256
					;$09->/512 $0A->/1024, $0B->/2048, $0C->/4096
					;$0D->/8192, $0E->/16384, $0F->/32768 
	;@base16, -> base of counter, ARRL
	;@comp16, ->  pulse width, CCR1 content
	;@mode8,  -> (CCMR)PWM mode: $60 pwm_mode_1, $70 pwm_mode_2
							;additional parameters (use OR) $04 -fast_mode
							; $80 - prelopad enable
	;@polarity8 -> (CCER)  $00 active HI,$02 active LO
	;@preload8  ->  $80 preload enable, CR1 content
	;SP +9
	;stack frame:
	;[v16a|return|prel|pol|mode|comp|base|presc]
tim2OnePulsePwmCh1Setup
		PUSH A
	;allocate memory
  SUBW SP, #$01	
	;-variables
	#define _002_v8a  $00 
	#define _002_prel $05
	#define _002_pol $06
	#define _002_mode $07
	#define _002_compH $08
	#define _002_compL $09
	#define _002_baseH $0A
	#define _002_baseL $0B
	#define _002_prescH $0C
	#define _002_prescL $0D
	;--disable timer
	LD A, TIM2_CR1
	AND A, #$FE;
	LD TIM2_CR1,A
	;--prescaler only low	
	LD A, (_002_prescL,SP)
	LD TIM2_PSCR, A
	LD A, TIM2_PSCR
	;--load comparand, Hi firstly
	LD A, (_002_compH,SP)
	LD TIM2_CCR1H, A
	LD A, (_002_compL,SP)
	LD TIM2_CCR1L, A
	;--load base, high byte first
	LD A, (_002_baseH,SP)
	LD TIM2_ARRH, A
	LD A, (_002_baseL,SP)
	LD TIM2_ARRL, A
	;--load CCMR1
	LD A, (_002_mode,SP)
	LD TIM2_CCMR1, A
	;--polarity
	;--1) read and store 
	; content of another channels
	LD A, TIM2_CCER1
	AND A, #$F0
	LD (_002_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_002_pol,SP)
	OR A, #$01; turn on channel 1
	;--3)apply others regs
	OR A, (_002_v8a,SP)
	LD TIM2_CCER1, A
	;--CR1
	LD A, (_002_prel,SP)
	LD TIM2_CR1, A
	OR A, #$08;//ONE PULSE MODE, stopped
	LD TIM2_CR1, A
	;free memory
	ADDW SP, #$01
	POP A
	RET 
	
	;--T E S T   P A S S E D!
	;=====P R O C E D U R E==='tim2OnePulsePwmCh2Setup'
	;@presc16, !!! must be in TIM2 from list  (only LOW byte):
				  ;$01->/2, $02->/4, $03->/8 $04->/16 
					;$05->/32, $06->/64, $07->/128, $08->/256
					;$09->/512 $0A->/1024, $0B->/2048, $0C->/4096
					;$0D->/8192, $0E->/16384, $0F->/32768 
	;@base16, -> base of counter, ARRL
	;@comp16, ->  pulse width, CCR1 content
	;@mode8,  -> (CCMR)PWM mode: $60 pwm_mode_1, $70 pwm_mode_2
							;additional parameters (use OR) $04 -fast_mode
							; $80 - prelopad enable
	;@polarity8 -> (CCER)  $02 active LI,$00 active Hi
	;@preload8  ->  $80 preload enable, CR1 content
	;SP +9
	;stack frame:
	;[v16a|return|prel|pol|mode|comp|base|presc]
tim2OnePulsePwmCh2Setup
	PUSH A
		;--allocate memory
		SUBW SP , #$01
	;-variables
	#define _003_v8a $00
	#define _003_prel $05
	#define _003_pol $06
	#define _003_mode $07
	#define _003_compH $08
	#define _003_compL $09
	#define _003_baseH $0A
	#define _003_baseL $0B
	#define _003_prescH $0C
	#define _003_prescL $0D
		;--disable timer
	LD A, TIM2_CR1
	AND A, #$FE;
	LD TIM2_CR1,A
	;--prescaler only low	
	LD A, (_002_prescL,SP)
	LD TIM2_PSCR, A
	LD A, TIM2_PSCR
	;--load comparand, Hi firstly
	LD A, (_003_compH,SP)
	LD TIM2_CCR2H, A
	LD A, (_003_compL,SP)
	LD TIM2_CCR2L, A
	;--load base, high byte first
	LD A, (_003_baseH,SP)
	LD TIM2_ARRH, A
	LD A, (_003_baseL,SP)
	LD TIM2_ARRL, A
	;--load CCMR2
	LD A, (_003_mode,SP)
	LD TIM2_CCMR2, A
	;--polarity
	; 1)store content of another channels
	LD A, TIM2_CCER1
	AND A, #$0F
	LD (_003_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_003_pol,SP)
	OR A, #$01; turn on channel 
	SWAP A;  A << 4
	;--3) apply another regs
	OR A, (_003_v8a,SP)
	LD TIM2_CCER1, A
	;--CR1
	LD A, (_003_prel,SP)
	LD TIM2_CR1, A
	OR A, #$08;//one pulse mode, stopped
	LD TIM2_CR1, A
	;--fre memory
	ADDW SP, #$01
	POP A
	RET
	
	;--T E S T   P A S S E D !
;=====P R O C E D U R E==='tim2OnePulsePwmCh3Setup'
	;@presc16, !!! must be in TIM2 from list  (only LOW byte):
				  ;$01->/2, $02->/4, $03->/8 $04->/16 
					;$05->/32, $06->/64, $07->/128, $08->/256
					;$09->/512 $0A->/1024, $0B->/2048, $0C->/4096
					;$0D->/8192, $0E->/16384, $0F->/32768 
	;@base16, -> base of counter, ARRL
	;@comp16, ->  pulse width, CCR1 content
	;@mode8,  -> (CCMR)PWM mode: $60 pwm_mode_1, $70 pwm_mode_2
							;additional parameters (use OR) $04 -fast_mode
							; $80 - prelopad enable
	;@polarity8 -> (CCER)  $02 active LO,$00 active Hi
	;@preload8  ->  $80 preload enable, CR1 content
	;SP +9
	;stack frame:
	;[v16a|return|prel|pol|mode|comp|base|presc]
tim2OnePulsePwmCh3Setup
				PUSH A
		;--allocate memory
		SUBW SP , #$01
	;-variables
	#define _004_v8a $00
	#define _004_prel $05
	#define _004_pol $06
	#define _004_mode $07
	#define _004_compH $08
	#define _004_compL $09
	#define _004_baseH $0A
	#define _004_baseL $0B
	#define _004_prescH $0C
	#define _004_prescL $0D
		;--disable timer
	LD A, TIM2_CR1
	AND A, #$FE;
	LD TIM2_CR1,A
	;--prescaler only low	
	LD A, (_002_prescL,SP)
	LD TIM2_PSCR, A
	LD A, TIM2_PSCR
	;--load comparand, Hi firstly
	LD A, (_004_compH,SP)
	LD TIM2_CCR3H, A
	LD A, (_004_compL,SP)
	LD TIM2_CCR3L, A
 
	;--load base, high byte first
	LD A, (_004_baseH,SP)
	LD TIM2_ARRH, A
	LD A, (_004_baseL,SP)
	LD TIM2_ARRL, A
	;--load CCMR1
	LD A, (_004_mode,SP)
	LD TIM2_CCMR3, A
	;--polarity
	; 1)store content of another channels
	LD A, TIM2_CCER2
	AND A, #$F0
	LD (_004_v8a,SP), A; store
	;--2)load data for loading in register
	LD A, (_004_pol,SP)
	OR A, #$01; turn on channel 
	;--3)apply another regs
	OR A, (_004_v8a,SP)
	LD TIM2_CCER2, A
	;--CR1
	LD A, (_004_prel,SP)
	LD TIM2_CR1, A
	OR A, #$08;//ONE PULSE mode, stopped
	LD TIM2_CR1, A
	;--free memory
	ADDW SP, #$01
	POP A
	RET
	;--TEST PASSED!
	;=P R O C E D UR E======tim1OnePulseModeStart=======
	;start one pulse mode
	;SP afer RETURN nas not been changed 
tim2OnePulseModeStart
	LD TIM2_CR1, A
	OR A, #$09; ///ONE PULSE MODE + Go
	LD TIM2_CR1, A
	RET
	
