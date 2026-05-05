/*
 * Lab4.c
 *
 * Created: 3/31/2025 4:42:13 PM
 * Author : Ervin Gomez 231226
 */

/****************************************/
// Encabezado
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

int		DIS7SEG[16] = {0x7E, 0x30, 0x6D, 0x79, 0x33, 0x5B, 0x5F, 0x70, 0x7F, 0x7B, 0x77, 0x1F, 0x4E, 0x3D, 0x4F, 0x47};
uint8_t display = 0;
uint8_t contador = 0;
uint8_t unidVolt = 0; 
uint8_t	decVolt	= 0;


/****************************************/
// Function prototypes
void PinChange();
void _ADC(); 
void TMR0(); 
/****************************************/
// Main Function
int main(void) {
	DDRD = 0xFF;  // Configura PORTD como salida
	PORTD = 0;

	DDRB &= ~((1 << PORTB3) | (1 << PORTB4));  //Puerto B como salida
	DDRB |= (1 << PORTB0) | (1 << PORTB1) | (1 << PORTB2); // Configura PB0-PB2 como salidas
	PORTB |= (1 << PORTB3) | (1 << PORTB4);    //Activacion de pull-ups
	
	DDRC |= (1 << PORTC0); // Configura PC0 como salida
	PORTC &= ~(1<<PORTC0);
	UCSR0B = 0x00; 
	
	//if(lectura >= contador){
		
	//}
	
	PinChange();
	_ADC(); 
	TMR0(); 
	
	sei();
	while (1) {
		if (ADCH >= contador)
		{
			PORTC |= (1<< PORTC0);
		}
		else{
			PORTC &= ~(1<< PORTC0);
		}
		_delay_ms(10);
	}
}
/****************************************/
// NON-Interrupt subroutines
void PinChange(void) {
	//Configuración del Pin_Change
	PCICR |= (1 << PCIE0);
	PCMSK0 |= (1 << PCINT3) | (1 << PCINT4);
}

void TMR0(void)
{
	cli(); 
	//Configuración del Clock del reloj
	CLKPR = (1<<CLKPCE); 
	CLKPR = (1<<CLKPS2);  // 1MHz
	
	TCCR0B = (1<<CS02) | (1<<CS00); 
	TCNT0 = 251; 
	TIMSK0 = (1<<TOIE0); 
	
	sei(); 
	
}

void _ADC(void)
{
	ADMUX = 0; 
	ADMUX |= (1<<REFS0) | (1<<ADLAR) | (1 << MUX0) |  (1 << MUX1) | (1<<MUX2);
	
	ADCSRA = 0; 
	ADCSRA |= (1<<ADPS1) | (1<<ADPS2) |  (1<<ADIE) | (1<<ADEN);
	ADCSRA |= (1<<ADSC);
	
}

/****************************************/
// Interrupt routine
ISR(PCINT0_vect) {
	if (!(PINB & (1 << PORTB3))) {
		contador++;
	}
	if (!(PINB & (1 << PORTB4))) {
		contador--;
	}
	//PORTC = contador; //Salida del contador
}

ISR(TIMER0_OVF_vect){
	TCNT0 = 251;
	display++;
	PORTB &= ~((1<<PORTB0) | (1<<PORTB1) | (1<<PORTB2));
	switch(display){
		case 1: 
			PORTB |= (1<<PORTB0);
			PORTD = decVolt ;
			break;
		case 2:
			PORTB |= (1<<PORTB1);
			PORTD = unidVolt;
			break;
		case 3: 
			PORTB |= (1<<PORTB2);
			PORTD = contador;
			break;
		default:
		display = 0; 
	}
}

ISR(ADC_vect)
{
	decVolt = DIS7SEG[ADCH >> 4];
	unidVolt = DIS7SEG[ADCH & 0x0F];
	ADCSRA |= (1<<ADSC); 
}