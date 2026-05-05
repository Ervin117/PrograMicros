/*
 * PWMTimer1.h
 *
 * Created: 4/6/2025 9:45:02 PM
 *  Author: Ervin Gomez 231226
 */ 

#ifndef PWM1TIMER1_H_
#define PWM1TIMER1_H_

#include <avr/io.h>
#define invt 1
#define no_invt 0

void PWM1A(uint8_t invertido, uint16_t presc);
void updateDutyCycle1(uint16_t duty); // duty entre 0 y ICR1

#endif /* PWM1TIMER1_H_ */
