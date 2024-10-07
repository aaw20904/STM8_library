;---Author: Andrii Androsovych
;! IMPORTANT NOTE. 
 ; ____  ___ __  __  
 ;|  _ \|_ _|  \/  | 
 ;| |_) || || |\/| | 
 ;|  _ < | || |  | | 
 ;|_| \_\___|_|  |_| 
 ;  instruction MUST be called when all interrupts has been configured
;initialization  UART
;==PROCEDURE==uart1ReceiverSetup
;@baudRate16, divider
;@dataLength8, $10->9bits (1stop 1 start) , $00->8bits
          ;(set  manually below)
;@stopBits8, active only when 8 bits: $00->1bit, $20->2bits
;@parity8, $00-disable, $04-enable: ($02-odd OR $00-even)
;-----------
;SP +5
;  0  1 2 4    5         6      7      8 
;[v8a|A|RET|stopBits|dataLength|baudRate]

uart1ReceiverSetup
  ;--store A
	PUSH A
	;--allocate 1 byte
	SUBW SP, #$01
	#define _U1000_v8a $00 
	#define _U1000_parity $05
	#define _U1000_stopBits $06 
	#define _U1000_dataLength $07
	#define _U1000_baudRateH $08
	#define _U1000_baudRateL $09
	;--disable Rx, Tx
	BRES UART1_CR2, #$2; REN flag
	BRES UART1_CR2, #$3; TEN flag
  ;--when the length 9 bits-jump below
	LD A, #$10
	AND A, (_U1000_dataLength,SP)
	JRNE L_U1000_nsb ;when 9 bits-go to label
	;--when 8 bit set stop bits
	LD A, (_U1000_stopBits,SP)
	LD UART1_CR3, A
L_U1000_nsb
  ;--write data length and parity
	LD A,(_U1000_dataLength,SP)
	OR A, (_U1000_parity,SP)
	LD UART1_CR1, A
	;prepare UART1_BRR2
	;n4 n1
	LD A, (_U1000_baudRateL,SP)
	AND A, #$0F;
	LD ( _U1000_v8a,SP),A; store nibble 1
	LD A, (_U1000_baudRateH,SP)
	AND A, #$f0 ; nibble 4
	OR A, (_U1000_v8a,SP) ; n4+n1
	LD ( _U1000_v8a,SP),A; store BRR2 [n4,n1]
	;;--send -TO REGISTER BRR2
	LD UART1_BRR2 , A
	;----n3 n2
	LD A, (_U1000_baudRateH,SP)
	SWAP A
	AND A, #$F0
	LD ( _U1000_v8a,SP),A; store n3
	LD A, (_U1000_baudRateL,SP)
	SWAP A
	AND A, #$0f
	OR A, ( _U1000_v8a,SP)
	;--send to register BRR1
	LD UART1_BRR1, A
	; RIEN interrupt on receive
	BSET UART1_CR2, #$5 
	;--setting REN bit "Receiver enable"
	BSET UART1_CR2 , #$2
	;--restore stack
	ADDW SP, #$01
	POP A
	RET

;-------------transmitting string flowchart-----------------------
;           turn Transmitter ON -> TEN (b3) UART_CR2
;               waiting, until TXE=1 (bit7)
;                 *1:( index > MA X?)      when true 
;   UART_DR=data[index]          waiting, until TC=1 (b6)
;   waiting, until TXE=1         clear TEN (b3) in UART_CR2
;   Go to *1:                    write any data in UART_DR to clear TXE
;                                   END
;------------------------------------------------------------
;    NOTE: 1)waiting og flags TXE, TE can be done by interrrupts
;     to avoid blocking of an execution stream
;     2) The transmitter may be working incorrectly (one short pulse) 
;        when you don`t wait after turn on. 
;
;-------------------------------------------------------

;==PROCEDURE==uart1TransmitterSetup
;@baudRate16, divider
;@dataLength8, $10->9bits (1stop 1 start) , $00->8bits
          ;(set  manually below)
;@stopBits8, active only when 8 bits: $00->1bit, $20->2bits
;@parity8, $00-disable, $04-enable: ($02-odd OR $00-even)
;-----------
;SP +5
;  0  1 2 4    5         6      7      8 
;[v8a|A|RET|stopBits|dataLength|baudRate]
;NOTE! The transmitter disable after procedure
;You turn it on manually when transmission is starting 

uart1TransmitterSetup
  ;--store A
	PUSH A
	;--allocate 1 byte
	SUBW SP, #$01
	#define _U1001_v8a $00 
	#define _U1001_parity $05
	#define _U1001_stopBits $06 
	#define _U1001_dataLength $07
	#define _U1001_baudRateH $08
	#define _U1001_baudRateL $09
	;--disable Rx, Tx
	BRES UART1_CR2, #$2; REN flag
	BRES UART1_CR2, #$3; TEN flag
  ;--when the length 9 bits-jump below
	LD A, #$10
	AND A, (_U1001_dataLength,SP)
	JRNE L_U1001_nsb ;when 9 bits-go to label
	;--when 8 bit set stop bits
	LD A, (_U1001_stopBits,SP)
	LD UART1_CR3, A
L_U1001_nsb
  ;--write data length and parity
	LD A,(_U1001_dataLength,SP)
	OR A, (_U1001_parity,SP)
	LD UART1_CR1, A
	;prepare UART1_BRR2
	;n4 n1
	LD A, (_U1001_baudRateL,SP)
	AND A, #$0F;
	LD ( _U1001_v8a,SP),A; store nibble 1
	LD A, (_U1001_baudRateH,SP)
	AND A, #$f0 ; nibble 4
	OR A, (_U1001_v8a,SP) ; n4+n1
	LD ( _U1001_v8a,SP),A; store BRR2 [n4,n1]
	;;--send -TO REGISTER BRR2
	LD UART1_BRR2 , A
	;----n3 n2
	LD A, (_U1001_baudRateH,SP)
	SWAP A
	AND A, #$F0
	LD ( _U1001_v8a,SP),A; store n3
	LD A, (_U1001_baudRateL,SP)
	SWAP A
	AND A, #$0f
	OR A, ( _U1001_v8a,SP)
	;--send to register BRR1
	LD UART1_BRR1, A
	; TCIEN interrupt on tx complete
	BSET UART1_CR2, #$6 
	;--setting TEN bit "Transmitter enable"
	;BSET UART1_CR2 , #$3
	;--restore stack
	ADDW SP, #$01
	POP A
	RET
;==PROCEDURE==uart1DuplexSetupIT
;--set up Receiver and Transmitter
; Turn on  TC, RXNE interrupts.
;---------------------
;@baudRate16, divider
;@dataLength8, $10->9bits (1stop 1 start) , $00->8bits
          ;(set  manually below)
;@stopBits8, active only when 8 bits: $00->1bit, $20->2bits
;@parity8, $00-disable, $04-enable: ($02-odd OR $00-even)
;-----------
;SP +5
;  0  1 2 4    5         6      7      8 
;[v8a|A|RET|stopBits|dataLength|baudRate]
;NOTE! The transmitter disable after procedure
;You turn it on manually when transmission is starting 
uart1DuplexSetupIT
  ;--store A
	PUSH A
	;--allocate 1 byte
	SUBW SP, #$01
	#define _U1003_v8a $00 
	#define _U1003_parity $05
	#define _U1003_stopBits $06 
	#define _U1003_dataLength $07
	#define _U1003_baudRateH $08
	#define _U1003_baudRateL $09
	;--disable Rx, Tx
	BRES UART1_CR2, #$2; REN flag
	BRES UART1_CR2, #$3; TEN flag
  ;--when the length 9 bits-jump below
	LD A, #$10
	AND A, (_U1003_dataLength,SP)
	JRNE L_U1003_nsb ;when 9 bits-go to label
	;--when 8 bit set stop bits
	LD A, (_U1003_stopBits,SP)
	LD UART1_CR3, A
L_U1003_nsb
  ;--write data length and parity
	LD A,(_U1003_dataLength,SP)
	OR A, (_U1003_parity,SP)
	LD UART1_CR1, A
	;prepare UART1_BRR2
	;n4 n1
	LD A, (_U1003_baudRateL,SP)
	AND A, #$0F;
	LD ( _U1003_v8a,SP),A; store nibble 1
	LD A, (_U1003_baudRateH,SP)
	AND A, #$f0 ; nibble 4
	OR A, (_U1003_v8a,SP) ; n4+n1
	LD ( _U1003_v8a,SP),A; store BRR2 [n4,n1]
	;;--send -TO REGISTER BRR2
	LD UART1_BRR2 , A
	;----n3 n2
	LD A, (_U1003_baudRateH,SP)
	SWAP A
	AND A, #$F0
	LD ( _U1003_v8a,SP),A; store n3
	LD A, (_U1003_baudRateL,SP)
	SWAP A
	AND A, #$0f
	OR A, ( _U1003_v8a,SP)
	;--send to register BRR1
	LD UART1_BRR1, A
	;turn on interrupt on tx complete, Rx not empty
	BSET UART1_CR2, #$6; TCIEN
	BSET UART1_CR2, #$5; RIEN
	;--set   "receiver enable"
	;BSET UART1_CR2 , #$3
	BSET UART1_CR2 , #$2
	;--restore stack
	ADDW SP, #$01
	POP A
	RET
