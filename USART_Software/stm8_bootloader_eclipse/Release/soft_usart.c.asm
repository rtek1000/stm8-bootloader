;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (Linux)
;--------------------------------------------------------
	.module soft_usart
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _pause_bit_send
	.globl _stop_bit_send
	.globl _start_bit_send
	.globl _empty_bit_send
	.globl _data_counter_send
	.globl _data_buffer_send
	.globl _received_data
	.globl _received_data_flag
	.globl _start_bit
	.globl _data_buffer
	.globl _data_counter
	.globl _initSerialReceiver
	.globl _receiver_data
	.globl _enableButton2interrupt
	.globl _disableButton2interrupt
	.globl _setButton3stateHIGH
	.globl _setButton3stateLOW
	.globl _receiver_Handle
	.globl _serial_sender_byte
	.globl _EXTI2_handler
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area INITIALIZED
_data_counter::
	.ds 1
_data_buffer::
	.ds 2
_start_bit::
	.ds 1
_received_data_flag::
	.ds 1
_received_data::
	.ds 1
_data_buffer_send::
	.ds 2
_data_counter_send::
	.ds 1
_empty_bit_send::
	.ds 1
_start_bit_send::
	.ds 1
_stop_bit_send::
	.ds 1
_pause_bit_send::
	.ds 1
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area DABS (ABS)

; default segment ordering for linker
	.area HOME
	.area GSINIT
	.area GSFINAL
	.area CONST
	.area INITIALIZER
	.area CODE

;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area HOME
	.area GSINIT
	.area GSFINAL
	.area GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area HOME
	.area HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area CODE
;	Core/Src/soft_usart.c: 28: void initSerialReceiver(void) {
;	-----------------------------------------
;	 function initSerialReceiver
;	-----------------------------------------
_initSerialReceiver:
;	Core/Src/soft_usart.c: 29: disableInterrupts();
	sim
;	Core/Src/soft_usart.c: 31: PC_DDR &= ~(BUTTON2_BIT | BUTTON3_BIT);  // Input
	ld	a, 0x500c
	and	a, #0xcf
	ld	0x500c, a
;	Core/Src/soft_usart.c: 32: PC_CR2 |= BUTTON2_BIT;                   // interrupt
	bset	20494, #4
;	Core/Src/soft_usart.c: 33: PC_CR1 |= BUTTON2_BIT | BUTTON3_BIT;     // Pull-up
	ld	a, 0x500d
	or	a, #0x30
	ld	0x500d, a
;	Core/Src/soft_usart.c: 35: EXTI_CR1 |= 0x20;   // generate interrupt on falling edge.
	ld	a, 0x50a0
	or	a, #0x20
	ld	0x50a0, a
;	Core/Src/soft_usart.c: 37: enableInterrupts();
	rim
;	Core/Src/soft_usart.c: 38: }
	ret
;	Core/Src/soft_usart.c: 40: void receiver_data(unsigned char _data){
;	-----------------------------------------
;	 function receiver_data
;	-----------------------------------------
_receiver_data:
;	Core/Src/soft_usart.c: 41: received_data = _data;
	ld	a, (0x03, sp)
	ld	_received_data+0, a
;	Core/Src/soft_usart.c: 43: received_data_flag = true;
	mov	_received_data_flag+0, #0x01
;	Core/Src/soft_usart.c: 44: }
	ret
;	Core/Src/soft_usart.c: 46: void enableButton2interrupt(void) {
;	-----------------------------------------
;	 function enableButton2interrupt
;	-----------------------------------------
_enableButton2interrupt:
;	Core/Src/soft_usart.c: 47: PC_CR2 |= BUTTON2_BIT;   // Pull-up with interrupt on pin PC4
	bset	20494, #4
;	Core/Src/soft_usart.c: 48: }
	ret
;	Core/Src/soft_usart.c: 50: void disableButton2interrupt(void) {
;	-----------------------------------------
;	 function disableButton2interrupt
;	-----------------------------------------
_disableButton2interrupt:
;	Core/Src/soft_usart.c: 51: PC_CR2 &= ~BUTTON2_BIT;   // Pull-up with Not interrupt on pin PC4
	bres	20494, #4
;	Core/Src/soft_usart.c: 52: }
	ret
;	Core/Src/soft_usart.c: 54: void setButton3stateHIGH(void) {
;	-----------------------------------------
;	 function setButton3stateHIGH
;	-----------------------------------------
_setButton3stateHIGH:
;	Core/Src/soft_usart.c: 56: PC_DDR &= ~BUTTON3_BIT;
	bres	20492, #5
;	Core/Src/soft_usart.c: 57: }
	ret
;	Core/Src/soft_usart.c: 59: void setButton3stateLOW(void) {
;	-----------------------------------------
;	 function setButton3stateLOW
;	-----------------------------------------
_setButton3stateLOW:
;	Core/Src/soft_usart.c: 61: PC_ODR &= ~BUTTON3_BIT;
	bres	20490, #5
;	Core/Src/soft_usart.c: 63: PC_DDR |= BUTTON3_BIT;
	bset	20492, #5
;	Core/Src/soft_usart.c: 64: }
	ret
;	Core/Src/soft_usart.c: 66: void receiver_Handle(void) {
;	-----------------------------------------
;	 function receiver_Handle
;	-----------------------------------------
_receiver_Handle:
;	Core/Src/soft_usart.c: 67: disableButton2interrupt();
	call	_disableButton2interrupt
;	Core/Src/soft_usart.c: 69: data_counter = 0;
	clr	_data_counter+0
;	Core/Src/soft_usart.c: 70: data_buffer = 0;
	clrw	x
	ldw	_data_buffer+0, x
;	Core/Src/soft_usart.c: 71: start_bit = false;
	clr	_start_bit+0
;	Core/Src/soft_usart.c: 73: TIM1_CNTRH = 0xFE;
	mov	0x525e+0, #0xfe
;	Core/Src/soft_usart.c: 74: TIM1_CNTRL = 0x63;
	mov	0x525f+0, #0x63
;	Core/Src/soft_usart.c: 76: TIM1_CR1 = 0x05;    // Enable timer
	mov	0x5250+0, #0x05
;	Core/Src/soft_usart.c: 77: }
	ret
;	Core/Src/soft_usart.c: 79: void serial_sender_byte(unsigned char data) {
;	-----------------------------------------
;	 function serial_sender_byte
;	-----------------------------------------
_serial_sender_byte:
;	Core/Src/soft_usart.c: 80: empty_bit_send = false;
	clr	_empty_bit_send+0
;	Core/Src/soft_usart.c: 82: start_bit_send = false;
	clr	_start_bit_send+0
;	Core/Src/soft_usart.c: 84: stop_bit_send = false;
	clr	_stop_bit_send+0
;	Core/Src/soft_usart.c: 86: data_buffer_send = data;
	clrw	x
	ld	a, (0x03, sp)
	ld	xl, a
	ldw	_data_buffer_send+0, x
;	Core/Src/soft_usart.c: 88: data_counter_send = 0;
	clr	_data_counter_send+0
;	Core/Src/soft_usart.c: 90: TIM2_CR1 = 0x05;    // Enable timer
	mov	0x5300+0, #0x05
;	Core/Src/soft_usart.c: 91: }
	ret
;	Core/Src/soft_usart.c: 93: void EXTI2_handler() __interrupt (5){
;	-----------------------------------------
;	 function EXTI2_handler
;	-----------------------------------------
_EXTI2_handler:
;	Core/Src/soft_usart.c: 94: receiver_Handle();
	call	_receiver_Handle
;	Core/Src/soft_usart.c: 95: }
	iret
	.area CODE
	.area CONST
	.area INITIALIZER
__xinit__data_counter:
	.db #0x00	; 0
__xinit__data_buffer:
	.dw #0x0000
__xinit__start_bit:
	.db #0x00	;  0
__xinit__received_data_flag:
	.db #0x00	;  0
__xinit__received_data:
	.db #0x00	; 0
__xinit__data_buffer_send:
	.dw #0x0000
__xinit__data_counter_send:
	.db #0x00	; 0
__xinit__empty_bit_send:
	.db #0x01	;  1
__xinit__start_bit_send:
	.db #0x00	;  0
__xinit__stop_bit_send:
	.db #0x00	;  0
__xinit__pause_bit_send:
	.db #0x00	;  0
	.area CABS (ABS)
