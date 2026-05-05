/*
 * PreLab5.c
 *
 * Created: 4/6/2025 5:55:32 PM
 * Author : Ervin Gomez 231226
 */ 

/****************************************/
// Encabezado (Libraries)
#define F_CPU 16000000
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include "PWM0/PWMTimer0.h"
#include "PWM1/PWMTimer1.h"
#include "PWM2/PWMTimer2.h"

uint16_t manual = 0; 
uint16_t mcount = 0; 
uint8_t duty2 = 0; 
uint16_t duty = 0;

/****************************************/
// Function prototypes
void setup(); 
void _ADC(); 

/****************************************/
// Main Function
int main(void){
	
	setup(); 
	_ADC(); 
	
	while (1)
	{
		updateDutyCycle1(duty);
		updateDutyCycle2(duty2);
		_delay_ms(1);
	}
}

/****************************************/
// NON-Interrupt subroutines
void setup()
{
	cli(); 
	CLKPR = (1<<CLKPCE);
	CLKPR = (1<<CLKPS2); //Frecuancia de CPU 1Mhz
	PWM1A(no_invt, 64); 
	PWM2A(no_invt2, 64); 
	//PWM0A(no_invt, 64);
	
	DDRB |= (1<<PORTB5);
	PORTB &= ~(1<<PORTB5);
	
	TCCR0A &= ~((1 << WGM01) | (1 << WGM00));
	TCCR0B |= (1 << CS00); //| (1 << CS00); // Prescaler de 64
	TIMSK0 |= (1 << TOIE0);
	
	UCSR0B = 0;
	sei(); 
}

void _ADC(void)
{
	ADMUX = 0;
	ADMUX |= (1<<REFS0) | (1<<ADLAR) | (1 << MUX0) |  (1 << MUX1) | (1<<MUX2); //
	
	ADCSRA = 0;
	ADCSRA |= (1<<ADPS1) | (1<<ADPS2) |  (1<<ADIE) | (1<<ADEN);
	ADCSRA |= (1<<ADSC);
	
}
/****************************************/
// Interrupt routines
ISR(ADC_vect)
{
	uint8_t currentADC = ADMUX & 0x07;
	uint8_t temp = ADCH;
	if (currentADC == 7)
	{
		duty = 8 + (temp*(38-8)/255);
		ADMUX = 0;
		ADMUX |= (1<<REFS0) | (1<<ADLAR); 
		ADMUX |= (1 << MUX1) | (1<<MUX2); 
	}
	else if (currentADC == 6)
	{
		duty2 = 7 + (temp*(37-7)/255);
		ADMUX = 0;
		ADMUX |= (1<<REFS0) | (1<<ADLAR);
		ADMUX |= (1 << MUX0) | (1<<MUX2); 
	}
	else if (currentADC == 5)
	{
		manual = ADCH;
		ADMUX = 0;
		ADMUX |= (1<<REFS0) | (1<<ADLAR);
		ADMUX |= (1 << MUX0) |  (1 << MUX1) | (1<<MUX2);
	}
	ADCSRA |= (1<<ADSC);
}

ISR(TIMER0_OVF_vect)
{
	if (mcount < manual )
	{
		PORTB |= (1<<PORTB5);
	}
	else
	{
		PORTB &= ~(1<<PORTB5);
	}
	mcount++;
	if (mcount > 255)
	{
		mcount = 0; 
	}
}