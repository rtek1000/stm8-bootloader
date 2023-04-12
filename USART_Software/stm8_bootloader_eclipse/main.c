#include "main.h"

#define IWDG_KEY_ENABLE         0xCC
#define IWDG_KEY_REFRESH        0xAA
#define IWDG_KEY_ACCESS         0x55

#define FLASH_PUKR_KEY1         0x56
#define FLASH_PUKR_KEY2         0xAE
#define FLASH_IAPSR_DUL         3
#define FLASH_IAPSR_EOP         2
#define FLASH_IAPSR_PUL         1

//extern volatile bool received_data_flag;
//extern volatile char received_data;
//extern volatile bool empty_bit_send;

// PC.4
#define BUTTON2_BIT      0x10
// PC.5
#define BUTTON3_BIT      0x20

volatile char data_counter = 0;
volatile int data_buffer = 0;
volatile bool start_bit = false;
volatile bool received_data_flag = false;
//volatile char received_data = 0;

volatile int data_buffer_send = 0;
volatile char data_counter_send = 0;
volatile bool empty_bit_send = true;
volatile bool start_bit_send = false;
volatile bool stop_bit_send = false;
volatile bool pause_bit_send = false;

volatile bool data_bit = false;
#define stop_bit true

volatile bool data_min_inc = false;
volatile bool data_sec_inc = true;
volatile bool data_millis_inc = false;

volatile bool timer_count_enabled = true;

void initSerialReceiver(void);
void receiver_Handle(void);
void serial_sender_byte(unsigned char data);

void initTimer(void);

/**
 * Initialize watchdog:
 * prescaler = /256, timeout = 1.02 s
 */
inline void iwdg_init() {
	IWDG_KR = IWDG_KEY_ENABLE;
	IWDG_KR = IWDG_KEY_ACCESS;
	IWDG_PR = 6;
	IWDG_KR = IWDG_KEY_REFRESH;
}

/**
 * Kick the dog
 */
inline void iwdg_refresh() {
	IWDG_KR = IWDG_KEY_REFRESH;
}

void initSerialReceiver(void) {
	// Input on pin PC3/PC4
	PC_DDR &= ~(BUTTON2_BIT | BUTTON3_BIT);
	// Pull-up on pin PC3/PC4
	PC_CR1 |= BUTTON2_BIT | BUTTON3_BIT;

	/* LOW */
	PC_ODR &= ~BUTTON3_BIT;
}

void receiver_Handle(void) {
	data_counter = 0;
	data_buffer = 0;
	start_bit = false;

	TIM1_CNTRH = 0xFE;
	TIM1_CNTRL = 0x63;

	TIM1_CR1 = 0x05;    // Enable timer

	while (TIM1_CR1 == 0x05) {
		while(!(TIM1_SR1 & 1));

		TIM1_SR1 &= ~TIMx_UIF; // Reset flag

		// 0xFCC5
		TIM1_CNTRH = 0xFC;
		TIM1_CNTRL = 0xC5;

		data_bit = (PC_IDR >> 4) & 1;

		if (start_bit == false) {
			if (data_bit == true) {
				TIM1_CR1 = 0x00;    // Disable timer

				return;
			} else {
				start_bit = true;
			}
		} else {

			if (data_counter < 8) {

				data_buffer |= data_bit << data_counter;

				data_counter++;
			} else {
				if (data_bit == stop_bit) {
					// received_data = data_buffer;

					received_data_flag = true;
				}

				TIM1_CR1 = 0x00;    // Disable timer
			}
		}
	}
}

void serial_sender_byte(unsigned char data) {
	empty_bit_send = false;

	start_bit_send = false;

	stop_bit_send = false;

	data_buffer_send = data;

	data_counter_send = 0;

	TIM2_CNTRH = 0xFC; // 0xFCC5
	TIM2_CNTRL = 0xC5;

	TIM2_CR1 = 0x05;    // Enable timer

	while (empty_bit_send == false) {
		while (!(TIM2_SR1 & 1))
			; // delay

		TIM2_SR1 &= ~TIMx_UIF; // Reset flag

		TIM2_CNTRH = 0xFC; // 0xFCC5
		TIM2_CNTRL = 0xC5;

		if (start_bit_send == false) {
			start_bit_send = true;

			PC_DDR |= BUTTON3_BIT;

		} else {
			if (data_counter_send < 8) {
				if (((data_buffer_send >> data_counter_send) & 1) == true) {
					PC_DDR &= ~BUTTON3_BIT;
				} else {
					PC_DDR |= BUTTON3_BIT;
				}

				data_counter_send++;

			} else {
				if (stop_bit_send == false) {
					stop_bit_send = true;

					PC_DDR &= ~BUTTON3_BIT;

				} else {
					if (pause_bit_send == false) {
						pause_bit_send = true;

					} else {
						if (empty_bit_send == false) {
							empty_bit_send = true;

						} else {
							TIM2_CR1 = 0x00;    // Disable timer
						}
					}
				}
			}
		}
	}
}

void initTimer(void) {
//	disableInterrupts();
//	CLK_CKDIVR = 0x00;  // Set the frequency to 16 MHz

	// Goal: 51.67us; 19353.59kHz (9600 bauds)
	// 16MHz: 0.000000062s; 0.000062ms; 0.062us; 62ns
	// 16MHz / 19353.59kHz = 826.72
	// 65536 - 827 = 64709 (0xFCC5)
	// 826.72 / 2 = 413.36
	// 65536 - 413 = 65123 (0xFE63)

//	TIM1_CNTRH = 0xFE;
//	TIM1_CNTRL = 0x63;
	TIM1_PSCRH = 0x00;   // CLK / 1 = 16MHz
	TIM1_PSCRL = 0x01;   // CLK / 1 = 16MHz
	TIM1_ARRH = 0xFF;    // 16MHz /  1653(0x0675) = 9679.37kHz
	TIM1_ARRL = 0xFF;    // 16MHz /  1653(0x0675) = 9679.37kHz

//	TIM2_CNTRH = 0xFC; // 0xFCC5
//	TIM2_CNTRL = 0xC5;
	TIM2_PSCR = 0x01;   // CLK / 1 = 16MHz
	TIM2_ARRH = 0xFF;    // 16MHz /  1653(0x0675) = 9679.37kHz
	TIM2_ARRL = 0xFF;    // 16MHz /  1653(0x0675) = 9679.37kHz
}

static uint8_t CRC;
#if !RELOCATE_IVT
static uint8_t ivt[128];
#endif
static uint8_t f_ram[128];
static uint8_t rx_buffer[BLOCK_SIZE];
static volatile uint8_t RAM_SEG_LEN;
static void (*flash_write_block)(uint16_t addr, const uint8_t *buf) =
(void (*)(uint16_t, const uint8_t *)) f_ram;

/**
 * Write RAM_SEG section length into RAM_SEG_LEN
 */
inline void get_ram_section_length() {
	__asm__("mov _RAM_SEG_LEN, #l_RAM_SEG");
}

/**
 * Initialize UART1 in 8N1 mode
 */
inline void uart_init() {
	initSerialReceiver();
	initTimer();

//    /* enable UART clock (STM8L only)*/
//    UART_CLK_ENABLE();
//    /* madness.. */
//    UART_BRR2 = ((UART_DIV >> 8) & 0xF0) + (UART_DIV & 0x0F);
//    UART_BRR1 = UART_DIV >> 4;
//    /* enable transmitter and receiver */
//    UART_CR2 = (1 << UART_CR2_TEN) | (1 << UART_CR2_REN);
}

/**
 * Write byte into UART
 */
static void uart_write(uint8_t data) {
	serial_sender_byte(data);

	//while(empty_bit_send == false);
//    UART_DR = data;
//    while (!(UART_SR & (1 << UART_SR_TC)));
}

/**
 * Read byte from UART and reset watchdog
 */
static uint8_t uart_read() {
	iwdg_refresh();

	received_data_flag = false;

	while (received_data_flag == false){
		// wait for line low state
		while((PC_IDR >> 4) & 1);

		receiver_Handle();
	}

	return data_buffer;
}

/**
 * Calculate CRC-8-CCIT.
 * Polynomial: x^8 + x^2 + x + 1 (0x07)
 *
 * @param data input byte
 * @param crc initial CRC
 * @return CRC value
 */
inline uint8_t crc8_update(uint8_t data, uint8_t crc) {
	crc ^= data;
	for (uint8_t i = 0; i < 8; i++)
		crc = (crc & 0x80) ? (crc << 1) ^ 0x07 : crc << 1;
	return crc;
}

/**
 * Send ACK response
 */
static void serial_send_ack() {
	uart_write(0xAA);
	uart_write(0xBB);
}

/**
 * Send NACK response (CRC mismatch)
 */
inline void serial_send_nack() {
	uart_write(0xDE);
	uart_write(0xAD);
}

/**
 * Read BLOCK_SIZE bytes from UART
 *
 * @param dest destination buffer
 */
static void serial_read_block(uint8_t *dest) {
	serial_send_ack();
	for (uint8_t i = 0; i < BLOCK_SIZE; i++) {
		uint8_t rx = uart_read();
		dest[i] = rx;
		CRC = crc8_update(rx, CRC);
	}
}

/**
 * Enter bootloader and perform firmware update
 */
inline void bootloader_exec() {
	uint8_t chunks, crc_rx;
	uint16_t addr = BOOT_ADDR;

	/* enter bootloader */
	for (;;) {
		uint8_t rx = uart_read();
		if (rx != 0xDE)
			continue;
		rx = uart_read();
		if (rx != 0xAD)
			continue;
		rx = uart_read();
		if (rx != 0xBE)
			continue;
		rx = uart_read();
		if (rx != 0xEF)
			continue;
		chunks = uart_read();
		crc_rx = uart_read();
		rx = uart_read();
		if (crc_rx != rx)
			continue;
		break;
	}

#if !RELOCATE_IVT
	/* get application interrupt table */
	serial_read_block(ivt);
	chunks--;
#if BLOCK_SIZE == 64
	chunks--;
	serial_read_block(ivt + BLOCK_SIZE);
#endif
#endif

	/* unlock flash */
	FLASH_PUKR = FLASH_PUKR_KEY1;
	FLASH_PUKR = FLASH_PUKR_KEY2;
	while (!(FLASH_IAPSR & (1 << FLASH_IAPSR_PUL)))
		;

	/* get main firmware */
	for (uint8_t i = 0; i < chunks; i++) {
		serial_read_block(rx_buffer);
		flash_write_block(addr, rx_buffer);
		addr += BLOCK_SIZE;
	}

	/* verify CRC */
	if (CRC != crc_rx) {
		serial_send_nack();
		for (;;)
			;
	}

#if !RELOCATE_IVT
	/* overwrite vector table preserving the reset interrupt */
	*(uint32_t *) ivt = *(uint32_t *) (0x8000);
	flash_write_block(0x8000, ivt);
#if BLOCK_SIZE == 64
	flash_write_block(0x8000 + BLOCK_SIZE, ivt + BLOCK_SIZE);
#endif
#endif

	/* lock flash */
	FLASH_IAPSR &= ~(1 << FLASH_IAPSR_PUL);

	serial_send_ack();

	/* reboot */
	for (;;)
		;
}

/**
 * Copy ram_flash_write_block routine into RAM
 */
inline void ram_cpy() {
	get_ram_section_length();
	for (uint8_t i = 0; i < RAM_SEG_LEN; i++)
		f_ram[i] = ((uint8_t*) ram_flash_write_block)[i];
}

#define OUTPUT_PIN      3

//void timer_isr() __interrupt(TIM4_ISR) {
//    PA_ODR ^= (1 << OUTPUT_PIN);
//    TIM4_SR &= ~(1 << TIM4_SR_UIF);
//}

void bootloader_main() {

    BOOT_PIN_CR1 = 1 << BOOT_PIN;
    if (!(BOOT_PIN_IDR & (1 << BOOT_PIN))) {
        /* execute bootloader */
        CLK_CKDIVR = 0;
        ram_cpy();
        iwdg_init();

    	initSerialReceiver();
    	initTimer();

        bootloader_exec();
    } else {
        /* jump to application */
        BOOT_PIN_CR1 = 0x00;
        BOOT();
    }
}
