/*
 * timer.h
 *
 *  Created on: 11 de abr. de 2023
 *      Author: RTEK1000
 */

#ifndef TIMER_H_
#define TIMER_H_

#include "main.h"

void initTimer(void);
void TIM1_UPD_handler() __interrupt (11);
void TIM2_UPD_handler() __interrupt (13);

#endif /* CORE_INC_TIMER_H_ */
