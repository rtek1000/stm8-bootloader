/*
 * soft_usart.c
 *
 *  Created on: 11 de abr. de 2023
 *      Author: RTEK1000
 */

#include "soft_usart.h"

// PC.4
#define BUTTON2_BIT      0x10
// PC.5
#define BUTTON3_BIT      0x20

volatile char data_counter = 0;
volatile int data_buffer = 0;
volatile bool start_bit = false;
volatile bool received_data_flag = false;
volatile char received_data = 0;

volatile int data_buffer_send = 0;
volatile char data_counter_send = 0;
volatile bool empty_bit_send = true;
volatile bool start_bit_send = false;
volatile bool stop_bit_send = false;
volatile bool pause_bit_send = false;

void initSerialReceiver(void) {
	disableInterrupts();

	PC_DDR &= ~(BUTTON2_BIT | BUTTON3_BIT);  // Input
	PC_CR2 |= BUTTON2_BIT;                   // interrupt
	PC_CR1 |= BUTTON2_BIT | BUTTON3_BIT;     // Pull-up

	EXTI_CR1 |= 0x20;   // generate interrupt on falling edge.

	enableInterrupts();
}

void receiver_data(unsigned char _data){
	received_data = _data;

	received_data_flag = true;
}

void enableButton2interrupt(void) {
	PC_CR2 |= BUTTON2_BIT;   // Pull-up with interrupt on pin PC4
}

void disableButton2interrupt(void) {
	PC_CR2 &= ~BUTTON2_BIT;   // Pull-up with Not interrupt on pin PC4
}

void setButton3stateHIGH(void) {
	/* Pull-up */
	PC_DDR &= ~BUTTON3_BIT;
}

void setButton3stateLOW(void) {
    /* LOW */
	PC_ODR &= ~BUTTON3_BIT;
	/* Push-pull, fast mode */
	PC_DDR |= BUTTON3_BIT;
}

void receiver_Handle(void) {
	disableButton2interrupt();

	data_counter = 0;
	data_buffer = 0;
	start_bit = false;

	TIM1_CNTRH = 0xFE;
	TIM1_CNTRL = 0x63;

	TIM1_CR1 = 0x05;    // Enable timer
}

void serial_sender_byte(unsigned char data) {
	empty_bit_send = false;

	start_bit_send = false;

	stop_bit_send = false;

	data_buffer_send = data;

	data_counter_send = 0;

	TIM2_CR1 = 0x05;    // Enable timer
}

void EXTI2_handler() __interrupt (5){
	receiver_Handle();
}
