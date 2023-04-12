;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (Linux)
;--------------------------------------------------------
	.module timer
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _receiver_data
	.globl _enableButton2interrupt
	.globl _setButton3stateLOW
	.globl _setButton3stateHIGH
	.globl _timer_count_enabled
	.globl _data_millis_inc
	.globl _data_sec_inc
	.globl _data_min_inc
	.globl _data_bit
	.globl _initTimer
	.globl _TIM1_UPD_handler
	.globl _TIM2_UPD_handler
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area INITIALIZED
_data_bit::
	.ds 1
_data_min_inc::
	.ds 1
_data_sec_inc::
	.ds 1
_data_millis_inc::
	.ds 1
_timer_count_enabled::
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
;	Core/Src/timer.c: 66: void initTimer(void) {
;	-----------------------------------------
;	 function initTimer
;	-----------------------------------------
_initTimer:
;	Core/Src/timer.c: 67: disableInterrupts();
	sim
;	Core/Src/timer.c: 77: TIM1_CNTRH = 0xFE;
	mov	0x525e+0, #0xfe
;	Core/Src/timer.c: 78: TIM1_CNTRL = 0x63;
	mov	0x525f+0, #0x63
;	Core/Src/timer.c: 79: TIM1_PSCRH = 0x00;   // CLK / 1 = 16MHz
	mov	0x5260+0, #0x00
;	Core/Src/timer.c: 80: TIM1_PSCRL = 0x01;   // CLK / 1 = 16MHz
	mov	0x5261+0, #0x01
;	Core/Src/timer.c: 81: TIM1_ARRH = 0xFF;    // 16MHz /  1653(0x0675) = 9679.37kHz
	mov	0x5262+0, #0xff
;	Core/Src/timer.c: 82: TIM1_ARRL = 0xFF;    // 16MHz /  1653(0x0675) = 9679.37kHz
	mov	0x5263+0, #0xff
;	Core/Src/timer.c: 83: TIM1_IER = 0x01;    // Enable interrupt on update event
	mov	0x5254+0, #0x01
;	Core/Src/timer.c: 86: TIM2_CNTRH = 0xFC; // 0xFCC5
	mov	0x530c+0, #0xfc
;	Core/Src/timer.c: 87: TIM2_CNTRL = 0xC5;
	mov	0x530d+0, #0xc5
;	Core/Src/timer.c: 88: TIM2_PSCR = 0x01;   // CLK / 1 = 16MHz
	mov	0x530e+0, #0x01
;	Core/Src/timer.c: 89: TIM2_ARRH = 0xFF;    // 16MHz /  1653(0x0675) = 9679.37kHz
	mov	0x530f+0, #0xff
;	Core/Src/timer.c: 90: TIM2_ARRL = 0xFF;    // 16MHz /  1653(0x0675) = 9679.37kHz
	mov	0x5310+0, #0xff
;	Core/Src/timer.c: 91: TIM2_IER = 0x01;    // Enable interrupt on update event
	mov	0x5303+0, #0x01
;	Core/Src/timer.c: 94: enableInterrupts();
	rim
;	Core/Src/timer.c: 95: }
	ret
;	Core/Src/timer.c: 97: void TIM1_UPD_handler()
;	-----------------------------------------
;	 function TIM1_UPD_handler
;	-----------------------------------------
_TIM1_UPD_handler:
	clr	a
	div	x, a
;	Core/Src/timer.c: 100: TIM1_SR1 &= ~TIMx_UIF; // Reset flag
	bres	21077, #0
;	Core/Src/timer.c: 103: TIM1_CNTRH = 0xFC;
	mov	0x525e+0, #0xfc
;	Core/Src/timer.c: 104: TIM1_CNTRL = 0xC5;
	mov	0x525f+0, #0xc5
;	Core/Src/timer.c: 107: data_bit = (PC_IDR >> 4) & 1;
	ld	a, 0x500b
	srl	a
	srl	a
	srl	a
	srl	a
	and	a, #0x01
	ld	_data_bit+0, a
;	Core/Src/timer.c: 109: if(start_bit == false) {
	btjf	_start_bit+0, #0, 00134$
	jra	00110$
00134$:
;	Core/Src/timer.c: 110: if (data_bit == true) {
	btjt	_data_bit+0, #0, 00135$
	jra	00102$
00135$:
;	Core/Src/timer.c: 111: TIM1_CR1 = 0x00;    // Disable timer
	mov	0x5250+0, #0x00
;	Core/Src/timer.c: 113: enableButton2interrupt();
	call	_enableButton2interrupt
;	Core/Src/timer.c: 115: return;
	jra	00112$
00102$:
;	Core/Src/timer.c: 117: start_bit = true;
	mov	_start_bit+0, #0x01
	jra	00112$
00110$:
;	Core/Src/timer.c: 121: if(data_counter < 8) {
	ld	a, _data_counter+0
	cp	a, #0x08
	jrnc	00107$
;	Core/Src/timer.c: 123: data_buffer |= data_bit << data_counter;
	clrw	x
	ld	a, _data_bit+0
	ld	xl, a
	ld	a, _data_counter+0
	jreq	00138$
00137$:
	sllw	x
	dec	a
	jrne	00137$
00138$:
	ld	a, xl
	or	a, _data_buffer+1
	rlwa	x
	or	a, _data_buffer+0
	ld	xh, a
	ldw	_data_buffer+0, x
;	Core/Src/timer.c: 125: data_counter++;
	inc	_data_counter+0
	jra	00112$
00107$:
;	Core/Src/timer.c: 127: if(data_bit == stop_bit) {
	btjt	_data_bit+0, #0, 00139$
	jra	00105$
00139$:
;	Core/Src/timer.c: 128: receiver_data(data_buffer);
	ld	a, _data_buffer+1
	push	a
	call	_receiver_data
	pop	a
00105$:
;	Core/Src/timer.c: 131: TIM1_CR1 = 0x00;    // Disable timer
	mov	0x5250+0, #0x00
;	Core/Src/timer.c: 133: enableButton2interrupt();
	call	_enableButton2interrupt
00112$:
;	Core/Src/timer.c: 137: }
	iret
;	Core/Src/timer.c: 139: void TIM2_UPD_handler()
;	-----------------------------------------
;	 function TIM2_UPD_handler
;	-----------------------------------------
_TIM2_UPD_handler:
	clr	a
	div	x, a
;	Core/Src/timer.c: 141: TIM2_SR1 &= ~TIMx_UIF; // Reset flag
	bres	21252, #0
;	Core/Src/timer.c: 143: TIM2_CNTRH = 0xFC;// 0xFCC5
	mov	0x530c+0, #0xfc
;	Core/Src/timer.c: 144: TIM2_CNTRL = 0xC5;
	mov	0x530d+0, #0xc5
;	Core/Src/timer.c: 146: if(start_bit_send == false) {
	btjf	_start_bit_send+0, #0, 00151$
	jra	00117$
00151$:
;	Core/Src/timer.c: 147: start_bit_send = true;
	mov	_start_bit_send+0, #0x01
;	Core/Src/timer.c: 149: setButton3stateLOW();
	call	_setButton3stateLOW
	jra	00119$
00117$:
;	Core/Src/timer.c: 152: if(data_counter_send < 8) {
	ld	a, _data_counter_send+0
	cp	a, #0x08
	jrnc	00114$
;	Core/Src/timer.c: 153: if (((data_buffer_send >> data_counter_send) & 1) == true) {
	ldw	x, _data_buffer_send+0
	ld	a, _data_counter_send+0
	jreq	00154$
00153$:
	sraw	x
	dec	a
	jrne	00153$
00154$:
	ld	a, xl
	and	a, #0x01
	ld	xl, a
	clr	a
	ld	xh, a
	decw	x
	jrne	00102$
;	Core/Src/timer.c: 154: setButton3stateHIGH();
	call	_setButton3stateHIGH
	jra	00103$
00102$:
;	Core/Src/timer.c: 156: setButton3stateLOW();
	call	_setButton3stateLOW
00103$:
;	Core/Src/timer.c: 159: data_counter_send++;
	inc	_data_counter_send+0
	jra	00119$
00114$:
;	Core/Src/timer.c: 162: if(stop_bit_send == false) {
	btjf	_stop_bit_send+0, #0, 00158$
	jra	00111$
00158$:
;	Core/Src/timer.c: 163: stop_bit_send = true;
	mov	_stop_bit_send+0, #0x01
;	Core/Src/timer.c: 165: setButton3stateHIGH();
	call	_setButton3stateHIGH
	jra	00119$
00111$:
;	Core/Src/timer.c: 168: if(pause_bit_send == false) {
	btjf	_pause_bit_send+0, #0, 00159$
	jra	00108$
00159$:
;	Core/Src/timer.c: 169: pause_bit_send = true;
	mov	_pause_bit_send+0, #0x01
	jra	00119$
00108$:
;	Core/Src/timer.c: 172: if(empty_bit_send == false) {
	btjf	_empty_bit_send+0, #0, 00160$
	jra	00105$
00160$:
;	Core/Src/timer.c: 173: empty_bit_send = true;
	mov	_empty_bit_send+0, #0x01
	jra	00119$
00105$:
;	Core/Src/timer.c: 176: TIM2_CR1 = 0x00;    // Disable timer
	mov	0x5300+0, #0x00
00119$:
;	Core/Src/timer.c: 182: }
	iret
	.area CODE
	.area CONST
	.area INITIALIZER
__xinit__data_bit:
	.db #0x00	;  0
__xinit__data_min_inc:
	.db #0x00	;  0
__xinit__data_sec_inc:
	.db #0x01	;  1
__xinit__data_millis_inc:
	.db #0x00	;  0
__xinit__timer_count_enabled:
	.db #0x01	;  1
	.area CABS (ABS)
