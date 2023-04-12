/*
 * soft_usart.h
 *
 *  Created on: 11 de abr. de 2023
 *      Author: RTEK1000
 */

#ifndef CORE_INC_SOFT_USART_H_
#define CORE_INC_SOFT_USART_H_

#include "main.h"

void initSerialReceiver(void);
void setButton3stateHIGH(void);
void setButton3stateLOW(void);
void enableButton2interrupt(void);
void disableButton2interrupt(void);
void receiver_Handle(void);
void receiver_data(unsigned char _data);
void serial_sender_byte(unsigned char data);
void EXTI2_handler() __interrupt (5);
#endif /* CORE_INC_SOFT_USART_H_ */
