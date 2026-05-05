/*
 * Prelab4.c
 *
 * Created: 3/29/2025 12:10:31 PM
 * Author : Ervin Gomez 231226
 */ 

/****************************************/
// Encabezado
#include <avr/io.h>
#include <avr/interrupt.h>
/****************************************/
// Function prototypes
void PinChange(void);
/****************************************/
// Main Function
int main(void) {
	DDRC = 0xFF;  // Configura PORTD como salida 
	PORTC = 0;    

	DDRB &= ~((1 << PB3) | (1 << PB4));  //Puerto B como salida 
	PORTB |= (1 << PB3) | (1 << PB4);    //Activacion de pull-ups

	PinChange(); 
	sei(); 

	while (1) {
	}
}
/****************************************/
// NON-Interrupt subroutines
void PinChange(void) {
	//Configuración del Pin_Change
	PCICR |= (1 << PCIE0); 
	PCMSK0 |= (1 << PCINT3) | (1 << PCINT4);  
}
/****************************************/
// Interrupt routine
ISR(PCINT0_vect) {
	uint8_t contador = 0; //variable para mantener el conteo 
	if (!(PINB & (1 << PB3))) {  
		contador++;
	}
	if (!(PINB & (1 << PB4))) {
		contador--;
	}
	PORTC = contador; //Salida del contador 
}
