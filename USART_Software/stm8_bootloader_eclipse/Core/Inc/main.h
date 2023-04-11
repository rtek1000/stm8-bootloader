/*
 * main.h
 *
 *  Created on: 11 de abr. de 2023
 *      Author: user
 */

#ifndef MAIN_H_
#define MAIN_H_

#include <stdint.h>
#include "config.h"
#include "stm8s.h"
#include "ram.h"

#define enableInterrupts()    __asm__("rim") //__asm rim __endasm;
#define disableInterrupts()   __asm__("sim") // __asm sim __endasm;
#define waitForInterrupt()  __asm__("wfi") // __asm wfi __endasm;
#define nop()                 __asm__("nop")    /* No Operation */

#ifndef bool
#define bool    _Bool
#define true    1
#define false   0
#define byte    unsigned char
#endif

#endif /* MAIN_H_ */
