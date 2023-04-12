;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (Linux)
;--------------------------------------------------------
	.module main
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _serial_sender_byte
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area DATA
_CRC:
	.ds 1
_f_ram:
	.ds 128
_rx_buffer:
	.ds 64
_RAM_SEG_LEN:
	.ds 1
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area INITIALIZED
_flash_write_block:
	.ds 2
;--------------------------------------------------------
; Stack segment in internal ram 
;--------------------------------------------------------
	.area	SSEG
__start__stack:
	.ds	1

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
; interrupt vector 
;--------------------------------------------------------
	.area HOME
__interrupt_vect:
	int s_GSINIT ; reset
	int 0x000000 ; trap
	int 0x000000 ; int0
	int 0x000000 ; int1
	int 0x000000 ; int2
	int 0x000000 ; int3
	int 0x000000 ; int4
	int _EXTI2_handler ; int5
	int 0x000000 ; int6
	int 0x000000 ; int7
	int 0x000000 ; int8
	int 0x000000 ; int9
	int 0x000000 ; int10
	int _TIM1_UPD_handler ; int11
	int 0x000000 ; int12
	int _TIM2_UPD_handler ; int13
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area HOME
	.area GSINIT
	.area GSFINAL
	.area GSINIT
__sdcc_gs_init_startup:
__sdcc_init_data:
; stm8_genXINIT() start
	ldw x, #l_DATA
	jreq	00002$
00001$:
	clr (s_DATA - 1, x)
	decw x
	jrne	00001$
00002$:
	ldw	x, #l_INITIALIZER
	jreq	00004$
00003$:
	ld	a, (s_INITIALIZER - 1, x)
	ld	(s_INITIALIZED - 1, x), a
	decw	x
	jrne	00003$
00004$:
; stm8_genXINIT() end
	.area GSFINAL
	jp	__sdcc_program_startup
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area HOME
	.area HOME
__sdcc_program_startup:
	jp	_main
;	return from main will return to caller
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area CODE
;	Core/Src/main.c: 73: static void uart_write(uint8_t data) {
;	-----------------------------------------
;	 function uart_write
;	-----------------------------------------
_uart_write:
;	Core/Src/main.c: 74: serial_sender_byte(data);
	ld	a, (0x03, sp)
	push	a
	call	_serial_sender_byte
	pop	a
;	Core/Src/main.c: 76: while(empty_bit_send == false);
00101$:
	btjt	_empty_bit_send+0, #0, 00111$
	jra	00101$
00111$:
;	Core/Src/main.c: 79: }
	ret
;	Core/Src/main.c: 84: static uint8_t uart_read() {
;	-----------------------------------------
;	 function uart_read
;	-----------------------------------------
_uart_read:
;	Core/Src/main.c: 51: IWDG_KR = IWDG_KEY_REFRESH;
	mov	0x50e0+0, #0xaa
;	Core/Src/main.c: 86: received_data_flag = false;
	clr	_received_data_flag+0
;	Core/Src/main.c: 88: while(received_data_flag == false);
00101$:
	btjt	_received_data_flag+0, #0, 00117$
	jra	00101$
00117$:
;	Core/Src/main.c: 90: return received_data;
	ld	a, _received_data+0
;	Core/Src/main.c: 95: }
	ret
;	Core/Src/main.c: 115: static void serial_send_ack() {
;	-----------------------------------------
;	 function serial_send_ack
;	-----------------------------------------
_serial_send_ack:
;	Core/Src/main.c: 116: uart_write(0xAA);
	push	#0xaa
	call	_uart_write
	pop	a
;	Core/Src/main.c: 117: uart_write(0xBB);
	push	#0xbb
	call	_uart_write
	pop	a
;	Core/Src/main.c: 118: }
	ret
;	Core/Src/main.c: 133: static void serial_read_block(uint8_t *dest) {
;	-----------------------------------------
;	 function serial_read_block
;	-----------------------------------------
_serial_read_block:
	sub	sp, #4
;	Core/Src/main.c: 134: serial_send_ack();
	call	_serial_send_ack
;	Core/Src/main.c: 135: for (uint8_t i = 0; i < BLOCK_SIZE; i++) {
	clr	(0x03, sp)
00108$:
	ld	a, (0x03, sp)
	cp	a, #0x40
	jrnc	00110$
;	Core/Src/main.c: 136: uint8_t rx = uart_read();
	call	_uart_read
	ld	(0x04, sp), a
;	Core/Src/main.c: 137: dest[i] = rx;
	clrw	x
	ld	a, (0x03, sp)
	ld	xl, a
	addw	x, (0x07, sp)
	ld	a, (0x04, sp)
	ld	(x), a
;	Core/Src/main.c: 138: CRC = crc8_update(rx, CRC);
	ld	a, _CRC+0
;	Core/Src/main.c: 106: crc ^= data;
	xor	a, (0x04, sp)
	ld	xh, a
;	Core/Src/main.c: 107: for (uint8_t i = 0; i < 8; i++)
	clr	(0x04, sp)
00105$:
	ld	a, (0x04, sp)
	cp	a, #0x08
	jrnc	00102$
;	Core/Src/main.c: 108: crc = (crc & 0x80) ? (crc << 1) ^ 0x07 : crc << 1;
	ld	a, xh
	sll	a
	ld	(0x02, sp), a
	rlc	a
	clr	a
	sbc	a, #0x00
	tnzw	x
	jrpl	00112$
	push	a
	ld	a, (0x03, sp)
	xor	a, #0x07
	ld	xh, a
	pop	a
	ld	(0x01, sp), a
	jra	00113$
00112$:
	ld	(0x01, sp), a
	ld	a, (0x02, sp)
	ld	xh, a
00113$:
;	Core/Src/main.c: 107: for (uint8_t i = 0; i < 8; i++)
	inc	(0x04, sp)
	jra	00105$
00102$:
;	Core/Src/main.c: 138: CRC = crc8_update(rx, CRC);
	ld	a, xh
	ld	_CRC+0, a
;	Core/Src/main.c: 135: for (uint8_t i = 0; i < BLOCK_SIZE; i++) {
	inc	(0x03, sp)
	jra	00108$
00110$:
;	Core/Src/main.c: 140: }
	addw	sp, #4
	ret
;	Core/Src/main.c: 223: void main(void) {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
;	Core/Src/main.c: 231: BOOT_PIN_CR1 = 1 << BOOT_PIN;
	mov	0x500d+0, #0x08
;	Core/Src/main.c: 232: if (!(BOOT_PIN_IDR & (1 << BOOT_PIN))) {
	ld	a, 0x500b
	bcp	a, #0x08
	jrne	00102$
;	Core/Src/main.c: 234: CLK_CKDIVR = 0;
	mov	0x50c6+0, #0x00
	ret
00102$:
;	Core/Src/main.c: 242: BOOT_PIN_CR1 = 0x00;
	mov	0x500d+0, #0x00
;	Core/Src/main.c: 243: BOOT();
	jp	0x83C0
;	Core/Src/main.c: 245: }
	ret
	.area CODE
	.area CONST
	.area INITIALIZER
__xinit__flash_write_block:
	.dw _f_ram
	.area CABS (ABS)
