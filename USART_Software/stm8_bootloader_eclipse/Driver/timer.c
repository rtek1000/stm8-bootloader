/*
 This file is part of the W1209 firmware replacement project
 (https://github.com/mister-grumbler/w1209-firmware).

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, version 3.

 This program is distributed in the hope that it will be useful, but
 WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

/*
 - Modified by RTEK1000
 - Mar/27/2023
 - Code adaptation for Arduino IDE sketch.ino
 - Some bug fixes
 - Some functions added
 - Note: Track the size of the code when uploading,
 The maximum I got was 93%
 --> (Sketch uses 7589 bytes (92%))
 --> (Bytes written: 8136)
 --> (Maximum is 8192 bytes)
 - Apr/06/2023
 - Arduino sketch converted to Eclipse project
 --> To free up space in program memory (Flash)

 References:
 - https://github.com/rtek1000/NTC_Lookup_Table_Generator
 - https://github.com/rtek1000/W1209-firmware-modified
 */

/**
 Time base for millis() and Relay timer
 */

#include "timer.h"

#include "soft_usart.h"

volatile bool data_bit = false;
#define stop_bit true

volatile bool data_min_inc = false;
volatile bool data_sec_inc = true;
volatile bool data_millis_inc = false;

volatile bool timer_count_enabled = true;

extern volatile int data_buffer;
extern volatile char data_counter;
extern volatile bool start_bit;

extern volatile int data_buffer_send;
extern volatile char data_counter_send;
extern volatile bool empty_bit_send;
extern volatile bool start_bit_send;
extern volatile bool stop_bit_send;
extern volatile bool pause_bit_send;

void initTimer(void) {
	disableInterrupts();
//	CLK_CKDIVR = 0x00;  // Set the frequency to 16 MHz

	// Goal: 51.67us; 19353.59kHz (9600 bauds)
	// 16MHz: 0.000000062s; 0.000062ms; 0.062us; 62ns
	// 16MHz / 19353.59kHz = 826.72
	// 65536 - 827 = 64709 (0xFCC5)
	// 826.72 / 2 = 413.36
	// 65536 - 413 = 65123 (0xFE63)

	TIM1_CNTRH = 0xFE;
	TIM1_CNTRL = 0x63;
	TIM1_PSCRH = 0x00;   // CLK / 1 = 16MHz
	TIM1_PSCRL = 0x01;   // CLK / 1 = 16MHz
	TIM1_ARRH = 0xFF;    // 16MHz /  1653(0x0675) = 9679.37kHz
	TIM1_ARRL = 0xFF;    // 16MHz /  1653(0x0675) = 9679.37kHz
	TIM1_IER = 0x01;    // Enable interrupt on update event
	// TIM1_CR1 = 0x05;    // Enable timer

	TIM2_CNTRH = 0xFC; // 0xFCC5
	TIM2_CNTRL = 0xC5;
	TIM2_PSCR = 0x01;   // CLK / 1 = 16MHz
	TIM2_ARRH = 0xFF;    // 16MHz /  1653(0x0675) = 9679.37kHz
	TIM2_ARRL = 0xFF;    // 16MHz /  1653(0x0675) = 9679.37kHz
	TIM2_IER = 0x01;    // Enable interrupt on update event
	// TIM2_CR1 = 0x05;    // Enable timer

	enableInterrupts();
}

void TIM1_UPD_handler()
__interrupt (11)
{
	TIM1_SR1 &= ~TIMx_UIF; // Reset flag

	// 0xFCC5
	TIM1_CNTRH = 0xFC;
	TIM1_CNTRL = 0xC5;

	//data_bit = (bool)((PC_IDR & BUTTON2_BIT) == BUTTON2_BIT);
	data_bit = (PC_IDR >> 4) & 1;

	if(start_bit == false) {
		if (data_bit == true) {
			TIM1_CR1 = 0x00;    // Disable timer

			enableButton2interrupt();

			return;
		} else {
			start_bit = true;
		}
	} else {

		if(data_counter < 8) {

			data_buffer |= data_bit << data_counter;

			data_counter++;
		} else {
			if(data_bit == stop_bit) {
				receiver_data(data_buffer);
			}

			TIM1_CR1 = 0x00;    // Disable timer

			enableButton2interrupt();

		}
	}
}

void TIM2_UPD_handler()
__interrupt (13) {
	TIM2_SR1 &= ~TIMx_UIF; // Reset flag

	TIM2_CNTRH = 0xFC;// 0xFCC5
	TIM2_CNTRL = 0xC5;

	if(start_bit_send == false) {
		start_bit_send = true;

		setButton3stateLOW();

	} else {
		if(data_counter_send < 8) {
			if (((data_buffer_send >> data_counter_send) & 1) == true) {
				setButton3stateHIGH();
			} else {
				setButton3stateLOW();
			}

			data_counter_send++;

		} else {
			if(stop_bit_send == false) {
				stop_bit_send = true;

				setButton3stateHIGH();

			} else {
				if(pause_bit_send == false) {
					pause_bit_send = true;

				} else {
					if(empty_bit_send == false) {
						empty_bit_send = true;

					} else {
						TIM2_CR1 = 0x00;    // Disable timer
					}
				}
			}
		}
	}
}
