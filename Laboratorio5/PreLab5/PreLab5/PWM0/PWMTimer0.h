/*
 * PWMTimer0.h
 *
 * Created: 4/6/2025 7:32:22 PM
 *  Author: Ervin Gomez 231226
 */ 


#ifndef PWMTIMER0_H_
#define PWMTIMER0_H_

#include <avr/io.h>
#define invt 1
#define no_invt 0
void PWM0A(uint8_t invertido, uint16_t presc);
void updateDutyCycle(uint8_t duty0);

#endif /* PWMTIMER0_H_ */