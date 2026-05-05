/*
 * PWMTimer2.h
 *
 * Created: 4/7/2025 5:04:31 PM
 *  Author: Ervin Gomez 231226
 */ 

#ifndef PWMTIMER2_H_
#define PWMTIMER2_H_

#include <avr/io.h>
#define invt2 1
#define no_invt2 0

void PWM2A(uint8_t invertido2, uint16_t presc2);
void updateDutyCycle2(uint8_t duty2);

#endif /* PWMTIMER2_H_ */