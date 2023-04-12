;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.0.0 #11528 (Linux)
;--------------------------------------------------------
	.module ram
	.optsdcc -mstm8
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _ram_flash_write_block
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area INITIALIZED
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
	.area RAM_SEG
;	Core/Src/ram.c: 6: void ram_flash_write_block(uint16_t addr, const uint8_t *buf) {
;	-----------------------------------------
;	 function ram_flash_write_block
;	-----------------------------------------
_ram_flash_write_block:
	sub	sp, #2
;	Core/Src/ram.c: 8: FLASH_CR2 = 1 << FLASH_CR2_PRG;
	mov	0x505b+0, #0x01
;	Core/Src/ram.c: 10: FLASH_NCR2 = (uint8_t) ~(1 << FLASH_NCR2_NPRG);
	mov	0x505c+0, #0xfe
;	Core/Src/ram.c: 14: for (uint8_t i = 0; i < BLOCK_SIZE; i++)
	clr	a
00106$:
	cp	a, #0x40
	jrnc	00102$
;	Core/Src/ram.c: 15: _MEM_(addr + i) = buf[i];
	clrw	x
	ld	xl, a
	ldw	y, (0x05, sp)
	ldw	(0x01, sp), x
	addw	y, (0x01, sp)
	clrw	x
	ld	xl, a
	addw	x, (0x07, sp)
	push	a
	ld	a, (x)
	ld	xl, a
	ld	(y), a
	pop	a
;	Core/Src/ram.c: 14: for (uint8_t i = 0; i < BLOCK_SIZE; i++)
	inc	a
	jra	00106$
;	Core/Src/ram.c: 18: while (!(FLASH_IAPSR & (1 << FLASH_IAPSR_EOP)));
00102$:
	ld	a, 0x505f
	bcp	a, #0x04
	jreq	00102$
;	Core/Src/ram.c: 19: }
	addw	sp, #2
	ret
	.area CODE
	.area CONST
	.area INITIALIZER
	.area CABS (ABS)
